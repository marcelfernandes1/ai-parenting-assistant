# Phase 1: Rich Educational Content

**Goal:** Transform milestones from simple trackers into comprehensive learning resources

**Estimated Time:** 2-3 weeks
**Priority:** 🔥 Critical (Foundation)
**Progress:** 0/8 tasks complete (0%)

---

## Tasks

### Task 1.1: Create MilestoneContent Model in Prisma Schema
**Status:** ⏳ Pending

**Description:**
Add new MilestoneContent model to `backend/prisma/schema.prisma` with comprehensive fields for educational content.

**Fields to Add:**
```prisma
model MilestoneContent {
  id                String        @id @default(uuid())
  milestoneType     MilestoneType // Enum reference
  name              String        @unique
  description       String        @db.Text  // 250-500 words overview
  whatToExpect      String        @db.Text  // Developmental details
  howToEncourage    String        @db.Text  // Practical activities
  redFlags          String        @db.Text  // Warning signs
  expertTips        String[]      // Array of tip strings
  relatedMilestones String[]      // Array of milestone names
  videoUrl          String?       // YouTube/Vimeo embed URL (optional)
  imageUrl          String?       // Illustration URL (optional)
  ageRangeMonths    Json          // {min: 3, max: 5, typical: 4}
  sources           String[]      // Array of medical sources
  createdAt         DateTime      @default(now())
  updatedAt         DateTime      @updatedAt

  @@index([name])
  @@index([milestoneType])
}
```

**Files to Modify:**
- `backend/prisma/schema.prisma`

**Testing:**
- Verify schema is valid: `npx prisma format`
- Check for errors before migration

---

### Task 1.2: Run Prisma Migration
**Status:** ⏳ Pending
**Dependencies:** Task 1.1

**Description:**
Create and apply database migration to add MilestoneContent table.

**Commands:**
```bash
cd backend
npx prisma migrate dev --name add_milestone_content_table
npx prisma generate
```

**Verification:**
- Check migration file created in `prisma/migrations/`
- Verify table exists in database using Prisma Studio: `npx prisma studio`
- Confirm no migration errors in console

---

### Task 1.3: Write Comprehensive Educational Content
**Status:** ⏳ Pending
**Dependencies:** None (can work in parallel)

**Description:**
Write detailed educational content for all 30+ existing milestone templates. Each milestone needs 250-500 words across all sections.

**Content Structure for Each Milestone:**

1. **Description** (100-150 words)
   - What this milestone means
   - Why it's important for development
   - Typical signs parents will observe

2. **What to Expect** (100-150 words)
   - Detailed developmental explanation
   - Age range and variations (normal range)
   - Signs baby is close to achieving milestone
   - Individual differences messaging

3. **How to Encourage** (100-150 words)
   - 4-6 practical activities parents can do
   - Daily routine integration tips
   - Play-based learning suggestions
   - Equipment/toys that help (keep affordable)

4. **Red Flags** (50-100 words)
   - Warning signs requiring pediatrician consultation
   - Developmental delay indicators
   - When to seek help
   - Reassuring context (every baby is different)

5. **Expert Tips** (3-5 bullet points)
   - Pediatrician-approved advice
   - Common mistakes to avoid
   - Pro tips from child development experts

6. **Related Milestones** (list)
   - 3-5 related milestone names
   - Developmental sequence connections

**Milestones to Write Content For:**
- First smile (0-2 months)
- Holding head up (0-2 months)
- Recognizes parents (1-3 months)
- Rolling over (3-5 months)
- Laughing (3-5 months)
- Reaches for toys (3-5 months)
- Sitting up (5-8 months)
- First solid foods (4-7 months)
- Stranger anxiety (6-9 months)
- Self-feeding with hands (6-9 months)
- Crawling (7-10 months)
- Pulling to stand (8-11 months)
- Waving bye-bye (8-12 months)
- Responds to name (7-10 months)
- First steps (9-15 months)
- First words (10-14 months)
- Using a spoon (12-18 months)
- Drinking from cup (10-14 months)
- Walking confidently (12-18 months)
- Pointing to objects (12-16 months)
- One nap per day (12-18 months)
- First tooth (4-12 months)
- 2-month checkup
- 4-month checkup
- 6-month checkup
- 9-month checkup
- 12-month checkup
- 15-month checkup
- 18-month checkup

**Format:**
Create content in a JSON file for easy seeding: `backend/src/data/milestone-content.json`

**Example Entry:**
```json
{
  "name": "First Steps",
  "milestoneType": "PHYSICAL",
  "description": "Taking first independent steps is a major physical milestone that typically occurs between 9-15 months. This achievement marks the beginning of your baby's journey to independent mobility and represents months of physical preparation including strengthening leg muscles, improving balance, and building confidence. Most babies will cruise along furniture and walk with hand-holding before taking those first magical unassisted steps. Remember, walking is a complex skill that requires coordination of multiple muscle groups and a sense of balance - it's normal for babies to achieve this milestone at different times.",
  "whatToExpect": "Before walking independently, your baby will show several preparatory behaviors. They'll pull themselves to standing using furniture, cruise along sofas and tables while holding on, and may stand independently for a few seconds. When ready to walk, they'll typically take 2-3 wobbly steps before falling or sitting down. Early walking is characterized by a wide-legged stance, arms held up for balance, and frequent tumbles. Walking gait will be unsteady for several weeks as baby builds confidence and coordination. Some babies walk early (9-10 months), others walk later (15-18 months) - both are completely normal! By 18 months, most children can walk well and are starting to run.",
  "howToEncourage": "Encourage walking by creating safe spaces for practice with soft flooring and padding. Hold your baby's hands and let them walk with your support, gradually reducing assistance as confidence grows. Place favorite toys across the room to motivate movement. Create furniture arrangements that allow for cruising practice. Ensure baby has plenty of barefoot time indoors - bare feet help with grip and balance development. Praise every attempt, even falls - enthusiasm encourages more practice! Avoid walkers (unsafe) and limit time in jumpers. Push toys with weighted bases can provide good support. Most importantly, never force walking - baby will walk when developmentally ready. Focus on tummy time and floor play in early months to build core strength.",
  "redFlags": "Consult your pediatrician if: baby isn't bearing weight on legs by 12 months, isn't standing with support by 15 months, shows significant asymmetry in leg movement (favoring one leg), stiffness in leg muscles, or toes pointing inward severely. Also concerning: loss of previously acquired motor skills, extreme fear of standing, or no interest in moving around by 15 months. Remember that babies who crawl late may walk late - this is usually normal. Premature babies may reach milestones on their adjusted age timeline. Trust your instincts - if something feels off, always consult your pediatrician.",
  "expertTips": [
    "Skip the baby shoes until walking outdoors - barefoot is best for balance development",
    "Falling is part of learning - resist the urge to hover constantly; baby needs to learn limits",
    "Baby-proof thoroughly before walking begins - mobility happens fast once it starts!",
    "Video first steps if possible - you'll treasure the memory and can show pediatrician gait",
    "Late walkers often become early talkers - development isn't a race"
  ],
  "relatedMilestones": ["Pulling to Stand", "Cruising Along Furniture", "Walking Confidently", "Running", "Climbing Stairs"],
  "videoUrl": null,
  "imageUrl": null,
  "ageRangeMonths": {
    "min": 9,
    "max": 15,
    "typical": 12
  },
  "sources": ["American Academy of Pediatrics", "CDC Developmental Milestones", "WHO Motor Development Study"]
}
```

**Deliverable:**
- `backend/src/data/milestone-content.json` with all 30+ milestone content entries

---

### Task 1.4: Create Seed Script
**Status:** ⏳ Pending
**Dependencies:** Tasks 1.2, 1.3

**Description:**
Create a database seed script to populate the MilestoneContent table with all educational content.

**File to Create:**
`backend/src/scripts/seed-milestone-content.ts`

**Script Requirements:**
- Read from `milestone-content.json`
- Upsert each milestone (update if exists, create if new)
- Handle errors gracefully
- Log progress (e.g., "Seeding milestone 5/30...")
- Confirm success at end

**Commands to Add to package.json:**
```json
"scripts": {
  "seed:milestones": "ts-node src/scripts/seed-milestone-content.ts"
}
```

**Testing:**
```bash
npm run seed:milestones
# Then verify in Prisma Studio
npx prisma studio
```

---

### Task 1.5: Create GET /milestones/content/:name Endpoint
**Status:** ⏳ Pending
**Dependencies:** Tasks 1.2, 1.4

**Description:**
Create backend API endpoint to fetch rich milestone content by milestone name.

**File to Modify:**
`backend/src/routes/milestones.ts`

**Endpoint Spec:**
```typescript
/**
 * GET /milestones/content/:name
 * Fetch detailed educational content for a specific milestone
 *
 * Params:
 * - name: string (milestone name, e.g., "First Steps")
 *
 * Returns:
 * - Full MilestoneContent object with all educational fields
 */
router.get(
  '/content/:name',
  authenticateToken, // Optional: could be public
  async (req: Request, res: Response) => {
    // Implementation here
  }
);
```

**Response Format:**
```json
{
  "content": {
    "id": "uuid",
    "milestoneType": "PHYSICAL",
    "name": "First Steps",
    "description": "...",
    "whatToExpect": "...",
    "howToEncourage": "...",
    "redFlags": "...",
    "expertTips": [...],
    "relatedMilestones": [...],
    "videoUrl": null,
    "imageUrl": null,
    "ageRangeMonths": {...},
    "sources": [...]
  }
}
```

**Testing:**
```bash
curl http://localhost:3000/api/milestones/content/First%20Steps \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### Task 1.6: Create MilestoneContentModel in Flutter
**Status:** ⏳ Pending
**Dependencies:** Task 1.5

**Description:**
Create Dart model with Freezed for milestone educational content.

**File to Create:**
`mobile/lib/features/milestones/domain/milestone_content_model.dart`

**Model Structure:**
```dart
@freezed
class MilestoneContent with _$MilestoneContent {
  const factory MilestoneContent({
    required String id,
    required MilestoneType milestoneType,
    required String name,
    required String description,
    required String whatToExpect,
    required String howToEncourage,
    required String redFlags,
    required List<String> expertTips,
    required List<String> relatedMilestones,
    String? videoUrl,
    String? imageUrl,
    required AgeRangeDetailed ageRangeMonths,
    required List<String> sources,
  }) = _MilestoneContent;

  factory MilestoneContent.fromJson(Map<String, dynamic> json) =>
      _$MilestoneContentFromJson(json);
}

@freezed
class AgeRangeDetailed with _$AgeRangeDetailed {
  const factory AgeRangeDetailed({
    required int min,
    required int max,
    required int typical,
  }) = _AgeRangeDetailed;

  factory AgeRangeDetailed.fromJson(Map<String, dynamic> json) =>
      _$AgeRangeDetailedFromJson(json);
}
```

**Code Generation:**
```bash
cd mobile
dart run build_runner build --delete-conflicting-outputs
```

---

### Task 1.7: Build MilestoneGuideScreen
**Status:** ⏳ Pending
**Dependencies:** Task 1.6

**Description:**
Create rich milestone guide screen showing all educational content with expandable sections.

**File to Create:**
`mobile/lib/features/milestones/presentation/milestone_guide_screen.dart`

**Screen Features:**
- Hero image/icon at top
- Milestone name as title
- Age range badge
- Expandable sections:
  - 📖 What to Expect
  - 💡 How to Encourage
  - ⚠️ Red Flags
  - 👨‍⚕️ Expert Tips
  - 🔗 Related Milestones (tappable links)
- Optional video player if videoUrl exists
- "Mark as Achieved" button
- "Ask AI About This" button (links to chat with pre-filled context)
- Share button

**UI/UX Requirements:**
- Smooth expand/collapse animations
- Readable text (large font, good contrast)
- Sections use ExpansionTile or similar
- Beautiful Material 3 design
- Loading state while fetching content
- Error state if content fails to load

**Supporting Files:**
- Create repository: `mobile/lib/features/milestones/data/milestone_content_repository.dart`
- Create provider: `mobile/lib/features/milestones/providers/milestone_content_provider.dart`

---

### Task 1.8: Add "Learn More" Navigation & Testing
**Status:** ⏳ Pending
**Dependencies:** Task 1.7

**Description:**
Add navigation to MilestoneGuideScreen from existing milestone cards and test Phase 1 end-to-end.

**Files to Modify:**
- `mobile/lib/features/milestones/presentation/widgets/milestone_card.dart`
- `mobile/lib/features/milestones/presentation/widgets/milestone_suggestions_card.dart`

**Changes:**
- Add "Learn More" button to milestone cards
- Add navigation to MilestoneGuideScreen on button tap
- Pass milestone name as parameter

**End-to-End Testing Checklist:**
- [ ] Database has MilestoneContent table
- [ ] All 30+ milestones seeded with content
- [ ] Backend endpoint returns content correctly
- [ ] Flutter model deserializes JSON properly
- [ ] MilestoneGuideScreen displays all sections
- [ ] Expand/collapse works smoothly
- [ ] "Learn More" button navigates correctly
- [ ] Related milestone links work
- [ ] Error handling works (try non-existent milestone)
- [ ] Loading states display properly
- [ ] Content is readable and well-formatted
- [ ] Test on both iOS and Android

**Acceptance Criteria:**
✅ All milestone cards have "Learn More" button
✅ Tapping opens rich educational screen
✅ All content sections display properly
✅ Navigation works smoothly
✅ No crashes or errors
✅ Content is medically accurate and helpful

---

## Phase 1 Complete! 🎉

**When all 8 tasks are done:**
- Mark phase as complete in TODO-MILESTONE-UPGRADE.md
- Update progress: 8/8 tasks (100%)
- Commit all changes with message: `[Milestone Upgrade] Complete Phase 1: Rich Educational Content`
- Move to Phase 2 or take feedback from users

**Next Phase:** [Phase 2: Push Notifications](./phase-2-notifications.md)

---

*Last Updated: 2025-01-31*
