# AI Parenting Assistant - Development Todo List

> **Optimized for AI-Assisted Development**
> This todo list is structured to minimize hallucinations and bugs by breaking down complex features into small, well-defined tasks with clear specifications and validation criteria.

---

## 🎯 Project Setup & Infrastructure (Phase 0)

### Environment & Tooling
- [ ] Initialize React Native 0.74+ project with TypeScript template
  - Use `npx react-native init AIParentingAssistant --template react-native-template-typescript`
  - Verify iOS and Android builds work on fresh install
  - Document Node.js version (20.x LTS) and package manager (npm/yarn)

- [ ] Configure TypeScript strict mode
  - Set `strict: true` in tsconfig.json
  - Enable `strictNullChecks`, `noImplicitAny`, `strictFunctionTypes`
  - Add path aliases for cleaner imports (`@components`, `@utils`, `@api`, etc.)

- [ ] Set up ESLint and Prettier
  - Install `@react-native-community/eslint-config`
  - Configure Prettier with 2-space indentation, single quotes
  - Add Husky pre-commit hooks for linting
  - Create `.prettierrc` and `.eslintrc.js` files

- [ ] Initialize Git repository with proper .gitignore
  - Use React Native template .gitignore
  - Add `.env*` files to gitignore
  - Create initial commit with base project structure

- [ ] Set up backend Node.js project
  - Initialize separate `/backend` directory with TypeScript
  - Use Express.js 4.x framework
  - Configure `tsconfig.json` for Node.js (commonjs modules)
  - Set up nodemon for development hot-reload

- [ ] Configure environment variables management
  - Install `dotenv` for backend
  - Install `react-native-config` for mobile
  - Create `.env.example` files with all required variables (no values)
  - Document all environment variables in README

### Database & Storage
- [ ] Set up PostgreSQL database (local development)
  - Install PostgreSQL 15+ locally or use Docker
  - Create database: `ai_parenting_assistant_dev`
  - Document connection string format

- [ ] Install and configure Prisma ORM
  - Run `npm install prisma @prisma/client`
  - Initialize Prisma: `npx prisma init`
  - Configure `schema.prisma` with PostgreSQL datasource
  - Set up migration workflow

- [ ] Set up Redis for caching (local development)
  - Install Redis locally or use Docker
  - Test connection with redis-cli
  - Install `redis` npm package in backend

- [ ] Configure AWS S3 for photo storage (development bucket)
  - Create S3 bucket with public read disabled
  - Generate IAM credentials with S3-only access
  - Install `@aws-sdk/client-s3` package
  - Test upload/download with dummy file

### CI/CD & Deployment Prep
- [ ] Set up GitHub repository
  - Create public or private repo
  - Add collaborators if team-based
  - Configure branch protection rules (require PR reviews)

- [ ] Configure GitHub Actions for backend
  - Create `.github/workflows/backend-ci.yml`
  - Add linting, type-checking, and test steps
  - Run on PR and push to main

- [ ] Configure EAS Build for React Native
  - Install `eas-cli` globally
  - Run `eas build:configure`
  - Set up development build profiles for iOS and Android

---

## 📊 Database Schema & Models (Phase 1)

### Define Prisma Schema Models
- [ ] Create `User` model in schema.prisma
  - Fields: id (UUID), email (unique), passwordHash, createdAt, updatedAt
  - Fields: subscriptionTier (enum: FREE, PREMIUM), subscriptionStatus (enum), subscriptionExpiresAt
  - Add indexes on email for fast lookup

- [ ] Create `UserProfile` model
  - Fields: userId (FK to User), mode (enum: PREGNANCY, PARENTING)
  - Fields: dueDate (nullable DateTime), babyBirthDate (nullable DateTime)
  - Fields: babyName (nullable), babyGender (nullable enum)
  - Fields: parentingPhilosophy (Json), religiousViews (Json), culturalBackground (String)
  - Fields: concerns (String array), notificationPreferences (Json)
  - One-to-one relation with User

- [ ] Create `Message` model
  - Fields: id (UUID), userId (FK), sessionId (UUID for grouping)
  - Fields: role (enum: USER, ASSISTANT), content (text)
  - Fields: contentType (enum: TEXT, VOICE, IMAGE)
  - Fields: mediaUrls (String array), tokensUsed (Int), timestamp (DateTime)
  - Index on userId and timestamp for fast chat history queries

- [ ] Create `Milestone` model
  - Fields: id (UUID), userId (FK), type (enum: PHYSICAL, FEEDING, SLEEP, SOCIAL, HEALTH)
  - Fields: name (String), achievedDate (DateTime), notes (text, nullable)
  - Fields: photoUrls (String array), aiSuggested (Boolean), confirmed (Boolean)
  - Index on userId and achievedDate

- [ ] Create `Photo` model
  - Fields: id (UUID), userId (FK), milestoneId (FK, nullable), albumId (nullable)
  - Fields: s3Key (unique String), uploadedAt (DateTime)
  - Fields: metadata (Json for EXIF data), analysisResults (Json, nullable)
  - Index on userId and uploadedAt

- [ ] Create `UsageTracking` model
  - Fields: id (UUID), userId (FK), date (Date)
  - Fields: messagesUsed (Int default 0), voiceMinutesUsed (Float default 0)
  - Fields: photosStored (Int default 0)
  - Unique constraint on userId + date (one record per user per day)

- [ ] Run initial Prisma migration
  - Execute `npx prisma migrate dev --name init`
  - Verify all tables created in database
  - Generate Prisma Client: `npx prisma generate`

---

## 🔐 Authentication System (Phase 1)

### Backend Auth API
- [ ] Install authentication dependencies
  - `npm install bcrypt jsonwebtoken express-validator`
  - `npm install @types/bcrypt @types/jsonwebtoken --save-dev`

- [ ] Create `POST /auth/register` endpoint
  - Validate email format and password strength (min 8 chars, 1 number)
  - Hash password with bcrypt (10 salt rounds)
  - Create User and UserProfile records in transaction
  - Return success message (do NOT auto-login, require email verification)
  - Handle duplicate email error gracefully

- [ ] Create `POST /auth/login` endpoint
  - Validate email and password fields present
  - Look up user by email
  - Compare password with bcrypt
  - Generate JWT access token (7-day expiry) and refresh token (30-day)
  - Return tokens and basic user info (id, email, subscriptionTier)

- [ ] Create JWT generation utility
  - Function `generateAccessToken(userId, email)` returns signed JWT
  - Function `generateRefreshToken(userId)` returns refresh token
  - Use separate secrets for access and refresh tokens (env variables)
  - Include userId and email in access token payload

- [ ] Create JWT verification middleware
  - Middleware `authenticateToken(req, res, next)`
  - Extract token from `Authorization: Bearer <token>` header
  - Verify token with jwt.verify()
  - Attach decoded user data to `req.user`
  - Return 401 if token invalid or expired

- [ ] Create `POST /auth/verify-email` endpoint (stub for now)
  - Accept token parameter
  - For MVP: simple implementation or skip (mark as TODO)
  - Return success if token valid

- [ ] Create `POST /auth/reset-password` endpoint (stub for now)
  - Accept email parameter
  - For MVP: simple implementation or skip (mark as TODO)
  - Return success message

- [ ] Add rate limiting to auth endpoints
  - Install `express-rate-limit`
  - Limit login to 5 attempts per 15 minutes per IP
  - Limit register to 3 attempts per hour per IP

### Frontend Auth Screens
- [ ] Create authentication context with React Context API
  - Create `AuthContext.tsx` with user state and auth methods
  - Methods: `login(email, password)`, `register(email, password)`, `logout()`
  - Store JWT tokens in AsyncStorage
  - Provide `isAuthenticated`, `user`, `loading` states

- [ ] Create Login screen UI
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

## 🎨 Onboarding Flow (Phase 1)

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

## 💬 Chat Interface - Basic (Phase 2)

### Backend Chat API
- [ ] Install OpenAI SDK
  - `npm install openai`
  - Configure API key in .env file
  - Create OpenAI client instance in `services/openai.ts`

- [ ] Create chat service utility
  - Function `generateChatResponse(messages, userProfile)`
  - Build system prompt from user profile data
  - Include last 10 messages for context
  - Call OpenAI GPT-4 Turbo API
  - Return assistant response and token count

- [ ] Create `POST /chat/message` endpoint
  - Authenticate with JWT middleware
  - Validate message content (not empty, max 2000 chars)
  - Check daily usage limit for user (query UsageTracking)
  - Return 429 error if limit exceeded
  - Fetch last 10 messages for context
  - Call chat service to generate response
  - Save both user message and assistant response to Message table
  - Update UsageTracking messagesUsed count
  - Return assistant response

- [ ] Create `GET /chat/history` endpoint
  - Authenticate with JWT middleware
  - Paginate messages (limit: 50, offset: query param)
  - Filter by userId from token
  - Order by timestamp descending
  - Return array of messages

- [ ] Create `DELETE /chat/session` endpoint
  - Authenticate with JWT middleware
  - Delete all messages for user's current sessionId
  - Generate new sessionId for next conversation
  - Return success message

### Frontend Chat UI
- [ ] Create Chat screen layout
  - Header: Display baby name and age (or pregnancy week)
  - Message list: FlatList for scrollable chat history
  - Input area: TextInput with send button
  - Footer: Medical disclaimer text (small, gray)

- [ ] Create Message component
  - User messages: right-aligned, blue background
  - Assistant messages: left-aligned, gray background
  - Show timestamp (formatted with date-fns)
  - Word-wrap long messages
  - Different styling for loading state

- [ ] Implement send message functionality
  - Disable input while message is sending
  - Add user message to local state immediately (optimistic UI)
  - Call `POST /chat/message` API
  - Add assistant response to message list
  - Scroll to bottom after new message
  - Handle errors (show retry button)

- [ ] Implement chat history loading
  - Fetch messages on screen mount
  - Call `GET /chat/history` API
  - Display in FlatList (reverse chronological order)
  - Add pull-to-refresh gesture
  - Add loading indicator

- [ ] Add typing indicator
  - Show "AI is typing..." animation while waiting for response
  - Use animated dots component
  - Display below last message

- [ ] Add "New Conversation" button
  - Header right button
  - Call `DELETE /chat/session` API
  - Clear local message state
  - Generate new sessionId on frontend

- [ ] Display usage counter
  - Fetch current usage from backend on screen mount
  - Create `GET /usage/today` endpoint to return messagesUsed and voiceMinutesUsed
  - Show badge in header: "7/10 messages today"
  - Update counter after each message sent

---

## 🎙️ Voice Input - Whisper Transcription (Phase 2)

### Backend Voice Transcription
- [ ] Create `POST /chat/voice` endpoint
  - Authenticate with JWT middleware
  - Accept audio file upload (multipart/form-data)
  - Use Multer middleware for file handling
  - Validate file type (audio/m4a, audio/wav, audio/mpeg)
  - Max file size: 25MB (Whisper API limit)
  - Check daily voice usage limit

- [ ] Implement Whisper API integration
  - Call OpenAI Whisper API with audio file
  - Use `whisper-1` model
  - Set language to 'en' for better accuracy
  - Return transcribed text

- [ ] Process transcribed message
  - After successful transcription, treat as regular text message
  - Call chat service to generate AI response
  - Save user message with contentType: VOICE
  - Store audio file URL in mediaUrls if needed
  - Update UsageTracking (voiceMinutesUsed NOT incremented for Whisper)
  - Return transcription and assistant response

### Frontend Voice Recording
- [ ] Install audio recording library
  - `npm install react-native-audio-recorder-player`
  - Link native dependencies for iOS and Android
  - Request microphone permissions (iOS: Info.plist, Android: AndroidManifest.xml)

- [ ] Create voice recording hook
  - Custom hook `useVoiceRecorder()`
  - State: isRecording, recordingPath, duration
  - Methods: startRecording(), stopRecording(), cancelRecording()
  - Use react-native-audio-recorder-player for recording

- [ ] Add microphone button to chat input
  - Icon button next to text input
  - Press and hold to record, release to send
  - Visual feedback: button changes color during recording
  - Show recording duration timer

- [ ] Implement voice recording UI
  - Show waveform animation during recording (simple animated view)
  - Display recording time (00:00 format)
  - Max recording length: 2 minutes (stop automatically)
  - Cancel gesture: swipe left while holding

- [ ] Upload and transcribe audio
  - After recording stops, show loading state
  - Upload audio file to `POST /chat/voice` endpoint
  - Use FormData for multipart upload
  - Display transcribed text in chat before AI responds
  - Show AI typing indicator
  - Add assistant response to chat

- [ ] Handle voice errors
  - Show error if transcription fails: "Couldn't transcribe - please try again"
  - Add retry button
  - Fallback to text input if microphone permission denied

---

## 🗣️ Advanced Voice Conversation Mode (Phase 2)

### Backend Real-Time Voice
- [ ] Install Socket.io for WebSocket
  - Backend: `npm install socket.io`
  - Frontend: `npm install socket.io-client`

- [ ] Create Socket.io server
  - Initialize Socket.io in Express app
  - Add authentication middleware for socket connections (verify JWT)
  - Create namespace `/voice` for voice conversations

- [ ] Create `POST /voice/start-session` endpoint
  - Authenticate user
  - Generate unique sessionId
  - Initialize voice conversation context
  - Return sessionId and WebSocket connection URL

- [ ] Implement WebSocket voice handler
  - Listen for `audio_chunk` events from client
  - Buffer audio chunks until silence detected
  - Send complete audio to Whisper API for transcription
  - Generate AI response with GPT-4
  - Convert response to speech with OpenAI TTS API
  - Emit `transcription` and `audio_response` events to client

- [ ] Create `POST /voice/end-session` endpoint
  - Close WebSocket connection
  - Calculate total voice minutes used
  - Update UsageTracking voiceMinutesUsed
  - Save conversation transcript as Message records
  - Return session summary

### Frontend Voice Conversation UI
- [ ] Create VoiceMode screen
  - Full-screen modal overlay
  - Large pulsing animation in center (indicates AI listening/speaking)
  - Display live transcription text below animation
  - "End Conversation" button at bottom
  - Show elapsed time timer

- [ ] Implement WebSocket connection
  - Connect to Socket.io server on session start
  - Listen for `transcription` and `audio_response` events
  - Handle reconnection on network issues
  - Close connection on screen exit

- [ ] Implement audio streaming
  - Record audio in chunks (streaming mode)
  - Send chunks to server via WebSocket
  - Detect silence for turn-taking (voice activity detection)
  - Handle interruptions (user speaks while AI is talking)

- [ ] Play AI audio responses
  - Install `react-native-sound` for audio playback
  - Receive audio data from WebSocket
  - Play audio through speaker
  - Show visual feedback (pulsing animation) during playback

- [ ] Add voice mode button to chat screen
  - Distinct icon (different from microphone button)
  - Tap to open VoiceMode screen
  - Show remaining voice minutes before starting

- [ ] Track voice session time
  - Start timer when session begins
  - Update every second
  - Show remaining minutes: "8 min remaining"
  - Show 1-minute warning when approaching limit
  - Auto-end session when limit reached

---

## 📸 Photo Upload & Storage (Phase 3)

### Backend Photo Management
- [ ] Create photo upload utility
  - Function `uploadToS3(file, userId)`
  - Generate unique S3 key: `${userId}/${timestamp}-${filename}`
  - Upload file to S3 bucket using AWS SDK
  - Return S3 key and public URL (signed URL for temporary access)

- [ ] Create `POST /photos/upload` endpoint
  - Authenticate user
  - Accept single or multiple files (max 3 per request)
  - Validate file types: JPEG, PNG, HEIC
  - Validate file size: max 10MB per file
  - Compress images on server if needed (use Sharp library)
  - Upload to S3 via uploadToS3 utility
  - Create Photo record in database for each uploaded file
  - Check free user photo limit (100 photos max)
  - Return array of uploaded photo objects (id, url, s3Key)

- [ ] Create `GET /photos/list` endpoint
  - Authenticate user
  - Support pagination (limit, offset)
  - Support filtering by milestoneId, albumId
  - Order by uploadedAt descending
  - Generate signed URLs for each photo (24-hour expiry)
  - Return array of photos with metadata

- [ ] Create `DELETE /photos/:id` endpoint
  - Authenticate user
  - Verify photo belongs to user
  - Delete photo from S3
  - Delete Photo record from database
  - Return success message

- [ ] Create `POST /photos/analyze` endpoint
  - Authenticate user
  - Accept photo upload (single file)
  - Upload to S3 first
  - Send to OpenAI Vision API (GPT-4o)
  - Include specific prompt for baby-related analysis (rashes, diaper contents, safety hazards)
  - Parse AI analysis results
  - Save analysis to Photo.analysisResults field
  - Return analysis text and photo URL

### Frontend Photo Features
- [ ] Install image picker library
  - `npm install react-native-image-picker`
  - Configure iOS permissions (NSPhotoLibraryUsageDescription, NSCameraUsageDescription)
  - Configure Android permissions (CAMERA, READ_EXTERNAL_STORAGE)

- [ ] Add attachment button to chat input
  - Paperclip icon next to text input
  - Tap to show action sheet: "Take Photo" / "Choose from Library"

- [ ] Implement photo selection
  - Open camera or photo library via react-native-image-picker
  - Allow multi-select in library (max 3 photos)
  - Show thumbnails of selected photos in chat input area
  - Add "X" button to remove photo before sending

- [ ] Upload photos with message
  - When user sends message with photos, upload first
  - Call `POST /photos/upload` endpoint
  - Show upload progress indicator for each photo
  - After upload completes, send chat message with photoUrls
  - Display photos inline in chat message bubble

- [ ] Create Photos tab/screen
  - Bottom tab navigation item
  - Grid layout (3 columns) using FlatList
  - Fetch photos on mount via `GET /photos/list`
  - Implement infinite scroll (load more on scroll to bottom)
  - Add pull-to-refresh gesture

- [ ] Implement full-screen photo viewer
  - Tap photo thumbnail to open full-screen modal
  - Swipe left/right to navigate between photos
  - Pinch-to-zoom gesture
  - Show photo details overlay (date, milestone tag)
  - "Download" button to save to device camera roll
  - "Delete" button (with confirmation alert)

- [ ] Add photo analysis feature
  - In full-screen viewer, add "Analyze" button
  - Call `POST /photos/analyze` with photo
  - Show loading indicator during analysis
  - Display AI analysis results in modal overlay
  - Show medical disclaimer before first analysis

---

## 🏆 Milestone Tracking (Phase 3)

### Backend Milestone API
- [ ] Create `GET /milestones` endpoint
  - Authenticate user
  - Fetch all milestones for user
  - Support filtering by type (query param)
  - Support filtering by confirmed/unconfirmed
  - Order by achievedDate descending
  - Return array of milestones with photo URLs

- [ ] Create `POST /milestones` endpoint
  - Authenticate user
  - Accept milestone data: type, name, achievedDate, notes, photoUrls, confirmed
  - Validate achievedDate not in future
  - Create Milestone record
  - Return created milestone object

- [ ] Create `PUT /milestones/:id` endpoint
  - Authenticate user
  - Verify milestone belongs to user
  - Update milestone fields (name, achievedDate, notes)
  - Return updated milestone

- [ ] Create `DELETE /milestones/:id` endpoint
  - Authenticate user
  - Verify milestone belongs to user
  - Delete Milestone record
  - Return success message

- [ ] Implement AI milestone suggestion logic
  - Function `suggestMilestones(userProfile)`
  - Calculate baby age from birthDate
  - Return age-appropriate milestones (e.g., "First smile" at 6-8 weeks)
  - Use predefined milestone templates
  - Mark milestones as aiSuggested: true

- [ ] Create `GET /milestones/suggestions` endpoint
  - Authenticate user
  - Fetch user profile (baby age)
  - Call suggestMilestones utility
  - Return array of suggested milestones

### Frontend Milestone Features
- [ ] Create Milestones tab/screen
  - Bottom tab navigation item
  - Header with toggle: "Timeline" / "Categories"
  - Timeline view as default

- [ ] Implement Timeline view
  - Vertical scrollable list with date markers
  - Display milestone cards with name, date, thumbnail photo
  - Group by month
  - Tap card to open detail view

- [ ] Implement Categories view
  - Horizontal scrolling category tabs
  - Categories: Physical, Feeding, Sleep, Social, Health
  - Tap category to filter milestones
  - Show filtered list below

- [ ] Create Milestone detail screen
  - Show milestone name, date, type
  - Display notes if present
  - Show full-size photos in carousel
  - "Edit" button (opens edit form)
  - "Delete" button (with confirmation)

- [ ] Create Add Milestone screen
  - Text input: Milestone name
  - Dropdown: Milestone type
  - Date picker: Achieved date
  - Text area: Notes (optional)
  - Photo picker: Add photos (multiple selection)
  - "Save" button

- [ ] Integrate AI milestone suggestions in chat
  - When baby reaches milestone age, AI asks in chat: "Has [Baby] started rolling over yet?"
  - Show inline buttons: "Yes!" / "Not Yet"
  - If "Yes!", trigger add milestone flow (pre-filled name and date)
  - Prompt to upload photo
  - Show celebration animation (confetti or similar)
  - If "Not Yet", schedule reminder for 2 weeks (create reminder system or note in database)

- [ ] Implement milestone prompts
  - Fetch suggestions from `GET /milestones/suggestions` weekly
  - Display as chat message from AI
  - User can confirm or dismiss

- [ ] Create milestone export feature
  - "Export to PDF" button in Milestones screen settings
  - Generate PDF report with milestone timeline and photos
  - Use library like `react-native-html-to-pdf`
  - Share via native share sheet

---

## 💳 Monetization & Subscriptions (Phase 4)

### Backend Subscription Management
- [ ] Install Stripe SDK
  - `npm install stripe`
  - Configure Stripe secret key in .env
  - Initialize Stripe client

- [ ] Create `GET /subscription/status` endpoint
  - Authenticate user
  - Return user's subscriptionTier, subscriptionStatus, subscriptionExpiresAt
  - Include usage stats (messagesUsed, voiceMinutesUsed, photosStored)

- [ ] Create `POST /subscription/create` endpoint
  - Authenticate user
  - Accept priceId from Stripe (monthly or yearly)
  - Create Stripe Customer if not exists
  - Create Stripe Subscription
  - Store Stripe customerId and subscriptionId in User table
  - Update subscriptionTier to PREMIUM
  - Return subscription object

- [ ] Create `POST /subscription/cancel` endpoint
  - Authenticate user
  - Cancel Stripe subscription (set cancel_at_period_end: true)
  - Update subscriptionStatus to CANCELLED
  - Keep premium access until current period ends
  - Return success message

- [ ] Create `POST /stripe/webhook` endpoint
  - Verify Stripe webhook signature
  - Handle subscription events: invoice.paid, customer.subscription.deleted, customer.subscription.updated
  - Update User subscription status based on events
  - Return 200 status to Stripe

- [ ] Implement usage limit checking middleware
  - Function `checkUsageLimit(userId, limitType)`
  - Query UsageTracking for today's usage
  - Compare with free tier limits (10 messages, 10 voice minutes)
  - If user is premium, return true (unlimited)
  - If free user exceeds limit, return false
  - Use in chat and voice endpoints before processing

### Frontend Subscription UI
- [ ] Install in-app purchase library
  - `npm install react-native-iap`
  - Configure iOS App Store Connect products
  - Configure Google Play Console products
  - Set up product IDs in .env

- [ ] Create Paywall modal component
  - Semi-transparent overlay (cannot dismiss by tapping outside)
  - Centered card with friendly design
  - Headline: "You've reached today's limit"
  - Subtext explaining limit reset time (midnight)
  - List premium benefits with checkmarks
  - Pricing display: $9.99/month or $99/year (save 17%)
  - Two CTA buttons: "Upgrade Now" (primary), "Remind Me Tomorrow" (secondary)
  - Small text link: "Continue with Free" (closes modal)

- [ ] Trigger paywall on limit reached
  - After sending message, check response for 429 error
  - If 429, show paywall modal
  - Disable message input until limit resets or user upgrades
  - Show countdown timer: "Resets in 8 hours 23 minutes"

- [ ] Implement subscription purchase flow
  - Tap "Upgrade Now" button
  - Show price selection: Monthly / Yearly toggle
  - Call react-native-iap to request payment
  - On successful purchase, call `POST /subscription/create` with receipt
  - Update local user state to premium
  - Close paywall and enable features

- [ ] Create Subscription Management screen (in Settings)
  - Display current plan (Free or Premium)
  - If premium, show renewal date and price
  - "Manage Subscription" button (opens App Store/Play Store subscription settings)
  - "Cancel Subscription" button (with confirmation alert)
  - Call `POST /subscription/cancel` on confirm

- [ ] Implement restore purchases functionality
  - "Restore Purchases" button in settings
  - Call react-native-iap.getAvailablePurchases()
  - Verify receipt with backend
  - Update local state if valid subscription found

- [ ] Add usage counter UI
  - Display in chat screen header
  - Badge showing: "7/10 messages" and "6/10 voice minutes"
  - Update after each message/voice session
  - If premium, show "Unlimited" instead of counter

---

## ⚙️ Settings & User Profile (Phase 5)

### Backend Settings API
- [ ] Create `PUT /user/profile` endpoint (if not already created)
  - Authenticate user
  - Accept profile updates: babyName, babyGender, concerns, preferences
  - Validate input data
  - Update UserProfile record
  - Return updated profile

- [ ] Create `POST /user/toggle-mode` endpoint
  - Authenticate user
  - Verify current mode is PREGNANCY
  - Update mode to PARENTING
  - Prompt for baby details (name, gender, birthDate) if not provided
  - Mark toggle as irreversible (add toggledAt timestamp)
  - Return success message

- [ ] Create `DELETE /user/account` endpoint
  - Authenticate user
  - Delete all user data: Messages, Milestones, Photos (from S3 and DB), UserProfile, User
  - Use database transaction for atomicity
  - Cancel Stripe subscription if active
  - Return success message

- [ ] Create `GET /user/data-export` endpoint
  - Authenticate user
  - Compile all user data into JSON format
  - Include: profile, messages, milestones, photos metadata
  - Generate presigned S3 URLs for photos (7-day expiry)
  - Return JSON file for download (GDPR compliance)

### Frontend Settings Screens
- [ ] Create Settings tab/screen
  - Bottom tab navigation item
  - Grouped list style layout
  - Sections: Account, Profile, Notifications, Privacy, Subscription, About

- [ ] Implement Account Settings section
  - "Change Email" row (navigates to form screen)
  - "Change Password" row (navigates to form screen)
  - "Delete Account" row (shows confirmation alert with warning)

- [ ] Create Change Email screen
  - Text input: New email
  - Text input: Password (for verification)
  - "Save" button
  - Call backend endpoint (create `PUT /user/email` if needed)

- [ ] Create Change Password screen
  - Text input: Current password
  - Text input: New password
  - Text input: Confirm new password
  - "Save" button
  - Call backend endpoint (create `PUT /user/password` if needed)

- [ ] Implement Profile & Personalization section
  - "Edit Profile" row (navigates to form with all onboarding fields)
  - "Mode Toggle" row (only if in PREGNANCY mode)
  - Shows current mode badge

- [ ] Create Edit Profile screen
  - Recreate onboarding quiz fields as editable form
  - Pre-populate with current values
  - "Save Changes" button
  - Call `PUT /user/profile` endpoint

- [ ] Implement mode toggle flow
  - Tap "Switch to Parenting Mode" button
  - Show confirmation alert with congratulations message
  - Prompt for baby details (name, gender, birthDate) in modal
  - Call `POST /user/toggle-mode` endpoint
  - Update local state and refresh UI

- [ ] Implement Notifications section
  - Toggle switches for each notification type
  - "Daily milestone updates"
  - "Weekly tips and guidance"
  - "Reminder to log milestones"
  - "Quiet hours" (shows time range picker)
  - Save preferences to backend on toggle change

- [ ] Implement Privacy & Data section
  - "Data Usage Consent" row (shows policy modal)
  - "Clear Chat History" button (with confirmation)
  - "Export My Data" button (calls API, downloads JSON)
  - "Facial Recognition" toggle (for photo organization)

- [ ] Implement App Preferences section
  - "Dark Mode" toggle (use React Native Appearance API)
  - "Text Size" slider (small, medium, large)
  - "Language" row (shows "English" with disabled state for MVP)

- [ ] Create About/Help section
  - App version display
  - "Terms of Service" row (opens web view)
  - "Privacy Policy" row (opens web view)
  - "Contact Support" row (opens email or in-app chat)
  - "About AI" row (opens explanation screen)

---

## 🎨 UI/UX Polish (Phase 5)

### Design System
- [ ] Define color palette
  - Primary color (brand blue)
  - Secondary color (accent)
  - Background colors (light/dark mode)
  - Text colors (primary, secondary, disabled)
  - Error, success, warning colors
  - Create `theme.ts` file with color constants

- [ ] Define typography scale
  - Font family (use system fonts: SF Pro for iOS, Roboto for Android)
  - Font sizes: heading1, heading2, body, caption, button
  - Font weights: light, regular, medium, bold
  - Line heights for readability

- [ ] Create reusable UI components
  - Button component (primary, secondary, text variants)
  - Input component (text, email, password types)
  - Card component (for milestones, photos)
  - Badge component (for usage counter)
  - Modal component (for paywall, alerts)

### Accessibility
- [ ] Add accessibility labels to all interactive elements
  - Use `accessibilityLabel` prop on buttons, inputs, images
  - Use `accessibilityHint` for complex interactions
  - Use `accessibilityRole` to indicate element types

- [ ] Test with VoiceOver (iOS)
  - Enable VoiceOver in iOS Simulator
  - Navigate through all screens
  - Verify all elements are readable
  - Fix any navigation issues

- [ ] Test with TalkBack (Android)
  - Enable TalkBack on Android device/emulator
  - Navigate through all screens
  - Verify all elements are readable
  - Fix any navigation issues

- [ ] Implement Dynamic Type support
  - Use scaled font sizes based on system settings
  - Test with large text sizes
  - Ensure layouts don't break

- [ ] Ensure color contrast ratios
  - Test all text/background combinations
  - Minimum 4.5:1 ratio for normal text
  - Use online contrast checker tool

- [ ] Add "Reduce Motion" support
  - Detect system preference for reduced motion
  - Disable or simplify animations when enabled

### Animations & Transitions
- [ ] Add screen transition animations
  - Use React Navigation default transitions
  - Customize if needed for brand feel

- [ ] Add button press feedback
  - Use `Pressable` component with opacity change
  - Or add scale animation on press

- [ ] Add loading skeletons
  - Show skeleton placeholders while loading chat, photos, milestones
  - Use libraries like react-native-shimmer-placeholder

- [ ] Add micro-interactions
  - Confetti animation on milestone confirmation
  - Pulsing animation for voice mode
  - Smooth scroll animations

### Error Handling & Empty States
- [ ] Create error boundary component
  - Catch JavaScript errors in component tree
  - Show friendly error screen with "Retry" button
  - Log errors to Sentry

- [ ] Design empty state screens
  - Chat: "Start your first conversation!"
  - Milestones: "Your milestone journey starts here!"
  - Photos: "Add your first photo to build memories!"
  - Include illustrations and helpful copy

- [ ] Implement retry mechanisms
  - Add "Retry" button on failed API calls
  - Auto-retry with exponential backoff for transient errors
  - Show clear error messages

### Performance Optimization
- [ ] Optimize image loading
  - Use react-native-fast-image for caching
  - Lazy load images in photo grid
  - Compress images before upload

- [ ] Optimize FlatList rendering
  - Use `getItemLayout` for fixed-height items
  - Use `removeClippedSubviews` prop
  - Use `maxToRenderPerBatch` to limit initial render

- [ ] Implement code splitting (if bundle size is large)
  - Use React.lazy() for heavy screens
  - Split by feature (chat, milestones, photos)

- [ ] Profile app with React Native Debugger
  - Check for unnecessary re-renders
  - Memoize expensive components
  - Use React.memo and useMemo where appropriate

---

## 🧪 Testing & QA (Phase 5)

### Backend Testing
- [ ] Write unit tests for authentication
  - Test password hashing
  - Test JWT generation and verification
  - Test rate limiting logic

- [ ] Write unit tests for chat service
  - Mock OpenAI API responses
  - Test prompt generation
  - Test context inclusion logic

- [ ] Write integration tests for API endpoints
  - Use Supertest library
  - Test authentication middleware
  - Test successful and error cases
  - Test rate limiting

- [ ] Write tests for Stripe webhook handling
  - Mock Stripe events
  - Verify subscription status updates

### Frontend Testing
- [ ] Write unit tests for utility functions
  - Date formatting helpers
  - Validation functions
  - Token storage helpers

- [ ] Write component tests for UI components
  - Use React Native Testing Library
  - Test Button, Input, Card components
  - Test user interactions (press, type)

- [ ] Write integration tests for key flows
  - Test login flow
  - Test onboarding flow
  - Test sending message flow

- [ ] Set up E2E testing with Detox (optional for MVP)
  - Configure Detox for iOS and Android
  - Write test for complete user journey
  - Run in CI pipeline

### Manual QA Checklist
- [ ] Test on multiple iOS devices
  - iPhone 8 (smallest supported)
  - iPhone 14 Pro (notch)
  - iPad (tablet layout)

- [ ] Test on multiple Android devices
  - Low-end device (Android 7.0)
  - Samsung Galaxy (One UI)
  - Google Pixel (stock Android)

- [ ] Test all user flows end-to-end
  - Registration → Onboarding → First message → Photo upload → Milestone → Upgrade

- [ ] Test edge cases
  - Poor network conditions (simulate with Network Link Conditioner)
  - App backgrounding during voice session
  - Rapid button presses (debounce)
  - Very long messages
  - Special characters in inputs

- [ ] Test accessibility features
  - VoiceOver/TalkBack navigation
  - Large text sizes
  - Color blindness modes

---

## 🚀 Deployment & Launch (Phase 6)

### Backend Deployment
- [ ] Set up production environment
  - Provision AWS infrastructure (EC2, RDS, S3, ElastiCache)
  - Or use managed platform: Render.com, Railway, Heroku

- [ ] Configure production database
  - Create PostgreSQL production instance (AWS RDS)
  - Run Prisma migrations on production DB
  - Set up automated backups

- [ ] Configure production environment variables
  - Use AWS Secrets Manager or similar
  - Set NODE_ENV=production
  - Add all API keys (OpenAI, Stripe, AWS)
  - Add JWT secrets (different from development)

- [ ] Set up SSL certificates
  - Use AWS Certificate Manager or Let's Encrypt
  - Configure HTTPS only

- [ ] Deploy backend to production
  - Build Docker image
  - Push to container registry
  - Deploy to ECS/Elastic Beanstalk or managed platform
  - Verify deployment with health check endpoint

- [ ] Set up monitoring and logging
  - Configure CloudWatch logs
  - Set up Sentry for error tracking
  - Create alerts for error rate spikes

### App Store Preparation (iOS)
- [ ] Create Apple Developer Account
  - Enroll in Apple Developer Program ($99/year)
  - Verify account and team

- [ ] Create App Store Connect listing
  - Add app name, bundle ID, SKU
  - Write app description (concise, keyword-rich)
  - Create screenshots for all device sizes (iPhone, iPad)
  - Add app icon (1024x1024)
  - Set age rating (4+ or 9+)
  - Add privacy policy URL

- [ ] Configure in-app purchases in App Store Connect
  - Create subscription products (monthly, yearly)
  - Set pricing in USD and other currencies
  - Write subscription descriptions
  - Submit for review

- [ ] Build production iOS app
  - Update version number in package.json and Info.plist
  - Use EAS Build: `eas build --platform ios --profile production`
  - Or use Xcode Archive and Export

- [ ] Submit app for App Store review
  - Upload IPA via Transporter or Xcode
  - Fill out App Store review information
  - Provide demo account credentials if needed
  - Add review notes (explain AI features)
  - Submit for review

### Google Play Preparation (Android)
- [ ] Create Google Play Developer Account
  - Pay one-time $25 registration fee
  - Verify account

- [ ] Create Google Play Console listing
  - Add app name, package name
  - Write app description
  - Create screenshots for phone and tablet
  - Add feature graphic, app icon
  - Set content rating (fill out questionnaire)
  - Add privacy policy URL

- [ ] Configure in-app products in Google Play Console
  - Create subscription products (monthly, yearly)
  - Set pricing in USD and other currencies
  - Write subscription descriptions

- [ ] Build production Android app
  - Generate signed APK or AAB
  - Use EAS Build: `eas build --platform android --profile production`
  - Or use Android Studio Build > Generate Signed Bundle/APK

- [ ] Submit app for Google Play review
  - Upload AAB to production track
  - Fill out content rating questionnaire
  - Complete store listing
  - Submit for review (usually faster than iOS)

### Post-Launch Monitoring
- [ ] Monitor app store reviews
  - Set up alerts for new reviews
  - Respond to negative reviews promptly
  - Thank users for positive feedback

- [ ] Monitor crash reports
  - Check Sentry dashboard daily
  - Prioritize critical crashes
  - Release hotfixes if needed

- [ ] Monitor backend performance
  - Check API response times
  - Monitor database query performance
  - Check OpenAI API usage and costs

- [ ] Monitor business metrics
  - Daily signups
  - Daily active users
  - Conversion rate (free to paid)
  - Churn rate
  - Revenue (MRR)

---

## 🔮 Post-MVP Features (Future Phases)

### High Priority (First 3 months)
- [ ] Push notifications system
  - Set up Firebase Cloud Messaging
  - Send milestone reminders
  - Send weekly tips
  - Handle notification taps (deep linking)

- [ ] Partner mode (multi-user accounts)
  - Allow two users to share one baby profile
  - Separate login credentials, shared data
  - Activity feed showing partner's actions

- [ ] Search functionality
  - Search chat history
  - Search milestones
  - Full-text search with Elasticsearch or PostgreSQL full-text

- [ ] Improved photo organization
  - Facial recognition for auto-tagging
  - Custom albums
  - Favorites

### Medium Priority (3-6 months)
- [ ] Offline mode
  - Cache chat history locally
  - Queue messages when offline, sync when online
  - Use WatermelonDB or similar

- [ ] Referral program
  - "Invite a Friend" feature
  - Reward with free premium days
  - Track referral conversions

- [ ] Content library
  - Curated articles on parenting topics
  - Search and filter
  - AI can reference articles in responses

- [ ] Pediatrician integration
  - Export milestone report for doctor visits
  - Share growth charts
  - Log vaccination records

### Lower Priority (6+ months)
- [ ] Community features
  - Parent-to-parent Q&A
  - Moderated forums by topic
  - AI summarizes discussions

- [ ] Sleep/feeding/diaper tracking
  - Log feeds, sleep sessions, diapers
  - AI detects patterns
  - Suggests improvements

- [ ] Smart device integration
  - Connect to baby monitors
  - Sync with smart scales, thermometers

- [ ] Multilingual support
  - Translate UI to Spanish, Mandarin, French
  - OpenAI API supports multiple languages
  - Localize date/time formatting

- [ ] Web app
  - React web version for desktop access
  - Sync with mobile app

---

## 📝 AI Coding Best Practices (Throughout Development)

### General Guidelines
- [ ] **Keep functions small and focused** (max 50 lines)
  - Easier for AI to understand and modify
  - Single responsibility principle

- [ ] **Use descriptive variable and function names**
  - Avoid abbreviations
  - Name should explain purpose: `getUserProfile()` not `getUP()`

- [ ] **Add TypeScript types to everything**
  - No `any` types
  - Define interfaces for all API responses
  - Use enums for fixed sets of values

- [ ] **Write clear comments for complex logic**
  - Explain "why" not "what"
  - Document edge cases and assumptions

- [ ] **Validate all user inputs**
  - Never trust client-side data
  - Use validation libraries (Zod, Joi)
  - Return clear error messages

- [ ] **Handle errors explicitly**
  - Use try-catch blocks
  - Don't swallow errors silently
  - Log errors with context

- [ ] **Test incrementally**
  - Test each feature immediately after building
  - Don't accumulate untested code
  - Fix bugs before moving to next task

### Avoiding Hallucinations
- [ ] **Verify library versions exist**
  - Check npm registry before installing
  - Use exact versions in package.json (not ^)

- [ ] **Don't assume API methods exist**
  - Check official documentation
  - Test API calls in Postman first

- [ ] **Don't invent configuration options**
  - Refer to official docs for config files
  - Copy examples from documentation

- [ ] **Test on actual devices, not just simulator**
  - iOS simulator != real iPhone
  - Android emulator != real Android device
  - Some features only work on physical devices (camera, push notifications)

### Code Review Checklist (For AI-Generated Code)
- [ ] Does the code actually run without errors?
- [ ] Are all imports valid and available?
- [ ] Are all function calls using correct parameters?
- [ ] Is error handling present for all async operations?
- [ ] Are TypeScript types correctly defined?
- [ ] Does the UI look correct on both iOS and Android?
- [ ] Are all edge cases handled (empty states, loading states, errors)?
- [ ] Is the code following project structure and naming conventions?

---

## 📊 Progress Tracking

**Phase 0 (Setup):** ⬜ 0/16 tasks completed
**Phase 1 (Auth & Onboarding):** ⬜ 0/30 tasks completed
**Phase 2 (Chat & Voice):** ⬜ 0/35 tasks completed
**Phase 3 (Photos & Milestones):** ⬜ 0/28 tasks completed
**Phase 4 (Monetization):** ⬜ 0/15 tasks completed
**Phase 5 (Settings & Polish):** ⬜ 0/45 tasks completed
**Phase 6 (Deployment):** ⬜ 0/25 tasks completed

**Total Progress:** ⬜ 0/194 MVP tasks completed

---

## 🎯 Next Steps

1. **Start with Phase 0**: Set up development environment completely before writing any feature code
2. **Build backend first**: API endpoints before frontend screens (easier to test)
3. **Test each feature immediately**: Don't accumulate untested code
4. **Deploy early and often**: Test in production-like environment
5. **Collect feedback continuously**: Start beta as soon as core chat works

**Estimated Timeline:** 22 weeks (5.5 months) with 2-3 engineers working full-time

---

**Good luck! Remember: Small, tested, incremental progress > Large, untested code dumps.**
