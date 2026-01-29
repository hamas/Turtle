import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtle/features/settings/presentation/providers/settings_providers.dart';

// Simple immutable state class
class SettingsState {
  // General
  final bool downloadNotification;
  final bool configureBeforeDownload;
  final bool saveThumbnail;
  final bool detailedOutput;
  final bool incognito; // Privacy
  final bool disablePreview; // Privacy
  final bool downloadPlaylist; // Advanced
  final bool downloadArchive; // Advanced
  final bool sponsorBlock; // Advanced
  final bool wifiOnly; // Advanced

  // Format
  final bool saveAsAudio;
  final String preferredAudioFormat; // e.g. 'mp3', 'm4a', 'best'
  final String audioQuality; // e.g. 'best', '320k'
  final bool convertAudioFormat;
  final bool embedMetadata;
  final bool cropArtwork;
  final String preferredVideoFormat; // e.g. 'mp4', 'webm'
  final String videoQuality; // e.g. '2160p', '1080p'
  final bool remuxVideoContainer;
  final bool subtitle;

  const SettingsState({
    this.downloadNotification = true,
    this.configureBeforeDownload = false,
    this.saveThumbnail = false,
    this.detailedOutput = false,
    this.incognito = false,
    this.disablePreview = false,
    this.downloadPlaylist = false,
    this.downloadArchive = false,
    this.sponsorBlock = false,
    this.wifiOnly = false,
    this.saveAsAudio = false,
    this.preferredAudioFormat = 'Not specified (default)',
    this.audioQuality = 'Unlimited',
    this.convertAudioFormat = false,
    this.embedMetadata = true,
    this.cropArtwork = false,
    this.preferredVideoFormat = 'Quality',
    this.videoQuality = 'Best quality',
    this.remuxVideoContainer = false,
    this.subtitle = false,
  });

  SettingsState copyWith({
    bool? downloadNotification,
    bool? configureBeforeDownload,
    bool? saveThumbnail,
    bool? detailedOutput,
    bool? incognito,
    bool? disablePreview,
    bool? downloadPlaylist,
    bool? downloadArchive,
    bool? sponsorBlock,
    bool? wifiOnly,
    bool? saveAsAudio,
    String? preferredAudioFormat,
    String? audioQuality,
    bool? convertAudioFormat,
    bool? embedMetadata,
    bool? cropArtwork,
    String? preferredVideoFormat,
    String? videoQuality,
    bool? remuxVideoContainer,
    bool? subtitle,
  }) {
    return SettingsState(
      downloadNotification: downloadNotification ?? this.downloadNotification,
      configureBeforeDownload:
          configureBeforeDownload ?? this.configureBeforeDownload,
      saveThumbnail: saveThumbnail ?? this.saveThumbnail,
      detailedOutput: detailedOutput ?? this.detailedOutput,
      incognito: incognito ?? this.incognito,
      disablePreview: disablePreview ?? this.disablePreview,
      downloadPlaylist: downloadPlaylist ?? this.downloadPlaylist,
      downloadArchive: downloadArchive ?? this.downloadArchive,
      sponsorBlock: sponsorBlock ?? this.sponsorBlock,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      saveAsAudio: saveAsAudio ?? this.saveAsAudio,
      preferredAudioFormat: preferredAudioFormat ?? this.preferredAudioFormat,
      audioQuality: audioQuality ?? this.audioQuality,
      convertAudioFormat: convertAudioFormat ?? this.convertAudioFormat,
      embedMetadata: embedMetadata ?? this.embedMetadata,
      cropArtwork: cropArtwork ?? this.cropArtwork,
      preferredVideoFormat: preferredVideoFormat ?? this.preferredVideoFormat,
      videoQuality: videoQuality ?? this.videoQuality,
      remuxVideoContainer: remuxVideoContainer ?? this.remuxVideoContainer,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'downloadNotification': downloadNotification,
      'configureBeforeDownload': configureBeforeDownload,
      'saveThumbnail': saveThumbnail,
      'detailedOutput': detailedOutput,
      'incognito': incognito,
      'disablePreview': disablePreview,
      'downloadPlaylist': downloadPlaylist,
      'downloadArchive': downloadArchive,
      'sponsorBlock': sponsorBlock,
      'wifiOnly': wifiOnly,
      'saveAsAudio': saveAsAudio,
      'preferredAudioFormat': preferredAudioFormat,
      'audioQuality': audioQuality,
      'convertAudioFormat': convertAudioFormat,
      'embedMetadata': embedMetadata,
      'cropArtwork': cropArtwork,
      'preferredVideoFormat': preferredVideoFormat,
      'videoQuality': videoQuality,
      'remuxVideoContainer': remuxVideoContainer,
      'subtitle': subtitle,
    };
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      downloadNotification: map['downloadNotification'] ?? true,
      configureBeforeDownload: map['configureBeforeDownload'] ?? false,
      saveThumbnail: map['saveThumbnail'] ?? false,
      detailedOutput: map['detailedOutput'] ?? false,
      incognito: map['incognito'] ?? false,
      disablePreview: map['disablePreview'] ?? false,
      downloadPlaylist: map['downloadPlaylist'] ?? false,
      downloadArchive: map['downloadArchive'] ?? false,
      sponsorBlock: map['sponsorBlock'] ?? false,
      wifiOnly: map['wifiOnly'] ?? false,
      saveAsAudio: map['saveAsAudio'] ?? false,
      preferredAudioFormat:
          map['preferredAudioFormat'] ?? 'Not specified (default)',
      audioQuality: map['audioQuality'] ?? 'Unlimited',
      convertAudioFormat: map['convertAudioFormat'] ?? false,
      embedMetadata: map['embedMetadata'] ?? true,
      cropArtwork: map['cropArtwork'] ?? false,
      preferredVideoFormat: map['preferredVideoFormat'] ?? 'Quality',
      videoQuality: map['videoQuality'] ?? 'Best quality',
      remuxVideoContainer: map['remuxVideoContainer'] ?? false,
      subtitle: map['subtitle'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingsState.fromJson(String source) =>
      SettingsState.fromMap(json.decode(source));
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _settingsKey = 'app_settings';

  @override
  SettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_settingsKey);
    if (jsonStr != null) {
      try {
        return SettingsState.fromJson(jsonStr);
      } catch (e) {
        // Fallback if parsing fails
        return const SettingsState();
      }
    }
    return const SettingsState();
  }

  void _save(SettingsState newState) {
    state = newState;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_settingsKey, newState.toJson());
  }

  void update({
    bool? downloadNotification,
    bool? configureBeforeDownload,
    bool? saveThumbnail,
    bool? detailedOutput,
    bool? incognito,
    bool? disablePreview,
    bool? downloadPlaylist,
    bool? downloadArchive,
    bool? sponsorBlock,
    bool? wifiOnly,
    bool? saveAsAudio,
    String? preferredAudioFormat,
    String? audioQuality,
    bool? convertAudioFormat,
    bool? embedMetadata,
    bool? cropArtwork,
    String? preferredVideoFormat,
    String? videoQuality,
    bool? remuxVideoContainer,
    bool? subtitle,
  }) {
    final newState = state.copyWith(
      downloadNotification: downloadNotification,
      configureBeforeDownload: configureBeforeDownload,
      saveThumbnail: saveThumbnail,
      detailedOutput: detailedOutput,
      incognito: incognito,
      disablePreview: disablePreview,
      downloadPlaylist: downloadPlaylist,
      downloadArchive: downloadArchive,
      sponsorBlock: sponsorBlock,
      wifiOnly: wifiOnly,
      saveAsAudio: saveAsAudio,
      preferredAudioFormat: preferredAudioFormat,
      audioQuality: audioQuality,
      convertAudioFormat: convertAudioFormat,
      embedMetadata: embedMetadata,
      cropArtwork: cropArtwork,
      preferredVideoFormat: preferredVideoFormat,
      videoQuality: videoQuality,
      remuxVideoContainer: remuxVideoContainer,
      subtitle: subtitle,
    );
    _save(newState);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
