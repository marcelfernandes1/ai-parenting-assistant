# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**AI Parenting Assistant** - A cross-platform mobile app (React Native) with Node.js/Express backend providing AI-powered parenting guidance through chat, voice, milestone tracking, and photo analysis.

**Tech Stack:**
- **Frontend:** React Native 0.74+ (TypeScript), React Navigation, Zustand/Redux
- **Backend:** Node.js 20.x (TypeScript), Express.js, Prisma ORM
- **Database:** PostgreSQL 15+, Redis (caching)
- **AI:** OpenAI GPT-4/GPT-4o, Whisper (transcription), Vision API (photo analysis)
- **Storage:** AWS S3 (photos), CloudFront (CDN)
- **Payments:** Stripe subscriptions, react-native-iap
- **Infrastructure:** AWS (RDS, ElastiCache, S3) or managed platform (Render, Railway)

---

## Critical Development Rules

### Task Tracking (MANDATORY)
**ALWAYS mark completed tasks with [x] in the phase files:**
- When you complete a task in any `todo-phase-*.md` file, change `- [ ]` to `- [x]`
- Update progress counters at bottom of each phase file
- Example: `- [x] Create User model in schema.prisma`

### Code Documentation (MANDATORY)
**EVERY piece of code MUST be documented:**
```typescript
// Example of required documentation style

/**
 * Generates a JWT access token for authenticated users
 * @param userId - UUID of the user from database
 * @param email - User's email address for token payload
 * @returns Signed JWT token string with 7-day expiry
 */
function generateAccessToken(userId: string, email: string): string {
  // Include userId and email in token payload for user identification
  const payload = { userId, email };

  // Sign token with secret from environment variable, expires in 7 days
  return jwt.sign(payload, process.env.JWT_SECRET!, { expiresIn: '7d' });
}

/**
 * Middleware to verify JWT tokens on protected routes
 * Extracts token from Authorization header, verifies signature,
 * and attaches decoded user data to req.user for downstream handlers
 */
export const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  // Extract token from "Bearer <token>" format in Authorization header
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  // Return 401 if no token provided (unauthenticated request)
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  // Verify token signature and expiry with JWT secret
  jwt.verify(token, process.env.JWT_SECRET!, (err, decoded) => {
    // Return 403 if token invalid or expired (forbidden access)
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }

    // Attach decoded user data to request object for use in route handlers
    req.user = decoded as { userId: string; email: string };
    next(); // Proceed to next middleware/route handler
  });
};
```

**Documentation Requirements:**
- Function-level JSDoc comments explaining purpose, parameters, return values
- Inline comments explaining WHY (not what) for complex logic
- Comments before each major code block explaining its purpose
- Explain edge cases, error handling, and security considerations

### Library-First Principle (MANDATORY)
**ALWAYS search for existing libraries/APIs/frameworks BEFORE writing custom code:**

When implementing ANY feature, follow this workflow:
1. **Search First:** Look for existing npm packages, React Native libraries, or APIs
2. **Evaluate Options:** Check library popularity, maintenance, and documentation
3. **Use Battle-Tested Solutions:** Prefer well-maintained packages over custom code
4. **Only Custom Code as Last Resort:** Write custom implementations ONLY if no suitable library exists

**Why This Matters:**
- Saves development time (hours → minutes)
- Reduces bugs (battle-tested code vs. new code)
- Better maintenance (community support vs. maintaining custom code)
- More features (libraries often have edge cases covered)

**Where to Search:**
- **npm/yarn:** `npm search <feature>` or https://www.npmjs.com
- **React Native Directory:** https://reactnative.directory (curated RN libraries)
- **GitHub:** Search for repos with high stars/recent commits
- **Official Docs:** React Native, Expo, framework-specific solutions
- **Stack Overflow:** Check what the community recommends

**Examples:**
- ❌ DON'T write custom date formatting → ✅ USE `date-fns` or `dayjs`
- ❌ DON'T write custom form validation → ✅ USE `react-hook-form` + `zod`
- ❌ DON'T write custom image picker → ✅ USE `react-native-image-picker`
- ❌ DON'T write custom HTTP client → ✅ USE `axios` or `fetch`
- ❌ DON'T write custom state management → ✅ USE `zustand` or `redux`

**When Custom Code is Acceptable:**
- Business logic specific to this app (e.g., parenting advice algorithm)
- Simple utilities (2-3 lines) that don't warrant a dependency
- No existing library meets the exact requirements after thorough search
- Existing libraries are unmaintained (last update >2 years ago)

**Before Writing Custom Code, Ask:**
1. "Has someone else solved this problem already?"
2. "Is there an npm package for this?"
3. "What does the React Native community recommend?"
4. "Can I accomplish this with existing dependencies?"

---

## Project Structure

### Phase-Based Development
This project uses **phase-based todo files** to manage development:

**Current Phase Files:**
- `todo-phase-0-setup.md` - Project setup (16 tasks)
- `todo-phase-1-database-auth.md` - Database & auth (44 tasks)
- `todo-phase-2-chat-voice.md` - Chat & voice (40 tasks)
- `todo-phase-3-photos-milestones.md` - Photos & milestones (33 tasks)
- `todo-phase-4-monetization.md` - Subscriptions (19 tasks)
- `todo-phase-5-settings-polish.md` - Settings & polish (58 tasks)
- `todo-phase-6-deployment.md` - Deployment (62 tasks)
- `todo-post-mvp.md` - Future features

**Workflow:**
1. Load ONLY the phase file you're currently working on
2. Complete tasks sequentially within that phase
3. Mark each completed task with [x]
4. Test immediately after each task
5. Commit after each working task with descriptive message
6. Move to next phase only when current phase is 100% complete

### Architecture Overview

**Monorepo Structure (to be created):**
```
ai-parenting-assistant/
├── mobile/                    # React Native app
│   ├── src/
│   │   ├── screens/          # Screen components
│   │   ├── components/       # Reusable UI components
│   │   ├── navigation/       # React Navigation config
│   │   ├── context/          # Auth, Subscription contexts
│   │   ├── services/         # API client, utilities
│   │   ├── hooks/            # Custom React hooks
│   │   └── theme/            # Design system (colors, fonts)
│   ├── ios/                  # Native iOS code
│   └── android/              # Native Android code
│
├── backend/                   # Node.js/Express API
│   ├── src/
│   │   ├── routes/           # Express route handlers
│   │   ├── controllers/      # Business logic
│   │   ├── services/         # OpenAI, Stripe, S3 integrations
│   │   ├── middleware/       # Auth, rate limiting, validation
│   │   ├── utils/            # Helper functions
│   │   └── prisma/           # Prisma schema and migrations
│   └── tests/                # Backend tests
│
└── shared/                    # Shared TypeScript types (optional)
```

**Key Architectural Patterns:**

1. **Authentication Flow:**
   - JWT tokens (7-day access, 30-day refresh)
   - Stored in AsyncStorage on mobile
   - Axios interceptor for token refresh on 401

2. **AI Integration:**
   - OpenAI client in `backend/src/services/openai.ts`
   - System prompt built dynamically from user profile
   - Last 10 messages included for context
   - Token counting for cost tracking

3. **Usage Limiting:**
   - `UsageTracking` table with daily records (userId + date unique)
   - Middleware checks limits before processing requests
   - 429 error triggers paywall on frontend

4. **Subscription Model:**
   - Free tier: 10 messages/day, 10 voice minutes/day, 100 photos
   - Premium: Unlimited everything
   - Stripe webhooks update subscription status
   - react-native-iap handles cross-platform purchases

5. **Photo Flow:**
   - Upload to S3 with userId prefix for organization
   - Image compression on server (Sharp library)
   - Presigned URLs with 24-hour expiry for security
   - Photo metadata stored in PostgreSQL

6. **Real-Time Voice:**
   - Socket.io WebSocket connections
   - Audio chunks streamed from client
   - Server buffers → Whisper transcription → GPT response → TTS
   - Session duration tracked for billing

---

## Development Workflow

### Context Management (Critical for AI Development)
- **Load ONE phase file at a time** - Prevents context overload
- **Complete ONE task at a time** - Test before moving on
- **Clear context every 10-15 tasks** - Start fresh conversation
- **Never assume library methods exist** - Verify in documentation first

### Testing Requirements
After completing EACH task:
1. **Backend:** Test endpoint with curl or Postman
2. **Frontend:** Run on iOS simulator AND Android emulator
3. **Database:** Verify migrations applied correctly
4. **Integration:** Test full flow end-to-end

### Commit and Push Strategy (MANDATORY)
**ALWAYS commit AND push to GitHub after each completed task:**

1. **Commit Format:** `"[Phase X] Add feature name"` or `"[Phase X] Fix issue description"`
2. **Push Immediately:** Run `git push` after every commit
3. **Why:** Allows easy rollback to any working state when needed

**Example Workflow:**
```bash
# After completing a task and testing it works
git add .
git commit -m "[Phase 1] Add User model to Prisma schema"
git push origin phase-1-database-auth

# Immediately continue to next task
```

**Commit Examples:**
- `"[Phase 1] Add User model to Prisma schema"`
- `"[Phase 2] Implement Whisper transcription endpoint"`
- `"[Phase 3] Add photo upload to S3 with compression"`
- `"[Phase 4] Add Stripe subscription creation endpoint"`

**Push Frequency:** After EVERY commit (not batched)

### Common Pitfalls to Avoid
1. **DON'T** accumulate untested code - Test each task immediately
2. **DON'T** use library versions with ^ or ~ - Pin exact versions
3. **DON'T** assume API methods - Verify in official docs
4. **DON'T** skip error handling - Wrap all async code in try-catch
5. **DON'T** forget to mark tasks complete with [x]

---

## Project-Specific Patterns

### OpenAI Integration Pattern
```typescript
// System prompt template - dynamically built from user profile
const systemPrompt = `
You are a supportive parenting assistant. The user is ${userProfile.mode === 'PREGNANCY' ? 'pregnant' : 'a parent'}.
${userProfile.babyName ? `Baby name: ${userProfile.babyName}` : ''}
${userProfile.babyBirthDate ? `Baby age: ${calculateAge(userProfile.babyBirthDate)}` : ''}
User preferences: ${userProfile.parentingPhilosophy}, ${userProfile.religiousViews}

Guidelines:
- Be warm, empathetic, and reassuring
- Use baby's name naturally in responses
- Flag urgent medical situations immediately
- Never provide definitive medical diagnoses
`;

// Always include last 10 messages for context
const contextMessages = await prisma.message.findMany({
  where: { userId },
  orderBy: { timestamp: 'desc' },
  take: 10
});

// Call OpenAI with context
const completion = await openai.chat.completions.create({
  model: 'gpt-4-turbo',
  messages: [
    { role: 'system', content: systemPrompt },
    ...contextMessages.map(m => ({ role: m.role, content: m.content })),
    { role: 'user', content: userMessage }
  ]
});
```

### Usage Limiting Pattern
```typescript
// Check daily limits before processing any request
const today = new Date().toISOString().split('T')[0];
const usage = await prisma.usageTracking.findUnique({
  where: { userId_date: { userId, date: today } }
});

// Free users have limits
if (user.subscriptionTier === 'FREE') {
  if (usage.messagesUsed >= 10) {
    return res.status(429).json({
      error: 'limit_reached',
      resetTime: 'midnight' // Frontend shows countdown
    });
  }
}

// Premium users: no checks needed (unlimited)
```

### Photo Upload Pattern
```typescript
// Always compress before S3 upload to save storage costs
const compressed = await sharp(file.buffer)
  .resize(1920, null, { withoutEnlargement: true }) // Max width 1920px
  .jpeg({ quality: 85 }) // 85% quality for good balance
  .toBuffer();

// Generate unique S3 key with userId prefix for organization
const s3Key = `${userId}/${Date.now()}-${file.originalname}`;

// Upload to S3 with server-side encryption
await s3.putObject({
  Bucket: process.env.S3_BUCKET!,
  Key: s3Key,
  Body: compressed,
  ContentType: 'image/jpeg',
  ServerSideEncryption: 'AES256'
});

// Store metadata in database, NOT the full file
await prisma.photo.create({
  data: {
    userId,
    s3Key,
    metadata: { originalName: file.originalname, size: compressed.length }
  }
});

// Return presigned URL with 24-hour expiry for security
const url = await s3.getSignedUrl('getObject', {
  Bucket: process.env.S3_BUCKET!,
  Key: s3Key,
  Expires: 86400 // 24 hours
});
```

---

## Environment Variables

**Backend (backend/.env):**
```bash
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/ai_parenting_dev
REDIS_URL=redis://localhost:6379
JWT_SECRET=<generate-random-string>
JWT_REFRESH_SECRET=<generate-different-random-string>
OPENAI_API_KEY=sk-...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
S3_BUCKET=ai-parenting-dev
```

**Mobile (mobile/.env):**
```bash
API_URL=http://localhost:3000
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

---

## Key Dependencies

**Backend (exact versions to use):**
- `express@4.18.2` - Web framework
- `@prisma/client@5.7.0` - Database ORM
- `openai@4.20.0` - OpenAI API client
- `stripe@14.5.0` - Stripe payments
- `bcrypt@5.1.1` - Password hashing
- `jsonwebtoken@9.0.2` - JWT tokens
- `socket.io@4.6.1` - WebSocket for voice
- `multer@1.4.5-lts.1` - File uploads
- `sharp@0.33.0` - Image processing
- `@aws-sdk/client-s3@3.450.0` - S3 uploads
- `redis@4.6.10` - Caching

**Frontend (exact versions to use):**
- `react-native@0.74.0` - Mobile framework
- `@react-navigation/native@6.1.9` - Navigation
- `react-native-iap@12.13.0` - In-app purchases
- `socket.io-client@4.6.1` - WebSocket client
- `axios@1.6.2` - HTTP client
- `react-native-image-picker@7.1.0` - Photo picker
- `react-native-audio-recorder-player@3.6.3` - Voice recording
- `react-native-fast-image@8.6.3` - Image caching

---

## PRD Reference

Full product requirements in `PRD_MVP.md` including:
- User stories and use cases
- Functional requirements per feature
- Non-functional requirements (performance, security, accessibility)
- Technical architecture details
- Success metrics and KPIs

**Key PRD Sections for Reference:**
- Section 5: Functional Requirements (detailed feature specs)
- Section 7: Technical Architecture (tech stack decisions)
- Section 11: Risks & Mitigation (common issues and solutions)

---

## Progress Tracking

**Check TODO-README.md for:**
- Current phase overview
- Progress percentages
- Phase prerequisites
- Completion criteria

**Before starting work:**
1. Check which phase you're in
2. Open that phase's todo file ONLY
3. Find first uncompleted task `- [ ]`
4. Complete it, test it, document it
5. Mark as complete `- [x]`
6. Commit with descriptive message
7. Move to next task

---

## Important Reminders

1. **Library-First Principle** - Search for existing libraries BEFORE writing custom code
2. **TypeScript Strict Mode is ON** - No `any` types, handle all nulls
3. **Test IMMEDIATELY after each task** - Don't accumulate untested code
4. **Mark todos with [x]** - Essential for progress tracking
5. **Document EVERYTHING** - Every function, every code block
6. **Use exact versions** - No ^ or ~ in package.json
7. **Error handling required** - try-catch all async operations
8. **Commit AND push after each task** - Run `git push` after every commit (enables easy rollback)
9. **One phase at a time** - Don't jump ahead or mix phases
10. **Security first** - Never commit secrets, always validate inputs
11. **Mobile: test iOS AND Android** - Platform-specific bugs are common

---

*This is an MVP project with 272 tasks across 6 phases. Stay focused, test thoroughly, document completely.*
