/**
 * Milestones API Routes
 *
 * Handles milestone CRUD operations for tracking baby development.
 * Milestones track physical, feeding, sleep, social, and health achievements.
 */

import express, { Response } from 'express';
import { PrismaClient, MilestoneType } from '@prisma/client';
import { authenticateToken, AuthenticatedRequest } from '../middleware/auth';
import { getPresignedUrl } from '../utils/s3';

const router = express.Router();
const prisma = new PrismaClient();

/**
 * GET /milestones
 * Retrieve user's milestones with optional filters
 *
 * Query params:
 * - type: filter by milestone type (PHYSICAL, FEEDING, SLEEP, SOCIAL, HEALTH) - optional
 * - confirmed: filter by confirmed status (true/false) - optional
 *
 * Returns milestones ordered by achievedDate descending (most recent first).
 * Generates presigned URLs for any photos associated with milestones.
 */
router.get(
  '/',
  authenticateToken,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.userId;

      // Parse optional filter parameters
      const typeFilter = req.query.type as MilestoneType | undefined;
      const confirmedFilter = req.query.confirmed as string | undefined;

      console.log(`🏆 Fetching milestones for user ${userId}`);

      // Build where clause with userId and optional filters
      const whereClause: any = { userId };

      // Filter by milestone type if provided
      if (typeFilter && Object.values(MilestoneType).includes(typeFilter)) {
        whereClause.type = typeFilter;
      }

      // Filter by confirmed status if provided
      if (confirmedFilter !== undefined) {
        whereClause.confirmed = confirmedFilter === 'true';
      }

      // Fetch milestones from database
      const milestones = await prisma.milestone.findMany({
        where: whereClause,
        orderBy: { achievedDate: 'desc' }, // Most recent milestones first
        select: {
          id: true,
          type: true,
          name: true,
          achievedDate: true,
          notes: true,
          photoUrls: true,
          aiSuggested: true,
          confirmed: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      // Generate presigned URLs for photos in photoUrls array
      const milestonesWithPresignedUrls = await Promise.all(
        milestones.map(async (milestone) => {
          // For each photo URL (S3 key), generate a presigned URL
          const presignedPhotoUrls = await Promise.all(
            milestone.photoUrls.map((s3Key) => getPresignedUrl(s3Key))
          );

          return {
            id: milestone.id,
            type: milestone.type,
            name: milestone.name,
            achievedDate: milestone.achievedDate,
            notes: milestone.notes,
            photoUrls: presignedPhotoUrls, // Replace S3 keys with presigned URLs
            aiSuggested: milestone.aiSuggested,
            confirmed: milestone.confirmed,
            createdAt: milestone.createdAt,
            updatedAt: milestone.updatedAt,
          };
        })
      );

      console.log(`✅ Returned ${milestones.length} milestone(s)`);

      res.status(200).json({
        milestones: milestonesWithPresignedUrls,
        count: milestones.length,
      });
    } catch (error) {
      console.error('Error fetching milestones:', error);
      res.status(500).json({ error: 'Failed to fetch milestones' });
    }
  }
);

/**
 * POST /milestones
 * Create a new milestone for baby development
 *
 * Request body:
 * - type: MilestoneType (PHYSICAL, FEEDING, SLEEP, SOCIAL, HEALTH) - required
 * - name: string - required
 * - achievedDate: ISO date string - required
 * - notes: string - optional
 * - photoUrls: string[] (S3 keys) - optional
 * - confirmed: boolean - optional (default: true)
 *
 * Validates achievedDate is not in the future.
 * Returns created milestone with generated ID.
 */
router.post(
  '/',
  authenticateToken,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.userId;

      // Extract milestone data from request body
      const {
        type,
        name,
        achievedDate,
        notes,
        photoUrls,
        confirmed,
      } = req.body;

      // Validate required fields
      if (!type || !name || !achievedDate) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['type', 'name', 'achievedDate'],
        });
      }

      // Validate type is a valid MilestoneType enum value
      if (!Object.values(MilestoneType).includes(type)) {
        return res.status(400).json({
          error: 'Invalid milestone type',
          validTypes: Object.values(MilestoneType),
        });
      }

      // Parse and validate achievedDate
      const achievedDateObj = new Date(achievedDate);

      // Check if date is valid
      if (isNaN(achievedDateObj.getTime())) {
        return res.status(400).json({
          error: 'Invalid achievedDate format',
          message: 'achievedDate must be a valid ISO date string',
        });
      }

      // Validate achievedDate is not in the future
      const now = new Date();
      if (achievedDateObj > now) {
        return res.status(400).json({
          error: 'Invalid achievedDate',
          message: 'achievedDate cannot be in the future',
        });
      }

      console.log(`🏆 Creating milestone for user ${userId}: ${name} (${type})`);

      // Create milestone in database
      const milestone = await prisma.milestone.create({
        data: {
          userId,
          type,
          name,
          achievedDate: achievedDateObj,
          notes: notes || null,
          photoUrls: photoUrls || [],
          confirmed: confirmed !== undefined ? confirmed : true,
          aiSuggested: false, // Default to false for user-created milestones
        },
      });

      console.log(`✅ Created milestone ${milestone.id}`);

      // Generate presigned URLs for photos if any
      const presignedPhotoUrls = milestone.photoUrls.length > 0
        ? await Promise.all(
            milestone.photoUrls.map((s3Key) => getPresignedUrl(s3Key))
          )
        : [];

      // Return created milestone with presigned photo URLs
      res.status(201).json({
        message: 'Milestone created successfully',
        milestone: {
          id: milestone.id,
          type: milestone.type,
          name: milestone.name,
          achievedDate: milestone.achievedDate,
          notes: milestone.notes,
          photoUrls: presignedPhotoUrls,
          aiSuggested: milestone.aiSuggested,
          confirmed: milestone.confirmed,
          createdAt: milestone.createdAt,
          updatedAt: milestone.updatedAt,
        },
      });
    } catch (error) {
      console.error('Error creating milestone:', error);
      res.status(500).json({ error: 'Failed to create milestone' });
    }
  }
);

export default router;
