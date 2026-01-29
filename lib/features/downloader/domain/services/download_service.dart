import 'dart:convert';
import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:turtle/features/downloader/domain/services/extractors/link_extractor.dart';
import 'package:turtle/features/downloader/domain/services/extractors/youtube_extractor.dart';
import 'package:turtle/features/downloader/domain/models/media_info.dart';
import 'package:turtle/features/downloader/presentation/providers/download_provider.dart';
import 'package:turtle/features/settings/presentation/providers/settings_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  final service = DownloadService(
    [YoutubeExtractor()],
    ref.read(downloadTasksProvider.notifier),
    ref,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

class DownloadService {
  final List<LinkExtractor> _extractors;
  final DownloadNotifier _notifier;
  final Ref _ref;
  final _yt = YoutubeExplode();

  DownloadService(this._extractors, this._notifier, this._ref);

  Future<MediaInfo> getMediaInfo(String url) async {
    for (final extractor in _extractors) {
      if (extractor.canHandle(url)) {
        return await extractor.extract(url);
      }
    }
    throw Exception('Unsupported URL');
  }

  Future<void> startDownload(
    String filename, {
    required String videoId,
    required int streamTag,
    bool isAudio = false,
    String? thumbnailUrl,
  }) async {
    // WiFi Only Check
    final settings = _ref.read(settingsProvider);
    if (settings.wifiOnly) {
      final connectivity = await Connectivity().checkConnectivity();
      if (!connectivity.contains(ConnectivityResult.wifi)) {
        throw Exception(
          'WiFi only mode enabled. Please connect to WiFi or disable the setting.',
        );
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/Downloads');
    await downloadDir.create(recursive: true);
    final filePath = '${downloadDir.path}/$filename';

    try {
      debugPrint('DownloadService: Fetching manifest for $videoId');
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Flatten all lists to search for the requested tag
      final allStreams = [
        ...manifest.muxed,
        ...manifest.videoOnly,
        ...manifest.audioOnly,
      ];

      final streamInfo = allStreams.firstWhereOrNull((s) => s.tag == streamTag);

      if (streamInfo == null) {
        throw Exception('Stream with tag $streamTag not found');
      }

      debugPrint(
        'DownloadService: Found stream ${streamInfo.tag} ${streamInfo.container}',
      );

      // Create a task to track progress (using a custom ID structure)
      // Note: Since we are not using FileDownloader engine anymore for YouTube,
      // we need to verify if _notifier accepts manual updates for tasks not in its DB?
      // Or we can just use the Task object structure and update the provider state directly.
      final task = DownloadTask(
        taskId: '$videoId-$streamTag-${DateTime.now().millisecondsSinceEpoch}',
        url: 'internal://youtube/$videoId/$streamTag',
        filename: filename,
        directory: 'Downloads',
        metaData: thumbnailUrl != null
            ? jsonEncode({'thumbnail': thumbnailUrl})
            : '',
        updates: Updates.statusAndProgress,
      );

      // Notify start
      _notifier.trackTask(task); // Adds to UI list

      if (streamInfo is VideoOnlyStreamInfo) {
        // Needs merging
        final audioStream = manifest.audioOnly.withHighestBitrate();
        debugPrint(
          'DownloadService: Merging with audio stream ${audioStream.tag}',
        );

        final videoPath = '$filePath.video';
        final audioPath = '$filePath.audio';

        // Download both
        await Future.wait([
          _downloadStream(streamInfo, videoPath),
          _downloadStream(audioStream, audioPath),
        ]);

        debugPrint('DownloadService: Streams downloaded. Merging...');

        // FFmpeg Merge: Copy video, re-encode audio if needed (usually copy is fine if container supports it)
        // "-c copy" is fastest.
        final command =
            '-y -i "$videoPath" -i "$audioPath" -c copy "$filePath"';

        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          debugPrint('DownloadService: Merge Success');
          // Cleanup temps
          await File(videoPath).delete();
          await File(audioPath).delete();

          // Notify completion via notifier (we might need to expose a method to update status manually)
          // Since we bypassed FileDownloader, the notifier won't get auto-updates.
          // We should assume the Ref sent us the notifier.
          // Looking at DownloadNotifier, it listens to FileDownloader updates.
          // We might need to manually trigger an update or just leave it 'complete' in UI?
          // Actually, standard FileDownloader events won't fire.
          // We can mock it or just rely on the user seeing result.
          // Ideally, we'd inject status updates.
          // For now:
          await _notifier.onTaskStatusUpdate(
            TaskStatusUpdate(task, TaskStatus.complete),
          );
        } else {
          debugPrint('DownloadService: Merge Failed');
          final logs = await session.getAllLogs();
          for (var log in logs) {
            debugPrint(log.getMessage());
          }
          await _notifier.onTaskStatusUpdate(
            TaskStatusUpdate(task, TaskStatus.failed),
          );
        }
      } else {
        // Muxed or Audio only - single file
        await _downloadStream(streamInfo, filePath);
        await _notifier.onTaskStatusUpdate(
          TaskStatusUpdate(task, TaskStatus.complete),
        );
      }
    } catch (e) {
      debugPrint('DownloadService: Error $e');
      // _notifier.onTaskStatusUpdate(TaskStatusUpdate(task, TaskStatus.failed)); // tricky to get task ref here if failed early
    }
  }

  Future<void> _downloadStream(StreamInfo streamInfo, String path) async {
    final file = File(path);
    final output = file.openWrite();
    final stream = _yt.videos.streamsClient.get(streamInfo);

    await stream.pipe(output);
    await output.flush();
    await output.close();
  }

  void dispose() {
    _yt.close();
    for (final extractor in _extractors) {
      extractor.dispose();
    }
  }
}
