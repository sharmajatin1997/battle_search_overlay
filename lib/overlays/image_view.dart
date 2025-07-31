import 'package:battle_search_overlay/generated/assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


/// A circular user avatar widget that displays a network image.
///
/// If the image fails to load or is still loading, it falls back to
/// a default placeholder image from the assets.
///
/// This widget ensures all images appear in a circular container.
///
/// Example usage:
/// ```dart
/// ImageViewUser(image: 'https://example.com/avatar.png')
/// ```
class ImageViewUser extends StatelessWidget {
  /// The URL of the user image to load.
  ///
  /// If null or loading fails, a placeholder is shown instead.
  final String? image;

  /// Creates an [ImageViewUser] widget.
  ///
  /// [image] is optional, but if provided, must be a valid image URL.
  const ImageViewUser({super.key, this.image});
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image!,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
          ),
        );
      },
      placeholder: (context, url) {
        return Image.asset(
          Assets.assetsUser,
          package: 'battle_search_overlay',
          height: 60,
          width: 60,
        );
      },
      errorWidget: (context, url, error) {
        return Image.asset(
          Assets.assetsUser,
          package: 'battle_search_overlay',
          height: 60,
          width: 60,
        );
      },
    );
  }
}
