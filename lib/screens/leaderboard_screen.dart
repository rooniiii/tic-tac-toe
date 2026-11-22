import 'package:flutter/material.dart';
import '../logic/profile_service.dart';
import '../models/user.dart';
import '../models/user_stats.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final User user;

  const LeaderboardScreen({super.key, required this.user});

  @override
  State<LeaderboardScreen> createState() =>
      _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ProfileService _profile = ProfileService();

  UserStats _stats = const UserStats();
  UserStats _computerStats = const UserStats();
  UserStats _guestStats = const UserStats();
  UserStats _playerStats = const UserStats();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final allStats = await _profile.getStats(widget.user.phone);

      final computer = await _profile.getStats(
        widget.user.phone,
        opponentType: 'computer',
      );

      final guest = await _profile.getStats(
        widget.user.phone,
        opponentType: 'guest',
      );

      final player = await _profile.getStats(
        widget.user.phone,
        opponentType: 'player',
      );

      if (!mounted) return;

      setState(() {
        _stats = allStats;
        _computerStats = computer;
        _guestStats = guest;
        _playerStats = player;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Widget _statCard(String title, int value, Color color) {
    return Card(
      color: const Color(0x337B2FF7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _opponentSection(String title, UserStats stats) {
    return Card(
      color: const Color(0x337B2FF7),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.neonYellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Played: ${stats.played}'),
            Text('Wins: ${stats.wins}'),
            Text('Losses: ${stats.losses}'),
            Text('Draws: ${stats.draws}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService.playButtonSound();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              AudioService.playButtonSound();
              setState(() => _loading = true);
              _load();
            },
          ),
        ],
        title: const Text(
          'My Performance',
          style: TextStyle(color: AppTheme.neonYellow),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${widget.user.name}\'s Performance',
            style: const TextStyle(
              color: AppTheme.neonCyan,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _statCard(
                'Total Played',
                _stats.played,
                AppTheme.neonCyan,
              ),
              _statCard(
                'Total Wins',
                _stats.wins,
                AppTheme.neonYellow,
              ),
              _statCard(
                'Total Losses',
                _stats.losses,
                Colors.redAccent,
              ),
              _statCard(
                'Total Draws',
                _stats.draws,
                Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _opponentSection('Computer', _computerStats),
          _opponentSection('Guest', _guestStats),
          _statCard(
            'Best Score',
            _stats.bestScore,
            AppTheme.neonCyan,
          ),
        ],
      ),
    );
  }
}