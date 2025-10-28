# Phase 1: Database Schema & Authentication

**Focus:** Prisma models, auth endpoints, login/register screens, onboarding flow
**Timeline:** Weeks 3-6
**Prerequisites:** Phase 0 completed

---

## 📊 Database Schema & Models

### Define Prisma Schema Models

- [x] Create `User` model in schema.prisma
  - Fields: id (UUID), email (unique), passwordHash, createdAt, updatedAt
  - Fields: subscriptionTier (enum: FREE, PREMIUM), subscriptionStatus (enum), subscriptionExpiresAt
  - Add indexes on email for fast lookup

- [x] Create `UserProfile` model
  - Fields: userId (FK to User), mode (enum: PREGNANCY, PARENTING)
  - Fields: dueDate (nullable DateTime), babyBirthDate (nullable DateTime)
  - Fields: babyName (nullable), babyGender (nullable enum)
  - Fields: parentingPhilosophy (Json), religiousViews (Json), culturalBackground (String)
  - Fields: concerns (String array), notificationPreferences (Json)
  - One-to-one relation with User

- [x] Create `Message` model
  - Fields: id (UUID), userId (FK), sessionId (UUID for grouping)
  - Fields: role (enum: USER, ASSISTANT), content (text)
  - Fields: contentType (enum: TEXT, VOICE, IMAGE)
  - Fields: mediaUrls (String array), tokensUsed (Int), timestamp (DateTime)
  - Index on userId and timestamp for fast chat history queries

- [x] Create `Milestone` model
  - Fields: id (UUID), userId (FK), type (enum: PHYSICAL, FEEDING, SLEEP, SOCIAL, HEALTH)
  - Fields: name (String), achievedDate (DateTime), notes (text, nullable)
  - Fields: photoUrls (String array), aiSuggested (Boolean), confirmed (Boolean)
  - Index on userId and achievedDate

- [x] Create `Photo` model
  - Fields: id (UUID), userId (FK), milestoneId (FK, nullable), albumId (nullable)
  - Fields: s3Key (unique String), uploadedAt (DateTime)
  - Fields: metadata (Json for EXIF data), analysisResults (Json, nullable)
  - Index on userId and uploadedAt

- [x] Create `UsageTracking` model
  - Fields: id (UUID), userId (FK), date (Date)
  - Fields: messagesUsed (Int default 0), voiceMinutesUsed (Float default 0)
  - Fields: photosStored (Int default 0)
  - Unique constraint on userId + date (one record per user per day)

- [x] Run initial Prisma migration
  - Execute `npx prisma migrate dev --name init`
  - Verify all tables created in database
  - Generate Prisma Client: `npx prisma generate`

---

## 🔐 Authentication System

### Backend Auth API

- [x] Install authentication dependencies
  - `npm install bcrypt jsonwebtoken express-validator`
  - `npm install @types/bcrypt @types/jsonwebtoken --save-dev`

- [x] Create `POST /auth/register` endpoint
  - Validate email format and password strength (min 8 chars, 1 number)
  - Hash password with bcrypt (10 salt rounds)
  - Create User and UserProfile records in transaction
  - Return success message (do NOT auto-login, require email verification)
  - Handle duplicate email error gracefully

- [x] Create `POST /auth/login` endpoint
  - Validate email and password fields present
  - Look up user by email
  - Compare password with bcrypt
  - Generate JWT access token (7-day expiry) and refresh token (30-day)
  - Return tokens and basic user info (id, email, subscriptionTier)

- [x] Create JWT generation utility
  - Function `generateAccessToken(userId, email)` returns signed JWT
  - Function `generateRefreshToken(userId)` returns refresh token
  - Use separate secrets for access and refresh tokens (env variables)
  - Include userId and email in access token payload

- [x] Create JWT verification middleware
  - Middleware `authenticateToken(req, res, next)`
  - Extract token from `Authorization: Bearer <token>` header
  - Verify token with jwt.verify()
  - Attach decoded user data to `req.user`
  - Return 401 if token invalid or expired

- [x] Create `POST /auth/verify-email` endpoint (stub for now)
  - Accept token parameter
  - For MVP: simple implementation or skip (mark as TODO)
  - Return success if token valid

- [x] Create `POST /auth/reset-password` endpoint (stub for now)
  - Accept email parameter
  - For MVP: simple implementation or skip (mark as TODO)
  - Return success message

- [x] Add rate limiting to auth endpoints
  - Install `express-rate-limit`
  - Limit login to 5 attempts per 15 minutes per IP
  - Limit register to 3 attempts per hour per IP

### Frontend Auth Screens

- [x] Create authentication context with React Context API
  - Create `AuthContext.tsx` with user state and auth methods
  - Methods: `login(email, password)`, `register(email, password)`, `logout()`
  - Store JWT tokens in AsyncStorage
  - Provide `isAuthenticated`, `user`, `loading` states

- [x] Create Login screen UI
  - Email input field (keyboard type: email-address, autoCapitalize: none)
  - Password input field (secureTextEntry: true)
  - "Login" button (disabled while loading)
  - "Don't have an account? Sign up" link
  - Display error messages below form (red text)

- [ ] Create Register screen UI
  - Email input field
  - Password input field with strength indicator
  - Confirm password field
  - "Sign Up" button (disabled while loading)
  - "Already have an account? Login" link
  - Display error messages

- [ ] Implement login flow
  - Call `POST /auth/login` API on button press
  - Store tokens in AsyncStorage on success
  - Update AuthContext user state
  - Navigate to onboarding or home screen
  - Show error toast/alert on failure

- [ ] Implement registration flow
  - Validate passwords match on frontend
  - Call `POST /auth/register` API
  - Show success message: "Check your email to verify account"
  - Navigate to login screen
  - Show error toast/alert on failure

- [ ] Create token refresh mechanism
  - Axios interceptor to catch 401 responses
  - Attempt to refresh token with `POST /auth/refresh` (create endpoint)
  - Retry failed request with new token
  - Logout user if refresh fails

- [ ] Implement logout functionality
  - Clear AsyncStorage tokens
  - Reset AuthContext state
  - Navigate to login screen

---

## 🎨 Onboarding Flow

### Onboarding Screens

- [ ] Create onboarding navigation stack
  - Install React Navigation 6.x: `@react-navigation/native`, `@react-navigation/stack`
  - Create `OnboardingNavigator.tsx` with 7 screens
  - Configure screen transitions (slide animations)

- [ ] Create Welcome screen (Step 1)
  - Display app logo and tagline
  - Brief intro text (2-3 sentences about app value)
  - Medical disclaimer text (small font): "Not medical advice..."
  - "Get Started" button
  - Skip onboarding option (small text link)

- [ ] Create Current Stage screen (Step 2)
  - Radio button group: "I am currently pregnant" / "I am already a parent"
  - Store selection in local state
  - "Next" button (disabled until selection made)
  - "Back" button

- [ ] Create Timeline Input screen (Step 3)
  - Conditional rendering based on previous answer
  - If pregnant: DatePicker for due date (future dates only)
  - If parent: DatePicker for baby birth date (past dates only, max 24 months ago)
  - "Next" button validates date selected

- [ ] Create Baby Info screen (Step 4)
  - Only shown if user selected "Already a parent"
  - Text input: Baby's name (optional, placeholder: "You can add this later")
  - Radio buttons: Male / Female / Prefer not to say (optional)
  - "Next" button always enabled

- [ ] Create Parenting Philosophy screen (Step 5 - Question 1)
  - Single-select radio buttons
  - Options: Gentle/Attachment, Structured/Scheduled, Balanced/Flexible, Still figuring it out, Prefer not to say
  - "Next" button enabled after selection

- [ ] Create Religious Background screen (Step 5 - Question 2)
  - Multi-select checkboxes
  - Options: Christian (expandable sub-options), Muslim, Jewish, Hindu, Buddhist, Secular, Spiritual, Prefer not to say
  - Allow multiple selections
  - "Next" button always enabled

- [ ] Create Cultural Background screen (Step 5 - Question 3)
  - Optional text area input (multiline)
  - Placeholder: "e.g., Latin American, South Asian, etc."
  - Character limit: 200
  - "Next" button always enabled

- [ ] Create Concerns screen (Step 5 - Question 4)
  - Multi-select checkboxes (max 3 selections)
  - Options: Sleep, Feeding, Development, Health, Crying, Postpartum recovery, Work/parenting balance, Partner coordination
  - Show counter: "Selected: 2/3"
  - "Next" button enabled after at least 1 selection

- [ ] Create Notification Preferences screen (Step 6)
  - Toggle switches for each preference
  - "Daily milestone updates" (default: ON)
  - "Weekly tips and guidance" (default: ON)
  - "Reminder to log milestones" (default: ON)
  - "Next" button always enabled

- [ ] Create Usage Limits Explanation screen (Step 7)
  - Visual explanation of free tier: "10 messages/day + 10 minutes voice/day"
  - List of premium benefits with checkmarks
  - Two buttons: "Start Free Trial" (primary), "Continue with Free" (secondary)
  - Small text: "Free trial requires credit card, cancel anytime"

### Onboarding Backend Integration

- [ ] Create `PUT /user/profile` endpoint
  - Accept all onboarding data in request body
  - Validate userId from JWT token
  - Update UserProfile record with onboarding answers
  - Return updated profile data

- [ ] Save onboarding data to backend
  - Call API after Step 7 completion
  - Send all collected data in single request
  - Handle errors gracefully (allow retry)
  - Store data in AuthContext on success

- [ ] Navigate to main app after onboarding
  - Check if user has completed onboarding on app launch
  - If not, show onboarding flow
  - If completed, go to home screen
  - Store onboarding completion flag in AsyncStorage

---

**Progress:** ⬜ 0/44 tasks completed

**Previous Phase:** [Phase 0: Setup](todo-phase-0-setup.md)
**Next Phase:** [Phase 2: Chat & Voice](todo-phase-2-chat-voice.md)
