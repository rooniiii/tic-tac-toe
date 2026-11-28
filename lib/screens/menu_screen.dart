import 'dart:async';
import 'package:flutter/material.dart';

import '../logic/auth_service.dart';
import '../logic/profile_service.dart';
import '../logic/settings_service.dart';
import '../logic/onboarding_service.dart';
import '../logic/level_progress_service.dart';
import '../services/house_ad_service.dart';
import 'ai_assistant_screen.dart';
import '../services/audio_service.dart';
import '../services/voice_assistant_service.dart';
import '../models/difficulty.dart';
import '../models/user.dart';
import '../models/user_stats.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import 'leaderboard_screen.dart';
import 'login_screen.dart';
import 'mode_screen.dart';
import 'tutorial_screen.dart';
import 'faq_screen.dart';

class MenuScreen extends StatefulWidget {
  final User user;

  const MenuScreen({super.key, required this.user});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Difficulty _difficulty = Difficulty.easy;

  final _auth = AuthService();
  final _settings = SettingsService.instance;
  final _profile = ProfileService();

  final _levels = LevelProgressService();
  final _onboarding = OnboardingService();

  String _bio = '';
  UserStats _stats = const UserStats();
  int _currentLevel = 1;

  bool _settingsReady = false;

  @override
  void initState() {
    super.initState();

    // Preload the admin-managed ads in the background.
    HouseAdService.instance.preload();

    _loadSettings();
    _loadProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowOnboarding());
  }

  /// First login on this device: show the introductory walkthrough once.
  Future<void> _maybeShowOnboarding() async {
    if (!await _onboarding.shouldShow(widget.user.phone)) return;
    await _onboarding.markDone(widget.user.phone);
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TutorialScreen(firstRun: true)),
    );
  }

  Future<void> _loadLevel() async {
    final level = await _levels.currentLevel(widget.user.phone, _difficulty);
    if (!mounted) return;
    setState(() => _currentLevel = level);
  }

  Future<void> _openAssistant() async {
    AudioService.playButtonSound();
    _announce('AI Assistant');

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
    );
  }

  Future<void> _replayIntro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TutorialScreen(firstRun: true)),
    );
  }

  Future<void> _loadSettings() async {
    await _settings.load();

    await VoiceAssistantService.instance.setEnabled(
      _settings.voiceAssistant,
    );

    if (!mounted) return;

    setState(() {
      _settingsReady = true;
    });
  }

  void _announce(String message) {
    if (!_settingsReady || !_settings.voiceAssistant) return;

    unawaited(
      VoiceAssistantService.instance.speak(message),
    );
  }

  Future<void> _loadProfile() async {
    final bio = await _profile.getBio(widget.user.phone);
    final stats = await _profile.getStats(widget.user.phone);
    await _loadLevel();

    if (!mounted) return;

    setState(() {
      _bio = bio;
      _stats = stats;
    });
  }

  String get _maskedId {
    final p = widget.user.phone;

    if (p.length < 8) return p;

    return '${p.substring(0, 4)}*****${p.substring(p.length - 2)}';
  }

  Future<void> _editBio() async {
    AudioService.playButtonSound();
    _announce('Edit bio');

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _EditBioDialog(initialBio: _bio);
      },
    );

    if (!mounted || result == null) return;

    await _profile.setBio(widget.user.phone, result);

    if (!mounted) return;

    setState(() {
      _bio = result;
    });

    _announce('Save');
  }

  Future<void> _openTutorial() async {
    AudioService.playButtonSound();
    _announce('HOW TO PLAY');

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TutorialScreen(),
      ),
    );
  }

  Future<void> _openFAQ() async {
    AudioService.playButtonSound();
    _announce('Frequently Asked Questions');

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FAQScreen(),
      ),
    );
  }

  Future<void> _openLeaderboard() async {
    AudioService.playButtonSound();
    _announce('Leaderboard');

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeaderboardScreen(
          user: widget.user,
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    AudioService.playButtonSound();
    _announce('Settings');

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppTheme.neonYellow,
            width: 2,
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: AppTheme.neonYellow),
        ),
        scrollable: true,
        content: ListenableBuilder(
          listenable: _settings,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Sound effects'),
                secondary: const Icon(
                  Icons.volume_up,
                  color: AppTheme.neonPink,
                ),
                value: _settings.sound,
                onChanged: (value) async {
                  await _settings.setSound(value);
                },
              ),
              SwitchListTile(
                title: const Text('Voice Assistant'),
                subtitle: const Text(
                  'Speak game options and button names',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                secondary: const Icon(
                  Icons.record_voice_over,
                  color: AppTheme.neonCyan,
                ),
                value: _settings.voiceAssistant,
                onChanged: (value) async {
                  await _settings.setVoiceAssistant(value);

                  await VoiceAssistantService.instance.setEnabled(
                    value,
                  );

                  if (value) {
                    _announce('Voice Assistant');
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.slideshow,
                  color: AppTheme.neonYellow,
                ),
                title: const Text('Replay introduction'),
                onTap: () {
                  AudioService.playButtonSound();
                  Navigator.pop(dialogContext);
                  _replayIntro();
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Delete my account',
                  style: TextStyle(color: Colors.redAccent),
                ),
                subtitle: const Text(
                  'Permanently remove your account and data',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                onTap: () {
                  AudioService.playButtonSound();
                  Navigator.pop(dialogContext);
                  _deleteAccount();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AudioService.playButtonSound();
              _announce('Close');
              Navigator.pop(dialogContext);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    AudioService.playButtonSound();
    _announce('Logout. Are you sure you want to logout?');

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppTheme.neonPink,
            width: 2,
          ),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: AppTheme.neonPink),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AudioService.playButtonSound();
              _announce('Cancel');
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AudioService.playButtonSound();
              _announce('Logout');
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.neonPink),
            ),
          ),
        ],
      ),
    );

    if (!mounted || confirm != true) return;

    try {
      await VoiceAssistantService.instance.stop();
      await _auth.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    _announce('Delete my account');

    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );

    if (!mounted || password == null || password.isEmpty) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final error = await _auth.deleteOwnAccount(
      password: password,
      phone: widget.user.phone,
    );

    if (!mounted) return;

    Navigator.of(context).pop(); // close the progress indicator

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    await VoiceAssistantService.instance.stop();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your account has been deleted.')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _selectDifficulty(Difficulty difficulty) {
    AudioService.playButtonSound();

    setState(() {
      _difficulty = difficulty;
    });

    _announce(difficulty.label);
    _loadLevel();
  }

  Future<void> _startGame() async {
    AudioService.playButtonSound();
    _announce('PLAY');

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModeScreen(
          user: widget.user,
          difficulty: _difficulty,
        ),
      ),
    );

    // Progress may have changed while playing.
    _loadLevel();
  }

  Widget _topIcon(
      String tip,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return IconButton(
      tooltip: tip,
      icon: Icon(icon, color: color, size: 28),
      onPressed: onTap,
    );
  }

  Widget _logoutButton() {
    return Tooltip(
      message: 'Logout from your account',
      child: TextButton.icon(
        onPressed: _logout,
        icon: const Icon(
          Icons.logout_rounded,
          color: AppTheme.neonCyan,
          size: 23,
        ),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: AppTheme.neonCyan,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x33203A8F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonCyan,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonCyan.withAlpha(70),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.neonPink,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: AppTheme.neonPink,
              size: 34,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonCyan,
                  ),
                ),
                Text(
                  'ID: $_maskedId',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  _bio.isEmpty
                      ? 'Bio: tap edit to add'
                      : 'Bio: $_bio',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit bio',
            icon: const Icon(
              Icons.edit_note,
              color: AppTheme.neonYellow,
            ),
            onPressed: _editBio,
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(160)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _difficultyButton(Difficulty difficulty) {
    final selected = difficulty == _difficulty;

    return Expanded(
      child: Tooltip(
        message: 'Play on ${difficulty.label} mode',
        child: GestureDetector(
          onTap: () => _selectDifficulty(difficulty),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.purple
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppTheme.neonCyan
                    : AppTheme.purple,
                width: 2,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color: AppTheme.neonCyan.withAlpha(120),
                  blurRadius: 14,
                ),
              ]
                  : [],
            ),
            child: Center(
              child: Text(
                difficulty.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? Colors.white
                      : Colors.white70,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Row(
                children: [
                  _logoutButton(),
                  const Spacer(),
                  _topIcon(
                    'AI Assistant',
                    Icons.smart_toy_outlined,
                    AppTheme.neonPink,
                    _openAssistant,
                  ),
                  _topIcon(
                    'Leaderboard',
                    Icons.leaderboard,
                    AppTheme.neonCyan,
                    _openLeaderboard,
                  ),
                  _topIcon(
                    'Settings',
                    Icons.settings,
                    AppTheme.neonYellow,
                    _openSettings,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        _profileCard(),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _stat('Played', _stats.played, Colors.white),
                            _stat('Wins', _stats.wins, AppTheme.neonCyan),
                            _stat('Losses', _stats.losses, AppTheme.neonPink),
                            _stat('Best', _stats.bestScore, AppTheme.neonYellow),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'NEON XO',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neonYellow,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Select difficulty',
                          style: TextStyle(
                            color: AppTheme.neonCyan,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _difficultyButton(Difficulty.easy),
                            _difficultyButton(Difficulty.medium),
                            _difficultyButton(Difficulty.hard),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            '${_difficulty.label}: Level $_currentLevel of '
                            '${LevelProgressService.maxLevel}',
                            style: const TextStyle(
                              color: AppTheme.neonYellow,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        NeonButton(
                          text: 'PLAY',
                          onPressed: _settingsReady ? _startGame : null,
                        ),

                        const SizedBox(height: 8),
                        const SizedBox(height: 8),

                        const Text(
                          'LEARN & GET HELP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.neonCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 58,
                                child: OutlinedButton.icon(
                                  onPressed: _settingsReady
                                      ? _openTutorial
                                      : null,
                                  icon: const Icon(
                                    Icons.school_outlined,
                                    color: AppTheme.neonCyan,
                                    size: 19,
                                  ),
                                  label: const Text(
                                    'HOW TO PLAY',
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                      color: AppTheme.neonCyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    side: const BorderSide(
                                      color: AppTheme.neonCyan,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 58,
                                child: OutlinedButton.icon(
                                  onPressed: _settingsReady
                                      ? _openFAQ
                                      : null,
                                  icon: const Icon(
                                    Icons.quiz_outlined,
                                    color: AppTheme.neonPink,
                                    size: 19,
                                  ),
                                  label: const Text(
                                    'FAQ',
                                    style: TextStyle(
                                      color: AppTheme.neonPink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    side: const BorderSide(
                                      color: AppTheme.neonPink,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _openAssistant,
                            icon: const Icon(
                              Icons.smart_toy_outlined,
                              color: AppTheme.neonYellow,
                              size: 20,
                            ),
                            label: const Text(
                              'ASK THE AI ASSISTANT',
                              style: TextStyle(
                                color: AppTheme.neonYellow,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.neonYellow,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditBioDialog extends StatefulWidget {
  final String initialBio;

  const _EditBioDialog({
    required this.initialBio,
  });

  @override
  State<_EditBioDialog> createState() => _EditBioDialogState();
}

class _EditBioDialogState extends State<_EditBioDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      backgroundColor: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppTheme.neonCyan,
          width: 2,
        ),
      ),
      title: const Text('Edit bio'),
      content: TextField(
        controller: _controller,
        maxLength: 40,
        decoration: const InputDecoration(
          hintText: 'Write something about you',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            AudioService.playButtonSound();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            AudioService.playButtonSound();
            Navigator.pop(context, _controller.text.trim());
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Asks for the password before the account is deleted. Owns its text
/// controller so it is disposed only after the dialog is gone.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      backgroundColor: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      title: const Text(
        'Delete Account?',
        style: TextStyle(color: Colors.redAccent),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'This permanently deletes your account, statistics, game '
            'history, bio and leaderboard entry. It cannot be undone.\n\n'
            'Enter your password to confirm.',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            AudioService.playButtonSound();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            AudioService.playButtonSound();
            Navigator.pop(context, _passwordController.text);
          },
          child: const Text(
            'Delete forever',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
