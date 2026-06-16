// ─────────────────────────────────────────────
// matches_screen.dart
//
// Screen 3 of 3: shows which profiles match
// the currently selected user's "want to learn"
// skill against every other user's "can teach".
//
// Because SkillSwap has no login system, the
// screen first asks "Which profile are you?"
// so it knows whose matches to show.
//
// Widget breakdown:
//   MatchesScreen (StatefulWidget)
//    ├─ _NoProfiesView       — fewer than 2 profiles saved
//    ├─ _ProfileSelectorCard — dropdown to pick "your" profile
//    └─ _MatchResults
//        ├─ _NoMatchesView   — matches list is empty
//        └─ ListView         — one SkillCard per match
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/skill_profile.dart';
import '../providers/skill_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/skill_card.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  // ── STATE ────────────────────────────────────
  // The profile the user has identified as their
  // own. null means "not chosen yet".
  SkillProfile? _selectedProfile;

  // ── BUILD ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Matches'),
      ),

      // Consumer rebuilds this subtree automatically
      // whenever SkillProvider calls notifyListeners()
      // (e.g. when a new profile is added in Add Skill).
      body: Consumer<SkillProvider>(
        builder: (context, provider, child) {
          // Spinner while data loads from disk on startup
          if (provider.isLoading) {
            return const _LoadingView();
          }

          // Need at least 2 profiles before matching is useful:
          // one to be "you" and one to match against.
          if (provider.profileCount < 2) {
            return const _NotEnoughProfilesView();
          }

          // Main content: selector + results
          return _buildContent(provider);
        },
      ),
    );
  }

  // ── MAIN CONTENT ─────────────────────────────
  Widget _buildContent(SkillProvider provider) {
    // If the selected profile was deleted by another
    // screen while we were here, reset it to null
    // so we don't hold a dangling reference.
    if (_selectedProfile != null &&
        provider.findById(_selectedProfile!.id) == null) {
      // Schedule the reset after the current build
      // completes — we cannot call setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedProfile = null);
      });
    }

    // Compute matches only when a profile is selected
    final List<SkillProfile> matches = _selectedProfile != null
        ? provider.getMatchesFor(_selectedProfile!)
        : [];

    return SingleChildScrollView(
      padding: AppTheme.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Step 1: Profile selector ───────────
          _ProfileSelectorCard(
            profiles: provider.profiles,
            selectedProfile: _selectedProfile,
            onChanged: (profile) {
              setState(() => _selectedProfile = profile);
            },
          ),

          const SizedBox(height: 24),

          // ── Step 2: Results ────────────────────
          // Only show results once a profile is chosen
          if (_selectedProfile != null)
            _MatchResults(
              selectedProfile: _selectedProfile!,
              matches: matches,
            ),

          // Bottom breathing room above nav bar
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _ProfileSelectorCard
//
// A card containing a dropdown that lets the
// user say "I am this person in the list."
// Uses a DropdownButtonFormField styled with
// AppTheme's input decoration.
// ─────────────────────────────────────────────

class _ProfileSelectorCard extends StatelessWidget {
  final List<SkillProfile> profiles;
  final SkillProfile? selectedProfile;
  final ValueChanged<SkillProfile?> onChanged;

  const _ProfileSelectorCard({
    required this.profiles,
    required this.selectedProfile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            const Row(
              children: [
                Icon(Icons.person_search_rounded,
                    color: AppTheme.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Who are you?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            const Text(
              'Select your profile to see who matches your learning goals.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 14),

            // Dropdown — one entry per saved profile
            DropdownButtonFormField<SkillProfile>(
              value: selectedProfile,
              decoration: const InputDecoration(
                labelText: 'Select your profile',
                prefixIcon: Icon(Icons.person_rounded,
                    color: AppTheme.textSecondary),
              ),
              // Build a menu item for each profile in the list
              items: profiles.map((profile) {
                return DropdownMenuItem<SkillProfile>(
                  value: profile,
                  // Each item shows the name and their teach skill
                  // so users can tell profiles apart easily.
                  child: Text(
                     '${profile.name} • ${profile.canTeachSkill}',
                     overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _MatchResults
//
// Shown once a profile is selected.
// Displays either:
//   • A header + list of matched SkillCards, or
//   • A friendly empty state
// ─────────────────────────────────────────────

class _MatchResults extends StatelessWidget {
  final SkillProfile selectedProfile;
  final List<SkillProfile> matches;

  const _MatchResults({
    required this.selectedProfile,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Results header ─────────────────────
        _buildResultsHeader(context),
        const SizedBox(height: 12),

        // ── Cards or empty state ───────────────
        if (matches.isEmpty)
          _NoMatchesView(wantedSkill: selectedProfile.wantToLearnSkill)
        else
          // ListView.builder inside a Column requires
          // shrinkWrap + NeverScrollableScrollPhysics
          // because the parent SingleChildScrollView
          // already handles scrolling.
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return SkillCard(
                profile: matches[index],
                // This is where the green "✓ Match" badge
                // we built into SkillCard gets used.
                showMatchBadge: true,
              );
            },
          ),
      ],
    );
  }

  // — Results count header ──────────────────────
  Widget _buildResultsHeader(BuildContext context) {
    final int count = matches.length;
    final String skillLabel = selectedProfile.wantToLearnSkill;

    return Row(
      children: [
        // Tinted icon container
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.handshake_rounded,
            size: 18,
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 10),
        // "3 matches for Python" etc.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count == 0
                    ? 'No matches found'
                    : count == 1
                        ? '1 match found'
                        : '$count matches found',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'For skill: $skillLabel',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Green count badge (only when there are matches)
        if (count > 0)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// _NoMatchesView
//
// Shown when a profile is selected but nothing
// in the list teaches the skill they want.
// Tells the user exactly what skill had no match
// and suggests what to do next.
// ─────────────────────────────────────────────

class _NoMatchesView extends StatelessWidget {
  final String wantedSkill;

  const _NoMatchesView({required this.wantedSkill});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          // Illustration
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 34,
              color: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // Headline with the specific missing skill
          Text(
            'No one teaches "$wantedSkill" yet',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          const Text(
            'Share this app with friends who know this skill — they could be your perfect match.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Tip chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tips_and_updates_rounded,
                    size: 14, color: AppTheme.primaryColor),
                SizedBox(width: 6),
                Text(
                  'Tip: check spelling matches exactly',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _NotEnoughProfilesView
//
// Shown when there are 0 or 1 profiles.
// Matching needs at least 2 people.
// ─────────────────────────────────────────────

class _NotEnoughProfilesView extends StatelessWidget {
  const _NotEnoughProfilesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppTheme.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_add_rounded,
                size: 44,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Not enough profiles yet',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            const Text(
              'Add at least 2 skill profiles before matches can be found. Tap "Add Skill" to get started.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

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
// Brief spinner shown while SharedPreferences
// data loads on first app launch.
// ─────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryColor,
        strokeWidth: 2.5,
      ),
    );
  }
}
