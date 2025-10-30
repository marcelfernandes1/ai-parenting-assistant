# Stripe Subscription Setup Guide

This document explains how to complete the Stripe integration for in-app subscription purchases.

## Overview

The subscription purchase flow has been implemented with the following architecture:

### Files Created/Modified

1. **`lib/features/subscription/data/purchase_service.dart`** - Service for handling Stripe purchases
2. **`lib/features/subscription/data/subscription_repository.dart`** - Repository methods for subscription API calls
3. **`lib/features/subscription/providers/subscription_provider.dart`** - Added `purchaseServiceProvider`
4. **`lib/features/subscription/presentation/paywall_modal.dart`** - Integrated purchase and restore flows

### Purchase Flow

1. User taps "Start Premium Trial" in paywall
2. App shows Stripe payment collection UI (CardField or Payment Sheet)
3. Stripe creates payment method
4. App sends payment method ID + price ID to backend
5. Backend creates Stripe subscription and charges card
6. App refreshes subscription status
7. User gains Premium access

## Required Setup Steps

### 1. Initialize Stripe SDK

In `lib/main.dart`, add Stripe initialization before `runApp()`:

```dart
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with publishable key
  Stripe.publishableKey = const String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_YOUR_TEST_KEY_HERE', // For development
  );

  // Optional: Set merchant identifier for Apple Pay (iOS only)
  Stripe.merchantIdentifier = 'merchant.com.yourapp';

  runApp(const MyApp());
}
```

**Get your Stripe publishable key:**
- Development: https://dashboard.stripe.com/test/apikeys
- Production: https://dashboard.stripe.com/apikeys

### 2. Create Stripe Products and Prices

In your Stripe Dashboard:

1. Go to **Products** → **Add Product**
2. Create product: "Premium Subscription"
3. Add prices:
   - **Monthly**: $4.99/month (recurring)
   - **Yearly**: $49.99/year (recurring) - optional

4. Copy the Price IDs (format: `price_xxxxxxxxxxxxx`)

### 3. Update Price IDs in Code

In `lib/features/subscription/data/purchase_service.dart`, replace placeholder price IDs:

```dart
static const String monthlyPriceId = 'price_1234567890'; // Your actual Stripe price ID
static const String yearlyPriceId = 'price_0987654321';  // Your actual Stripe price ID
```

### 4. Add Payment Collection UI

You have two options for collecting payment details:

#### Option A: CardField Widget (Simple)

Add CardField to paywall modal or a dedicated payment screen:

```dart
import 'package:flutter_stripe/flutter_stripe.dart';

// In your payment UI widget:
CardField(
  onCardChanged: (card) {
    // Card details are automatically stored by Stripe SDK
    // They will be used when purchaseSubscription() is called
  },
  style: CardFieldStyle(
    borderColor: Theme.of(context).colorScheme.outline,
    backgroundColor: Theme.of(context).colorScheme.surface,
  ),
)
```

#### Option B: Payment Sheet (Recommended)

For a better UX, use Stripe's pre-built Payment Sheet. Update `purchase_service.dart`:

```dart
Future<Map<String, dynamic>> purchaseSubscription({
  required String priceId,
}) async {
  try {
    // Step 1: Create Setup Intent on backend (requires new endpoint)
    final setupIntent = await _subscriptionRepository.createSetupIntent();

    // Step 2: Initialize payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'AI Parenting Assistant',
        setupIntentClientSecret: setupIntent['clientSecret'],
        customerId: setupIntent['customerId'],
        customerEphemeralKeySecret: setupIntent['ephemeralKey'],
        style: ThemeMode.system,
      ),
    );

    // Step 3: Present payment sheet to user
    await Stripe.instance.presentPaymentSheet();

    // Step 4: Create subscription with payment method
    final paymentMethodId = setupIntent['paymentMethodId'];
    return await _subscriptionRepository.createSubscription(
      paymentMethodId: paymentMethodId,
      priceId: priceId,
    );
  } catch (e) {
    throw Exception('Purchase failed: $e');
  }
}
```

### 5. Test with Stripe Test Cards

Use these test card numbers in development:

- **Success**: `4242 4242 4242 4242`
- **Requires 3D Secure**: `4000 0025 0000 3155`
- **Declined**: `4000 0000 0000 0002`
- **Expires in future**: Any month/year in the future
- **CVC**: Any 3 digits
- **ZIP**: Any 5 digits

### 6. Backend Setup Verification

Ensure your backend has these endpoints configured:

- ✅ `POST /subscription/create` - Creates Stripe subscription (already implemented)
- ✅ `POST /subscription/cancel` - Cancels subscription (already implemented)
- ✅ `GET /subscription/status` - Gets subscription status (already implemented)
- ⚠️  `POST /subscription/webhook` - Handles Stripe webhooks (needs testing)

**Important**: Test the webhook endpoint with Stripe CLI:

```bash
stripe listen --forward-to http://localhost:3000/stripe/webhook
stripe trigger invoice.paid
stripe trigger customer.subscription.deleted
```

### 7. iOS Configuration (if using Apple Pay)

In `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>your-app-scheme</string>
    </array>
  </dict>
</array>
```

Enable Apple Pay capability in Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner target → Signing & Capabilities
3. Click "+ Capability" → Apple Pay
4. Add merchant identifier

### 8. Android Configuration

No additional configuration needed for basic Stripe integration.

For Google Pay (optional), follow: https://stripe.com/docs/google-pay

## Testing Checklist

Before deploying to production:

- [ ] Stripe publishable key is set correctly (test key for dev, live key for prod)
- [ ] Price IDs match your Stripe Dashboard products
- [ ] CardField or Payment Sheet is displayed in UI
- [ ] Test purchase with test card `4242 4242 4242 4242`
- [ ] Subscription is created in Stripe Dashboard after purchase
- [ ] User record is updated to PREMIUM tier in database
- [ ] Paywall no longer shows after successful purchase
- [ ] Usage counter shows "Premium" badge instead of limits
- [ ] Restore purchases works for existing subscribers
- [ ] Webhook handles `invoice.paid` and `customer.subscription.deleted` events
- [ ] Test subscription cancellation
- [ ] Verify canceled subscription still has access until period end

## Production Deployment

When ready for production:

1. Replace test publishable key with live key from Stripe
2. Update Price IDs to live price IDs
3. Enable webhook signing verification in backend
4. Set up Stripe webhook endpoint in Stripe Dashboard
5. Test thoroughly with real payment methods (refund immediately)
6. Enable Stripe Radar for fraud prevention
7. Set up email receipts in Stripe settings
8. Configure subscription management portal URL

## Troubleshooting

### "Stripe is not initialized"

Ensure `Stripe.publishableKey` is set in `main.dart` before `runApp()`.

### "Invalid price ID"

Verify the price ID in `purchase_service.dart` matches your Stripe Dashboard.

### Payment sheet doesn't show

Check console for errors. Ensure you're using a valid Setup Intent or Payment Intent.

### Subscription created but user still FREE

Check backend logs. Verify webhook is receiving and processing Stripe events correctly.

## Additional Resources

- [Stripe Flutter SDK Docs](https://stripe.com/docs/payments/accept-a-payment?platform=flutter)
- [Stripe Testing](https://stripe.com/docs/testing)
- [Stripe Webhooks](https://stripe.com/docs/webhooks)
- [Flutter Stripe Package](https://pub.dev/packages/flutter_stripe)

## Current Status

✅ Backend API endpoints created
✅ Purchase service implemented
✅ Repository methods added
✅ Paywall integration complete
⚠️  Stripe SDK initialization needed (see step 1)
⚠️  Payment UI needs to be added (see step 4)
⚠️  Price IDs need to be updated (see step 3)
⚠️  Testing required with real Stripe account

**Next Steps:**
1. Set up Stripe account and get API keys
2. Initialize Stripe SDK in main.dart
3. Add CardField or Payment Sheet to paywall
4. Test purchase flow end-to-end
5. Verify webhook processing
