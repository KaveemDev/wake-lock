// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_history.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAlarmHistoryCollection on Isar {
  IsarCollection<AlarmHistory> get alarmHistorys => this.collection();
}

const AlarmHistorySchema = CollectionSchema(
  name: r'AlarmHistory',
  id: -1463096488341244298,
  properties: {
    r'alarmId': PropertySchema(id: 0, name: r'alarmId', type: IsarType.long),
    r'alarmLabel': PropertySchema(
      id: 1,
      name: r'alarmLabel',
      type: IsarType.string,
    ),
    r'dismissTimeSeconds': PropertySchema(
      id: 2,
      name: r'dismissTimeSeconds',
      type: IsarType.long,
    ),
    r'missionType': PropertySchema(
      id: 3,
      name: r'missionType',
      type: IsarType.string,
    ),
    r'snoozeCount': PropertySchema(
      id: 4,
      name: r'snoozeCount',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 5,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'verifiedAwake': PropertySchema(
      id: 6,
      name: r'verifiedAwake',
      type: IsarType.bool,
    ),
  },
  estimateSize: _alarmHistoryEstimateSize,
  serialize: _alarmHistorySerialize,
  deserialize: _alarmHistoryDeserialize,
  deserializeProp: _alarmHistoryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _alarmHistoryGetId,
  getLinks: _alarmHistoryGetLinks,
  attach: _alarmHistoryAttach,
  version: '3.1.0+1',
);

int _alarmHistoryEstimateSize(
  AlarmHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.alarmLabel.length * 3;
  bytesCount += 3 + object.missionType.length * 3;
  return bytesCount;
}

void _alarmHistorySerialize(
  AlarmHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.alarmId);
  writer.writeString(offsets[1], object.alarmLabel);
  writer.writeLong(offsets[2], object.dismissTimeSeconds);
  writer.writeString(offsets[3], object.missionType);
  writer.writeLong(offsets[4], object.snoozeCount);
  writer.writeDateTime(offsets[5], object.timestamp);
  writer.writeBool(offsets[6], object.verifiedAwake);
}

AlarmHistory _alarmHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AlarmHistory(
    alarmId: reader.readLong(offsets[0]),
    alarmLabel: reader.readString(offsets[1]),
    dismissTimeSeconds: reader.readLongOrNull(offsets[2]) ?? 30,
    missionType: reader.readString(offsets[3]),
    snoozeCount: reader.readLongOrNull(offsets[4]) ?? 0,
    timestamp: reader.readDateTime(offsets[5]),
    verifiedAwake: reader.readBoolOrNull(offsets[6]) ?? true,
  );
  object.id = id;
  return object;
}

P _alarmHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 30) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _alarmHistoryGetId(AlarmHistory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _alarmHistoryGetLinks(AlarmHistory object) {
  return [];
}

void _alarmHistoryAttach(
  IsarCollection<dynamic> col,
  Id id,
  AlarmHistory object,
) {
  object.id = id;
}

extension AlarmHistoryQueryWhereSort
    on QueryBuilder<AlarmHistory, AlarmHistory, QWhere> {
  QueryBuilder<AlarmHistory, AlarmHistory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AlarmHistoryQueryWhere
    on QueryBuilder<AlarmHistory, AlarmHistory, QWhereClause> {
  QueryBuilder<AlarmHistory, AlarmHistory, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterWhereClause> idBetween(
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
}

extension AlarmHistoryQueryFilter
    on QueryBuilder<AlarmHistory, AlarmHistory, QFilterCondition> {
  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'alarmId', value: value),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'alarmId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'alarmId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'alarmId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmLabelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'alarmLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'alarmLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'alarmLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'alarmLabel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmLabelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'alarmLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmLabelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'alarmLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'alarmLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'alarmLabel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'alarmLabel', value: ''),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  alarmLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'alarmLabel', value: ''),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  dismissTimeSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dismissTimeSeconds', value: value),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  dismissTimeSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dismissTimeSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  dismissTimeSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dismissTimeSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  dismissTimeSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dismissTimeSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  missionTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'missionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  missionTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'missionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  missionTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'missionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  missionTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'missionType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  missionTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'missionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  missionTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'missionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  missionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'missionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  missionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'missionType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  missionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'missionType', value: ''),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  missionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'missionType', value: ''),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  snoozeCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'snoozeCount', value: value),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  snoozeCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'snoozeCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  snoozeCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'snoozeCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  snoozeCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'snoozeCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterFilterCondition>
  verifiedAwakeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verifiedAwake', value: value),
      );
    });
  }
}

extension AlarmHistoryQueryObject
    on QueryBuilder<AlarmHistory, AlarmHistory, QFilterCondition> {}

extension AlarmHistoryQueryLinks
    on QueryBuilder<AlarmHistory, AlarmHistory, QFilterCondition> {}

extension AlarmHistoryQuerySortBy
    on QueryBuilder<AlarmHistory, AlarmHistory, QSortBy> {
  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> sortByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> sortByAlarmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> sortByAlarmLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmLabel', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  sortByAlarmLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmLabel', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  sortByDismissTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  sortByDismissTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> sortByMissionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  sortByMissionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> sortBySnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeCount', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  sortBySnoozeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeCount', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> sortByVerifiedAwake() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifiedAwake', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  sortByVerifiedAwakeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifiedAwake', Sort.desc);
    });
  }
}

extension AlarmHistoryQuerySortThenBy
    on QueryBuilder<AlarmHistory, AlarmHistory, QSortThenBy> {
  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> thenByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> thenByAlarmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> thenByAlarmLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmLabel', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  thenByAlarmLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmLabel', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  thenByDismissTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  thenByDismissTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> thenByMissionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  thenByMissionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> thenBySnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeCount', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  thenBySnoozeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeCount', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy> thenByVerifiedAwake() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifiedAwake', Sort.asc);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QAfterSortBy>
  thenByVerifiedAwakeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifiedAwake', Sort.desc);
    });
  }
}

extension AlarmHistoryQueryWhereDistinct
    on QueryBuilder<AlarmHistory, AlarmHistory, QDistinct> {
  QueryBuilder<AlarmHistory, AlarmHistory, QDistinct> distinctByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alarmId');
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QDistinct> distinctByAlarmLabel({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alarmLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QDistinct>
  distinctByDismissTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dismissTimeSeconds');
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QDistinct> distinctByMissionType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QDistinct> distinctBySnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snoozeCount');
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<AlarmHistory, AlarmHistory, QDistinct>
  distinctByVerifiedAwake() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verifiedAwake');
    });
  }
}

extension AlarmHistoryQueryProperty
    on QueryBuilder<AlarmHistory, AlarmHistory, QQueryProperty> {
  QueryBuilder<AlarmHistory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AlarmHistory, int, QQueryOperations> alarmIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alarmId');
    });
  }

  QueryBuilder<AlarmHistory, String, QQueryOperations> alarmLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alarmLabel');
    });
  }

  QueryBuilder<AlarmHistory, int, QQueryOperations>
  dismissTimeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dismissTimeSeconds');
    });
  }

  QueryBuilder<AlarmHistory, String, QQueryOperations> missionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missionType');
    });
  }

  QueryBuilder<AlarmHistory, int, QQueryOperations> snoozeCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snoozeCount');
    });
  }

  QueryBuilder<AlarmHistory, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<AlarmHistory, bool, QQueryOperations> verifiedAwakeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verifiedAwake');
    });
  }
}
