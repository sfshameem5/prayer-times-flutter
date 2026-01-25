import 'package:just_audio/just_audio.dart';

class AudioService {
  static var _currentlyPlayingAsset = "";

  static final _player = AudioPlayer();

  static Future<bool> playAudio(String assetPath) async {
    if (_player.playing && _currentlyPlayingAsset == assetPath) return true;

    await _player.setAudioSource(AudioSource.asset(assetPath));
    await _player.play();
    _currentlyPlayingAsset = assetPath;

    return false;
  }

  static Future cancelAudio() async {
    await _player.stop();
  }
}
