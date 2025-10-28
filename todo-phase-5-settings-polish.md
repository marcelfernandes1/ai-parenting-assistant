# Phase 5: Settings, UI Polish & Testing

**Focus:** User settings, profile management, design system, accessibility, performance optimization, QA
**Timeline:** Weeks 16-18
**Prerequisites:** Phase 4 completed (all core features built)

---

## ⚙️ Settings & User Profile

### Backend Settings API

- [ ] Create `PUT /user/email` endpoint
  - Authenticate user
  - Accept newEmail and password (for verification)
  - Verify current password is correct
  - Check if newEmail already in use
  - Update email in User table
  - Send verification email to new address (optional for MVP)
  - Return success message

- [ ] Create `PUT /user/password` endpoint
  - Authenticate user
  - Accept currentPassword, newPassword, confirmPassword
  - Verify currentPassword is correct
  - Validate newPassword strength (min 8 chars, 1 number)
  - Hash newPassword with bcrypt
  - Update passwordHash in User table
  - Return success message

- [ ] Update `PUT /user/profile` endpoint (if needed)
  - Ensure it accepts all profile field updates
  - Validate input data (dates, enum values)
  - Update UserProfile record
  - Return updated profile

- [ ] Create `POST /user/toggle-mode` endpoint (if not already created)
  - Authenticate user
  - Verify current mode is PREGNANCY
  - Accept baby details: babyName, babyGender, babyBirthDate
  - Update mode to PARENTING in UserProfile
  - Save baby details
  - Add toggledAt timestamp (make mode change irreversible)
  - Return success message

- [ ] Create `DELETE /user/account` endpoint
  - Authenticate user
  - Show warning that this is irreversible
  - Delete all related data in transaction:
    - All messages (Message table)
    - All milestones (Milestone table)
    - All photos from S3 bucket
    - All photo records (Photo table)
    - UsageTracking records
    - UserProfile record
    - User record
  - Cancel Stripe subscription if active
  - Return success message

- [ ] Create `GET /user/data-export` endpoint
  - Authenticate user
  - Compile all user data into JSON:
    - User profile
    - All messages
    - All milestones
    - Photos metadata (with presigned URLs, 7-day expiry)
  - Return JSON file for download
  - GDPR compliance requirement

### Frontend Settings Screens

- [ ] Create Settings tab/screen
  - Add to bottom tab navigation
  - Grouped list style layout (iOS style)
  - Sections:
    - Account (email, password, delete account)
    - Profile & Personalization (edit profile, mode toggle)
    - Notifications (toggle preferences)
    - Privacy & Data (clear history, export data)
    - Subscription (manage, upgrade)
    - About & Help (version, TOS, privacy policy, support)

- [ ] Implement Account Settings section
  - "Change Email" row → navigates to form screen
  - "Change Password" row → navigates to form screen
  - "Delete Account" row → shows confirmation alert with strong warning

- [ ] Create Change Email screen
  - Text input: New email (keyboard type: email-address)
  - Text input: Current password (for verification)
  - "Save Changes" button
  - Show loading state during API call
  - Show success toast or error message
  - Navigate back on success

- [ ] Create Change Password screen
  - Text input: Current password (secureTextEntry)
  - Text input: New password (with strength indicator)
  - Text input: Confirm new password
  - "Save Changes" button
  - Validate passwords match on frontend
  - Show loading state during API call
  - Show success toast or error message

- [ ] Implement Profile & Personalization section
  - "Edit Profile" row → navigates to form
  - "Baby Information" row → edit baby name, gender, birthDate
  - "Mode Toggle" row (only visible if mode = PREGNANCY)
  - Display current mode badge

- [ ] Create Edit Profile screen
  - Recreate all onboarding quiz fields as editable form
  - Pre-populate with current values from UserProfile
  - Same fields: parenting philosophy, religious views, cultural background, concerns
  - "Save Changes" button
  - Call `PUT /user/profile` endpoint

- [ ] Implement mode toggle flow
  - "Switch to Parenting Mode" button
  - Show confirmation modal with congratulations message
  - Prompt for baby details (name, gender, birthDate) in modal form
  - "Confirm" button calls `POST /user/toggle-mode`
  - Update local AuthContext state
  - Refresh entire app UI to reflect parenting mode

- [ ] Implement Notifications section
  - Toggle switches for each notification type:
    - Daily milestone updates (default: ON)
    - Weekly tips and guidance (default: ON)
    - Reminder to log milestones (default: ON)
  - "Quiet hours" row → opens time picker modal
  - Save preferences to backend on toggle change
  - Update UserProfile.notificationPreferences JSON field

- [ ] Implement Privacy & Data section
  - "Data Usage Consent" row → shows policy in modal
  - "Clear Chat History" button
    - Show confirmation alert: "This will delete all your conversations. Continue?"
    - Call `DELETE /chat/session` or create new endpoint to clear all sessions
  - "Export My Data" button
    - Call `GET /user/data-export`
    - Show loading indicator
    - Download JSON file or share via native share sheet
  - "Facial Recognition" toggle (for future photo organization feature)

- [ ] Implement App Preferences section
  - "Dark Mode" toggle
    - Use React Native Appearance API
    - Store preference in AsyncStorage
    - Apply theme throughout app
  - "Text Size" row → shows slider (Small, Medium, Large)
    - Store preference in AsyncStorage
    - Apply scaled fonts throughout app
  - "Language" row → shows "English" (disabled for MVP with note: "More languages coming soon")

- [ ] Create About & Help section
  - "App Version" row → displays current version (from package.json)
  - "Terms of Service" row → opens web view or browser
  - "Privacy Policy" row → opens web view or browser
  - "Contact Support" row → opens email client or in-app support chat
  - "About AI" row → opens explanation screen about AI features and limitations

---

## 🎨 UI/UX Polish

### Design System

- [ ] Define color palette
  - Create `theme.ts` file
  - Define colors:
    - Primary color (brand blue, e.g., #4A90E2)
    - Secondary color (accent, e.g., #F5A623)
    - Background colors (light: #FFFFFF, dark: #1A1A1A)
    - Text colors (primary: #333333, secondary: #666666, disabled: #CCCCCC)
    - Status colors (error: #E74C3C, success: #2ECC71, warning: #F39C12)
  - Export as constants

- [ ] Define typography scale
  - Font family (system defaults: SF Pro for iOS, Roboto for Android)
  - Font sizes:
    - heading1: 28px
    - heading2: 22px
    - heading3: 18px
    - body: 16px
    - caption: 14px
    - small: 12px
  - Font weights: 300 (light), 400 (regular), 500 (medium), 700 (bold)
  - Line heights: 1.5 for body text, 1.3 for headings

- [ ] Create reusable UI components library
  - Button component (primary, secondary, text variants)
  - Input component (text, email, password types with built-in validation display)
  - Card component (for milestones, photos with consistent padding/shadows)
  - Badge component (for usage counter, status indicators)
  - Modal component (for paywall, alerts with consistent styling)

---

## ♿ Accessibility

- [ ] Add accessibility labels to all interactive elements
  - Use `accessibilityLabel` prop on buttons, inputs, images
  - Use `accessibilityHint` for complex interactions
  - Use `accessibilityRole` to indicate element types (button, link, image, etc.)

- [ ] Test with VoiceOver (iOS)
  - Enable VoiceOver in iOS Simulator (Cmd+F5)
  - Navigate through all screens
  - Verify all elements are readable and in logical order
  - Fix any navigation issues or missing labels

- [ ] Test with TalkBack (Android)
  - Enable TalkBack on Android device/emulator
  - Navigate through all screens
  - Verify all elements are readable
  - Fix any navigation issues

- [ ] Implement Dynamic Type support
  - Use scaled font sizes based on system accessibility settings
  - Test with largest text sizes
  - Ensure layouts don't break or clip text

- [ ] Ensure color contrast ratios
  - Test all text/background combinations
  - Minimum 4.5:1 ratio for normal text
  - Minimum 3:1 for large text (18px+)
  - Use online contrast checker tool (WebAIM)

- [ ] Add "Reduce Motion" support
  - Detect system preference: `AccessibilityInfo.isReduceMotionEnabled()`
  - Disable or simplify animations when enabled
  - Ensure app is fully functional without animations

- [ ] Add proper focus management
  - Ensure keyboard navigation works (important for Android)
  - Focus moves logically through form fields
  - Focus is visible (outline or highlight)

---

## ✨ Animations & Transitions

- [ ] Add screen transition animations
  - Use React Navigation default transitions
  - Customize if needed for brand feel (e.g., fade vs slide)

- [ ] Add button press feedback
  - Use `Pressable` component with opacity change (0.6 on press)
  - Or add subtle scale animation (0.95 on press)

- [ ] Add loading skeletons
  - Install `react-native-shimmer-placeholder` or create custom
  - Show skeleton placeholders while loading:
    - Chat messages (gray boxes pulsing)
    - Photos grid (gray squares)
    - Milestones list
  - Improves perceived performance

- [ ] Add micro-interactions
  - Confetti animation on milestone confirmation (use react-native-confetti-cannon)
  - Pulsing animation for voice mode (scale and opacity)
  - Smooth scroll animations (Animated API)
  - Checkmark animation on successful save

---

## 🔧 Error Handling & Empty States

- [ ] Create error boundary component
  - Catch JavaScript errors in component tree
  - Show friendly error screen: "Oops! Something went wrong"
  - "Retry" button to reset error boundary
  - "Report Issue" button (optional)
  - Log errors to Sentry automatically

- [ ] Design empty state screens
  - Chat: Friendly message + illustration: "Start your first conversation! Ask me anything about parenting."
  - Milestones: "Your milestone journey starts here! I'll help you track your baby's special moments."
  - Photos: "Add your first photo to start building memories!"
  - Include illustrations (use free illustrations from unDraw or similar)

- [ ] Implement retry mechanisms
  - Add "Retry" button on failed API calls
  - Auto-retry with exponential backoff for transient errors (500, 503)
  - Show clear error messages: "Couldn't connect. Please check your internet."
  - Don't retry on 4xx errors (client errors)

---

## ⚡ Performance Optimization

- [ ] Optimize image loading
  - Use `react-native-fast-image` throughout app (replaces Image component)
  - Enables automatic caching
  - Preload critical images
  - Lazy load images in photo grid (only render visible items)

- [ ] Optimize FlatList rendering
  - Use `getItemLayout` for fixed-height items (massive performance boost)
  - Use `removeClippedSubviews={true}` prop
  - Use `maxToRenderPerBatch={10}` to limit initial render
  - Use `windowSize={10}` to control render window

- [ ] Implement code splitting (if bundle size > 40MB)
  - Use React.lazy() for heavy screens that aren't immediately needed
  - Split by feature (settings screens, photo viewer)
  - Show loading indicator while lazy component loads

- [ ] Profile app with React Native Debugger
  - Check for unnecessary re-renders (use React DevTools Profiler)
  - Memoize expensive components with React.memo()
  - Use useMemo() for expensive calculations
  - Use useCallback() for event handlers passed to child components

- [ ] Optimize app startup time
  - Minimize work in app root component
  - Defer non-critical initializations
  - Use InteractionManager.runAfterInteractions() for heavy tasks
  - Target <2 seconds from tap to interactive

---

## 🧪 Testing & QA

### Backend Testing

- [ ] Write unit tests for authentication
  - Test password hashing (bcrypt)
  - Test JWT generation and verification
  - Test rate limiting logic
  - Use Jest framework

- [ ] Write unit tests for chat service
  - Mock OpenAI API responses
  - Test prompt generation logic
  - Test context inclusion (last 10 messages)

- [ ] Write integration tests for API endpoints
  - Use Supertest library for HTTP testing
  - Test authentication middleware on protected routes
  - Test successful cases and error cases
  - Test rate limiting behavior

- [ ] Write tests for Stripe webhook handling
  - Mock Stripe webhook events
  - Verify subscription status updates correctly
  - Test signature verification

### Frontend Testing

- [ ] Write unit tests for utility functions
  - Date formatting helpers
  - Validation functions (email, password)
  - Token storage helpers

- [ ] Write component tests for UI components
  - Use React Native Testing Library
  - Test Button, Input, Card components render correctly
  - Test user interactions (press, type, toggle)

- [ ] Write integration tests for key flows
  - Test login flow (input credentials → success → navigate)
  - Test onboarding flow (all steps → submit → home)
  - Test sending message flow (type → send → response appears)

- [ ] Set up E2E testing with Detox (optional for MVP)
  - Configure Detox for iOS and Android
  - Write smoke test for critical user journey
  - Run E2E tests in CI pipeline

### Manual QA Checklist

- [ ] Test on multiple iOS devices
  - iPhone 8 (4.7", smallest supported)
  - iPhone 14 Pro (6.1", notch)
  - iPad (10", tablet layout)

- [ ] Test on multiple Android devices
  - Low-end device (Android 7.0, 2GB RAM)
  - Samsung Galaxy (One UI skin)
  - Google Pixel (stock Android)

- [ ] Test all user flows end-to-end
  - Complete journey: Registration → Onboarding → First message → Photo upload → Milestone log → Upgrade
  - Verify no crashes or blocking errors

- [ ] Test edge cases
  - Poor network conditions (use Network Link Conditioner or throttling)
  - App backgrounding during voice session
  - Rapid button presses (test debouncing)
  - Very long messages (2000+ characters)
  - Special characters in inputs (emojis, accents, symbols)
  - Limit edge cases (exactly 10 messages, 10 minutes)

- [ ] Test accessibility features
  - VoiceOver/TalkBack complete navigation
  - Large text sizes (all screens readable)
  - Color blindness modes (deuteranopia, protanopia)

---

**Progress:** ⬜ 0/58 tasks completed

**Previous Phase:** [Phase 4: Monetization](todo-phase-4-monetization.md)
**Next Phase:** [Phase 6: Deployment](todo-phase-6-deployment.md)
