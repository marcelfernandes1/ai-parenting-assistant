/// Purchase service for handling Stripe subscription purchases.
/// Integrates with flutter_stripe package and backend subscription endpoints.
library;

import 'package:flutter_stripe/flutter_stripe.dart';
import 'subscription_repository.dart';

/// Service class for managing subscription purchases via Stripe.
/// Handles payment method creation and backend subscription creation.
class PurchaseService {
  final SubscriptionRepository _subscriptionRepository;

  /// Stripe Price IDs for different subscription tiers.
  /// These should match the Price IDs created in your Stripe Dashboard.
  /// TODO: Replace with actual Stripe price IDs from your Stripe account.
  static const String monthlyPriceId = 'price_monthly_premium';
  static const String yearlyPriceId = 'price_yearly_premium';

  PurchaseService(this._subscriptionRepository);

  /// Purchases a subscription using Stripe CardField.
  ///
  /// Flow:
  /// 1. Collect card details from user (via CardField widget)
  /// 2. Create payment method with Stripe
  /// 3. Send payment method ID + price ID to backend
  /// 4. Backend creates subscription and charges card
  /// 5. Returns subscription details
  ///
  /// Parameters:
  /// - priceId: Stripe price ID (monthly or yearly subscription)
  ///
  /// Returns: Map containing subscription details on success
  /// Throws: Exception on purchase or verification errors
  Future<Map<String, dynamic>> purchaseSubscription({
    required String priceId,
  }) async {
    try {
      // Step 1: Create payment method from card field
      // Note: CardField must be added to UI before calling this
      // The card details are collected in the CardField widget
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // Step 2: Send payment method ID to backend to create subscription
      final subscriptionResult = await _subscriptionRepository.createSubscription(
        paymentMethodId: paymentMethod.id,
        priceId: priceId,
      );

      // Step 3: Handle client secret if payment requires confirmation
      final clientSecret = subscriptionResult['clientSecret'] as String?;
      if (clientSecret != null) {
        // Payment requires additional authentication (3D Secure)
        final result = await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
        );

        if (result.status != PaymentIntentsStatus.Succeeded) {
          throw Exception('Payment authentication failed');
        }
      }

      return subscriptionResult;
    } on StripeException catch (e) {
      // Handle Stripe-specific errors
      final message = e.error.localizedMessage ?? e.error.message ?? 'Payment failed';
      throw Exception('Stripe error: $message');
    } catch (e) {
      // Handle other errors (network, backend, etc.)
      throw Exception('Purchase failed: ${e.toString()}');
    }
  }

  /// Restores previous purchases by fetching subscription status from backend.
  /// Since Stripe manages subscriptions server-side, we just refresh the status.
  ///
  /// Returns: true if active premium subscription found, false otherwise
  /// Throws: Exception on backend errors
  Future<bool> restorePurchases() async {
    try {
      // Fetch current subscription status from backend
      final subscriptionStatus = await _subscriptionRepository.getSubscriptionStatus();

      // Check if user has active premium subscription
      final isPremium = subscriptionStatus.isPremium;
      final isActive = subscriptionStatus.isActive;

      return isPremium && isActive;
    } catch (e) {
      throw Exception('Failed to restore purchases: ${e.toString()}');
    }
  }

  /// Cancels the current active subscription.
  /// Subscription remains active until end of billing period.
  ///
  /// Returns: DateTime when subscription will end (null if no cancel date)
  /// Throws: Exception if no active subscription or cancellation fails
  Future<DateTime?> cancelSubscription() async {
    try {
      // Call backend to cancel subscription
      final result = await _subscriptionRepository.cancelSubscription();

      // Parse cancellation date
      final cancelAtString = result['cancelAt'] as String?;
      if (cancelAtString != null) {
        return DateTime.parse(cancelAtString);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to cancel subscription: ${e.toString()}');
    }
  }
}
