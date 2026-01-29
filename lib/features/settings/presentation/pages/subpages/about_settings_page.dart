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
                    onTap: () => _launch(
                      'https://github.com/hamas/Turtle/blob/main/README.md',
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
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),

                  // Version
                  _buildListTile(
                    context,
                    title: 'Version',
                    subtitle: '1.0.0+1',
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
