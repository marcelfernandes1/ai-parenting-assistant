/**
 * Milestone suggestion utility functions
 *
 * Provides age-appropriate milestone suggestions based on baby's age.
 * Milestones are categorized by developmental age ranges.
 */

import { MilestoneType } from '@prisma/client';

/**
 * Interface for milestone suggestion template
 */
export interface MilestoneSuggestion {
  type: MilestoneType;
  name: string;
  description: string;
  ageRangeMonths: {
    min: number;
    max: number;
  };
}

/**
 * Predefined milestone templates organized by age ranges
 * Based on typical baby development milestones
 */
const MILESTONE_TEMPLATES: MilestoneSuggestion[] = [
  // 0-2 months
  {
    type: 'SOCIAL',
    name: 'First smile',
    description: 'Baby smiles in response to your smile',
    ageRangeMonths: { min: 0, max: 2 },
  },
  {
    type: 'PHYSICAL',
    name: 'Holding head up',
    description: 'Baby can hold head up while lying on tummy',
    ageRangeMonths: { min: 0, max: 2 },
  },
  {
    type: 'SOCIAL',
    name: 'Recognizes parents',
    description: 'Baby recognizes parents and familiar faces',
    ageRangeMonths: { min: 1, max: 3 },
  },

  // 3-4 months
  {
    type: 'PHYSICAL',
    name: 'Rolling over',
    description: 'Baby rolls from tummy to back',
    ageRangeMonths: { min: 3, max: 5 },
  },
  {
    type: 'SOCIAL',
    name: 'Laughing',
    description: 'Baby laughs out loud',
    ageRangeMonths: { min: 3, max: 5 },
  },
  {
    type: 'PHYSICAL',
    name: 'Reaches for toys',
    description: 'Baby reaches for and grasps toys',
    ageRangeMonths: { min: 3, max: 5 },
  },

  // 5-7 months
  {
    type: 'PHYSICAL',
    name: 'Sitting up',
    description: 'Baby sits without support',
    ageRangeMonths: { min: 5, max: 8 },
  },
  {
    type: 'FEEDING',
    name: 'First solid foods',
    description: 'Baby eats first solid foods',
    ageRangeMonths: { min: 4, max: 7 },
  },
  {
    type: 'SOCIAL',
    name: 'Stranger anxiety',
    description: 'Baby shows awareness of strangers',
    ageRangeMonths: { min: 6, max: 9 },
  },
  {
    type: 'FEEDING',
    name: 'Self-feeding with hands',
    description: 'Baby feeds self with fingers',
    ageRangeMonths: { min: 6, max: 9 },
  },

  // 8-10 months
  {
    type: 'PHYSICAL',
    name: 'Crawling',
    description: 'Baby crawls on hands and knees',
    ageRangeMonths: { min: 7, max: 10 },
  },
  {
    type: 'PHYSICAL',
    name: 'Pulling to stand',
    description: 'Baby pulls self up to standing',
    ageRangeMonths: { min: 8, max: 11 },
  },
  {
    type: 'SOCIAL',
    name: 'Waving bye-bye',
    description: 'Baby waves goodbye',
    ageRangeMonths: { min: 8, max: 12 },
  },
  {
    type: 'SOCIAL',
    name: 'Responds to name',
    description: 'Baby turns when you call their name',
    ageRangeMonths: { min: 7, max: 10 },
  },

  // 11-14 months
  {
    type: 'PHYSICAL',
    name: 'First steps',
    description: 'Baby takes first independent steps',
    ageRangeMonths: { min: 9, max: 15 },
  },
  {
    type: 'SOCIAL',
    name: 'First words',
    description: 'Baby says first meaningful words',
    ageRangeMonths: { min: 10, max: 14 },
  },
  {
    type: 'FEEDING',
    name: 'Using a spoon',
    description: 'Baby uses spoon to feed themselves',
    ageRangeMonths: { min: 12, max: 18 },
  },
  {
    type: 'FEEDING',
    name: 'Drinking from cup',
    description: 'Baby drinks from sippy cup',
    ageRangeMonths: { min: 10, max: 14 },
  },

  // 15-18 months
  {
    type: 'PHYSICAL',
    name: 'Walking confidently',
    description: 'Baby walks well without falling',
    ageRangeMonths: { min: 12, max: 18 },
  },
  {
    type: 'SOCIAL',
    name: 'Pointing to objects',
    description: 'Baby points to things they want',
    ageRangeMonths: { min: 12, max: 16 },
  },
  {
    type: 'SLEEP',
    name: 'One nap per day',
    description: 'Baby transitions to one daytime nap',
    ageRangeMonths: { min: 12, max: 18 },
  },

  // Health milestones (not age-specific ranges, but important)
  {
    type: 'HEALTH',
    name: 'First tooth',
    description: 'Baby gets first tooth',
    ageRangeMonths: { min: 4, max: 12 },
  },
  {
    type: 'HEALTH',
    name: '2-month checkup',
    description: 'Baby has 2-month well-child visit',
    ageRangeMonths: { min: 2, max: 2 },
  },
  {
    type: 'HEALTH',
    name: '4-month checkup',
    description: 'Baby has 4-month well-child visit',
    ageRangeMonths: { min: 4, max: 4 },
  },
  {
    type: 'HEALTH',
    name: '6-month checkup',
    description: 'Baby has 6-month well-child visit',
    ageRangeMonths: { min: 6, max: 6 },
  },
  {
    type: 'HEALTH',
    name: '9-month checkup',
    description: 'Baby has 9-month well-child visit',
    ageRangeMonths: { min: 9, max: 9 },
  },
  {
    type: 'HEALTH',
    name: '12-month checkup',
    description: 'Baby has 12-month well-child visit',
    ageRangeMonths: { min: 12, max: 12 },
  },
  {
    type: 'HEALTH',
    name: '15-month checkup',
    description: 'Baby has 15-month well-child visit',
    ageRangeMonths: { min: 15, max: 15 },
  },
  {
    type: 'HEALTH',
    name: '18-month checkup',
    description: 'Baby has 18-month well-child visit',
    ageRangeMonths: { min: 18, max: 18 },
  },
];

/**
 * Calculate baby's age in months from birth date
 *
 * @param birthDate - Baby's birth date
 * @returns Age in months (rounded to nearest month)
 */
export function calculateBabyAgeInMonths(birthDate: Date): number {
  const today = new Date();
  const ageInDays = Math.floor(
    (today.getTime() - birthDate.getTime()) / (1000 * 60 * 60 * 24)
  );

  // Convert days to months (approximate: 30 days per month)
  const ageInMonths = Math.floor(ageInDays / 30);

  return ageInMonths;
}

/**
 * Get age-appropriate milestone suggestions for a baby
 *
 * Suggests milestones based on baby's current age, including:
 * - Milestones within the current age range
 * - Milestones slightly ahead (to encourage tracking upcoming milestones)
 *
 * @param birthDate - Baby's birth date
 * @param alreadyLoggedMilestoneNames - Array of milestone names already logged
 * @returns Array of suggested milestone templates
 */
export function suggestMilestones(
  birthDate: Date,
  alreadyLoggedMilestoneNames: string[] = []
): MilestoneSuggestion[] {
  // Calculate baby's current age in months
  const ageInMonths = calculateBabyAgeInMonths(birthDate);

  console.log(`🏆 Suggesting milestones for baby age: ${ageInMonths} months`);

  // Filter milestones that are age-appropriate
  // Include current age and up to 2 months ahead for planning
  const suggestions = MILESTONE_TEMPLATES.filter((milestone) => {
    const { min, max } = milestone.ageRangeMonths;

    // Check if milestone is within appropriate age range
    const isAgeAppropriate = ageInMonths >= min && ageInMonths <= max + 2;

    // Check if milestone hasn't been logged yet (case-insensitive comparison)
    const isNotLogged = !alreadyLoggedMilestoneNames.some(
      (loggedName) => loggedName.toLowerCase() === milestone.name.toLowerCase()
    );

    return isAgeAppropriate && isNotLogged;
  });

  console.log(`✅ Found ${suggestions.length} age-appropriate milestone suggestions`);

  // Sort by age range (closest to current age first)
  return suggestions.sort((a, b) => {
    const aDistance = Math.abs(a.ageRangeMonths.min - ageInMonths);
    const bDistance = Math.abs(b.ageRangeMonths.min - ageInMonths);
    return aDistance - bDistance;
  });
}
