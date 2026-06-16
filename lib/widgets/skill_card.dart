// ─────────────────────────────────────────────
// skill_card.dart
//
// A reusable widget that displays one SkillProfile
// as a visual card.
//
// "Reusable" means we build it once here and
// use it in Browse, Matches, and anywhere else
// that needs to show a profile — no copy-paste.
//
// It is a StatelessWidget because the card only
// DISPLAYS data. It has no internal state that
// can change (no tap counters, no toggles).
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/skill_profile.dart';
import '../providers/skill_provider.dart';
import '../theme/app_theme.dart';

class SkillCard extends StatelessWidget {
  // ── 1. INPUTS (constructor parameters) ──────
  // The card needs a profile to display.
  // `showMatchBadge` lets the Matches screen
  // add a green "Match" badge without needing a
  // separate MatchCard widget.

  /// The profile data this card will display.
  final SkillProfile profile;

  /// When true, shows a green "✓ Match" badge
  /// in the top-right corner of the card.
  /// Defaults to false so Browse screen needs
  /// no extra code.
  final bool showMatchBadge;

  const SkillCard({
    super.key,
    required this.profile,
    this.showMatchBadge = false,
  });

  // ── 2. BUILD METHOD ──────────────────────────
  // build() is called by Flutter whenever it
  // needs to draw (or redraw) this widget.
  // It returns a tree of smaller widgets.

  @override
  Widget build(BuildContext context) {
    // Access the theme's text styles so our card
    // stays consistent with the rest of the app.
    final textTheme = Theme.of(context).textTheme;

    // Card is a Material widget that draws a
    // rounded rectangle with a background color.
    // Its visual style comes from AppTheme._cardTheme
    // (elevation: 0, white bg, rounded corners).
    return Card(
      // Stack lets us layer the match badge ON TOP
      // of the card content.
      child: Stack(
        children: [
          // ── Main card content ────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              // Align children to the left edge
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: Avatar + Name ────────
                _buildHeader(textTheme),

                const SizedBox(height: 14),

                // ── Divider ─────────────────────
                const Divider(
                  color: AppTheme.borderColor,
                  height: 1,
                  thickness: 1,
                ),

                const SizedBox(height: 14),

                // ── Row 2: Teach section ────────
                _buildSkillRow(
                  context: context,
                  icon: Icons.school_rounded,
                  iconColor: AppTheme.primaryColor,
                  label: 'Can Teach',
                  skill: profile.canTeachSkill,
                  level: profile.canTeachLevel,
                  chipColor: AppTheme.secondaryColor,
                  chipTextColor: AppTheme.primaryColor,
                ),

                const SizedBox(height: 10),

                // ── Row 3: Learn section ────────
                _buildSkillRow(
                  context: context,
                  icon: Icons.lightbulb_rounded,
                  iconColor: AppTheme.accentColor,
                  label: 'Wants to Learn',
                  skill: profile.wantToLearnSkill,
                  level: profile.wantToLearnLevel,
                  chipColor: const Color(0xFFD1FAE5), // light emerald tint
                  chipTextColor: AppTheme.accentColor,
                ),

                const SizedBox(height: 14),

                // ── Row 4: Learning mode badge ──
                _buildModeChip(),
              ],
            ),
          ),

          // ── Match badge (conditional) ────────
          // Only rendered when showMatchBadge is true.
          // Positioned in the top-right corner.
          if (showMatchBadge) _buildMatchBadge(),
        ],
      ),
    );
  }

  // ── 3. PRIVATE HELPER METHODS ────────────────
  // Breaking the UI into small private methods
  // keeps build() easy to read. Each method
  // builds one visual "chunk" of the card.

  // — Header: coloured avatar circle + name ————
  Widget _buildHeader(TextTheme textTheme) {
    // Use the first letter of the name as the avatar.
    // We pick a background colour based on which
    // letter it is so each card feels unique.
    final String initial = profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : '?';

    return Row(
      children: [
        // Circular avatar with initial
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _avatarColor(profile.name),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Name + subtle "student" label
        Expanded(
          // Expanded fills remaining width so long
          // names don't overflow out of the row.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: textTheme.titleLarge,
                // Truncate with ellipsis if name is very long
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Skill Swapper',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        // ── Delete button ────────────────────────
        // Needs BuildContext to show the dialog, so
        // it is built inline here rather than in a
        // separate private method (private methods on
        // StatelessWidget don't receive context unless
        // it is passed in explicitly — passing it here
        // is cleaner for a single-use widget).
        Builder(
          builder: (context) => IconButton(
            // Tight padding keeps the button small so
            // it doesn't push the avatar or name around.
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            tooltip: 'Delete profile',
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ],
    );
  }

  // — Skill row: icon + label + skill name + level chip ─
  Widget _buildSkillRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String skill,
    required SkillLevel level,
    required Color chipColor,
    required Color chipTextColor,
  }) {
    return Row(
      // Align children to the vertical centre
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon in a small tinted circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),

        const SizedBox(width: 10),

        // Label + skill name stacked vertically
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                skill,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Level chip (Beginner / Intermediate / Advanced)
        _buildLevelChip(
          label: level.label,
          bgColor: chipColor,
          textColor: chipTextColor,
        ),
      ],
    );
  }

  // — Small pill-shaped chip for skill level ————
  Widget _buildLevelChip({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // — Learning mode chip at card bottom ─────────
  Widget _buildModeChip() {
    // Pick an icon that matches the mode
    IconData modeIcon;
    switch (profile.preferredMode) {
      case LearningMode.online:
        modeIcon = Icons.wifi_rounded;
        break;
      case LearningMode.offline:
        modeIcon = Icons.location_on_rounded;
        break;
      case LearningMode.both:
        modeIcon = Icons.swap_horiz_rounded;
        break;
    }

    return Row(
      children: [
        Icon(modeIcon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          '${profile.preferredMode.label} sessions',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // — Confirmation dialog + delete action ──────
  // async because we await the dialog result and
  // then await the provider call.
  Future<void> _confirmDelete(BuildContext context) async {
    // showDialog returns whatever value was passed
    // to Navigator.pop() when the dialog closed.
    // We use a bool: true = confirmed, false/null = cancelled.
    final bool? confirmed = await showDialog<bool>(
      context: context,
      // barrierDismissible: false means tapping outside
      // the dialog does NOT close it — the user must
      // explicitly tap Cancel or Delete.
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        // ── Dialog title ──────────────────────────
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppTheme.errorColor, size: 22),
            SizedBox(width: 8),
            Text(
              'Delete Profile?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        // ── Dialog body ───────────────────────────
        content: const Text(
          'Are you sure you want to delete this profile? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        // ── Dialog buttons ────────────────────────
        actions: [
          // Cancel — closes dialog, does nothing
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Delete — closes dialog with true
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    // If the user tapped Cancel (or dismissed), do nothing.
    if (confirmed != true) return;

    // Guard: if the card's parent widget was removed
    // from the tree while the dialog was open, the
    // original context is no longer valid. Attempting
    // to use it would throw an error.
    if (!context.mounted) return;

    // Call the provider to remove from memory + storage.
    // context.read() is used here (not watch/Consumer)
    // because we only need the provider once for an
    // action — we are not listening for changes.
    await context.read<SkillProvider>().deleteProfile(profile.id);

    // Guard again after the async gap — the widget
    // may have unmounted while deleteProfile() ran.
    if (!context.mounted) return;

    // Show brief confirmation at the bottom of the screen.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Profile deleted',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppTheme.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // — Green "✓ Match" badge ─────────────────────
  Widget _buildMatchBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Match',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. AVATAR COLOR HELPER ───────────────────
  // Returns one of several indigo/teal shades
  // based on the first character of the name.
  // Same name always gets the same color.

  Color _avatarColor(String name) {
    const List<Color> palette = [
      Color(0xFF4F46E5), // indigo
      Color(0xFF7C3AED), // violet
      Color(0xFF0891B2), // cyan
      Color(0xFF059669), // emerald
      Color(0xFFD97706), // amber
      Color(0xFFDB2777), // pink
    ];

    if (name.isEmpty) return palette[0];

    // Use the char code of the first letter to
    // pick an index. This is deterministic —
    // "Aisha" will always get the same colour.
    final int index = name.codeUnitAt(0) % palette.length;
    return palette[index];
  }
}
