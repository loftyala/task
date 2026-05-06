import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/entities/product.dart';
import 'robust_image.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final int animationIndex;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select((ids) => ids.contains(product.id)),
    );
    final isInCart = ref.watch(
      cartProvider.select((items) => items.any((i) => i.product.id == product.id)),
    );
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'product_image_${product.id}',
                  child: RobustImage(
                    url: product.imageUrl,
                    height: AppSizes.productCardImageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: AppSizes.sm,
                  right: AppSizes.sm,
                  child: _FavoriteButton(
                    productId: product.id,
                    isFavorite: isFavorite,
                  ),
                ),
                if (!product.isInStock)
                  Positioned(
                    top: AppSizes.sm,
                    left: AppSizes.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        AppStrings.outOfStock,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onError,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.sm),
                child: Stack(
                  children: [
                    // Name + rating flow from the top.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Price + cart button always anchored to the bottom.
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatter.format(product.price),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _AddToCartButton(
                            product: product,
                            isInCart: isInCart,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: animationIndex * 60),
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
          delay: Duration(milliseconds: animationIndex * 60),
          curve: Curves.easeOut,
        );
  }
}

class _FavoriteButton extends ConsumerWidget {
  final String productId;
  final bool isFavorite;

  const _FavoriteButton({required this.productId, required this.isFavorite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(favoritesProvider.notifier).toggle(productId),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withAlpha(230),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 18,
          color: isFavorite ? AppColors.error : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      )
          .animate(target: isFavorite ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
            duration: 150.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1, 1),
            duration: 100.ms,
          ),
    );
  }
}

class _AddToCartButton extends ConsumerWidget {
  final Product product;
  final bool isInCart;

  const _AddToCartButton({required this.product, required this.isInCart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: product.isInStock
          ? () => ref.read(cartProvider.notifier).addProduct(product)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isInCart
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Icon(
          isInCart ? Icons.shopping_cart_rounded : Icons.add_shopping_cart_rounded,
          size: 16,
          color: isInCart
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
