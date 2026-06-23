import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../data/models/enums.dart';

/// Assembles the 134-d content feature vector from the components returned by
/// the enrichment service, matching the layout in the spec:
///
///   genre_embedding(128) + valence + energy + bpm_norm + key + artist_hash + decade
///
/// The result is L2-normalized so cosine similarity reduces to a dot product
/// (see the recommender in deliverables 6 & 8).
class FeatureVectorBuilder {
  const FeatureVectorBuilder._();

  static const int dim = kFeatureVectorDim; // 134

  static List<double> build({
    required List<double> genreEmbedding,
    required double valence,
    required double energy,
    required double bpm,
    required String musicalKey,
    required String? artist,
    required int decade,
  }) {
    final embedding = _fit(genreEmbedding, kGenreEmbeddingDim);
    final vector = <double>[
      ...embedding,
      valence.clamp(0.0, 1.0),
      energy.clamp(0.0, 1.0),
      normalizeBpm(bpm),
      encodeKey(musicalKey),
      hashArtist(artist),
      encodeDecade(decade),
    ];
    assert(vector.length == dim, 'expected $dim dims, got ${vector.length}');
    return l2Normalize(vector);
  }

  /// BPM mapped to 0..1 (cap ~250 BPM covers essentially all music).
  static double normalizeBpm(double bpm) => (bpm / 250.0).clamp(0.0, 1.0);

  /// Musical key -> 0..1 over the 12 semitones; unknown keys map to 0.
  static double encodeKey(String key) {
    final i = MusicalKey.all.indexOf(key);
    return i < 0 ? 0.0 : i / (MusicalKey.all.length - 1);
  }

  /// Stable 0..1 hash of the canonical artist name (md5 -> first 4 bytes).
  static double hashArtist(String? artist) {
    if (artist == null || artist.trim().isEmpty) return 0.0;
    final bytes = md5.convert(utf8.encode(artist.trim().toLowerCase())).bytes;
    final v = ((bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3]) &
        0xFFFFFFFF;
    return v / 0xFFFFFFFF;
  }

  /// Decade mapped to 0..1 across 1900..2100.
  static double encodeDecade(int decade) =>
      ((decade - 1900) / 200.0).clamp(0.0, 1.0);

  static List<double> _fit(List<double> v, int n) {
    if (v.length == n) return v;
    if (v.length > n) return v.sublist(0, n);
    return [...v, ...List<double>.filled(n - v.length, 0.0)];
  }

  static List<double> l2Normalize(List<double> v) {
    var sumSq = 0.0;
    for (final x in v) {
      sumSq += x * x;
    }
    final norm = sqrt(sumSq);
    if (norm == 0) return v;
    return [for (final x in v) x / norm];
  }
}
