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

/**
 * GET /photos/list
 * Retrieve user's photo list with pagination and optional filters
 *
 * Query params:
 * - limit: number of photos per page (default: 20, max: 100)
 * - offset: number of photos to skip (default: 0)
 * - milestoneId: filter by specific milestone (optional)
 * - albumId: filter by specific album (optional)
 *
 * Returns photos with presigned URLs for immediate display.
 */
router.get(
  '/list',
  authenticateToken,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.userId;

      // Parse pagination parameters with validation
      const limit = Math.min(parseInt(req.query.limit as string) || 20, 100); // Max 100 photos per request
      const offset = parseInt(req.query.offset as string) || 0;

      // Parse optional filter parameters
      const milestoneId = req.query.milestoneId as string | undefined;
      const albumId = req.query.albumId as string | undefined;

      console.log(`📸 Fetching photos for user ${userId} (limit: ${limit}, offset: ${offset})`);

      // Build where clause with userId and optional filters
      const whereClause: any = { userId };

      if (milestoneId) {
        whereClause.milestoneId = milestoneId;
      }

      if (albumId) {
        whereClause.albumId = albumId;
      }

      // Fetch photos from database with pagination
      const photos = await prisma.photo.findMany({
        where: whereClause,
        orderBy: { uploadedAt: 'desc' }, // Most recent photos first
        take: limit,
        skip: offset,
        select: {
          id: true,
          s3Key: true,
          uploadedAt: true,
          metadata: true,
          milestoneId: true,
          albumId: true,
          analysisResults: true,
        },
      });

      // Generate presigned URLs for all photos (24-hour expiry)
      const photosWithUrls = await Promise.all(
        photos.map(async (photo) => {
          const url = await getPresignedUrl(photo.s3Key);

          return {
            id: photo.id,
            url,
            s3Key: photo.s3Key,
            uploadedAt: photo.uploadedAt,
            metadata: photo.metadata,
            milestoneId: photo.milestoneId,
            albumId: photo.albumId,
            analysisResults: photo.analysisResults,
          };
        })
      );

      // Get total count for pagination (helps frontend know if there are more pages)
      const totalCount = await prisma.photo.count({ where: whereClause });

      res.status(200).json({
        photos: photosWithUrls,
        pagination: {
          limit,
          offset,
          total: totalCount,
          hasMore: offset + photos.length < totalCount,
        },
      });

      console.log(`✅ Returned ${photos.length} photos (total: ${totalCount})`);
    } catch (error) {
      console.error('Error fetching photos:', error);
      res.status(500).json({ error: 'Failed to fetch photos' });
    }
  }
);

/**
 * DELETE /photos/:id
 * Delete a specific photo from S3 and database
 *
 * Verifies photo ownership before deletion for security.
 * Permanently removes photo from S3 bucket and database.
 */
router.delete(
  '/:id',
  authenticateToken,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.userId;
      const photoId = req.params.id;

      console.log(`🗑️ Deleting photo ${photoId} for user ${userId}`);

      // Fetch photo to verify ownership and get S3 key
      const photo = await prisma.photo.findUnique({
        where: { id: photoId },
        select: {
          id: true,
          userId: true,
          s3Key: true,
        },
      });

      // Check if photo exists
      if (!photo) {
        return res.status(404).json({ error: 'Photo not found' });
      }

      // Verify photo belongs to the authenticated user (security check)
      if (photo.userId !== userId) {
        return res.status(403).json({
          error: 'Forbidden',
          message: 'You do not have permission to delete this photo',
        });
      }

      // Delete from S3 bucket first
      try {
        await deleteFromS3(photo.s3Key);
        console.log(`✅ Deleted photo from S3: ${photo.s3Key}`);
      } catch (s3Error) {
        console.error('Error deleting from S3:', s3Error);
        // Continue with database deletion even if S3 deletion fails
        // This prevents orphaned database records
      }

      // Delete from database
      await prisma.photo.delete({
        where: { id: photoId },
      });

      console.log(`✅ Deleted photo ${photoId} from database`);

      res.status(200).json({
        message: 'Photo deleted successfully',
        photoId,
      });
    } catch (error) {
      console.error('Error deleting photo:', error);
      res.status(500).json({ error: 'Failed to delete photo' });
    }
  }
);

export default router;
