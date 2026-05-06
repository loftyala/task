import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:shopwave/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopwave/features/products/domain/entities/product.dart';

import 'cart_provider_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  late MockBox<String> mockBox;

  const testProduct = Product(
    id: 'p001',
    name: 'Nova Pro Earbuds',
    price: 89.99,
    imageUrl: 'https://example.com/img.jpg',
    description: 'Great earbuds',
    category: 'Audio',
    rating: 4.7,
    reviewCount: 100,
    isInStock: true,
  );

  const testProduct2 = Product(
    id: 'p002',
    name: 'SoundCore Speaker',
    price: 149.99,
    imageUrl: 'https://example.com/img2.jpg',
    description: 'Great speaker',
    category: 'Audio',
    rating: 4.5,
    reviewCount: 200,
    isInStock: true,
  );

  setUp(() {
    mockBox = MockBox<String>();
    when(mockBox.get('cart_items')).thenReturn(null);
    when(mockBox.put(any, any)).thenAnswer((_) async {});
  });

  CartNotifier makeNotifier() {
    return CartNotifier.withBox(mockBox);
  }

  test('1. Initial state is empty list', () {
    final notifier = makeNotifier();
    expect(notifier.state, isEmpty);
  });

  test('2. addProduct adds item with quantity 1', () {
    final notifier = makeNotifier();
    notifier.addProduct(testProduct);
    expect(notifier.state.length, equals(1));
    expect(notifier.state.first.product, equals(testProduct));
    expect(notifier.state.first.quantity, equals(1));
  });

  test('3. addProduct same product increments quantity', () {
    final notifier = makeNotifier();
    notifier.addProduct(testProduct);
    notifier.addProduct(testProduct);
    expect(notifier.state.length, equals(1));
    expect(notifier.state.first.quantity, equals(2));
  });

  test('4. removeProduct removes item completely', () {
    final notifier = makeNotifier();
    notifier.addProduct(testProduct);
    notifier.removeProduct(testProduct.id);
    expect(notifier.state, isEmpty);
  });

  test('5. incrementQuantity increases by 1', () {
    final notifier = makeNotifier();
    notifier.addProduct(testProduct);
    notifier.incrementQuantity(testProduct.id);
    expect(notifier.state.first.quantity, equals(2));
  });

  test('6. decrementQuantity decreases by 1', () {
    final notifier = makeNotifier();
    notifier.addProduct(testProduct);
    notifier.addProduct(testProduct);
    notifier.decrementQuantity(testProduct.id);
    expect(notifier.state.first.quantity, equals(1));
  });

  test('7. decrementQuantity at quantity 1 removes item', () {
    final notifier = makeNotifier();
    notifier.addProduct(testProduct);
    notifier.decrementQuantity(testProduct.id);
    expect(notifier.state, isEmpty);
  });

  test('8. clearCart empties all items', () {
    final notifier = makeNotifier();
    notifier.addProduct(testProduct);
    notifier.addProduct(testProduct2);
    notifier.clearCart();
    expect(notifier.state, isEmpty);
  });

  test('9. totalPrice calculates correctly across multiple items', () {
    final notifier = makeNotifier();
    notifier.addProduct(testProduct);
    notifier.addProduct(testProduct);
    notifier.addProduct(testProduct2);
    // 2 * 89.99 + 1 * 149.99
    expect(notifier.totalPrice, closeTo(329.97, 0.01));
  });

  test('10. isInCart returns true/false correctly', () {
    final notifier = makeNotifier();
    notifier.addProduct(testProduct);
    expect(notifier.isInCart(testProduct.id), isTrue);
    expect(notifier.isInCart(testProduct2.id), isFalse);
  });
}
