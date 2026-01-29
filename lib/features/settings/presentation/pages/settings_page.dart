import 'package:flutter/material.dart';
import 'package:turtle/core/widgets/content_card.dart';
import 'package:turtle/features/settings/presentation/pages/subpages/about_settings_page.dart';
import 'package:turtle/features/settings/presentation/pages/subpages/format_settings_page.dart';
import 'package:turtle/features/settings/presentation/pages/subpages/general_settings_page.dart';
import 'package:turtle/features/settings/presentation/pages/subpages/look_and_feel_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildBatteryConfigCard(context),
          Expanded(
            child: ContentCard(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 128),
              padding: EdgeInsets.zero,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildSettingsItem(
                    context,
                    icon: Icons.settings_rounded,
                    title: 'General',
                    subtitle: 'Yt-dlp version, notification, playlist',
                    onTap: () =>
                        _navigate(context, const GeneralSettingsPage()),
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.description_rounded,
                    title: 'Format',
                    subtitle: 'File format, video quality, subtitles',
                    onTap: () => _navigate(context, const FormatSettingsPage()),
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.palette_rounded,
                    title: 'Look & feel',
                    subtitle: 'Dark theme, dynamic color, languages',
                    onTap: () => _navigate(context, const LookAndFeelPage()),
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.info_rounded,
                    title: 'About',
                    subtitle: 'Version, feedback, auto update',
                    onTap: () => _navigate(context, const AboutSettingsPage()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildBatteryConfigCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.onSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: colorScheme.surface,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Battery configuration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ignore battery optimization for this app to download in the background',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
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
}
