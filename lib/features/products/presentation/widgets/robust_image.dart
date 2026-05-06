import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../products/presentation/widgets/product_shimmer.dart';

class RobustImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const RobustImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  State<RobustImage> createState() => _RobustImageState();
}

class _RobustImageState extends State<RobustImage> {
  int _retryCount = 0;
  Key _imageKey = UniqueKey();

  void _retry() {
    if (_retryCount < 2) {
      setState(() {
        _retryCount++;
        _imageKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      key: _imageKey,
      imageUrl: widget.url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      httpHeaders: const {
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      },
      placeholder: (context, url) => SizedBox(
        width: widget.width,
        height: widget.height,
        child: const ProductImageShimmer(),
      ),
      errorWidget: (context, url, error) {
        if (_retryCount < 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _retry());
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const ProductImageShimmer(),
          );
        }
        return widget.errorWidget ??
            Container(
              width: widget.width,
              height: widget.height,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No image',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
      },
    );
  }
}
