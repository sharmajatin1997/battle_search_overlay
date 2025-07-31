import 'dart:async';
import 'package:battle_search_overlay/generated/assets.dart';
import 'package:battle_search_overlay/overlays/image_view.dart';
import 'package:flutter/material.dart';

/// A utility class to display a VS-style animated overlay between two users.
///
/// This overlay animates two user avatars sliding in from opposite sides,
/// scaling up with a central "VS" icon between them, and disappears after a short duration.
class VsOverlayUtils {
  /// Displays the animated VS overlay on top of the current screen.
  ///
  /// [context] is required to get the overlay.
  /// [me] and [opponent] should each be a map containing at least 'name' and 'image' keys.
  /// [duration] defines how long the overlay remains visible (default: 4 seconds).
  static void show({
    required BuildContext context,
    required Map<String, dynamic> me,
    required Map<String, dynamic> opponent,
    Duration duration = const Duration(seconds: 4),
  }) {
    late OverlayEntry overlayEntry;

    // Animation controllers for each part of the animation
    final meOffsetController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 800),
    );

    final opponentOffsetController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 800),
    );

    final scaleController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 800),
    );

    // Slide-in from left for "me"
    final meSlide =
        Tween<Offset>(begin: const Offset(-1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: meOffsetController, curve: Curves.easeOut),
        );

    // Slide-in from right for "opponent"
    final opponentSlide =
        Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: opponentOffsetController,
            curve: Curves.easeOut,
          ),
        );

    // Scaling animation for both avatars
    final scaleAnim = CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOut,
    );

    // Create and insert the overlay
    overlayEntry = OverlayEntry(
      builder: (_) {
        return Material(
          color: Colors.black.withAlpha(216),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: meSlide,
                  child: ScaleTransition(
                    scale: scaleAnim,
                    child: _userAvatar(name: me['name'], image: me['image']),
                  ),
                ),
                const SizedBox(width: 16),
                Image.asset(
                  Assets.assetsVs,
                  package: 'battle_search_overlay',
                  height: 60,
                  width: 60,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                SlideTransition(
                  position: opponentSlide,
                  child: ScaleTransition(
                    scale: scaleAnim,
                    child: _userAvatar(
                      name: opponent['name'],
                      image: opponent['image'],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Insert overlay into the widget tree
    Overlay.of(context, rootOverlay: true).insert(overlayEntry);

    // Start animations
    meOffsetController.forward();
    opponentOffsetController.forward();
    scaleController.forward();

    // Auto-remove overlay and dispose controllers after [duration]
    Future.delayed(duration, () {
      overlayEntry.remove();
      meOffsetController.dispose();
      opponentOffsetController.dispose();
      scaleController.dispose();
    });
  }

  /// Builds a styled user avatar widget with an optional image and a name label.
  ///
  /// [name] is the user's display name.
  /// [image] is an optional image URL or asset path shown inside a circular avatar.
  static Widget _userAvatar({required String name, String? image}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: ImageViewUser(image: image),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
