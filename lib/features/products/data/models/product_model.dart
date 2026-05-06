import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
    required String description,
    required String category,
    required double rating,
    required int reviewCount,
    required bool isInStock,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

extension ProductModelX on ProductModel {
  Product toEntity() => Product(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        description: description,
        category: category,
        rating: rating,
        reviewCount: reviewCount,
        isInStock: isInStock,
      );
}
