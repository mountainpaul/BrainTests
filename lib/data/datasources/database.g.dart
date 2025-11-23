// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AssessmentTableTable extends AssessmentTable
    with TableInfo<$AssessmentTableTable, AssessmentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  late final GeneratedColumnWithTypeConverter<AssessmentType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<AssessmentType>($AssessmentTableTable.$convertertype);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _maxScoreMeta =
      const VerificationMeta('maxScore');
  @override
  late final GeneratedColumn<int> maxScore = GeneratedColumn<int>(
      'max_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>('sync_status', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: Constant(SyncStatus.pendingInsert.index))
          .withConverter<SyncStatus>(
              $AssessmentTableTable.$convertersyncStatus);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        score,
        maxScore,
        notes,
        completedAt,
        createdAt,
        uuid,
        syncStatus,
        lastUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessments';
  @override
  VerificationContext validateIntegrity(Insertable<AssessmentEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('max_score')) {
      context.handle(_maxScoreMeta,
          maxScore.isAcceptableOrUnknown(data['max_score']!, _maxScoreMeta));
    } else if (isInserting) {
      context.missing(_maxScoreMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessmentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessmentEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: $AssessmentTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score'])!,
      maxScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_score'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      syncStatus: $AssessmentTableTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}sync_status'])!),
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
    );
  }

  @override
  $AssessmentTableTable createAlias(String alias) {
    return $AssessmentTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AssessmentType, String, String> $convertertype =
      const EnumNameConverter<AssessmentType>(AssessmentType.values);
  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class AssessmentEntry extends DataClass implements Insertable<AssessmentEntry> {
  final int id;
  final AssessmentType type;
  final int score;
  final int maxScore;
  final String? notes;
  final DateTime completedAt;
  final DateTime createdAt;
  final String uuid;
  final SyncStatus syncStatus;
  final DateTime lastUpdatedAt;
  const AssessmentEntry(
      {required this.id,
      required this.type,
      required this.score,
      required this.maxScore,
      this.notes,
      required this.completedAt,
      required this.createdAt,
      required this.uuid,
      required this.syncStatus,
      required this.lastUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] =
          Variable<String>($AssessmentTableTable.$convertertype.toSql(type));
    }
    map['score'] = Variable<int>(score);
    map['max_score'] = Variable<int>(maxScore);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['uuid'] = Variable<String>(uuid);
    {
      map['sync_status'] = Variable<int>(
          $AssessmentTableTable.$convertersyncStatus.toSql(syncStatus));
    }
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    return map;
  }

  AssessmentTableCompanion toCompanion(bool nullToAbsent) {
    return AssessmentTableCompanion(
      id: Value(id),
      type: Value(type),
      score: Value(score),
      maxScore: Value(maxScore),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      completedAt: Value(completedAt),
      createdAt: Value(createdAt),
      uuid: Value(uuid),
      syncStatus: Value(syncStatus),
      lastUpdatedAt: Value(lastUpdatedAt),
    );
  }

  factory AssessmentEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessmentEntry(
      id: serializer.fromJson<int>(json['id']),
      type: $AssessmentTableTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      score: serializer.fromJson<int>(json['score']),
      maxScore: serializer.fromJson<int>(json['maxScore']),
      notes: serializer.fromJson<String?>(json['notes']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncStatus: $AssessmentTableTable.$convertersyncStatus
          .fromJson(serializer.fromJson<int>(json['syncStatus'])),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer
          .toJson<String>($AssessmentTableTable.$convertertype.toJson(type)),
      'score': serializer.toJson<int>(score),
      'maxScore': serializer.toJson<int>(maxScore),
      'notes': serializer.toJson<String?>(notes),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'uuid': serializer.toJson<String>(uuid),
      'syncStatus': serializer.toJson<int>(
          $AssessmentTableTable.$convertersyncStatus.toJson(syncStatus)),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
    };
  }

  AssessmentEntry copyWith(
          {int? id,
          AssessmentType? type,
          int? score,
          int? maxScore,
          Value<String?> notes = const Value.absent(),
          DateTime? completedAt,
          DateTime? createdAt,
          String? uuid,
          SyncStatus? syncStatus,
          DateTime? lastUpdatedAt}) =>
      AssessmentEntry(
        id: id ?? this.id,
        type: type ?? this.type,
        score: score ?? this.score,
        maxScore: maxScore ?? this.maxScore,
        notes: notes.present ? notes.value : this.notes,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        uuid: uuid ?? this.uuid,
        syncStatus: syncStatus ?? this.syncStatus,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
  AssessmentEntry copyWithCompanion(AssessmentTableCompanion data) {
    return AssessmentEntry(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      score: data.score.present ? data.score.value : this.score,
      maxScore: data.maxScore.present ? data.maxScore.value : this.maxScore,
      notes: data.notes.present ? data.notes.value : this.notes,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentEntry(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('score: $score, ')
          ..write('maxScore: $maxScore, ')
          ..write('notes: $notes, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('uuid: $uuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, score, maxScore, notes, completedAt,
      createdAt, uuid, syncStatus, lastUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessmentEntry &&
          other.id == this.id &&
          other.type == this.type &&
          other.score == this.score &&
          other.maxScore == this.maxScore &&
          other.notes == this.notes &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.uuid == this.uuid &&
          other.syncStatus == this.syncStatus &&
          other.lastUpdatedAt == this.lastUpdatedAt);
}

class AssessmentTableCompanion extends UpdateCompanion<AssessmentEntry> {
  final Value<int> id;
  final Value<AssessmentType> type;
  final Value<int> score;
  final Value<int> maxScore;
  final Value<String?> notes;
  final Value<DateTime> completedAt;
  final Value<DateTime> createdAt;
  final Value<String> uuid;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastUpdatedAt;
  const AssessmentTableCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.score = const Value.absent(),
    this.maxScore = const Value.absent(),
    this.notes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  });
  AssessmentTableCompanion.insert({
    this.id = const Value.absent(),
    required AssessmentType type,
    required int score,
    required int maxScore,
    this.notes = const Value.absent(),
    required DateTime completedAt,
    this.createdAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  })  : type = Value(type),
        score = Value(score),
        maxScore = Value(maxScore),
        completedAt = Value(completedAt);
  static Insertable<AssessmentEntry> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? score,
    Expression<int>? maxScore,
    Expression<String>? notes,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? uuid,
    Expression<int>? syncStatus,
    Expression<DateTime>? lastUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (score != null) 'score': score,
      if (maxScore != null) 'max_score': maxScore,
      if (notes != null) 'notes': notes,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (uuid != null) 'uuid': uuid,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
    });
  }

  AssessmentTableCompanion copyWith(
      {Value<int>? id,
      Value<AssessmentType>? type,
      Value<int>? score,
      Value<int>? maxScore,
      Value<String?>? notes,
      Value<DateTime>? completedAt,
      Value<DateTime>? createdAt,
      Value<String>? uuid,
      Value<SyncStatus>? syncStatus,
      Value<DateTime>? lastUpdatedAt}) {
    return AssessmentTableCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      uuid: uuid ?? this.uuid,
      syncStatus: syncStatus ?? this.syncStatus,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
          $AssessmentTableTable.$convertertype.toSql(type.value));
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (maxScore.present) {
      map['max_score'] = Variable<int>(maxScore.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
          $AssessmentTableTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentTableCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('score: $score, ')
          ..write('maxScore: $maxScore, ')
          ..write('notes: $notes, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('uuid: $uuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $CognitiveExerciseTableTable extends CognitiveExerciseTable
    with TableInfo<$CognitiveExerciseTableTable, CognitiveExerciseEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CognitiveExerciseTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ExerciseType>(
              $CognitiveExerciseTableTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseDifficulty, String>
      difficulty = GeneratedColumn<String>('difficulty', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ExerciseDifficulty>(
              $CognitiveExerciseTableTable.$converterdifficulty);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _maxScoreMeta =
      const VerificationMeta('maxScore');
  @override
  late final GeneratedColumn<int> maxScore = GeneratedColumn<int>(
      'max_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timeSpentSecondsMeta =
      const VerificationMeta('timeSpentSeconds');
  @override
  late final GeneratedColumn<int> timeSpentSeconds = GeneratedColumn<int>(
      'time_spent_seconds', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _exerciseDataMeta =
      const VerificationMeta('exerciseData');
  @override
  late final GeneratedColumn<String> exerciseData = GeneratedColumn<String>(
      'exercise_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>('sync_status', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: Constant(SyncStatus.pendingInsert.index))
          .withConverter<SyncStatus>(
              $CognitiveExerciseTableTable.$convertersyncStatus);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        difficulty,
        score,
        maxScore,
        timeSpentSeconds,
        isCompleted,
        exerciseData,
        completedAt,
        createdAt,
        uuid,
        syncStatus,
        lastUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cognitive_exercises';
  @override
  VerificationContext validateIntegrity(
      Insertable<CognitiveExerciseEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('max_score')) {
      context.handle(_maxScoreMeta,
          maxScore.isAcceptableOrUnknown(data['max_score']!, _maxScoreMeta));
    } else if (isInserting) {
      context.missing(_maxScoreMeta);
    }
    if (data.containsKey('time_spent_seconds')) {
      context.handle(
          _timeSpentSecondsMeta,
          timeSpentSeconds.isAcceptableOrUnknown(
              data['time_spent_seconds']!, _timeSpentSecondsMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('exercise_data')) {
      context.handle(
          _exerciseDataMeta,
          exerciseData.isAcceptableOrUnknown(
              data['exercise_data']!, _exerciseDataMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CognitiveExerciseEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CognitiveExerciseEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: $CognitiveExerciseTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      difficulty: $CognitiveExerciseTableTable.$converterdifficulty.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}difficulty'])!),
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score']),
      maxScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_score'])!,
      timeSpentSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_spent_seconds']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      exerciseData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_data']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      syncStatus: $CognitiveExerciseTableTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}sync_status'])!),
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
    );
  }

  @override
  $CognitiveExerciseTableTable createAlias(String alias) {
    return $CognitiveExerciseTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExerciseType, String, String> $convertertype =
      const EnumNameConverter<ExerciseType>(ExerciseType.values);
  static JsonTypeConverter2<ExerciseDifficulty, String, String>
      $converterdifficulty =
      const EnumNameConverter<ExerciseDifficulty>(ExerciseDifficulty.values);
  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class CognitiveExerciseEntry extends DataClass
    implements Insertable<CognitiveExerciseEntry> {
  final int id;
  final String name;
  final ExerciseType type;
  final ExerciseDifficulty difficulty;
  final int? score;
  final int maxScore;
  final int? timeSpentSeconds;
  final bool isCompleted;
  final String? exerciseData;
  final DateTime? completedAt;
  final DateTime createdAt;
  final String uuid;
  final SyncStatus syncStatus;
  final DateTime lastUpdatedAt;
  const CognitiveExerciseEntry(
      {required this.id,
      required this.name,
      required this.type,
      required this.difficulty,
      this.score,
      required this.maxScore,
      this.timeSpentSeconds,
      required this.isCompleted,
      this.exerciseData,
      this.completedAt,
      required this.createdAt,
      required this.uuid,
      required this.syncStatus,
      required this.lastUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>(
          $CognitiveExerciseTableTable.$convertertype.toSql(type));
    }
    {
      map['difficulty'] = Variable<String>(
          $CognitiveExerciseTableTable.$converterdifficulty.toSql(difficulty));
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    map['max_score'] = Variable<int>(maxScore);
    if (!nullToAbsent || timeSpentSeconds != null) {
      map['time_spent_seconds'] = Variable<int>(timeSpentSeconds);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || exerciseData != null) {
      map['exercise_data'] = Variable<String>(exerciseData);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['uuid'] = Variable<String>(uuid);
    {
      map['sync_status'] = Variable<int>(
          $CognitiveExerciseTableTable.$convertersyncStatus.toSql(syncStatus));
    }
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    return map;
  }

  CognitiveExerciseTableCompanion toCompanion(bool nullToAbsent) {
    return CognitiveExerciseTableCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      difficulty: Value(difficulty),
      score:
          score == null && nullToAbsent ? const Value.absent() : Value(score),
      maxScore: Value(maxScore),
      timeSpentSeconds: timeSpentSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(timeSpentSeconds),
      isCompleted: Value(isCompleted),
      exerciseData: exerciseData == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseData),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      uuid: Value(uuid),
      syncStatus: Value(syncStatus),
      lastUpdatedAt: Value(lastUpdatedAt),
    );
  }

  factory CognitiveExerciseEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CognitiveExerciseEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $CognitiveExerciseTableTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      difficulty: $CognitiveExerciseTableTable.$converterdifficulty
          .fromJson(serializer.fromJson<String>(json['difficulty'])),
      score: serializer.fromJson<int?>(json['score']),
      maxScore: serializer.fromJson<int>(json['maxScore']),
      timeSpentSeconds: serializer.fromJson<int?>(json['timeSpentSeconds']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      exerciseData: serializer.fromJson<String?>(json['exerciseData']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncStatus: $CognitiveExerciseTableTable.$convertersyncStatus
          .fromJson(serializer.fromJson<int>(json['syncStatus'])),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
          $CognitiveExerciseTableTable.$convertertype.toJson(type)),
      'difficulty': serializer.toJson<String>(
          $CognitiveExerciseTableTable.$converterdifficulty.toJson(difficulty)),
      'score': serializer.toJson<int?>(score),
      'maxScore': serializer.toJson<int>(maxScore),
      'timeSpentSeconds': serializer.toJson<int?>(timeSpentSeconds),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'exerciseData': serializer.toJson<String?>(exerciseData),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'uuid': serializer.toJson<String>(uuid),
      'syncStatus': serializer.toJson<int>(
          $CognitiveExerciseTableTable.$convertersyncStatus.toJson(syncStatus)),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
    };
  }

  CognitiveExerciseEntry copyWith(
          {int? id,
          String? name,
          ExerciseType? type,
          ExerciseDifficulty? difficulty,
          Value<int?> score = const Value.absent(),
          int? maxScore,
          Value<int?> timeSpentSeconds = const Value.absent(),
          bool? isCompleted,
          Value<String?> exerciseData = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt,
          String? uuid,
          SyncStatus? syncStatus,
          DateTime? lastUpdatedAt}) =>
      CognitiveExerciseEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        difficulty: difficulty ?? this.difficulty,
        score: score.present ? score.value : this.score,
        maxScore: maxScore ?? this.maxScore,
        timeSpentSeconds: timeSpentSeconds.present
            ? timeSpentSeconds.value
            : this.timeSpentSeconds,
        isCompleted: isCompleted ?? this.isCompleted,
        exerciseData:
            exerciseData.present ? exerciseData.value : this.exerciseData,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        uuid: uuid ?? this.uuid,
        syncStatus: syncStatus ?? this.syncStatus,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
  CognitiveExerciseEntry copyWithCompanion(
      CognitiveExerciseTableCompanion data) {
    return CognitiveExerciseEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      score: data.score.present ? data.score.value : this.score,
      maxScore: data.maxScore.present ? data.maxScore.value : this.maxScore,
      timeSpentSeconds: data.timeSpentSeconds.present
          ? data.timeSpentSeconds.value
          : this.timeSpentSeconds,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      exerciseData: data.exerciseData.present
          ? data.exerciseData.value
          : this.exerciseData,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CognitiveExerciseEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('difficulty: $difficulty, ')
          ..write('score: $score, ')
          ..write('maxScore: $maxScore, ')
          ..write('timeSpentSeconds: $timeSpentSeconds, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('exerciseData: $exerciseData, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('uuid: $uuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      type,
      difficulty,
      score,
      maxScore,
      timeSpentSeconds,
      isCompleted,
      exerciseData,
      completedAt,
      createdAt,
      uuid,
      syncStatus,
      lastUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CognitiveExerciseEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.difficulty == this.difficulty &&
          other.score == this.score &&
          other.maxScore == this.maxScore &&
          other.timeSpentSeconds == this.timeSpentSeconds &&
          other.isCompleted == this.isCompleted &&
          other.exerciseData == this.exerciseData &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.uuid == this.uuid &&
          other.syncStatus == this.syncStatus &&
          other.lastUpdatedAt == this.lastUpdatedAt);
}

class CognitiveExerciseTableCompanion
    extends UpdateCompanion<CognitiveExerciseEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<ExerciseType> type;
  final Value<ExerciseDifficulty> difficulty;
  final Value<int?> score;
  final Value<int> maxScore;
  final Value<int?> timeSpentSeconds;
  final Value<bool> isCompleted;
  final Value<String?> exerciseData;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<String> uuid;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastUpdatedAt;
  const CognitiveExerciseTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.score = const Value.absent(),
    this.maxScore = const Value.absent(),
    this.timeSpentSeconds = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.exerciseData = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  });
  CognitiveExerciseTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required ExerciseType type,
    required ExerciseDifficulty difficulty,
    this.score = const Value.absent(),
    required int maxScore,
    this.timeSpentSeconds = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.exerciseData = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  })  : name = Value(name),
        type = Value(type),
        difficulty = Value(difficulty),
        maxScore = Value(maxScore);
  static Insertable<CognitiveExerciseEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? difficulty,
    Expression<int>? score,
    Expression<int>? maxScore,
    Expression<int>? timeSpentSeconds,
    Expression<bool>? isCompleted,
    Expression<String>? exerciseData,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? uuid,
    Expression<int>? syncStatus,
    Expression<DateTime>? lastUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (difficulty != null) 'difficulty': difficulty,
      if (score != null) 'score': score,
      if (maxScore != null) 'max_score': maxScore,
      if (timeSpentSeconds != null) 'time_spent_seconds': timeSpentSeconds,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (exerciseData != null) 'exercise_data': exerciseData,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (uuid != null) 'uuid': uuid,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
    });
  }

  CognitiveExerciseTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<ExerciseType>? type,
      Value<ExerciseDifficulty>? difficulty,
      Value<int?>? score,
      Value<int>? maxScore,
      Value<int?>? timeSpentSeconds,
      Value<bool>? isCompleted,
      Value<String?>? exerciseData,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<String>? uuid,
      Value<SyncStatus>? syncStatus,
      Value<DateTime>? lastUpdatedAt}) {
    return CognitiveExerciseTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      exerciseData: exerciseData ?? this.exerciseData,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      uuid: uuid ?? this.uuid,
      syncStatus: syncStatus ?? this.syncStatus,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
          $CognitiveExerciseTableTable.$convertertype.toSql(type.value));
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>($CognitiveExerciseTableTable
          .$converterdifficulty
          .toSql(difficulty.value));
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (maxScore.present) {
      map['max_score'] = Variable<int>(maxScore.value);
    }
    if (timeSpentSeconds.present) {
      map['time_spent_seconds'] = Variable<int>(timeSpentSeconds.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (exerciseData.present) {
      map['exercise_data'] = Variable<String>(exerciseData.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>($CognitiveExerciseTableTable
          .$convertersyncStatus
          .toSql(syncStatus.value));
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CognitiveExerciseTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('difficulty: $difficulty, ')
          ..write('score: $score, ')
          ..write('maxScore: $maxScore, ')
          ..write('timeSpentSeconds: $timeSpentSeconds, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('exerciseData: $exerciseData, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('uuid: $uuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $WordDictionaryTableTable extends WordDictionaryTable
    with TableInfo<$WordDictionaryTableTable, WordDictionary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordDictionaryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<WordLanguage, String> language =
      GeneratedColumn<String>('language', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<WordLanguage>(
              $WordDictionaryTableTable.$converterlanguage);
  @override
  late final GeneratedColumnWithTypeConverter<WordType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<WordType>($WordDictionaryTableTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseDifficulty, String>
      difficulty = GeneratedColumn<String>('difficulty', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ExerciseDifficulty>(
              $WordDictionaryTableTable.$converterdifficulty);
  static const VerificationMeta _lengthMeta = const VerificationMeta('length');
  @override
  late final GeneratedColumn<int> length = GeneratedColumn<int>(
      'length', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        word,
        language,
        type,
        difficulty,
        length,
        version,
        isActive,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_dictionary';
  @override
  VerificationContext validateIntegrity(Insertable<WordDictionary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('length')) {
      context.handle(_lengthMeta,
          length.isAcceptableOrUnknown(data['length']!, _lengthMeta));
    } else if (isInserting) {
      context.missing(_lengthMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordDictionary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordDictionary(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      language: $WordDictionaryTableTable.$converterlanguage.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}language'])!),
      type: $WordDictionaryTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      difficulty: $WordDictionaryTableTable.$converterdifficulty.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}difficulty'])!),
      length: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}length'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $WordDictionaryTableTable createAlias(String alias) {
    return $WordDictionaryTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WordLanguage, String, String> $converterlanguage =
      const EnumNameConverter<WordLanguage>(WordLanguage.values);
  static JsonTypeConverter2<WordType, String, String> $convertertype =
      const EnumNameConverter<WordType>(WordType.values);
  static JsonTypeConverter2<ExerciseDifficulty, String, String>
      $converterdifficulty =
      const EnumNameConverter<ExerciseDifficulty>(ExerciseDifficulty.values);
}

class WordDictionary extends DataClass implements Insertable<WordDictionary> {
  final int id;
  final String word;
  final WordLanguage language;
  final WordType type;
  final ExerciseDifficulty difficulty;
  final int length;
  final int version;
  final bool isActive;
  final DateTime createdAt;
  const WordDictionary(
      {required this.id,
      required this.word,
      required this.language,
      required this.type,
      required this.difficulty,
      required this.length,
      required this.version,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    {
      map['language'] = Variable<String>(
          $WordDictionaryTableTable.$converterlanguage.toSql(language));
    }
    {
      map['type'] = Variable<String>(
          $WordDictionaryTableTable.$convertertype.toSql(type));
    }
    {
      map['difficulty'] = Variable<String>(
          $WordDictionaryTableTable.$converterdifficulty.toSql(difficulty));
    }
    map['length'] = Variable<int>(length);
    map['version'] = Variable<int>(version);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WordDictionaryTableCompanion toCompanion(bool nullToAbsent) {
    return WordDictionaryTableCompanion(
      id: Value(id),
      word: Value(word),
      language: Value(language),
      type: Value(type),
      difficulty: Value(difficulty),
      length: Value(length),
      version: Value(version),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory WordDictionary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordDictionary(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      language: $WordDictionaryTableTable.$converterlanguage
          .fromJson(serializer.fromJson<String>(json['language'])),
      type: $WordDictionaryTableTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      difficulty: $WordDictionaryTableTable.$converterdifficulty
          .fromJson(serializer.fromJson<String>(json['difficulty'])),
      length: serializer.fromJson<int>(json['length']),
      version: serializer.fromJson<int>(json['version']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'language': serializer.toJson<String>(
          $WordDictionaryTableTable.$converterlanguage.toJson(language)),
      'type': serializer.toJson<String>(
          $WordDictionaryTableTable.$convertertype.toJson(type)),
      'difficulty': serializer.toJson<String>(
          $WordDictionaryTableTable.$converterdifficulty.toJson(difficulty)),
      'length': serializer.toJson<int>(length),
      'version': serializer.toJson<int>(version),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WordDictionary copyWith(
          {int? id,
          String? word,
          WordLanguage? language,
          WordType? type,
          ExerciseDifficulty? difficulty,
          int? length,
          int? version,
          bool? isActive,
          DateTime? createdAt}) =>
      WordDictionary(
        id: id ?? this.id,
        word: word ?? this.word,
        language: language ?? this.language,
        type: type ?? this.type,
        difficulty: difficulty ?? this.difficulty,
        length: length ?? this.length,
        version: version ?? this.version,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  WordDictionary copyWithCompanion(WordDictionaryTableCompanion data) {
    return WordDictionary(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      language: data.language.present ? data.language.value : this.language,
      type: data.type.present ? data.type.value : this.type,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      length: data.length.present ? data.length.value : this.length,
      version: data.version.present ? data.version.value : this.version,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordDictionary(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('language: $language, ')
          ..write('type: $type, ')
          ..write('difficulty: $difficulty, ')
          ..write('length: $length, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, word, language, type, difficulty, length,
      version, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordDictionary &&
          other.id == this.id &&
          other.word == this.word &&
          other.language == this.language &&
          other.type == this.type &&
          other.difficulty == this.difficulty &&
          other.length == this.length &&
          other.version == this.version &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class WordDictionaryTableCompanion extends UpdateCompanion<WordDictionary> {
  final Value<int> id;
  final Value<String> word;
  final Value<WordLanguage> language;
  final Value<WordType> type;
  final Value<ExerciseDifficulty> difficulty;
  final Value<int> length;
  final Value<int> version;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const WordDictionaryTableCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.language = const Value.absent(),
    this.type = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.length = const Value.absent(),
    this.version = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WordDictionaryTableCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    required WordLanguage language,
    required WordType type,
    required ExerciseDifficulty difficulty,
    required int length,
    this.version = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : word = Value(word),
        language = Value(language),
        type = Value(type),
        difficulty = Value(difficulty),
        length = Value(length);
  static Insertable<WordDictionary> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<String>? language,
    Expression<String>? type,
    Expression<String>? difficulty,
    Expression<int>? length,
    Expression<int>? version,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (language != null) 'language': language,
      if (type != null) 'type': type,
      if (difficulty != null) 'difficulty': difficulty,
      if (length != null) 'length': length,
      if (version != null) 'version': version,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WordDictionaryTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? word,
      Value<WordLanguage>? language,
      Value<WordType>? type,
      Value<ExerciseDifficulty>? difficulty,
      Value<int>? length,
      Value<int>? version,
      Value<bool>? isActive,
      Value<DateTime>? createdAt}) {
    return WordDictionaryTableCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      language: language ?? this.language,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      length: length ?? this.length,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(
          $WordDictionaryTableTable.$converterlanguage.toSql(language.value));
    }
    if (type.present) {
      map['type'] = Variable<String>(
          $WordDictionaryTableTable.$convertertype.toSql(type.value));
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>($WordDictionaryTableTable
          .$converterdifficulty
          .toSql(difficulty.value));
    }
    if (length.present) {
      map['length'] = Variable<int>(length.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordDictionaryTableCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('language: $language, ')
          ..write('type: $type, ')
          ..write('difficulty: $difficulty, ')
          ..write('length: $length, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserProfileTableTable extends UserProfileTable
    with TableInfo<$UserProfileTableTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _programStartDateMeta =
      const VerificationMeta('programStartDate');
  @override
  late final GeneratedColumn<DateTime> programStartDate =
      GeneratedColumn<DateTime>('program_start_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>('sync_status', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: Constant(SyncStatus.pendingInsert.index))
          .withConverter<SyncStatus>(
              $UserProfileTableTable.$convertersyncStatus);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        age,
        dateOfBirth,
        gender,
        programStartDate,
        createdAt,
        updatedAt,
        uuid,
        syncStatus,
        lastUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('program_start_date')) {
      context.handle(
          _programStartDateMeta,
          programStartDate.isAcceptableOrUnknown(
              data['program_start_date']!, _programStartDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      programStartDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}program_start_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      syncStatus: $UserProfileTableTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}sync_status'])!),
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
    );
  }

  @override
  $UserProfileTableTable createAlias(String alias) {
    return $UserProfileTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String? name;
  final int? age;
  final DateTime? dateOfBirth;
  final String? gender;
  final DateTime? programStartDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String uuid;
  final SyncStatus syncStatus;
  final DateTime lastUpdatedAt;
  const UserProfile(
      {required this.id,
      this.name,
      this.age,
      this.dateOfBirth,
      this.gender,
      this.programStartDate,
      required this.createdAt,
      required this.updatedAt,
      required this.uuid,
      required this.syncStatus,
      required this.lastUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || programStartDate != null) {
      map['program_start_date'] = Variable<DateTime>(programStartDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['uuid'] = Variable<String>(uuid);
    {
      map['sync_status'] = Variable<int>(
          $UserProfileTableTable.$convertersyncStatus.toSql(syncStatus));
    }
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    return map;
  }

  UserProfileTableCompanion toCompanion(bool nullToAbsent) {
    return UserProfileTableCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      programStartDate: programStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(programStartDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      uuid: Value(uuid),
      syncStatus: Value(syncStatus),
      lastUpdatedAt: Value(lastUpdatedAt),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      age: serializer.fromJson<int?>(json['age']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      gender: serializer.fromJson<String?>(json['gender']),
      programStartDate:
          serializer.fromJson<DateTime?>(json['programStartDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncStatus: $UserProfileTableTable.$convertersyncStatus
          .fromJson(serializer.fromJson<int>(json['syncStatus'])),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'age': serializer.toJson<int?>(age),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'gender': serializer.toJson<String?>(gender),
      'programStartDate': serializer.toJson<DateTime?>(programStartDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'uuid': serializer.toJson<String>(uuid),
      'syncStatus': serializer.toJson<int>(
          $UserProfileTableTable.$convertersyncStatus.toJson(syncStatus)),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
    };
  }

  UserProfile copyWith(
          {int? id,
          Value<String?> name = const Value.absent(),
          Value<int?> age = const Value.absent(),
          Value<DateTime?> dateOfBirth = const Value.absent(),
          Value<String?> gender = const Value.absent(),
          Value<DateTime?> programStartDate = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? uuid,
          SyncStatus? syncStatus,
          DateTime? lastUpdatedAt}) =>
      UserProfile(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        age: age.present ? age.value : this.age,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        gender: gender.present ? gender.value : this.gender,
        programStartDate: programStartDate.present
            ? programStartDate.value
            : this.programStartDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        uuid: uuid ?? this.uuid,
        syncStatus: syncStatus ?? this.syncStatus,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
  UserProfile copyWithCompanion(UserProfileTableCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      gender: data.gender.present ? data.gender.value : this.gender,
      programStartDate: data.programStartDate.present
          ? data.programStartDate.value
          : this.programStartDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('programStartDate: $programStartDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uuid: $uuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, age, dateOfBirth, gender,
      programStartDate, createdAt, updatedAt, uuid, syncStatus, lastUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.dateOfBirth == this.dateOfBirth &&
          other.gender == this.gender &&
          other.programStartDate == this.programStartDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.uuid == this.uuid &&
          other.syncStatus == this.syncStatus &&
          other.lastUpdatedAt == this.lastUpdatedAt);
}

class UserProfileTableCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String?> name;
  final Value<int?> age;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> gender;
  final Value<DateTime?> programStartDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> uuid;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastUpdatedAt;
  const UserProfileTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.programStartDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  });
  UserProfileTableCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.programStartDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  });
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? gender,
    Expression<DateTime>? programStartDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? uuid,
    Expression<int>? syncStatus,
    Expression<DateTime>? lastUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (programStartDate != null) 'program_start_date': programStartDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (uuid != null) 'uuid': uuid,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
    });
  }

  UserProfileTableCompanion copyWith(
      {Value<int>? id,
      Value<String?>? name,
      Value<int?>? age,
      Value<DateTime?>? dateOfBirth,
      Value<String?>? gender,
      Value<DateTime?>? programStartDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? uuid,
      Value<SyncStatus>? syncStatus,
      Value<DateTime>? lastUpdatedAt}) {
    return UserProfileTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      programStartDate: programStartDate ?? this.programStartDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uuid: uuid ?? this.uuid,
      syncStatus: syncStatus ?? this.syncStatus,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (programStartDate.present) {
      map['program_start_date'] = Variable<DateTime>(programStartDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
          $UserProfileTableTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('programStartDate: $programStartDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uuid: $uuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $CambridgeAssessmentTableTable extends CambridgeAssessmentTable
    with TableInfo<$CambridgeAssessmentTableTable, CambridgeAssessmentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CambridgeAssessmentTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  late final GeneratedColumnWithTypeConverter<CambridgeTestType, String>
      testType = GeneratedColumn<String>('test_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<CambridgeTestType>(
              $CambridgeAssessmentTableTable.$convertertestType);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalTrialsMeta =
      const VerificationMeta('totalTrials');
  @override
  late final GeneratedColumn<int> totalTrials = GeneratedColumn<int>(
      'total_trials', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _correctTrialsMeta =
      const VerificationMeta('correctTrials');
  @override
  late final GeneratedColumn<int> correctTrials = GeneratedColumn<int>(
      'correct_trials', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _errorCountMeta =
      const VerificationMeta('errorCount');
  @override
  late final GeneratedColumn<int> errorCount = GeneratedColumn<int>(
      'error_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _meanLatencyMsMeta =
      const VerificationMeta('meanLatencyMs');
  @override
  late final GeneratedColumn<double> meanLatencyMs = GeneratedColumn<double>(
      'mean_latency_ms', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _medianLatencyMsMeta =
      const VerificationMeta('medianLatencyMs');
  @override
  late final GeneratedColumn<double> medianLatencyMs = GeneratedColumn<double>(
      'median_latency_ms', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _normScoreMeta =
      const VerificationMeta('normScore');
  @override
  late final GeneratedColumn<double> normScore = GeneratedColumn<double>(
      'norm_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _interpretationMeta =
      const VerificationMeta('interpretation');
  @override
  late final GeneratedColumn<String> interpretation = GeneratedColumn<String>(
      'interpretation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _specificMetricsMeta =
      const VerificationMeta('specificMetrics');
  @override
  late final GeneratedColumn<String> specificMetrics = GeneratedColumn<String>(
      'specific_metrics', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>('sync_status', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: Constant(SyncStatus.pendingInsert.index))
          .withConverter<SyncStatus>(
              $CambridgeAssessmentTableTable.$convertersyncStatus);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        testType,
        durationSeconds,
        accuracy,
        totalTrials,
        correctTrials,
        errorCount,
        meanLatencyMs,
        medianLatencyMs,
        normScore,
        interpretation,
        specificMetrics,
        completedAt,
        createdAt,
        uuid,
        syncStatus,
        lastUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cambridge_assessments';
  @override
  VerificationContext validateIntegrity(
      Insertable<CambridgeAssessmentEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('total_trials')) {
      context.handle(
          _totalTrialsMeta,
          totalTrials.isAcceptableOrUnknown(
              data['total_trials']!, _totalTrialsMeta));
    } else if (isInserting) {
      context.missing(_totalTrialsMeta);
    }
    if (data.containsKey('correct_trials')) {
      context.handle(
          _correctTrialsMeta,
          correctTrials.isAcceptableOrUnknown(
              data['correct_trials']!, _correctTrialsMeta));
    } else if (isInserting) {
      context.missing(_correctTrialsMeta);
    }
    if (data.containsKey('error_count')) {
      context.handle(
          _errorCountMeta,
          errorCount.isAcceptableOrUnknown(
              data['error_count']!, _errorCountMeta));
    } else if (isInserting) {
      context.missing(_errorCountMeta);
    }
    if (data.containsKey('mean_latency_ms')) {
      context.handle(
          _meanLatencyMsMeta,
          meanLatencyMs.isAcceptableOrUnknown(
              data['mean_latency_ms']!, _meanLatencyMsMeta));
    } else if (isInserting) {
      context.missing(_meanLatencyMsMeta);
    }
    if (data.containsKey('median_latency_ms')) {
      context.handle(
          _medianLatencyMsMeta,
          medianLatencyMs.isAcceptableOrUnknown(
              data['median_latency_ms']!, _medianLatencyMsMeta));
    } else if (isInserting) {
      context.missing(_medianLatencyMsMeta);
    }
    if (data.containsKey('norm_score')) {
      context.handle(_normScoreMeta,
          normScore.isAcceptableOrUnknown(data['norm_score']!, _normScoreMeta));
    } else if (isInserting) {
      context.missing(_normScoreMeta);
    }
    if (data.containsKey('interpretation')) {
      context.handle(
          _interpretationMeta,
          interpretation.isAcceptableOrUnknown(
              data['interpretation']!, _interpretationMeta));
    } else if (isInserting) {
      context.missing(_interpretationMeta);
    }
    if (data.containsKey('specific_metrics')) {
      context.handle(
          _specificMetricsMeta,
          specificMetrics.isAcceptableOrUnknown(
              data['specific_metrics']!, _specificMetricsMeta));
    } else if (isInserting) {
      context.missing(_specificMetricsMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CambridgeAssessmentEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CambridgeAssessmentEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      testType: $CambridgeAssessmentTableTable.$convertertestType.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}test_type'])!),
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy'])!,
      totalTrials: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_trials'])!,
      correctTrials: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct_trials'])!,
      errorCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}error_count'])!,
      meanLatencyMs: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}mean_latency_ms'])!,
      medianLatencyMs: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}median_latency_ms'])!,
      normScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}norm_score'])!,
      interpretation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}interpretation'])!,
      specificMetrics: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specific_metrics'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      syncStatus: $CambridgeAssessmentTableTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}sync_status'])!),
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
    );
  }

  @override
  $CambridgeAssessmentTableTable createAlias(String alias) {
    return $CambridgeAssessmentTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CambridgeTestType, String, String>
      $convertertestType =
      const EnumNameConverter<CambridgeTestType>(CambridgeTestType.values);
  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class CambridgeAssessmentEntry extends DataClass
    implements Insertable<CambridgeAssessmentEntry> {
  final int id;
  final CambridgeTestType testType;
  final int durationSeconds;
  final double accuracy;
  final int totalTrials;
  final int correctTrials;
  final int errorCount;
  final double meanLatencyMs;
  final double medianLatencyMs;
  final double normScore;
  final String interpretation;
  final String specificMetrics;
  final DateTime completedAt;
  final DateTime createdAt;
  final String uuid;
  final SyncStatus syncStatus;
  final DateTime lastUpdatedAt;
  const CambridgeAssessmentEntry(
      {required this.id,
      required this.testType,
      required this.durationSeconds,
      required this.accuracy,
      required this.totalTrials,
      required this.correctTrials,
      required this.errorCount,
      required this.meanLatencyMs,
      required this.medianLatencyMs,
      required this.normScore,
      required this.interpretation,
      required this.specificMetrics,
      required this.completedAt,
      required this.createdAt,
      required this.uuid,
      required this.syncStatus,
      required this.lastUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['test_type'] = Variable<String>(
          $CambridgeAssessmentTableTable.$convertertestType.toSql(testType));
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['accuracy'] = Variable<double>(accuracy);
    map['total_trials'] = Variable<int>(totalTrials);
    map['correct_trials'] = Variable<int>(correctTrials);
    map['error_count'] = Variable<int>(errorCount);
    map['mean_latency_ms'] = Variable<double>(meanLatencyMs);
    map['median_latency_ms'] = Variable<double>(medianLatencyMs);
    map['norm_score'] = Variable<double>(normScore);
    map['interpretation'] = Variable<String>(interpretation);
    map['specific_metrics'] = Variable<String>(specificMetrics);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['uuid'] = Variable<String>(uuid);
    {
      map['sync_status'] = Variable<int>($CambridgeAssessmentTableTable
          .$convertersyncStatus
          .toSql(syncStatus));
    }
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    return map;
  }

  CambridgeAssessmentTableCompanion toCompanion(bool nullToAbsent) {
    return CambridgeAssessmentTableCompanion(
      id: Value(id),
      testType: Value(testType),
      durationSeconds: Value(durationSeconds),
      accuracy: Value(accuracy),
      totalTrials: Value(totalTrials),
      correctTrials: Value(correctTrials),
      errorCount: Value(errorCount),
      meanLatencyMs: Value(meanLatencyMs),
      medianLatencyMs: Value(medianLatencyMs),
      normScore: Value(normScore),
      interpretation: Value(interpretation),
      specificMetrics: Value(specificMetrics),
      completedAt: Value(completedAt),
      createdAt: Value(createdAt),
      uuid: Value(uuid),
      syncStatus: Value(syncStatus),
      lastUpdatedAt: Value(lastUpdatedAt),
    );
  }

  factory CambridgeAssessmentEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CambridgeAssessmentEntry(
      id: serializer.fromJson<int>(json['id']),
      testType: $CambridgeAssessmentTableTable.$convertertestType
          .fromJson(serializer.fromJson<String>(json['testType'])),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      totalTrials: serializer.fromJson<int>(json['totalTrials']),
      correctTrials: serializer.fromJson<int>(json['correctTrials']),
      errorCount: serializer.fromJson<int>(json['errorCount']),
      meanLatencyMs: serializer.fromJson<double>(json['meanLatencyMs']),
      medianLatencyMs: serializer.fromJson<double>(json['medianLatencyMs']),
      normScore: serializer.fromJson<double>(json['normScore']),
      interpretation: serializer.fromJson<String>(json['interpretation']),
      specificMetrics: serializer.fromJson<String>(json['specificMetrics']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncStatus: $CambridgeAssessmentTableTable.$convertersyncStatus
          .fromJson(serializer.fromJson<int>(json['syncStatus'])),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'testType': serializer.toJson<String>(
          $CambridgeAssessmentTableTable.$convertertestType.toJson(testType)),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'accuracy': serializer.toJson<double>(accuracy),
      'totalTrials': serializer.toJson<int>(totalTrials),
      'correctTrials': serializer.toJson<int>(correctTrials),
      'errorCount': serializer.toJson<int>(errorCount),
      'meanLatencyMs': serializer.toJson<double>(meanLatencyMs),
      'medianLatencyMs': serializer.toJson<double>(medianLatencyMs),
      'normScore': serializer.toJson<double>(normScore),
      'interpretation': serializer.toJson<String>(interpretation),
      'specificMetrics': serializer.toJson<String>(specificMetrics),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'uuid': serializer.toJson<String>(uuid),
      'syncStatus': serializer.toJson<int>($CambridgeAssessmentTableTable
          .$convertersyncStatus
          .toJson(syncStatus)),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
    };
  }

  CambridgeAssessmentEntry copyWith(
          {int? id,
          CambridgeTestType? testType,
          int? durationSeconds,
          double? accuracy,
          int? totalTrials,
          int? correctTrials,
          int? errorCount,
          double? meanLatencyMs,
          double? medianLatencyMs,
          double? normScore,
          String? interpretation,
          String? specificMetrics,
          DateTime? completedAt,
          DateTime? createdAt,
          String? uuid,
          SyncStatus? syncStatus,
          DateTime? lastUpdatedAt}) =>
      CambridgeAssessmentEntry(
        id: id ?? this.id,
        testType: testType ?? this.testType,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        accuracy: accuracy ?? this.accuracy,
        totalTrials: totalTrials ?? this.totalTrials,
        correctTrials: correctTrials ?? this.correctTrials,
        errorCount: errorCount ?? this.errorCount,
        meanLatencyMs: meanLatencyMs ?? this.meanLatencyMs,
        medianLatencyMs: medianLatencyMs ?? this.medianLatencyMs,
        normScore: normScore ?? this.normScore,
        interpretation: interpretation ?? this.interpretation,
        specificMetrics: specificMetrics ?? this.specificMetrics,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        uuid: uuid ?? this.uuid,
        syncStatus: syncStatus ?? this.syncStatus,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
  CambridgeAssessmentEntry copyWithCompanion(
      CambridgeAssessmentTableCompanion data) {
    return CambridgeAssessmentEntry(
      id: data.id.present ? data.id.value : this.id,
      testType: data.testType.present ? data.testType.value : this.testType,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      totalTrials:
          data.totalTrials.present ? data.totalTrials.value : this.totalTrials,
      correctTrials: data.correctTrials.present
          ? data.correctTrials.value
          : this.correctTrials,
      errorCount:
          data.errorCount.present ? data.errorCount.value : this.errorCount,
      meanLatencyMs: data.meanLatencyMs.present
          ? data.meanLatencyMs.value
          : this.meanLatencyMs,
      medianLatencyMs: data.medianLatencyMs.present
          ? data.medianLatencyMs.value
          : this.medianLatencyMs,
      normScore: data.normScore.present ? data.normScore.value : this.normScore,
      interpretation: data.interpretation.present
          ? data.interpretation.value
          : this.interpretation,
      specificMetrics: data.specificMetrics.present
          ? data.specificMetrics.value
          : this.specificMetrics,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CambridgeAssessmentEntry(')
          ..write('id: $id, ')
          ..write('testType: $testType, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('accuracy: $accuracy, ')
          ..write('totalTrials: $totalTrials, ')
          ..write('correctTrials: $correctTrials, ')
          ..write('errorCount: $errorCount, ')
          ..write('meanLatencyMs: $meanLatencyMs, ')
          ..write('medianLatencyMs: $medianLatencyMs, ')
          ..write('normScore: $normScore, ')
          ..write('interpretation: $interpretation, ')
          ..write('specificMetrics: $specificMetrics, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('uuid: $uuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      testType,
      durationSeconds,
      accuracy,
      totalTrials,
      correctTrials,
      errorCount,
      meanLatencyMs,
      medianLatencyMs,
      normScore,
      interpretation,
      specificMetrics,
      completedAt,
      createdAt,
      uuid,
      syncStatus,
      lastUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CambridgeAssessmentEntry &&
          other.id == this.id &&
          other.testType == this.testType &&
          other.durationSeconds == this.durationSeconds &&
          other.accuracy == this.accuracy &&
          other.totalTrials == this.totalTrials &&
          other.correctTrials == this.correctTrials &&
          other.errorCount == this.errorCount &&
          other.meanLatencyMs == this.meanLatencyMs &&
          other.medianLatencyMs == this.medianLatencyMs &&
          other.normScore == this.normScore &&
          other.interpretation == this.interpretation &&
          other.specificMetrics == this.specificMetrics &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.uuid == this.uuid &&
          other.syncStatus == this.syncStatus &&
          other.lastUpdatedAt == this.lastUpdatedAt);
}

class CambridgeAssessmentTableCompanion
    extends UpdateCompanion<CambridgeAssessmentEntry> {
  final Value<int> id;
  final Value<CambridgeTestType> testType;
  final Value<int> durationSeconds;
  final Value<double> accuracy;
  final Value<int> totalTrials;
  final Value<int> correctTrials;
  final Value<int> errorCount;
  final Value<double> meanLatencyMs;
  final Value<double> medianLatencyMs;
  final Value<double> normScore;
  final Value<String> interpretation;
  final Value<String> specificMetrics;
  final Value<DateTime> completedAt;
  final Value<DateTime> createdAt;
  final Value<String> uuid;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastUpdatedAt;
  const CambridgeAssessmentTableCompanion({
    this.id = const Value.absent(),
    this.testType = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.totalTrials = const Value.absent(),
    this.correctTrials = const Value.absent(),
    this.errorCount = const Value.absent(),
    this.meanLatencyMs = const Value.absent(),
    this.medianLatencyMs = const Value.absent(),
    this.normScore = const Value.absent(),
    this.interpretation = const Value.absent(),
    this.specificMetrics = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  });
  CambridgeAssessmentTableCompanion.insert({
    this.id = const Value.absent(),
    required CambridgeTestType testType,
    required int durationSeconds,
    required double accuracy,
    required int totalTrials,
    required int correctTrials,
    required int errorCount,
    required double meanLatencyMs,
    required double medianLatencyMs,
    required double normScore,
    required String interpretation,
    required String specificMetrics,
    required DateTime completedAt,
    this.createdAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  })  : testType = Value(testType),
        durationSeconds = Value(durationSeconds),
        accuracy = Value(accuracy),
        totalTrials = Value(totalTrials),
        correctTrials = Value(correctTrials),
        errorCount = Value(errorCount),
        meanLatencyMs = Value(meanLatencyMs),
        medianLatencyMs = Value(medianLatencyMs),
        normScore = Value(normScore),
        interpretation = Value(interpretation),
        specificMetrics = Value(specificMetrics),
        completedAt = Value(completedAt);
  static Insertable<CambridgeAssessmentEntry> custom({
    Expression<int>? id,
    Expression<String>? testType,
    Expression<int>? durationSeconds,
    Expression<double>? accuracy,
    Expression<int>? totalTrials,
    Expression<int>? correctTrials,
    Expression<int>? errorCount,
    Expression<double>? meanLatencyMs,
    Expression<double>? medianLatencyMs,
    Expression<double>? normScore,
    Expression<String>? interpretation,
    Expression<String>? specificMetrics,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? uuid,
    Expression<int>? syncStatus,
    Expression<DateTime>? lastUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (testType != null) 'test_type': testType,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (accuracy != null) 'accuracy': accuracy,
      if (totalTrials != null) 'total_trials': totalTrials,
      if (correctTrials != null) 'correct_trials': correctTrials,
      if (errorCount != null) 'error_count': errorCount,
      if (meanLatencyMs != null) 'mean_latency_ms': meanLatencyMs,
      if (medianLatencyMs != null) 'median_latency_ms': medianLatencyMs,
      if (normScore != null) 'norm_score': normScore,
      if (interpretation != null) 'interpretation': interpretation,
      if (specificMetrics != null) 'specific_metrics': specificMetrics,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (uuid != null) 'uuid': uuid,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
    });
  }

  CambridgeAssessmentTableCompanion copyWith(
      {Value<int>? id,
      Value<CambridgeTestType>? testType,
      Value<int>? durationSeconds,
      Value<double>? accuracy,
      Value<int>? totalTrials,
      Value<int>? correctTrials,
      Value<int>? errorCount,
      Value<double>? meanLatencyMs,
      Value<double>? medianLatencyMs,
      Value<double>? normScore,
      Value<String>? interpretation,
      Value<String>? specificMetrics,
      Value<DateTime>? completedAt,
      Value<DateTime>? createdAt,
      Value<String>? uuid,
      Value<SyncStatus>? syncStatus,
      Value<DateTime>? lastUpdatedAt}) {
    return CambridgeAssessmentTableCompanion(
      id: id ?? this.id,
      testType: testType ?? this.testType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      accuracy: accuracy ?? this.accuracy,
      totalTrials: totalTrials ?? this.totalTrials,
      correctTrials: correctTrials ?? this.correctTrials,
      errorCount: errorCount ?? this.errorCount,
      meanLatencyMs: meanLatencyMs ?? this.meanLatencyMs,
      medianLatencyMs: medianLatencyMs ?? this.medianLatencyMs,
      normScore: normScore ?? this.normScore,
      interpretation: interpretation ?? this.interpretation,
      specificMetrics: specificMetrics ?? this.specificMetrics,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      uuid: uuid ?? this.uuid,
      syncStatus: syncStatus ?? this.syncStatus,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (testType.present) {
      map['test_type'] = Variable<String>($CambridgeAssessmentTableTable
          .$convertertestType
          .toSql(testType.value));
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (totalTrials.present) {
      map['total_trials'] = Variable<int>(totalTrials.value);
    }
    if (correctTrials.present) {
      map['correct_trials'] = Variable<int>(correctTrials.value);
    }
    if (errorCount.present) {
      map['error_count'] = Variable<int>(errorCount.value);
    }
    if (meanLatencyMs.present) {
      map['mean_latency_ms'] = Variable<double>(meanLatencyMs.value);
    }
    if (medianLatencyMs.present) {
      map['median_latency_ms'] = Variable<double>(medianLatencyMs.value);
    }
    if (normScore.present) {
      map['norm_score'] = Variable<double>(normScore.value);
    }
    if (interpretation.present) {
      map['interpretation'] = Variable<String>(interpretation.value);
    }
    if (specificMetrics.present) {
      map['specific_metrics'] = Variable<String>(specificMetrics.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>($CambridgeAssessmentTableTable
          .$convertersyncStatus
          .toSql(syncStatus.value));
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CambridgeAssessmentTableCompanion(')
          ..write('id: $id, ')
          ..write('testType: $testType, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('accuracy: $accuracy, ')
          ..write('totalTrials: $totalTrials, ')
          ..write('correctTrials: $correctTrials, ')
          ..write('errorCount: $errorCount, ')
          ..write('meanLatencyMs: $meanLatencyMs, ')
          ..write('medianLatencyMs: $medianLatencyMs, ')
          ..write('normScore: $normScore, ')
          ..write('interpretation: $interpretation, ')
          ..write('specificMetrics: $specificMetrics, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('uuid: $uuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $DailyGoalsTableTable extends DailyGoalsTable
    with TableInfo<$DailyGoalsTableTable, DailyGoalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyGoalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _targetGamesMeta =
      const VerificationMeta('targetGames');
  @override
  late final GeneratedColumn<int> targetGames = GeneratedColumn<int>(
      'target_games', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _completedGamesMeta =
      const VerificationMeta('completedGames');
  @override
  late final GeneratedColumn<int> completedGames = GeneratedColumn<int>(
      'completed_games', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>('sync_status', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: Constant(SyncStatus.pendingInsert.index))
          .withConverter<SyncStatus>(
              $DailyGoalsTableTable.$convertersyncStatus);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        targetGames,
        completedGames,
        isCompleted,
        createdAt,
        updatedAt,
        uuid,
        syncStatus,
        lastUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_goals';
  @override
  VerificationContext validateIntegrity(Insertable<DailyGoalEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('target_games')) {
      context.handle(
          _targetGamesMeta,
          targetGames.isAcceptableOrUnknown(
              data['target_games']!, _targetGamesMeta));
    }
    if (data.containsKey('completed_games')) {
      context.handle(
          _completedGamesMeta,
          completedGames.isAcceptableOrUnknown(
              data['completed_games']!, _completedGamesMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyGoalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyGoalEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      targetGames: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_games'])!,
      completedGames: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_games'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      syncStatus: $DailyGoalsTableTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}sync_status'])!),
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
    );
  }

  @override
  $DailyGoalsTableTable createAlias(String alias) {
    return $DailyGoalsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class DailyGoalEntry extends DataClass implements Insertable<DailyGoalEntry> {
  final int id;
  final DateTime date;
  final int targetGames;
  final int completedGames;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String uuid;
  final SyncStatus syncStatus;
  final DateTime lastUpdatedAt;
  const DailyGoalEntry(
      {required this.id,
      required this.date,
      required this.targetGames,
      required this.completedGames,
      required this.isCompleted,
      required this.createdAt,
      required this.updatedAt,
      required this.uuid,
      required this.syncStatus,
      required this.lastUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['target_games'] = Variable<int>(targetGames);
    map['completed_games'] = Variable<int>(completedGames);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['uuid'] = Variable<String>(uuid);
    {
      map['sync_status'] = Variable<int>(
          $DailyGoalsTableTable.$convertersyncStatus.toSql(syncStatus));
    }
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    return map;
  }

  DailyGoalsTableCompanion toCompanion(bool nullToAbsent) {
    return DailyGoalsTableCompanion(
      id: Value(id),
      date: Value(date),
      targetGames: Value(targetGames),
      completedGames: Value(completedGames),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      uuid: Value(uuid),
      syncStatus: Value(syncStatus),
      lastUpdatedAt: Value(lastUpdatedAt),
    );
  }

  factory DailyGoalEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyGoalEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      targetGames: serializer.fromJson<int>(json['targetGames']),
      completedGames: serializer.fromJson<int>(json['completedGames']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      uuid: serializer.fromJson<String>(json['uuid']),
      syncStatus: $DailyGoalsTableTable.$convertersyncStatus
          .fromJson(serializer.fromJson<int>(json['syncStatus'])),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'targetGames': serializer.toJson<int>(targetGames),
      'completedGames': serializer.toJson<int>(completedGames),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'uuid': serializer.toJson<String>(uuid),
      'syncStatus': serializer.toJson<int>(
          $DailyGoalsTableTable.$convertersyncStatus.toJson(syncStatus)),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
    };
  }

  DailyGoalEntry copyWith(
          {int? id,
          DateTime? date,
          int? targetGames,
          int? completedGames,
          bool? isCompleted,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? uuid,
          SyncStatus? syncStatus,
          DateTime? lastUpdatedAt}) =>
      DailyGoalEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        targetGames: targetGames ?? this.targetGames,
        completedGames: completedGames ?? this.completedGames,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        uuid: uuid ?? this.uuid,
        syncStatus: syncStatus ?? this.syncStatus,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
  DailyGoalEntry copyWithCompanion(DailyGoalsTableCompanion data) {
    return DailyGoalEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      targetGames:
          data.targetGames.present ? data.targetGames.value : this.targetGames,
      completedGames: data.completedGames.present
          ? data.completedGames.value
          : this.completedGames,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoalEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('targetGames: $targetGames, ')
          ..write('completedGames: $completedGames, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uuid: $uuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, targetGames, completedGames,
      isCompleted, createdAt, updatedAt, uuid, syncStatus, lastUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyGoalEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.targetGames == this.targetGames &&
          other.completedGames == this.completedGames &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.uuid == this.uuid &&
          other.syncStatus == this.syncStatus &&
          other.lastUpdatedAt == this.lastUpdatedAt);
}

class DailyGoalsTableCompanion extends UpdateCompanion<DailyGoalEntry> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> targetGames;
  final Value<int> completedGames;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> uuid;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastUpdatedAt;
  const DailyGoalsTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.targetGames = const Value.absent(),
    this.completedGames = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  });
  DailyGoalsTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.targetGames = const Value.absent(),
    this.completedGames = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailyGoalEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? targetGames,
    Expression<int>? completedGames,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? uuid,
    Expression<int>? syncStatus,
    Expression<DateTime>? lastUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (targetGames != null) 'target_games': targetGames,
      if (completedGames != null) 'completed_games': completedGames,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (uuid != null) 'uuid': uuid,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
    });
  }

  DailyGoalsTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<int>? targetGames,
      Value<int>? completedGames,
      Value<bool>? isCompleted,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? uuid,
      Value<SyncStatus>? syncStatus,
      Value<DateTime>? lastUpdatedAt}) {
    return DailyGoalsTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      targetGames: targetGames ?? this.targetGames,
      completedGames: completedGames ?? this.completedGames,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uuid: uuid ?? this.uuid,
      syncStatus: syncStatus ?? this.syncStatus,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (targetGames.present) {
      map['target_games'] = Variable<int>(targetGames.value);
    }
    if (completedGames.present) {
      map['completed_games'] = Variable<int>(completedGames.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
          $DailyGoalsTableTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoalsTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('targetGames: $targetGames, ')
          ..write('completedGames: $completedGames, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('uuid: $uuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AssessmentTableTable assessmentTable =
      $AssessmentTableTable(this);
  late final $CognitiveExerciseTableTable cognitiveExerciseTable =
      $CognitiveExerciseTableTable(this);
  late final $WordDictionaryTableTable wordDictionaryTable =
      $WordDictionaryTableTable(this);
  late final $UserProfileTableTable userProfileTable =
      $UserProfileTableTable(this);
  late final $CambridgeAssessmentTableTable cambridgeAssessmentTable =
      $CambridgeAssessmentTableTable(this);
  late final $DailyGoalsTableTable dailyGoalsTable =
      $DailyGoalsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        assessmentTable,
        cognitiveExerciseTable,
        wordDictionaryTable,
        userProfileTable,
        cambridgeAssessmentTable,
        dailyGoalsTable
      ];
}

typedef $$AssessmentTableTableCreateCompanionBuilder = AssessmentTableCompanion
    Function({
  Value<int> id,
  required AssessmentType type,
  required int score,
  required int maxScore,
  Value<String?> notes,
  required DateTime completedAt,
  Value<DateTime> createdAt,
  Value<String> uuid,
  Value<SyncStatus> syncStatus,
  Value<DateTime> lastUpdatedAt,
});
typedef $$AssessmentTableTableUpdateCompanionBuilder = AssessmentTableCompanion
    Function({
  Value<int> id,
  Value<AssessmentType> type,
  Value<int> score,
  Value<int> maxScore,
  Value<String?> notes,
  Value<DateTime> completedAt,
  Value<DateTime> createdAt,
  Value<String> uuid,
  Value<SyncStatus> syncStatus,
  Value<DateTime> lastUpdatedAt,
});

class $$AssessmentTableTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentTableTable> {
  $$AssessmentTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AssessmentType, AssessmentType, String>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxScore => $composableBuilder(
      column: $table.maxScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$AssessmentTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentTableTable> {
  $$AssessmentTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxScore => $composableBuilder(
      column: $table.maxScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$AssessmentTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentTableTable> {
  $$AssessmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AssessmentType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get maxScore =>
      $composableBuilder(column: $table.maxScore, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);
}

class $$AssessmentTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssessmentTableTable,
    AssessmentEntry,
    $$AssessmentTableTableFilterComposer,
    $$AssessmentTableTableOrderingComposer,
    $$AssessmentTableTableAnnotationComposer,
    $$AssessmentTableTableCreateCompanionBuilder,
    $$AssessmentTableTableUpdateCompanionBuilder,
    (
      AssessmentEntry,
      BaseReferences<_$AppDatabase, $AssessmentTableTable, AssessmentEntry>
    ),
    AssessmentEntry,
    PrefetchHooks Function()> {
  $$AssessmentTableTableTableManager(
      _$AppDatabase db, $AssessmentTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssessmentTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssessmentTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssessmentTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<AssessmentType> type = const Value.absent(),
            Value<int> score = const Value.absent(),
            Value<int> maxScore = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
          }) =>
              AssessmentTableCompanion(
            id: id,
            type: type,
            score: score,
            maxScore: maxScore,
            notes: notes,
            completedAt: completedAt,
            createdAt: createdAt,
            uuid: uuid,
            syncStatus: syncStatus,
            lastUpdatedAt: lastUpdatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required AssessmentType type,
            required int score,
            required int maxScore,
            Value<String?> notes = const Value.absent(),
            required DateTime completedAt,
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
          }) =>
              AssessmentTableCompanion.insert(
            id: id,
            type: type,
            score: score,
            maxScore: maxScore,
            notes: notes,
            completedAt: completedAt,
            createdAt: createdAt,
            uuid: uuid,
            syncStatus: syncStatus,
            lastUpdatedAt: lastUpdatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AssessmentTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssessmentTableTable,
    AssessmentEntry,
    $$AssessmentTableTableFilterComposer,
    $$AssessmentTableTableOrderingComposer,
    $$AssessmentTableTableAnnotationComposer,
    $$AssessmentTableTableCreateCompanionBuilder,
    $$AssessmentTableTableUpdateCompanionBuilder,
    (
      AssessmentEntry,
      BaseReferences<_$AppDatabase, $AssessmentTableTable, AssessmentEntry>
    ),
    AssessmentEntry,
    PrefetchHooks Function()>;
typedef $$CognitiveExerciseTableTableCreateCompanionBuilder
    = CognitiveExerciseTableCompanion Function({
  Value<int> id,
  required String name,
  required ExerciseType type,
  required ExerciseDifficulty difficulty,
  Value<int?> score,
  required int maxScore,
  Value<int?> timeSpentSeconds,
  Value<bool> isCompleted,
  Value<String?> exerciseData,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<String> uuid,
  Value<SyncStatus> syncStatus,
  Value<DateTime> lastUpdatedAt,
});
typedef $$CognitiveExerciseTableTableUpdateCompanionBuilder
    = CognitiveExerciseTableCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<ExerciseType> type,
  Value<ExerciseDifficulty> difficulty,
  Value<int?> score,
  Value<int> maxScore,
  Value<int?> timeSpentSeconds,
  Value<bool> isCompleted,
  Value<String?> exerciseData,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<String> uuid,
  Value<SyncStatus> syncStatus,
  Value<DateTime> lastUpdatedAt,
});

class $$CognitiveExerciseTableTableFilterComposer
    extends Composer<_$AppDatabase, $CognitiveExerciseTableTable> {
  $$CognitiveExerciseTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ExerciseType, ExerciseType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ExerciseDifficulty, ExerciseDifficulty, String>
      get difficulty => $composableBuilder(
          column: $table.difficulty,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxScore => $composableBuilder(
      column: $table.maxScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeSpentSeconds => $composableBuilder(
      column: $table.timeSpentSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseData => $composableBuilder(
      column: $table.exerciseData, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$CognitiveExerciseTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CognitiveExerciseTableTable> {
  $$CognitiveExerciseTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxScore => $composableBuilder(
      column: $table.maxScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeSpentSeconds => $composableBuilder(
      column: $table.timeSpentSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseData => $composableBuilder(
      column: $table.exerciseData,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$CognitiveExerciseTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CognitiveExerciseTableTable> {
  $$CognitiveExerciseTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExerciseType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExerciseDifficulty, String> get difficulty =>
      $composableBuilder(
          column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get maxScore =>
      $composableBuilder(column: $table.maxScore, builder: (column) => column);

  GeneratedColumn<int> get timeSpentSeconds => $composableBuilder(
      column: $table.timeSpentSeconds, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<String> get exerciseData => $composableBuilder(
      column: $table.exerciseData, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);
}

class $$CognitiveExerciseTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CognitiveExerciseTableTable,
    CognitiveExerciseEntry,
    $$CognitiveExerciseTableTableFilterComposer,
    $$CognitiveExerciseTableTableOrderingComposer,
    $$CognitiveExerciseTableTableAnnotationComposer,
    $$CognitiveExerciseTableTableCreateCompanionBuilder,
    $$CognitiveExerciseTableTableUpdateCompanionBuilder,
    (
      CognitiveExerciseEntry,
      BaseReferences<_$AppDatabase, $CognitiveExerciseTableTable,
          CognitiveExerciseEntry>
    ),
    CognitiveExerciseEntry,
    PrefetchHooks Function()> {
  $$CognitiveExerciseTableTableTableManager(
      _$AppDatabase db, $CognitiveExerciseTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CognitiveExerciseTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CognitiveExerciseTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CognitiveExerciseTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<ExerciseType> type = const Value.absent(),
            Value<ExerciseDifficulty> difficulty = const Value.absent(),
            Value<int?> score = const Value.absent(),
            Value<int> maxScore = const Value.absent(),
            Value<int?> timeSpentSeconds = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<String?> exerciseData = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
          }) =>
              CognitiveExerciseTableCompanion(
            id: id,
            name: name,
            type: type,
            difficulty: difficulty,
            score: score,
            maxScore: maxScore,
            timeSpentSeconds: timeSpentSeconds,
            isCompleted: isCompleted,
            exerciseData: exerciseData,
            completedAt: completedAt,
            createdAt: createdAt,
            uuid: uuid,
            syncStatus: syncStatus,
            lastUpdatedAt: lastUpdatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required ExerciseType type,
            required ExerciseDifficulty difficulty,
            Value<int?> score = const Value.absent(),
            required int maxScore,
            Value<int?> timeSpentSeconds = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<String?> exerciseData = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
          }) =>
              CognitiveExerciseTableCompanion.insert(
            id: id,
            name: name,
            type: type,
            difficulty: difficulty,
            score: score,
            maxScore: maxScore,
            timeSpentSeconds: timeSpentSeconds,
            isCompleted: isCompleted,
            exerciseData: exerciseData,
            completedAt: completedAt,
            createdAt: createdAt,
            uuid: uuid,
            syncStatus: syncStatus,
            lastUpdatedAt: lastUpdatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CognitiveExerciseTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CognitiveExerciseTableTable,
        CognitiveExerciseEntry,
        $$CognitiveExerciseTableTableFilterComposer,
        $$CognitiveExerciseTableTableOrderingComposer,
        $$CognitiveExerciseTableTableAnnotationComposer,
        $$CognitiveExerciseTableTableCreateCompanionBuilder,
        $$CognitiveExerciseTableTableUpdateCompanionBuilder,
        (
          CognitiveExerciseEntry,
          BaseReferences<_$AppDatabase, $CognitiveExerciseTableTable,
              CognitiveExerciseEntry>
        ),
        CognitiveExerciseEntry,
        PrefetchHooks Function()>;
typedef $$WordDictionaryTableTableCreateCompanionBuilder
    = WordDictionaryTableCompanion Function({
  Value<int> id,
  required String word,
  required WordLanguage language,
  required WordType type,
  required ExerciseDifficulty difficulty,
  required int length,
  Value<int> version,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});
typedef $$WordDictionaryTableTableUpdateCompanionBuilder
    = WordDictionaryTableCompanion Function({
  Value<int> id,
  Value<String> word,
  Value<WordLanguage> language,
  Value<WordType> type,
  Value<ExerciseDifficulty> difficulty,
  Value<int> length,
  Value<int> version,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

class $$WordDictionaryTableTableFilterComposer
    extends Composer<_$AppDatabase, $WordDictionaryTableTable> {
  $$WordDictionaryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<WordLanguage, WordLanguage, String>
      get language => $composableBuilder(
          column: $table.language,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<WordType, WordType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ExerciseDifficulty, ExerciseDifficulty, String>
      get difficulty => $composableBuilder(
          column: $table.difficulty,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get length => $composableBuilder(
      column: $table.length, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$WordDictionaryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WordDictionaryTableTable> {
  $$WordDictionaryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get length => $composableBuilder(
      column: $table.length, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$WordDictionaryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordDictionaryTableTable> {
  $$WordDictionaryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WordLanguage, String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WordType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExerciseDifficulty, String> get difficulty =>
      $composableBuilder(
          column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get length =>
      $composableBuilder(column: $table.length, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WordDictionaryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordDictionaryTableTable,
    WordDictionary,
    $$WordDictionaryTableTableFilterComposer,
    $$WordDictionaryTableTableOrderingComposer,
    $$WordDictionaryTableTableAnnotationComposer,
    $$WordDictionaryTableTableCreateCompanionBuilder,
    $$WordDictionaryTableTableUpdateCompanionBuilder,
    (
      WordDictionary,
      BaseReferences<_$AppDatabase, $WordDictionaryTableTable, WordDictionary>
    ),
    WordDictionary,
    PrefetchHooks Function()> {
  $$WordDictionaryTableTableTableManager(
      _$AppDatabase db, $WordDictionaryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordDictionaryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordDictionaryTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordDictionaryTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<WordLanguage> language = const Value.absent(),
            Value<WordType> type = const Value.absent(),
            Value<ExerciseDifficulty> difficulty = const Value.absent(),
            Value<int> length = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              WordDictionaryTableCompanion(
            id: id,
            word: word,
            language: language,
            type: type,
            difficulty: difficulty,
            length: length,
            version: version,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String word,
            required WordLanguage language,
            required WordType type,
            required ExerciseDifficulty difficulty,
            required int length,
            Value<int> version = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              WordDictionaryTableCompanion.insert(
            id: id,
            word: word,
            language: language,
            type: type,
            difficulty: difficulty,
            length: length,
            version: version,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WordDictionaryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordDictionaryTableTable,
    WordDictionary,
    $$WordDictionaryTableTableFilterComposer,
    $$WordDictionaryTableTableOrderingComposer,
    $$WordDictionaryTableTableAnnotationComposer,
    $$WordDictionaryTableTableCreateCompanionBuilder,
    $$WordDictionaryTableTableUpdateCompanionBuilder,
    (
      WordDictionary,
      BaseReferences<_$AppDatabase, $WordDictionaryTableTable, WordDictionary>
    ),
    WordDictionary,
    PrefetchHooks Function()>;
typedef $$UserProfileTableTableCreateCompanionBuilder
    = UserProfileTableCompanion Function({
  Value<int> id,
  Value<String?> name,
  Value<int?> age,
  Value<DateTime?> dateOfBirth,
  Value<String?> gender,
  Value<DateTime?> programStartDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> uuid,
  Value<SyncStatus> syncStatus,
  Value<DateTime> lastUpdatedAt,
});
typedef $$UserProfileTableTableUpdateCompanionBuilder
    = UserProfileTableCompanion Function({
  Value<int> id,
  Value<String?> name,
  Value<int?> age,
  Value<DateTime?> dateOfBirth,
  Value<String?> gender,
  Value<DateTime?> programStartDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> uuid,
  Value<SyncStatus> syncStatus,
  Value<DateTime> lastUpdatedAt,
});

class $$UserProfileTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get programStartDate => $composableBuilder(
      column: $table.programStartDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserProfileTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get programStartDate => $composableBuilder(
      column: $table.programStartDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$UserProfileTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get programStartDate => $composableBuilder(
      column: $table.programStartDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);
}

class $$UserProfileTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfileTableTable,
    UserProfile,
    $$UserProfileTableTableFilterComposer,
    $$UserProfileTableTableOrderingComposer,
    $$UserProfileTableTableAnnotationComposer,
    $$UserProfileTableTableCreateCompanionBuilder,
    $$UserProfileTableTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfileTableTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()> {
  $$UserProfileTableTableTableManager(
      _$AppDatabase db, $UserProfileTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<DateTime?> programStartDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
          }) =>
              UserProfileTableCompanion(
            id: id,
            name: name,
            age: age,
            dateOfBirth: dateOfBirth,
            gender: gender,
            programStartDate: programStartDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            uuid: uuid,
            syncStatus: syncStatus,
            lastUpdatedAt: lastUpdatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<DateTime?> programStartDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
          }) =>
              UserProfileTableCompanion.insert(
            id: id,
            name: name,
            age: age,
            dateOfBirth: dateOfBirth,
            gender: gender,
            programStartDate: programStartDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            uuid: uuid,
            syncStatus: syncStatus,
            lastUpdatedAt: lastUpdatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfileTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfileTableTable,
    UserProfile,
    $$UserProfileTableTableFilterComposer,
    $$UserProfileTableTableOrderingComposer,
    $$UserProfileTableTableAnnotationComposer,
    $$UserProfileTableTableCreateCompanionBuilder,
    $$UserProfileTableTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfileTableTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()>;
typedef $$CambridgeAssessmentTableTableCreateCompanionBuilder
    = CambridgeAssessmentTableCompanion Function({
  Value<int> id,
  required CambridgeTestType testType,
  required int durationSeconds,
  required double accuracy,
  required int totalTrials,
  required int correctTrials,
  required int errorCount,
  required double meanLatencyMs,
  required double medianLatencyMs,
  required double normScore,
  required String interpretation,
  required String specificMetrics,
  required DateTime completedAt,
  Value<DateTime> createdAt,
  Value<String> uuid,
  Value<SyncStatus> syncStatus,
  Value<DateTime> lastUpdatedAt,
});
typedef $$CambridgeAssessmentTableTableUpdateCompanionBuilder
    = CambridgeAssessmentTableCompanion Function({
  Value<int> id,
  Value<CambridgeTestType> testType,
  Value<int> durationSeconds,
  Value<double> accuracy,
  Value<int> totalTrials,
  Value<int> correctTrials,
  Value<int> errorCount,
  Value<double> meanLatencyMs,
  Value<double> medianLatencyMs,
  Value<double> normScore,
  Value<String> interpretation,
  Value<String> specificMetrics,
  Value<DateTime> completedAt,
  Value<DateTime> createdAt,
  Value<String> uuid,
  Value<SyncStatus> syncStatus,
  Value<DateTime> lastUpdatedAt,
});

class $$CambridgeAssessmentTableTableFilterComposer
    extends Composer<_$AppDatabase, $CambridgeAssessmentTableTable> {
  $$CambridgeAssessmentTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<CambridgeTestType, CambridgeTestType, String>
      get testType => $composableBuilder(
          column: $table.testType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalTrials => $composableBuilder(
      column: $table.totalTrials, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correctTrials => $composableBuilder(
      column: $table.correctTrials, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get errorCount => $composableBuilder(
      column: $table.errorCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get meanLatencyMs => $composableBuilder(
      column: $table.meanLatencyMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get medianLatencyMs => $composableBuilder(
      column: $table.medianLatencyMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get normScore => $composableBuilder(
      column: $table.normScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get interpretation => $composableBuilder(
      column: $table.interpretation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specificMetrics => $composableBuilder(
      column: $table.specificMetrics,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$CambridgeAssessmentTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CambridgeAssessmentTableTable> {
  $$CambridgeAssessmentTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get testType => $composableBuilder(
      column: $table.testType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalTrials => $composableBuilder(
      column: $table.totalTrials, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correctTrials => $composableBuilder(
      column: $table.correctTrials,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get errorCount => $composableBuilder(
      column: $table.errorCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get meanLatencyMs => $composableBuilder(
      column: $table.meanLatencyMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get medianLatencyMs => $composableBuilder(
      column: $table.medianLatencyMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get normScore => $composableBuilder(
      column: $table.normScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get interpretation => $composableBuilder(
      column: $table.interpretation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specificMetrics => $composableBuilder(
      column: $table.specificMetrics,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$CambridgeAssessmentTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CambridgeAssessmentTableTable> {
  $$CambridgeAssessmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CambridgeTestType, String> get testType =>
      $composableBuilder(column: $table.testType, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get totalTrials => $composableBuilder(
      column: $table.totalTrials, builder: (column) => column);

  GeneratedColumn<int> get correctTrials => $composableBuilder(
      column: $table.correctTrials, builder: (column) => column);

  GeneratedColumn<int> get errorCount => $composableBuilder(
      column: $table.errorCount, builder: (column) => column);

  GeneratedColumn<double> get meanLatencyMs => $composableBuilder(
      column: $table.meanLatencyMs, builder: (column) => column);

  GeneratedColumn<double> get medianLatencyMs => $composableBuilder(
      column: $table.medianLatencyMs, builder: (column) => column);

  GeneratedColumn<double> get normScore =>
      $composableBuilder(column: $table.normScore, builder: (column) => column);

  GeneratedColumn<String> get interpretation => $composableBuilder(
      column: $table.interpretation, builder: (column) => column);

  GeneratedColumn<String> get specificMetrics => $composableBuilder(
      column: $table.specificMetrics, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);
}

class $$CambridgeAssessmentTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CambridgeAssessmentTableTable,
    CambridgeAssessmentEntry,
    $$CambridgeAssessmentTableTableFilterComposer,
    $$CambridgeAssessmentTableTableOrderingComposer,
    $$CambridgeAssessmentTableTableAnnotationComposer,
    $$CambridgeAssessmentTableTableCreateCompanionBuilder,
    $$CambridgeAssessmentTableTableUpdateCompanionBuilder,
    (
      CambridgeAssessmentEntry,
      BaseReferences<_$AppDatabase, $CambridgeAssessmentTableTable,
          CambridgeAssessmentEntry>
    ),
    CambridgeAssessmentEntry,
    PrefetchHooks Function()> {
  $$CambridgeAssessmentTableTableTableManager(
      _$AppDatabase db, $CambridgeAssessmentTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CambridgeAssessmentTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CambridgeAssessmentTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CambridgeAssessmentTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<CambridgeTestType> testType = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            Value<int> totalTrials = const Value.absent(),
            Value<int> correctTrials = const Value.absent(),
            Value<int> errorCount = const Value.absent(),
            Value<double> meanLatencyMs = const Value.absent(),
            Value<double> medianLatencyMs = const Value.absent(),
            Value<double> normScore = const Value.absent(),
            Value<String> interpretation = const Value.absent(),
            Value<String> specificMetrics = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
          }) =>
              CambridgeAssessmentTableCompanion(
            id: id,
            testType: testType,
            durationSeconds: durationSeconds,
            accuracy: accuracy,
            totalTrials: totalTrials,
            correctTrials: correctTrials,
            errorCount: errorCount,
            meanLatencyMs: meanLatencyMs,
            medianLatencyMs: medianLatencyMs,
            normScore: normScore,
            interpretation: interpretation,
            specificMetrics: specificMetrics,
            completedAt: completedAt,
            createdAt: createdAt,
            uuid: uuid,
            syncStatus: syncStatus,
            lastUpdatedAt: lastUpdatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required CambridgeTestType testType,
            required int durationSeconds,
            required double accuracy,
            required int totalTrials,
            required int correctTrials,
            required int errorCount,
            required double meanLatencyMs,
            required double medianLatencyMs,
            required double normScore,
            required String interpretation,
            required String specificMetrics,
            required DateTime completedAt,
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
          }) =>
              CambridgeAssessmentTableCompanion.insert(
            id: id,
            testType: testType,
            durationSeconds: durationSeconds,
            accuracy: accuracy,
            totalTrials: totalTrials,
            correctTrials: correctTrials,
            errorCount: errorCount,
            meanLatencyMs: meanLatencyMs,
            medianLatencyMs: medianLatencyMs,
            normScore: normScore,
            interpretation: interpretation,
            specificMetrics: specificMetrics,
            completedAt: completedAt,
            createdAt: createdAt,
            uuid: uuid,
            syncStatus: syncStatus,
            lastUpdatedAt: lastUpdatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CambridgeAssessmentTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CambridgeAssessmentTableTable,
        CambridgeAssessmentEntry,
        $$CambridgeAssessmentTableTableFilterComposer,
        $$CambridgeAssessmentTableTableOrderingComposer,
        $$CambridgeAssessmentTableTableAnnotationComposer,
        $$CambridgeAssessmentTableTableCreateCompanionBuilder,
        $$CambridgeAssessmentTableTableUpdateCompanionBuilder,
        (
          CambridgeAssessmentEntry,
          BaseReferences<_$AppDatabase, $CambridgeAssessmentTableTable,
              CambridgeAssessmentEntry>
        ),
        CambridgeAssessmentEntry,
        PrefetchHooks Function()>;
typedef $$DailyGoalsTableTableCreateCompanionBuilder = DailyGoalsTableCompanion
    Function({
  Value<int> id,
  required DateTime date,
  Value<int> targetGames,
  Value<int> completedGames,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> uuid,
  Value<SyncStatus> syncStatus,
  Value<DateTime> lastUpdatedAt,
});
typedef $$DailyGoalsTableTableUpdateCompanionBuilder = DailyGoalsTableCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<int> targetGames,
  Value<int> completedGames,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> uuid,
  Value<SyncStatus> syncStatus,
  Value<DateTime> lastUpdatedAt,
});

class $$DailyGoalsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DailyGoalsTableTable> {
  $$DailyGoalsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetGames => $composableBuilder(
      column: $table.targetGames, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedGames => $composableBuilder(
      column: $table.completedGames,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$DailyGoalsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyGoalsTableTable> {
  $$DailyGoalsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetGames => $composableBuilder(
      column: $table.targetGames, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedGames => $composableBuilder(
      column: $table.completedGames,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$DailyGoalsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyGoalsTableTable> {
  $$DailyGoalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get targetGames => $composableBuilder(
      column: $table.targetGames, builder: (column) => column);

  GeneratedColumn<int> get completedGames => $composableBuilder(
      column: $table.completedGames, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);
}

class $$DailyGoalsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyGoalsTableTable,
    DailyGoalEntry,
    $$DailyGoalsTableTableFilterComposer,
    $$DailyGoalsTableTableOrderingComposer,
    $$DailyGoalsTableTableAnnotationComposer,
    $$DailyGoalsTableTableCreateCompanionBuilder,
    $$DailyGoalsTableTableUpdateCompanionBuilder,
    (
      DailyGoalEntry,
      BaseReferences<_$AppDatabase, $DailyGoalsTableTable, DailyGoalEntry>
    ),
    DailyGoalEntry,
    PrefetchHooks Function()> {
  $$DailyGoalsTableTableTableManager(
      _$AppDatabase db, $DailyGoalsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyGoalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyGoalsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyGoalsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> targetGames = const Value.absent(),
            Value<int> completedGames = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
          }) =>
              DailyGoalsTableCompanion(
            id: id,
            date: date,
            targetGames: targetGames,
            completedGames: completedGames,
            isCompleted: isCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            uuid: uuid,
            syncStatus: syncStatus,
            lastUpdatedAt: lastUpdatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            Value<int> targetGames = const Value.absent(),
            Value<int> completedGames = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
          }) =>
              DailyGoalsTableCompanion.insert(
            id: id,
            date: date,
            targetGames: targetGames,
            completedGames: completedGames,
            isCompleted: isCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            uuid: uuid,
            syncStatus: syncStatus,
            lastUpdatedAt: lastUpdatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyGoalsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyGoalsTableTable,
    DailyGoalEntry,
    $$DailyGoalsTableTableFilterComposer,
    $$DailyGoalsTableTableOrderingComposer,
    $$DailyGoalsTableTableAnnotationComposer,
    $$DailyGoalsTableTableCreateCompanionBuilder,
    $$DailyGoalsTableTableUpdateCompanionBuilder,
    (
      DailyGoalEntry,
      BaseReferences<_$AppDatabase, $DailyGoalsTableTable, DailyGoalEntry>
    ),
    DailyGoalEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AssessmentTableTableTableManager get assessmentTable =>
      $$AssessmentTableTableTableManager(_db, _db.assessmentTable);
  $$CognitiveExerciseTableTableTableManager get cognitiveExerciseTable =>
      $$CognitiveExerciseTableTableTableManager(
          _db, _db.cognitiveExerciseTable);
  $$WordDictionaryTableTableTableManager get wordDictionaryTable =>
      $$WordDictionaryTableTableTableManager(_db, _db.wordDictionaryTable);
  $$UserProfileTableTableTableManager get userProfileTable =>
      $$UserProfileTableTableTableManager(_db, _db.userProfileTable);
  $$CambridgeAssessmentTableTableTableManager get cambridgeAssessmentTable =>
      $$CambridgeAssessmentTableTableTableManager(
          _db, _db.cambridgeAssessmentTable);
  $$DailyGoalsTableTableTableManager get dailyGoalsTable =>
      $$DailyGoalsTableTableTableManager(_db, _db.dailyGoalsTable);
}
