# Manual QA Checklist

This checklist should be used before each release to ensure comprehensive testing across all platforms and scenarios.

---

## 1. Device Testing Matrix

Test the app on the following devices and configurations:

### iOS
- [ ] iPhone SE (3rd gen) - iOS 17+ (Small screen: 4.7")
- [ ] iPhone 14 Pro - iOS 17+ (Medium screen: 6.1")
- [ ] iPhone 15 Pro Max - iOS 17+ (Large screen: 6.7")
- [ ] iPad Air (5th gen) - iPadOS 17+ (Tablet: 10.9")
- [ ] iPad Pro 12.9" - iPadOS 17+ (Large tablet)

### Android
- [ ] Pixel 6 - Android 13+ (Small-medium: 6.4")
- [ ] Samsung Galaxy S23 - Android 13+ (Medium: 6.1")
- [ ] Samsung Galaxy S23 Ultra - Android 13+ (Large: 6.8")
- [ ] Google Pixel Tablet - Android 13+ (Tablet: 10.95")
- [ ] OnePlus or similar budget device - Android 12+ (Budget hardware)

### Network Conditions
- [ ] Strong Wi-Fi (high speed)
- [ ] Weak Wi-Fi (simulated 2G speeds)
- [ ] Cellular data (4G/5G)
- [ ] Airplane mode → reconnect scenarios
- [ ] Intermittent connectivity (toggle on/off during operations)

---

## 2. User Flow Testing

Test complete end-to-end user journeys:

### Onboarding & Authentication
- [ ] New user registration with email/password
- [ ] Login with existing credentials
- [ ] Password reset flow (email → reset link → new password)
- [ ] Profile setup: parent mode, baby details, preferences
- [ ] Onboarding screens: swipe through, skip, complete
- [ ] Logout and login again (session persistence)
- [ ] Token refresh on app reopen after 24+ hours
- [ ] Session expiration handling (graceful re-auth)

### Chat Functionality
- [ ] Send text message → receive AI response
- [ ] Send multiple messages in quick succession
- [ ] Upload photo in chat → AI analyzes photo
- [ ] Long conversation (20+ messages) maintains context
- [ ] Chat history loads correctly on reopen
- [ ] Delete individual message
- [ ] Clear entire chat history
- [ ] Usage limit reached → paywall modal shown
- [ ] Premium user: unlimited messaging works

### Voice Messaging
- [ ] Record voice message (5 seconds)
- [ ] Record voice message (60+ seconds)
- [ ] Cancel recording mid-way
- [ ] Send voice → transcription displays
- [ ] Background noise handling (test in noisy environment)
- [ ] Microphone permission: deny → prompt, allow → record
- [ ] Voice recording during phone call (should fail gracefully)
- [ ] Usage limit reached for free tier
- [ ] Premium user: unlimited voice works

### Photo Features
- [ ] Take photo with camera → upload
- [ ] Select photo from gallery → upload
- [ ] Upload multiple photos in sequence
- [ ] Large photo (10+ MB) compression works
- [ ] Photo thumbnail loads in chat
- [ ] Full-size photo view (tap thumbnail)
- [ ] Delete photo from gallery
- [ ] Camera/photo library permission flow
- [ ] Usage limit for free tier (100 photos)

### Profile & Settings
- [ ] Update user profile (name, email)
- [ ] Change password (old password → new password)
- [ ] Update baby details (name, birthdate, milestones)
- [ ] Switch between pregnancy and parent mode
- [ ] Update preferences (parenting philosophy, religion)
- [ ] Enable/disable notifications
- [ ] Change app language (if i18n implemented)
- [ ] View subscription status (Free/Premium)
- [ ] View usage statistics (messages, voice minutes, photos)

### Subscription & Payments
- [ ] View premium features modal
- [ ] Start premium subscription flow (iOS in-app purchase)
- [ ] Start premium subscription flow (Android in-app purchase)
- [ ] Successful payment → immediate access to premium features
- [ ] Failed payment → error message, retry option
- [ ] Restore purchases (reinstall app → restore premium)
- [ ] Cancel subscription (billing remains active until period ends)
- [ ] Subscription renewal notification
- [ ] Subscription expiration → downgrade to free tier

---

## 3. Edge Case Testing

Test unusual scenarios and error conditions:

### Network & Connectivity
- [ ] Start chat → lose network mid-message → reconnect
- [ ] Upload photo → lose network → retry mechanism
- [ ] Voice recording → lose network → save locally, retry
- [ ] API timeout (backend slow) → loading spinner → error message
- [ ] 500 server error → retry button works
- [ ] 401 unauthorized → auto-refresh token → retry request

### App Lifecycle
- [ ] Send message → minimize app → reopen → message sent
- [ ] Voice recording → phone call interrupts → recording saved/cancelled
- [ ] Photo upload → app crashes → retry on reopen
- [ ] Long background (12+ hours) → reopen → session still valid
- [ ] iOS: app killed by system → reopen → state restored
- [ ] Android: app killed by system → reopen → state restored

### Input Validation
- [ ] Empty message (shouldn't send)
- [ ] Very long message (1000+ characters) → sends successfully
- [ ] Special characters in message (emoji, symbols, non-Latin)
- [ ] Paste large text (5000+ chars) → UI handles gracefully
- [ ] Invalid email format in login/registration
- [ ] Weak password (too short, no special chars) → validation error
- [ ] Future birthdate for baby → validation error
- [ ] Very old birthdate (50+ years ago) → validation error

### UI & Interaction
- [ ] Rapid button tapping (double-tap send) → single request
- [ ] Swipe back gesture mid-request (iOS) → cancels request
- [ ] Rotate device → layout adjusts correctly
- [ ] Split screen mode (iPad/Android) → UI responsive
- [ ] Picture-in-picture video (if video features exist)
- [ ] Deep link from notification → navigates correctly
- [ ] Deep link from email → opens app, navigates

### Data Integrity
- [ ] Clear app cache → chat history persists (server-backed)
- [ ] Uninstall → reinstall → login → data restored
- [ ] Concurrent sessions (phone + tablet) → data syncs
- [ ] Edit profile on device A → reflects on device B
- [ ] Delete message on device A → deleted on device B
- [ ] Subscription purchased on device A → active on device B

---

## 4. Accessibility Testing

Test with assistive technologies and accessibility settings:

### Screen Reader Testing
- [ ] iOS VoiceOver: navigate entire app using gestures
- [ ] iOS VoiceOver: send message, hear AI response read aloud
- [ ] iOS VoiceOver: all buttons have descriptive labels
- [ ] iOS VoiceOver: form inputs have clear hints
- [ ] Android TalkBack: navigate entire app
- [ ] Android TalkBack: interactive elements focusable
- [ ] Android TalkBack: meaningful content descriptions

### Dynamic Type (Text Scaling)
- [ ] iOS: Settings → Accessibility → Larger Text → test largest size
- [ ] Android: Settings → Display → Font size → test largest size
- [ ] All text scales properly (no truncation or overflow)
- [ ] Buttons remain tappable with large text
- [ ] Chat bubbles expand correctly with scaled text
- [ ] Navigation bar items remain readable

### Reduce Motion
- [ ] iOS: Settings → Accessibility → Motion → Reduce Motion ON
- [ ] Android: Settings → Accessibility → Remove animations ON
- [ ] Animations disabled or simplified
- [ ] App remains functional without animations
- [ ] Confetti animations disabled
- [ ] Page transitions simplified

### Color & Contrast
- [ ] Test in bright sunlight (outdoor readability)
- [ ] Dark mode: all text readable (WCAG AA 4.5:1 contrast)
- [ ] Light mode: all text readable
- [ ] Color blindness simulation (Deuteranopia, Protanopia)
- [ ] Interactive elements visually distinct without color alone
- [ ] Error messages have icons, not just red text

### Keyboard & Input
- [ ] External keyboard (iPad/Android tablet): tab navigation works
- [ ] Return key sends message in chat
- [ ] Tab key moves between form fields
- [ ] All interactive elements reachable via keyboard

---

## 5. Performance Testing

Measure and verify performance benchmarks:

### App Launch Time
- [ ] Cold start (app not in memory): < 3 seconds to home screen
- [ ] Warm start (app in background): < 1 second
- [ ] iOS: Time to Interactive (TTI) < 2 seconds
- [ ] Android: Time to Interactive (TTI) < 2.5 seconds

### UI Responsiveness
- [ ] Chat list scrolling: 60 FPS (no jank)
- [ ] Scroll through 100+ messages: smooth performance
- [ ] Image gallery scrolling: 60 FPS
- [ ] Profile screen with photos: smooth rendering
- [ ] No dropped frames during animations
- [ ] Button taps respond within 100ms (perceived instantly)

### Memory Usage
- [ ] iOS: Memory < 200 MB in normal usage
- [ ] Android: Memory < 250 MB in normal usage
- [ ] No memory leaks after 30 minutes usage
- [ ] Large photo upload: memory spike < 300 MB
- [ ] Background mode: memory usage drops (resources released)

### Network Performance
- [ ] API requests complete in < 2 seconds (good network)
- [ ] Image upload (5 MB): < 5 seconds (good network)
- [ ] Retry mechanism for failed requests works
- [ ] Exponential backoff prevents request spam
- [ ] Offline mode: graceful error messages

### Battery Usage
- [ ] 1 hour usage: < 10% battery drain (normal usage)
- [ ] Voice recording: < 5% battery per 10 minutes
- [ ] Background idle: < 1% drain per hour
- [ ] No abnormal CPU usage (check with Xcode/Android Profiler)

### Data Usage
- [ ] Track data usage during 1 hour session
- [ ] Chat messaging: < 10 MB per hour
- [ ] Voice recording: < 20 MB per hour (including transcription)
- [ ] Photo uploads: reasonable compression (5 MB → 500 KB)
- [ ] Image caching prevents re-downloads

---

## 6. Security Testing

Verify security best practices:

### Authentication & Authorization
- [ ] JWT tokens stored in encrypted keychain (iOS) / KeyStore (Android)
- [ ] Tokens not logged in console (production builds)
- [ ] Session expires after 7 days (access token) / 30 days (refresh)
- [ ] Logout clears all stored tokens
- [ ] API rejects expired tokens (401 response)
- [ ] Token refresh works automatically on 401

### Data Protection
- [ ] Sensitive data encrypted at rest (flutter_secure_storage)
- [ ] HTTPS used for all API requests (no HTTP)
- [ ] Certificate pinning (if implemented)
- [ ] API keys not hardcoded in source (use .env)
- [ ] No sensitive data in logs (production builds)
- [ ] No sensitive data in crash reports

### Input Validation
- [ ] SQL injection attempts fail (Prisma parameterized queries)
- [ ] XSS attempts sanitized (OpenAI API handles this)
- [ ] File upload type validation (only images allowed)
- [ ] File size limits enforced (backend rejects > 10 MB)
- [ ] Rate limiting prevents abuse (backend throttling)

---

## 7. Integration Testing

Test third-party service integrations:

### OpenAI API
- [ ] Chat message → GPT response received
- [ ] System prompt includes user profile context
- [ ] Last 10 messages included for conversation context
- [ ] Token counting for cost tracking works
- [ ] API error (429 rate limit) → user-friendly message
- [ ] Timeout after 30 seconds → retry option

### Whisper Transcription
- [ ] Audio file uploaded → transcription received
- [ ] Transcription accuracy (English, clear speech)
- [ ] Background noise handling (partial transcription OK)
- [ ] API error → user-friendly message
- [ ] Timeout after 30 seconds → retry option

### Stripe Payments
- [ ] Test card (4242 4242 4242 4242) → successful subscription
- [ ] Declined card → error message
- [ ] Webhook received → subscription status updated
- [ ] Subscription cancellation webhook → status updated
- [ ] Refund webhook → access revoked

### AWS S3 Storage
- [ ] Photo upload → S3 URL returned
- [ ] Presigned URL (24-hour expiry) → photo loads
- [ ] Expired URL → new URL generated
- [ ] S3 error (500) → user-friendly message
- [ ] Large file compression before upload

---

## 8. Localization & Internationalization (if applicable)

- [ ] App supports multiple languages (if i18n implemented)
- [ ] Date/time formats respect user locale
- [ ] Currency formats correct (Stripe payments)
- [ ] Right-to-left (RTL) layout for Arabic/Hebrew
- [ ] Translated strings fit in UI (no truncation)

---

## 9. Legal & Compliance

- [ ] Privacy policy accessible in app
- [ ] Terms of service accessible in app
- [ ] Data deletion request honored (GDPR compliance)
- [ ] User consent for data collection
- [ ] Age verification (13+ or parental consent)
- [ ] Medical disclaimer visible (not a medical device)

---

## 10. Pre-Release Checklist

Before submitting to App Store / Play Store:

### Build Configuration
- [ ] App version incremented (pubspec.yaml)
- [ ] Build number incremented (iOS/Android)
- [ ] Release build mode (not debug)
- [ ] Obfuscation enabled (Flutter `--obfuscate`)
- [ ] ProGuard enabled (Android)
- [ ] Bitcode enabled (iOS, if required)

### App Store Assets
- [ ] App icon (1024x1024, no transparency)
- [ ] Screenshots (all required sizes, iOS + Android)
- [ ] App preview video (optional, but recommended)
- [ ] App description (clear, keyword-optimized)
- [ ] Privacy policy URL
- [ ] Support URL / email
- [ ] Age rating completed

### Final Checks
- [ ] Test on production backend (not staging)
- [ ] No test/debug features enabled
- [ ] Analytics tracking works (if implemented)
- [ ] Crash reporting works (Sentry/Firebase)
- [ ] Push notifications work (if implemented)
- [ ] Deep links work (test from email/SMS)

### Post-Submission Monitoring
- [ ] Monitor crash reports (first 24 hours)
- [ ] Monitor user reviews (respond to issues)
- [ ] Track download metrics
- [ ] Monitor backend server load (scaling if needed)
- [ ] Monitor OpenAI API costs (usage spikes)

---

## Testing Sign-Off

| Test Category | Tested By | Date | Pass/Fail | Notes |
|--------------|-----------|------|-----------|-------|
| Device Testing Matrix | | | | |
| User Flow Testing | | | | |
| Edge Case Testing | | | | |
| Accessibility Testing | | | | |
| Performance Testing | | | | |
| Security Testing | | | | |
| Integration Testing | | | | |
| Pre-Release Checklist | | | | |

**Release Approved By:** _____________________ **Date:** ___________

---

## Bug Reporting Template

When bugs are found during QA, use this template:

**Bug ID:** [e.g., QA-001]
**Severity:** [Critical / High / Medium / Low]
**Platform:** [iOS / Android / Both]
**Device:** [e.g., iPhone 14 Pro, iOS 17.2]
**Steps to Reproduce:**
1. Step one
2. Step two
3. Step three

**Expected Result:** What should happen
**Actual Result:** What actually happens
**Screenshots/Video:** [Attach if available]
**Workaround:** [If known]
**Status:** [Open / In Progress / Fixed / Closed]

---

*This checklist should be updated as new features are added. Review and update quarterly.*
