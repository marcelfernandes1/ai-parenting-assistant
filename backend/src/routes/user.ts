/**
 * User Profile Routes
 *
 * Endpoints for managing user profile data including onboarding information.
 * All routes require authentication (JWT token).
 */

import express, { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticateToken } from '../middleware/auth';

const router = express.Router();
const prisma = new PrismaClient();

/**
 * PUT /user/profile
 *
 * Update user profile with onboarding data.
 * This endpoint is called after onboarding completion to save all collected information.
 *
 * Request body:
 * - mode: UserMode (PREGNANCY | PARENTING)
 * - dueDate?: Date (if pregnant)
 * - babyBirthDate?: Date (if parent)
 * - babyName?: string
 * - babyGender?: BabyGender
 * - parentingPhilosophy?: ParentingPhilosophy
 * - religiousViews?: ReligiousView[]
 * - culturalBackground?: string
 * - concerns?: Concern[]
 * - notificationPreferences?: object
 *
 * Returns: Updated user profile data
 */
router.put('/profile', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from authenticated token (set by authenticateToken middleware)
    const userId = (req as any).user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Extract onboarding data from request body
    const {
      mode,
      dueDate,
      babyBirthDate,
      babyName,
      babyGender,
      parentingPhilosophy,
      religiousViews,
      culturalBackground,
      concerns,
      notificationPreferences,
    } = req.body;

    // Validate required field: mode
    if (!mode || !['PREGNANCY', 'PARENTING'].includes(mode)) {
      return res.status(400).json({
        error: 'Invalid or missing mode (must be PREGNANCY or PARENTING)',
      });
    }

    // Convert date strings to Date objects if provided
    const parsedDueDate = dueDate ? new Date(dueDate) : null;
    const parsedBabyBirthDate = babyBirthDate ? new Date(babyBirthDate) : null;

    // Prepare notification preferences JSON
    const notificationPrefs = notificationPreferences || {
      dailyMilestoneUpdates: true,
      weeklyTipsGuidance: true,
      milestoneReminders: true,
    };

    // Update UserProfile in database
    // Use upsert to create if doesn't exist, or update if it does
    const updatedProfile = await prisma.userProfile.upsert({
      where: {
        userId: userId,
      },
      // If profile exists, update these fields
      update: {
        mode: mode,
        dueDate: parsedDueDate,
        babyBirthDate: parsedBabyBirthDate,
        babyName: babyName || null,
        babyGender: babyGender || null,
        parentingPhilosophy: parentingPhilosophy ? JSON.stringify(parentingPhilosophy) : undefined,
        religiousViews: religiousViews ? JSON.stringify(religiousViews) : undefined,
        culturalBackground: culturalBackground || null,
        concerns: concerns || [],
        notificationPreferences: notificationPrefs,
        updatedAt: new Date(),
      },
      // If profile doesn't exist, create with these fields
      create: {
        userId: userId,
        mode: mode,
        dueDate: parsedDueDate,
        babyBirthDate: parsedBabyBirthDate,
        babyName: babyName || null,
        babyGender: babyGender || null,
        parentingPhilosophy: parentingPhilosophy ? JSON.stringify(parentingPhilosophy) : undefined,
        religiousViews: religiousViews ? JSON.stringify(religiousViews) : undefined,
        culturalBackground: culturalBackground || null,
        concerns: concerns || [],
        notificationPreferences: notificationPrefs,
      },
    });

    // Mark onboarding as complete in User model
    // This flag is checked by the router to determine if user should see onboarding
    const updatedUser = await prisma.user.update({
      where: {
        id: userId,
      },
      data: {
        onboardingComplete: true,
        updatedAt: new Date(),
      },
    });

    // Return success response with updated user data (not profile)
    // Frontend expects 'user' field with User model data including onboardingComplete flag
    return res.status(200).json({
      message: 'Profile updated successfully',
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        subscriptionTier: updatedUser.subscriptionTier,
        onboardingComplete: updatedUser.onboardingComplete,
        // Include profile data in user response
        mode: updatedProfile.mode,
        babyName: updatedProfile.babyName,
        babyBirthDate: updatedProfile.babyBirthDate?.toISOString() || null,
        parentingPhilosophy: updatedProfile.parentingPhilosophy
          ? JSON.parse(updatedProfile.parentingPhilosophy as string)
          : null,
        religiousViews: updatedProfile.religiousViews
          ? JSON.parse(updatedProfile.religiousViews as string)
          : null,
        primaryConcerns: updatedProfile.concerns,
        createdAt: updatedUser.createdAt,
        updatedAt: updatedUser.updatedAt,
      },
    });
  } catch (error) {
    console.error('Error updating user profile:', error);

    // Return error response
    return res.status(500).json({
      error: 'Failed to update profile',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * GET /user/profile
 *
 * Retrieve user profile data.
 * Used to check if onboarding is complete and to display profile information.
 *
 * Returns: User profile data or 404 if not found
 */
router.get('/profile', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from authenticated token
    const userId = (req as any).user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Fetch user profile from database
    const profile = await prisma.userProfile.findUnique({
      where: {
        userId: userId,
      },
    });

    // Return 404 if profile doesn't exist (onboarding not completed)
    if (!profile) {
      return res.status(404).json({
        error: 'Profile not found',
        message: 'User has not completed onboarding',
      });
    }

    // Return profile data
    return res.status(200).json({
      profile: {
        ...profile,
        // Parse JSON fields back to objects
        parentingPhilosophy: profile.parentingPhilosophy
          ? JSON.parse(profile.parentingPhilosophy as string)
          : null,
        religiousViews: profile.religiousViews
          ? JSON.parse(profile.religiousViews as string)
          : null,
      },
    });
  } catch (error) {
    console.error('Error fetching user profile:', error);

    return res.status(500).json({
      error: 'Failed to fetch profile',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
