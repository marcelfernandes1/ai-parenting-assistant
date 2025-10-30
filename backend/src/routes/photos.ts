/**
 * Photos API Routes
 *
 * Handles photo uploads to S3, photo listing, deletion, and AI vision analysis.
 * Uses Multer middleware for multipart file handling.
 */

import express, { Response } from 'express';
import multer from 'multer';
import { PrismaClient } from '@prisma/client';
import { authenticateToken, AuthenticatedRequest } from '../middleware/auth';
import { uploadToS3, deleteFromS3, getPresignedUrl } from '../utils/s3';

const router = express.Router();
const prisma = new PrismaClient();

// Configure Multer for memory storage (files stored in RAM temporarily)
// Files will be processed and uploaded to S3, not saved to disk
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max file size
    files: 3, // Max 3 files per request
  },
  fileFilter: (req, file, cb) => {
    // Validate file types: JPEG, PNG, HEIC
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/heic', 'image/heif'];

    if (allowedMimeTypes.includes(file.mimetype)) {
      cb(null, true); // Accept file
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, and HEIC images are allowed.'));
    }
  },
});

/**
 * POST /photos/upload
 * Upload single or multiple photos (max 3) to S3
 *
 * Free users limited to 100 photos total.
 * Compresses images before upload to save storage.
 * Returns photo objects with presigned URLs for immediate display.
 */
router.post(
  '/upload',
  authenticateToken,
  upload.array('photos', 3), // Accept up to 3 files with field name 'photos'
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.userId;
      const files = req.files as Express.Multer.File[];

      // Validate that at least one file was uploaded
      if (!files || files.length === 0) {
        return res.status(400).json({ error: 'No files uploaded' });
      }

      console.log(`📸 Uploading ${files.length} photo(s) for user ${userId}`);

      // Check user's subscription tier for photo limits
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { subscriptionTier: true },
      });

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      // Free users: check if photo limit reached (100 photos max)
      if (user.subscriptionTier === 'FREE') {
        const existingPhotosCount = await prisma.photo.count({
          where: { userId },
        });

        // Check if upload would exceed limit
        if (existingPhotosCount + files.length > 100) {
          return res.status(429).json({
            error: 'photo_limit_reached',
            message: 'Free tier allows maximum 100 photos. Upgrade to Premium for unlimited storage.',
            currentCount: existingPhotosCount,
            limit: 100,
          });
        }
      }

      // Process each uploaded file
      const uploadedPhotos = [];

      for (const file of files) {
        try {
          // Upload to S3 (automatically compresses images)
          const s3Key = await uploadToS3(
            file.buffer,
            userId,
            file.originalname,
            file.mimetype
          );

          // Create Photo record in database
          const photo = await prisma.photo.create({
            data: {
              userId,
              s3Key,
              metadata: {
                originalName: file.originalname,
                mimeType: file.mimetype,
                size: file.size,
                uploadedAt: new Date().toISOString(),
              },
            },
          });

          // Generate presigned URL for immediate access (24-hour expiry)
          const url = await getPresignedUrl(s3Key);

          uploadedPhotos.push({
            id: photo.id,
            url,
            s3Key: photo.s3Key,
            uploadedAt: photo.uploadedAt,
            metadata: photo.metadata,
          });

          console.log(`✅ Uploaded photo ${photo.id} to S3: ${s3Key}`);
        } catch (error) {
          console.error(`❌ Failed to upload file ${file.originalname}:`, error);
          // Continue with other files even if one fails
        }
      }

      // Return array of successfully uploaded photos
      res.status(201).json({
        message: `Successfully uploaded ${uploadedPhotos.length} photo(s)`,
        photos: uploadedPhotos,
      });
    } catch (error) {
      console.error('Error uploading photos:', error);

      // Handle Multer-specific errors
      if (error instanceof multer.MulterError) {
        if (error.code === 'LIMIT_FILE_SIZE') {
          return res.status(400).json({ error: 'File size exceeds 10MB limit' });
        }
        if (error.code === 'LIMIT_FILE_COUNT') {
          return res.status(400).json({ error: 'Maximum 3 files allowed per upload' });
        }
      }

      res.status(500).json({ error: 'Failed to upload photos' });
    }
  }
);

export default router;
