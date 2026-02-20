import 'package:audioplayers/audioplayers.dart';

import '../providers/settings_provider.dart';

/// 효과음 종류
enum SoundEffect {
  check('sounds/check.wav'),
  levelUp('sounds/level_up.wav'),
  achievement('sounds/achievement.wav'),
  doodleComplete('sounds/doodle_complete.wav');

  const SoundEffect(this.assetPath);
  final String assetPath;
}

/// 효과음 재생 서비스 (싱글톤)
class SoundService {
  factory SoundService() => _instance;
  SoundService._internal();
  static final SoundService _instance = SoundService._internal();

  final Map<SoundEffect, AudioPlayer> _players = {};
  SettingsProvider? _settingsProvider;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    for (final effect in SoundEffect.values) {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setSource(AssetSource(effect.assetPath));
      _players[effect] = player;
    }

    _isInitialized = true;
  }

  void setSettingsProvider(SettingsProvider provider) {
    _settingsProvider = provider;
  }

  /// 효과음 재생 (fire-and-forget)
  void play(SoundEffect effect) {
    if (!_isInitialized) return;
    if (_settingsProvider?.soundEnabled == false) return;

    final player = _players[effect];
    if (player == null) return;

    // 비동기로 재생 (에러 무시)
    _playAsync(player, effect);
  }

  Future<void> _playAsync(AudioPlayer player, SoundEffect effect) async {
    try {
      await player.stop();
      await player.play(AssetSource(effect.assetPath));
    } catch (_) {
      // 사운드 재생 실패는 무시
    }
  }

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _isInitialized = false;
  }
}
