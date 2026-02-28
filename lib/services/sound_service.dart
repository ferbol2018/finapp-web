import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playStart() async {
    await _player.play(AssetSource('sounds/start.wav'));
  }

  Future<void> playStop() async {
    await _player.play(AssetSource('sounds/stop.wav'));
  }
}