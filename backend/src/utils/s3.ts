/**
 * AWS S3 Upload Utility
 *
 * Handles file uploads to S3 bucket with image compression.
 * Generates presigned URLs for secure temporary access.
 */

import { S3Client, PutObjectCommand, DeleteObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import sharp from 'sharp';
import { randomUUID } from 'crypto';
import { promises as fs } from 'fs';
import path from 'path';

// Check if AWS credentials are configured
const hasAwsCredentials = process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY;

// Initialize S3 client with credentials from environment variables (only if credentials exist)
const s3Client = hasAwsCredentials ? new S3Client({
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
}) : null;

const S3_BUCKET = process.env.S3_BUCKET || 'ai-parenting-dev';
const USE_LOCAL_STORAGE = !hasAwsCredentials;

// Local storage configuration (fallback when AWS not configured)
const LOCAL_UPLOADS_DIR = process.env.UPLOADS_DIR || 'uploads';
const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

/**
 * Compress image using Sharp library
 * Resizes to max 1920px width while maintaining aspect ratio
 * Converts to JPEG format with 85% quality
 *
 * @param fileBuffer - Original image file buffer
 * @returns Compressed image buffer
 */
export async function compressImage(fileBuffer: Buffer): Promise<Buffer> {
  try {
    // Compress and resize image
    const compressed = await sharp(fileBuffer)
      .resize(1920, null, {
        withoutEnlargement: true, // Don't upscale smaller images
        fit: 'inside', // Maintain aspect ratio
      })
      .jpeg({
        quality: 85, // 85% quality for good balance between size and quality
        progressive: true, // Progressive JPEG for better web loading
      })
      .toBuffer();

    console.log(`📸 Image compressed: ${fileBuffer.length} → ${compressed.length} bytes`);
    return compressed;
  } catch (error) {
    console.error('Error compressing image:', error);
    throw new Error('Failed to compress image');
  }
}

/**
 * Upload file to S3 bucket
 * Automatically compresses images before upload
 *
 * @param fileBuffer - File content as buffer
 * @param userId - User ID for organizing files
 * @param originalFilename - Original filename for reference
 * @param contentType - MIME type of the file
 * @returns S3 key of uploaded file
 */
export async function uploadToS3(
  fileBuffer: Buffer,
  userId: string,
  originalFilename: string,
  contentType: string
): Promise<string> {
  try {
    // Compress image if it's an image file
    let uploadBuffer = fileBuffer;
    if (contentType.startsWith('image/')) {
      uploadBuffer = await compressImage(fileBuffer);
    }

    // Generate unique key/filename with user ID prefix for organization
    const timestamp = Date.now();
    const fileExtension = originalFilename.split('.').pop() || 'jpg';
    const uniqueFilename = `${timestamp}-${randomUUID()}.${fileExtension}`;
    const fileKey = `${userId}/${uniqueFilename}`;

    // Use local storage if AWS credentials not configured
    if (USE_LOCAL_STORAGE) {
      // Save to local uploads directory
      const userDir = path.join(LOCAL_UPLOADS_DIR, userId);
      await fs.mkdir(userDir, { recursive: true });

      const filePath = path.join(userDir, uniqueFilename);
      await fs.writeFile(filePath, uploadBuffer);

      console.log(`💾 Saved locally: ${fileKey} (${uploadBuffer.length} bytes)`);
      return fileKey;
    }

    // Upload to S3 with server-side encryption (production)
    const command = new PutObjectCommand({
      Bucket: S3_BUCKET,
      Key: fileKey,
      Body: uploadBuffer,
      ContentType: contentType.startsWith('image/') ? 'image/jpeg' : contentType,
      ServerSideEncryption: 'AES256', // Server-side encryption for security
      Metadata: {
        userId,
        originalFilename,
        uploadedAt: new Date().toISOString(),
      },
    });

    await s3Client!.send(command);

    console.log(`📤 Uploaded to S3: ${fileKey} (${uploadBuffer.length} bytes)`);
    return fileKey;
  } catch (error) {
    console.error('Error uploading file:', error);
    throw new Error('Failed to upload file');
  }
}

/**
 * Delete file from S3 bucket or local storage
 *
 * @param fileKey - S3 key or local file path
 */
export async function deleteFromS3(fileKey: string): Promise<void> {
  try {
    // Delete from local storage
    if (USE_LOCAL_STORAGE) {
      const filePath = path.join(LOCAL_UPLOADS_DIR, fileKey);
      await fs.unlink(filePath);
      console.log(`🗑️ Deleted locally: ${fileKey}`);
      return;
    }

    // Delete from S3 (production)
    const command = new DeleteObjectCommand({
      Bucket: S3_BUCKET,
      Key: fileKey,
    });

    await s3Client!.send(command);
    console.log(`🗑️ Deleted from S3: ${fileKey}`);
  } catch (error) {
    console.error('Error deleting file:', error);
    throw new Error('Failed to delete file');
  }
}

/**
 * Generate presigned URL for temporary access to S3 object or local file URL
 * URL expires after 24 hours (86400 seconds) for S3, permanent for local
 *
 * @param fileKey - S3 key or local file path
 * @returns Presigned URL valid for 24 hours (S3) or local HTTP URL
 */
export async function getPresignedUrl(fileKey: string): Promise<string> {
  try {
    // Return local URL if using local storage
    if (USE_LOCAL_STORAGE) {
      // Return HTTP URL to access file via Express static middleware
      const url = `${BASE_URL}/uploads/${fileKey}`;
      console.log(`🔗 Generated local URL: ${url}`);
      return url;
    }

    // Generate presigned URL with 24-hour expiry for S3 (production)
    const command = new GetObjectCommand({
      Bucket: S3_BUCKET,
      Key: fileKey,
    });

    // Generate presigned URL with 24-hour expiry
    const url = await getSignedUrl(s3Client!, command, {
      expiresIn: 86400, // 24 hours in seconds
    });

    console.log(`🔗 Generated presigned URL: ${url}`);
    return url;
  } catch (error) {
    console.error('Error generating presigned URL:', error);
    throw new Error('Failed to generate presigned URL');
  }
}

/**
 * Generate presigned URLs for multiple S3 keys
 * Useful for batch operations on photo lists
 *
 * @param s3Keys - Array of S3 keys
 * @returns Array of presigned URLs
 */
export async function getPresignedUrls(s3Keys: string[]): Promise<string[]> {
  try {
    const urls = await Promise.all(
      s3Keys.map((key) => getPresignedUrl(key))
    );
    return urls;
  } catch (error) {
    console.error('Error generating presigned URLs:', error);
    throw new Error('Failed to generate presigned URLs');
  }
}
