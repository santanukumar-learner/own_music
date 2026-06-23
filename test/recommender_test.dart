import 'package:flutter_test/flutter_test.dart';
import 'package:music_recommender/recommender/content_ranker.dart';
import 'package:music_recommender/recommender/similarity.dart';

List<double> _vec(double a, double b, double c) => [a, b, c];

void main() {
  group('similarity', () {
    test('cosine of identical vectors is 1', () {
      expect(cosineSimilarity(_vec(1, 2, 3), _vec(1, 2, 3)), closeTo(1.0, 1e-9));
    });

    test('cosine of orthogonal vectors is 0', () {
      expect(cosineSimilarity(_vec(1, 0, 0), _vec(0, 1, 0)), closeTo(0.0, 1e-9));
    });

    test('cosineUnit maps to [0,1]', () {
      expect(cosineUnit(_vec(1, 0, 0), _vec(1, 0, 0)), closeTo(1.0, 1e-9));
      expect(cosineUnit(_vec(1, 0, 0), _vec(-1, 0, 0)), closeTo(0.0, 1e-9));
      expect(cosineUnit(_vec(1, 0, 0), _vec(0, 1, 0)), closeTo(0.5, 1e-9));
    });
  });

  group('energyCenter', () {
    test('time-of-day bands', () {
      expect(energyCenter(hour: 8), 0.75); // morning upbeat
      expect(energyCenter(hour: 2), 0.30); // late night calm
    });

    test('mood pin overrides time of day', () {
      expect(energyCenter(hour: 2, moodPin: 'workout'), 0.85);
      expect(energyCenter(hour: 8, moodPin: 'focus'), 0.30);
    });
  });

  group('rankContent', () {
    final query = _vec(1, 0, 0);

    RecCandidate cand(
      int id,
      List<double> v, {
      double energy = 0.5,
      List<String> genres = const ['pop'],
      bool up = false,
      bool down = false,
      bool recent = false,
    }) =>
        RecCandidate(
          songId: id,
          featureVector: v,
          energy: energy,
          genres: genres,
          thumbUp: up,
          thumbDown: down,
          playedRecently: recent,
        );

    test('most similar candidate ranks first', () {
      final result = rankContent(
        query,
        [
          cand(1, _vec(0, 1, 0)), // orthogonal
          cand(2, _vec(1, 0, 0)), // identical
          cand(3, _vec(0.5, 0.5, 0)),
        ],
        const RecContext(),
      );
      expect(result.first.songId, 2);
    });

    test('thumbed-down and recently-played are zeroed out', () {
      final result = rankContent(
        query,
        [
          cand(1, _vec(1, 0, 0), down: true),
          cand(2, _vec(1, 0, 0), recent: true),
          cand(3, _vec(0, 1, 0)),
        ],
        const RecContext(),
      );
      final byId = {for (final s in result) s.songId: s};
      expect(byId[1]!.score, 0.0);
      expect(byId[2]!.score, 0.0);
      expect(byId[3]!.score, greaterThan(0.0));
    });

    test('thumb-up boosts score above an equal non-boosted candidate', () {
      final result = rankContent(
        query,
        [
          cand(1, _vec(1, 0, 0)),
          cand(2, _vec(1, 0, 0), up: true),
        ],
        const RecContext(),
      );
      expect(result.first.songId, 2);
    });

    test('energy band preference favors in-band candidates', () {
      final result = rankContent(
        query,
        [
          cand(1, _vec(1, 0, 0), energy: 0.1), // far from center
          cand(2, _vec(1, 0, 0), energy: 0.75), // in band
        ],
        const RecContext(preferredEnergyCenter: 0.75),
      );
      expect(result.first.songId, 2);
    });

    test('genre diversity injects different-genre picks into a uniform top-10', () {
      // 12 identical-genre 'pop' candidates with descending similarity, plus a
      // strong 'rock' candidate that would otherwise sit just outside top-10.
      final candidates = <RecCandidate>[
        for (var i = 0; i < 11; i++)
          cand(i, [1.0 - i * 0.01, i * 0.01, 0], genres: const ['pop']),
        cand(100, _vec(0.85, 0.15, 0), genres: const ['rock']),
      ];
      final result = rankContent(query, candidates, const RecContext());
      final top10 = result.take(10).map((s) => s.primaryGenre).toSet();
      expect(top10.contains('rock'), isTrue,
          reason: 'a different genre should be injected into the top 10');
    });
  });
}
