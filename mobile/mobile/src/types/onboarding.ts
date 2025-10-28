/**
 * Onboarding Types
 *
 * Type definitions for onboarding flow data collection.
 * Matches backend UserProfile model structure.
 */

/**
 * User's current parenting stage
 */
export type UserMode = 'PREGNANCY' | 'PARENTING';

/**
 * Baby's gender
 */
export type BabyGender = 'MALE' | 'FEMALE' | 'PREFER_NOT_TO_SAY';

/**
 * Parenting philosophy options
 */
export type ParentingPhilosophy =
  | 'GENTLE_ATTACHMENT'
  | 'STRUCTURED_SCHEDULED'
  | 'BALANCED_FLEXIBLE'
  | 'FIGURING_IT_OUT'
  | 'PREFER_NOT_TO_SAY';

/**
 * Religious background options
 */
export type ReligiousView =
  | 'CHRISTIAN'
  | 'MUSLIM'
  | 'JEWISH'
  | 'HINDU'
  | 'BUDDHIST'
  | 'SECULAR'
  | 'SPIRITUAL'
  | 'PREFER_NOT_TO_SAY';

/**
 * Parenting concern categories
 */
export type Concern =
  | 'SLEEP'
  | 'FEEDING'
  | 'DEVELOPMENT'
  | 'HEALTH'
  | 'CRYING'
  | 'POSTPARTUM_RECOVERY'
  | 'WORK_PARENTING_BALANCE'
  | 'PARTNER_COORDINATION';

/**
 * Complete onboarding data structure
 * Collected across all onboarding screens
 */
export interface OnboardingData {
  // Step 2: Current stage
  mode: UserMode;

  // Step 3: Timeline
  dueDate?: Date;
  babyBirthDate?: Date;

  // Step 4: Baby info (only if mode is PARENTING)
  babyName?: string;
  babyGender?: BabyGender;

  // Step 5: Preferences
  parentingPhilosophy?: ParentingPhilosophy;
  religiousViews?: ReligiousView[];
  culturalBackground?: string;
  concerns?: Concern[];

  // Step 6: Notification preferences
  notificationPreferences?: {
    dailyMilestoneUpdates: boolean;
    weeklyTipsGuidance: boolean;
    milestoneReminders: boolean;
  };

  // Step 7: Subscription choice
  startFreeTrial?: boolean;
}

/**
 * Navigation prop types for onboarding screens
 */
export interface OnboardingNavigationProps {
  navigation: any; // Will be properly typed with React Navigation types
  route?: any;
}
