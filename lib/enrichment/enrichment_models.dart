// Dart mirror of the `/enrich` JSON contract returned by the Python LAN
// service (see service/README.md). Parsing is defensive: any missing/odd field
// degrades to null/empty rather than throwing.

class EnrichmentResult {
  const EnrichmentResult({
    required this.status,
    required this.source,
    this.title,
    this.artist,
    this.artistMbid,
    this.album,
    this.mbTrackId,
    this.acoustidId,
    this.year,
    this.decade,
    this.coverArtUrl,
    this.audioFeatures,
    this.classification,
    this.error,
  });

  /// raw | enriched | fingerprinted | failed
  final String status;

  /// acoustid | musicbrainz_search | lastfm | discogs | local_features | none
  final String source;

  final String? title;
  final String? artist;
  final String? artistMbid;
  final String? album;
  final String? mbTrackId;
  final String? acoustidId;
  final int? year;
  final int? decade;
  final String? coverArtUrl;
  final AudioFeatures? audioFeatures;
  final Classification? classification;
  final String? error;

  bool get failed => status == 'failed';

  factory EnrichmentResult.fromJson(Map<String, dynamic> json) {
    return EnrichmentResult(
      status: json['status'] as String? ?? 'failed',
      source: json['source'] as String? ?? 'none',
      title: json['title'] as String?,
      artist: json['artist'] as String?,
      artistMbid: json['artist_mbid'] as String?,
      album: json['album'] as String?,
      mbTrackId: json['mb_track_id'] as String?,
      acoustidId: json['acoustid_id'] as String?,
      year: _asInt(json['year']),
      decade: _asInt(json['decade']),
      coverArtUrl: json['cover_art_url'] as String?,
      audioFeatures: json['audio_features'] is Map
          ? AudioFeatures.fromJson(
              (json['audio_features'] as Map).cast<String, dynamic>())
          : null,
      classification: json['classification'] is Map
          ? Classification.fromJson(
              (json['classification'] as Map).cast<String, dynamic>())
          : null,
      error: json['error'] as String?,
    );
  }
}

class AudioFeatures {
  const AudioFeatures({
    required this.bpm,
    required this.musicalKey,
    required this.valence,
    required this.energy,
    required this.durationMs,
  });

  final double bpm;
  final String musicalKey;
  final double valence;
  final double energy;
  final int durationMs;

  factory AudioFeatures.fromJson(Map<String, dynamic> json) {
    return AudioFeatures(
      bpm: _asDouble(json['bpm']),
      musicalKey: json['musical_key'] as String? ?? 'C',
      valence: _asDouble(json['valence']),
      energy: _asDouble(json['energy']),
      durationMs: _asInt(json['duration_ms']) ?? 0,
    );
  }
}

class Classification {
  const Classification({
    required this.genres,
    required this.genreConfidences,
    required this.mood,
    required this.genreEmbedding,
    this.source,
  });

  final List<String> genres;
  final List<double> genreConfidences;
  final String mood;
  final List<double> genreEmbedding; // 128-d
  final String? source; // onnx | id3_fallback

  factory Classification.fromJson(Map<String, dynamic> json) {
    return Classification(
      genres: _asStringList(json['genres']),
      genreConfidences: _asDoubleList(json['genre_confidences']),
      mood: json['mood'] as String? ?? 'calm',
      genreEmbedding: _asDoubleList(json['genre_embedding']),
      source: json['source'] as String?,
    );
  }
}

// --- defensive coercion helpers ---

int? _asInt(Object? v) => v == null
    ? null
    : v is int
        ? v
        : v is num
            ? v.toInt()
            : int.tryParse(v.toString());

double _asDouble(Object? v) => v == null
    ? 0.0
    : v is double
        ? v
        : v is num
            ? v.toDouble()
            : double.tryParse(v.toString()) ?? 0.0;

List<String> _asStringList(Object? v) =>
    v is List ? v.map((e) => e.toString()).toList() : const [];

List<double> _asDoubleList(Object? v) =>
    v is List ? v.map(_asDouble).toList() : const [];
