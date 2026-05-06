import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';
import '../widgets/product_shimmer.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = ref.watch(filteredProductsProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final favCount = ref.watch(favoritesCountProvider);
    final isFromCache = ref.watch(isFromCacheProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          try {
            await ref.read(productsProvider.future);
          } catch (_) {}
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text(AppStrings.appName),
              floating: true,
              snap: true,
              actions: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () => context.go('/favorites'),
                      icon: const Icon(Icons.favorite_border_rounded),
                    ),
                    if (favCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: _Badge(count: favCount),
                      ),
                  ],
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () => context.go('/cart'),
                      icon: const Icon(Icons.shopping_cart_outlined),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: _Badge(count: cartCount),
                      ),
                  ],
                ),
                const SizedBox(width: AppSizes.xs),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  AppSizes.sm,
                  AppSizes.md,
                  AppSizes.sm,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) =>
                      ref.read(searchQueryProvider.notifier).state = val,
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchHint,
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: _SearchClearButton(),
                  ),
                ),
              ),
            ),
            if (isFromCache)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          AppStrings.offlineMode,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(top: AppSizes.sm)),
            filteredProducts.when(
              loading: () => const ShimmerProductGrid(),
              error: (error, _) => SliverFillRemaining(
                child: _ErrorState(
                  onRetry: () => ref.invalidate(productsProvider),
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const SliverFillRemaining(child: _EmptyState());
                }
                // Compute aspect ratio from actual available width so the card
                // is always tall enough to show a 2-line product name + price.
                final cardWidth =
                    (MediaQuery.sizeOf(context).width - AppSizes.md * 2 - AppSizes.sm) / 2;
                const cardHeight = AppSizes.productCardImageHeight + 114.0;
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSizes.sm,
                      crossAxisSpacing: AppSizes.sm,
                      childAspectRatio: cardWidth / cardHeight,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(
                        key: ValueKey(products[index].id),
                        product: products[index],
                        animationIndex: index,
                        onTap: () =>
                            context.push('/products/${products[index].id}'),
                      ),
                      childCount: products.length,
                    ),
                  ),
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: AppSizes.lg)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 9 ? '9+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SearchClearButton extends ConsumerWidget {
  const _SearchClearButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return const SizedBox.shrink();
    return IconButton(
      onPressed: () {
        ref.read(searchQueryProvider.notifier).state = '';
      },
      icon: const Icon(Icons.close_rounded),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            AppStrings.noProductsFound,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            AppStrings.tryDifferentKeyword,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              AppStrings.errorLoadingProducts,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
