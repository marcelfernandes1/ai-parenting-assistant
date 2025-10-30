/**
 * User Profile Routes
 *
 * Endpoints for managing user profile data including onboarding information.
 * All routes require authentication (JWT token).
 */

import express, { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticateToken } from '../middleware/auth';
import bcrypt from 'bcrypt';
import { deleteFromS3, getPresignedUrl } from '../utils/s3';
import Stripe from 'stripe';

const router = express.Router();
const prisma = new PrismaClient();

// Initialize Stripe client (only if STRIPE_SECRET_KEY is configured)
const stripe = process.env.STRIPE_SECRET_KEY
  ? new Stripe(process.env.STRIPE_SECRET_KEY, { apiVersion: '2025-10-29.clover' })
  : null;

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
      skipOnboarding, // New flag to allow skipping onboarding without providing all data
    } = req.body;

    // If skipOnboarding is true, just mark onboarding as complete without updating profile
    if (skipOnboarding === true) {
      const updatedUser = await prisma.user.update({
        where: {
          id: userId,
        },
        data: {
          onboardingComplete: true,
          updatedAt: new Date(),
        },
      });

      return res.status(200).json({
        message: 'Onboarding skipped successfully',
        user: {
          id: updatedUser.id,
          email: updatedUser.email,
          subscriptionTier: updatedUser.subscriptionTier,
          onboardingComplete: updatedUser.onboardingComplete,
          createdAt: updatedUser.createdAt,
          updatedAt: updatedUser.updatedAt,
        },
      });
    }

    // Validate required field: mode (only if not skipping)
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

/**
 * PUT /user/email
 *
 * Change user's email address.
 * Requires current password for verification.
 *
 * Request body:
 * - newEmail: string (new email address)
 * - password: string (current password for verification)
 *
 * Returns: Success message
 */
router.put('/email', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from authenticated token
    const userId = (req as any).user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Extract request data
    const { newEmail, password } = req.body;

    // Validate inputs
    if (!newEmail || !password) {
      return res.status(400).json({
        error: 'Missing required fields: newEmail and password are required',
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(newEmail)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    // Fetch current user from database
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Verify current password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid password' });
    }

    // Check if new email is already in use
    const existingUser = await prisma.user.findUnique({
      where: { email: newEmail },
    });

    if (existingUser && existingUser.id !== userId) {
      return res.status(409).json({
        error: 'Email already in use',
      });
    }

    // Update email in database
    await prisma.user.update({
      where: { id: userId },
      data: {
        email: newEmail,
        updatedAt: new Date(),
      },
    });

    return res.status(200).json({
      message: 'Email updated successfully',
      newEmail: newEmail,
    });
  } catch (error) {
    console.error('Error updating email:', error);

    return res.status(500).json({
      error: 'Failed to update email',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * PUT /user/password
 *
 * Change user's password.
 * Requires current password for verification.
 *
 * Request body:
 * - currentPassword: string
 * - newPassword: string
 * - confirmPassword: string
 *
 * Returns: Success message
 */
router.put('/password', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from authenticated token
    const userId = (req as any).user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Extract request data
    const { currentPassword, newPassword, confirmPassword } = req.body;

    // Validate inputs
    if (!currentPassword || !newPassword || !confirmPassword) {
      return res.status(400).json({
        error: 'Missing required fields: currentPassword, newPassword, and confirmPassword are required',
      });
    }

    // Validate passwords match
    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        error: 'New password and confirmation do not match',
      });
    }

    // Validate password strength
    if (newPassword.length < 8) {
      return res.status(400).json({
        error: 'Password must be at least 8 characters long',
      });
    }

    // Check for at least one number
    if (!/\d/.test(newPassword)) {
      return res.status(400).json({
        error: 'Password must contain at least one number',
      });
    }

    // Fetch current user from database
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Verify current password
    const isPasswordValid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password in database
    await prisma.user.update({
      where: { id: userId },
      data: {
        passwordHash: hashedPassword,
        updatedAt: new Date(),
      },
    });

    return res.status(200).json({
      message: 'Password updated successfully',
    });
  } catch (error) {
    console.error('Error updating password:', error);

    return res.status(500).json({
      error: 'Failed to update password',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * POST /user/toggle-mode
 *
 * Switch user mode from PREGNANCY to PARENTING.
 * This is a one-way toggle and cannot be reversed.
 *
 * Request body:
 * - babyName: string
 * - babyGender: BabyGender
 * - babyBirthDate: Date
 *
 * Returns: Success message with updated profile
 */
router.post('/toggle-mode', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from authenticated token
    const userId = (req as any).user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Extract request data
    const { babyName, babyGender, babyBirthDate } = req.body;

    // Validate inputs
    if (!babyName || !babyGender || !babyBirthDate) {
      return res.status(400).json({
        error: 'Missing required fields: babyName, babyGender, and babyBirthDate are required',
      });
    }

    // Fetch current user profile
    const profile = await prisma.userProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      return res.status(404).json({ error: 'User profile not found' });
    }

    // Verify current mode is PREGNANCY
    if (profile.mode !== 'PREGNANCY') {
      return res.status(400).json({
        error: 'Mode toggle only allowed from PREGNANCY to PARENTING',
      });
    }

    // Update profile to PARENTING mode with baby details
    const updatedProfile = await prisma.userProfile.update({
      where: { userId },
      data: {
        mode: 'PARENTING',
        babyName,
        babyGender,
        babyBirthDate: new Date(babyBirthDate),
        dueDate: null, // Clear due date since baby is now born
        updatedAt: new Date(),
      },
    });

    return res.status(200).json({
      message: 'Successfully switched to Parenting mode',
      profile: {
        ...updatedProfile,
        parentingPhilosophy: updatedProfile.parentingPhilosophy
          ? JSON.parse(updatedProfile.parentingPhilosophy as string)
          : null,
        religiousViews: updatedProfile.religiousViews
          ? JSON.parse(updatedProfile.religiousViews as string)
          : null,
      },
    });
  } catch (error) {
    console.error('Error toggling mode:', error);

    return res.status(500).json({
      error: 'Failed to toggle mode',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * DELETE /user/account
 *
 * Delete user account and all associated data.
 * This action is irreversible.
 *
 * Request body:
 * - password: string (for verification)
 *
 * Returns: Success message
 */
router.delete('/account', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from authenticated token
    const userId = (req as any).user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Extract password for verification
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({ error: 'Password is required for account deletion' });
    }

    // Fetch current user from database
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid password' });
    }

    // Cancel Stripe subscription if active
    if (stripe && user.stripeSubscriptionId) {
      try {
        await stripe.subscriptions.cancel(user.stripeSubscriptionId);
        console.log(`Canceled Stripe subscription: ${user.stripeSubscriptionId}`);
      } catch (stripeError) {
        console.error('Error canceling Stripe subscription:', stripeError);
        // Continue with deletion even if Stripe cancellation fails
      }
    }

    // Fetch all photos to delete from S3
    const photos = await prisma.photo.findMany({
      where: { userId },
    });

    // Delete all photos from S3
    for (const photo of photos) {
      try {
        await deleteFromS3(photo.s3Key);
        console.log(`Deleted photo from S3: ${photo.s3Key}`);
      } catch (s3Error) {
        console.error(`Error deleting photo ${photo.s3Key} from S3:`, s3Error);
        // Continue with deletion even if S3 deletion fails
      }
    }

    // Delete all user data in a transaction
    // Order matters: delete children before parents (foreign key constraints)
    await prisma.$transaction(async (tx) => {
      // Delete all messages
      await tx.message.deleteMany({
        where: { userId },
      });

      // Delete all milestones
      await tx.milestone.deleteMany({
        where: { userId },
      });

      // Delete all photo records
      await tx.photo.deleteMany({
        where: { userId },
      });

      // Delete all usage tracking records
      await tx.usageTracking.deleteMany({
        where: { userId },
      });

      // Delete user profile
      await tx.userProfile.deleteMany({
        where: { userId },
      });

      // Delete user account
      await tx.user.delete({
        where: { id: userId },
      });
    });

    console.log(`Successfully deleted account for user: ${userId}`);

    return res.status(200).json({
      message: 'Account deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting account:', error);

    return res.status(500).json({
      error: 'Failed to delete account',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * GET /user/data-export
 *
 * Export all user data in JSON format (GDPR compliance).
 * Includes profile, messages, milestones, and photo metadata with presigned URLs.
 *
 * Returns: JSON file with all user data
 */
router.get('/data-export', authenticateToken, async (req: Request, res: Response) => {
  try {
    // Extract userId from authenticated token
    const userId = (req as any).user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized - user ID not found' });
    }

    // Fetch all user data from database
    const [user, profile, messages, milestones, photos, usageRecords] = await Promise.all([
      prisma.user.findUnique({
        where: { id: userId },
        select: {
          id: true,
          email: true,
          subscriptionTier: true,
          subscriptionStatus: true,
          subscriptionExpiresAt: true,
          onboardingComplete: true,
          createdAt: true,
          updatedAt: true,
        },
      }),
      prisma.userProfile.findUnique({
        where: { userId },
      }),
      prisma.message.findMany({
        where: { userId },
        orderBy: { timestamp: 'asc' },
      }),
      prisma.milestone.findMany({
        where: { userId },
        orderBy: { achievedAt: 'desc' },
      }),
      prisma.photo.findMany({
        where: { userId },
        orderBy: { uploadedAt: 'desc' },
      }),
      prisma.usageTracking.findMany({
        where: { userId },
        orderBy: { date: 'desc' },
      }),
    ]);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Generate presigned URLs for photos (valid for 7 days)
    const photosWithUrls = await Promise.all(
      photos.map(async (photo) => {
        try {
          const url = await getPresignedUrl(photo.s3Key, 7 * 24 * 60 * 60); // 7 days
          return {
            ...photo,
            url,
            urlExpiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
          };
        } catch (error) {
          console.error(`Error generating presigned URL for ${photo.s3Key}:`, error);
          return {
            ...photo,
            url: null,
            urlError: 'Failed to generate download URL',
          };
        }
      })
    );

    // Compile all data into export object
    const exportData = {
      exportedAt: new Date().toISOString(),
      user: {
        ...user,
        profile: profile
          ? {
              ...profile,
              parentingPhilosophy: profile.parentingPhilosophy
                ? JSON.parse(profile.parentingPhilosophy as string)
                : null,
              religiousViews: profile.religiousViews
                ? JSON.parse(profile.religiousViews as string)
                : null,
            }
          : null,
      },
      messages: messages.map((msg) => ({
        ...msg,
        content: msg.content || msg.textContent, // Handle both field names
      })),
      milestones,
      photos: photosWithUrls,
      usageHistory: usageRecords,
    };

    // Set headers for file download
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', `attachment; filename="my-data-export-${userId}.json"`);

    return res.status(200).json(exportData);
  } catch (error) {
    console.error('Error exporting user data:', error);

    return res.status(500).json({
      error: 'Failed to export data',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
