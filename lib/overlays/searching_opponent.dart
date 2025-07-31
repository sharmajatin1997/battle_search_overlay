import 'dart:async';
import 'package:battle_search_overlay/generated/assets.dart';
import 'package:battle_search_overlay/overlays/image_view.dart';
import 'package:flutter/material.dart';

/// A widget that displays a searching overlay UI while
/// trying to find an opponent for a VS battle.
///
/// Shows animated user avatars and a VS icon, and loops through
/// a list of users until timeout or cancel.
class SearchingOpponent extends StatefulWidget {
  /// Current user data containing at least `name` and `image` keys.
  final Map<String, dynamic> me;

  /// List of users to loop through while searching.
  final List<Map<String, dynamic>> users;

  /// Called when the user taps the cancel button.
  final VoidCallback onCancel;

  /// Called when the search times out after [durationInSeconds].
  final VoidCallback onTimeout;

  /// Duration to wait before timing out the search.
  final int durationInSeconds;

  /// Creates the searching overlay screen.
  const SearchingOpponent({
    required this.me,
    required this.users,
    required this.onCancel,
    required this.onTimeout,
    this.durationInSeconds = 10,
    super.key,
  });

  @override
  State<SearchingOpponent> createState() => _SearchingOpponentScreenState();
}

class _SearchingOpponentScreenState extends State<SearchingOpponent>
    with TickerProviderStateMixin {
  late final List<Map<String, dynamic>> users;
  late final String image;
  late final String myName;

  int currentIndex = 0;
  Timer? _loopTimer;
  Timer? _timeoutTimer;
  bool showFadeItems = false;

  late AnimationController _rewardController;

  @override
  void initState() {
    super.initState();

    users = widget.users;
    image = widget.me['image'];
    myName = widget.me['name'];

    _rewardController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    startMatching();
    startTimeoutCountdown();
  }

  /// Starts a countdown timer that calls [widget.onTimeout]
  /// after [widget.durationInSeconds].
  void startTimeoutCountdown() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(Duration(seconds: widget.durationInSeconds), () {
      if (mounted) {
        widget.onTimeout();
      }
    });
  }

  /// Starts the avatar rotation and enables fade-in animation.
  void startMatching() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => showFadeItems = true);
    });

    _loopTimer?.cancel();
    _loopTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        currentIndex = (currentIndex + 1) % users.length;
      });
    });
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _timeoutTimer?.cancel();
    _rewardController.dispose();
    super.dispose();
  }

  /// Builds a circular user avatar with a name label underneath.
  ///
  /// [name] is required, and [image] is optional.
  Widget userAvatar({Key? key, required String name, String? image}) {
    return Column(
      key: key,
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = users[currentIndex];

    return Material(
      color: Colors.black.withAlpha(216),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatars + VS Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              userAvatar(name: myName, image: image),
              const SizedBox(width: 16),
              AnimatedOpacity(
                opacity: showFadeItems ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Image.asset(
                  Assets.assetsVs,
                  package: 'battle_search_overlay',
                  height: 60,
                  width: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: userAvatar(
                  key: ValueKey(currentUser['name']),
                  name: currentUser['name'],
                  image: currentUser['image'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Cancel Button
          AnimatedOpacity(
            opacity: showFadeItems ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            child: ElevatedButton.icon(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text(
                "Cancel Search",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
