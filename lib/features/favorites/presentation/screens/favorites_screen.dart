import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../products/presentation/widgets/robust_image.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favProducts = ref.watch(favoriteProductsProvider);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myFavorites)),
      body: favProducts.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading favorites')),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withAlpha(80),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    AppStrings.noFavorites,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    AppStrings.noFavoritesSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xl),
                  ElevatedButton(
                    onPressed: () => context.go('/products'),
                    child: const Text(AppStrings.startShopping),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, index) {
              final product = products[index];
              final isInCart = ref.watch(
                cartProvider.select(
                  (items) => items.any((i) => i.product.id == product.id),
                ),
              );
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/products/${product.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSm),
                          child: RobustImage(
                            url: product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSizes.xs),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 14, color: AppColors.star),
                                  const SizedBox(width: 2),
                                  Text(
                                    product.rating.toStringAsFixed(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.xs),
                              Text(
                                formatter.format(product.price),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () => ref
                                  .read(favoritesProvider.notifier)
                                  .toggle(product.id),
                              icon: const Icon(
                                Icons.favorite_rounded,
                                color: AppColors.error,
                              ),
                            ),
                            IconButton(
                              onPressed: product.isInStock
                                  ? () => ref
                                      .read(cartProvider.notifier)
                                      .addProduct(product)
                                  : null,
                              icon: Icon(
                                isInCart
                                    ? Icons.shopping_cart_rounded
                                    : Icons.add_shopping_cart_rounded,
                                color: isInCart
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(
                    duration: 300.ms,
                    delay: Duration(milliseconds: index * 50),
                  )
                  .slideX(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }
}
