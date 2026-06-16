// ─────────────────────────────────────────────
// browse_screen.dart
//
// Screen 1 of 3: shows all saved skill profiles.
//
// This screen's only job is to READ data and
// display it. It never modifies data — that
// happens in add_skill_screen.dart.
//
// Key Flutter concepts used here:
//  • Consumer    — listens to SkillProvider and
//                  rebuilds when data changes
//  • ListView.builder — efficiently renders a
//                  scrollable list of cards
//  • StatelessWidget — no internal state needed;
//                  all data comes from the provider
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/skill_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/skill_card.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  // ── BUILD ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ────────────────────────────────
      // backgroundColor and titleTextStyle come
      // from AppTheme.appBarTheme set in main.dart,
      // so we only need to provide the title text.
      appBar: AppBar(
        title: const Text('Browse Skills'),
        // A small subtitle showing total count,
        // updated automatically by the Consumer below.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: _buildCountBanner(context),
        ),
      ),

      // ── Body ──────────────────────────────────
      // Consumer<SkillProvider> does two things:
      //  1. Gets the current SkillProvider instance
      //  2. Re-runs its builder whenever the provider
      //     calls notifyListeners()
      //
      // This means: add a profile → this screen
      // automatically shows the new card. No manual
      // refresh or setState needed.
      body: Consumer<SkillProvider>(
        builder: (context, provider, child) {
          // Show a spinner while profiles load from disk
          if (provider.isLoading) {
            return const _LoadingView();
          }

          // Show a friendly illustration when no profiles exist
          if (provider.isEmpty) {
            return const _EmptyStateView();
          }

          // Show the list of profile cards
          return _ProfileList(profiles: provider.profiles);
        },
      ),
    );
  }

  // ── COUNT BANNER ─────────────────────────────
  // Shown just below the AppBar title.
  // "3 students sharing skills" etc.
  Widget _buildCountBanner(BuildContext context) {
    return Consumer<SkillProvider>(
      builder: (context, provider, _) {
        final int count = provider.profileCount;
        final String text = count == 0
            ? 'No profiles yet — be the first!'
            : count == 1
                ? '1 student sharing skills'
                : '$count students sharing skills';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 16, bottom: 10),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// _ProfileList
//
// Renders the scrollable list of SkillCards.
// Extracted into its own widget to keep
// BrowseScreen.build() clean and readable.
//
// Why ListView.builder instead of ListView?
//  ListView renders ALL children at once.
//  ListView.builder only renders the cards
//  visible on screen — much more efficient
//  when the list grows large.
// ─────────────────────────────────────────────

class _ProfileList extends StatelessWidget {
  final List profiles;

  const _ProfileList({required this.profiles});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Padding at the top and bottom of the list
      padding: const EdgeInsets.only(top: 8, bottom: 100),

      // Total number of items in the list
      itemCount: profiles.length,

      // itemBuilder is called once per visible item.
      // `index` is the position (0, 1, 2, …).
      itemBuilder: (context, index) {
        final profile = profiles[index];

        // Each SkillCard gets a subtle fade-in
        // animation so the list feels lively.
        return _AnimatedCard(
          // key helps Flutter track which card
          // is which when the list order changes.
          key: ValueKey(profile.id),
          index: index,
          child: SkillCard(profile: profile),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// _AnimatedCard
//
// Wraps any child widget in a fade + slide-up
// entrance animation.
//
// StatefulWidget is used here (not Stateless)
// because animations require a controller that
// lives across multiple frames — that's "state".
// ─────────────────────────────────────────────

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index; // used to stagger the animation

  const _AnimatedCard({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  // AnimationController drives the animation over time.
  late final AnimationController _controller;

  // Two animations: opacity (fade) and vertical position (slide)
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this, // SingleTickerProviderStateMixin provides this
      duration: const Duration(milliseconds: 350),
    );

    // Fade from invisible (0.0) to fully visible (1.0)
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Slide from slightly below (y: 0.04 = 4% down) to normal position
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Stagger: card 0 starts immediately, card 1 waits 50ms,
    // card 2 waits 100ms, etc. — max 300ms delay.
    final int delayMs = (widget.index * 50).clamp(0, 300);
    Future.delayed(Duration(milliseconds: delayMs), () {
      // Check mounted before calling setState to avoid
      // errors if the widget is removed before the delay ends.
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    // Always dispose controllers to free memory.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _EmptyStateView
//
// Shown when there are no profiles yet.
// Treat empty screens as invitations to act —
// not dead ends.
// ─────────────────────────────────────────────

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration: large icon in a soft circle
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppTheme.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            // Headline
            Text(
              'No skills listed yet',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Helpful instruction — tells the user exactly what to do
            const Text(
              'Tap "Add Skill" below to create your profile and start swapping skills with other students.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Arrow pointing down toward the bottom nav
            const Icon(
              Icons.arrow_downward_rounded,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _LoadingView
//
// Shown for the brief moment while profiles
// are being read from SharedPreferences.
// ─────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 16),
          Text(
            'Loading profiles…',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
