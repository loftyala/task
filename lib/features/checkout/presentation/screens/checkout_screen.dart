import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final orderId = await ref.read(checkoutProvider.notifier).placeOrder();
    if (orderId != null && mounted) {
      context.go('/order-success', extra: orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CheckoutState>(checkoutProvider, (_, next) {
      if (next.status == CheckoutStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final checkoutState = ref.watch(checkoutProvider);
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isLoading = checkoutState.status == CheckoutStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.checkout)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            _SectionCard(
              title: AppStrings.personalInfo,
              children: [
                _FormField(
                  controller: _nameController,
                  label: AppStrings.fullName,
                  icon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim())) {
                      return 'Name can only contain letters and spaces';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.sm),
                _FormField(
                  controller: _emailController,
                  label: AppStrings.email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.sm),
                _FormField(
                  controller: _phoneController,
                  label: AppStrings.phone,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone is required';
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10 || digits.length > 15) {
                      return 'Phone must be 10-15 digits';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            _SectionCard(
              title: AppStrings.deliveryDetails,
              children: [
                _FormField(
                  controller: _addressController,
                  label: AppStrings.deliveryAddress,
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  validator: (v) {
                    if (v == null || v.trim().length < 10) {
                      return 'Address must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.sm),
                _FormField(
                  controller: _cityController,
                  label: AppStrings.city,
                  icon: Icons.location_city_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'City is required';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.sm),
                _FormField(
                  controller: _postalController,
                  label: AppStrings.postalCode,
                  icon: Icons.local_post_office_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Postal code is required';
                    }
                    if (!RegExp(r'^\d{4,6}$').hasMatch(v.trim())) {
                      return 'Enter a valid 4-6 digit postal code';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            _SectionCard(
              title: AppStrings.orderSummary,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${cartItems.length} items',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      formatter.format(total),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(AppStrings.placeOrder),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
