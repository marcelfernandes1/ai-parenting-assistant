# Phase 6: Deployment & Launch

**Focus:** Production setup, App Store/Google Play submission, monitoring, beta testing
**Timeline:** Weeks 19-22
**Prerequisites:** Phase 5 completed (app fully built and tested)

---

## 🚀 Backend Deployment

### Production Infrastructure Setup

- [ ] Set up production environment (choose one)
  - **Option A - AWS**: Provision EC2, RDS, S3, ElastiCache
  - **Option B - Managed Platform**: Use Render.com, Railway, or Heroku
  - Document choice and setup steps

- [ ] Configure production database
  - Create PostgreSQL production instance (AWS RDS Multi-AZ or managed service)
  - Enable automated backups (daily, 7-day retention)
  - Set up read replicas if needed for scale
  - Configure connection pooling (max 20-50 connections)
  - Run Prisma migrations: `npx prisma migrate deploy`

- [ ] Configure production Redis
  - Set up Redis instance (AWS ElastiCache or Redis Cloud)
  - Enable persistence (AOF or RDB)
  - Configure eviction policy (allkeys-lru for caching)

- [ ] Configure production S3 bucket
  - Create separate production bucket
  - Enable versioning (for photo recovery)
  - Configure lifecycle policies (transition to Glacier after 1 year)
  - Set up CORS for mobile app access
  - Enable server-side encryption (AES-256)

- [ ] Configure production environment variables
  - Use AWS Secrets Manager or similar service
  - Set NODE_ENV=production
  - Add all API keys: OPENAI_API_KEY, STRIPE_SECRET_KEY, AWS credentials
  - Add JWT_SECRET and JWT_REFRESH_SECRET (generate new, different from dev)
  - Add database connection string
  - Add Redis connection string
  - Document all required env vars

- [ ] Set up SSL/TLS certificates
  - Use AWS Certificate Manager (free) or Let's Encrypt
  - Configure HTTPS only (redirect HTTP to HTTPS)
  - Use TLS 1.2 or higher

- [ ] Build production backend
  - Run TypeScript build: `npm run build`
  - Create Docker image (optional but recommended)
  - Test production build locally before deploying

- [ ] Deploy backend to production
  - Push Docker image to container registry (ECR, Docker Hub)
  - Deploy to ECS Fargate, Elastic Beanstalk, or managed platform
  - Configure health check endpoint: `GET /health`
  - Set up auto-scaling (min 2 instances for HA)
  - Verify deployment with smoke tests

- [ ] Set up monitoring and logging
  - Configure AWS CloudWatch logs (or platform equivalent)
  - Set up log retention (30 days minimum)
  - Install Sentry SDK for error tracking
  - Configure Sentry alerts for error rate spikes
  - Set up uptime monitoring (UptimeRobot, Pingdom)

- [ ] Configure production Stripe webhook
  - Add production webhook endpoint in Stripe Dashboard
  - Use production webhook signing secret
  - Test webhook with Stripe CLI: `stripe listen --forward-to`

---

## 📱 App Store Preparation (iOS)

### Apple Developer Setup

- [ ] Create Apple Developer Account
  - Enroll in Apple Developer Program ($99/year)
  - Complete enrollment verification (can take 24-48 hours)
  - Accept latest Developer Agreement

- [ ] Set up App Store Connect
  - Create new app in App Store Connect
  - Add app name (check availability first)
  - Choose bundle ID: e.g., `com.yourcompany.aiparenting`
  - Set SKU (unique identifier)
  - Select primary language (English US)

### App Store Listing

- [ ] Write app metadata
  - App name (max 30 chars): "AI Parenting Assistant" or final name
  - Subtitle (max 30 chars): "Your 24/7 Parenting Guide"
  - Description (max 4000 chars):
    - Start with value proposition
    - List key features
    - Mention AI capabilities and personalization
    - Include disclaimer about medical advice
  - Keywords (max 100 chars, comma-separated): "parenting, baby, AI, pregnancy, milestones"
  - Promotional text (170 chars, updateable): Use for announcements

- [ ] Create app screenshots
  - Required sizes: 6.7" (iPhone 14 Pro Max) and 5.5" (iPhone 8 Plus)
  - Recommended: Use all device sizes for best presentation
  - Create 3-5 screenshots showing:
    - Chat interface with AI response
    - Milestone tracking
    - Photo gallery
    - Onboarding screen (optional)
  - Add text overlays highlighting features

- [ ] Create app icon
  - Design 1024x1024 icon (no alpha channel, no rounded corners)
  - Follow iOS design guidelines
  - Should be recognizable at small sizes
  - Export at @1x, @2x, @3x for Xcode

- [ ] Create app preview video (optional but recommended)
  - 15-30 seconds showing app in use
  - Use portrait orientation
  - No audio narration (use captions)

- [ ] Set age rating
  - Complete App Store questionnaire
  - Expected rating: 4+ (no concerning content)
  - Note: App provides parenting advice, not medical treatment

- [ ] Add privacy policy URL
  - Host privacy policy on your website or use iubenda
  - Must be publicly accessible
  - Add URL to App Store listing

- [ ] Add support URL
  - Create support email or website
  - Add to App Store listing

### In-App Purchases Configuration

- [ ] Create subscription products in App Store Connect
  - Navigate to Features > In-App Purchases
  - Create new "Auto-Renewable Subscription"
  - Product ID: `com.aiparenting.monthly`
  - Reference name: "Premium Monthly Subscription"
  - Set pricing: $9.99/month (Tier 10)
  - Create subscription group if needed
  - Repeat for yearly: `com.aiparenting.yearly` at $99/year

- [ ] Write subscription descriptions
  - Display name: "Premium" (shown to users)
  - Description: "Unlimited messages, voice time, and photo storage"
  - Add localized descriptions if supporting other languages

- [ ] Set up subscription offers (optional)
  - Introductory offer: 7-day free trial
  - Configure eligibility (new subscribers only)

- [ ] Submit in-app purchases for review
  - Add screenshot showing subscription in app
  - Submit separately before app submission

### iOS Build & Submit

- [ ] Prepare production build
  - Update version number: package.json, Info.plist (e.g., 1.0.0)
  - Update build number: increment for each submission
  - Set production API URLs in config
  - Remove development debugging code

- [ ] Build with EAS Build (recommended)
  - Configure production profile in eas.json
  - Run: `eas build --platform ios --profile production`
  - Wait for build to complete (download IPA)

- [ ] Or build with Xcode
  - Open iOS workspace in Xcode
  - Select "Any iOS Device" as build target
  - Product > Archive
  - Wait for archive to complete
  - Validate app before uploading
  - Distribute to App Store

- [ ] Submit app for App Store review
  - Upload IPA via Transporter app or Xcode
  - In App Store Connect, select uploaded build
  - Fill out review information:
    - Contact info (name, phone, email)
    - Demo account credentials if login required
    - Review notes: Explain AI features, mention OpenAI usage
  - Add export compliance info (encryption)
  - Submit for review

- [ ] Monitor review status
  - Expect 1-3 days review time
  - Respond promptly to any rejection or questions
  - Common issues: screenshots, privacy policy, IAP

---

## 🤖 Google Play Preparation (Android)

### Google Play Developer Setup

- [ ] Create Google Play Developer Account
  - Pay one-time $25 registration fee
  - Complete account verification
  - Accept Developer Distribution Agreement

- [ ] Create app in Google Play Console
  - Click "Create app"
  - Add app name (check availability)
  - Select default language (English US)
  - Choose app or game (app)
  - Select free or paid (free with IAP)

### Google Play Listing

- [ ] Write app metadata
  - Short description (max 80 chars): "Your AI-powered parenting companion"
  - Full description (max 4000 chars):
    - Similar to iOS description
    - Format with markdown (bold, bullets)
  - Title (max 50 chars): "AI Parenting Assistant"

- [ ] Create app graphics
  - App icon: 512x512 PNG (no rounded corners)
  - Feature graphic: 1024x500 (required, shown in store)
  - Screenshots:
    - Phone: 16:9 or 9:16 aspect ratio (min 320px)
    - Tablet: 16:9 or 9:16 (min 1024px)
    - Create 2-8 screenshots showing key features

- [ ] Set content rating
  - Complete content rating questionnaire
  - Describe app's purpose and content
  - Expected rating: Everyone or PEGI 3

- [ ] Add privacy policy URL
  - Same as iOS (publicly accessible)

- [ ] Set up store listing details
  - App category: Parenting
  - Add tags (relevant keywords)
  - Contact email (public)
  - Website (optional)

### In-App Products Configuration

- [ ] Create subscription products in Google Play Console
  - Navigate to Monetize > Subscriptions
  - Create new subscription
  - Product ID: `monthly_premium` (must match iOS for react-native-iap)
  - Name: "Premium Monthly"
  - Description: "Unlimited access to all features"
  - Set billing period: 1 month
  - Set price: $9.99 USD (configure other countries)
  - Repeat for yearly subscription

- [ ] Configure free trial
  - Set trial period: 7 days
  - Select eligibility (new subscribers)

### Android Build & Submit

- [ ] Prepare production build
  - Update version in package.json and android/app/build.gradle
    - versionCode: 1 (increment for each release)
    - versionName: "1.0.0"
  - Set production API URLs
  - Remove debug code

- [ ] Generate signing key
  - Run: `keytool -genkeypair -v -storetype PKCS12 -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000`
  - Store keystore file securely (backup!)
  - Document keystore password and alias

- [ ] Build with EAS Build (recommended)
  - Configure production profile in eas.json
  - Run: `eas build --platform android --profile production`
  - Download AAB (Android App Bundle)

- [ ] Or build with Android Studio
  - Open android folder in Android Studio
  - Build > Generate Signed Bundle/APK
  - Select Android App Bundle (AAB)
  - Choose release variant
  - Sign with keystore

- [ ] Upload to Google Play Console
  - Navigate to Release > Production
  - Create new release
  - Upload AAB file
  - Add release notes: "Initial release with AI chat, milestone tracking, photo storage"
  - Review and roll out to production

- [ ] Submit for review
  - Complete all required sections (content rating, target audience, etc.)
  - Submit for review
  - Usually faster than iOS (few hours to 1 day)

---

## 📊 Post-Launch Monitoring

### Set Up Analytics & Monitoring

- [ ] Verify analytics tracking
  - Mixpanel or Firebase Analytics initialized
  - Test event firing:
    - User registration
    - First message sent
    - Subscription purchased
    - Milestone logged
  - Set up conversion funnels

- [ ] Monitor app store reviews
  - Set up alerts for new reviews (AppFollow, App Radar)
  - Respond to reviews within 24 hours
  - Thank positive reviews
  - Address concerns in negative reviews professionally

- [ ] Monitor crash reports
  - Check Sentry dashboard daily
  - Set up Slack/email alerts for new crashes
  - Prioritize critical crashes (affecting >1% users)
  - Create hotfix releases if needed

- [ ] Monitor backend performance
  - Check API response times (CloudWatch or similar)
  - Monitor database query performance
  - Check OpenAI API usage and costs (set billing alerts)
  - Monitor error rates

- [ ] Monitor business metrics
  - Track daily signups (goal: 100+ in first week)
  - Track daily active users (DAU)
  - Track conversion rate free → paid (goal: 15%+)
  - Track churn rate (should be <5% monthly)
  - Track revenue (MRR - Monthly Recurring Revenue)

### Beta Testing (Weeks 19-21)

- [ ] Closed beta (Week 19-20)
  - Recruit 50-100 expecting/new parents
  - Use personal network, parenting forums, ads
  - Distribute via TestFlight (iOS) and Google Play Internal Testing (Android)
  - Set up feedback channel (Slack, email, in-app form)
  - Focus areas:
    - App stability (crashes, bugs)
    - AI response quality
    - User experience (confusing flows?)
  - Collect feedback daily

- [ ] Analyze beta feedback
  - Identify top 5 issues/bugs
  - Fix critical bugs before open beta
  - Iterate on confusing UX
  - Improve AI prompts if responses poor

- [ ] Open beta (Week 21-22)
  - Expand to 500-1000 users
  - Publicly available via TestFlight link
  - Light promotion (post in parenting communities)
  - Metrics to watch:
    - Retention (Day 1, 7)
    - Conversion rate
    - Support ticket volume
  - Continue iterating based on feedback

### Launch Day Checklist

- [ ] Final pre-launch checks
  - All production environment variables set
  - Database backups enabled
  - Monitoring and alerts configured
  - Support email ready to receive messages
  - Stripe webhooks working

- [ ] App Store launch (once approved)
  - Apps automatically available after approval
  - Share App Store / Google Play links
  - Post on social media
  - Email beta users thanking them

- [ ] Press outreach
  - Email parenting blogs, tech blogs
  - Provide press kit (screenshots, description, founder story)
  - Offer free premium access for reviews

- [ ] Community engagement
  - Post on parenting subreddits (follow self-promotion rules)
  - Post in parenting Facebook groups
  - Share in relevant Slack/Discord communities

- [ ] Paid acquisition (if budget allows)
  - Set up Facebook/Instagram ads
  - Set up Google/Apple Search Ads
  - Target: expecting mothers, new parents
  - Budget: $500-1000 for initial test
  - Monitor CPA (cost per acquisition)

---

**Progress:** ⬜ 0/62 tasks completed

**Previous Phase:** [Phase 5: Settings & Polish](todo-phase-5-settings-polish.md)
**Next:** [Post-MVP Features](todo-post-mvp.md)
