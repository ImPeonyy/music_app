import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  AudioPlayerManager._internal();
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;

  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  String songUrl = "";

  void init({bool isNewSong = false}) {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
            (position, playbackEvent) => DurationState(
              progess: position,
              buffered: playbackEvent.bufferedPosition,
              total: playbackEvent.duration
            ));
    if(isNewSong) {
      player.setUrl(songUrl);
    }
  }

  void updateSongUrl(String url) {
    songUrl = url;
    init();
  }

  void dispose() {
    player.dispose();
  }
}

class DurationState {
  const DurationState({
    required this.progess,
    required this.buffered,
    this.total,
});
  final Duration progess;
  final Duration buffered;
  final Duration? total;
}