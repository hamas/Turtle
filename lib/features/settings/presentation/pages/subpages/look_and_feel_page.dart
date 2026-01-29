import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtle/core/widgets/content_card.dart';
import 'package:turtle/features/settings/presentation/providers/settings_providers.dart';

class LookAndFeelPage extends ConsumerWidget {
  const LookAndFeelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Look & feel'), centerTitle: false),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ContentCard(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              padding: EdgeInsets.zero,
              child: RadioGroup<ThemeMode>(
                groupValue: currentTheme,
                onChanged: (v) => notifier.setThemeMode(v!),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildThemeOption(
                      context,
                      title: 'System default',
                      mode: ThemeMode.system,
                      onChanged: (v) => notifier.setThemeMode(v!),
                    ),
                    _buildThemeOption(
                      context,
                      title: 'Light',
                      mode: ThemeMode.light,
                      onChanged: (v) => notifier.setThemeMode(v!),
                    ),
                    _buildThemeOption(
                      context,
                      title: 'Dark',
                      mode: ThemeMode.dark,
                      onChanged: (v) => notifier.setThemeMode(v!),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required ThemeMode mode,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      leading: Radio<ThemeMode>(value: mode),
      onTap: () => onChanged(mode),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
    );
  }
}
