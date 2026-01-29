class MediaInfo {
  final String videoId;
  final String title;
  final String author;
  final String thumbnailUrl;
  final Duration? duration;
  final List<VideoStreamInfo> muxedStreams;
  final List<VideoStreamInfo> videoOnlyStreams;
  final List<AudioStreamInfo> audioOnlyStreams;

  MediaInfo({
    required this.videoId,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    this.duration,
    required this.muxedStreams,
    required this.videoOnlyStreams,
    required this.audioOnlyStreams,
  });
}

class VideoStreamInfo {
  final String id;
  final String url;
  final String qualityLabel;
  final String codec;
  final String container;
  final int size;
  final double bitrateMbps;

  VideoStreamInfo({
    required this.id,
    required this.url,
    required this.qualityLabel,
    required this.codec,
    required this.container,
    required this.size,
    required this.bitrateMbps,
  });
}

class AudioStreamInfo {
  final String id;
  final String url;
  final int bitrateKbps;
  final String codec;
  final String container;
  final int size;

  AudioStreamInfo({
    required this.id,
    required this.url,
    required this.bitrateKbps,
    required this.codec,
    required this.container,
    required this.size,
  });
}
