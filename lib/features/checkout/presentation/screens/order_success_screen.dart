import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEEF2FF), Colors.white],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                ..._buildConfettiParticles(context),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSuccessIcon(),
                        const SizedBox(height: AppSizes.lg),
                        Text(
                          AppStrings.orderConfirmed,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 400.ms)
                            .slideY(begin: 0.3, end: 0),
                        const SizedBox(height: AppSizes.md),
                        _buildOrderIdChip(context),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          AppStrings.estimatedDelivery,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 900.ms, duration: 400.ms),
                        const SizedBox(height: AppSizes.xxl),
                        _buildButtons(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        size: 80,
        color: AppColors.primary,
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 300.ms);
  }

  Widget _buildOrderIdChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_rounded,
              size: 16, color: AppColors.primary),
          const SizedBox(width: AppSizes.sm),
          Text(
            widget.orderId,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 750.ms, duration: 400.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          delay: 750.ms,
        );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.featureComingSoon)),
              );
            },
            icon: const Icon(Icons.local_shipping_outlined),
            label: const Text(AppStrings.trackOrder),
          ),
        )
            .animate()
            .fadeIn(delay: 1000.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: AppSizes.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/products'),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text(AppStrings.continueShopping),
          ),
        )
            .animate()
            .fadeIn(delay: 1100.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  List<Widget> _buildConfettiParticles(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.error,
      const Color(0xFF8B5CF6),
    ];

    return List.generate(20, (index) {
      final x = (index * 53 % 100) / 100.0 * size.width;
      final delay = index * 80;
      final color = colors[index % colors.length];
      final shapeIndex = index % 3;

      return Positioned(
        left: x,
        top: -20,
        child: Container(
          width: shapeIndex == 0 ? 8 : 12,
          height: shapeIndex == 0 ? 8 : 6,
          decoration: BoxDecoration(
            color: color.withAlpha(180),
            shape: shapeIndex == 0 ? BoxShape.circle : BoxShape.rectangle,
            borderRadius:
                shapeIndex == 1 ? BorderRadius.circular(2) : null,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .moveY(
              begin: 0,
              end: size.height + 40,
              duration: Duration(milliseconds: 2500 + delay),
              delay: Duration(milliseconds: delay),
              curve: Curves.easeIn,
            )
            .fadeIn(duration: 200.ms)
            .rotate(
              begin: 0,
              end: index % 2 == 0 ? 1 : -1,
              duration: Duration(milliseconds: 2500 + delay),
            ),
      );
    });
  }
}
