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

// Initialize S3 client with credentials from environment variables
const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
});

const S3_BUCKET = process.env.S3_BUCKET || 'ai-parenting-dev';

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

    // Generate unique S3 key with user ID prefix for organization
    const timestamp = Date.now();
    const fileExtension = originalFilename.split('.').pop() || 'jpg';
    const uniqueFilename = `${timestamp}-${randomUUID()}.${fileExtension}`;
    const s3Key = `${userId}/${uniqueFilename}`;

    // Upload to S3 with server-side encryption
    const command = new PutObjectCommand({
      Bucket: S3_BUCKET,
      Key: s3Key,
      Body: uploadBuffer,
      ContentType: contentType.startsWith('image/') ? 'image/jpeg' : contentType,
      ServerSideEncryption: 'AES256', // Server-side encryption for security
      Metadata: {
        userId,
        originalFilename,
        uploadedAt: new Date().toISOString(),
      },
    });

    await s3Client.send(command);

    console.log(`📤 Uploaded to S3: ${s3Key} (${uploadBuffer.length} bytes)`);
    return s3Key;
  } catch (error) {
    console.error('Error uploading to S3:', error);
    throw new Error('Failed to upload file to S3');
  }
}

/**
 * Delete file from S3 bucket
 *
 * @param s3Key - S3 key of file to delete
 */
export async function deleteFromS3(s3Key: string): Promise<void> {
  try {
    const command = new DeleteObjectCommand({
      Bucket: S3_BUCKET,
      Key: s3Key,
    });

    await s3Client.send(command);
    console.log(`🗑️ Deleted from S3: ${s3Key}`);
  } catch (error) {
    console.error('Error deleting from S3:', error);
    throw new Error('Failed to delete file from S3');
  }
}

/**
 * Generate presigned URL for temporary access to S3 object
 * URL expires after 24 hours (86400 seconds)
 *
 * @param s3Key - S3 key of file
 * @returns Presigned URL valid for 24 hours
 */
export async function getPresignedUrl(s3Key: string): Promise<string> {
  try {
    const command = new GetObjectCommand({
      Bucket: S3_BUCKET,
      Key: s3Key,
    });

    // Generate presigned URL with 24-hour expiry
    const url = await getSignedUrl(s3Client, command, {
      expiresIn: 86400, // 24 hours in seconds
    });

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
