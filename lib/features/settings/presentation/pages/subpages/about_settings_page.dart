import 'package:flutter/material.dart';
import 'package:turtle/core/widgets/content_card.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), centerTitle: false),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ContentCard(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              padding: EdgeInsets.zero,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildListTile(
                    context,
                    title: 'README',
                    subtitle: 'Check the GitHub repository and the README',
                    icon: Icons.description_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReadmePage()),
                    ),
                  ),
                  _buildListTile(
                    context,
                    title: 'GitHub issue',
                    subtitle:
                        'Submit an issue for bug report or feature request',
                    icon: Icons.help_outline_rounded,
                    onTap: () =>
                        _launch('https://github.com/hamas/Turtle/issues'),
                  ),
                  _buildListTile(
                    context,
                    title: 'Credits',
                    subtitle: 'Credits and libre software',
                    icon: Icons.auto_awesome_outlined,
                    onTap: () => _launch('https://github.com/hamas'),
                  ),

                  const SizedBox(height: 16),

                  // Version
                  _buildListTile(
                    context,
                    title: 'Version',
                    subtitle: '1.0.0',
                    icon: Icons.info_outline_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class ReadmePage extends StatelessWidget {
  const ReadmePage({super.key});

  static const _readmeContent = '''
# Turtle 🐢

Turtle is a powerful, feature-rich media downloader focused on privacy, aesthetics, and ease of use. It allows you to download videos and audio from various platforms securely and efficiently.

## Features ✨

### 🛡️ Privacy & Security
- **Secure Downloads:** All network traffic is encrypted (HTTPS enforced).
- **Incognito Mode:** Download content without saving history.
- **Privacy Focused:** Minimal permissions required.

### 🚀 Smart & Efficient
- **Smart Clipboard Detection:** Auto-detects copied links (YouTube, Instagram) on app resume and offers immediate download.
- **WiFi-Only Mode:** Option to restrict downloads to WiFi networks to save mobile data.
- **Background Downloads:** Reliable background downloading service.

### 📺 Rich Media Experience
- **In-App Player:** Watch your downloaded videos directly within the app using the built-in PIP-capable player.
- **High Quality:** Support for HD video and high-bitrate audio downloads.
- **Format Selection:** Choose your preferred video and audio formats.

### 🎨 Beautiful Design
- **Material 3:** Modern, adaptive UI with dynamic color support.
- **Dark Mode:** System-aware light and dark themes.
- **Intuitive Navigation:** Custom expressive navigation bar.

## Customization & Technology

- **Framework:** Flutter
- **State Management:** Riverpod
- **Architecture:** Feature-First (Clean Architecture)
- **Local Storage:** SharedPreferences & SQLite
- **Video Engine:** YoutubeExplode & FFmpeg
- **Player:** Chewie & Video Player

## Getting Started

Check out the full documentation and source code on GitHub:
https://github.com/hamas/Turtle

## License 📄

This project is licensed under the MIT License.

---
**Created by Hamas**  
📧 hamasdmc@gmail.com
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('README'), centerTitle: false),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ContentCard(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _readmeContent,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
