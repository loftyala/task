import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../products/presentation/widgets/robust_image.dart';
import '../providers/cart_provider.dart';
import '../../domain/cart_item.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final shipping = total > 50 ? 0.0 : 4.99;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(AppStrings.myCart),
            if (items.isNotEmpty) ...[
              const SizedBox(width: AppSizes.sm),
              Chip(
                label: Text('${items.length}'),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
      body: items.isEmpty
          ? _EmptyCart(onShop: () => context.go('/products'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.sm),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _CartItemTile(
                        key: ValueKey(item.product.id),
                        item: item,
                        formatter: formatter,
                      );
                    },
                  ),
                ),
                _OrderSummary(
                  subtotal: total,
                  shipping: shipping,
                  formatter: formatter,
                  onCheckout: items.isNotEmpty
                      ? () => context.push('/checkout')
                      : null,
                ),
              ],
            ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;
  final NumberFormat formatter;

  const _CartItemTile({super.key, required this.item, required this.formatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          ref.read(cartProvider.notifier).removeProduct(item.product.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: RobustImage(
                  url: item.product.imageUrl,
                  width: AppSizes.thumbnailSize,
                  height: AppSizes.thumbnailSize,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      formatter.format(item.product.price),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              _QuantityControl(productId: item.product.id, quantity: item.quantity),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityControl extends ConsumerWidget {
  final String productId;
  final int quantity;

  const _QuantityControl({required this.productId, required this.quantity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          onPressed: () =>
              ref.read(cartProvider.notifier).decrementQuantity(productId),
          icon: Icon(
            quantity <= 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            size: 20,
          ),
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
          onPressed: () =>
              ref.read(cartProvider.notifier).incrementQuantity(productId),
          icon: const Icon(Icons.add_rounded, size: 20),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final NumberFormat formatter;
  final VoidCallback? onCheckout;

  const _OrderSummary({
    required this.subtotal,
    required this.shipping,
    required this.formatter,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final total = subtotal + shipping;

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
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.subtotal,
                  style: Theme.of(context).textTheme.bodyMedium),
              Text(formatter.format(subtotal),
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.shipping,
                  style: Theme.of(context).textTheme.bodyMedium),
              Text(
                shipping == 0 ? AppStrings.freeShipping : formatter.format(shipping),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: shipping == 0 ? Colors.green : null,
                  fontWeight: shipping == 0 ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
          const Divider(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.total,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                formatter.format(total),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              child: const Text(AppStrings.proceedToCheckout),
            ),
          ),
          if (subtotal < 50 && subtotal > 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.sm),
              child: Text(
                AppStrings.freeShippingThreshold,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onShop;
  const _EmptyCart({required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 96,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(80),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              AppStrings.cartEmpty,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              AppStrings.cartEmptySubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton.icon(
              onPressed: onShop,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text(AppStrings.startShopping),
            ),
          ],
        ),
      ),
    );
  }
}
