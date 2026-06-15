import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// AppTheme: The single source of truth for all
// visual decisions in SkillSwap.
//
// Why keep it here?
// If you ever want to change a color or font,
// you only change it in ONE place instead of
// hunting through every screen file.
// ─────────────────────────────────────────────

class AppTheme {
  // ── 1. PRIVATE CONSTRUCTOR ──────────────────
  // The underscore (_) makes this constructor
  // private. This prevents anyone from writing
  // `AppTheme()` by mistake. All properties
  // below are accessed directly on the class,
  // e.g. AppTheme.primaryColor
  AppTheme._();

  // ── 2. COLOR PALETTE ────────────────────────
  // A focused 5-color system. Every color in
  // the app comes from this list — nothing is
  // hardcoded anywhere else.

  /// Deep indigo — used for buttons, active nav icons, and highlights.
  static const Color primaryColor = Color(0xFF4F46E5);

  /// Soft lavender — backgrounds of cards and secondary surfaces.
  static const Color secondaryColor = Color(0xFFEEF2FF);

  /// Emerald — "match found" badges and success indicators.
  static const Color accentColor = Color(0xFF10B981);

  /// Near-white — the main page background.
  static const Color backgroundColor = Color(0xFFF8F9FF);

  /// Dark slate — body text and headings.
  static const Color textPrimary = Color(0xFF1E1B4B);

  /// Medium grey — subtitles, placeholders, helper text.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Light grey — card borders and dividers.
  static const Color borderColor = Color(0xFFE5E7EB);

  /// Soft red — error states on form fields.
  static const Color errorColor = Color(0xFFEF4444);

  // ── 3. TYPOGRAPHY ───────────────────────────
  // TextTheme defines every text style used
  // throughout the app in one place.
  //
  // Material 3 text roles:
  //  displayLarge  → giant hero numbers (rarely used)
  //  headlineMedium→ screen titles
  //  titleLarge    → card titles / section headers
  //  bodyLarge     → main readable content
  //  bodyMedium    → secondary content, card subtitles
  //  labelMedium   → tags, badges, button labels

  static const TextTheme _textTheme = TextTheme(
    // Screen titles  e.g. "Browse Skills"
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.5,
    ),

    // Card name / section headings
    titleLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: -0.2,
    ),

    // Normal readable text
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    ),

    // Helper text / subtitles
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.4,
    ),

    // Tags, chips, button labels
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textSecondary,
      letterSpacing: 0.3,
    ),
  );

  // ── 4. COMPONENT THEMES ─────────────────────
  // These customize Flutter's built-in widgets
  // so they always look consistent with our
  // brand without needing to style each one
  // individually in every screen.

  // — Card ————————————————————————————————————
  static const CardThemeData _cardTheme = CardThemeData(
    // How far the card lifts off the background
    elevation: 0,

    // Background of every Card widget
    color: Colors.white,

    // Space between cards when listed
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),

    // Rounded corners — modern & friendly
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      side: BorderSide(color: borderColor, width: 1),
    ),
  );

  // — Input Fields ————————————————————————————
  static final InputDecorationTheme _inputTheme = InputDecorationTheme(
    // Fill the text field with a soft background
    filled: true,
    fillColor: secondaryColor,

    // Helper / error text style
    helperStyle: const TextStyle(color: textSecondary, fontSize: 12),
    errorStyle: const TextStyle(color: errorColor, fontSize: 12),

    // Remove the underline; use an outline border instead
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: borderColor),
    ),

    // Normal (unfocused) state
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: borderColor, width: 1),
    ),

    // When the user taps into the field
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),

    // When form validation fails
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: errorColor, width: 1),
    ),

    // Padding inside the field
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

    // Placeholder label style
    labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
    hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
  );

  // — Elevated Button ——————————————————————————
  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white, // text + icon color
      elevation: 0,
      minimumSize: const Size(double.infinity, 52), // full-width by default
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  );

  // — Bottom Navigation Bar ———————————————————
  static const BottomNavigationBarThemeData _bottomNavTheme =
      BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: primaryColor,
    unselectedItemColor: textSecondary,
    selectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
    ),
    elevation: 12,
    type: BottomNavigationBarType.fixed, // labels always visible
  );

  // — Chip (used for skill tags / levels) ———————
  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: secondaryColor,
    labelStyle: const TextStyle(
      color: primaryColor,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    side: const BorderSide(color: primaryColor, width: 0.8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  );

  // ── 5. THE MAIN THEMEDATA ───────────────────
  // This is the object you pass to MaterialApp.
  // It wires together everything defined above.

  static ThemeData get lightTheme => ThemeData(
        // Enable Material 3 (the modern version of Material Design)
        useMaterial3: true,

        // Seed color generates a full color scheme automatically
        // but we override individual components below
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          primary: primaryColor,
          secondary: accentColor,
          surface: backgroundColor,
          error: errorColor,
        ),

        // Page / scaffold background
        scaffoldBackgroundColor: backgroundColor,

        // Apply all the component themes defined above
        textTheme: _textTheme,
        cardTheme: _cardTheme,
        inputDecorationTheme: _inputTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        bottomNavigationBarTheme: _bottomNavTheme,
        chipTheme: _chipTheme,

        // AppBar — transparent, no shadow, title left-aligned
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
      );

  // ── 6. HELPER GETTERS (optional utilities) ──
  // Convenience decorations you can apply
  // manually in widgets when needed.

  /// A standard page padding applied to screen content.
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// Vertical gap between form fields.
  static const SizedBox fieldGap = SizedBox(height: 16);

  /// Vertical gap between sections.
  static const SizedBox sectionGap = SizedBox(height: 28);
}
