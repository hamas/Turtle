import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtle/features/downloader/domain/models/media_info.dart';

class MediaInfoNotifier extends Notifier<MediaInfo?> {
  @override
  MediaInfo? build() => null;
  @override
  set state(MediaInfo? value) => super.state = value;
}

final mediaInfoProvider = NotifierProvider<MediaInfoNotifier, MediaInfo?>(
  MediaInfoNotifier.new,
);

class IsExtractingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  @override
  set state(bool value) => super.state = value;
}

final isExtractingProvider = NotifierProvider<IsExtractingNotifier, bool>(
  IsExtractingNotifier.new,
);

class SelectedStreamIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  @override
  set state(String? value) => super.state = value;
}

final selectedStreamIdProvider =
    NotifierProvider<SelectedStreamIdNotifier, String?>(
      SelectedStreamIdNotifier.new,
    );

class SelectedStreamTypeNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  @override
  set state(String? value) => super.state = value;
}

final selectedStreamTypeProvider =
    NotifierProvider<SelectedStreamTypeNotifier, String?>(
      SelectedStreamTypeNotifier.new,
    );
