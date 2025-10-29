# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**AI Parenting Assistant** - A cross-platform mobile app (Flutter) with Node.js/Express backend providing AI-powered parenting guidance through chat, voice, milestone tracking, and photo analysis.

**Tech Stack:**
- **Frontend:** Flutter 3.24+ (Dart), go_router, Riverpod (state management), Material 3
- **Backend:** Node.js 20.x (TypeScript), Express.js, Prisma ORM
- **Database:** PostgreSQL 15+, Redis (caching)
- **AI:** OpenAI GPT-4/GPT-4o, Whisper (transcription), Vision API (photo analysis)
- **Storage:** AWS S3 (photos), CloudFront (CDN)
- **Payments:** Stripe subscriptions, in_app_purchase
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

**Flutter/Dart Example:**
```dart
/// Riverpod provider that manages authentication state.
/// Provides access to current user and auth methods.
/// Automatically refreshes token when expired.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // Create auth notifier with API service dependency
  return AuthNotifier(ref.watch(apiServiceProvider));
});

/// State notifier for authentication logic.
/// Handles login, logout, token refresh, and session management.
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(const AuthState.initial());

  /// Authenticates user with email and password.
  /// Stores JWT token in secure storage for persistent sessions.
  /// Returns true if login successful, false otherwise.
  Future<bool> login(String email, String password) async {
    try {
      // Set loading state to show UI feedback
      state = const AuthState.loading();

      // Call backend authentication endpoint
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      // Extract JWT tokens from response
      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;

      // Store tokens securely for session persistence
      await _secureStorage.write(key: 'access_token', value: accessToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);

      // Update state with authenticated user data
      state = AuthState.authenticated(user: User.fromJson(response.data['user']));

      return true;
    } catch (e) {
      // Set error state with user-friendly message
      state = AuthState.error(message: 'Invalid credentials');
      return false;
    }
  }
}
```

**Backend (Node.js/TypeScript) Example:**
```typescript
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
- **Dart:** Use `///` dartdoc comments for classes, methods, and important properties
- **TypeScript:** Use JSDoc comments for functions and complex logic
- Inline comments explaining WHY (not what) for complex logic
- Comments before each major code block explaining its purpose
- Explain edge cases, error handling, and security considerations

### Library-First Principle (MANDATORY)
**ALWAYS search for existing libraries/APIs/frameworks BEFORE writing custom code:**

When implementing ANY feature, follow this workflow:
1. **Search First:** Look for existing Flutter packages, pub.dev packages, or APIs
2. **Evaluate Options:** Check library popularity (pub points, likes), maintenance, and documentation
3. **Use Battle-Tested Solutions:** Prefer well-maintained packages over custom code
4. **Only Custom Code as Last Resort:** Write custom implementations ONLY if no suitable library exists

**Why This Matters:**
- Saves development time (hours → minutes)
- Reduces bugs (battle-tested code vs. new code)
- Better maintenance (community support vs. maintaining custom code)
- More features (libraries often have edge cases covered)

**Where to Search:**
- **pub.dev:** https://pub.dev (official Dart package repository)
- **Flutter Favorites:** https://pub.dev/flutter-favorites (curated high-quality packages)
- **Flutter Community:** https://flutter.dev/community
- **GitHub:** Search for repos with high stars/recent commits
- **Official Docs:** Flutter.dev, framework-specific solutions
- **Stack Overflow:** Check what the community recommends

**Flutter Examples:**
- ❌ DON'T write custom date formatting → ✅ USE `intl` package
- ❌ DON'T write custom form validation → ✅ USE `flutter_form_builder` + `form_builder_validators`
- ❌ DON'T write custom image picker → ✅ USE `image_picker` (official)
- ❌ DON'T write custom HTTP client → ✅ USE `dio` or `http`
- ❌ DON'T write custom state management → ✅ USE `riverpod`, `bloc`, or `provider`
- ❌ DON'T write custom routing → ✅ USE `go_router` or `auto_route`
- ❌ DON'T write custom animations → ✅ USE `flutter_animate` or built-in `AnimatedWidget`
- ❌ DON'T write custom image caching → ✅ USE `cached_network_image`

**When Custom Code is Acceptable:**
- Business logic specific to this app (e.g., parenting advice algorithm)
- Simple utilities (2-3 lines) that don't warrant a dependency
- No existing library meets the exact requirements after thorough search
- Existing libraries are unmaintained (last update >2 years ago)

**Before Writing Custom Code, Ask:**
1. "Has someone else solved this problem already?"
2. "Is there a pub.dev package for this?"
3. "What does the Flutter community recommend?"
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

**Monorepo Structure:**
```
ai-parenting-assistant/
├── mobile/                    # Flutter app
│   ├── lib/
│   │   ├── main.dart         # App entry point
│   │   ├── features/         # Feature-based architecture
│   │   │   ├── auth/         # Authentication feature
│   │   │   │   ├── data/     # API calls, repositories
│   │   │   │   ├── domain/   # Models, entities
│   │   │   │   ├── presentation/ # Screens, widgets
│   │   │   │   └── providers/    # Riverpod providers
│   │   │   ├── chat/         # Chat feature
│   │   │   ├── voice/        # Voice recording feature
│   │   │   ├── photos/       # Photo upload feature
│   │   │   └── profile/      # User profile feature
│   │   ├── shared/           # Shared utilities
│   │   │   ├── widgets/      # Reusable UI components
│   │   │   ├── models/       # Shared data models
│   │   │   ├── services/     # API client, storage
│   │   │   ├── providers/    # Global providers
│   │   │   └── theme/        # Material 3 theme
│   │   └── router/           # go_router configuration
│   ├── ios/                  # Native iOS code
│   ├── android/              # Native Android code
│   ├── test/                 # Unit & widget tests
│   └── pubspec.yaml          # Dependencies
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

1. **Flutter State Management (Riverpod):**
   - Feature-based provider organization
   - `StateNotifierProvider` for complex state with business logic
   - `FutureProvider` for async data fetching
   - `StreamProvider` for real-time WebSocket data
   - Code generation with `riverpod_generator` for type safety

2. **Authentication Flow:**
   - JWT tokens (7-day access, 30-day refresh) from backend
   - Stored in `flutter_secure_storage` on mobile (encrypted keychain)
   - Dio interceptor for automatic token refresh on 401
   - Riverpod `authProvider` manages auth state globally

3. **Navigation (go_router):**
   - Declarative routing with type-safe route definitions
   - Authentication-aware routing (redirect to login if unauthenticated)
   - Deep linking support for notifications
   - Bottom navigation with nested routes

4. **AI Integration:**
   - OpenAI client in `backend/src/services/openai.ts`
   - System prompt built dynamically from user profile
   - Last 10 messages included for context
   - Token counting for cost tracking

5. **Usage Limiting:**
   - `UsageTracking` table with daily records (userId + date unique)
   - Backend middleware checks limits before processing requests
   - 429 error triggers paywall modal in Flutter app
   - Real-time usage display with progress indicators

6. **Subscription Model:**
   - Free tier: 10 messages/day, 10 voice minutes/day, 100 photos
   - Premium: Unlimited everything
   - Stripe webhooks update subscription status
   - `in_app_purchase` package handles iOS/Android purchases

7. **Photo Flow:**
   - `image_picker` for camera/gallery selection
   - Upload to S3 via backend API
   - Image compression on server (Sharp library)
   - `cached_network_image` for efficient image loading
   - Presigned URLs with 24-hour expiry for security

8. **Real-Time Voice:**
   - `socket_io_client` for WebSocket connections
   - `flutter_sound` for audio recording
   - Audio chunks streamed to backend
   - Server: buffers → Whisper transcription → GPT response → TTS
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
2. **Flutter:** Run on iOS simulator AND Android emulator (hot reload for quick testing)
3. **Flutter Tests:** Run `flutter test` for unit and widget tests
4. **Database:** Verify migrations applied correctly
5. **Integration:** Test full flow end-to-end on both platforms

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

**Flutter Frontend (pub.dev packages):**

**Core Flutter & State Management:**
- `flutter_riverpod: ^2.5.1` - Riverpod state management
- `riverpod_annotation: ^2.3.5` - Code generation annotations
- `freezed: ^2.5.2` - Immutable models with code generation
- `freezed_annotation: ^2.4.1` - Freezed annotations

**Routing & Navigation:**
- `go_router: ^14.2.0` - Declarative routing (Flutter team recommended)

**HTTP & Networking:**
- `dio: ^5.4.3` - HTTP client with interceptors
- `socket_io_client: ^2.0.3` - WebSocket for real-time voice
- `http: ^1.2.1` - Backup HTTP client (if needed)

**Storage:**
- `flutter_secure_storage: ^9.2.2` - Encrypted storage for tokens
- `shared_preferences: ^2.2.3` - Simple key-value storage
- `path_provider: ^2.1.3` - File system paths

**Media & Camera:**
- `image_picker: ^1.1.1` - Camera/gallery picker (official Flutter package)
- `cached_network_image: ^3.3.1` - Image caching and loading
- `flutter_sound: ^9.2.13` - Audio recording and playback
- `permission_handler: ^11.3.1` - Runtime permissions

**UI & Design:**
- `flutter_animate: ^4.5.0` - Beautiful declarative animations
- `shimmer: ^3.0.0` - Loading skeleton animations
- `flutter_svg: ^2.0.10` - SVG rendering

**Payments:**
- `in_app_purchase: ^3.2.0` - Official in-app purchases (iOS/Android)
- `flutter_stripe: ^11.0.0` - Stripe SDK integration

**Utilities:**
- `intl: ^0.19.0` - Internationalization and date formatting
- `uuid: ^4.4.0` - UUID generation
- `url_launcher: ^6.3.0` - Open URLs and deep links

**Dev Dependencies (code generation):**
- `build_runner: ^2.4.11` - Code generation runner
- `riverpod_generator: ^2.4.0` - Riverpod code generation
- `json_serializable: ^6.8.0` - JSON serialization code gen
- `flutter_launcher_icons: ^0.13.1` - App icon generation
- `flutter_native_splash: ^2.4.1` - Splash screen generation

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

1. **Library-First Principle** - Search for existing Flutter packages on pub.dev BEFORE writing custom code
2. **Dart Type Safety** - Enable null safety, avoid `dynamic`, use strict typing
3. **Test IMMEDIATELY after each task** - Don't accumulate untested code
4. **Mark todos with [x]** - Essential for progress tracking
5. **Document EVERYTHING** - Every function, every code block (use `///` dartdoc)
6. **Use exact versions in pubspec.yaml** - Pin versions or use ^ for patch updates only
7. **Error handling required** - try-catch all async operations, handle null cases
8. **Commit AND push after each task** - Run `git push` after every commit (enables easy rollback)
9. **One phase at a time** - Don't jump ahead or mix phases
10. **Security first** - Never commit secrets, always validate inputs, use `flutter_secure_storage`
11. **Flutter: test iOS AND Android** - Platform-specific bugs are common, use hot reload for rapid testing
12. **Code Generation** - Run `dart run build_runner build` after model changes
13. **Riverpod Best Practices** - Use code generation, avoid global state mutation

---

*This is an MVP project with 272 tasks across 6 phases. Stay focused, test thoroughly, document completely.*
