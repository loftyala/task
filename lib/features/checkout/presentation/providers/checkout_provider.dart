import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

enum CheckoutStatus { idle, loading, success, error }

class CheckoutState {
  final CheckoutStatus status;
  final String? orderId;
  final String? errorMessage;

  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.orderId,
    this.errorMessage,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? orderId,
    String? errorMessage,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref _ref;

  CheckoutNotifier(this._ref) : super(const CheckoutState());

  Future<String?> placeOrder() async {
    state = state.copyWith(status: CheckoutStatus.loading);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      final orderId = _generateOrderId();
      _ref.read(cartProvider.notifier).clearCart();
      state = state.copyWith(status: CheckoutStatus.success, orderId: orderId);
      return orderId;
    } catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: 'Failed to place order. Please try again.',
      );
      return null;
    }
  }

  void reset() {
    state = const CheckoutState();
  }

  String _generateOrderId() {
    final rand = Random();
    final num = rand.nextInt(99999).toString().padLeft(5, '0');
    return 'ORD-2024-$num';
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});
