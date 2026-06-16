// ─────────────────────────────────────────────
// main.dart
//
// The entry point of every Flutter app.
// Flutter calls main() first, which calls
// runApp(), which starts the widget tree.
//
// This file has three jobs:
//  1. Create the SkillProvider and load saved data
//  2. Make the provider available to every screen
//  3. Apply AppTheme and launch BrowseScreen
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/skill_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

// ── 1. ENTRY POINT ───────────────────────────
// main() is the first function Dart runs.
// `async` lets us use `await` inside it so we
// can load saved profiles before the UI appears.

void main() async {
  // WidgetsFlutterBinding.ensureInitialized() must
  // be called before any Flutter framework code
  // runs inside an async main(). It wires up the
  // Flutter engine so plugins (like SharedPreferences)
  // are ready to use.
  WidgetsFlutterBinding.ensureInitialized();

  // Create the provider once, here at the top.
  // We create it before runApp so we can call
  // loadProfiles() and wait for it to finish
  // before the first frame is drawn.
  final skillProvider = SkillProvider();

  // Load any profiles saved on disk.
  // await means: "wait here until loading is done,
  // then continue." The UI won't appear until this
  // line completes, so the Browse screen always
  // starts with real data rather than flickering
  // from empty → populated.
  await skillProvider.loadProfiles();

  // Hand control to Flutter and draw the first frame.
  runApp(SkillSwapApp(skillProvider: skillProvider));
}

// ── 2. ROOT APP WIDGET ───────────────────────
// SkillSwapApp is the top of the entire widget
// tree. Every screen, widget, and provider lives
// inside it.
//
// It is a StatelessWidget because the app itself
// has no state — theme and routing don't change.

class SkillSwapApp extends StatelessWidget {
  /// The pre-loaded provider passed in from main().
  final SkillProvider skillProvider;

  const SkillSwapApp({super.key, required this.skillProvider});

  @override
  Widget build(BuildContext context) {
    // ── 3. CHANGNOTIFIERPROVIDER ──────────────
    // ChangeNotifierProvider makes SkillProvider
    // available to every widget in the tree below
    // it. Any screen can access it with:
    //
    //   Provider.of<SkillProvider>(context)
    //   or
    //   Consumer<SkillProvider>(builder: ...)
    //
    // `value:` is used (instead of `create:`)
    // because we already created the provider
    // above in main() and pre-loaded its data.
    // Using `create:` here would create a fresh
    // empty provider and lose the loaded profiles.
    return ChangeNotifierProvider<SkillProvider>.value(
      value: skillProvider,

      // ── 4. MATERIALAPP ─────────────────────
      // MaterialApp sets up:
      //  • The app title (shown in task switcher)
      //  • The global theme (fonts, colors, shapes)
      //  • The first screen to show (home)
      //  • Removes the debug banner in the corner
      child: MaterialApp(
        title: 'SkillSwap',

        // Apply our custom theme from AppTheme.
        // Every Card, Button, TextField, and AppBar
        // in the app will automatically use these styles.
        theme: AppTheme.lightTheme,

        // Remove the red "DEBUG" banner in the
        // top-right corner during development.
        debugShowCheckedModeBanner: false,

        // BrowseScreen is the first screen the
        // user sees when they open the app.
        home: const HomeScreen(),
      ),
    );
  }
}
