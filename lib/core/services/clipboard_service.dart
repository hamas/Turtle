import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtle/features/home/presentation/pages/main_scaffold.dart';
import 'package:turtle/features/home/presentation/providers/home_providers.dart';

class ClipboardService {
  String? _lastCheckedContent;

  Future<void> checkClipboard(WidgetRef ref, BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final content = data?.text;

    if (content == null || content.isEmpty || content == _lastCheckedContent) {
      return;
    }

    _lastCheckedContent = content;

    // Regex for YouTube/Instagram typical links
    // YouTube: youtube.com, youtu.be
    // Instagram: instagram.com
    final youtubeRegex = RegExp(
      r'(https?://)?(www\.)?(youtube\.com|youtu\.be)/.+',
    );
    final instagramRegex = RegExp(r'(https?://)?(www\.)?instagram\.com/.+');

    if (youtubeRegex.hasMatch(content) || instagramRegex.hasMatch(content)) {
      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Link Detected'),
          content: Text('Do you want to download this link?\n\n$content'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(c);
                // 1. Set URL in provider
                ref.read(clipboardUrlProvider.notifier).setUrl(content);
                // 2. Navigate to Home (index 0)
                ref.read(navigationIndexProvider.notifier).state = 0;
              },
              child: const Text('Download'),
            ),
          ],
        ),
      );
    }
  }
}

final clipboardServiceProvider = Provider((ref) => ClipboardService());
