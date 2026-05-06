import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../providers/product_providers.dart';
import '../widgets/robust_image.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _showFullDescription = false;
  int _selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return PopScope(
      canPop: true,
      child: Scaffold(
      body: productAsync.when(
        loading: () => _DetailShimmer(productId: widget.productId),
        error: (e, _) => _DetailError(
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
        data: (product) {
          final isFavorite = ref.watch(
            favoritesProvider.select((ids) => ids.contains(product.id)),
          );
          final isInCart = ref.watch(
            cartProvider.select(
              (items) => items.any((i) => i.product.id == product.id),
            ),
          );
          final cartQty = ref.watch(
            cartProvider.select(
              (items) => items
                  .where((i) => i.product.id == product.id)
                  .fold<int>(0, (_, item) => item.quantity),
            ),
          );

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar.large(
                    expandedHeight: 300,
                    pinned: true,
                    leading: IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/products');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => ref
                            .read(favoritesProvider.notifier)
                            .toggle(product.id),
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(isFavorite),
                            color: isFavorite
                                ? AppColors.error
                                : null,
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: 'product_image_${product.id}',
                        child: RobustImage(
                          url: product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 300,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: AppSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: product.isInStock
                                    ? AppColors.success.withAlpha(30)
                                    : Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withAlpha(30),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              child: Text(
                                product.isInStock
                                    ? AppStrings.inStock
                                    : AppStrings.outOfStock,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: product.isInStock
                                          ? AppColors.success
                                          : Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < product.rating.floor()
                                    ? Icons.star_rounded
                                    : i < product.rating
                                        ? Icons.star_half_rounded
                                        : Icons.star_outline_rounded,
                                color: AppColors.star,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: AppSizes.xs),
                            Text(
                              '${product.rating} (${product.reviewCount} ${AppStrings.reviews})',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                        const SizedBox(height: AppSizes.sm),
                        Chip(
                          label: Text(product.category),
                          labelStyle: Theme.of(context).textTheme.labelSmall,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                        const SizedBox(height: AppSizes.md),
                        _DescriptionSection(
                          description: product.description,
                          showFull: _showFullDescription,
                          onToggle: () => setState(
                            () => _showFullDescription = !_showFullDescription,
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
                        if (isInCart) ...[
                          const SizedBox(height: AppSizes.md),
                          Chip(
                            avatar: const Icon(
                              Icons.shopping_cart_rounded,
                              size: 16,
                            ),
                            label: Text('$cartQty in cart'),
                          ),
                        ],
                        const SizedBox(height: 120),
                      ]),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _StickyBottomBar(
                  product: product,
                  isInCart: isInCart,
                  quantity: _selectedQuantity,
                  formatter: formatter,
                  onQuantityChanged: (val) =>
                      setState(() => _selectedQuantity = val),
                ).animate().slideY(
                      begin: 1,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final String description;
  final bool showFull;
  final VoidCallback onToggle;

  const _DescriptionSection({
    required this.description,
    required this.showFull,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.sm),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              showFull ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            showFull ? AppStrings.showLess : AppStrings.showMore,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StickyBottomBar extends ConsumerWidget {
  final dynamic product;
  final bool isInCart;
  final int quantity;
  final NumberFormat formatter;
  final ValueChanged<int> onQuantityChanged;

  const _StickyBottomBar({
    required this.product,
    required this.isInCart,
    required this.quantity,
    required this.formatter,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Price',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                formatter.format(product.price),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          _QuantitySelector(
            quantity: quantity,
            onChanged: onQuantityChanged,
          ),
          const SizedBox(width: AppSizes.sm),
          _CartActionButton(
            product: product,
            isInCart: isInCart,
            quantity: quantity,
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed:
                quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove_rounded, size: 18),
            visualDensity: VisualDensity.compact,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              '$quantity',
              key: ValueKey(quantity),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () => onChanged(quantity + 1),
            icon: const Icon(Icons.add_rounded, size: 18),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _CartActionButton extends ConsumerWidget {
  final dynamic product;
  final bool isInCart;
  final int quantity;

  const _CartActionButton({
    required this.product,
    required this.isInCart,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: product.isInStock
          ? () {
              if (isInCart) {
                context.go('/cart');
              } else {
                for (var i = 0; i < quantity; i++) {
                  ref.read(cartProvider.notifier).addProduct(product);
                }
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + AppSizes.xs,
        ),
        decoration: BoxDecoration(
          gradient: product.isInStock
              ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                )
              : null,
          color: product.isInStock
              ? null
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Text(
          isInCart ? AppStrings.goToCart : AppStrings.addToCart,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: product.isInStock
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DetailShimmer extends StatelessWidget {
  final String productId;
  const _DetailShimmer({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _DetailError extends StatelessWidget {
  final VoidCallback onRetry;
  const _DetailError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppSizes.md),
          const Text('Error loading product'),
          const SizedBox(height: AppSizes.md),
          ElevatedButton(onPressed: onRetry, child: const Text(AppStrings.retry)),
        ],
      ),
    );
  }
}
