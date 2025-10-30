# Phase 4: Monetization & Subscriptions

**Focus:** Stripe integration, in-app purchases, paywall, usage limits enforcement
**Timeline:** Weeks 14-15
**Prerequisites:** Phase 3 completed (core features functional, usage tracking in place)

---

## 💳 Backend Subscription Management

- [x] Install Stripe SDK
  - `npm install stripe`
  - Configure Stripe secret key in .env (use test key for development)
  - Initialize Stripe client in `services/stripe.ts`

- [x] Add Stripe fields to User model
  - Migration to add: stripeCustomerId (String, nullable), stripeSubscriptionId (String, nullable)
  - Run `npx prisma migrate dev --name add-stripe-fields`
  - Generate Prisma Client

- [x] Create `GET /subscription/status` endpoint
  - Authenticate user with JWT middleware
  - Return user's subscriptionTier, subscriptionStatus, subscriptionExpiresAt
  - Include current usage stats:
    - messagesUsed today (from UsageTracking)
    - voiceMinutesUsed today
    - photosStored total (count from Photo table)
  - Return limits based on tier (free: 10/10/100, premium: unlimited)

- [x] Create `POST /subscription/create` endpoint
  - Authenticate user
  - Accept priceId from request body (Stripe price ID for monthly or yearly)
  - Create Stripe Customer if stripeCustomerId is null
    - Use user email and userId as metadata
  - Create Stripe Subscription with payment method
  - Store stripeCustomerId and stripeSubscriptionId in User table
  - Update subscriptionTier to PREMIUM
  - Update subscriptionStatus to ACTIVE
  - Set subscriptionExpiresAt to subscription current_period_end
  - Return subscription object

- [x] Create `POST /subscription/cancel` endpoint
  - Authenticate user
  - Verify user has active subscription
  - Cancel Stripe subscription (set cancel_at_period_end: true)
  - Update subscriptionStatus to CANCELLED
  - Keep premium access until subscriptionExpiresAt (current period ends)
  - Return success message and final access date

- [x] Create `POST /stripe/webhook` endpoint
  - Accept Stripe webhook POST requests
  - Verify Stripe webhook signature with stripe.webhooks.constructEvent()
  - Handle events:
    - `invoice.paid`: Update subscriptionExpiresAt, set status to ACTIVE
    - `customer.subscription.deleted`: Set subscriptionTier to FREE, status to EXPIRED
    - `customer.subscription.updated`: Update subscriptionExpiresAt and status
  - Return 200 status to Stripe to acknowledge receipt

- [x] Implement usage limit checking middleware
  - Function `checkUsageLimit(userId, limitType: 'message' | 'voice')`
  - Query User to check subscriptionTier
  - If PREMIUM, return { allowed: true, unlimited: true }
  - If FREE, query UsageTracking for today's usage
  - For message: check messagesUsed < 10
  - For voice: check voiceMinutesUsed < 10
  - Return { allowed: boolean, remaining: number }

- [x] Integrate usage checking in chat endpoints
  - In `POST /chat/message`, call checkUsageLimit before processing
  - If not allowed, return 429 status with { error: 'limit_reached', resetTime: '...' }
  - In `POST /voice/start-session`, check voice limit
  - In `POST /chat/voice`, check message limit (Whisper counts as message)

---

## 📱 Frontend Subscription UI

- [x] Install in-app purchase library
  - `flutter pub add flutter_stripe` (Note: Currently disabled due to iOS 18 compatibility)
  - Configure iOS App Store Connect:
    - Create app in App Store Connect
    - Add in-app purchase products (subscription type)
    - Product IDs: e.g., "com.aiparenting.monthly", "com.aiparenting.yearly"
  - Configure Google Play Console:
    - Create app listing
    - Add subscription products
    - Same product IDs as iOS for consistency
  - Set up product IDs in .env or config file

- [x] Create subscription context
  - Created subscription providers with Riverpod:
    - subscriptionStatus state
    - usageStats state (messages, voice, photos)
    - Methods: fetchSubscriptionStatus(), purchaseSubscription(), cancelSubscription()

- [x] Fetch subscription status on app launch
  - Watches subscriptionProvider in main_navigation.dart
  - Updates subscription state via Riverpod
  - Automatically refreshes on app launch

- [x] Create Paywall modal component
  - Semi-transparent overlay (Modal with transparent background)
  - Centered card (cannot dismiss by tapping outside)
  - Design elements:
    - Friendly icon (not aggressive/annoying)
    - Headline: "You've reached today's limit"
    - Subtext: "Continue the conversation with Premium, or wait until [midnight reset time]"
    - List premium benefits with checkmarks:
      - Unlimited messages and voice
      - Unlimited photo storage
      - Priority AI responses
      - Early access to features
  - Pricing display: Toggle between Monthly ($9.99) and Yearly ($99, "Save 17%")
  - Two CTA buttons:
    - "Upgrade Now" (primary, prominent)
    - "Remind Me Tomorrow" (secondary, less prominent)
  - Small text link at bottom: "Continue with Free" (closes modal)

- [x] Trigger paywall on limit reached
  - After sending message, check for 429 error response
  - If 429 with error: 'limit_reached', show paywall modal
  - Disable message input and show countdown: "Resets in 8h 23m"
  - For voice, check limit before starting session
  - If limit reached, show paywall instead of starting voice mode

- [x] Implement subscription purchase flow
  - Tap "Upgrade Now" button in paywall
  - Show price selection if not already selected (Monthly / Yearly toggle)
  - Integrated with PurchaseService and SubscriptionRepository
  - On successful purchase, get purchase receipt
  - Call `POST /subscription/create` with receipt data
  - Update local subscription state to PREMIUM
  - Close paywall and show success toast
  - Refresh UI to show "Unlimited" badge

- [x] Handle purchase errors
  - User cancels: just close purchase modal
  - Payment fails: show error alert with retry option
  - Receipt validation fails: show error, contact support message

- [x] Create Subscription Management screen (in Settings)
  - Navigate from Settings tab
  - Display current plan:
    - Free: "Free Plan" with upgrade button
    - Premium: "Premium - Monthly/Yearly" with renewal date
  - Show usage stats (even for premium, show activity)
  - If premium, show "Manage Subscription" button
    - Opens App Store subscriptions (iOS) via url_launcher
    - Opens Google Play subscriptions (Android)
  - "Cancel Subscription" button (with confirmation alert)
    - Call `POST /subscription/cancel` on confirm
    - Show message: "Your access continues until [date]"

- [x] Implement restore purchases functionality
  - "Restore Purchases" button in Settings > Subscription
  - Calls PurchaseService.restorePurchases()
  - If valid subscription found, verify with backend
  - Update local state to PREMIUM if valid
  - Show success or "No purchases found" message

- [x] Add usage counter UI component
  - Display in chat screen header (next to baby name)
  - Badge showing: "7/10 messages" or "Unlimited"
  - Separate indicator for voice: "6/10 voice min"
  - Update counter in real-time after each use
  - If premium, show "⭐ Premium" badge instead of counters
  - Tapping counter shows explanation of limits

- [x] Add upgrade prompts (non-intrusive)
  - After 10 days of active use (7+ messages per day), show soft prompt:
    - "Loving the app? Upgrade for unlimited access"
    - Dismissable, doesn't block usage
  - When user hits 80% of daily limit, show gentle reminder:
    - "2 messages left today. Upgrade for unlimited"
    - Small banner at top, easily dismissed

---

**Progress:** ✅ 19/19 tasks completed (100%)

**Previous Phase:** [Phase 3: Photos & Milestones](todo-phase-3-photos-milestones.md)
**Next Phase:** [Phase 5: Settings & Polish](todo-phase-5-settings-polish.md)
