import 'package:isar_community/isar.dart';

part 'song.g.dart';

/// A single audio track discovered on the device, together with all enriched
/// metadata and the precomputed feature vector used by the content-based
/// recommender.
///
/// String-typed fields ([mood], [metadataStatus], [musicalKey]) draw their
/// values from the constants in `enums.dart`.
@collection
class Song {
  Id id = Isar.autoIncrement;

  /// Absolute MediaStore path. The natural unique key for a track; `replace`
  /// lets a re-scan upsert the same file without throwing on the unique index.
  @Index(unique: true, replace: true)
  late String filePath;

  late String fileName;

  String? title;

  /// Canonical artist name (MusicBrainz), falling back to the ID3 tag.
  /// Indexed (case-insensitive) for the Artist page "all songs by artist".
  @Index(caseSensitive: false)
  String? artist;

  /// MusicBrainz artist id, used for disambiguation and the Artist page lookup.
  @Index()
  String? artistMbid;

  String? album;

  /// Locally cached album-art file (Cover Art Archive → Last.fm → embedded).
  String? albumArtPath;

  late int durationMs;

  /// Top-3 genres from the ONNX classifier. Indexed per element so the genre
  /// filter chip can query "songs whose genres contain X".
  @Index(type: IndexType.value)
  List<String> genres = [];

  /// Classifier confidence (0.0–1.0), aligned by position with [genres].
  List<double> genreConfidences = [];

  /// euphoric | happy | calm | melancholic | angry | dark — see `Mood`.
  @Index()
  late String mood;

  /// Russell circumplex axes, 0.0–1.0.
  late double valence;
  late double energy;

  /// Beats per minute (librosa tempo).
  late double bpm;

  /// Musical key: C, C#, D … B — see `MusicalKey`.
  late String musicalKey;

  /// Release decade: 1980, 1990 … 2020. Indexed for the decade filter chip.
  @Index()
  late int decade;

  String? acoustidId;
  String? mbTrackId;

  /// Precomputed 134-d vector (see `kFeatureVectorDim`):
  /// genre_embedding(128) + valence+energy(2) + bpm_norm(1) + key(1) +
  /// artist_hash(1) + decade(1). L2-normalized before cosine similarity.
  List<double> featureVector = [];

  /// raw | enriched | fingerprinted | failed — see `MetadataStatus`.
  /// Indexed so the enrichment queue can pull "raw"/"failed" rows cheaply.
  @Index()
  late String metadataStatus;

  DateTime? lastEnrichedAt;

  /// Drives the Library "recently added" sort.
  @Index()
  late DateTime addedAt;

  /// `false` once the underlying file disappears from the device. We keep the
  /// row (and its play history) instead of deleting — see LibraryScan Task A,
  /// step 5. Indexed so library queries can exclude unavailable tracks.
  @Index()
  bool isAvailable = true;
}
