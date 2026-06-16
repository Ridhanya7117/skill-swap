// ─────────────────────────────────────────────
// add_skill_screen.dart
//
// Screen 2 of 3: lets a student fill in their
// skill profile and save it locally.
//
// Why StatefulWidget here (not Stateless)?
// This screen owns several pieces of changing
// state: the form field values, the selected
// dropdown items, and whether the form is
// currently saving. Stateless widgets cannot
// hold changing data — StatefulWidget can.
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/skill_profile.dart';
import '../providers/skill_provider.dart';
import '../theme/app_theme.dart';

class AddSkillScreen extends StatefulWidget {
  const AddSkillScreen({super.key});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

// ── STATE CLASS ──────────────────────────────
// All mutable data and logic lives here.
// The leading underscore makes it private to
// this file — nothing outside can create it.

class _AddSkillScreenState extends State<AddSkillScreen> {
  // ── 1. FORM KEY ───────────────────────────────
  // A GlobalKey gives us a handle to the Form
  // widget so we can call:
  //   _formKey.currentState!.validate()  — triggers all validators
  //   _formKey.currentState!.reset()     — clears all fields
  //
  // GlobalKey<FormState> is the exact type Flutter
  // requires for Form widgets.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ── 2. TEXT CONTROLLERS ───────────────────────
  // A TextEditingController is attached to each
  // TextFormField. It lets us:
  //   • Read the current text:  _nameController.text
  //   • Clear the field:        _nameController.clear()
  //
  // We need one per text field.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _teachSkillController = TextEditingController();
  final TextEditingController _learnSkillController = TextEditingController();

  // ── 3. DROPDOWN STATE ─────────────────────────
  // Dropdowns are not text fields, so they don't
  // use TextEditingControllers. Instead we store
  // the selected enum value as a nullable variable.
  // null means "nothing chosen yet" — this lets
  // the validator catch an empty dropdown.
  SkillLevel? _selectedTeachLevel;
  SkillLevel? _selectedLearnLevel;
  LearningMode? _selectedMode;

  // ── 4. LOADING FLAG ───────────────────────────
  // True while we're waiting for provider.addProfile()
  // to finish. Used to show a spinner on the button
  // and prevent double-taps.
  bool _isSaving = false;

  // ── 5. DISPOSE ────────────────────────────────
  // IMPORTANT: always dispose controllers when the
  // widget is removed from the tree. Failing to do
  // this causes memory leaks.
  @override
  void dispose() {
    _nameController.dispose();
    _teachSkillController.dispose();
    _learnSkillController.dispose();
    super.dispose();
  }

  // ── 6. SAVE LOGIC ─────────────────────────────
  // Called when the user taps the Save button.
  // Steps:
  //  a) Validate every field — stop if any fail
  //  b) Build a SkillProfile from the form data
  //  c) Call provider.addProfile() to save it
  //  d) Show a success SnackBar
  //  e) Reset the form back to empty
  Future<void> _saveProfile() async {
    // a) validate() calls every field's validator.
    //    It returns false if any validator returned
    //    an error string. We stop here in that case.
    final bool isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    // Show spinner, disable the button
    setState(() => _isSaving = true);

    // b) Build the profile.
    //    const Uuid().v4() generates a random unique
    //    string like "550e8400-e29b-41d4-a716-446655440000"
    final SkillProfile newProfile = SkillProfile(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      canTeachSkill: _teachSkillController.text.trim(),
      // The ! asserts these are non-null — safe here
      // because validate() already checked them above.
      canTeachLevel: _selectedTeachLevel!,
      wantToLearnSkill: _learnSkillController.text.trim(),
      wantToLearnLevel: _selectedLearnLevel!,
      preferredMode: _selectedMode!,
      createdAt: DateTime.now(),
    );

    // c) Save via the provider (writes to SharedPreferences)
    await context.read<SkillProvider>().addProfile(newProfile);

    // Hide spinner
    // Check mounted first — if the user navigated away
    // while saving, the widget may no longer exist and
    // calling setState on it would crash the app.
    if (!mounted) return;
    setState(() => _isSaving = false);

    // d) Show a brief success message at the bottom
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              'Profile for ${newProfile.name} saved!',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );

    // e) Reset: clear text fields and dropdown values
    _formKey.currentState!.reset();
    _nameController.clear();
    _teachSkillController.clear();
    _learnSkillController.clear();
    setState(() {
      _selectedTeachLevel = null;
      _selectedLearnLevel = null;
      _selectedMode = null;
    });
  }

  // ── 7. BUILD ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Skills'),
      ),

      // SingleChildScrollView prevents the form
      // from being cut off when the keyboard opens
      // and pushes the layout upward.
      body: SingleChildScrollView(
        padding: AppTheme.pagePadding,
        child: Form(
          // Attach the form key so we can validate
          // and reset from _saveProfile()
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Intro text ─────────────────────
              _buildSectionHeader(
                icon: Icons.person_rounded,
                title: 'Your Details',
                subtitle: 'Tell other students who you are',
              ),
              AppTheme.fieldGap,

              // ── Name field ─────────────────────
              _buildNameField(),
              AppTheme.sectionGap,

              // ── "Can Teach" section ────────────
              _buildSectionHeader(
                icon: Icons.school_rounded,
                iconColor: AppTheme.primaryColor,
                title: 'What Can You Teach?',
                subtitle: 'Share a skill you are good at',
              ),
              AppTheme.fieldGap,
              _buildTeachSkillField(),
              AppTheme.fieldGap,
              _buildTeachLevelDropdown(),
              AppTheme.sectionGap,

              // ── "Want to Learn" section ────────
              _buildSectionHeader(
                icon: Icons.lightbulb_rounded,
                iconColor: AppTheme.accentColor,
                title: 'What Do You Want to Learn?',
                subtitle: 'A skill you are looking for',
              ),
              AppTheme.fieldGap,
              _buildLearnSkillField(),
              AppTheme.fieldGap,
              _buildLearnLevelDropdown(),
              AppTheme.sectionGap,

              // ── "Preferred Mode" section ───────
              _buildSectionHeader(
                icon: Icons.swap_horiz_rounded,
                title: 'Preferred Session Type',
                subtitle: 'How would you like to meet?',
              ),
              AppTheme.fieldGap,
              _buildModeDropdown(),

              // Space so the button doesn't hug the last field
              const SizedBox(height: 36),

              // ── Save button ────────────────────
              _buildSaveButton(),

              // Bottom padding so the button clears the
              // bottom nav bar when scrolled to the end
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PRIVATE BUILDER METHODS
  // Each method builds one chunk of the form.
  // Keeping them separate makes the build()
  // method above easy to scan.
  // ─────────────────────────────────────────────

  // — Section header with icon ──────────────────
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = AppTheme.primaryColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }

  // — Name TextFormField ─────────────────────────
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      // Capitalise the first letter of each word
      textCapitalization: TextCapitalization.words,
      // Show "Done" on the keyboard (closes keyboard)
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Your Name',
        hintText: 'e.g. Aisha Patel',
        prefixIcon: Icon(Icons.badge_rounded, color: AppTheme.textSecondary),
      ),
      // validator runs when _formKey.currentState!.validate() is called.
      // Return a String to show an error, or null if the value is fine.
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null; // null = no error
      },
    );
  }

  // — Can Teach skill TextFormField ─────────────
  Widget _buildTeachSkillField() {
    return TextFormField(
      controller: _teachSkillController,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Skill I Can Teach',
        hintText: 'e.g. Python, Guitar, Photography',
        prefixIcon:
            Icon(Icons.school_rounded, color: AppTheme.primaryColor),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a skill you can teach';
        }
        if (value.trim().length < 2) {
          return 'Skill name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  // — Can Teach level DropdownButtonFormField ────
  Widget _buildTeachLevelDropdown() {
    return DropdownButtonFormField<SkillLevel>(
      value: _selectedTeachLevel,
      decoration: const InputDecoration(
        labelText: 'My Teaching Level',
        prefixIcon:
            Icon(Icons.signal_cellular_alt_rounded, color: AppTheme.primaryColor),
      ),
      // DropdownMenuItem: one entry per enum value.
      // SkillLevel.values is a built-in list of all
      // values: [beginner, intermediate, advanced]
      items: SkillLevel.values.map((level) {
        return DropdownMenuItem<SkillLevel>(
          value: level,
          child: Text(level.label),
        );
      }).toList(),
      onChanged: (SkillLevel? newValue) {
        // setState tells Flutter the state has changed
        // and it should redraw this widget.
        setState(() => _selectedTeachLevel = newValue);
      },
      validator: (value) {
        if (value == null) return 'Please select your teaching level';
        return null;
      },
    );
  }

  // — Want to Learn skill TextFormField ─────────
  Widget _buildLearnSkillField() {
    return TextFormField(
      controller: _learnSkillController,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Skill I Want to Learn',
        hintText: 'e.g. Spanish, Web Design, Piano',
        prefixIcon:
            Icon(Icons.lightbulb_rounded, color: AppTheme.accentColor),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a skill you want to learn';
        }
        if (value.trim().length < 2) {
          return 'Skill name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  // — Want to Learn level DropdownButtonFormField ─
  Widget _buildLearnLevelDropdown() {
    return DropdownButtonFormField<SkillLevel>(
      value: _selectedLearnLevel,
      decoration: const InputDecoration(
        labelText: 'Level I\'m Aiming For',
        prefixIcon: Icon(Icons.trending_up_rounded, color: AppTheme.accentColor),
      ),
      items: SkillLevel.values.map((level) {
        return DropdownMenuItem<SkillLevel>(
          value: level,
          child: Text(level.label),
        );
      }).toList(),
      onChanged: (SkillLevel? newValue) {
        setState(() => _selectedLearnLevel = newValue);
      },
      validator: (value) {
        if (value == null) return 'Please select the level you are aiming for';
        return null;
      },
    );
  }

  // — Preferred mode DropdownButtonFormField ─────
  Widget _buildModeDropdown() {
    // Each mode has a matching icon for scannability
    final Map<LearningMode, IconData> modeIcons = {
      LearningMode.online: Icons.wifi_rounded,
      LearningMode.offline: Icons.location_on_rounded,
      LearningMode.both: Icons.swap_horiz_rounded,
    };

    return DropdownButtonFormField<LearningMode>(
      value: _selectedMode,
      decoration: const InputDecoration(
        labelText: 'Preferred Session Type',
        prefixIcon:
            Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary),
      ),
      items: LearningMode.values.map((mode) {
        return DropdownMenuItem<LearningMode>(
          value: mode,
          child: Row(
            children: [
              Icon(modeIcons[mode], size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(mode.label),
            ],
          ),
        );
      }).toList(),
      onChanged: (LearningMode? newValue) {
        setState(() => _selectedMode = newValue);
      },
      validator: (value) {
        if (value == null) return 'Please select your preferred session type';
        return null;
      },
    );
  }

  // — Save button ────────────────────────────────
  Widget _buildSaveButton() {
    return ElevatedButton(
      // When _isSaving is true, pass null to onPressed.
      // A null onPressed disables the button automatically —
      // Flutter greys it out and ignores taps.
      onPressed: _isSaving ? null : _saveProfile,
      child: _isSaving
          // Show a small white spinner while saving
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          // Normal state: icon + label
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_rounded, size: 20),
                SizedBox(width: 8),
                Text('Save Profile'),
              ],
            ),
    );
  }
}
