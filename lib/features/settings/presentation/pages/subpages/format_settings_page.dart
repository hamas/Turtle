import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtle/core/widgets/content_card.dart';
import 'package:turtle/features/settings/presentation/providers/settings_state.dart';

class FormatSettingsPage extends ConsumerWidget {
  const FormatSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Format'), centerTitle: false),
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
                  _buildSectionHeader(context, 'Audio'),

                  // Save as audio
                  _buildSwitchTile(
                    context,
                    title: 'Save as audio',
                    subtitle: 'Download and save audio, instead of video',
                    icon: Icons.music_note_outlined,
                    value: settings.saveAsAudio,
                    onChanged: (v) => notifier.update(saveAsAudio: v),
                  ),

                  // Audio quality
                  _buildListTile(
                    context,
                    title: 'Audio quality',
                    subtitle: settings.audioQuality,
                    icon: Icons.high_quality_outlined,
                    onTap: () {
                      // Logic
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildSectionHeader(context, 'Video'),

                  // Video quality
                  _buildListTile(
                    context,
                    title: 'Video quality',
                    subtitle: settings.videoQuality,
                    icon: Icons.hd_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
}
