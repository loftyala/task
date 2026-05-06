import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:shopwave/core/errors/exceptions.dart';
import 'package:shopwave/core/errors/failures.dart';
import 'package:shopwave/features/products/data/datasources/product_local_datasource.dart';
import 'package:shopwave/features/products/data/models/product_model.dart';
import 'package:shopwave/features/products/data/repositories/product_repository_impl.dart';
import 'package:shopwave/features/products/domain/entities/product.dart';

import 'product_repository_test.mocks.dart';

@GenerateMocks([IProductLocalDatasource, IProductRemoteDatasource])
void main() {
  late MockIProductLocalDatasource mockLocal;
  late MockIProductRemoteDatasource mockRemote;
  late ProductRepositoryImpl repo;

  const testModel = ProductModel(
    id: 'p001',
    name: 'Nova Pro Earbuds',
    price: 89.99,
    imageUrl: 'https://example.com/img.jpg',
    description: 'Great earbuds with noise cancellation',
    category: 'Audio',
    rating: 4.7,
    reviewCount: 100,
    isInStock: true,
  );

  const testModel2 = ProductModel(
    id: 'p002',
    name: 'SoundCore Speaker',
    price: 149.99,
    imageUrl: 'https://example.com/img2.jpg',
    description: 'Portable bluetooth speaker',
    category: 'Audio',
    rating: 4.5,
    reviewCount: 200,
    isInStock: true,
  );

  setUp(() {
    mockLocal = MockIProductLocalDatasource();
    mockRemote = MockIProductRemoteDatasource();
    repo = ProductRepositoryImpl(remote: mockRemote, local: mockLocal);
  });

  group('getProducts', () {
    test('1. Returns Right(products) when remote loads successfully', () async {
      when(mockRemote.getProducts()).thenAnswer((_) async => [testModel]);
      when(mockLocal.cacheProducts(any)).thenAnswer((_) async {});

      final result = await repo.getProducts();

      expect(result.isRight(), isTrue);
      final products = (result as Right<Failure, List<Product>>).value;
      expect(products.length, equals(1));
      expect(products.first.id, equals('p001'));
    });

    test('2. Returns Right(cachedProducts) when remote fails but cache has data',
        () async {
      when(mockRemote.getProducts()).thenThrow(const ServerException());
      when(mockLocal.getCachedProducts())
          .thenAnswer((_) async => [testModel, testModel2]);

      final result = await repo.getProducts();

      expect(result.isRight(), isTrue);
      final products = (result as Right<Failure, List<Product>>).value;
      expect(products.length, equals(2));
    });

    test('3. Returns Left(CacheFailure) when both remote and cache fail',
        () async {
      when(mockRemote.getProducts()).thenThrow(const ServerException());
      when(mockLocal.getCachedProducts())
          .thenThrow(const CacheException('No cache'));

      final result = await repo.getProducts();

      expect(result.isLeft(), isTrue);
      final failure = (result as Left<Failure, List<Product>>).value;
      expect(failure, isA<CacheFailure>());
    });
  });

  group('searchProducts', () {
    setUp(() {
      when(mockRemote.getProducts())
          .thenAnswer((_) async => [testModel, testModel2]);
      when(mockLocal.cacheProducts(any)).thenAnswer((_) async {});
    });

    test('4. searchProducts returns matching products (case-insensitive)',
        () async {
      final result = await repo.searchProducts('earbuds');
      expect(result.isRight(), isTrue);
      final products = (result as Right<Failure, List<Product>>).value;
      expect(products.length, equals(1));
      expect(products.first.id, equals('p001'));
    });

    test('5. searchProducts returns empty list when no matches', () async {
      final result = await repo.searchProducts('xyz123notfound');
      expect(result.isRight(), isTrue);
      final products = (result as Right<Failure, List<Product>>).value;
      expect(products, isEmpty);
    });
  });

  group('getProductById', () {
    setUp(() {
      when(mockRemote.getProducts())
          .thenAnswer((_) async => [testModel, testModel2]);
      when(mockLocal.cacheProducts(any)).thenAnswer((_) async {});
    });

    test('6. getProductById returns correct product', () async {
      final result = await repo.getProductById('p001');
      expect(result.isRight(), isTrue);
      final product = (result as Right<Failure, Product>).value;
      expect(product.id, equals('p001'));
      expect(product.name, equals('Nova Pro Earbuds'));
    });

    test('7. getProductById returns Left(NotFoundFailure) for unknown id',
        () async {
      final result = await repo.getProductById('unknown_id');
      expect(result.isLeft(), isTrue);
      final failure = (result as Left<Failure, Product>).value;
      expect(failure, isA<NotFoundFailure>());
    });
  });
}
