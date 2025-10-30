/// Widget tests for EmptyState components
/// Tests rendering, layout, and user interactions
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_parenting_assistant/shared/widgets/empty_state.dart';

void main() {
  group('EmptyState Widget', () {
    testWidgets('should display icon, title, and message', (tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'There are no items to display',
            ),
          ),
        ),
      );

      // Verify icon is displayed
      expect(find.byIcon(Icons.inbox), findsOneWidget);

      // Verify title is displayed
      expect(find.text('No Items'), findsOneWidget);

      // Verify message is displayed
      expect(find.text('There are no items to display'), findsOneWidget);
    });

    testWidgets('should display action button when provided', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'There are no items',
              actionText: 'Add Item',
              onAction: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify action button is displayed
      expect(find.text('Add Item'), findsOneWidget);

      // Tap the button
      await tester.tap(find.text('Add Item'));
      await tester.pump();

      // Verify callback was called
      expect(buttonPressed, true);
    });

    testWidgets('should not display action button when not provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'There are no items',
            ),
          ),
        ),
      );

      // Verify no FilledButton is present
      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('EmptyChatState Widget', () {
    testWidgets('should display chat empty state message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyChatState(),
          ),
        ),
      );

      // Verify chat icon
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);

      // Verify chat-specific message
      expect(find.textContaining('Conversation'), findsOneWidget);
    });
  });

  group('ErrorState Widget', () {
    testWidgets('should display error message and retry button', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Failed to load data',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Verify title
      expect(find.text('Oops!'), findsOneWidget);

      // Verify error message
      expect(find.text('Failed to load data'), findsOneWidget);

      // Verify retry button
      expect(find.text('Try Again'), findsOneWidget);

      // Tap retry
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryPressed, true);
    });
  });
}
