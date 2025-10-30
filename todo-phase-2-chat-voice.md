# Phase 2: Chat Interface & Voice Features

**Focus:** Basic chat, OpenAI integration, Whisper transcription, real-time voice conversation
**Timeline:** Weeks 7-10
**Prerequisites:** Phase 1 completed (auth working, database set up)

---

## 💬 Chat Interface - Basic

### Backend Chat API

- [x] Install OpenAI SDK
  - `npm install openai`
  - Configure API key in .env file
  - Create OpenAI client instance in `services/openai.ts`

- [x] Create chat service utility
  - Function `generateChatResponse(messages, userProfile)`
  - Build system prompt from user profile data
  - Include last 10 messages for context
  - Call OpenAI GPT-4 Turbo API
  - Return assistant response and token count

- [x] Create `POST /chat/message` endpoint
  - Authenticate with JWT middleware
  - Validate message content (not empty, max 2000 chars)
  - Check daily usage limit for user (query UsageTracking)
  - Return 429 error if limit exceeded
  - Fetch last 10 messages for context
  - Call chat service to generate response
  - Save both user message and assistant response to Message table
  - Update UsageTracking messagesUsed count
  - Return assistant response

- [x] Create `GET /chat/history` endpoint
  - Authenticate with JWT middleware
  - Paginate messages (limit: 50, offset: query param)
  - Filter by userId from token
  - Order by timestamp descending
  - Return array of messages

- [x] Create `DELETE /chat/session` endpoint
  - Authenticate with JWT middleware
  - Delete all messages for user's current sessionId
  - Generate new sessionId for next conversation
  - Return success message

- [x] Create `GET /usage/today` endpoint
  - Authenticate with JWT middleware
  - Query UsageTracking for today's date
  - Return messagesUsed, voiceMinutesUsed, photosStored
  - If no record exists, return zeros

### Frontend Chat UI

- [x] Create Chat screen layout
  - Header: Display baby name and age (or pregnancy week)
  - Message list: ListView for scrollable chat history
  - Input area: TextField with send button
  - Footer: Medical disclaimer text (small, gray)

- [x] Create Message component
  - User messages: right-aligned, blue background
  - Assistant messages: left-aligned, gray background
  - Show timestamp (formatted with intl)
  - Word-wrap long messages
  - Different styling for loading state

- [x] Implement send message functionality
  - Disable input while message is sending
  - Clear input field immediately (optimistic UI)
  - Call `POST /chat/message` API via provider
  - Add assistant response to message list
  - Scroll to bottom after new message
  - Handle errors (show error banner)

- [x] Implement chat history loading
  - Fetch messages on screen mount via provider
  - Call `GET /chat/history` API
  - Display in ListView (chronological order)
  - Add pull-to-refresh gesture
  - Add loading indicator

- [x] Add typing indicator
  - Show animated dots while waiting for response
  - Use TypingIndicator widget with staggered animation
  - Display below last message

- [x] Add "New Conversation" button
  - Header right button with confirmation dialog
  - Call `DELETE /chat/session` API via provider
  - Clear local message state
  - Generate new sessionId in provider

- [x] Display usage counter
  - Fetch current usage from backend via usageProvider
  - Call `GET /usage/today` endpoint
  - Show badge in header: "7/10 today"
  - Updates automatically when watching provider

---

## 🎙️ Voice Input - Whisper Transcription

### Backend Voice Transcription

- [x] Install Multer for file uploads
  - `npm install multer`
  - `npm install @types/multer --save-dev`

- [x] Create `POST /chat/voice` endpoint
  - Authenticate with JWT middleware
  - Accept audio file upload (multipart/form-data)
  - Use Multer middleware for file handling
  - Validate file type (audio/m4a, audio/wav, audio/mpeg)
  - Max file size: 25MB (Whisper API limit)
  - Check daily voice usage limit (message count, NOT minutes for Whisper)

- [x] Implement Whisper API integration
  - Call OpenAI Whisper API with audio file
  - Use `whisper-1` model
  - Set language to 'en' for better accuracy
  - Return transcribed text

- [x] Process transcribed message
  - After successful transcription, treat as regular text message
  - Call chat service to generate AI response
  - Save user message with contentType: VOICE
  - Store audio file URL in mediaUrls if needed (optional)
  - Update UsageTracking messagesUsed count
  - Return transcription and assistant response

### Frontend Voice Recording

- [x] Install audio recording library
  - Installed `record: ^5.1.2` package (modern alternative to flutter_sound)
  - Native dependencies link automatically with Flutter
  - Microphone permissions already configured in Info.plist and AndroidManifest.xml

- [x] Create voice recording provider
  - Created `VoiceRecorderNotifier` using Riverpod StateNotifier
  - State: RecordingState (idle, recording, stopped, error), filePath, duration, errorMessage
  - Methods: startRecording(), stopRecording(), cancelRecording(), checkPermission()
  - Uses `record` package for audio recording with m4a format
  - Auto-stops recording after 2 minutes
  - Automatic duration timer updates every second

- [x] Add microphone button to chat input
  - Icon button next to text input (switches with send button based on text)
  - Press and hold to record, release to send (GestureDetector)
  - Visual feedback: button changes color to red during recording
  - Show recording duration timer in dedicated indicator bar

- [x] Implement voice recording UI
  - Recording indicator bar with red background when recording
  - Display recording time in mm:ss format (e.g., 01:23)
  - Max recording length: 2 minutes (auto-stop in provider)
  - Cancel button in recording indicator bar

- [x] Upload and transcribe audio
  - After recording stops, shows loading state via chatState.isSendingMessage
  - Uploads audio file to `POST /chat/voice` endpoint via uploadFile
  - Uses FormData for multipart upload (handled by api_client)
  - Displays transcribed text in chat (VOICE content type)
  - Shows AI typing indicator during response generation
  - Adds assistant response to chat automatically

- [x] Handle voice errors
  - Shows error snackbar if recording fails to start (permission denied)
  - Shows error snackbar if recording file not found
  - Error handling in chat provider for failed uploads/transcriptions
  - Permission check before starting recording

---

## 🗣️ Advanced Voice Conversation Mode

### Backend Real-Time Voice

- [x] Install Socket.io for WebSocket
  - Backend: `npm install socket.io` ✓
  - Frontend: `flutter pub add socket_io_client` (upgraded to 3.1.2) ✓

- [x] Create Socket.io server
  - Initialize Socket.io in Express app (index.ts) ✓
  - Add authentication middleware for socket connections (verify JWT) ✓
  - Create namespace `/voice` for voice conversations (sockets/voice.ts) ✓

- [x] Create voice session start handler (via WebSocket `start_session` event)
  - Authenticate user ✓
  - Generate unique voiceSessionId ✓
  - Initialize voice conversation context ✓
  - Check daily voice minutes remaining ✓
  - Return voiceSessionId and remaining minutes to client ✓

- [x] Implement WebSocket voice handler
  - Listen for `audio_chunk` events from client ✓
  - Buffer audio chunks until client signals completion ✓
  - Send complete audio to Whisper API for transcription ✓
  - Generate AI response with GPT-4 ✓
  - Emit `transcription` and `ai_response` events to client ✓
  - Track elapsed time for billing ✓
  - Save messages to database ✓
  - Note: TTS conversion to be added in future iteration

- [x] Create voice session end handler (via WebSocket `end_session` event)
  - Close WebSocket connection ✓
  - Calculate total voice minutes used ✓
  - Update UsageTracking voiceMinutesUsed ✓
  - Messages already saved during conversation ✓
  - Return session summary (duration, voiceSessionId) ✓

### Frontend Voice Conversation UI

- [ ] Create VoiceMode screen
  - Full-screen modal overlay
  - Large pulsing animation in center (indicates AI listening/speaking)
  - Display live transcription text below animation
  - "End Conversation" button at bottom
  - Show elapsed time timer and remaining minutes

- [ ] Implement WebSocket connection
  - Connect to Socket.io server on session start
  - Pass JWT token for authentication
  - Listen for `transcription` and `audio_response` events
  - Handle reconnection on network issues
  - Close connection on screen exit

- [ ] Implement audio streaming
  - Record audio in chunks (streaming mode)
  - Send chunks to server via WebSocket emit
  - Detect silence for turn-taking (voice activity detection - optional)
  - Handle interruptions (user speaks while AI is talking)

- [ ] Play AI audio responses
  - Install `react-native-sound` or use expo-av for audio playback
  - Receive audio data from WebSocket
  - Play audio through speaker
  - Show visual feedback (pulsing animation) during playback

- [ ] Add voice mode button to chat screen
  - Distinct icon (different from microphone button)
  - Tap to check remaining minutes first
  - If minutes available, navigate to VoiceMode screen
  - If limit reached, show paywall

- [ ] Track voice session time
  - Start timer when session begins
  - Update every second
  - Show remaining minutes: "8 min remaining"
  - Show 1-minute warning when approaching limit
  - Auto-end session when limit reached

---

## 🎬 Quick Action Buttons

- [ ] Create quick action button component
  - Rounded button with icon and text
  - Tap triggers pre-filled message
  - Automatically sends to chat

- [ ] Add quick actions to chat screen
  - Display below header, above message list
  - Horizontal scrollable row (3-4 buttons visible)
  - Load buttons based on user mode and baby age

- [ ] Create quick action configuration
  - Define button sets for different stages:
    - Pregnancy mode
    - Parenting 0-3 months
    - Parenting 3-12 months
  - Store in constants file or fetch from backend

- [ ] Implement button tap behavior
  - Populate chat input with button text
  - Auto-send message to AI
  - Show loading state
  - Display AI response

- [ ] Add age-based button updates
  - Calculate baby age from birthDate
  - Update button set when age thresholds crossed
  - Smoothly transition buttons (fade animation)

---

**Progress:** ✅ 29/40 tasks completed (73%)

**Previous Phase:** [Phase 1: Database & Auth](todo-phase-1-database-auth.md)
**Next Phase:** [Phase 3: Photos & Milestones](todo-phase-3-photos-milestones.md)
