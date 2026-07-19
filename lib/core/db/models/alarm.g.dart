// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAlarmCollection on Isar {
  IsarCollection<Alarm> get alarms => this.collection();
}

const AlarmSchema = CollectionSchema(
  name: r'Alarm',
  id: -6172094888861729789,
  properties: {
    r'enabled': PropertySchema(
      id: 0,
      name: r'enabled',
      type: IsarType.bool,
    ),
    r'label': PropertySchema(
      id: 1,
      name: r'label',
      type: IsarType.string,
    ),
    r'repeatDays': PropertySchema(
      id: 2,
      name: r'repeatDays',
      type: IsarType.longList,
    ),
    r'snoozeDurationMinutes': PropertySchema(
      id: 3,
      name: r'snoozeDurationMinutes',
      type: IsarType.long,
    ),
    r'soundName': PropertySchema(
      id: 4,
      name: r'soundName',
      type: IsarType.string,
    ),
    r'time': PropertySchema(
      id: 5,
      name: r'time',
      type: IsarType.dateTime,
    ),
    r'vibrate': PropertySchema(
      id: 6,
      name: r'vibrate',
      type: IsarType.bool,
    )
  },
  estimateSize: _alarmEstimateSize,
  serialize: _alarmSerialize,
  deserialize: _alarmDeserialize,
  deserializeProp: _alarmDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _alarmGetId,
  getLinks: _alarmGetLinks,
  attach: _alarmAttach,
  version: '3.1.0+1',
);

int _alarmEstimateSize(
  Alarm object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.label.length * 3;
  bytesCount += 3 + object.repeatDays.length * 8;
  bytesCount += 3 + object.soundName.length * 3;
  return bytesCount;
}

void _alarmSerialize(
  Alarm object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.enabled);
  writer.writeString(offsets[1], object.label);
  writer.writeLongList(offsets[2], object.repeatDays);
  writer.writeLong(offsets[3], object.snoozeDurationMinutes);
  writer.writeString(offsets[4], object.soundName);
  writer.writeDateTime(offsets[5], object.time);
  writer.writeBool(offsets[6], object.vibrate);
}

Alarm _alarmDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Alarm(
    enabled: reader.readBoolOrNull(offsets[0]) ?? true,
    label: reader.readStringOrNull(offsets[1]) ?? 'Alarm',
    repeatDays: reader.readLongList(offsets[2]) ?? const [],
    snoozeDurationMinutes: reader.readLongOrNull(offsets[3]) ?? 5,
    soundName: reader.readStringOrNull(offsets[4]) ?? 'Default System Alarm',
    time: reader.readDateTime(offsets[5]),
    vibrate: reader.readBoolOrNull(offsets[6]) ?? true,
  );
  object.id = id;
  return object;
}

P _alarmDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? 'Alarm') as P;
    case 2:
      return (reader.readLongList(offset) ?? const []) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 5) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? 'Default System Alarm') as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _alarmGetId(Alarm object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _alarmGetLinks(Alarm object) {
  return [];
}

void _alarmAttach(IsarCollection<dynamic> col, Id id, Alarm object) {
  object.id = id;
}

extension AlarmQueryWhereSort on QueryBuilder<Alarm, Alarm, QWhere> {
  QueryBuilder<Alarm, Alarm, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AlarmQueryWhere on QueryBuilder<Alarm, Alarm, QWhereClause> {
  QueryBuilder<Alarm, Alarm, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Alarm, Alarm, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AlarmQueryFilter on QueryBuilder<Alarm, Alarm, QFilterCondition> {
  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysElementEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      repeatDaysElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      snoozeDurationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snoozeDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      snoozeDurationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'snoozeDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      snoozeDurationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'snoozeDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      snoozeDurationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'snoozeDurationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'soundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'soundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'soundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'soundName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'soundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'soundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'soundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'soundName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'soundName',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'soundName',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> vibrateEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vibrate',
        value: value,
      ));
    });
  }
}

extension AlarmQueryObject on QueryBuilder<Alarm, Alarm, QFilterCondition> {}

extension AlarmQueryLinks on QueryBuilder<Alarm, Alarm, QFilterCondition> {}

extension AlarmQuerySortBy on QueryBuilder<Alarm, Alarm, QSortBy> {
  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySnoozeDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySnoozeDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySoundName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundName', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySoundNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundName', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByVibrate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrate', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByVibrateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrate', Sort.desc);
    });
  }
}

extension AlarmQuerySortThenBy on QueryBuilder<Alarm, Alarm, QSortThenBy> {
  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySnoozeDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySnoozeDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySoundName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundName', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySoundNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundName', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByVibrate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrate', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByVibrateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrate', Sort.desc);
    });
  }
}

extension AlarmQueryWhereDistinct on QueryBuilder<Alarm, Alarm, QDistinct> {
  QueryBuilder<Alarm, Alarm, QDistinct> distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByRepeatDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatDays');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctBySnoozeDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snoozeDurationMinutes');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctBySoundName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'soundName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByVibrate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vibrate');
    });
  }
}

extension AlarmQueryProperty on QueryBuilder<Alarm, Alarm, QQueryProperty> {
  QueryBuilder<Alarm, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<Alarm, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<Alarm, List<int>, QQueryOperations> repeatDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatDays');
    });
  }

  QueryBuilder<Alarm, int, QQueryOperations> snoozeDurationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snoozeDurationMinutes');
    });
  }

  QueryBuilder<Alarm, String, QQueryOperations> soundNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'soundName');
    });
  }

  QueryBuilder<Alarm, DateTime, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> vibrateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vibrate');
    });
  }
}
