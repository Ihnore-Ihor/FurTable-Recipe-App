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
    // 1. If path is empty - show "No Image" placeholder
    if (imagePath.isEmpty) {
      return _buildContainer(child: const _ErrorPlaceholder(message: 'No Image'));
    }

    // 2. If it is URL (Firebase/Supabase)
    if (imagePath.startsWith('http')) {
      final useCache = LocalStorageService().isCacheEnabled;

      // Determine optimal size for memory caching.
      // If we know width, take it * 2 (for Retina),
      // otherwise default to 600px (good quality/performance balance).
      final int? cacheWidth = width != null && width!.isFinite
          ? (width! * 2).toInt()
          : 600;

      if (useCache) {
        return _buildContainer(
          child: CachedNetworkImage(
            imageUrl: imagePath,
            width: width,
            height: height,
            fit: fit,

            // --- OPTIMIZATION ---
            // Tell Flutter: "Decode image to memory at max 600px".
            // Drastically reduces CPU and RAM usage.
            memCacheWidth: cacheWidth,

            // Animation: remove delay for Hero, but use our loader
            fadeInDuration: Duration.zero,
            placeholderFadeInDuration: Duration.zero,
            
            // CUSTOM LOADER (Legoshi)
            placeholder: (context, url) => const _LoadingPlaceholder(),
            
            // CUSTOM ERROR PLACEHOLDER (Gohin)
            errorWidget: (context, url, error) => const _ErrorPlaceholder(),
          ),
        );
      } else {
        // Without cache (Image.network)
        return _buildContainer(
          child: Image.network(
            imagePath,
            width: width,
            height: height,
            fit: fit,
            // Image.network also has cacheWidth
            cacheWidth: cacheWidth,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const _LoadingPlaceholder();
            },
            errorBuilder: (context, error, stackTrace) => const _ErrorPlaceholder(),
          ),
        );
      }
    }

    // 3. If it is local asset
    return _buildContainer(
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const _ErrorPlaceholder(),
      ),
    );
  }

  // Wrapper for rounding corners
  Widget _buildContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}

// --- LOADING WIDGET (LEGOSHI) ---
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5), // Background like LoadingScreen
      child: FittedBox( // Scales content to fit card size
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding to avoid sticking to edges
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Legoshi Image
              Image.asset(
                'assets/images/legoshi_loading.png', 
                height: 250,
                opacity: const AlwaysStoppedAnimation(0.5), // Slightly transparent for background
              ),
              // Spinner (offset, like in your design)
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

// --- ERROR/NO PHOTO WIDGET (GOHIN) ---
class _ErrorPlaceholder extends StatelessWidget {
  final String message;
  const _ErrorPlaceholder({this.message = 'No Image'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Opacity(
              opacity: 0.3, // Pale to avoid distraction
              child: Image.asset(
                'assets/images/gohin_empty.png', // Using panda
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.mediumGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
