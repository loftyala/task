import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:shopwave/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopwave/features/cart/presentation/screens/cart_screen.dart';
import 'package:shopwave/features/checkout/presentation/screens/checkout_screen.dart';

// Minimal in-memory Box — satisfies CartNotifier.withBox() without Hive init.
class _FakeBox extends Fake implements Box<String> {
  final Map<dynamic, String> _store = {};

  @override
  String? get(dynamic key, {String? defaultValue}) => _store[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, String value) async => _store[key] = value;

  @override
  bool get isOpen => true;
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      cartProvider.overrideWith((ref) => CartNotifier.withBox(_FakeBox())),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('CartScreen widget', () {
    testWidgets('shows empty-cart message when cart has no items', (tester) async {
      await tester.pumpWidget(_wrap(const CartScreen()));
      await tester.pump();

      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('shows Start Shopping button on empty cart', (tester) async {
      await tester.pumpWidget(_wrap(const CartScreen()));
      await tester.pump();

      expect(find.text('Start Shopping'), findsOneWidget);
    });
  });

  group('CheckoutScreen form validation', () {
    // Use a tall viewport so all form fields + the Place Order button are
    // rendered without scrolling (ListView lazily removes off-screen widgets).
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('renders personal-info fields', (tester) async {
      await tester.pumpWidget(_wrap(const CheckoutScreen()));
      await tester.pump();

      expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Phone'), findsOneWidget);
    });

    testWidgets('shows name validation error when form submitted empty',
        (tester) async {
      // Enlarge viewport so the entire form fits without scrolling.
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const CheckoutScreen()));
      await tester.pump();

      await tester.tap(find.text('Place Order'));
      await tester.pump();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('shows email validation error for invalid format', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const CheckoutScreen()));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'bad-email',
      );
      await tester.tap(find.text('Place Order'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });
  });
}
