import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/services/local_storage_service.dart';

class AppImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // 1. DETERMINE IMAGE TYPE
    // If it's our placeholder (Haru), we want custom alignment (TopCenter)
    // If it's any other image (food) - Center
    final isHaru = imagePath.contains('haru_eating');
    final Alignment geometryAlignment = isHaru
        ? Alignment.topCenter
        : Alignment.center;

    // 2. NETWORK (HTTP)
    if (imagePath.startsWith('http')) {
      final useCache = LocalStorageService().isCacheEnabled;
      final int cacheWidth = width != null && width!.isFinite
          ? (width! * 2).toInt()
          : 800;

      if (useCache) {
        return _buildWrapper(
          child: CachedNetworkImage(
            imageUrl: imagePath,
            width: width,
            height: height,
            fit: fit,
            alignment: geometryAlignment,
            memCacheWidth: cacheWidth,

            // No fade-in to avoid breaking Hero transitions
            fadeInDuration: Duration.zero,
            placeholderFadeInDuration: Duration.zero,

            // Loader (Legoshi) only for network
            placeholder: (context, url) => const _LoadingPlaceholder(),

            // If network load fails -> show local Haru
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/haru_eating_en.png',
              fit: fit,
              alignment: Alignment.topCenter,
            ),
          ),
        );
      } else {
        return _buildWrapper(
          child: Image.network(
            imagePath,
            width: width,
            height: height,
            fit: fit,
            alignment: geometryAlignment,
            cacheWidth: cacheWidth,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const _LoadingPlaceholder();
            },
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/haru_eating_en.png',
              fit: fit,
              alignment: Alignment.topCenter,
            ),
          ),
        );
      }
    }

    // 3. LOCAL ASSET (Haru or anything else from assets folder)
    // This loads instantly. No spinners.
    return _buildWrapper(
      child: Image.asset(
        // If an empty string somehow arrives (old data) - fallback to Haru
        imagePath.isEmpty ? 'assets/images/haru_eating_en.png' : imagePath,
        width: width,
        height: height,
        fit: fit,
        alignment: geometryAlignment,
        // If file not found
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/haru_eating_en.png',
          fit: fit,
          alignment: Alignment.topCenter,
        ),
      ),
      // Apply background only for Haru to look like a placeholder
      forceBackground: isHaru,
    );
  }

  Widget _buildWrapper({required Widget child, bool forceBackground = false}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        color: forceBackground ? const Color(0xFFEFEFEF) : null,
        child: child,
      ),
    );
  }
}

// Loading (Legoshi)
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/images/legoshi_loading.png', height: 250),
              Transform.translate(
                offset: const Offset(92, 0),
                child: const SizedBox(
                  width: 35,
                  height: 35,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppTheme.darkCharcoal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
