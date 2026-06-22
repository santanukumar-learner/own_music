import 'package:isar_community/isar.dart';

part 'artist.g.dart';

/// Cached artist metadata for the Artist page — bio pulled from MusicBrainz and
/// refreshed weekly. Keyed by MusicBrainz artist id; tracks whose artist could
/// not be resolved to an MBID simply have no cached bio here.
///
/// (This is the 5th collection: implied by the Artist-page bio-cache feature,
/// which the four data-model collections in the spec don't cover.)
@collection
class Artist {
  Id id = Isar.autoIncrement;

  /// MusicBrainz artist id — the canonical, disambiguated key.
  @Index(unique: true, replace: true)
  late String mbid;

  /// Canonical display name (case-insensitive index for lookups).
  @Index(caseSensitive: false)
  late String name;

  /// Artist biography/wiki text from MusicBrainz, cached locally.
  String? bio;

  /// Locally cached artist image path.
  String? imagePath;

  /// When [bio] was last fetched; drives the weekly refresh policy.
  DateTime? bioRefreshedAt;
}
