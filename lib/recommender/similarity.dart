import 'dart:math';

/// Vector similarity helpers for the content-based recommender.
///
/// Feature vectors are stored L2-normalized (see FeatureVectorBuilder), so for
/// those [dotProduct] already equals the cosine. [cosineSimilarity] re-normalizes
/// defensively for vectors of unknown magnitude.

double dotProduct(List<double> a, List<double> b) {
  final n = min(a.length, b.length);
  var sum = 0.0;
  for (var i = 0; i < n; i++) {
    sum += a[i] * b[i];
  }
  return sum;
}

/// Cosine similarity in [-1, 1]. Returns 0 for empty/zero vectors.
double cosineSimilarity(List<double> a, List<double> b) {
  final n = min(a.length, b.length);
  if (n == 0) return 0.0;
  var dot = 0.0, normA = 0.0, normB = 0.0;
  for (var i = 0; i < n; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  if (normA == 0 || normB == 0) return 0.0;
  return dot / (sqrt(normA) * sqrt(normB));
}

/// Cosine similarity mapped to [0, 1] (per the spec's "normalize each to 0-1"
/// before blending content + collaborative scores).
double cosineUnit(List<double> a, List<double> b) =>
    ((cosineSimilarity(a, b) + 1.0) / 2.0).clamp(0.0, 1.0);
