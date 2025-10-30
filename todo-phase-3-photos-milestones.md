# Phase 3: Photo Storage & Milestone Tracking

**Focus:** Photo upload to S3, AI Vision analysis, milestone CRUD, timeline UI
**Timeline:** Weeks 11-13
**Prerequisites:** Phase 2 completed (chat working, messaging system in place)

---

## 📸 Photo Upload & Storage

### Backend Photo Management

- [x] Install image processing libraries
  - `npm install sharp` (for image compression)
  - `npm install @aws-sdk/client-s3` (for S3 uploads)
  - `npm install @aws-sdk/s3-request-presigner` (for presigned URLs)

- [x] Create photo upload utility
  - Function `uploadToS3(file, userId)` ✓
  - Generate unique S3 key: `${userId}/${timestamp}-${filename}` ✓
  - Compress images with Sharp before upload (max 1920px width) ✓
  - Upload file to S3 bucket using AWS SDK ✓
  - Set appropriate Content-Type and ACL ✓
  - Return S3 key and generate presigned URL (24-hour expiry) ✓

- [x] Create `POST /photos/upload` endpoint
  - Authenticate with JWT middleware ✓
  - Accept single or multiple files (max 3 per request) ✓
  - Validate file types: JPEG, PNG, HEIC ✓
  - Validate file size: max 10MB per file ✓
  - Compress images on server if needed ✓
  - Upload to S3 via uploadToS3 utility ✓
  - Create Photo record in database for each uploaded file ✓
  - Check free user photo limit (100 photos max) ✓
  - Return array of uploaded photo objects (id, url, s3Key) ✓

- [x] Create `GET /photos/list` endpoint
  - Authenticate user with JWT middleware ✓
  - Support pagination (limit, offset query params) ✓
  - Support filtering by milestoneId, albumId (optional filters) ✓
  - Order by uploadedAt descending ✓
  - Generate presigned URLs for each photo (24-hour expiry) ✓
  - Return array of photos with metadata ✓

- [x] Create `DELETE /photos/:id` endpoint
  - Authenticate user ✓
  - Verify photo belongs to user ✓
  - Delete photo from S3 bucket ✓
  - Delete Photo record from database ✓
  - Return success message ✓

- [x] Create `POST /photos/analyze` endpoint
  - Authenticate user ✓
  - Accept photo upload (single file) ✓
  - Upload to S3 first (save permanently) ✓
  - Send to OpenAI Vision API (GPT-4o with vision) ✓
  - Include specific prompt for baby-related analysis: ✓
    - Skin rashes/discoloration ✓
    - Diaper contents analysis ✓
    - Safety hazards in environment ✓
    - General visual concerns ✓
  - Parse AI analysis results ✓
  - Save analysis to Photo.analysisResults JSON field ✓
  - Show medical disclaimer in response ✓
  - Return analysis text and photo URL ✓

### Frontend Photo Features

- [x] Install image picker library
  - `flutter pub add image_picker` ✓
  - Configure iOS permissions (NSPhotoLibraryUsageDescription, NSCameraUsageDescription in Info.plist) ✓
  - Configure Android permissions (CAMERA, READ_MEDIA_IMAGES in AndroidManifest.xml) ✓
  - Package already installed and permissions configured ✓

- [x] Add attachment button to chat input
  - Paperclip icon next to text input ✓
  - Tap to show action sheet: "Take Photo" / "Choose from Library" / "Cancel" ✓

- [x] Implement photo selection
  - Open camera or photo library via image_picker ✓
  - Allow multi-select in library (max 3 photos) ✓
  - Show thumbnails of selected photos in chat input area (above keyboard) ✓
  - Add "X" button on each thumbnail to remove before sending ✓

- [x] Upload photos with message
  - When user sends message with photos, upload first ✓
  - Call `POST /photos/upload` endpoint ✓
  - Show upload progress indicator for each photo (percentage) ✓
  - After upload completes, send chat message with photoUrls array ✓
  - Display photos inline in chat message bubble (thumbnail grid) ✓

- [x] Install image optimization library
  - `flutter pub add cached_network_image` ✓
  - Use for cached image loading throughout app ✓
  - Displays photos with loading and error states ✓

- [x] Create Photos tab/screen
  - Add to bottom tab navigation ✓
  - Grid layout (3 columns) using GridView ✓
  - Fetch photos on mount via `GET /photos/list` ✓
  - Implement infinite scroll (load more on scroll to bottom) ✓
  - Add pull-to-refresh gesture ✓
  - Show empty state if no photos ✓

- [x] Implement full-screen photo viewer
  - Tap photo thumbnail to open full-screen modal ✓
  - PageView with InteractiveViewer for zoom ✓
  - Swipe left/right to navigate between photos ✓
  - Pinch-to-zoom gesture ✓
  - Show photo details overlay (date, milestone tag if present) ✓
  - "Delete" button (with confirmation alert) ✓

- [x] Add photo analysis feature
  - In full-screen viewer, add "Analyze with AI" button ✓
  - Show medical disclaimer modal before first analysis ✓
  - Call `POST /photos/analyze` with photo ✓
  - Show loading indicator during analysis (can take 3-5 seconds) ✓
  - Display AI analysis results in modal overlay ✓
  - Include disclaimer: "This is not medical advice..." ✓

---

## 🏆 Milestone Tracking

### Backend Milestone API

- [x] Create `GET /milestones` endpoint
  - Authenticate user ✓
  - Fetch all milestones for userId ✓
  - Support filtering by type (query param: ?type=PHYSICAL) ✓
  - Support filtering by confirmed status (?confirmed=true) ✓
  - Order by achievedDate descending ✓
  - Generate presigned URLs for photos in photoUrls array ✓
  - Return array of milestones with photo URLs ✓

- [x] Create `POST /milestones` endpoint
  - Authenticate user ✓
  - Accept milestone data: type, name, achievedDate, notes, photoUrls, confirmed ✓
  - Validate achievedDate not in future ✓
  - Validate type is valid enum value ✓
  - Create Milestone record in database ✓
  - Return created milestone object with generated id ✓

- [x] Create `PUT /milestones/:id` endpoint
  - Authenticate user ✓
  - Verify milestone belongs to user ✓
  - Accept partial updates (name, achievedDate, notes) ✓
  - Update Milestone record ✓
  - Return updated milestone ✓

- [x] Create `DELETE /milestones/:id` endpoint
  - Authenticate user ✓
  - Verify milestone belongs to user ✓
  - Delete Milestone record from database ✓
  - Return success message ✓

- [x] Implement AI milestone suggestion logic
  - Function `suggestMilestones(userProfile): Milestone[]` ✓
  - Calculate baby age from birthDate ✓
  - Return age-appropriate milestones based on age ranges: ✓
    - 0-2 months: First smile, holding head up ✓
    - 3-4 months: Rolling over, laughing ✓
    - 5-7 months: Sitting up, first solid foods ✓
    - 8-10 months: Crawling, pulling to stand ✓
    - 11-14 months: First steps, first words ✓
  - Use predefined milestone templates with aiSuggested: true ✓
  - Don't suggest milestones already logged ✓

- [x] Create `GET /milestones/suggestions` endpoint
  - Authenticate user ✓
  - Fetch user profile (baby birthDate) ✓
  - Call suggestMilestones utility ✓
  - Filter out already-confirmed milestones ✓
  - Return array of suggested milestone objects (not yet saved to DB) ✓

### Frontend Milestone Features

- [ ] Create Milestones tab/screen
  - Add to bottom tab navigation
  - Header with toggle button: "Timeline" / "Categories"
  - Timeline view as default
  - Pull-to-refresh to reload milestones

- [ ] Implement Timeline view
  - Vertical scrollable list with date markers
  - Group milestones by month ("January 2025")
  - Display milestone cards with:
    - Milestone name and type icon
    - Date achieved
    - Thumbnail photo (first photo if multiple)
  - Tap card to open detail view

- [ ] Implement Categories view
  - Horizontal scrolling category tabs (Physical, Feeding, Sleep, Social, Health)
  - Tap category to filter milestones
  - Show filtered list below in same card format
  - "All" category to show everything

- [ ] Create Milestone detail screen
  - Full-screen view
  - Show milestone name, type, date
  - Display notes section if present
  - Show all photos in horizontal scrollable carousel
  - "Edit" button in header (navigates to edit form)
  - "Delete" button in header (shows confirmation alert)

- [ ] Create Add Milestone screen
  - Form with fields:
    - Text input: Milestone name
    - Dropdown/Picker: Milestone type (5 options)
    - Date picker: Achieved date (defaults to today)
    - Text area: Notes (optional, multiline)
    - Photo picker: Add photos (show thumbnails, allow multiple)
  - "Save" button in header (validates and submits)
  - "Cancel" button to go back

- [ ] Create Edit Milestone screen
  - Same form as Add Milestone
  - Pre-populate with existing milestone data
  - "Save Changes" button calls PUT endpoint
  - Show loading state during save

- [ ] Integrate AI milestone suggestions in chat
  - When fetching chat context, check for milestone suggestions
  - Periodically (weekly), inject AI message asking about age-appropriate milestones
  - Example: "Has Emma started rolling over yet? This usually happens around 4-6 months!"
  - Show inline buttons in chat: "Yes!" / "Not Yet"
  - If "Yes!", navigate to Add Milestone screen with pre-filled name and date
  - Show celebration animation (confetti) on successful save
  - If "Not Yet", send reassuring message and note to prompt again in 2 weeks

- [ ] Create milestone prompt system
  - Fetch suggestions from `GET /milestones/suggestions` on app launch
  - Store in local state
  - Display as AI chat message at appropriate times
  - User can confirm (creates milestone) or dismiss

- [ ] Implement milestone export feature
  - "Export to PDF" button in Milestones screen header (gear icon menu)
  - Generate PDF report with milestone timeline and photos
  - Use library like `react-native-html-to-pdf` or `react-native-pdf`
  - Format: chronological list with photos, dates, and notes
  - Share via native share sheet (email, messages, etc.)

---

**Progress:** 🟩 20/29 tasks completed (69% - Backend complete! All Photo & Milestone APIs done!)

**Previous Phase:** [Phase 2: Chat & Voice](todo-phase-2-chat-voice.md)
**Next Phase:** [Phase 4: Monetization](todo-phase-4-monetization.md)
