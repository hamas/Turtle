import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtle/core/widgets/expressive_widgets.dart';
import 'package:turtle/features/downloader/domain/models/media_info.dart';
import 'package:turtle/features/downloader/presentation/providers/media_provider.dart';
import 'package:turtle/features/downloader/domain/services/download_service.dart';
import 'package:collection/collection.dart';
import 'package:turtle/core/widgets/content_card.dart';

class SelectFormatPage extends ConsumerStatefulWidget {
  const SelectFormatPage({super.key});

  @override
  ConsumerState<SelectFormatPage> createState() => _SelectFormatPageState();
}

class _SelectFormatPageState extends ConsumerState<SelectFormatPage> {
  String _selectedFilter = 'Suggested'; // 'Suggested', 'Video', 'Audio'

  // Note: Only 'Suggested' contains Muxed streams in this logic to simplify for user
  // 'Video' will be Video-only streams
  // 'Audio' will be Audio-only streams

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(mediaInfoProvider);
    // Listen to provider changes (keeping for safety, though FAB is gone)
    // ref.listen(selectedStreamIdProvider, (_, __) => _updateFABState(ref));

    if (info == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Format')),
        body: const Center(child: Text('No media info available')),
      );
    }

    final selectedId = ref.watch(selectedStreamIdProvider);
    final isEnabled = selectedId != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Select Format',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Actions removed as requested
        actions: const [],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: _buildMediaHeader(context, info),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildFilterChips(context),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ContentCard(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildFilteredGrid(context, ref, info),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // Big Download Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: FilledButton(
              onPressed: isEnabled ? () => _handleDownload(context, ref) : null,
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll<Size>(
                  Size.fromHeight(64), // Matches Home Toolbar Height
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return const Color(0xFF424242); // Dark Grey
                  }
                  return colorScheme.primary;
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.white.withValues(alpha: 0.38);
                  }
                  return colorScheme.primary.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white;
                }),
                shape: WidgetStatePropertyAll<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
              child: const Text(
                'Download',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, 'Suggested'),
          const SizedBox(width: 8),
          _buildChip(context, 'Video'),
          const SizedBox(width: 8),
          _buildChip(context, 'Audio'),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      showCheckmark: false,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
      elevation: 0,
      pressElevation: 0,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    );
  }

  Widget _buildFilteredGrid(
    BuildContext context,
    WidgetRef ref,
    MediaInfo info,
  ) {
    List<dynamic> streams = [];
    bool isAudioOnly = false;
    bool isMuxed = false;

    if (_selectedFilter == 'Suggested') {
      // Combine best video options
      streams = info.muxedStreams;
      isMuxed = true;
    } else if (_selectedFilter == 'Video') {
      streams = info.videoOnlyStreams;
      // isMuxed remains false
    } else if (_selectedFilter == 'Audio') {
      streams = info.audioOnlyStreams;
      isAudioOnly = true;
    }

    if (streams.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No formats available for $_selectedFilter',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return _buildFormatGrid(
      context,
      ref,
      streams,
      false,
      isAudioOnly: isAudioOnly,
      isMuxed: isMuxed,
    );
  }

  Widget _buildMediaHeader(BuildContext context, MediaInfo info) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            info.thumbnailUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 100,
              height: 100,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.broken_image_rounded),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                info.author,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (info.duration != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDuration(info.duration!),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Widget _buildFormatGrid(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> streams,
    bool isLarge, {
    bool isAudioOnly = false,
    bool isMuxed = false,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLarge ? 1 : 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: isLarge ? 100 : 110,
      ),
      itemCount: streams.length,
      itemBuilder: (context, index) {
        final s = streams[index];
        final isSelected = ref.watch(selectedStreamIdProvider) == s.id;

        String title = '';
        String subtitle = '';
        String formatInfo = '';
        final hasVideo = !isAudioOnly;
        final hasAudio = isAudioOnly || isMuxed;

        if (s is VideoStreamInfo) {
          title = '${s.id} - ${s.qualityLabel}';
          subtitle =
              '${_formatSize(s.size)}\n${s.bitrateMbps.toStringAsFixed(2)} Mbps';
          formatInfo = '${s.container} (${s.codec})';
        } else if (s is AudioStreamInfo) {
          title = '${s.id} - audio only';
          subtitle = '${_formatSize(s.size)}\n${s.bitrateKbps} Kbps';
          formatInfo = '${s.container} (${s.codec})';
        }

        return FormatCard(
          title: title,
          subtitle: subtitle,
          info: formatInfo,
          isSelected: isSelected,
          hasVideo: hasVideo,
          hasAudio: hasAudio,
          onTap: () {
            ref.read(selectedStreamIdProvider.notifier).state = s.id;
            ref.read(selectedStreamTypeProvider.notifier).state = isAudioOnly
                ? 'audio'
                : (isMuxed ? 'muxed' : 'video');
          },
        );
      },
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _handleDownload(BuildContext context, WidgetRef ref) async {
    final info = ref.read(mediaInfoProvider);
    final selectedId = ref.read(selectedStreamIdProvider);
    final selectedType = ref.read(selectedStreamTypeProvider);

    if (info == null || selectedId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a format')));
      return;
    }

    String extension = '';

    if (selectedType == 'audio') {
      final s = info.audioOnlyStreams.firstWhereOrNull(
        (s) => s.id == selectedId,
      );
      if (s == null) return;
      extension = s.container.toLowerCase();
    } else if (selectedType == 'muxed') {
      final s = info.muxedStreams.firstWhereOrNull((s) => s.id == selectedId);
      if (s == null) return;
      extension = s.container.toLowerCase();
    } else {
      final s = info.videoOnlyStreams.firstWhereOrNull(
        (s) => s.id == selectedId,
      );
      if (s == null) return;
      extension = s.container.toLowerCase();
    }

    final sanitizedTitle = info.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final filename = '$sanitizedTitle.$extension';

    final service = ref.read(downloadServiceProvider);

    // Parse stream tag from ID (assuming ID is the tag string)
    final streamTag = int.tryParse(selectedId);

    if (streamTag != null) {
      await service.startDownload(
        filename,
        videoId: info.videoId,
        streamTag: streamTag,
        thumbnailUrl: info.thumbnailUrl,
      );
    } else {
      // Fallback or error?
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid stream ID')));
      return;
    }

    if (!context.mounted) return;

    // Go back to home
    Navigator.pop(context);

    // Clear selection
    ref.read(selectedStreamIdProvider.notifier).state = null;
    ref.read(selectedStreamTypeProvider.notifier).state = null;
    ref.read(mediaInfoProvider.notifier).state = null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting download: $filename'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
