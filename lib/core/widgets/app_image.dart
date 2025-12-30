import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/services/local_storage_service.dart';

/// A customizable image widget that handles network caching, locale-specific placeholders,
/// and error states for the application.
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
    // 1. Determine the relevant placeholder (EN vs UK)
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String haruAsset = languageCode == 'uk'
        ? 'assets/images/haru_eating_uk.png'
        : 'assets/images/haru_eating_en.png';

    // 2. Determine the alignment type
    final bool isHaru = imagePath.contains('haru_eating') || imagePath.contains('legom');
    final Alignment geometryAlignment = isHaru ? Alignment.topCenter : Alignment.center;

    // 3. Placeholder (for empty or invalid path)
    if (imagePath.trim().isEmpty || imagePath.contains('placehold.co')) {
      return _buildWrapper(
        child: Image.asset(
          haruAsset, // <--- Using dynamic path
          width: width,
          height: height,
          fit: fit,
          alignment: Alignment.topCenter,
        ),
        forceBackground: true,
      );
    }

    // 4. Network Image
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
            fadeInDuration: Duration.zero,
            placeholderFadeInDuration: Duration.zero,
            placeholder: (context, url) => const _LoadingPlaceholder(),
            errorWidget: (context, url, error) => Image.asset(
              haruAsset, // <--- Dynamic path on error
              fit: fit,
              alignment: Alignment.topCenter,
            ),
          ),
          forceBackground: false,
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
              haruAsset, // <--- Dynamic path on error
              fit: fit,
              alignment: Alignment.topCenter,
            ),
          ),
          forceBackground: false,
        );
      }
    }

    // 5. Local Asset
    // If the path explicitly points to the "old" Haru (haru_eating_en),
    // we replace it with the relevant one for the current language.
    // This handles cases where the path might be hardcoded elsewhere in the code.
    String actualPath = imagePath;
    if (imagePath.contains('haru_eating')) {
      actualPath = haruAsset;
    }

    return _buildWrapper(
      child: Image.asset(
        actualPath,
        width: width,
        height: height,
        fit: fit,
        alignment: geometryAlignment,
        errorBuilder: (context, error, stackTrace) => Image.asset(
           haruAsset, // <--- Dynamic path
           fit: fit,
           alignment: Alignment.topCenter,
        ),
      ),
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

/// Internal fallback widget shown while a network image is loading.
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
                  child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.darkCharcoal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
