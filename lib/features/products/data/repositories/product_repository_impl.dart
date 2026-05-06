import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

final class ProductRepositoryImpl implements IProductRepository {
  final IProductRemoteDatasource _remote;
  final IProductLocalDatasource _local;
  bool _lastLoadedFromCache = false;

  bool get lastLoadedFromCache => _lastLoadedFromCache;

  ProductRepositoryImpl({
    required IProductRemoteDatasource remote,
    required IProductLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    _lastLoadedFromCache = false;
    try {
      final models = await _remote.getProducts();
      await _local.cacheProducts(models);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException {
      _lastLoadedFromCache = true;
      return _loadFromCache();
    } catch (_) {
      _lastLoadedFromCache = true;
      return _loadFromCache();
    }
  }

  Future<Either<Failure, List<Product>>> _loadFromCache() async {
    try {
      final cached = await _local.getCachedProducts();
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    final result = await getProducts();
    return result.fold(
      (failure) => Left(failure),
      (products) {
        try {
          final product = products.firstWhere((p) => p.id == id);
          return Right(product);
        } catch (_) {
          return const Left(NotFoundFailure());
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    final result = await getProducts();
    return result.fold(
      (failure) => Left(failure),
      (products) {
        final lower = query.toLowerCase();
        final filtered = products
            .where(
              (p) =>
                  p.name.toLowerCase().contains(lower) ||
                  p.description.toLowerCase().contains(lower),
            )
            .toList();
        return Right(filtered);
      },
    );
  }
}

