import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:shopwave/features/favorites/presentation/providers/favorites_provider.dart';

import 'favorites_provider_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  late MockBox<String> mockBox;

  setUp(() {
    mockBox = MockBox<String>();
    when(mockBox.get('favorite_ids')).thenReturn(null);
    when(mockBox.put(any, any)).thenAnswer((_) async {});
  });

  FavoritesNotifier makeNotifier() {
    return FavoritesNotifier.withBox(mockBox);
  }

  test('1. Initial state loads from Hive (empty box)', () {
    final notifier = makeNotifier();
    expect(notifier.state, isEmpty);
  });

  test('2. toggle adds ID to favorites when not present', () {
    final notifier = makeNotifier();
    notifier.toggle('p001');
    expect(notifier.state, contains('p001'));
  });

  test('3. toggle removes ID from favorites when present', () {
    final notifier = makeNotifier();
    notifier.toggle('p001');
    notifier.toggle('p001');
    expect(notifier.state, isNot(contains('p001')));
  });

  test('4. isFavorite returns true for added ID', () {
    final notifier = makeNotifier();
    notifier.toggle('p001');
    expect(notifier.isFavorite('p001'), isTrue);
  });

  test('5. isFavorite returns false for unknown ID', () {
    final notifier = makeNotifier();
    expect(notifier.isFavorite('unknown'), isFalse);
  });

  test('6. Multiple toggles leave state consistent', () {
    final notifier = makeNotifier();
    notifier.toggle('p001');
    notifier.toggle('p002');
    notifier.toggle('p001');
    expect(notifier.state, contains('p002'));
    expect(notifier.state, isNot(contains('p001')));
    expect(notifier.state.length, equals(1));
  });

  test('7. Persists to Hive on every toggle', () {
    final notifier = makeNotifier();
    notifier.toggle('p001');
    verify(mockBox.put('favorite_ids', any)).called(1);
    notifier.toggle('p002');
    verify(mockBox.put('favorite_ids', any)).called(1);
  });
}
