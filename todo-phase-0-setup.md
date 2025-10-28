# Phase 0: Project Setup & Infrastructure

**Focus:** Environment setup, tooling, database, AWS configuration
**Timeline:** Weeks 1-2
**Prerequisites:** None - this is the starting point

---

## 🎯 Environment & Tooling

- [x] Initialize React Native 0.74+ project with TypeScript template
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

---

## 📊 Database & Storage

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

---

## 🚀 CI/CD & Deployment Prep

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

**Progress:** ⬜ 0/16 tasks completed

**Next Phase:** [Phase 1: Database Schema & Auth](todo-phase-1-database-auth.md)
