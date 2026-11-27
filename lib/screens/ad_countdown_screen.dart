import 'dart:async';

import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../services/house_ad_service.dart';
import '../services/voice_assistant_service.dart';
import '../theme/app_theme.dart';

/// Full-screen advertisement with a countdown (15 seconds by default, set
/// per ad by an administrator). The player can continue only when the
/// countdown reaches zero. Pops with `true` when the ad was watched fully.
class AdCountdownScreen extends StatefulWidget {
  final HouseAd ad;

  const AdCountdownScreen({super.key, required this.ad});

  /// Shows [ad] and returns true when it was watched until the end.
  static Future<bool> show(BuildContext context, HouseAd ad) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AdCountdownScreen(ad: ad),
      ),
    );
    return result ?? false;
  }

  @override
  State<AdCountdownScreen> createState() => _AdCountdownScreenState();
}

class _AdCountdownScreenState extends State<AdCountdownScreen> {
  Timer? _timer;
  late int _secondsLeft;

  bool get _done => _secondsLeft <= 0;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.ad.countdownSeconds;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(VoiceAssistantService.instance.speak(
        'Advertisement. ${widget.ad.title}. '
        'You can continue in $_secondsLeft seconds.',
      ));
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_done) {
        timer.cancel();
        unawaited(VoiceAssistantService.instance.speak('You can continue now'));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _continue() {
    if (!_done) return;
    AudioService.playButtonSound();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final total = ad.countdownSeconds;
    final progress = total == 0 ? 1.0 : 1 - (_secondsLeft / total);

    return PopScope(
      // System back works only after the countdown.
      canPop: _done,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.neonYellow),
                          ),
                          child: const Text(
                            'AD',
                            style: TextStyle(
                              color: AppTheme.neonYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Semantics(
                          liveRegion: true,
                          label: _done
                              ? 'Countdown finished'
                              : '$_secondsLeft seconds left',
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  color: AppTheme.neonCyan,
                                  backgroundColor: Colors.white12,
                                ),
                                ExcludeSemantics(
                                  child: Text(
                                    _done ? '✓' : '$_secondsLeft',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        children: [
                          if (ad.imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 16 / 10,
                                child: Image.network(
                                  ad.imageUrl!,
                                  fit: BoxFit.cover,
                                  semanticLabel: ad.title,
                                  errorBuilder: (_, __, ___) =>
                                      const _ImageFallback(),
                                  loadingBuilder: (context, child, p) =>
                                      p == null
                                          ? child
                                          : const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                ),
                              ),
                            )
                          else
                            const AspectRatio(
                              aspectRatio: 16 / 10,
                              child: _ImageFallback(),
                            ),
                          const SizedBox(height: 22),
                          Text(
                            ad.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neonCyan,
                            ),
                          ),
                          if (ad.message.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              ad.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _done ? _continue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.purple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppTheme.purple.withAlpha(90),
                          disabledForegroundColor: Colors.white60,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppTheme.neonPink),
                          ),
                        ),
                        child: Text(
                          _done
                              ? 'CONTINUE'
                              : 'CONTINUE IN $_secondsLeft s',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
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
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppTheme.purple, AppTheme.neonPink],
        ),
      ),
      child: const Center(
        child: Icon(Icons.campaign, size: 64, color: Colors.white),
      ),
    );
  }
}
