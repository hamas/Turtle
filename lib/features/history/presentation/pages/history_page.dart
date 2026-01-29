import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:turtle/features/downloader/presentation/providers/download_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:turtle/core/widgets/content_card.dart';
import 'package:turtle/features/player/presentation/pages/video_player_page.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String _selectedFilter = 'All'; // 'All', 'Completed', 'Failed'

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(downloadHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [_buildFilterChips(context), const SizedBox(width: 16)],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ContentCard(
              margin: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                128,
              ), // Clear toolbar (48+64+16)
              child: historyAsync.when(
                data: (records) {
                  final filteredRecords = _filterRecords(records);
                  if (filteredRecords.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.separated(
                    padding: EdgeInsets.zero, // Use Card internal padding
                    itemCount: filteredRecords.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return _buildHistoryItem(context, record, ref);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error loading history: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TaskRecord> _filterRecords(List<TaskRecord> records) {
    // Sort by creation time descending (newest first)
    final sorted = List<TaskRecord>.from(records);
    sorted.sort((a, b) => b.task.creationTime.compareTo(a.task.creationTime));

    if (_selectedFilter == 'All') return sorted;

    return sorted.where((record) {
      if (_selectedFilter == 'Completed') {
        return record.status == TaskStatus.complete;
      } else if (_selectedFilter == 'Failed') {
        return record.status == TaskStatus.failed ||
            record.status == TaskStatus.canceled ||
            record.status == TaskStatus.notFound;
      }
      return true;
    }).toList();
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildChip(context, 'All'),
          const SizedBox(width: 6),
          _buildChip(context, 'Completed'),
          const SizedBox(width: 6),
          _buildChip(context, 'Failed'),
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
          fontSize: 11,
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
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      pressElevation: 0,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    TaskRecord record,
    WidgetRef ref,
  ) {
    final task = record.task;
    final isComplete = record.status == TaskStatus.complete;

    // Parse Thumbnail
    String? thumbnailUrl;
    try {
      if (task.metaData.isNotEmpty) {
        final json = jsonDecode(task.metaData);
        thumbnailUrl = json['thumbnail'] as String?;
      }
    } catch (e) {
      // ignore JSON errors
    }

    // No outer Card, just content
    return InkWell(
      onTap: isComplete
          ? () async {
              final path = await task.filePath();
              if (await File(path).exists()) {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerPage(filePath: path),
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File not found')),
                  );
                }
              }
            }
          : null,
      child: Row(
        children: [
          // Thumbnail - Increased by 20% (from 56 to ~68)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: thumbnailUrl != null
                ? Image.network(
                    thumbnailUrl,
                    width: 70,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _buildFallbackIcon(context, isComplete),
                  )
                : _buildFallbackIcon(context, isComplete),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? Colors.green.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isComplete ? 'Downloaded' : 'Failed',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isComplete
                          ? Colors.green
                          : Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          if (isComplete)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () async {
                final path = await task.filePath();
                if (await File(path).exists()) {
                  await SharePlus.instance.share(
                    ShareParams(files: [XFile(path)]),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context, bool isComplete) {
    return Container(
      width: 70,
      height: 50,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Icon(
        isComplete ? Icons.movie_outlined : Icons.broken_image_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 28,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No downloads yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
