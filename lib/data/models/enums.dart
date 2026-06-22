/// Centralized allowed values for the String-typed "enum" fields on the Isar
/// collections.
///
/// The database schema stores these as plain `String` (per spec), but the rest
/// of the app references them through these constants instead of magic strings,
/// so typos surface at compile time and the valid sets live in one place.

/// [Song.metadataStatus] values — the enrichment lifecycle of a track.
abstract final class MetadataStatus {
  static const String raw = 'raw'; // freshly scanned, ID3 tags only
  static const String enriched = 'enriched'; // web metadata + features written
  static const String fingerprinted = 'fingerprinted'; // matched via AcoustID
  static const String failed = 'failed'; // enrichment failed, retry scheduled

  static const List<String> all = [raw, enriched, fingerprinted, failed];
}

/// [Song.mood] values — Russell circumplex quadrant labels.
abstract final class Mood {
  static const String euphoric = 'euphoric'; // high energy + high valence
  static const String happy = 'happy';
  static const String calm = 'calm';
  static const String melancholic = 'melancholic';
  static const String angry = 'angry';
  static const String dark = 'dark'; // low energy + low valence

  static const List<String> all = [
    euphoric,
    happy,
    calm,
    melancholic,
    angry,
    dark,
  ];
}

/// [PlayEvent.context] values — how playback of a track was initiated.
abstract final class PlayContext {
  static const String autoplay = 'autoplay'; // recommender-driven
  static const String manual = 'manual'; // user tapped a song
  static const String queue = 'queue'; // from the up-next queue

  static const List<String> all = [autoplay, manual, queue];
}

/// Active explicit mood filter ([PlayEvent.moodPin] / settings mood mode).
abstract final class MoodPin {
  static const String focus = 'focus';
  static const String workout = 'workout';
  static const String chill = 'chill';

  static const List<String> all = [focus, workout, chill];
}

/// The 12 musical keys used by [Song.musicalKey].
abstract final class MusicalKey {
  static const List<String> all = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];
}

/// Dimensionality of [Song.featureVector]:
/// genre_embedding(128) + valence+energy(2) + bpm_norm(1) + key(1) +
/// artist_hash(1) + decade(1) = 134.
const int kFeatureVectorDim = 134;
const int kGenreEmbeddingDim = 128;
