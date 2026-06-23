import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../audio/audio_providers.dart';
import '../enrichment/enrichment_controller.dart';
import '../settings/settings_screen.dart';
import '../widgets/mini_player.dart';
import 'songs_provider.dart';

/// The home screen: every track on the device. Tap to play; the recommender
/// autoplays the next song when one ends. "Scan & enrich" populates the feature
/// vectors the recommender needs.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);
    final currentSong = ref.watch(currentSongProvider);
    final progress = ref.watch(enrichmentControllerProvider);

    // Surface the recommender's "Why this song?" reason when autoplay picks one.
    ref.listen<String?>(nowPlayingReasonProvider, (prev, next) {
      if (next != null && next != prev) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Why this song?  $next'),
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonata'),
        actions: [
          if (progress.running)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Scan & enrich',
              onPressed: () {
                final songs = ref.read(songsProvider).asData?.value;
                if (songs != null && songs.isNotEmpty) {
                  ref
                      .read(enrichmentControllerProvider.notifier)
                      .scanAndEnrich(songs);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _EnrichBanner(progress: progress),
          Expanded(
            child: songsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => _PermissionOrError(error: err),
              data: (songs) {
                if (songs.isEmpty) return const _EmptyLibrary();
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(songsProvider);
                    try {
                      await ref.read(songsProvider.future);
                    } catch (_) {
                      // Error state is rendered on the next build.
                    }
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: 4,
                      bottom: currentSong != null ? 96 : 8,
                    ),
                    itemCount: songs.length,
                    itemBuilder: (context, i) => _SongTile(song: songs[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: currentSong == null ? null : const MiniPlayer(),
    );
  }
}

class _EnrichBanner extends StatelessWidget {
  const _EnrichBanner({required this.progress});

  final EnrichmentProgress progress;

  @override
  Widget build(BuildContext context) {
    if (!progress.running && progress.message == null) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    final label = progress.running && progress.total > 0
        ? '${progress.message ?? 'Enriching…'}  ${progress.done}/${progress.total}'
        : (progress.message ?? '');
    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHigh,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.running && progress.total > 0
                  ? progress.fraction
                  : (progress.running ? null : 0),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SongTile extends ConsumerWidget {
  const _SongTile({required this.song});

  final SongModel song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isCurrent = ref.watch(currentSongProvider)?.id == song.id;

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: QueryArtworkWidget(
          id: song.id,
          type: ArtworkType.AUDIO,
          artworkWidth: 48,
          artworkHeight: 48,
          nullArtworkWidget: Container(
            width: 48,
            height: 48,
            color: scheme.surfaceContainerHighest,
            child: const Icon(Icons.music_note),
          ),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isCurrent ? scheme.primary : null,
          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        song.artist ?? 'Unknown artist',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isCurrent
          ? Icon(Icons.equalizer_rounded, color: scheme.primary, size: 20)
          : null,
      onTap: () => ref.read(playbackControllerProvider).playSong(song),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_music_outlined, size: 48),
            SizedBox(height: 16),
            Text(
              'No audio files found on this device.\n'
              'Add some music, then pull down to refresh.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionOrError extends ConsumerWidget {
  const _PermissionOrError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final denied = error is PermissionDeniedException;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(denied ? Icons.lock_outline : Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              denied
                  ? 'Sonata needs permission to read the audio on your device.'
                  : 'Could not load your library.\n$error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.invalidate(audioPermissionProvider);
                ref.invalidate(songsProvider);
              },
              child: Text(denied ? 'Grant permission' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
