# Environment Variables Documentation

This document describes all environment variables used in the AI Parenting Assistant project.

## Setup Instructions

### Backend Setup

1. Navigate to the `backend` directory
2. Copy `.env.example` to `.env`:
   ```bash
   cd backend
   cp .env.example .env
   ```
3. Fill in actual values in `.env` file
4. Never commit `.env` file to version control

### Mobile App Setup

1. Navigate to the `mobile` directory
2. Copy `.env.example` to `.env`:
   ```bash
   cd mobile
   cp .env.example .env
   ```
3. Fill in actual values in `.env` file
4. For iOS: `cd ios && pod install`
5. Never commit `.env` file to version control

---

## Backend Environment Variables

### Server Configuration

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `NODE_ENV` | Yes | Environment mode | `development`, `production` |
| `PORT` | Yes | Server port | `3000` |

### Database Configuration

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `DATABASE_URL` | Yes | PostgreSQL connection string | `postgresql://user:pass@localhost:5432/db_name` |
| `REDIS_URL` | Yes | Redis connection string | `redis://localhost:6379` |

### Authentication

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `JWT_SECRET` | Yes | Secret for access tokens (7-day expiry) | Generate with `openssl rand -base64 64` |
| `JWT_REFRESH_SECRET` | Yes | Secret for refresh tokens (30-day expiry) | Generate with `openssl rand -base64 64` |

### Third-Party APIs

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `OPENAI_API_KEY` | Yes | OpenAI API key for GPT-4, Whisper, Vision | `sk-proj-...` |
| `STRIPE_SECRET_KEY` | Yes | Stripe secret key for payments | `sk_test_...` or `sk_live_...` |
| `STRIPE_WEBHOOK_SECRET` | Yes | Stripe webhook signing secret | `whsec_...` |

### AWS S3 Storage

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | Yes | AWS IAM access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Yes | AWS IAM secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | Yes | AWS region for S3 bucket | `us-east-1` |
| `S3_BUCKET` | Yes | S3 bucket name | `ai-parenting-dev` |

### Security

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `CORS_ORIGIN` | No | Allowed CORS origins (comma-separated) | `http://localhost:3000,http://localhost:8081` |

---

## Mobile App Environment Variables

### API Configuration

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `API_URL` | Yes | Backend API base URL | `http://192.168.1.100:3000` (dev), `https://api.example.com` (prod) |

**Important for Development:**
- Do NOT use `localhost` or `127.0.0.1` - the mobile app can't connect to your computer's localhost
- Use your computer's local IP address instead (find with `ipconfig` on Windows or `ifconfig` on Mac/Linux)
- Example: `http://192.168.1.100:3000`

### Payments

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `STRIPE_PUBLISHABLE_KEY` | Yes | Stripe publishable key | `pk_test_...` or `pk_live_...` |

---

## Generating Secrets

### JWT Secrets

Generate random, secure secrets for JWT tokens:

```bash
# Generate JWT_SECRET
openssl rand -base64 64

# Generate JWT_REFRESH_SECRET (use a different value!)
openssl rand -base64 64
```

Copy the output into your `.env` file.

---

## Security Best Practices

1. **Never commit `.env` files** - They are already in `.gitignore`
2. **Use different secrets for development and production**
3. **Rotate secrets regularly** (every 90 days recommended)
4. **Use environment-specific values**:
   - Development: Use test API keys (Stripe `sk_test_`, OpenAI test keys)
   - Production: Use live API keys (Stripe `sk_live_`, production OpenAI keys)
5. **Limit AWS IAM permissions** - S3 access only, no admin rights
6. **Enable Stripe webhook signature verification** - Always verify webhook signatures

---

## Getting API Keys

### OpenAI API Key
1. Visit https://platform.openai.com/api-keys
2. Sign in or create account
3. Click "Create new secret key"
4. Copy key immediately (shown only once)

### Stripe Keys
1. Visit https://dashboard.stripe.com/apikeys
2. Sign in or create account
3. Copy "Publishable key" (starts with `pk_`)
4. Copy "Secret key" (starts with `sk_`)
5. For webhooks: https://dashboard.stripe.com/webhooks

### AWS Credentials
1. Visit AWS IAM console
2. Create new user with programmatic access
3. Attach policy: `AmazonS3FullAccess` (or custom S3-only policy)
4. Save access key ID and secret access key
5. Create S3 bucket in desired region

---

## Troubleshooting

### Backend not connecting to database
- Verify `DATABASE_URL` is correct
- Check PostgreSQL is running: `pg_isready`
- Test connection: `psql <DATABASE_URL>`

### Mobile app can't reach backend
- Use local IP, not `localhost`
- Check firewall allows connections on port 3000
- Verify backend is running: `curl http://localhost:3000/health`

### Stripe webhooks failing
- Verify `STRIPE_WEBHOOK_SECRET` is correct
- Check webhook endpoint is publicly accessible
- Use Stripe CLI for local testing: `stripe listen --forward-to localhost:3000/webhooks/stripe`

### OpenAI API errors
- Verify API key is valid
- Check account has credits/billing enabled
- Review rate limits: https://platform.openai.com/account/rate-limits

---

*Last Updated: 2025-10-28*
