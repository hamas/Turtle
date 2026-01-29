import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtle/core/widgets/expressive_widgets.dart';
import 'package:turtle/core/widgets/m3_loading_indicator.dart';
import 'package:turtle/features/downloader/domain/services/download_service.dart';
import 'package:turtle/features/downloader/presentation/providers/download_provider.dart';
import 'package:turtle/features/downloader/presentation/providers/fab_provider.dart';
import 'package:turtle/features/downloader/presentation/providers/media_provider.dart';
import 'package:turtle/features/downloader/presentation/pages/select_format_page.dart';
import 'package:turtle/features/downloader/domain/models/media_info.dart';
import 'package:turtle/features/settings/presentation/providers/settings_state.dart';
import 'package:flutter/services.dart';

import 'package:turtle/core/widgets/content_card.dart';
import 'package:turtle/features/home/presentation/providers/home_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _urlController = TextEditingController();
  MediaInfo? _cachedMediaInfo;
  Future<MediaInfo?>? _pendingFetch;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(() {
      setState(() {}); // Update FAB state when text changes
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateFABState(ref);

    // Listen to mediaInfoProvider to trigger navigation
    ref.listen(mediaInfoProvider, (previous, next) {
      if (next != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SelectFormatPage()),
        ).then((_) {
          // Reset providers when back from Select Format Page
          ref.read(mediaInfoProvider.notifier).state = null;
        });
      }
    });

    // Listen to clipboard URL injection
    ref.listen<String?>(clipboardUrlProvider, (previous, next) {
      if (next != null) {
        _urlController.text = next;
        _startBackgroundFetch(next);
        // Reset provider
        ref.read(clipboardUrlProvider.notifier).clear();
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Turtle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [],
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
              ), // Added top margin
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Grab Your Content',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Paste a link to save your favorite video or audio instantly.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SearchBar(
                      controller: _urlController,
                      constraints: const BoxConstraints(minHeight: 72.0),
                      padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      onTap: () {},
                      onChanged: (value) async {
                        if (value.isNotEmpty) _startBackgroundFetch(value);
                      },
                      leading: const Icon(
                        Icons.search_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                      trailing: [
                        if (_urlController.text.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _urlController.clear();
                              _cachedMediaInfo = null;
                              _pendingFetch = null;
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear_rounded),
                          ),
                      ],
                      hintText: 'Paste link here...',
                      hintStyle: WidgetStatePropertyAll<TextStyle?>(
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      textStyle: WidgetStatePropertyAll<TextStyle?>(
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      elevation: const WidgetStatePropertyAll<double>(0),
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Colors.black.withValues(alpha: 0.3),
                      ),
                      shape: const WidgetStatePropertyAll<OutlinedBorder>(
                        StadiumBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: _urlController.text.isNotEmpty
                              ? () => _handleDownloadPress()
                              : null,
                          style: ButtonStyle(
                            minimumSize: const WidgetStatePropertyAll<Size>(
                              Size(0, 48),
                            ),
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return const Color(0xFF424242); // Dark Grey
                                  }
                                  return Theme.of(context).colorScheme.primary;
                                }),
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Colors.white.withValues(alpha: 0.38);
                                  }
                                  final primary = Theme.of(
                                    context,
                                  ).colorScheme.primary;
                                  return primary.computeLuminance() > 0.5
                                      ? Colors.black
                                      : Colors.white;
                                }),
                            padding: const WidgetStatePropertyAll<EdgeInsets>(
                              EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            shape: WidgetStatePropertyAll<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          child: Text(
                            'Download',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  // Color is handled by foregroundColor
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTopDownloadProgress(ref),
                    if (ref.watch(isExtractingProvider))
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: M3LoadingIndicator(),
                        ),
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

  void _updateFABState(WidgetRef ref) {
    final isExtracting = ref.watch(isExtractingProvider);
    final isFabEnabled = !isExtracting;

    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(fabProvider.notifier)
          .set(
            FABState(
              icon: Icons.content_paste_rounded,
              isEnabled: isFabEnabled,
              onPressed: _handlePaste,
              key: const ValueKey('paste_fab'),
            ),
          );
    });
  }

  Widget _buildTopDownloadProgress(WidgetRef ref) {
    final tasks = ref.watch(downloadTasksProvider);
    if (tasks.isEmpty) return const SizedBox.shrink();

    final progress = tasks.values.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WavyProgressIndicator(value: progress),
          const SizedBox(height: 4),
          Text(
            'Downloading: ${(progress * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Background Fetch Logic ---

  void _startBackgroundFetch(String url) {
    // Clear old cache
    _cachedMediaInfo = null;
    final service = ref.read(downloadServiceProvider);

    // Start silent fetch
    _pendingFetch = service
        .getMediaInfo(url)
        .then<MediaInfo?>((info) {
          if (mounted) {
            _cachedMediaInfo = info;
          }
          return info;
        })
        .catchError((e) {
          // Ignore errors in background, they will be caught when user clicks download
          return null;
        });
  }

  void _handleDownloadPress() async {
    final url = _urlController.text;
    if (url.isEmpty) return;

    final settings = ref.read(settingsProvider); // Read settings

    ref.read(isExtractingProvider.notifier).state = true;

    try {
      MediaInfo? info;
      if (_cachedMediaInfo != null) {
        info = _cachedMediaInfo;
      } else if (_pendingFetch != null) {
        info = await _pendingFetch;
      } else {
        final service = ref.read(downloadServiceProvider);
        info = await service.getMediaInfo(url);
      }

      if (info != null && mounted) {
        if (settings.configureBeforeDownload) {
          // Navigate to Selection Page (Default behavior)
          ref.read(mediaInfoProvider.notifier).state = info;
        } else {
          // Quick Download: Pick best muxed stream
          final bestStream = _getBestMuxedStream(info);
          if (bestStream != null) {
            final sanitizedTitle = info.title.replaceAll(
              RegExp(r'[\\/:*?"<>|]'),
              '_',
            );
            final filename =
                '$sanitizedTitle.${bestStream.container.toLowerCase()}';

            final service = ref.read(downloadServiceProvider);
            final streamTag = int.tryParse(bestStream.id);
            if (streamTag != null) {
              await service.startDownload(
                filename,
                videoId: info.videoId,
                streamTag: streamTag,
                thumbnailUrl: info.thumbnailUrl,
              );
            } else {
              // Should not happen if id is properly set from tag
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error parsing stream ID')),
              );
              return;
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Starting download: $filename'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            // Clear input after success
            _urlController.clear();
            _cachedMediaInfo = null;
            _pendingFetch = null;
            setState(() {});
          } else {
            // Fallback if no stream found
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No suitable format found for Quick Download.'),
              ),
            );
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not fetch media info. Please check the URL.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        ref.read(isExtractingProvider.notifier).state = false;
      }
    }
  }

  VideoStreamInfo? _getBestMuxedStream(MediaInfo info) {
    if (info.muxedStreams.isEmpty) return null;
    // Sort by size (proxy for quality) descending, or bitrate
    // Using size as simple proxy for 'best' assuming correlated with resolution/bitrate
    final sorted = List<VideoStreamInfo>.from(info.muxedStreams);
    sorted.sort((a, b) => b.size.compareTo(a.size));
    return sorted.first;
  }

  void _handlePaste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _urlController.text = data!.text!;
      // Trigger background fetch on paste
      _startBackgroundFetch(data.text!);
    }
  }
}
