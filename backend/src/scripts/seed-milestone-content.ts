/**
 * Seed script to populate MilestoneContent table with educational content
 *
 * This script reads milestone data from milestone-content.json and inserts it
 * into the MilestoneContent table. It can be run multiple times safely as it
 * uses upsert operations (update if exists, insert if not).
 *
 * Usage: npm run seed:milestones
 * or: ts-node src/scripts/seed-milestone-content.ts
 */

import { PrismaClient, MilestoneType } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';

// Initialize Prisma Client
const prisma = new PrismaClient();

/**
 * Interface matching the structure of milestone data in JSON file
 */
interface MilestoneData {
  name: string;
  milestoneType: string;
  description: string;
  whatToExpect: string;
  howToEncourage: string;
  redFlags: string;
  expertTips: string[];
  relatedMilestones: string[];
  videoUrl: string | null;
  imageUrl: string | null;
  ageRangeMonths: {
    min: number;
    max: number;
    typical: number;
  };
  sources: string[];
}

/**
 * Main seeding function that reads JSON and populates database
 */
async function seedMilestoneContent() {
  try {
    console.log('🌱 Starting milestone content seeding...\n');

    // Read the milestone content JSON file
    const dataPath = path.join(__dirname, '../data/milestone-content.json');
    console.log(`📂 Reading data from: ${dataPath}`);

    const jsonData = fs.readFileSync(dataPath, 'utf-8');
    const milestones: MilestoneData[] = JSON.parse(jsonData);

    console.log(`✅ Found ${milestones.length} milestones to seed\n`);

    // Counter for tracking success/failures
    let successCount = 0;
    let errorCount = 0;

    // Process each milestone
    for (const milestone of milestones) {
      try {
        // Validate milestone type matches enum
        if (!Object.values(MilestoneType).includes(milestone.milestoneType as MilestoneType)) {
          throw new Error(`Invalid milestone type: ${milestone.milestoneType}`);
        }

        // Upsert milestone (update if exists, create if not)
        // Using 'name' as unique identifier
        await prisma.milestoneContent.upsert({
          where: {
            name: milestone.name,
          },
          update: {
            // Update all fields if record exists
            milestoneType: milestone.milestoneType as MilestoneType,
            description: milestone.description,
            whatToExpect: milestone.whatToExpect,
            howToEncourage: milestone.howToEncourage,
            redFlags: milestone.redFlags,
            expertTips: milestone.expertTips,
            relatedMilestones: milestone.relatedMilestones,
            videoUrl: milestone.videoUrl,
            imageUrl: milestone.imageUrl,
            ageRangeMonths: milestone.ageRangeMonths,
            sources: milestone.sources,
            updatedAt: new Date(),
          },
          create: {
            // Create new record if doesn't exist
            name: milestone.name,
            milestoneType: milestone.milestoneType as MilestoneType,
            description: milestone.description,
            whatToExpect: milestone.whatToExpect,
            howToEncourage: milestone.howToEncourage,
            redFlags: milestone.redFlags,
            expertTips: milestone.expertTips,
            relatedMilestones: milestone.relatedMilestones,
            videoUrl: milestone.videoUrl,
            imageUrl: milestone.imageUrl,
            ageRangeMonths: milestone.ageRangeMonths,
            sources: milestone.sources,
          },
        });

        successCount++;
        console.log(`✓ Seeded: ${milestone.name} (${milestone.milestoneType})`);
      } catch (error) {
        errorCount++;
        console.error(`✗ Error seeding ${milestone.name}:`, error);
      }
    }

    // Print summary
    console.log('\n' + '='.repeat(60));
    console.log('📊 Seeding Summary:');
    console.log(`   ✅ Successful: ${successCount}`);
    console.log(`   ❌ Failed: ${errorCount}`);
    console.log(`   📝 Total: ${milestones.length}`);
    console.log('='.repeat(60) + '\n');

    if (errorCount === 0) {
      console.log('🎉 All milestone content seeded successfully!');
    } else {
      console.log('⚠️  Some milestones failed to seed. Check errors above.');
    }

  } catch (error) {
    console.error('❌ Fatal error during seeding:', error);
    throw error;
  } finally {
    // Always disconnect from database
    await prisma.$disconnect();
    console.log('\n🔌 Database connection closed.');
  }
}

/**
 * Execute seeding function
 * Handle errors and exit with appropriate code
 */
seedMilestoneContent()
  .then(() => {
    console.log('✅ Seeding completed successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  });
