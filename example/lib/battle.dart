import 'package:battle_search_overlay/battle_search_overlay.dart';
import 'package:flutter/material.dart';

class Battle extends StatefulWidget {
  const Battle({super.key});

  @override
  State<Battle> createState() => _BattleState();
}

class _BattleState extends State<Battle> {
  bool _showSearching = false;

  final me = {
    'name': 'You',
    'image': 'https://media.tenor.com/zt-PcMT2y3kAAAAe/war-hrithik-roshan.png',
  };

  final users = List.generate(20, (index) {
    return {
      'name': 'User ${index + 1}',
      'image':
          'https://images.hindustantimes.com/rf/image_size_640x362/HT/p1/2015/04/03/Incoming/Pictures/1333507_Wallpaper2.jpg',
    };
  });

  void _toggleSearching() {
    setState(() {
      _showSearching = !_showSearching;
    });
  }

  void _handleTimeout() async {
    // Step 1: Hide the overlay
    setState(() => _showSearching = false);
    if (!mounted) return;
    // Below mounted you can use your methods or Functionality
    // if data gets you call this
    VsOverlayUtils.show(
      context: context,
      me: me,
      opponent: {
        'name': 'Nitish Nanda',
        'image':
            'https://images.hindustantimes.com/rf/image_size_640x362/HT/p1/2015/04/03/Incoming/Pictures/1333507_Wallpaper2.jpg',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text("Battle")),
          body: Center(
            child: ElevatedButton(
              onPressed: _toggleSearching,
              child: const Text("Search Opponent"),
            ),
          ),
        ),
        if (_showSearching)
          Positioned.fill(
            child: SearchingOpponent(
              me: me,
              users: users,
              durationInSeconds:
                  10, //Basically this time duration use for Backend Response if Your API take 1 min set 60 sec(Add Time according to API response)
              onCancel:
                  _toggleSearching, //In this method you can do cancel searching functionality
              onTimeout:
                  _handleTimeout, // In this method you can use your Logic If API Data retrieve do whatever you want
            ),
          ),
      ],
    );
  }
}
