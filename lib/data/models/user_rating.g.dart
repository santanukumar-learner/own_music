// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rating.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserRatingCollection on Isar {
  IsarCollection<UserRating> get userRatings => this.collection();
}

const UserRatingSchema = CollectionSchema(
  name: r'UserRating',
  id: 9023778781551869380,
  properties: {
    r'songId': PropertySchema(id: 0, name: r'songId', type: IsarType.long),
    r'thumbDown': PropertySchema(
      id: 1,
      name: r'thumbDown',
      type: IsarType.bool,
    ),
    r'thumbUp': PropertySchema(id: 2, name: r'thumbUp', type: IsarType.bool),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _userRatingEstimateSize,
  serialize: _userRatingSerialize,
  deserialize: _userRatingDeserialize,
  deserializeProp: _userRatingDeserializeProp,
  idName: r'id',
  indexes: {
    r'songId': IndexSchema(
      id: -4588889454650216128,
      name: r'songId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'songId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _userRatingGetId,
  getLinks: _userRatingGetLinks,
  attach: _userRatingAttach,
  version: '3.3.2',
);

int _userRatingEstimateSize(
  UserRating object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _userRatingSerialize(
  UserRating object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.songId);
  writer.writeBool(offsets[1], object.thumbDown);
  writer.writeBool(offsets[2], object.thumbUp);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

UserRating _userRatingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserRating();
  object.id = id;
  object.songId = reader.readLong(offsets[0]);
  object.thumbDown = reader.readBoolOrNull(offsets[1]);
  object.thumbUp = reader.readBoolOrNull(offsets[2]);
  object.updatedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _userRatingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userRatingGetId(UserRating object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userRatingGetLinks(UserRating object) {
  return [];
}

void _userRatingAttach(IsarCollection<dynamic> col, Id id, UserRating object) {
  object.id = id;
}

extension UserRatingByIndex on IsarCollection<UserRating> {
  Future<UserRating?> getBySongId(int songId) {
    return getByIndex(r'songId', [songId]);
  }

  UserRating? getBySongIdSync(int songId) {
    return getByIndexSync(r'songId', [songId]);
  }

  Future<bool> deleteBySongId(int songId) {
    return deleteByIndex(r'songId', [songId]);
  }

  bool deleteBySongIdSync(int songId) {
    return deleteByIndexSync(r'songId', [songId]);
  }

  Future<List<UserRating?>> getAllBySongId(List<int> songIdValues) {
    final values = songIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'songId', values);
  }

  List<UserRating?> getAllBySongIdSync(List<int> songIdValues) {
    final values = songIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'songId', values);
  }

  Future<int> deleteAllBySongId(List<int> songIdValues) {
    final values = songIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'songId', values);
  }

  int deleteAllBySongIdSync(List<int> songIdValues) {
    final values = songIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'songId', values);
  }

  Future<Id> putBySongId(UserRating object) {
    return putByIndex(r'songId', object);
  }

  Id putBySongIdSync(UserRating object, {bool saveLinks = true}) {
    return putByIndexSync(r'songId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySongId(List<UserRating> objects) {
    return putAllByIndex(r'songId', objects);
  }

  List<Id> putAllBySongIdSync(
    List<UserRating> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'songId', objects, saveLinks: saveLinks);
  }
}

extension UserRatingQueryWhereSort
    on QueryBuilder<UserRating, UserRating, QWhere> {
  QueryBuilder<UserRating, UserRating, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterWhere> anySongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'songId'),
      );
    });
  }
}

extension UserRatingQueryWhere
    on QueryBuilder<UserRating, UserRating, QWhereClause> {
  QueryBuilder<UserRating, UserRating, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UserRating, UserRating, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterWhereClause> idBetween(
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

  QueryBuilder<UserRating, UserRating, QAfterWhereClause> songIdEqualTo(
    int songId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'songId', value: [songId]),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterWhereClause> songIdNotEqualTo(
    int songId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'songId',
                lower: [],
                upper: [songId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'songId',
                lower: [songId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'songId',
                lower: [songId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'songId',
                lower: [],
                upper: [songId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterWhereClause> songIdGreaterThan(
    int songId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'songId',
          lower: [songId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterWhereClause> songIdLessThan(
    int songId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'songId',
          lower: [],
          upper: [songId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterWhereClause> songIdBetween(
    int lowerSongId,
    int upperSongId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'songId',
          lower: [lowerSongId],
          includeLower: includeLower,
          upper: [upperSongId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserRatingQueryFilter
    on QueryBuilder<UserRating, UserRating, QFilterCondition> {
  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> songIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'songId', value: value),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> songIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'songId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> songIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'songId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> songIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'songId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition>
  thumbDownIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'thumbDown'),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition>
  thumbDownIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'thumbDown'),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> thumbDownEqualTo(
    bool? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'thumbDown', value: value),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> thumbUpIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'thumbUp'),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition>
  thumbUpIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'thumbUp'),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> thumbUpEqualTo(
    bool? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'thumbUp', value: value),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserRatingQueryObject
    on QueryBuilder<UserRating, UserRating, QFilterCondition> {}

extension UserRatingQueryLinks
    on QueryBuilder<UserRating, UserRating, QFilterCondition> {}

extension UserRatingQuerySortBy
    on QueryBuilder<UserRating, UserRating, QSortBy> {
  QueryBuilder<UserRating, UserRating, QAfterSortBy> sortBySongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.asc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> sortBySongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.desc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> sortByThumbDown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbDown', Sort.asc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> sortByThumbDownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbDown', Sort.desc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> sortByThumbUp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbUp', Sort.asc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> sortByThumbUpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbUp', Sort.desc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension UserRatingQuerySortThenBy
    on QueryBuilder<UserRating, UserRating, QSortThenBy> {
  QueryBuilder<UserRating, UserRating, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> thenBySongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.asc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> thenBySongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.desc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> thenByThumbDown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbDown', Sort.asc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> thenByThumbDownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbDown', Sort.desc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> thenByThumbUp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbUp', Sort.asc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> thenByThumbUpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbUp', Sort.desc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserRating, UserRating, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension UserRatingQueryWhereDistinct
    on QueryBuilder<UserRating, UserRating, QDistinct> {
  QueryBuilder<UserRating, UserRating, QDistinct> distinctBySongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songId');
    });
  }

  QueryBuilder<UserRating, UserRating, QDistinct> distinctByThumbDown() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbDown');
    });
  }

  QueryBuilder<UserRating, UserRating, QDistinct> distinctByThumbUp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbUp');
    });
  }

  QueryBuilder<UserRating, UserRating, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension UserRatingQueryProperty
    on QueryBuilder<UserRating, UserRating, QQueryProperty> {
  QueryBuilder<UserRating, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserRating, int, QQueryOperations> songIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songId');
    });
  }

  QueryBuilder<UserRating, bool?, QQueryOperations> thumbDownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbDown');
    });
  }

  QueryBuilder<UserRating, bool?, QQueryOperations> thumbUpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbUp');
    });
  }

  QueryBuilder<UserRating, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
