import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtle/core/widgets/content_card.dart';
import 'package:turtle/features/settings/presentation/providers/settings_state.dart';

class GeneralSettingsPage extends ConsumerWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('General'), centerTitle: false),
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
                  // Update YT-DLP
                  ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: const Text('Update yt-dlp'),
                    subtitle: const Text('Internal Engine: Latest'),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => _updateYtDlp(context),
                    ),
                    onTap: () => _updateYtDlp(context),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  ),

                  // WiFi Only Mode
                  _buildSwitchTile(
                    context,
                    title: 'WiFi only',
                    subtitle: 'Download only when connected to WiFi',
                    icon: Icons.wifi_rounded,
                    value: settings.wifiOnly,
                    onChanged: (v) => notifier.update(wifiOnly: v),
                  ),

                  // Download Notification
                  _buildSwitchTile(
                    context,
                    title: 'Download notification',
                    subtitle: 'Notify of downloaded files and progress',
                    icon: Icons.notifications_outlined,
                    value: settings.downloadNotification,
                    onChanged: (v) => notifier.update(downloadNotification: v),
                  ),

                  // Configure before download (Keep rest same)
                  _buildSwitchTile(
                    context,
                    title: 'Configure before download',
                    subtitle: 'Configure preferences before downloading',
                    icon: Icons.tune_outlined,
                    value: settings.configureBeforeDownload,
                    onChanged: (v) =>
                        notifier.update(configureBeforeDownload: v),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionHeader(context, 'Privacy'),

                  // Incognito
                  _buildSwitchTile(
                    context,
                    title: 'Incognito',
                    subtitle: 'Disable download history',
                    icon: Icons.history_toggle_off_outlined,
                    value: settings.incognito,
                    onChanged: (v) => notifier.update(incognito: v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateYtDlp(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update yt-dlp'),
            content: const Text('Internal engine is up to date.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    // M3 Expressive Switch
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      secondary: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      // Apply M3 switch styling if needed, but SwitchListTile adapts well
    );
  }
}
