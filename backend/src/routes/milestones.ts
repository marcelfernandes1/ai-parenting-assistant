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
import { suggestMilestones } from '../utils/milestones';

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

/**
 * PUT /milestones/:id
 * Update an existing milestone
 *
 * Request body (all fields optional, only provided fields will be updated):
 * - name: string - optional
 * - achievedDate: ISO date string - optional
 * - notes: string - optional
 *
 * Verifies milestone belongs to authenticated user before updating.
 * Returns updated milestone.
 */
router.put(
  '/:id',
  authenticateToken,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.userId;
      const milestoneId = req.params.id;

      // Extract update data from request body
      const { name, achievedDate, notes } = req.body;

      console.log(`🏆 Updating milestone ${milestoneId} for user ${userId}`);

      // Fetch milestone to verify ownership
      const existingMilestone = await prisma.milestone.findUnique({
        where: { id: milestoneId },
        select: { id: true, userId: true },
      });

      // Check if milestone exists
      if (!existingMilestone) {
        return res.status(404).json({ error: 'Milestone not found' });
      }

      // Verify milestone belongs to the authenticated user (security check)
      if (existingMilestone.userId !== userId) {
        return res.status(403).json({
          error: 'Forbidden',
          message: 'You do not have permission to update this milestone',
        });
      }

      // Build update data object (only include provided fields)
      const updateData: any = {};

      if (name !== undefined) {
        updateData.name = name;
      }

      if (achievedDate !== undefined) {
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

        updateData.achievedDate = achievedDateObj;
      }

      if (notes !== undefined) {
        updateData.notes = notes || null;
      }

      // Update milestone in database
      const updatedMilestone = await prisma.milestone.update({
        where: { id: milestoneId },
        data: updateData,
      });

      console.log(`✅ Updated milestone ${milestoneId}`);

      // Generate presigned URLs for photos
      const presignedPhotoUrls = updatedMilestone.photoUrls.length > 0
        ? await Promise.all(
            updatedMilestone.photoUrls.map((s3Key) => getPresignedUrl(s3Key))
          )
        : [];

      // Return updated milestone
      res.status(200).json({
        message: 'Milestone updated successfully',
        milestone: {
          id: updatedMilestone.id,
          type: updatedMilestone.type,
          name: updatedMilestone.name,
          achievedDate: updatedMilestone.achievedDate,
          notes: updatedMilestone.notes,
          photoUrls: presignedPhotoUrls,
          aiSuggested: updatedMilestone.aiSuggested,
          confirmed: updatedMilestone.confirmed,
          createdAt: updatedMilestone.createdAt,
          updatedAt: updatedMilestone.updatedAt,
        },
      });
    } catch (error) {
      console.error('Error updating milestone:', error);
      res.status(500).json({ error: 'Failed to update milestone' });
    }
  }
);

/**
 * DELETE /milestones/:id
 * Delete a specific milestone
 *
 * Verifies milestone belongs to authenticated user before deletion.
 * Permanently removes milestone from database.
 */
router.delete(
  '/:id',
  authenticateToken,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.userId;
      const milestoneId = req.params.id;

      console.log(`🗑️ Deleting milestone ${milestoneId} for user ${userId}`);

      // Fetch milestone to verify ownership
      const milestone = await prisma.milestone.findUnique({
        where: { id: milestoneId },
        select: { id: true, userId: true, name: true },
      });

      // Check if milestone exists
      if (!milestone) {
        return res.status(404).json({ error: 'Milestone not found' });
      }

      // Verify milestone belongs to the authenticated user (security check)
      if (milestone.userId !== userId) {
        return res.status(403).json({
          error: 'Forbidden',
          message: 'You do not have permission to delete this milestone',
        });
      }

      // Delete milestone from database
      await prisma.milestone.delete({
        where: { id: milestoneId },
      });

      console.log(`✅ Deleted milestone ${milestoneId}: ${milestone.name}`);

      res.status(200).json({
        message: 'Milestone deleted successfully',
        milestoneId,
      });
    } catch (error) {
      console.error('Error deleting milestone:', error);
      res.status(500).json({ error: 'Failed to delete milestone' });
    }
  }
);

/**
 * GET /milestones/suggestions
 * Get age-appropriate milestone suggestions for baby
 *
 * Returns milestone suggestions based on baby's age from user profile.
 * Filters out milestones that have already been confirmed by the user.
 * Suggestions are not saved to database until user confirms them.
 */
router.get(
  '/suggestions',
  authenticateToken,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.userId;

      console.log(`🏆 Fetching milestone suggestions for user ${userId}`);

      // Fetch user profile to get baby's birth date
      const userProfile = await prisma.userProfile.findUnique({
        where: { userId },
        select: { babyBirthDate: true },
      });

      // Check if user has set baby birth date
      if (!userProfile || !userProfile.babyBirthDate) {
        return res.status(400).json({
          error: 'Baby birth date not set',
          message: 'Please set baby birth date in your profile to get milestone suggestions',
        });
      }

      // Fetch all confirmed milestones to exclude from suggestions
      const confirmedMilestones = await prisma.milestone.findMany({
        where: {
          userId,
          confirmed: true,
        },
        select: { name: true },
      });

      // Extract milestone names
      const loggedMilestoneNames = confirmedMilestones.map((m) => m.name);

      // Get age-appropriate suggestions
      const suggestions = suggestMilestones(
        userProfile.babyBirthDate,
        loggedMilestoneNames
      );

      console.log(`✅ Returning ${suggestions.length} milestone suggestions`);

      // Return suggestions (not yet saved to database)
      res.status(200).json({
        suggestions: suggestions.map((s) => ({
          type: s.type,
          name: s.name,
          description: s.description,
          ageRangeMonths: s.ageRangeMonths,
          aiSuggested: true, // Mark as AI-suggested
        })),
        count: suggestions.length,
      });
    } catch (error) {
      console.error('Error fetching milestone suggestions:', error);
      res.status(500).json({ error: 'Failed to fetch milestone suggestions' });
    }
  }
);

export default router;
