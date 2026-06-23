import 'package:isar_community/isar.dart';

import '../enrichment/enrichment_models.dart';
import '../enrichment/feature_vector.dart';
import 'isar_service.dart';
import 'models/enums.dart';
import 'models/song.dart';

/// Persistence + enrichment writes for [Song]. Backed by the single Isar
/// instance. Used by the LibraryScan / MetadataEnrichment tasks (deliverable 5)
/// and read by the recommender (deliverables 6 & 8).
class SongRepository {
  SongRepository(this._isar);

  final Isar _isar;

  static Future<SongRepository> open() async =>
      SongRepository(await IsarService.instance());

  /// Insert or update the raw row for a scanned file (keyed by [filePath]).
  /// New rows start as `metadataStatus = raw` with neutral feature defaults.
  /// Returns the stored song id.
  Future<int> upsertScanned({
    required String filePath,
    required String fileName,
    String? title,
    String? artist,
    String? album,
    required int durationMs,
    required DateTime addedAt,
  }) {
    return _isar.writeTxn(() async {
      final existing =
          await _isar.songs.filter().filePathEqualTo(filePath).findFirst();
      final song = existing ??
          (Song()
            ..filePath = filePath
            ..addedAt = addedAt
            ..metadataStatus = MetadataStatus.raw
            ..mood = Mood.calm
            ..valence = 0.5
            ..energy = 0.5
            ..bpm = 0
            ..musicalKey = 'C'
            ..decade = 0);
      song
        ..fileName = fileName
        ..title = title ?? song.title
        ..artist = artist ?? song.artist
        ..album = album ?? song.album
        ..durationMs = durationMs
        ..isAvailable = true;
      return _isar.songs.put(song);
    });
  }

  /// Apply an enrichment result: write canonical metadata + audio features +
  /// genre/mood, assemble the 134-d feature vector, and advance the status.
  Future<void> applyEnrichment(int songId, EnrichmentResult result) {
    return _isar.writeTxn(() async {
      final song = await _isar.songs.get(songId);
      if (song == null) return;

      if (result.title != null) song.title = result.title;
      if (result.artist != null) song.artist = result.artist;
      song.artistMbid = result.artistMbid ?? song.artistMbid;
      if (result.album != null) song.album = result.album;
      song.mbTrackId = result.mbTrackId ?? song.mbTrackId;
      song.acoustidId = result.acoustidId ?? song.acoustidId;
      if (result.decade != null && result.decade! > 0) {
        song.decade = result.decade!;
      }

      final feats = result.audioFeatures;
      if (feats != null) {
        song.bpm = feats.bpm;
        song.musicalKey = feats.musicalKey;
        song.valence = feats.valence;
        song.energy = feats.energy;
        if (feats.durationMs > 0) song.durationMs = feats.durationMs;
      }

      final cls = result.classification;
      if (cls != null) {
        song.genres = cls.genres;
        song.genreConfidences = cls.genreConfidences;
        song.mood = cls.mood;
      }

      if (feats != null && cls != null) {
        song.featureVector = FeatureVectorBuilder.build(
          genreEmbedding: cls.genreEmbedding,
          valence: feats.valence,
          energy: feats.energy,
          bpm: feats.bpm,
          musicalKey: feats.musicalKey,
          artist: song.artist,
          decade: song.decade,
        );
      }

      song
        ..metadataStatus = result.failed
            ? MetadataStatus.failed
            : (result.acoustidId != null
                ? MetadataStatus.fingerprinted
                : MetadataStatus.enriched)
        ..lastEnrichedAt = DateTime.now();
      await _isar.songs.put(song);
    });
  }

  /// Songs awaiting enrichment (raw or previously failed).
  Future<List<Song>> pendingEnrichment({int limit = 200}) {
    return _isar.songs
        .filter()
        .metadataStatusEqualTo(MetadataStatus.raw)
        .or()
        .metadataStatusEqualTo(MetadataStatus.failed)
        .limit(limit)
        .findAll();
  }

  /// Songs with a usable feature vector (enriched or fingerprinted, available).
  Future<List<Song>> recommendable() {
    return _isar.songs
        .filter()
        .isAvailableEqualTo(true)
        .group((q) => q
            .metadataStatusEqualTo(MetadataStatus.enriched)
            .or()
            .metadataStatusEqualTo(MetadataStatus.fingerprinted))
        .findAll();
  }

  Future<Song?> byId(int id) => _isar.songs.get(id);

  Future<Song?> byFilePath(String filePath) =>
      _isar.songs.filter().filePathEqualTo(filePath).findFirst();

  Future<int> count() => _isar.songs.count();
}
