import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClipboardUrlNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setUrl(String url) {
    state = url;
  }

  void clear() {
    state = null;
  }
}

final clipboardUrlProvider = NotifierProvider<ClipboardUrlNotifier, String?>(
  ClipboardUrlNotifier.new,
);
