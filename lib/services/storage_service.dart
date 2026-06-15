// ─────────────────────────────────────────────
// storage_service.dart
//
// The only file in the app that talks to the
// phone's local storage.
//
// Every other file that needs data goes through
// this class — no screen or provider ever calls
// SharedPreferences directly. This pattern is
// called the "Repository pattern" and it means
// if you ever swap SharedPreferences for a real
// database, you only change THIS file.
// ─────────────────────────────────────────────

import 'dart:convert'; // jsonEncode / jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill_profile.dart';

class StorageService {
  // ── 1. STORAGE KEY ──────────────────────────
  // SharedPreferences works like a dictionary:
  // every value is stored under a string key.
  // We use a single key to store ALL profiles
  // as one JSON string (a list of objects).
  //
  // Making it a constant prevents typos —
  // if you type _profilesKey everywhere, Dart
  // catches misspellings at compile time.

  static const String _profilesKey = 'skill_profiles';

  // ── 2. SAVE ALL PROFILES ────────────────────
  // Accepts the current full list of profiles
  // and writes it to storage, replacing whatever
  // was there before.
  //
  // Why save the whole list every time?
  // SharedPreferences doesn't support partial
  // updates. It's simpler and safer to always
  // write the complete list.
  //
  // Steps:
  //   List<SkillProfile>
  //     → List<Map>       (via toJson())
  //     → JSON string     (via jsonEncode)
  //     → SharedPreferences

  Future<void> saveProfiles(List<SkillProfile> profiles) async {
    // Get access to the phone's key-value store
    final prefs = await SharedPreferences.getInstance();

    // Convert each SkillProfile to a Map, then
    // encode the whole list as a JSON string.
    // e.g. '[{"id":"abc","name":"Aisha",...}, ...]'
    final String jsonString = jsonEncode(
      profiles.map((profile) => profile.toJson()).toList(),
    );

    // Write the string under our key.
    // await means we wait for the disk write to finish
    // before this function returns.
    await prefs.setString(_profilesKey, jsonString);
  }

  // ── 3. LOAD ALL PROFILES ────────────────────
  // Reads the stored JSON string and converts it
  // back into a list of SkillProfile objects.
  //
  // Steps (reverse of save):
  //   SharedPreferences
  //     → JSON string
  //     → List<dynamic>  (via jsonDecode)
  //     → List<Map>
  //     → List<SkillProfile>  (via fromJson())
  //
  // Returns an empty list if nothing is saved yet
  // (first launch) so the app never crashes on null.

  Future<List<SkillProfile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to read the stored string.
    // Returns null if the key doesn't exist yet.
    final String? jsonString = prefs.getString(_profilesKey);

    // First launch: nothing saved yet → return empty list
    if (jsonString == null) return [];

    // jsonDecode turns the string back into a
    // Dart List. Each element is a Map<String, dynamic>.
    final List<dynamic> jsonList = jsonDecode(jsonString);

    // Convert every Map back into a SkillProfile object
    // using the fromJson() factory we wrote in the model.
    return jsonList
        .map((item) => SkillProfile.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ── 4. DELETE A PROFILE BY ID ───────────────
  // Removes one profile from storage.
  //
  // Strategy:
  //   1. Load the current list
  //   2. Remove the item whose id matches
  //   3. Save the updated list back
  //
  // We never directly delete a single item from
  // SharedPreferences — we always load, modify,
  // and save the whole list.

  Future<void> deleteProfile(String id) async {
    // Load what's currently saved
    final List<SkillProfile> profiles = await loadProfiles();

    // Keep every profile EXCEPT the one with this id.
    // removeWhere mutates the list in place.
    profiles.removeWhere((profile) => profile.id == id);

    // Write the shortened list back to storage
    await saveProfiles(profiles);
  }
}
