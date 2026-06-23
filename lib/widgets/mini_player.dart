import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../audio/audio_providers.dart';

/// Compact player strip shown at the bottom while a song is loaded:
/// artwork + title/artist + play-pause, with a seekable progress bar.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);
    if (song == null) return const SizedBox.shrink();

    final player = ref.watch(audioPlayerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProgressBar(player: player),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 8, 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkWidth: 44,
                      artworkHeight: 44,
                      nullArtworkWidget: Container(
                        width: 44,
                        height: 44,
                        color: scheme.surfaceContainerHighest,
                        child: const Icon(Icons.music_note, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          song.artist ?? 'Unknown artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _PlayPauseButton(player: player),
                  IconButton(
                    iconSize: 28,
                    color: scheme.onSurface,
                    icon: const Icon(Icons.skip_next_rounded),
                    tooltip: 'Next (recommended)',
                    onPressed: () =>
                        ref.read(playbackControllerProvider).skipToNext(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.player});

  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, durSnap) {
        final maxMs = (durSnap.data ?? Duration.zero).inMilliseconds.toDouble();
        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, posSnap) {
            final posMs = (posSnap.data ?? Duration.zero).inMilliseconds.toDouble();
            final value = maxMs <= 0 ? 0.0 : posMs.clamp(0.0, maxMs);
            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: value,
                max: maxMs <= 0 ? 1.0 : maxMs,
                onChanged: (v) => player.seek(Duration(milliseconds: v.round())),
              ),
            );
          },
        );
      },
    );
  }
}

class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton({required this.player});

  final AudioPlayer player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snap) {
        final state = snap.data;
        final processing = state?.processingState;
        if (processing == ProcessingState.loading ||
            processing == ProcessingState.buffering) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final playing = state?.playing ?? false;
        return IconButton(
          iconSize: 36,
          color: scheme.primary,
          icon: Icon(
            playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
          ),
          onPressed: () =>
              ref.read(playbackControllerProvider).togglePlayPause(),
        );
      },
    );
  }
}
