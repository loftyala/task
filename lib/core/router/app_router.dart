import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/favorites/presentation/providers/favorites_provider.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/products',
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) => _ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductListScreen(),
            ),
          ),
          GoRoute(
            path: '/favorites',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FavoritesScreen(),
            ),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CartScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/products/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(productId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CheckoutScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: '/order-success',
        pageBuilder: (context, state) {
          final orderId = state.extra as String? ?? 'ORD-2024-00000';
          return CustomTransitionPage(
            key: state.pageKey,
            child: OrderSuccessScreen(orderId: orderId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64),
            const SizedBox(height: 16),
            const Text('Page Not Found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/products'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

class _ShellScreen extends ConsumerStatefulWidget {
  final Widget child;
  const _ShellScreen({required this.child});

  @override
  ConsumerState<_ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<_ShellScreen> {
  DateTime? _lastBackPress;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    final lastPress = _lastBackPress;
    if (lastPress == null ||
        now.difference(lastPress) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    await SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);
    final favCount = ref.watch(favoritesCountProvider);
    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex = 0;
    if (location.startsWith('/favorites')) selectedIndex = 1;
    if (location.startsWith('/cart')) selectedIndex = 2;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _onWillPop();
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/products');
              case 1:
                context.go('/favorites');
              case 2:
                context.go('/cart');
            }
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.store_outlined),
              selectedIcon: Icon(Icons.store_rounded),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: favCount > 0,
                label: Text('$favCount'),
                child: const Icon(Icons.favorite_border_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: favCount > 0,
                label: Text('$favCount'),
                child: const Icon(Icons.favorite_rounded),
              ),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              label: 'Cart',
            ),
          ],
        ),
      ),
    );
  }
}
