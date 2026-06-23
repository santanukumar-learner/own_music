import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_recommender/enrichment/enrichment_models.dart';
import 'package:music_recommender/enrichment/feature_vector.dart';

void main() {
  group('EnrichmentResult.fromJson', () {
    test('parses the full /enrich contract', () {
      final json = <String, dynamic>{
        'status': 'enriched',
        'source': 'musicbrainz_search',
        'title': 'Blinding Lights',
        'artist': 'The Weeknd',
        'artist_mbid': 'abc',
        'album': 'After Hours',
        'mb_track_id': 'def',
        'acoustid_id': null,
        'year': 2020,
        'decade': 2020,
        'cover_art_url': 'https://example/front',
        'audio_features': {
          'bpm': 171.0,
          'musical_key': 'C#',
          'valence': 0.72,
          'energy': 0.81,
          'duration_ms': 200040,
        },
        'classification': {
          'genres': ['synthpop', 'pop', 'new wave'],
          'genre_confidences': [0.61, 0.22, 0.07],
          'mood': 'euphoric',
          'genre_embedding': List<double>.filled(128, 0.1),
          'source': 'id3_fallback',
        },
        'error': null,
      };

      final r = EnrichmentResult.fromJson(json);
      expect(r.status, 'enriched');
      expect(r.artist, 'The Weeknd');
      expect(r.decade, 2020);
      expect(r.audioFeatures!.bpm, 171.0);
      expect(r.audioFeatures!.musicalKey, 'C#');
      expect(r.classification!.genres, hasLength(3));
      expect(r.classification!.mood, 'euphoric');
      expect(r.classification!.genreEmbedding, hasLength(128));
    });

    test('degrades gracefully on missing/partial fields', () {
      final r = EnrichmentResult.fromJson(
        <String, dynamic>{'status': 'failed', 'source': 'none'},
      );
      expect(r.failed, isTrue);
      expect(r.audioFeatures, isNull);
      expect(r.classification, isNull);
    });

    test('coerces int-like numeric fields', () {
      final r = EnrichmentResult.fromJson(<String, dynamic>{
        'status': 'enriched',
        'source': 'lastfm',
        'audio_features': {
          'bpm': 120, // int, not double
          'musical_key': 'A',
          'valence': 0,
          'energy': 1,
          'duration_ms': 180000,
        },
      });
      expect(r.audioFeatures!.bpm, 120.0);
      expect(r.audioFeatures!.valence, 0.0);
      expect(r.audioFeatures!.energy, 1.0);
    });
  });

  group('FeatureVectorBuilder', () {
    test('produces a 134-d, L2-normalized vector', () {
      final v = FeatureVectorBuilder.build(
        genreEmbedding: List<double>.filled(128, 0.1),
        valence: 0.7,
        energy: 0.8,
        bpm: 171,
        musicalKey: 'C#',
        artist: 'The Weeknd',
        decade: 2020,
      );
      expect(v, hasLength(134));
      final norm = sqrt(v.fold<double>(0, (s, x) => s + x * x));
      expect((norm - 1.0).abs(), lessThan(1e-6));
    });

    test('pads/truncates the genre embedding to 128', () {
      final short = FeatureVectorBuilder.build(
        genreEmbedding: const [0.5, 0.5],
        valence: 0.5,
        energy: 0.5,
        bpm: 100,
        musicalKey: 'C',
        artist: null,
        decade: 2000,
      );
      expect(short, hasLength(134));
    });

    test('encoders stay within 0..1', () {
      expect(FeatureVectorBuilder.normalizeBpm(300), 1.0);
      expect(FeatureVectorBuilder.encodeKey('C'), 0.0);
      expect(FeatureVectorBuilder.encodeKey('B'), 1.0);
      expect(FeatureVectorBuilder.encodeKey('???'), 0.0);
      final h = FeatureVectorBuilder.hashArtist('The Weeknd');
      expect(h, inInclusiveRange(0.0, 1.0));
      expect(FeatureVectorBuilder.hashArtist(null), 0.0);
    });
  });
}
