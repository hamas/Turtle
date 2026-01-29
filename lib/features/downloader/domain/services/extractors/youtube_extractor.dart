import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_exp;
import 'package:turtle/features/downloader/domain/services/extractors/link_extractor.dart';
import 'package:turtle/features/downloader/domain/models/media_info.dart';

class YoutubeExtractor implements LinkExtractor {
  final _yt = yt_exp.YoutubeExplode();

  @override
  bool canHandle(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  @override
  Future<MediaInfo> extract(String url) async {
    try {
      final video = await _yt.videos.get(url);
      debugPrint('YoutubeExtractor: Fetched video: ${video.title}');
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);
      debugPrint(
        'YoutubeExtractor: Fetched manifest. Muxed: ${manifest.muxed.length}, VideoOnly: ${manifest.videoOnly.length}, AudioOnly: ${manifest.audioOnly.length}',
      );

      final muxedStreams = manifest.muxed
          .map(
            (s) => VideoStreamInfo(
              id: s.tag.toString(),
              url: s.url.toString(),
              qualityLabel: s.videoQuality.name,
              codec: s.videoCodec,
              container: s.container.name.toUpperCase(),
              size: s.size.totalBytes,
              bitrateMbps: s.bitrate.bitsPerSecond / (1024 * 1024),
            ),
          )
          .toList();

      final videoOnlyStreams = manifest.videoOnly
          .map(
            (s) => VideoStreamInfo(
              id: s.tag.toString(),
              url: s.url.toString(),
              qualityLabel: s.videoQuality.name,
              codec: s.videoCodec,
              container: s.container.name.toUpperCase(),
              size: s.size.totalBytes,
              bitrateMbps: s.bitrate.bitsPerSecond / (1024 * 1024),
            ),
          )
          .toList();

      final audioStreams = manifest.audioOnly
          .map(
            (s) => AudioStreamInfo(
              id: s.tag.toString(),
              url: s.url.toString(),
              bitrateKbps: (s.bitrate.bitsPerSecond / 1024).round(),
              codec: s.audioCodec,
              container: s.container.name.toUpperCase(),
              size: s.size.totalBytes,
            ),
          )
          .toList();

      return MediaInfo(
        videoId: video.id.value,
        title: video.title,
        author: video.author,
        thumbnailUrl: video.thumbnails.highResUrl,
        duration: video.duration,
        muxedStreams: muxedStreams,
        videoOnlyStreams: videoOnlyStreams,
        audioOnlyStreams: audioStreams,
      );
    } catch (e) {
      throw Exception('Failed to extract YouTube video: $e');
    }
  }

  @override
  void dispose() {
    _yt.close();
  }
}
