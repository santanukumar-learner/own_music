// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecommendationCacheCollection on Isar {
  IsarCollection<RecommendationCache> get recommendationCaches =>
      this.collection();
}

const RecommendationCacheSchema = CollectionSchema(
  name: r'RecommendationCache',
  id: 1227106273808510701,
  properties: {
    r'generatedAt': PropertySchema(
      id: 0,
      name: r'generatedAt',
      type: IsarType.dateTime,
    ),
    r'recommendedIds': PropertySchema(
      id: 1,
      name: r'recommendedIds',
      type: IsarType.longList,
    ),
    r'sourceSongId': PropertySchema(
      id: 2,
      name: r'sourceSongId',
      type: IsarType.long,
    ),
    r'ttlSeconds': PropertySchema(
      id: 3,
      name: r'ttlSeconds',
      type: IsarType.long,
    ),
  },

  estimateSize: _recommendationCacheEstimateSize,
  serialize: _recommendationCacheSerialize,
  deserialize: _recommendationCacheDeserialize,
  deserializeProp: _recommendationCacheDeserializeProp,
  idName: r'id',
  indexes: {
    r'sourceSongId': IndexSchema(
      id: -6874660262091091420,
      name: r'sourceSongId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'sourceSongId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _recommendationCacheGetId,
  getLinks: _recommendationCacheGetLinks,
  attach: _recommendationCacheAttach,
  version: '3.3.2',
);

int _recommendationCacheEstimateSize(
  RecommendationCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.recommendedIds.length * 8;
  return bytesCount;
}

void _recommendationCacheSerialize(
  RecommendationCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.generatedAt);
  writer.writeLongList(offsets[1], object.recommendedIds);
  writer.writeLong(offsets[2], object.sourceSongId);
  writer.writeLong(offsets[3], object.ttlSeconds);
}

RecommendationCache _recommendationCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecommendationCache();
  object.generatedAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.recommendedIds = reader.readLongList(offsets[1]) ?? [];
  object.sourceSongId = reader.readLong(offsets[2]);
  object.ttlSeconds = reader.readLong(offsets[3]);
  return object;
}

P _recommendationCacheDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLongList(offset) ?? []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _recommendationCacheGetId(RecommendationCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recommendationCacheGetLinks(
  RecommendationCache object,
) {
  return [];
}

void _recommendationCacheAttach(
  IsarCollection<dynamic> col,
  Id id,
  RecommendationCache object,
) {
  object.id = id;
}

extension RecommendationCacheByIndex on IsarCollection<RecommendationCache> {
  Future<RecommendationCache?> getBySourceSongId(int sourceSongId) {
    return getByIndex(r'sourceSongId', [sourceSongId]);
  }

  RecommendationCache? getBySourceSongIdSync(int sourceSongId) {
    return getByIndexSync(r'sourceSongId', [sourceSongId]);
  }

  Future<bool> deleteBySourceSongId(int sourceSongId) {
    return deleteByIndex(r'sourceSongId', [sourceSongId]);
  }

  bool deleteBySourceSongIdSync(int sourceSongId) {
    return deleteByIndexSync(r'sourceSongId', [sourceSongId]);
  }

  Future<List<RecommendationCache?>> getAllBySourceSongId(
    List<int> sourceSongIdValues,
  ) {
    final values = sourceSongIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sourceSongId', values);
  }

  List<RecommendationCache?> getAllBySourceSongIdSync(
    List<int> sourceSongIdValues,
  ) {
    final values = sourceSongIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sourceSongId', values);
  }

  Future<int> deleteAllBySourceSongId(List<int> sourceSongIdValues) {
    final values = sourceSongIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sourceSongId', values);
  }

  int deleteAllBySourceSongIdSync(List<int> sourceSongIdValues) {
    final values = sourceSongIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sourceSongId', values);
  }

  Future<Id> putBySourceSongId(RecommendationCache object) {
    return putByIndex(r'sourceSongId', object);
  }

  Id putBySourceSongIdSync(
    RecommendationCache object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'sourceSongId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySourceSongId(List<RecommendationCache> objects) {
    return putAllByIndex(r'sourceSongId', objects);
  }

  List<Id> putAllBySourceSongIdSync(
    List<RecommendationCache> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'sourceSongId', objects, saveLinks: saveLinks);
  }
}

extension RecommendationCacheQueryWhereSort
    on QueryBuilder<RecommendationCache, RecommendationCache, QWhere> {
  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhere>
  anySourceSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sourceSongId'),
      );
    });
  }
}

extension RecommendationCacheQueryWhere
    on QueryBuilder<RecommendationCache, RecommendationCache, QWhereClause> {
  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhereClause>
  sourceSongIdEqualTo(int sourceSongId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'sourceSongId',
          value: [sourceSongId],
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhereClause>
  sourceSongIdNotEqualTo(int sourceSongId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceSongId',
                lower: [],
                upper: [sourceSongId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceSongId',
                lower: [sourceSongId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceSongId',
                lower: [sourceSongId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceSongId',
                lower: [],
                upper: [sourceSongId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhereClause>
  sourceSongIdGreaterThan(int sourceSongId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'sourceSongId',
          lower: [sourceSongId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhereClause>
  sourceSongIdLessThan(int sourceSongId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'sourceSongId',
          lower: [],
          upper: [sourceSongId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterWhereClause>
  sourceSongIdBetween(
    int lowerSourceSongId,
    int upperSourceSongId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'sourceSongId',
          lower: [lowerSourceSongId],
          includeLower: includeLower,
          upper: [upperSourceSongId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RecommendationCacheQueryFilter
    on
        QueryBuilder<
          RecommendationCache,
          RecommendationCache,
          QFilterCondition
        > {
  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  generatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'generatedAt', value: value),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  generatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'generatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  generatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'generatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  generatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'generatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  recommendedIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recommendedIds', value: value),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  recommendedIdsElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recommendedIds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  recommendedIdsElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recommendedIds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  recommendedIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recommendedIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  recommendedIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recommendedIds', length, true, length, true);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  recommendedIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recommendedIds', 0, true, 0, true);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  recommendedIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recommendedIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  recommendedIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recommendedIds', 0, true, length, include);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  recommendedIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recommendedIds', length, include, 999999, true);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  recommendedIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recommendedIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  sourceSongIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceSongId', value: value),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  sourceSongIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceSongId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  sourceSongIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceSongId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  sourceSongIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceSongId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  ttlSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ttlSeconds', value: value),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  ttlSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ttlSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  ttlSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ttlSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterFilterCondition>
  ttlSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ttlSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RecommendationCacheQueryObject
    on
        QueryBuilder<
          RecommendationCache,
          RecommendationCache,
          QFilterCondition
        > {}

extension RecommendationCacheQueryLinks
    on
        QueryBuilder<
          RecommendationCache,
          RecommendationCache,
          QFilterCondition
        > {}

extension RecommendationCacheQuerySortBy
    on QueryBuilder<RecommendationCache, RecommendationCache, QSortBy> {
  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  sortByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  sortByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  sortBySourceSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceSongId', Sort.asc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  sortBySourceSongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceSongId', Sort.desc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  sortByTtlSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.asc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  sortByTtlSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.desc);
    });
  }
}

extension RecommendationCacheQuerySortThenBy
    on QueryBuilder<RecommendationCache, RecommendationCache, QSortThenBy> {
  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  thenByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  thenByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  thenBySourceSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceSongId', Sort.asc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  thenBySourceSongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceSongId', Sort.desc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  thenByTtlSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.asc);
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QAfterSortBy>
  thenByTtlSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.desc);
    });
  }
}

extension RecommendationCacheQueryWhereDistinct
    on QueryBuilder<RecommendationCache, RecommendationCache, QDistinct> {
  QueryBuilder<RecommendationCache, RecommendationCache, QDistinct>
  distinctByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatedAt');
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QDistinct>
  distinctByRecommendedIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recommendedIds');
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QDistinct>
  distinctBySourceSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceSongId');
    });
  }

  QueryBuilder<RecommendationCache, RecommendationCache, QDistinct>
  distinctByTtlSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ttlSeconds');
    });
  }
}

extension RecommendationCacheQueryProperty
    on QueryBuilder<RecommendationCache, RecommendationCache, QQueryProperty> {
  QueryBuilder<RecommendationCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecommendationCache, DateTime, QQueryOperations>
  generatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatedAt');
    });
  }

  QueryBuilder<RecommendationCache, List<int>, QQueryOperations>
  recommendedIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recommendedIds');
    });
  }

  QueryBuilder<RecommendationCache, int, QQueryOperations>
  sourceSongIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceSongId');
    });
  }

  QueryBuilder<RecommendationCache, int, QQueryOperations>
  ttlSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ttlSeconds');
    });
  }
}
