# AI Parenting Assistant

An AI-powered cross-platform mobile application designed to support parents from pregnancy through early childhood with personalized guidance, milestone tracking, and instant support.

## 🚀 Project Status

**Current Phase:** Phase 3 - Photos & Milestones
**Progress:** ~27/272 MVP tasks completed (~10%)

## 📋 Documentation

- **[PRD_MVP.md](PRD_MVP.md)** - Complete product requirements document
- **[CLAUDE.md](CLAUDE.md)** - Development guide for AI assistants (comprehensive)
- **[TODO-README.md](TODO-README.md)** - Todo structure and workflow

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.24+** (Dart)
- **go_router** - Declarative routing
- **Riverpod** - State management with code generation
- **Material 3** - Modern UI design system

### Backend
- Node.js 20.x (TypeScript)
- Express.js 4.x
- Prisma ORM
- PostgreSQL 15+
- Socket.io (real-time voice)

### Infrastructure & Services
- **AWS S3** - Photo storage with presigned URLs
- **OpenAI GPT-4o** - AI chat assistant
- **OpenAI Whisper** - Voice transcription
- **OpenAI Vision** - Photo analysis
- Stripe (subscriptions) - Coming in Phase 4

## 📱 Features (MVP)

- ✅ AI-powered parenting chat (24/7 guidance)
- ✅ Voice input and conversation mode
- ✅ Photo-based symptom analysis (AI Vision)
- ✅ Milestone tracking with photos
- ✅ Pregnancy mode → Parenting mode transition
- ✅ Freemium model (10 messages/day free, unlimited premium)
- ✅ Cross-platform (iOS & Android)

## 🏗️ Development Phases

1. **Phase 0:** Project Setup (16 tasks) - ✅ **COMPLETE**
2. **Phase 1:** Database & Auth (44 tasks) - ✅ **COMPLETE**
3. **Phase 2:** Chat & Voice (40 tasks) - ✅ **COMPLETE**
4. **Phase 3:** Photos & Milestones (33 tasks) - 🚧 **IN PROGRESS** (~90% complete)
5. **Phase 4:** Monetization (19 tasks) - ⏸️ **BLOCKED** (iOS 18 payment package compatibility)
6. **Phase 5:** Settings & Polish (58 tasks) - ⏳ Not Started
7. **Phase 6:** Deployment (62 tasks) - ⏳ Not Started

**Estimated Timeline:** 22 weeks (5.5 months) for MVP
**Time Elapsed:** ~2 weeks

## 📦 Project Structure

```
ai-parenting-assistant/
├── mobile/                      # Flutter app
│   ├── lib/
│   │   ├── features/           # Feature-based architecture
│   │   │   ├── auth/           # Authentication & login
│   │   │   ├── chat/           # AI chat interface
│   │   │   ├── voice/          # Voice recording
│   │   │   ├── photos/         # Photo upload & gallery
│   │   │   ├── milestones/     # Milestone tracking
│   │   │   ├── profile/        # User profile
│   │   │   └── onboarding/     # Onboarding flow
│   │   ├── shared/             # Shared utilities & widgets
│   │   ├── router/             # go_router configuration
│   │   └── main.dart           # App entry point
│   └── pubspec.yaml            # Flutter dependencies
│
├── backend/                     # Node.js/Express API
│   ├── src/
│   │   ├── routes/             # API endpoints
│   │   ├── controllers/        # Business logic
│   │   ├── services/           # OpenAI, S3 integrations
│   │   ├── middleware/         # Auth, rate limiting
│   │   ├── utils/              # Helper functions
│   │   └── prisma/             # Database schema
│   └── package.json            # Node.js dependencies
│
└── docs/                        # Setup & configuration docs
    ├── DATABASE_SETUP.md
    ├── ENVIRONMENT_VARIABLES.md
    └── MOBILE_BUILD_SETUP.md
```

## 🔑 Key Principles

- **Phase-based development** - Complete one phase before moving to next
- **Test immediately** - No untested code accumulation
- **Document everything** - Every function, every code block (mandatory)
- **Commit frequently** - Push after each completed task
- **Library-first approach** - Search pub.dev before writing custom code
- **AI-optimized** - Structured for AI-assisted development

## ⚙️ Quick Start

### Prerequisites
- Flutter 3.24+ SDK
- Node.js 20.x
- PostgreSQL 15+
- Xcode (for iOS development)
- Android Studio (for Android development)

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env  # Configure environment variables
npx prisma migrate dev
npm run dev
```

### Mobile Setup
```bash
cd mobile
flutter pub get
dart run build_runner build
flutter run
```

For detailed setup instructions, see [MOBILE_BUILD_SETUP.md](MOBILE_BUILD_SETUP.md) and [DATABASE_SETUP.md](DATABASE_SETUP.md).

## 📖 Getting Started

### For Development

1. **Read the guides:**
   - [CLAUDE.md](CLAUDE.md) - Comprehensive development guide (MUST READ)
   - [TODO-README.md](TODO-README.md) - Todo workflow and progress tracking
   - [PRD_MVP.md](PRD_MVP.md) - Product requirements

2. **Check current phase:**
   - Currently on Phase 3 (Photos & Milestones)
   - View progress in [todo-phase-3-photos-milestones.md](todo-phase-3-photos-milestones.md)

3. **Setup environment:**
   - Follow backend setup in [DATABASE_SETUP.md](DATABASE_SETUP.md)
   - Follow mobile setup in [MOBILE_BUILD_SETUP.md](MOBILE_BUILD_SETUP.md)
   - Configure environment variables per [ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md)

4. **Start coding:**
   - Pick next uncompleted task from current phase file
   - Complete, test, document, commit, push
   - Mark task as complete with `[x]`

## 🎯 Success Metrics (MVP Goals)

- 60%+ Day 1 retention
- 15%+ free-to-paid conversion
- 4.5+ App Store rating
- 10,000 downloads in first month

## ⚠️ Important Notes

### iOS 18 Compatibility
The project uses **iOS 18** development environment. Some Flutter packages have compatibility issues:

- ✅ **Audio Recording:** Using `record` package (iOS 18 compatible) instead of `flutter_sound`
- ⏳ **Payments:** `in_app_purchase` and `flutter_stripe` temporarily disabled until iOS 18-compatible versions are released
- 💡 **Phase 4 Blocked:** Monetization features blocked until payment packages are updated

See [CLAUDE.md](CLAUDE.md) "iOS 18 Compatibility Notes" section for full details and workarounds.

### Development Commands
All commonly used commands are documented in [CLAUDE.md](CLAUDE.md) under "Development Commands":
- Flutter build, test, and run commands
- Backend Prisma migrations and server commands
- Git workflow and commit strategies
- Troubleshooting steps for common issues

## 📄 License

TBD

## 👥 Team

TBD

---

*Last Updated: 2025-10-30*
*MVP PRD Version: 1.0*
*Tech Stack: Flutter 3.24+ | Node.js 20.x | PostgreSQL 15+ | OpenAI GPT-4o*
