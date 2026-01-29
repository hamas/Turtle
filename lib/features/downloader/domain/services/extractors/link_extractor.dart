import 'package:turtle/features/downloader/domain/models/media_info.dart';

abstract class LinkExtractor {
  bool canHandle(String url);
  Future<MediaInfo> extract(String url);
  void dispose();
}
