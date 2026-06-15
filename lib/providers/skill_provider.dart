// ─────────────────────────────────────────────
// skill_provider.dart
//
// The "brain" of the app. SkillProvider holds
// all profile data in memory and is the single
// place where that data is modified.
//
// How it connects to the UI:
//   Provider (package) makes SkillProvider
//   available to every screen. When data changes
//   and we call notifyListeners(), every screen
//   that is "watching" this provider rebuilds
//   automatically — like a spreadsheet where
//   cells update when the source data changes.
//
// Data flow:
//   StorageService (disk) ←→ SkillProvider (memory) ←→ Screens (UI)
// ─────────────────────────────────────────────

import 'package:flutter/foundation.dart'; // ChangeNotifier
import '../models/skill_profile.dart';
import '../services/storage_service.dart';

class SkillProvider extends ChangeNotifier {
  // ── 1. DEPENDENCIES ─────────────────────────
  // We create one StorageService instance here.
  // SkillProvider uses it whenever it needs to
  // read or write to the phone's storage.

  final StorageService _storageService = StorageService();

  // ── 2. PRIVATE STATE ─────────────────────────
  // The master list of profiles lives here.
  // It is PRIVATE (underscore prefix) so no
  // screen can modify it directly — all changes
  // must go through the methods below.
  // This protects data integrity.

  List<SkillProfile> _profiles = [];

  // Track whether data is still being loaded
  // from disk on first launch.
  bool _isLoading = false;

  // ── 3. PUBLIC GETTERS ────────────────────────
  // Screens read data through these getters.
  // They get a copy of the data but cannot
  // mutate the private list directly.

  /// All profiles currently in memory.
  List<SkillProfile> get profiles => List.unmodifiable(_profiles);
  // List.unmodifiable() means screens can read
  // the list but cannot call .add() or .remove()
  // on it — enforcing the rule that all mutations
  // must go through SkillProvider's methods.

  /// True while profiles are loading from disk.
  /// Screens can show a spinner based on this.
  bool get isLoading => _isLoading;

  /// Total number of saved profiles.
  int get profileCount => _profiles.length;

  // ── 4. LOAD PROFILES ─────────────────────────
  // Called once when the app starts (from main.dart).
  // Reads saved profiles off disk and puts them
  // into memory so screens can display them.

  Future<void> loadProfiles() async {
    // Tell the UI we are busy loading
    _isLoading = true;
    notifyListeners(); // triggers a rebuild with the loading state

    // Ask StorageService to read from SharedPreferences
    _profiles = await _storageService.loadProfiles();

    // Loading is done
    _isLoading = false;
    notifyListeners(); // triggers a rebuild with the loaded data
  }

  // ── 5. ADD A PROFILE ─────────────────────────
  // Adds a new SkillProfile to the in-memory list
  // and immediately persists the updated list to disk.
  //
  // The caller (Add Skill screen) creates the
  // SkillProfile object; this method just stores it.

  Future<void> addProfile(SkillProfile profile) async {
    // Add to the in-memory list
    _profiles.add(profile);

    // Persist the whole updated list to disk
    await _storageService.saveProfiles(_profiles);

    // Tell every listening screen to rebuild
    notifyListeners();
  }

  // ── 6. DELETE A PROFILE ──────────────────────
  // Removes a profile from memory and from disk.
  // Takes an id string (not the whole object)
  // because that's all we need to identify it.

  Future<void> deleteProfile(String id) async {
    // Remove from in-memory list
    _profiles.removeWhere((profile) => profile.id == id);

    // Remove from disk
    await _storageService.deleteProfile(id);

    // Tell every listening screen to rebuild
    notifyListeners();
  }

  // ── 7. MATCHES GETTER ────────────────────────
  // Returns profiles that match a given profile.
  //
  // Matching rule (defined in SkillProfile.matchesWith):
  //   my wantToLearnSkill == their canTeachSkill
  //
  // We keep this logic IN THE MODEL so it only
  // lives in one place. Here we just filter the
  // list using that model method.
  //
  // Usage from the Matches screen:
  //   final matches = provider.getMatchesFor(myProfile);

  List<SkillProfile> getMatchesFor(SkillProfile myProfile) {
    return _profiles
        .where((other) => myProfile.matchesWith(other))
        .toList();
  }

  // ── 8. CONVENIENCE HELPERS ───────────────────
  // Small utilities that screens might need.

  /// Find a single profile by its id.
  /// Returns null if not found (screens should handle this).
  SkillProfile? findById(String id) {
    try {
      return _profiles.firstWhere((p) => p.id == id);
    } catch (_) {
      // firstWhere throws if nothing matches;
      // we catch that and return null instead.
      return null;
    }
  }

  /// True if there are no profiles saved yet.
  /// Useful for showing an "empty state" in Browse screen.
  bool get isEmpty => _profiles.isEmpty;
}
