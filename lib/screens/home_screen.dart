// ─────────────────────────────────────────────
// home_screen.dart
//
// The "shell" that holds all three screens.
// It is not a content screen itself — its only
// job is to:
//   1. Keep track of which tab is active
//   2. Show the right screen for that tab
//   3. Display the bottom navigation bar
//
// Why StatefulWidget?
// The active tab index is state that changes
// when the user taps the nav bar. StatelessWidget
// cannot hold changing values, so StatefulWidget
// is required here.
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'browse_screen.dart';
import 'add_skill_screen.dart';
import 'matches_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── 1. ACTIVE TAB INDEX ──────────────────────
  // 0 = Browse, 1 = Add Skill, 2 = Matches
  // Starts on 0 so Browse is the landing tab.
  int _currentIndex = 0;

  // ── 2. SCREENS LIST ──────────────────────────
  // Created once as a final list, not rebuilt on
  // every setState call. This is important for
  // IndexedStack — the screens must be the same
  // object instances across rebuilds so that their
  // internal state (scroll positions, form text)
  // is preserved when you switch tabs.
  //
  // If we wrote the list inside build(), new widget
  // instances would be created on every tab switch,
  // destroying the previous screen's state.
  final List<Widget> _screens = const [
    BrowseScreen(),    // index 0
    AddSkillScreen(),  // index 1
    MatchesScreen(),   // index 2
  ];

  // ── 3. BUILD ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── IndexedStack ───────────────────────────
      // IndexedStack keeps ALL screens in the widget
      // tree simultaneously, but only makes the one
      // at [index] visible. The others are hidden
      // (offstage) but remain alive.
      //
      // This is the key difference from PageView or
      // Navigator:
      //
      //   PageView / Navigator → destroys inactive screens
      //     → form text is lost when you switch tabs
      //
      //   IndexedStack → keeps inactive screens alive
      //     → form text, scroll position, state all preserved
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ── Bottom Navigation Bar ──────────────────
      // Styling comes from AppTheme.bottomNavTheme
      // set in app_theme.dart — we only provide the
      // current index and the tap callback here.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        // Called when the user taps any nav item.
        // setState rebuilds the widget with the new
        // index, which makes IndexedStack show the
        // correct screen.
        onTap: (int index) {
          setState(() => _currentIndex = index);
        },

        // Explicit colours so the bar always uses
        // our brand palette regardless of the device's
        // system theme or Material version defaults.
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,

        // The three navigation destinations
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            // Active state gets a filled variant for
            // a stronger visual affordance
            activeIcon: Icon(Icons.search_rounded,
                color: AppTheme.primaryColor),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            activeIcon: Icon(Icons.add_circle_rounded,
                color: AppTheme.primaryColor),
            label: 'Add Skill',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            activeIcon: Icon(Icons.handshake_rounded,
                color: AppTheme.primaryColor),
            label: 'Matches',
          ),
        ],
      ),
    );
  }
}
