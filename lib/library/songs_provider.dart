import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

final onAudioQueryProvider = Provider<OnAudioQuery>((ref) => OnAudioQuery());

/// Requests (or reads) the audio-library permission. Throwing keeps the error
/// path in [songsProvider] simple.
final audioPermissionProvider = FutureProvider<bool>((ref) async {
  final query = ref.read(onAudioQueryProvider);
  var granted = await query.permissionsStatus();
  if (!granted) {
    granted = await query.permissionsRequest();
  }
  return granted;
});

/// All music tracks on the device, newest first. (Isar persistence + enrichment
/// are layered on later; this is the direct MediaStore scan for playback.)
final songsProvider = FutureProvider<List<SongModel>>((ref) async {
  final granted = await ref.watch(audioPermissionProvider.future);
  if (!granted) {
    throw const PermissionDeniedException();
  }
  final query = ref.read(onAudioQueryProvider);
  final songs = await query.querySongs(
    sortType: SongSortType.DATE_ADDED,
    orderType: OrderType.DESC_OR_GREATER,
    uriType: UriType.EXTERNAL,
    ignoreCase: true,
  );
  // Keep real music files with a positive duration (filters ringtones, etc.).
  return songs
      .where((s) => (s.isMusic ?? true) && (s.duration ?? 0) > 0)
      .toList();
});

class PermissionDeniedException implements Exception {
  const PermissionDeniedException();

  @override
  String toString() => 'Audio permission denied';
}
