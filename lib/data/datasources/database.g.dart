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
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, score, maxScore, notes, completedAt, createdAt];
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
    );
  }

  @override
  $AssessmentTableTable createAlias(String alias) {
    return $AssessmentTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AssessmentType, String, String> $convertertype =
      const EnumNameConverter<AssessmentType>(AssessmentType.values);
}

class AssessmentEntry extends DataClass implements Insertable<AssessmentEntry> {
  final int id;
  final AssessmentType type;
  final int score;
  final int maxScore;
  final String? notes;
  final DateTime completedAt;
  final DateTime createdAt;
  const AssessmentEntry(
      {required this.id,
      required this.type,
      required this.score,
      required this.maxScore,
      this.notes,
      required this.completedAt,
      required this.createdAt});
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
    };
  }

  AssessmentEntry copyWith(
          {int? id,
          AssessmentType? type,
          int? score,
          int? maxScore,
          Value<String?> notes = const Value.absent(),
          DateTime? completedAt,
          DateTime? createdAt}) =>
      AssessmentEntry(
        id: id ?? this.id,
        type: type ?? this.type,
        score: score ?? this.score,
        maxScore: maxScore ?? this.maxScore,
        notes: notes.present ? notes.value : this.notes,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, score, maxScore, notes, completedAt, createdAt);
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
          other.createdAt == this.createdAt);
}

class AssessmentTableCompanion extends UpdateCompanion<AssessmentEntry> {
  final Value<int> id;
  final Value<AssessmentType> type;
  final Value<int> score;
  final Value<int> maxScore;
  final Value<String?> notes;
  final Value<DateTime> completedAt;
  final Value<DateTime> createdAt;
  const AssessmentTableCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.score = const Value.absent(),
    this.maxScore = const Value.absent(),
    this.notes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AssessmentTableCompanion.insert({
    this.id = const Value.absent(),
    required AssessmentType type,
    required int score,
    required int maxScore,
    this.notes = const Value.absent(),
    required DateTime completedAt,
    this.createdAt = const Value.absent(),
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (score != null) 'score': score,
      if (maxScore != null) 'max_score': maxScore,
      if (notes != null) 'notes': notes,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AssessmentTableCompanion copyWith(
      {Value<int>? id,
      Value<AssessmentType>? type,
      Value<int>? score,
      Value<int>? maxScore,
      Value<String?>? notes,
      Value<DateTime>? completedAt,
      Value<DateTime>? createdAt}) {
    return AssessmentTableCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ReminderTableTable extends ReminderTable
    with TableInfo<$ReminderTableTable, ReminderEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<ReminderType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ReminderType>($ReminderTableTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<ReminderFrequency, String>
      frequency = GeneratedColumn<String>('frequency', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ReminderFrequency>(
              $ReminderTableTable.$converterfrequency);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _nextScheduledMeta =
      const VerificationMeta('nextScheduled');
  @override
  late final GeneratedColumn<DateTime> nextScheduled =
      GeneratedColumn<DateTime>('next_scheduled', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        type,
        frequency,
        scheduledAt,
        nextScheduled,
        isActive,
        isCompleted,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<ReminderEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('next_scheduled')) {
      context.handle(
          _nextScheduledMeta,
          nextScheduled.isAcceptableOrUnknown(
              data['next_scheduled']!, _nextScheduledMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      type: $ReminderTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      frequency: $ReminderTableTable.$converterfrequency.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!),
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at'])!,
      nextScheduled: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_scheduled']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ReminderTableTable createAlias(String alias) {
    return $ReminderTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderType, String, String> $convertertype =
      const EnumNameConverter<ReminderType>(ReminderType.values);
  static JsonTypeConverter2<ReminderFrequency, String, String>
      $converterfrequency =
      const EnumNameConverter<ReminderFrequency>(ReminderFrequency.values);
}

class ReminderEntry extends DataClass implements Insertable<ReminderEntry> {
  final int id;
  final String title;
  final String? description;
  final ReminderType type;
  final ReminderFrequency frequency;
  final DateTime scheduledAt;
  final DateTime? nextScheduled;
  final bool isActive;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReminderEntry(
      {required this.id,
      required this.title,
      this.description,
      required this.type,
      required this.frequency,
      required this.scheduledAt,
      this.nextScheduled,
      required this.isActive,
      required this.isCompleted,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    {
      map['type'] =
          Variable<String>($ReminderTableTable.$convertertype.toSql(type));
    }
    {
      map['frequency'] = Variable<String>(
          $ReminderTableTable.$converterfrequency.toSql(frequency));
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || nextScheduled != null) {
      map['next_scheduled'] = Variable<DateTime>(nextScheduled);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReminderTableCompanion toCompanion(bool nullToAbsent) {
    return ReminderTableCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
      frequency: Value(frequency),
      scheduledAt: Value(scheduledAt),
      nextScheduled: nextScheduled == null && nullToAbsent
          ? const Value.absent()
          : Value(nextScheduled),
      isActive: Value(isActive),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReminderEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderEntry(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      type: $ReminderTableTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      frequency: $ReminderTableTable.$converterfrequency
          .fromJson(serializer.fromJson<String>(json['frequency'])),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      nextScheduled: serializer.fromJson<DateTime?>(json['nextScheduled']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'type': serializer
          .toJson<String>($ReminderTableTable.$convertertype.toJson(type)),
      'frequency': serializer.toJson<String>(
          $ReminderTableTable.$converterfrequency.toJson(frequency)),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'nextScheduled': serializer.toJson<DateTime?>(nextScheduled),
      'isActive': serializer.toJson<bool>(isActive),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReminderEntry copyWith(
          {int? id,
          String? title,
          Value<String?> description = const Value.absent(),
          ReminderType? type,
          ReminderFrequency? frequency,
          DateTime? scheduledAt,
          Value<DateTime?> nextScheduled = const Value.absent(),
          bool? isActive,
          bool? isCompleted,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ReminderEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        type: type ?? this.type,
        frequency: frequency ?? this.frequency,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        nextScheduled:
            nextScheduled.present ? nextScheduled.value : this.nextScheduled,
        isActive: isActive ?? this.isActive,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ReminderEntry copyWithCompanion(ReminderTableCompanion data) {
    return ReminderEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      type: data.type.present ? data.type.value : this.type,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      nextScheduled: data.nextScheduled.present
          ? data.nextScheduled.value
          : this.nextScheduled,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('frequency: $frequency, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('nextScheduled: $nextScheduled, ')
          ..write('isActive: $isActive, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, type, frequency,
      scheduledAt, nextScheduled, isActive, isCompleted, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.type == this.type &&
          other.frequency == this.frequency &&
          other.scheduledAt == this.scheduledAt &&
          other.nextScheduled == this.nextScheduled &&
          other.isActive == this.isActive &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReminderTableCompanion extends UpdateCompanion<ReminderEntry> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<ReminderType> type;
  final Value<ReminderFrequency> frequency;
  final Value<DateTime> scheduledAt;
  final Value<DateTime?> nextScheduled;
  final Value<bool> isActive;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ReminderTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.frequency = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.nextScheduled = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReminderTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required ReminderType type,
    required ReminderFrequency frequency,
    required DateTime scheduledAt,
    this.nextScheduled = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : title = Value(title),
        type = Value(type),
        frequency = Value(frequency),
        scheduledAt = Value(scheduledAt);
  static Insertable<ReminderEntry> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? frequency,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? nextScheduled,
    Expression<bool>? isActive,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (frequency != null) 'frequency': frequency,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (nextScheduled != null) 'next_scheduled': nextScheduled,
      if (isActive != null) 'is_active': isActive,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReminderTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<ReminderType>? type,
      Value<ReminderFrequency>? frequency,
      Value<DateTime>? scheduledAt,
      Value<DateTime?>? nextScheduled,
      Value<bool>? isActive,
      Value<bool>? isCompleted,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ReminderTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      nextScheduled: nextScheduled ?? this.nextScheduled,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
          $ReminderTableTable.$convertertype.toSql(type.value));
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(
          $ReminderTableTable.$converterfrequency.toSql(frequency.value));
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (nextScheduled.present) {
      map['next_scheduled'] = Variable<DateTime>(nextScheduled.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('frequency: $frequency, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('nextScheduled: $nextScheduled, ')
          ..write('isActive: $isActive, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
        createdAt
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
      required this.createdAt});
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
          DateTime? createdAt}) =>
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, difficulty, score, maxScore,
      timeSpentSeconds, isCompleted, exerciseData, completedAt, createdAt);
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
          other.createdAt == this.createdAt);
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
      Value<DateTime>? createdAt}) {
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MoodEntryTableTable extends MoodEntryTable
    with TableInfo<$MoodEntryTableTable, MoodEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodEntryTableTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumnWithTypeConverter<MoodLevel, String> mood =
      GeneratedColumn<String>('mood', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<MoodLevel>($MoodEntryTableTable.$convertermood);
  static const VerificationMeta _energyLevelMeta =
      const VerificationMeta('energyLevel');
  @override
  late final GeneratedColumn<int> energyLevel = GeneratedColumn<int>(
      'energy_level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stressLevelMeta =
      const VerificationMeta('stressLevel');
  @override
  late final GeneratedColumn<int> stressLevel = GeneratedColumn<int>(
      'stress_level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sleepQualityMeta =
      const VerificationMeta('sleepQuality');
  @override
  late final GeneratedColumn<int> sleepQuality = GeneratedColumn<int>(
      'sleep_quality', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entryDateMeta =
      const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
      'entry_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
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
        mood,
        energyLevel,
        stressLevel,
        sleepQuality,
        notes,
        entryDate,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_entries';
  @override
  VerificationContext validateIntegrity(Insertable<MoodEntryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('energy_level')) {
      context.handle(
          _energyLevelMeta,
          energyLevel.isAcceptableOrUnknown(
              data['energy_level']!, _energyLevelMeta));
    } else if (isInserting) {
      context.missing(_energyLevelMeta);
    }
    if (data.containsKey('stress_level')) {
      context.handle(
          _stressLevelMeta,
          stressLevel.isAcceptableOrUnknown(
              data['stress_level']!, _stressLevelMeta));
    } else if (isInserting) {
      context.missing(_stressLevelMeta);
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
          _sleepQualityMeta,
          sleepQuality.isAcceptableOrUnknown(
              data['sleep_quality']!, _sleepQualityMeta));
    } else if (isInserting) {
      context.missing(_sleepQualityMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta,
          entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    } else if (isInserting) {
      context.missing(_entryDateMeta);
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
  MoodEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodEntryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mood: $MoodEntryTableTable.$convertermood.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood'])!),
      energyLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}energy_level'])!,
      stressLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stress_level'])!,
      sleepQuality: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sleep_quality'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      entryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}entry_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MoodEntryTableTable createAlias(String alias) {
    return $MoodEntryTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MoodLevel, String, String> $convertermood =
      const EnumNameConverter<MoodLevel>(MoodLevel.values);
}

class MoodEntryData extends DataClass implements Insertable<MoodEntryData> {
  final int id;
  final MoodLevel mood;
  final int energyLevel;
  final int stressLevel;
  final int sleepQuality;
  final String? notes;
  final DateTime entryDate;
  final DateTime createdAt;
  const MoodEntryData(
      {required this.id,
      required this.mood,
      required this.energyLevel,
      required this.stressLevel,
      required this.sleepQuality,
      this.notes,
      required this.entryDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['mood'] =
          Variable<String>($MoodEntryTableTable.$convertermood.toSql(mood));
    }
    map['energy_level'] = Variable<int>(energyLevel);
    map['stress_level'] = Variable<int>(stressLevel);
    map['sleep_quality'] = Variable<int>(sleepQuality);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MoodEntryTableCompanion toCompanion(bool nullToAbsent) {
    return MoodEntryTableCompanion(
      id: Value(id),
      mood: Value(mood),
      energyLevel: Value(energyLevel),
      stressLevel: Value(stressLevel),
      sleepQuality: Value(sleepQuality),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      entryDate: Value(entryDate),
      createdAt: Value(createdAt),
    );
  }

  factory MoodEntryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodEntryData(
      id: serializer.fromJson<int>(json['id']),
      mood: $MoodEntryTableTable.$convertermood
          .fromJson(serializer.fromJson<String>(json['mood'])),
      energyLevel: serializer.fromJson<int>(json['energyLevel']),
      stressLevel: serializer.fromJson<int>(json['stressLevel']),
      sleepQuality: serializer.fromJson<int>(json['sleepQuality']),
      notes: serializer.fromJson<String?>(json['notes']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mood': serializer
          .toJson<String>($MoodEntryTableTable.$convertermood.toJson(mood)),
      'energyLevel': serializer.toJson<int>(energyLevel),
      'stressLevel': serializer.toJson<int>(stressLevel),
      'sleepQuality': serializer.toJson<int>(sleepQuality),
      'notes': serializer.toJson<String?>(notes),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MoodEntryData copyWith(
          {int? id,
          MoodLevel? mood,
          int? energyLevel,
          int? stressLevel,
          int? sleepQuality,
          Value<String?> notes = const Value.absent(),
          DateTime? entryDate,
          DateTime? createdAt}) =>
      MoodEntryData(
        id: id ?? this.id,
        mood: mood ?? this.mood,
        energyLevel: energyLevel ?? this.energyLevel,
        stressLevel: stressLevel ?? this.stressLevel,
        sleepQuality: sleepQuality ?? this.sleepQuality,
        notes: notes.present ? notes.value : this.notes,
        entryDate: entryDate ?? this.entryDate,
        createdAt: createdAt ?? this.createdAt,
      );
  MoodEntryData copyWithCompanion(MoodEntryTableCompanion data) {
    return MoodEntryData(
      id: data.id.present ? data.id.value : this.id,
      mood: data.mood.present ? data.mood.value : this.mood,
      energyLevel:
          data.energyLevel.present ? data.energyLevel.value : this.energyLevel,
      stressLevel:
          data.stressLevel.present ? data.stressLevel.value : this.stressLevel,
      sleepQuality: data.sleepQuality.present
          ? data.sleepQuality.value
          : this.sleepQuality,
      notes: data.notes.present ? data.notes.value : this.notes,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodEntryData(')
          ..write('id: $id, ')
          ..write('mood: $mood, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('stressLevel: $stressLevel, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('notes: $notes, ')
          ..write('entryDate: $entryDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mood, energyLevel, stressLevel,
      sleepQuality, notes, entryDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodEntryData &&
          other.id == this.id &&
          other.mood == this.mood &&
          other.energyLevel == this.energyLevel &&
          other.stressLevel == this.stressLevel &&
          other.sleepQuality == this.sleepQuality &&
          other.notes == this.notes &&
          other.entryDate == this.entryDate &&
          other.createdAt == this.createdAt);
}

class MoodEntryTableCompanion extends UpdateCompanion<MoodEntryData> {
  final Value<int> id;
  final Value<MoodLevel> mood;
  final Value<int> energyLevel;
  final Value<int> stressLevel;
  final Value<int> sleepQuality;
  final Value<String?> notes;
  final Value<DateTime> entryDate;
  final Value<DateTime> createdAt;
  const MoodEntryTableCompanion({
    this.id = const Value.absent(),
    this.mood = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.stressLevel = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.notes = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MoodEntryTableCompanion.insert({
    this.id = const Value.absent(),
    required MoodLevel mood,
    required int energyLevel,
    required int stressLevel,
    required int sleepQuality,
    this.notes = const Value.absent(),
    required DateTime entryDate,
    this.createdAt = const Value.absent(),
  })  : mood = Value(mood),
        energyLevel = Value(energyLevel),
        stressLevel = Value(stressLevel),
        sleepQuality = Value(sleepQuality),
        entryDate = Value(entryDate);
  static Insertable<MoodEntryData> custom({
    Expression<int>? id,
    Expression<String>? mood,
    Expression<int>? energyLevel,
    Expression<int>? stressLevel,
    Expression<int>? sleepQuality,
    Expression<String>? notes,
    Expression<DateTime>? entryDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mood != null) 'mood': mood,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (stressLevel != null) 'stress_level': stressLevel,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (notes != null) 'notes': notes,
      if (entryDate != null) 'entry_date': entryDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MoodEntryTableCompanion copyWith(
      {Value<int>? id,
      Value<MoodLevel>? mood,
      Value<int>? energyLevel,
      Value<int>? stressLevel,
      Value<int>? sleepQuality,
      Value<String?>? notes,
      Value<DateTime>? entryDate,
      Value<DateTime>? createdAt}) {
    return MoodEntryTableCompanion(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      notes: notes ?? this.notes,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(
          $MoodEntryTableTable.$convertermood.toSql(mood.value));
    }
    if (energyLevel.present) {
      map['energy_level'] = Variable<int>(energyLevel.value);
    }
    if (stressLevel.present) {
      map['stress_level'] = Variable<int>(stressLevel.value);
    }
    if (sleepQuality.present) {
      map['sleep_quality'] = Variable<int>(sleepQuality.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodEntryTableCompanion(')
          ..write('id: $id, ')
          ..write('mood: $mood, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('stressLevel: $stressLevel, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('notes: $notes, ')
          ..write('entryDate: $entryDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyTrackingTableTable extends DailyTrackingTable
    with TableInfo<$DailyTrackingTableTable, DailyEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyTrackingTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entryDateMeta =
      const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
      'entry_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cycleDayMeta =
      const VerificationMeta('cycleDay');
  @override
  late final GeneratedColumn<int> cycleDay = GeneratedColumn<int>(
      'cycle_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sleepHoursMeta =
      const VerificationMeta('sleepHours');
  @override
  late final GeneratedColumn<double> sleepHours = GeneratedColumn<double>(
      'sleep_hours', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
      'mood', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _cyclingMeta =
      const VerificationMeta('cycling');
  @override
  late final GeneratedColumn<bool> cycling = GeneratedColumn<bool>(
      'cycling', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("cycling" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _resistanceMeta =
      const VerificationMeta('resistance');
  @override
  late final GeneratedColumn<bool> resistance = GeneratedColumn<bool>(
      'resistance', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("resistance" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _meditationMeta =
      const VerificationMeta('meditation');
  @override
  late final GeneratedColumn<bool> meditation = GeneratedColumn<bool>(
      'meditation', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("meditation" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _diveMeta = const VerificationMeta('dive');
  @override
  late final GeneratedColumn<bool> dive = GeneratedColumn<bool>(
      'dive', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dive" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hikeMeta = const VerificationMeta('hike');
  @override
  late final GeneratedColumn<bool> hike = GeneratedColumn<bool>(
      'hike', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("hike" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _socialMeta = const VerificationMeta('social');
  @override
  late final GeneratedColumn<bool> social = GeneratedColumn<bool>(
      'social', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("social" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _yogaMeta = const VerificationMeta('yoga');
  @override
  late final GeneratedColumn<bool> yoga = GeneratedColumn<bool>(
      'yoga', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("yoga" IN (0, 1))'),
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entryDate,
        cycleDay,
        sleepHours,
        weight,
        mood,
        cycling,
        resistance,
        meditation,
        dive,
        hike,
        social,
        yoga,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_tracking';
  @override
  VerificationContext validateIntegrity(Insertable<DailyEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta,
          entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('cycle_day')) {
      context.handle(_cycleDayMeta,
          cycleDay.isAcceptableOrUnknown(data['cycle_day']!, _cycleDayMeta));
    } else if (isInserting) {
      context.missing(_cycleDayMeta);
    }
    if (data.containsKey('sleep_hours')) {
      context.handle(
          _sleepHoursMeta,
          sleepHours.isAcceptableOrUnknown(
              data['sleep_hours']!, _sleepHoursMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('mood')) {
      context.handle(
          _moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    }
    if (data.containsKey('cycling')) {
      context.handle(_cyclingMeta,
          cycling.isAcceptableOrUnknown(data['cycling']!, _cyclingMeta));
    }
    if (data.containsKey('resistance')) {
      context.handle(
          _resistanceMeta,
          resistance.isAcceptableOrUnknown(
              data['resistance']!, _resistanceMeta));
    }
    if (data.containsKey('meditation')) {
      context.handle(
          _meditationMeta,
          meditation.isAcceptableOrUnknown(
              data['meditation']!, _meditationMeta));
    }
    if (data.containsKey('dive')) {
      context.handle(
          _diveMeta, dive.isAcceptableOrUnknown(data['dive']!, _diveMeta));
    }
    if (data.containsKey('hike')) {
      context.handle(
          _hikeMeta, hike.isAcceptableOrUnknown(data['hike']!, _hikeMeta));
    }
    if (data.containsKey('social')) {
      context.handle(_socialMeta,
          social.isAcceptableOrUnknown(data['social']!, _socialMeta));
    }
    if (data.containsKey('yoga')) {
      context.handle(
          _yogaMeta, yoga.isAcceptableOrUnknown(data['yoga']!, _yogaMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}entry_date'])!,
      cycleDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_day'])!,
      sleepHours: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sleep_hours']),
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight']),
      mood: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mood']),
      cycling: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}cycling'])!,
      resistance: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}resistance'])!,
      meditation: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}meditation'])!,
      dive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dive'])!,
      hike: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hike'])!,
      social: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}social'])!,
      yoga: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}yoga'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DailyTrackingTableTable createAlias(String alias) {
    return $DailyTrackingTableTable(attachedDatabase, alias);
  }
}

class DailyEntry extends DataClass implements Insertable<DailyEntry> {
  final int id;
  final DateTime entryDate;
  final int cycleDay;
  final double? sleepHours;
  final double? weight;
  final int? mood;
  final bool cycling;
  final bool resistance;
  final bool meditation;
  final bool dive;
  final bool hike;
  final bool social;
  final bool yoga;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyEntry(
      {required this.id,
      required this.entryDate,
      required this.cycleDay,
      this.sleepHours,
      this.weight,
      this.mood,
      required this.cycling,
      required this.resistance,
      required this.meditation,
      required this.dive,
      required this.hike,
      required this.social,
      required this.yoga,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['cycle_day'] = Variable<int>(cycleDay);
    if (!nullToAbsent || sleepHours != null) {
      map['sleep_hours'] = Variable<double>(sleepHours);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<int>(mood);
    }
    map['cycling'] = Variable<bool>(cycling);
    map['resistance'] = Variable<bool>(resistance);
    map['meditation'] = Variable<bool>(meditation);
    map['dive'] = Variable<bool>(dive);
    map['hike'] = Variable<bool>(hike);
    map['social'] = Variable<bool>(social);
    map['yoga'] = Variable<bool>(yoga);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyTrackingTableCompanion toCompanion(bool nullToAbsent) {
    return DailyTrackingTableCompanion(
      id: Value(id),
      entryDate: Value(entryDate),
      cycleDay: Value(cycleDay),
      sleepHours: sleepHours == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepHours),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      cycling: Value(cycling),
      resistance: Value(resistance),
      meditation: Value(meditation),
      dive: Value(dive),
      hike: Value(hike),
      social: Value(social),
      yoga: Value(yoga),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyEntry(
      id: serializer.fromJson<int>(json['id']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      cycleDay: serializer.fromJson<int>(json['cycleDay']),
      sleepHours: serializer.fromJson<double?>(json['sleepHours']),
      weight: serializer.fromJson<double?>(json['weight']),
      mood: serializer.fromJson<int?>(json['mood']),
      cycling: serializer.fromJson<bool>(json['cycling']),
      resistance: serializer.fromJson<bool>(json['resistance']),
      meditation: serializer.fromJson<bool>(json['meditation']),
      dive: serializer.fromJson<bool>(json['dive']),
      hike: serializer.fromJson<bool>(json['hike']),
      social: serializer.fromJson<bool>(json['social']),
      yoga: serializer.fromJson<bool>(json['yoga']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'cycleDay': serializer.toJson<int>(cycleDay),
      'sleepHours': serializer.toJson<double?>(sleepHours),
      'weight': serializer.toJson<double?>(weight),
      'mood': serializer.toJson<int?>(mood),
      'cycling': serializer.toJson<bool>(cycling),
      'resistance': serializer.toJson<bool>(resistance),
      'meditation': serializer.toJson<bool>(meditation),
      'dive': serializer.toJson<bool>(dive),
      'hike': serializer.toJson<bool>(hike),
      'social': serializer.toJson<bool>(social),
      'yoga': serializer.toJson<bool>(yoga),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyEntry copyWith(
          {int? id,
          DateTime? entryDate,
          int? cycleDay,
          Value<double?> sleepHours = const Value.absent(),
          Value<double?> weight = const Value.absent(),
          Value<int?> mood = const Value.absent(),
          bool? cycling,
          bool? resistance,
          bool? meditation,
          bool? dive,
          bool? hike,
          bool? social,
          bool? yoga,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DailyEntry(
        id: id ?? this.id,
        entryDate: entryDate ?? this.entryDate,
        cycleDay: cycleDay ?? this.cycleDay,
        sleepHours: sleepHours.present ? sleepHours.value : this.sleepHours,
        weight: weight.present ? weight.value : this.weight,
        mood: mood.present ? mood.value : this.mood,
        cycling: cycling ?? this.cycling,
        resistance: resistance ?? this.resistance,
        meditation: meditation ?? this.meditation,
        dive: dive ?? this.dive,
        hike: hike ?? this.hike,
        social: social ?? this.social,
        yoga: yoga ?? this.yoga,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DailyEntry copyWithCompanion(DailyTrackingTableCompanion data) {
    return DailyEntry(
      id: data.id.present ? data.id.value : this.id,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      cycleDay: data.cycleDay.present ? data.cycleDay.value : this.cycleDay,
      sleepHours:
          data.sleepHours.present ? data.sleepHours.value : this.sleepHours,
      weight: data.weight.present ? data.weight.value : this.weight,
      mood: data.mood.present ? data.mood.value : this.mood,
      cycling: data.cycling.present ? data.cycling.value : this.cycling,
      resistance:
          data.resistance.present ? data.resistance.value : this.resistance,
      meditation:
          data.meditation.present ? data.meditation.value : this.meditation,
      dive: data.dive.present ? data.dive.value : this.dive,
      hike: data.hike.present ? data.hike.value : this.hike,
      social: data.social.present ? data.social.value : this.social,
      yoga: data.yoga.present ? data.yoga.value : this.yoga,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyEntry(')
          ..write('id: $id, ')
          ..write('entryDate: $entryDate, ')
          ..write('cycleDay: $cycleDay, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('weight: $weight, ')
          ..write('mood: $mood, ')
          ..write('cycling: $cycling, ')
          ..write('resistance: $resistance, ')
          ..write('meditation: $meditation, ')
          ..write('dive: $dive, ')
          ..write('hike: $hike, ')
          ..write('social: $social, ')
          ..write('yoga: $yoga, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entryDate,
      cycleDay,
      sleepHours,
      weight,
      mood,
      cycling,
      resistance,
      meditation,
      dive,
      hike,
      social,
      yoga,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyEntry &&
          other.id == this.id &&
          other.entryDate == this.entryDate &&
          other.cycleDay == this.cycleDay &&
          other.sleepHours == this.sleepHours &&
          other.weight == this.weight &&
          other.mood == this.mood &&
          other.cycling == this.cycling &&
          other.resistance == this.resistance &&
          other.meditation == this.meditation &&
          other.dive == this.dive &&
          other.hike == this.hike &&
          other.social == this.social &&
          other.yoga == this.yoga &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyTrackingTableCompanion extends UpdateCompanion<DailyEntry> {
  final Value<int> id;
  final Value<DateTime> entryDate;
  final Value<int> cycleDay;
  final Value<double?> sleepHours;
  final Value<double?> weight;
  final Value<int?> mood;
  final Value<bool> cycling;
  final Value<bool> resistance;
  final Value<bool> meditation;
  final Value<bool> dive;
  final Value<bool> hike;
  final Value<bool> social;
  final Value<bool> yoga;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DailyTrackingTableCompanion({
    this.id = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.cycleDay = const Value.absent(),
    this.sleepHours = const Value.absent(),
    this.weight = const Value.absent(),
    this.mood = const Value.absent(),
    this.cycling = const Value.absent(),
    this.resistance = const Value.absent(),
    this.meditation = const Value.absent(),
    this.dive = const Value.absent(),
    this.hike = const Value.absent(),
    this.social = const Value.absent(),
    this.yoga = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyTrackingTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime entryDate,
    required int cycleDay,
    this.sleepHours = const Value.absent(),
    this.weight = const Value.absent(),
    this.mood = const Value.absent(),
    this.cycling = const Value.absent(),
    this.resistance = const Value.absent(),
    this.meditation = const Value.absent(),
    this.dive = const Value.absent(),
    this.hike = const Value.absent(),
    this.social = const Value.absent(),
    this.yoga = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : entryDate = Value(entryDate),
        cycleDay = Value(cycleDay);
  static Insertable<DailyEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? entryDate,
    Expression<int>? cycleDay,
    Expression<double>? sleepHours,
    Expression<double>? weight,
    Expression<int>? mood,
    Expression<bool>? cycling,
    Expression<bool>? resistance,
    Expression<bool>? meditation,
    Expression<bool>? dive,
    Expression<bool>? hike,
    Expression<bool>? social,
    Expression<bool>? yoga,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryDate != null) 'entry_date': entryDate,
      if (cycleDay != null) 'cycle_day': cycleDay,
      if (sleepHours != null) 'sleep_hours': sleepHours,
      if (weight != null) 'weight': weight,
      if (mood != null) 'mood': mood,
      if (cycling != null) 'cycling': cycling,
      if (resistance != null) 'resistance': resistance,
      if (meditation != null) 'meditation': meditation,
      if (dive != null) 'dive': dive,
      if (hike != null) 'hike': hike,
      if (social != null) 'social': social,
      if (yoga != null) 'yoga': yoga,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyTrackingTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? entryDate,
      Value<int>? cycleDay,
      Value<double?>? sleepHours,
      Value<double?>? weight,
      Value<int?>? mood,
      Value<bool>? cycling,
      Value<bool>? resistance,
      Value<bool>? meditation,
      Value<bool>? dive,
      Value<bool>? hike,
      Value<bool>? social,
      Value<bool>? yoga,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return DailyTrackingTableCompanion(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      cycleDay: cycleDay ?? this.cycleDay,
      sleepHours: sleepHours ?? this.sleepHours,
      weight: weight ?? this.weight,
      mood: mood ?? this.mood,
      cycling: cycling ?? this.cycling,
      resistance: resistance ?? this.resistance,
      meditation: meditation ?? this.meditation,
      dive: dive ?? this.dive,
      hike: hike ?? this.hike,
      social: social ?? this.social,
      yoga: yoga ?? this.yoga,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (cycleDay.present) {
      map['cycle_day'] = Variable<int>(cycleDay.value);
    }
    if (sleepHours.present) {
      map['sleep_hours'] = Variable<double>(sleepHours.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (cycling.present) {
      map['cycling'] = Variable<bool>(cycling.value);
    }
    if (resistance.present) {
      map['resistance'] = Variable<bool>(resistance.value);
    }
    if (meditation.present) {
      map['meditation'] = Variable<bool>(meditation.value);
    }
    if (dive.present) {
      map['dive'] = Variable<bool>(dive.value);
    }
    if (hike.present) {
      map['hike'] = Variable<bool>(hike.value);
    }
    if (social.present) {
      map['social'] = Variable<bool>(social.value);
    }
    if (yoga.present) {
      map['yoga'] = Variable<bool>(yoga.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyTrackingTableCompanion(')
          ..write('id: $id, ')
          ..write('entryDate: $entryDate, ')
          ..write('cycleDay: $cycleDay, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('weight: $weight, ')
          ..write('mood: $mood, ')
          ..write('cycling: $cycling, ')
          ..write('resistance: $resistance, ')
          ..write('meditation: $meditation, ')
          ..write('dive: $dive, ')
          ..write('hike: $hike, ')
          ..write('social: $social, ')
          ..write('yoga: $yoga, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SleepTrackingTableTable extends SleepTrackingTable
    with TableInfo<$SleepTrackingTableTable, SleepEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepTrackingTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sleepDateMeta =
      const VerificationMeta('sleepDate');
  @override
  late final GeneratedColumn<DateTime> sleepDate = GeneratedColumn<DateTime>(
      'sleep_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<SleepQuality?, String> quality =
      GeneratedColumn<String>('quality', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<SleepQuality?>(
              $SleepTrackingTableTable.$converterqualityn);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _stressMeta = const VerificationMeta('stress');
  @override
  late final GeneratedColumn<int> stress = GeneratedColumn<int>(
      'stress', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _deepSleepMinutesMeta =
      const VerificationMeta('deepSleepMinutes');
  @override
  late final GeneratedColumn<int> deepSleepMinutes = GeneratedColumn<int>(
      'deep_sleep_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lightSleepMinutesMeta =
      const VerificationMeta('lightSleepMinutes');
  @override
  late final GeneratedColumn<int> lightSleepMinutes = GeneratedColumn<int>(
      'light_sleep_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _remSleepMinutesMeta =
      const VerificationMeta('remSleepMinutes');
  @override
  late final GeneratedColumn<int> remSleepMinutes = GeneratedColumn<int>(
      'rem_sleep_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<RestlessnessLevel?, String>
      restlessness = GeneratedColumn<String>('restlessness', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<RestlessnessLevel?>(
              $SleepTrackingTableTable.$converterrestlessnessn);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sleepDate,
        score,
        quality,
        durationMinutes,
        stress,
        deepSleepMinutes,
        lightSleepMinutes,
        remSleepMinutes,
        restlessness,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_tracking';
  @override
  VerificationContext validateIntegrity(Insertable<SleepEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sleep_date')) {
      context.handle(_sleepDateMeta,
          sleepDate.isAcceptableOrUnknown(data['sleep_date']!, _sleepDateMeta));
    } else if (isInserting) {
      context.missing(_sleepDateMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    }
    if (data.containsKey('stress')) {
      context.handle(_stressMeta,
          stress.isAcceptableOrUnknown(data['stress']!, _stressMeta));
    }
    if (data.containsKey('deep_sleep_minutes')) {
      context.handle(
          _deepSleepMinutesMeta,
          deepSleepMinutes.isAcceptableOrUnknown(
              data['deep_sleep_minutes']!, _deepSleepMinutesMeta));
    }
    if (data.containsKey('light_sleep_minutes')) {
      context.handle(
          _lightSleepMinutesMeta,
          lightSleepMinutes.isAcceptableOrUnknown(
              data['light_sleep_minutes']!, _lightSleepMinutesMeta));
    }
    if (data.containsKey('rem_sleep_minutes')) {
      context.handle(
          _remSleepMinutesMeta,
          remSleepMinutes.isAcceptableOrUnknown(
              data['rem_sleep_minutes']!, _remSleepMinutesMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sleepDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sleep_date'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score']),
      quality: $SleepTrackingTableTable.$converterqualityn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}quality'])),
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes']),
      stress: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stress']),
      deepSleepMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deep_sleep_minutes']),
      lightSleepMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}light_sleep_minutes']),
      remSleepMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rem_sleep_minutes']),
      restlessness: $SleepTrackingTableTable.$converterrestlessnessn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}restlessness'])),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SleepTrackingTableTable createAlias(String alias) {
    return $SleepTrackingTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SleepQuality, String, String> $converterquality =
      const EnumNameConverter<SleepQuality>(SleepQuality.values);
  static JsonTypeConverter2<SleepQuality?, String?, String?>
      $converterqualityn = JsonTypeConverter2.asNullable($converterquality);
  static JsonTypeConverter2<RestlessnessLevel, String, String>
      $converterrestlessness =
      const EnumNameConverter<RestlessnessLevel>(RestlessnessLevel.values);
  static JsonTypeConverter2<RestlessnessLevel?, String?, String?>
      $converterrestlessnessn =
      JsonTypeConverter2.asNullable($converterrestlessness);
}

class SleepEntry extends DataClass implements Insertable<SleepEntry> {
  final int id;
  final DateTime sleepDate;
  final int? score;
  final SleepQuality? quality;
  final int? durationMinutes;
  final int? stress;
  final int? deepSleepMinutes;
  final int? lightSleepMinutes;
  final int? remSleepMinutes;
  final RestlessnessLevel? restlessness;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SleepEntry(
      {required this.id,
      required this.sleepDate,
      this.score,
      this.quality,
      this.durationMinutes,
      this.stress,
      this.deepSleepMinutes,
      this.lightSleepMinutes,
      this.remSleepMinutes,
      this.restlessness,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sleep_date'] = Variable<DateTime>(sleepDate);
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<String>(
          $SleepTrackingTableTable.$converterqualityn.toSql(quality));
    }
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || stress != null) {
      map['stress'] = Variable<int>(stress);
    }
    if (!nullToAbsent || deepSleepMinutes != null) {
      map['deep_sleep_minutes'] = Variable<int>(deepSleepMinutes);
    }
    if (!nullToAbsent || lightSleepMinutes != null) {
      map['light_sleep_minutes'] = Variable<int>(lightSleepMinutes);
    }
    if (!nullToAbsent || remSleepMinutes != null) {
      map['rem_sleep_minutes'] = Variable<int>(remSleepMinutes);
    }
    if (!nullToAbsent || restlessness != null) {
      map['restlessness'] = Variable<String>(
          $SleepTrackingTableTable.$converterrestlessnessn.toSql(restlessness));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SleepTrackingTableCompanion toCompanion(bool nullToAbsent) {
    return SleepTrackingTableCompanion(
      id: Value(id),
      sleepDate: Value(sleepDate),
      score:
          score == null && nullToAbsent ? const Value.absent() : Value(score),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      stress:
          stress == null && nullToAbsent ? const Value.absent() : Value(stress),
      deepSleepMinutes: deepSleepMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(deepSleepMinutes),
      lightSleepMinutes: lightSleepMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(lightSleepMinutes),
      remSleepMinutes: remSleepMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(remSleepMinutes),
      restlessness: restlessness == null && nullToAbsent
          ? const Value.absent()
          : Value(restlessness),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SleepEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepEntry(
      id: serializer.fromJson<int>(json['id']),
      sleepDate: serializer.fromJson<DateTime>(json['sleepDate']),
      score: serializer.fromJson<int?>(json['score']),
      quality: $SleepTrackingTableTable.$converterqualityn
          .fromJson(serializer.fromJson<String?>(json['quality'])),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      stress: serializer.fromJson<int?>(json['stress']),
      deepSleepMinutes: serializer.fromJson<int?>(json['deepSleepMinutes']),
      lightSleepMinutes: serializer.fromJson<int?>(json['lightSleepMinutes']),
      remSleepMinutes: serializer.fromJson<int?>(json['remSleepMinutes']),
      restlessness: $SleepTrackingTableTable.$converterrestlessnessn
          .fromJson(serializer.fromJson<String?>(json['restlessness'])),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sleepDate': serializer.toJson<DateTime>(sleepDate),
      'score': serializer.toJson<int?>(score),
      'quality': serializer.toJson<String?>(
          $SleepTrackingTableTable.$converterqualityn.toJson(quality)),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'stress': serializer.toJson<int?>(stress),
      'deepSleepMinutes': serializer.toJson<int?>(deepSleepMinutes),
      'lightSleepMinutes': serializer.toJson<int?>(lightSleepMinutes),
      'remSleepMinutes': serializer.toJson<int?>(remSleepMinutes),
      'restlessness': serializer.toJson<String?>($SleepTrackingTableTable
          .$converterrestlessnessn
          .toJson(restlessness)),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SleepEntry copyWith(
          {int? id,
          DateTime? sleepDate,
          Value<int?> score = const Value.absent(),
          Value<SleepQuality?> quality = const Value.absent(),
          Value<int?> durationMinutes = const Value.absent(),
          Value<int?> stress = const Value.absent(),
          Value<int?> deepSleepMinutes = const Value.absent(),
          Value<int?> lightSleepMinutes = const Value.absent(),
          Value<int?> remSleepMinutes = const Value.absent(),
          Value<RestlessnessLevel?> restlessness = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SleepEntry(
        id: id ?? this.id,
        sleepDate: sleepDate ?? this.sleepDate,
        score: score.present ? score.value : this.score,
        quality: quality.present ? quality.value : this.quality,
        durationMinutes: durationMinutes.present
            ? durationMinutes.value
            : this.durationMinutes,
        stress: stress.present ? stress.value : this.stress,
        deepSleepMinutes: deepSleepMinutes.present
            ? deepSleepMinutes.value
            : this.deepSleepMinutes,
        lightSleepMinutes: lightSleepMinutes.present
            ? lightSleepMinutes.value
            : this.lightSleepMinutes,
        remSleepMinutes: remSleepMinutes.present
            ? remSleepMinutes.value
            : this.remSleepMinutes,
        restlessness:
            restlessness.present ? restlessness.value : this.restlessness,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SleepEntry copyWithCompanion(SleepTrackingTableCompanion data) {
    return SleepEntry(
      id: data.id.present ? data.id.value : this.id,
      sleepDate: data.sleepDate.present ? data.sleepDate.value : this.sleepDate,
      score: data.score.present ? data.score.value : this.score,
      quality: data.quality.present ? data.quality.value : this.quality,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      stress: data.stress.present ? data.stress.value : this.stress,
      deepSleepMinutes: data.deepSleepMinutes.present
          ? data.deepSleepMinutes.value
          : this.deepSleepMinutes,
      lightSleepMinutes: data.lightSleepMinutes.present
          ? data.lightSleepMinutes.value
          : this.lightSleepMinutes,
      remSleepMinutes: data.remSleepMinutes.present
          ? data.remSleepMinutes.value
          : this.remSleepMinutes,
      restlessness: data.restlessness.present
          ? data.restlessness.value
          : this.restlessness,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepEntry(')
          ..write('id: $id, ')
          ..write('sleepDate: $sleepDate, ')
          ..write('score: $score, ')
          ..write('quality: $quality, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('stress: $stress, ')
          ..write('deepSleepMinutes: $deepSleepMinutes, ')
          ..write('lightSleepMinutes: $lightSleepMinutes, ')
          ..write('remSleepMinutes: $remSleepMinutes, ')
          ..write('restlessness: $restlessness, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sleepDate,
      score,
      quality,
      durationMinutes,
      stress,
      deepSleepMinutes,
      lightSleepMinutes,
      remSleepMinutes,
      restlessness,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepEntry &&
          other.id == this.id &&
          other.sleepDate == this.sleepDate &&
          other.score == this.score &&
          other.quality == this.quality &&
          other.durationMinutes == this.durationMinutes &&
          other.stress == this.stress &&
          other.deepSleepMinutes == this.deepSleepMinutes &&
          other.lightSleepMinutes == this.lightSleepMinutes &&
          other.remSleepMinutes == this.remSleepMinutes &&
          other.restlessness == this.restlessness &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SleepTrackingTableCompanion extends UpdateCompanion<SleepEntry> {
  final Value<int> id;
  final Value<DateTime> sleepDate;
  final Value<int?> score;
  final Value<SleepQuality?> quality;
  final Value<int?> durationMinutes;
  final Value<int?> stress;
  final Value<int?> deepSleepMinutes;
  final Value<int?> lightSleepMinutes;
  final Value<int?> remSleepMinutes;
  final Value<RestlessnessLevel?> restlessness;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SleepTrackingTableCompanion({
    this.id = const Value.absent(),
    this.sleepDate = const Value.absent(),
    this.score = const Value.absent(),
    this.quality = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.stress = const Value.absent(),
    this.deepSleepMinutes = const Value.absent(),
    this.lightSleepMinutes = const Value.absent(),
    this.remSleepMinutes = const Value.absent(),
    this.restlessness = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SleepTrackingTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime sleepDate,
    this.score = const Value.absent(),
    this.quality = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.stress = const Value.absent(),
    this.deepSleepMinutes = const Value.absent(),
    this.lightSleepMinutes = const Value.absent(),
    this.remSleepMinutes = const Value.absent(),
    this.restlessness = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : sleepDate = Value(sleepDate);
  static Insertable<SleepEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? sleepDate,
    Expression<int>? score,
    Expression<String>? quality,
    Expression<int>? durationMinutes,
    Expression<int>? stress,
    Expression<int>? deepSleepMinutes,
    Expression<int>? lightSleepMinutes,
    Expression<int>? remSleepMinutes,
    Expression<String>? restlessness,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sleepDate != null) 'sleep_date': sleepDate,
      if (score != null) 'score': score,
      if (quality != null) 'quality': quality,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (stress != null) 'stress': stress,
      if (deepSleepMinutes != null) 'deep_sleep_minutes': deepSleepMinutes,
      if (lightSleepMinutes != null) 'light_sleep_minutes': lightSleepMinutes,
      if (remSleepMinutes != null) 'rem_sleep_minutes': remSleepMinutes,
      if (restlessness != null) 'restlessness': restlessness,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SleepTrackingTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? sleepDate,
      Value<int?>? score,
      Value<SleepQuality?>? quality,
      Value<int?>? durationMinutes,
      Value<int?>? stress,
      Value<int?>? deepSleepMinutes,
      Value<int?>? lightSleepMinutes,
      Value<int?>? remSleepMinutes,
      Value<RestlessnessLevel?>? restlessness,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SleepTrackingTableCompanion(
      id: id ?? this.id,
      sleepDate: sleepDate ?? this.sleepDate,
      score: score ?? this.score,
      quality: quality ?? this.quality,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      stress: stress ?? this.stress,
      deepSleepMinutes: deepSleepMinutes ?? this.deepSleepMinutes,
      lightSleepMinutes: lightSleepMinutes ?? this.lightSleepMinutes,
      remSleepMinutes: remSleepMinutes ?? this.remSleepMinutes,
      restlessness: restlessness ?? this.restlessness,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sleepDate.present) {
      map['sleep_date'] = Variable<DateTime>(sleepDate.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (quality.present) {
      map['quality'] = Variable<String>(
          $SleepTrackingTableTable.$converterqualityn.toSql(quality.value));
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (stress.present) {
      map['stress'] = Variable<int>(stress.value);
    }
    if (deepSleepMinutes.present) {
      map['deep_sleep_minutes'] = Variable<int>(deepSleepMinutes.value);
    }
    if (lightSleepMinutes.present) {
      map['light_sleep_minutes'] = Variable<int>(lightSleepMinutes.value);
    }
    if (remSleepMinutes.present) {
      map['rem_sleep_minutes'] = Variable<int>(remSleepMinutes.value);
    }
    if (restlessness.present) {
      map['restlessness'] = Variable<String>($SleepTrackingTableTable
          .$converterrestlessnessn
          .toSql(restlessness.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepTrackingTableCompanion(')
          ..write('id: $id, ')
          ..write('sleepDate: $sleepDate, ')
          ..write('score: $score, ')
          ..write('quality: $quality, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('stress: $stress, ')
          ..write('deepSleepMinutes: $deepSleepMinutes, ')
          ..write('lightSleepMinutes: $lightSleepMinutes, ')
          ..write('remSleepMinutes: $remSleepMinutes, ')
          ..write('restlessness: $restlessness, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CyclingTrackingTableTable extends CyclingTrackingTable
    with TableInfo<$CyclingTrackingTableTable, CyclingTrackingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CyclingTrackingTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rideDateMeta =
      const VerificationMeta('rideDate');
  @override
  late final GeneratedColumn<DateTime> rideDate = GeneratedColumn<DateTime>(
      'ride_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _distanceKmMeta =
      const VerificationMeta('distanceKm');
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
      'distance_km', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalTimeSecondsMeta =
      const VerificationMeta('totalTimeSeconds');
  @override
  late final GeneratedColumn<int> totalTimeSeconds = GeneratedColumn<int>(
      'total_time_seconds', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _avgMovingSpeedKmhMeta =
      const VerificationMeta('avgMovingSpeedKmh');
  @override
  late final GeneratedColumn<double> avgMovingSpeedKmh =
      GeneratedColumn<double>('avg_moving_speed_kmh', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _avgHeartRateMeta =
      const VerificationMeta('avgHeartRate');
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
      'avg_heart_rate', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _maxHeartRateMeta =
      const VerificationMeta('maxHeartRate');
  @override
  late final GeneratedColumn<int> maxHeartRate = GeneratedColumn<int>(
      'max_heart_rate', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        rideDate,
        distanceKm,
        totalTimeSeconds,
        avgMovingSpeedKmh,
        avgHeartRate,
        maxHeartRate,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycling_tracking';
  @override
  VerificationContext validateIntegrity(
      Insertable<CyclingTrackingEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ride_date')) {
      context.handle(_rideDateMeta,
          rideDate.isAcceptableOrUnknown(data['ride_date']!, _rideDateMeta));
    } else if (isInserting) {
      context.missing(_rideDateMeta);
    }
    if (data.containsKey('distance_km')) {
      context.handle(
          _distanceKmMeta,
          distanceKm.isAcceptableOrUnknown(
              data['distance_km']!, _distanceKmMeta));
    }
    if (data.containsKey('total_time_seconds')) {
      context.handle(
          _totalTimeSecondsMeta,
          totalTimeSeconds.isAcceptableOrUnknown(
              data['total_time_seconds']!, _totalTimeSecondsMeta));
    }
    if (data.containsKey('avg_moving_speed_kmh')) {
      context.handle(
          _avgMovingSpeedKmhMeta,
          avgMovingSpeedKmh.isAcceptableOrUnknown(
              data['avg_moving_speed_kmh']!, _avgMovingSpeedKmhMeta));
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
          _avgHeartRateMeta,
          avgHeartRate.isAcceptableOrUnknown(
              data['avg_heart_rate']!, _avgHeartRateMeta));
    }
    if (data.containsKey('max_heart_rate')) {
      context.handle(
          _maxHeartRateMeta,
          maxHeartRate.isAcceptableOrUnknown(
              data['max_heart_rate']!, _maxHeartRateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CyclingTrackingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CyclingTrackingEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rideDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ride_date'])!,
      distanceKm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance_km']),
      totalTimeSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_time_seconds']),
      avgMovingSpeedKmh: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}avg_moving_speed_kmh']),
      avgHeartRate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}avg_heart_rate']),
      maxHeartRate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_heart_rate']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CyclingTrackingTableTable createAlias(String alias) {
    return $CyclingTrackingTableTable(attachedDatabase, alias);
  }
}

class CyclingTrackingEntry extends DataClass
    implements Insertable<CyclingTrackingEntry> {
  final int id;
  final DateTime rideDate;
  final double? distanceKm;
  final int? totalTimeSeconds;
  final double? avgMovingSpeedKmh;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CyclingTrackingEntry(
      {required this.id,
      required this.rideDate,
      this.distanceKm,
      this.totalTimeSeconds,
      this.avgMovingSpeedKmh,
      this.avgHeartRate,
      this.maxHeartRate,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ride_date'] = Variable<DateTime>(rideDate);
    if (!nullToAbsent || distanceKm != null) {
      map['distance_km'] = Variable<double>(distanceKm);
    }
    if (!nullToAbsent || totalTimeSeconds != null) {
      map['total_time_seconds'] = Variable<int>(totalTimeSeconds);
    }
    if (!nullToAbsent || avgMovingSpeedKmh != null) {
      map['avg_moving_speed_kmh'] = Variable<double>(avgMovingSpeedKmh);
    }
    if (!nullToAbsent || avgHeartRate != null) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate);
    }
    if (!nullToAbsent || maxHeartRate != null) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CyclingTrackingTableCompanion toCompanion(bool nullToAbsent) {
    return CyclingTrackingTableCompanion(
      id: Value(id),
      rideDate: Value(rideDate),
      distanceKm: distanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceKm),
      totalTimeSeconds: totalTimeSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(totalTimeSeconds),
      avgMovingSpeedKmh: avgMovingSpeedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(avgMovingSpeedKmh),
      avgHeartRate: avgHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHeartRate),
      maxHeartRate: maxHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHeartRate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CyclingTrackingEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CyclingTrackingEntry(
      id: serializer.fromJson<int>(json['id']),
      rideDate: serializer.fromJson<DateTime>(json['rideDate']),
      distanceKm: serializer.fromJson<double?>(json['distanceKm']),
      totalTimeSeconds: serializer.fromJson<int?>(json['totalTimeSeconds']),
      avgMovingSpeedKmh:
          serializer.fromJson<double?>(json['avgMovingSpeedKmh']),
      avgHeartRate: serializer.fromJson<int?>(json['avgHeartRate']),
      maxHeartRate: serializer.fromJson<int?>(json['maxHeartRate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rideDate': serializer.toJson<DateTime>(rideDate),
      'distanceKm': serializer.toJson<double?>(distanceKm),
      'totalTimeSeconds': serializer.toJson<int?>(totalTimeSeconds),
      'avgMovingSpeedKmh': serializer.toJson<double?>(avgMovingSpeedKmh),
      'avgHeartRate': serializer.toJson<int?>(avgHeartRate),
      'maxHeartRate': serializer.toJson<int?>(maxHeartRate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CyclingTrackingEntry copyWith(
          {int? id,
          DateTime? rideDate,
          Value<double?> distanceKm = const Value.absent(),
          Value<int?> totalTimeSeconds = const Value.absent(),
          Value<double?> avgMovingSpeedKmh = const Value.absent(),
          Value<int?> avgHeartRate = const Value.absent(),
          Value<int?> maxHeartRate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CyclingTrackingEntry(
        id: id ?? this.id,
        rideDate: rideDate ?? this.rideDate,
        distanceKm: distanceKm.present ? distanceKm.value : this.distanceKm,
        totalTimeSeconds: totalTimeSeconds.present
            ? totalTimeSeconds.value
            : this.totalTimeSeconds,
        avgMovingSpeedKmh: avgMovingSpeedKmh.present
            ? avgMovingSpeedKmh.value
            : this.avgMovingSpeedKmh,
        avgHeartRate:
            avgHeartRate.present ? avgHeartRate.value : this.avgHeartRate,
        maxHeartRate:
            maxHeartRate.present ? maxHeartRate.value : this.maxHeartRate,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CyclingTrackingEntry copyWithCompanion(CyclingTrackingTableCompanion data) {
    return CyclingTrackingEntry(
      id: data.id.present ? data.id.value : this.id,
      rideDate: data.rideDate.present ? data.rideDate.value : this.rideDate,
      distanceKm:
          data.distanceKm.present ? data.distanceKm.value : this.distanceKm,
      totalTimeSeconds: data.totalTimeSeconds.present
          ? data.totalTimeSeconds.value
          : this.totalTimeSeconds,
      avgMovingSpeedKmh: data.avgMovingSpeedKmh.present
          ? data.avgMovingSpeedKmh.value
          : this.avgMovingSpeedKmh,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      maxHeartRate: data.maxHeartRate.present
          ? data.maxHeartRate.value
          : this.maxHeartRate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CyclingTrackingEntry(')
          ..write('id: $id, ')
          ..write('rideDate: $rideDate, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('totalTimeSeconds: $totalTimeSeconds, ')
          ..write('avgMovingSpeedKmh: $avgMovingSpeedKmh, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      rideDate,
      distanceKm,
      totalTimeSeconds,
      avgMovingSpeedKmh,
      avgHeartRate,
      maxHeartRate,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CyclingTrackingEntry &&
          other.id == this.id &&
          other.rideDate == this.rideDate &&
          other.distanceKm == this.distanceKm &&
          other.totalTimeSeconds == this.totalTimeSeconds &&
          other.avgMovingSpeedKmh == this.avgMovingSpeedKmh &&
          other.avgHeartRate == this.avgHeartRate &&
          other.maxHeartRate == this.maxHeartRate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CyclingTrackingTableCompanion
    extends UpdateCompanion<CyclingTrackingEntry> {
  final Value<int> id;
  final Value<DateTime> rideDate;
  final Value<double?> distanceKm;
  final Value<int?> totalTimeSeconds;
  final Value<double?> avgMovingSpeedKmh;
  final Value<int?> avgHeartRate;
  final Value<int?> maxHeartRate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CyclingTrackingTableCompanion({
    this.id = const Value.absent(),
    this.rideDate = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.totalTimeSeconds = const Value.absent(),
    this.avgMovingSpeedKmh = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CyclingTrackingTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime rideDate,
    this.distanceKm = const Value.absent(),
    this.totalTimeSeconds = const Value.absent(),
    this.avgMovingSpeedKmh = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : rideDate = Value(rideDate);
  static Insertable<CyclingTrackingEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? rideDate,
    Expression<double>? distanceKm,
    Expression<int>? totalTimeSeconds,
    Expression<double>? avgMovingSpeedKmh,
    Expression<int>? avgHeartRate,
    Expression<int>? maxHeartRate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rideDate != null) 'ride_date': rideDate,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (totalTimeSeconds != null) 'total_time_seconds': totalTimeSeconds,
      if (avgMovingSpeedKmh != null) 'avg_moving_speed_kmh': avgMovingSpeedKmh,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (maxHeartRate != null) 'max_heart_rate': maxHeartRate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CyclingTrackingTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? rideDate,
      Value<double?>? distanceKm,
      Value<int?>? totalTimeSeconds,
      Value<double?>? avgMovingSpeedKmh,
      Value<int?>? avgHeartRate,
      Value<int?>? maxHeartRate,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CyclingTrackingTableCompanion(
      id: id ?? this.id,
      rideDate: rideDate ?? this.rideDate,
      distanceKm: distanceKm ?? this.distanceKm,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      avgMovingSpeedKmh: avgMovingSpeedKmh ?? this.avgMovingSpeedKmh,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rideDate.present) {
      map['ride_date'] = Variable<DateTime>(rideDate.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (totalTimeSeconds.present) {
      map['total_time_seconds'] = Variable<int>(totalTimeSeconds.value);
    }
    if (avgMovingSpeedKmh.present) {
      map['avg_moving_speed_kmh'] = Variable<double>(avgMovingSpeedKmh.value);
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate.value);
    }
    if (maxHeartRate.present) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CyclingTrackingTableCompanion(')
          ..write('id: $id, ')
          ..write('rideDate: $rideDate, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('totalTimeSeconds: $totalTimeSeconds, ')
          ..write('avgMovingSpeedKmh: $avgMovingSpeedKmh, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        age,
        dateOfBirth,
        gender,
        programStartDate,
        createdAt,
        updatedAt
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
    );
  }

  @override
  $UserProfileTableTable createAlias(String alias) {
    return $UserProfileTableTable(attachedDatabase, alias);
  }
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
  const UserProfile(
      {required this.id,
      this.name,
      this.age,
      this.dateOfBirth,
      this.gender,
      this.programStartDate,
      required this.createdAt,
      required this.updatedAt});
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
          DateTime? updatedAt}) =>
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
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, age, dateOfBirth, gender,
      programStartDate, createdAt, updatedAt);
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
          other.updatedAt == this.updatedAt);
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
  const UserProfileTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.programStartDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
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
      Value<DateTime>? updatedAt}) {
    return UserProfileTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      programStartDate: programStartDate ?? this.programStartDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
          ..write('updatedAt: $updatedAt')
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
        createdAt
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
    );
  }

  @override
  $CambridgeAssessmentTableTable createAlias(String alias) {
    return $CambridgeAssessmentTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CambridgeTestType, String, String>
      $convertertestType =
      const EnumNameConverter<CambridgeTestType>(CambridgeTestType.values);
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
      required this.createdAt});
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
          DateTime? createdAt}) =>
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
          ..write('createdAt: $createdAt')
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
      createdAt);
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
          other.createdAt == this.createdAt);
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
      Value<DateTime>? createdAt}) {
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MealPlanTableTable extends MealPlanTable
    with TableInfo<$MealPlanTableTable, MealPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealPlanTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dayNumberMeta =
      const VerificationMeta('dayNumber');
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
      'day_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<MealType, String> mealType =
      GeneratedColumn<String>('meal_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<MealType>($MealPlanTableTable.$convertermealType);
  static const VerificationMeta _mealNameMeta =
      const VerificationMeta('mealName');
  @override
  late final GeneratedColumn<String> mealName = GeneratedColumn<String>(
      'meal_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dayNumber,
        mealType,
        mealName,
        description,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_plans';
  @override
  VerificationContext validateIntegrity(Insertable<MealPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_number')) {
      context.handle(_dayNumberMeta,
          dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta));
    } else if (isInserting) {
      context.missing(_dayNumberMeta);
    }
    if (data.containsKey('meal_name')) {
      context.handle(_mealNameMeta,
          mealName.isAcceptableOrUnknown(data['meal_name']!, _mealNameMeta));
    } else if (isInserting) {
      context.missing(_mealNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dayNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_number'])!,
      mealType: $MealPlanTableTable.$convertermealType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_type'])!),
      mealName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MealPlanTableTable createAlias(String alias) {
    return $MealPlanTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MealType, String, String> $convertermealType =
      const EnumNameConverter<MealType>(MealType.values);
}

class MealPlan extends DataClass implements Insertable<MealPlan> {
  final int id;
  final int dayNumber;
  final MealType mealType;
  final String mealName;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MealPlan(
      {required this.id,
      required this.dayNumber,
      required this.mealType,
      required this.mealName,
      this.description,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_number'] = Variable<int>(dayNumber);
    {
      map['meal_type'] = Variable<String>(
          $MealPlanTableTable.$convertermealType.toSql(mealType));
    }
    map['meal_name'] = Variable<String>(mealName);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MealPlanTableCompanion toCompanion(bool nullToAbsent) {
    return MealPlanTableCompanion(
      id: Value(id),
      dayNumber: Value(dayNumber),
      mealType: Value(mealType),
      mealName: Value(mealName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MealPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealPlan(
      id: serializer.fromJson<int>(json['id']),
      dayNumber: serializer.fromJson<int>(json['dayNumber']),
      mealType: $MealPlanTableTable.$convertermealType
          .fromJson(serializer.fromJson<String>(json['mealType'])),
      mealName: serializer.fromJson<String>(json['mealName']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayNumber': serializer.toJson<int>(dayNumber),
      'mealType': serializer.toJson<String>(
          $MealPlanTableTable.$convertermealType.toJson(mealType)),
      'mealName': serializer.toJson<String>(mealName),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MealPlan copyWith(
          {int? id,
          int? dayNumber,
          MealType? mealType,
          String? mealName,
          Value<String?> description = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MealPlan(
        id: id ?? this.id,
        dayNumber: dayNumber ?? this.dayNumber,
        mealType: mealType ?? this.mealType,
        mealName: mealName ?? this.mealName,
        description: description.present ? description.value : this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MealPlan copyWithCompanion(MealPlanTableCompanion data) {
    return MealPlan(
      id: data.id.present ? data.id.value : this.id,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      mealName: data.mealName.present ? data.mealName.value : this.mealName,
      description:
          data.description.present ? data.description.value : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealPlan(')
          ..write('id: $id, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('mealType: $mealType, ')
          ..write('mealName: $mealName, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayNumber, mealType, mealName,
      description, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealPlan &&
          other.id == this.id &&
          other.dayNumber == this.dayNumber &&
          other.mealType == this.mealType &&
          other.mealName == this.mealName &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MealPlanTableCompanion extends UpdateCompanion<MealPlan> {
  final Value<int> id;
  final Value<int> dayNumber;
  final Value<MealType> mealType;
  final Value<String> mealName;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MealPlanTableCompanion({
    this.id = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.mealType = const Value.absent(),
    this.mealName = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MealPlanTableCompanion.insert({
    this.id = const Value.absent(),
    required int dayNumber,
    required MealType mealType,
    required String mealName,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : dayNumber = Value(dayNumber),
        mealType = Value(mealType),
        mealName = Value(mealName);
  static Insertable<MealPlan> custom({
    Expression<int>? id,
    Expression<int>? dayNumber,
    Expression<String>? mealType,
    Expression<String>? mealName,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayNumber != null) 'day_number': dayNumber,
      if (mealType != null) 'meal_type': mealType,
      if (mealName != null) 'meal_name': mealName,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MealPlanTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? dayNumber,
      Value<MealType>? mealType,
      Value<String>? mealName,
      Value<String?>? description,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return MealPlanTableCompanion(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      mealType: mealType ?? this.mealType,
      mealName: mealName ?? this.mealName,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(
          $MealPlanTableTable.$convertermealType.toSql(mealType.value));
    }
    if (mealName.present) {
      map['meal_name'] = Variable<String>(mealName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealPlanTableCompanion(')
          ..write('id: $id, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('mealType: $mealType, ')
          ..write('mealName: $mealName, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FeedingWindowTableTable extends FeedingWindowTable
    with TableInfo<$FeedingWindowTableTable, FeedingWindow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedingWindowTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _startHourMeta =
      const VerificationMeta('startHour');
  @override
  late final GeneratedColumn<int> startHour = GeneratedColumn<int>(
      'start_hour', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startMinuteMeta =
      const VerificationMeta('startMinute');
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
      'start_minute', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endHourMeta =
      const VerificationMeta('endHour');
  @override
  late final GeneratedColumn<int> endHour = GeneratedColumn<int>(
      'end_hour', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endMinuteMeta =
      const VerificationMeta('endMinute');
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
      'end_minute', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        startHour,
        startMinute,
        endHour,
        endMinute,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeding_windows';
  @override
  VerificationContext validateIntegrity(Insertable<FeedingWindow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_hour')) {
      context.handle(_startHourMeta,
          startHour.isAcceptableOrUnknown(data['start_hour']!, _startHourMeta));
    } else if (isInserting) {
      context.missing(_startHourMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
          _startMinuteMeta,
          startMinute.isAcceptableOrUnknown(
              data['start_minute']!, _startMinuteMeta));
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_hour')) {
      context.handle(_endHourMeta,
          endHour.isAcceptableOrUnknown(data['end_hour']!, _endHourMeta));
    } else if (isInserting) {
      context.missing(_endHourMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(_endMinuteMeta,
          endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta));
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedingWindow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedingWindow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      startHour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_hour'])!,
      startMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_minute'])!,
      endHour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_hour'])!,
      endMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_minute'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FeedingWindowTableTable createAlias(String alias) {
    return $FeedingWindowTableTable(attachedDatabase, alias);
  }
}

class FeedingWindow extends DataClass implements Insertable<FeedingWindow> {
  final int id;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FeedingWindow(
      {required this.id,
      required this.startHour,
      required this.startMinute,
      required this.endHour,
      required this.endMinute,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_hour'] = Variable<int>(startHour);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_hour'] = Variable<int>(endHour);
    map['end_minute'] = Variable<int>(endMinute);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FeedingWindowTableCompanion toCompanion(bool nullToAbsent) {
    return FeedingWindowTableCompanion(
      id: Value(id),
      startHour: Value(startHour),
      startMinute: Value(startMinute),
      endHour: Value(endHour),
      endMinute: Value(endMinute),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeedingWindow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedingWindow(
      id: serializer.fromJson<int>(json['id']),
      startHour: serializer.fromJson<int>(json['startHour']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endHour: serializer.fromJson<int>(json['endHour']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startHour': serializer.toJson<int>(startHour),
      'startMinute': serializer.toJson<int>(startMinute),
      'endHour': serializer.toJson<int>(endHour),
      'endMinute': serializer.toJson<int>(endMinute),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FeedingWindow copyWith(
          {int? id,
          int? startHour,
          int? startMinute,
          int? endHour,
          int? endMinute,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FeedingWindow(
        id: id ?? this.id,
        startHour: startHour ?? this.startHour,
        startMinute: startMinute ?? this.startMinute,
        endHour: endHour ?? this.endHour,
        endMinute: endMinute ?? this.endMinute,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FeedingWindow copyWithCompanion(FeedingWindowTableCompanion data) {
    return FeedingWindow(
      id: data.id.present ? data.id.value : this.id,
      startHour: data.startHour.present ? data.startHour.value : this.startHour,
      startMinute:
          data.startMinute.present ? data.startMinute.value : this.startMinute,
      endHour: data.endHour.present ? data.endHour.value : this.endHour,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedingWindow(')
          ..write('id: $id, ')
          ..write('startHour: $startHour, ')
          ..write('startMinute: $startMinute, ')
          ..write('endHour: $endHour, ')
          ..write('endMinute: $endMinute, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startHour, startMinute, endHour,
      endMinute, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedingWindow &&
          other.id == this.id &&
          other.startHour == this.startHour &&
          other.startMinute == this.startMinute &&
          other.endHour == this.endHour &&
          other.endMinute == this.endMinute &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeedingWindowTableCompanion extends UpdateCompanion<FeedingWindow> {
  final Value<int> id;
  final Value<int> startHour;
  final Value<int> startMinute;
  final Value<int> endHour;
  final Value<int> endMinute;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FeedingWindowTableCompanion({
    this.id = const Value.absent(),
    this.startHour = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endHour = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FeedingWindowTableCompanion.insert({
    this.id = const Value.absent(),
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : startHour = Value(startHour),
        startMinute = Value(startMinute),
        endHour = Value(endHour),
        endMinute = Value(endMinute);
  static Insertable<FeedingWindow> custom({
    Expression<int>? id,
    Expression<int>? startHour,
    Expression<int>? startMinute,
    Expression<int>? endHour,
    Expression<int>? endMinute,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startHour != null) 'start_hour': startHour,
      if (startMinute != null) 'start_minute': startMinute,
      if (endHour != null) 'end_hour': endHour,
      if (endMinute != null) 'end_minute': endMinute,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FeedingWindowTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? startHour,
      Value<int>? startMinute,
      Value<int>? endHour,
      Value<int>? endMinute,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return FeedingWindowTableCompanion(
      id: id ?? this.id,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startHour.present) {
      map['start_hour'] = Variable<int>(startHour.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endHour.present) {
      map['end_hour'] = Variable<int>(endHour.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedingWindowTableCompanion(')
          ..write('id: $id, ')
          ..write('startHour: $startHour, ')
          ..write('startMinute: $startMinute, ')
          ..write('endHour: $endHour, ')
          ..write('endMinute: $endMinute, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FastingTableTable extends FastingTable
    with TableInfo<$FastingTableTable, FastingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FastingTableTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumnWithTypeConverter<FastType, String> fastType =
      GeneratedColumn<String>('fast_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<FastType>($FastingTableTable.$converterfastType);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _durationHoursMeta =
      const VerificationMeta('durationHours');
  @override
  late final GeneratedColumn<int> durationHours = GeneratedColumn<int>(
      'duration_hours', aliasedName, true,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        fastType,
        startTime,
        endTime,
        durationHours,
        isCompleted,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fasting_entries';
  @override
  VerificationContext validateIntegrity(Insertable<FastingEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('duration_hours')) {
      context.handle(
          _durationHoursMeta,
          durationHours.isAcceptableOrUnknown(
              data['duration_hours']!, _durationHoursMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
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
  FastingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FastingEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fastType: $FastingTableTable.$converterfastType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fast_type'])!),
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      durationHours: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_hours']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FastingTableTable createAlias(String alias) {
    return $FastingTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FastType, String, String> $converterfastType =
      const EnumNameConverter<FastType>(FastType.values);
}

class FastingEntry extends DataClass implements Insertable<FastingEntry> {
  final int id;
  final FastType fastType;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationHours;
  final bool isCompleted;
  final String? notes;
  final DateTime createdAt;
  const FastingEntry(
      {required this.id,
      required this.fastType,
      required this.startTime,
      this.endTime,
      this.durationHours,
      required this.isCompleted,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['fast_type'] = Variable<String>(
          $FastingTableTable.$converterfastType.toSql(fastType));
    }
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || durationHours != null) {
      map['duration_hours'] = Variable<int>(durationHours);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FastingTableCompanion toCompanion(bool nullToAbsent) {
    return FastingTableCompanion(
      id: Value(id),
      fastType: Value(fastType),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      durationHours: durationHours == null && nullToAbsent
          ? const Value.absent()
          : Value(durationHours),
      isCompleted: Value(isCompleted),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory FastingEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FastingEntry(
      id: serializer.fromJson<int>(json['id']),
      fastType: $FastingTableTable.$converterfastType
          .fromJson(serializer.fromJson<String>(json['fastType'])),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      durationHours: serializer.fromJson<int?>(json['durationHours']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fastType': serializer.toJson<String>(
          $FastingTableTable.$converterfastType.toJson(fastType)),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'durationHours': serializer.toJson<int?>(durationHours),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FastingEntry copyWith(
          {int? id,
          FastType? fastType,
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          Value<int?> durationHours = const Value.absent(),
          bool? isCompleted,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      FastingEntry(
        id: id ?? this.id,
        fastType: fastType ?? this.fastType,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        durationHours:
            durationHours.present ? durationHours.value : this.durationHours,
        isCompleted: isCompleted ?? this.isCompleted,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  FastingEntry copyWithCompanion(FastingTableCompanion data) {
    return FastingEntry(
      id: data.id.present ? data.id.value : this.id,
      fastType: data.fastType.present ? data.fastType.value : this.fastType,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationHours: data.durationHours.present
          ? data.durationHours.value
          : this.durationHours,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FastingEntry(')
          ..write('id: $id, ')
          ..write('fastType: $fastType, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationHours: $durationHours, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fastType, startTime, endTime,
      durationHours, isCompleted, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FastingEntry &&
          other.id == this.id &&
          other.fastType == this.fastType &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationHours == this.durationHours &&
          other.isCompleted == this.isCompleted &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class FastingTableCompanion extends UpdateCompanion<FastingEntry> {
  final Value<int> id;
  final Value<FastType> fastType;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int?> durationHours;
  final Value<bool> isCompleted;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const FastingTableCompanion({
    this.id = const Value.absent(),
    this.fastType = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationHours = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FastingTableCompanion.insert({
    this.id = const Value.absent(),
    required FastType fastType,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.durationHours = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : fastType = Value(fastType),
        startTime = Value(startTime);
  static Insertable<FastingEntry> custom({
    Expression<int>? id,
    Expression<String>? fastType,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationHours,
    Expression<bool>? isCompleted,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fastType != null) 'fast_type': fastType,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationHours != null) 'duration_hours': durationHours,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FastingTableCompanion copyWith(
      {Value<int>? id,
      Value<FastType>? fastType,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<int?>? durationHours,
      Value<bool>? isCompleted,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return FastingTableCompanion(
      id: id ?? this.id,
      fastType: fastType ?? this.fastType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fastType.present) {
      map['fast_type'] = Variable<String>(
          $FastingTableTable.$converterfastType.toSql(fastType.value));
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationHours.present) {
      map['duration_hours'] = Variable<int>(durationHours.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FastingTableCompanion(')
          ..write('id: $id, ')
          ..write('fastType: $fastType, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationHours: $durationHours, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SupplementsTableTable extends SupplementsTable
    with TableInfo<$SupplementsTableTable, Supplement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplementsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
      'dosage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<SupplementTiming, String> timing =
      GeneratedColumn<String>('timing', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<SupplementTiming>(
              $SupplementsTableTable.$convertertiming);
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
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, dosage, timing, isActive, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplements';
  @override
  VerificationContext validateIntegrity(Insertable<Supplement> instance,
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
    if (data.containsKey('dosage')) {
      context.handle(_dosageMeta,
          dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta));
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dosage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage'])!,
      timing: $SupplementsTableTable.$convertertiming.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timing'])!),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SupplementsTableTable createAlias(String alias) {
    return $SupplementsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SupplementTiming, String, String> $convertertiming =
      const EnumNameConverter<SupplementTiming>(SupplementTiming.values);
}

class Supplement extends DataClass implements Insertable<Supplement> {
  final int id;
  final String name;
  final String dosage;
  final SupplementTiming timing;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Supplement(
      {required this.id,
      required this.name,
      required this.dosage,
      required this.timing,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<String>(dosage);
    {
      map['timing'] = Variable<String>(
          $SupplementsTableTable.$convertertiming.toSql(timing));
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SupplementsTableCompanion toCompanion(bool nullToAbsent) {
    return SupplementsTableCompanion(
      id: Value(id),
      name: Value(name),
      dosage: Value(dosage),
      timing: Value(timing),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Supplement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplement(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String>(json['dosage']),
      timing: $SupplementsTableTable.$convertertiming
          .fromJson(serializer.fromJson<String>(json['timing'])),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String>(dosage),
      'timing': serializer.toJson<String>(
          $SupplementsTableTable.$convertertiming.toJson(timing)),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Supplement copyWith(
          {int? id,
          String? name,
          String? dosage,
          SupplementTiming? timing,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Supplement(
        id: id ?? this.id,
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        timing: timing ?? this.timing,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Supplement copyWithCompanion(SupplementsTableCompanion data) {
    return Supplement(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      timing: data.timing.present ? data.timing.value : this.timing,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplement(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('timing: $timing, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, dosage, timing, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplement &&
          other.id == this.id &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.timing == this.timing &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SupplementsTableCompanion extends UpdateCompanion<Supplement> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> dosage;
  final Value<SupplementTiming> timing;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SupplementsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.timing = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SupplementsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String dosage,
    required SupplementTiming timing,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        dosage = Value(dosage),
        timing = Value(timing);
  static Insertable<Supplement> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<String>? timing,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (timing != null) 'timing': timing,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SupplementsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? dosage,
      Value<SupplementTiming>? timing,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SupplementsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timing: timing ?? this.timing,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (timing.present) {
      map['timing'] = Variable<String>(
          $SupplementsTableTable.$convertertiming.toSql(timing.value));
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplementsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('timing: $timing, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SupplementLogsTableTable extends SupplementLogsTable
    with TableInfo<$SupplementLogsTableTable, SupplementLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplementLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _supplementIdMeta =
      const VerificationMeta('supplementId');
  @override
  late final GeneratedColumn<int> supplementId = GeneratedColumn<int>(
      'supplement_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES supplements (id)'));
  static const VerificationMeta _logDateMeta =
      const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
      'log_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _takenMeta = const VerificationMeta('taken');
  @override
  late final GeneratedColumn<bool> taken = GeneratedColumn<bool>(
      'taken', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("taken" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
      'taken_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, supplementId, logDate, taken, takenAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplement_logs';
  @override
  VerificationContext validateIntegrity(Insertable<SupplementLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('supplement_id')) {
      context.handle(
          _supplementIdMeta,
          supplementId.isAcceptableOrUnknown(
              data['supplement_id']!, _supplementIdMeta));
    } else if (isInserting) {
      context.missing(_supplementIdMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta,
          logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('taken')) {
      context.handle(
          _takenMeta, taken.isAcceptableOrUnknown(data['taken']!, _takenMeta));
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
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
  SupplementLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplementLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      supplementId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}supplement_id'])!,
      logDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}log_date'])!,
      taken: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}taken'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SupplementLogsTableTable createAlias(String alias) {
    return $SupplementLogsTableTable(attachedDatabase, alias);
  }
}

class SupplementLog extends DataClass implements Insertable<SupplementLog> {
  final int id;
  final int supplementId;
  final DateTime logDate;
  final bool taken;
  final DateTime? takenAt;
  final DateTime createdAt;
  const SupplementLog(
      {required this.id,
      required this.supplementId,
      required this.logDate,
      required this.taken,
      this.takenAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['supplement_id'] = Variable<int>(supplementId);
    map['log_date'] = Variable<DateTime>(logDate);
    map['taken'] = Variable<bool>(taken);
    if (!nullToAbsent || takenAt != null) {
      map['taken_at'] = Variable<DateTime>(takenAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SupplementLogsTableCompanion toCompanion(bool nullToAbsent) {
    return SupplementLogsTableCompanion(
      id: Value(id),
      supplementId: Value(supplementId),
      logDate: Value(logDate),
      taken: Value(taken),
      takenAt: takenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(takenAt),
      createdAt: Value(createdAt),
    );
  }

  factory SupplementLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplementLog(
      id: serializer.fromJson<int>(json['id']),
      supplementId: serializer.fromJson<int>(json['supplementId']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      taken: serializer.fromJson<bool>(json['taken']),
      takenAt: serializer.fromJson<DateTime?>(json['takenAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'supplementId': serializer.toJson<int>(supplementId),
      'logDate': serializer.toJson<DateTime>(logDate),
      'taken': serializer.toJson<bool>(taken),
      'takenAt': serializer.toJson<DateTime?>(takenAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SupplementLog copyWith(
          {int? id,
          int? supplementId,
          DateTime? logDate,
          bool? taken,
          Value<DateTime?> takenAt = const Value.absent(),
          DateTime? createdAt}) =>
      SupplementLog(
        id: id ?? this.id,
        supplementId: supplementId ?? this.supplementId,
        logDate: logDate ?? this.logDate,
        taken: taken ?? this.taken,
        takenAt: takenAt.present ? takenAt.value : this.takenAt,
        createdAt: createdAt ?? this.createdAt,
      );
  SupplementLog copyWithCompanion(SupplementLogsTableCompanion data) {
    return SupplementLog(
      id: data.id.present ? data.id.value : this.id,
      supplementId: data.supplementId.present
          ? data.supplementId.value
          : this.supplementId,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      taken: data.taken.present ? data.taken.value : this.taken,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplementLog(')
          ..write('id: $id, ')
          ..write('supplementId: $supplementId, ')
          ..write('logDate: $logDate, ')
          ..write('taken: $taken, ')
          ..write('takenAt: $takenAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, supplementId, logDate, taken, takenAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplementLog &&
          other.id == this.id &&
          other.supplementId == this.supplementId &&
          other.logDate == this.logDate &&
          other.taken == this.taken &&
          other.takenAt == this.takenAt &&
          other.createdAt == this.createdAt);
}

class SupplementLogsTableCompanion extends UpdateCompanion<SupplementLog> {
  final Value<int> id;
  final Value<int> supplementId;
  final Value<DateTime> logDate;
  final Value<bool> taken;
  final Value<DateTime?> takenAt;
  final Value<DateTime> createdAt;
  const SupplementLogsTableCompanion({
    this.id = const Value.absent(),
    this.supplementId = const Value.absent(),
    this.logDate = const Value.absent(),
    this.taken = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SupplementLogsTableCompanion.insert({
    this.id = const Value.absent(),
    required int supplementId,
    required DateTime logDate,
    this.taken = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : supplementId = Value(supplementId),
        logDate = Value(logDate);
  static Insertable<SupplementLog> custom({
    Expression<int>? id,
    Expression<int>? supplementId,
    Expression<DateTime>? logDate,
    Expression<bool>? taken,
    Expression<DateTime>? takenAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplementId != null) 'supplement_id': supplementId,
      if (logDate != null) 'log_date': logDate,
      if (taken != null) 'taken': taken,
      if (takenAt != null) 'taken_at': takenAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SupplementLogsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? supplementId,
      Value<DateTime>? logDate,
      Value<bool>? taken,
      Value<DateTime?>? takenAt,
      Value<DateTime>? createdAt}) {
    return SupplementLogsTableCompanion(
      id: id ?? this.id,
      supplementId: supplementId ?? this.supplementId,
      logDate: logDate ?? this.logDate,
      taken: taken ?? this.taken,
      takenAt: takenAt ?? this.takenAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (supplementId.present) {
      map['supplement_id'] = Variable<int>(supplementId.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (taken.present) {
      map['taken'] = Variable<bool>(taken.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplementLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('supplementId: $supplementId, ')
          ..write('logDate: $logDate, ')
          ..write('taken: $taken, ')
          ..write('takenAt: $takenAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlanningTableTable extends PlanningTable
    with TableInfo<$PlanningTableTable, PlanEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanningTableTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumnWithTypeConverter<PlanType, String> planType =
      GeneratedColumn<String>('plan_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PlanType>($PlanningTableTable.$converterplanType);
  static const VerificationMeta _planDateMeta =
      const VerificationMeta('planDate');
  @override
  late final GeneratedColumn<DateTime> planDate = GeneratedColumn<DateTime>(
      'plan_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        planType,
        planDate,
        title,
        description,
        isCompleted,
        priority,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planning';
  @override
  VerificationContext validateIntegrity(Insertable<PlanEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_date')) {
      context.handle(_planDateMeta,
          planDate.isAcceptableOrUnknown(data['plan_date']!, _planDateMeta));
    } else if (isInserting) {
      context.missing(_planDateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      planType: $PlanningTableTable.$converterplanType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_type'])!),
      planDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}plan_date'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PlanningTableTable createAlias(String alias) {
    return $PlanningTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlanType, String, String> $converterplanType =
      const EnumNameConverter<PlanType>(PlanType.values);
}

class PlanEntry extends DataClass implements Insertable<PlanEntry> {
  final int id;
  final PlanType planType;
  final DateTime planDate;
  final String title;
  final String? description;
  final bool isCompleted;
  final int? priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlanEntry(
      {required this.id,
      required this.planType,
      required this.planDate,
      required this.title,
      this.description,
      required this.isCompleted,
      this.priority,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['plan_type'] = Variable<String>(
          $PlanningTableTable.$converterplanType.toSql(planType));
    }
    map['plan_date'] = Variable<DateTime>(planDate);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(priority);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlanningTableCompanion toCompanion(bool nullToAbsent) {
    return PlanningTableCompanion(
      id: Value(id),
      planType: Value(planType),
      planDate: Value(planDate),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isCompleted: Value(isCompleted),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlanEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanEntry(
      id: serializer.fromJson<int>(json['id']),
      planType: $PlanningTableTable.$converterplanType
          .fromJson(serializer.fromJson<String>(json['planType'])),
      planDate: serializer.fromJson<DateTime>(json['planDate']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      priority: serializer.fromJson<int?>(json['priority']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planType': serializer.toJson<String>(
          $PlanningTableTable.$converterplanType.toJson(planType)),
      'planDate': serializer.toJson<DateTime>(planDate),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'priority': serializer.toJson<int?>(priority),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlanEntry copyWith(
          {int? id,
          PlanType? planType,
          DateTime? planDate,
          String? title,
          Value<String?> description = const Value.absent(),
          bool? isCompleted,
          Value<int?> priority = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PlanEntry(
        id: id ?? this.id,
        planType: planType ?? this.planType,
        planDate: planDate ?? this.planDate,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        priority: priority.present ? priority.value : this.priority,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PlanEntry copyWithCompanion(PlanningTableCompanion data) {
    return PlanEntry(
      id: data.id.present ? data.id.value : this.id,
      planType: data.planType.present ? data.planType.value : this.planType,
      planDate: data.planDate.present ? data.planDate.value : this.planDate,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      priority: data.priority.present ? data.priority.value : this.priority,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanEntry(')
          ..write('id: $id, ')
          ..write('planType: $planType, ')
          ..write('planDate: $planDate, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planType, planDate, title, description,
      isCompleted, priority, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanEntry &&
          other.id == this.id &&
          other.planType == this.planType &&
          other.planDate == this.planDate &&
          other.title == this.title &&
          other.description == this.description &&
          other.isCompleted == this.isCompleted &&
          other.priority == this.priority &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlanningTableCompanion extends UpdateCompanion<PlanEntry> {
  final Value<int> id;
  final Value<PlanType> planType;
  final Value<DateTime> planDate;
  final Value<String> title;
  final Value<String?> description;
  final Value<bool> isCompleted;
  final Value<int?> priority;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PlanningTableCompanion({
    this.id = const Value.absent(),
    this.planType = const Value.absent(),
    this.planDate = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlanningTableCompanion.insert({
    this.id = const Value.absent(),
    required PlanType planType,
    required DateTime planDate,
    required String title,
    this.description = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : planType = Value(planType),
        planDate = Value(planDate),
        title = Value(title);
  static Insertable<PlanEntry> custom({
    Expression<int>? id,
    Expression<String>? planType,
    Expression<DateTime>? planDate,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isCompleted,
    Expression<int>? priority,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planType != null) 'plan_type': planType,
      if (planDate != null) 'plan_date': planDate,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (priority != null) 'priority': priority,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlanningTableCompanion copyWith(
      {Value<int>? id,
      Value<PlanType>? planType,
      Value<DateTime>? planDate,
      Value<String>? title,
      Value<String?>? description,
      Value<bool>? isCompleted,
      Value<int?>? priority,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PlanningTableCompanion(
      id: id ?? this.id,
      planType: planType ?? this.planType,
      planDate: planDate ?? this.planDate,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planType.present) {
      map['plan_type'] = Variable<String>(
          $PlanningTableTable.$converterplanType.toSql(planType.value));
    }
    if (planDate.present) {
      map['plan_date'] = Variable<DateTime>(planDate.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanningTableCompanion(')
          ..write('id: $id, ')
          ..write('planType: $planType, ')
          ..write('planDate: $planDate, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $JournalTableTable extends JournalTable
    with TableInfo<$JournalTableTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalTableTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumnWithTypeConverter<JournalType, String> journalType =
      GeneratedColumn<String>('journal_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<JournalType>($JournalTableTable.$converterjournalType);
  static const VerificationMeta _entryDateMeta =
      const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
      'entry_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _reflectionsMeta =
      const VerificationMeta('reflections');
  @override
  late final GeneratedColumn<String> reflections = GeneratedColumn<String>(
      'reflections', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gratitudeMeta =
      const VerificationMeta('gratitude');
  @override
  late final GeneratedColumn<String> gratitude = GeneratedColumn<String>(
      'gratitude', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _winsMeta = const VerificationMeta('wins');
  @override
  late final GeneratedColumn<String> wins = GeneratedColumn<String>(
      'wins', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lessonsMeta =
      const VerificationMeta('lessons');
  @override
  late final GeneratedColumn<String> lessons = GeneratedColumn<String>(
      'lessons', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextWeekPlanMeta =
      const VerificationMeta('nextWeekPlan');
  @override
  late final GeneratedColumn<String> nextWeekPlan = GeneratedColumn<String>(
      'next_week_plan', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        journalType,
        entryDate,
        reflections,
        gratitude,
        notes,
        wins,
        lessons,
        nextWeekPlan,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal';
  @override
  VerificationContext validateIntegrity(Insertable<JournalEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta,
          entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('reflections')) {
      context.handle(
          _reflectionsMeta,
          reflections.isAcceptableOrUnknown(
              data['reflections']!, _reflectionsMeta));
    }
    if (data.containsKey('gratitude')) {
      context.handle(_gratitudeMeta,
          gratitude.isAcceptableOrUnknown(data['gratitude']!, _gratitudeMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('wins')) {
      context.handle(
          _winsMeta, wins.isAcceptableOrUnknown(data['wins']!, _winsMeta));
    }
    if (data.containsKey('lessons')) {
      context.handle(_lessonsMeta,
          lessons.isAcceptableOrUnknown(data['lessons']!, _lessonsMeta));
    }
    if (data.containsKey('next_week_plan')) {
      context.handle(
          _nextWeekPlanMeta,
          nextWeekPlan.isAcceptableOrUnknown(
              data['next_week_plan']!, _nextWeekPlanMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      journalType: $JournalTableTable.$converterjournalType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}journal_type'])!),
      entryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}entry_date'])!,
      reflections: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reflections']),
      gratitude: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gratitude']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      wins: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wins']),
      lessons: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lessons']),
      nextWeekPlan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}next_week_plan']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $JournalTableTable createAlias(String alias) {
    return $JournalTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<JournalType, String, String> $converterjournalType =
      const EnumNameConverter<JournalType>(JournalType.values);
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final int id;
  final JournalType journalType;
  final DateTime entryDate;
  final String? reflections;
  final String? gratitude;
  final String? notes;
  final String? wins;
  final String? lessons;
  final String? nextWeekPlan;
  final DateTime createdAt;
  final DateTime updatedAt;
  const JournalEntry(
      {required this.id,
      required this.journalType,
      required this.entryDate,
      this.reflections,
      this.gratitude,
      this.notes,
      this.wins,
      this.lessons,
      this.nextWeekPlan,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['journal_type'] = Variable<String>(
          $JournalTableTable.$converterjournalType.toSql(journalType));
    }
    map['entry_date'] = Variable<DateTime>(entryDate);
    if (!nullToAbsent || reflections != null) {
      map['reflections'] = Variable<String>(reflections);
    }
    if (!nullToAbsent || gratitude != null) {
      map['gratitude'] = Variable<String>(gratitude);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || wins != null) {
      map['wins'] = Variable<String>(wins);
    }
    if (!nullToAbsent || lessons != null) {
      map['lessons'] = Variable<String>(lessons);
    }
    if (!nullToAbsent || nextWeekPlan != null) {
      map['next_week_plan'] = Variable<String>(nextWeekPlan);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JournalTableCompanion toCompanion(bool nullToAbsent) {
    return JournalTableCompanion(
      id: Value(id),
      journalType: Value(journalType),
      entryDate: Value(entryDate),
      reflections: reflections == null && nullToAbsent
          ? const Value.absent()
          : Value(reflections),
      gratitude: gratitude == null && nullToAbsent
          ? const Value.absent()
          : Value(gratitude),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      wins: wins == null && nullToAbsent ? const Value.absent() : Value(wins),
      lessons: lessons == null && nullToAbsent
          ? const Value.absent()
          : Value(lessons),
      nextWeekPlan: nextWeekPlan == null && nullToAbsent
          ? const Value.absent()
          : Value(nextWeekPlan),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<int>(json['id']),
      journalType: $JournalTableTable.$converterjournalType
          .fromJson(serializer.fromJson<String>(json['journalType'])),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      reflections: serializer.fromJson<String?>(json['reflections']),
      gratitude: serializer.fromJson<String?>(json['gratitude']),
      notes: serializer.fromJson<String?>(json['notes']),
      wins: serializer.fromJson<String?>(json['wins']),
      lessons: serializer.fromJson<String?>(json['lessons']),
      nextWeekPlan: serializer.fromJson<String?>(json['nextWeekPlan']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'journalType': serializer.toJson<String>(
          $JournalTableTable.$converterjournalType.toJson(journalType)),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'reflections': serializer.toJson<String?>(reflections),
      'gratitude': serializer.toJson<String?>(gratitude),
      'notes': serializer.toJson<String?>(notes),
      'wins': serializer.toJson<String?>(wins),
      'lessons': serializer.toJson<String?>(lessons),
      'nextWeekPlan': serializer.toJson<String?>(nextWeekPlan),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JournalEntry copyWith(
          {int? id,
          JournalType? journalType,
          DateTime? entryDate,
          Value<String?> reflections = const Value.absent(),
          Value<String?> gratitude = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> wins = const Value.absent(),
          Value<String?> lessons = const Value.absent(),
          Value<String?> nextWeekPlan = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      JournalEntry(
        id: id ?? this.id,
        journalType: journalType ?? this.journalType,
        entryDate: entryDate ?? this.entryDate,
        reflections: reflections.present ? reflections.value : this.reflections,
        gratitude: gratitude.present ? gratitude.value : this.gratitude,
        notes: notes.present ? notes.value : this.notes,
        wins: wins.present ? wins.value : this.wins,
        lessons: lessons.present ? lessons.value : this.lessons,
        nextWeekPlan:
            nextWeekPlan.present ? nextWeekPlan.value : this.nextWeekPlan,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  JournalEntry copyWithCompanion(JournalTableCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      journalType:
          data.journalType.present ? data.journalType.value : this.journalType,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      reflections:
          data.reflections.present ? data.reflections.value : this.reflections,
      gratitude: data.gratitude.present ? data.gratitude.value : this.gratitude,
      notes: data.notes.present ? data.notes.value : this.notes,
      wins: data.wins.present ? data.wins.value : this.wins,
      lessons: data.lessons.present ? data.lessons.value : this.lessons,
      nextWeekPlan: data.nextWeekPlan.present
          ? data.nextWeekPlan.value
          : this.nextWeekPlan,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('journalType: $journalType, ')
          ..write('entryDate: $entryDate, ')
          ..write('reflections: $reflections, ')
          ..write('gratitude: $gratitude, ')
          ..write('notes: $notes, ')
          ..write('wins: $wins, ')
          ..write('lessons: $lessons, ')
          ..write('nextWeekPlan: $nextWeekPlan, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, journalType, entryDate, reflections,
      gratitude, notes, wins, lessons, nextWeekPlan, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.journalType == this.journalType &&
          other.entryDate == this.entryDate &&
          other.reflections == this.reflections &&
          other.gratitude == this.gratitude &&
          other.notes == this.notes &&
          other.wins == this.wins &&
          other.lessons == this.lessons &&
          other.nextWeekPlan == this.nextWeekPlan &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JournalTableCompanion extends UpdateCompanion<JournalEntry> {
  final Value<int> id;
  final Value<JournalType> journalType;
  final Value<DateTime> entryDate;
  final Value<String?> reflections;
  final Value<String?> gratitude;
  final Value<String?> notes;
  final Value<String?> wins;
  final Value<String?> lessons;
  final Value<String?> nextWeekPlan;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const JournalTableCompanion({
    this.id = const Value.absent(),
    this.journalType = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.reflections = const Value.absent(),
    this.gratitude = const Value.absent(),
    this.notes = const Value.absent(),
    this.wins = const Value.absent(),
    this.lessons = const Value.absent(),
    this.nextWeekPlan = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JournalTableCompanion.insert({
    this.id = const Value.absent(),
    required JournalType journalType,
    required DateTime entryDate,
    this.reflections = const Value.absent(),
    this.gratitude = const Value.absent(),
    this.notes = const Value.absent(),
    this.wins = const Value.absent(),
    this.lessons = const Value.absent(),
    this.nextWeekPlan = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : journalType = Value(journalType),
        entryDate = Value(entryDate);
  static Insertable<JournalEntry> custom({
    Expression<int>? id,
    Expression<String>? journalType,
    Expression<DateTime>? entryDate,
    Expression<String>? reflections,
    Expression<String>? gratitude,
    Expression<String>? notes,
    Expression<String>? wins,
    Expression<String>? lessons,
    Expression<String>? nextWeekPlan,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (journalType != null) 'journal_type': journalType,
      if (entryDate != null) 'entry_date': entryDate,
      if (reflections != null) 'reflections': reflections,
      if (gratitude != null) 'gratitude': gratitude,
      if (notes != null) 'notes': notes,
      if (wins != null) 'wins': wins,
      if (lessons != null) 'lessons': lessons,
      if (nextWeekPlan != null) 'next_week_plan': nextWeekPlan,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JournalTableCompanion copyWith(
      {Value<int>? id,
      Value<JournalType>? journalType,
      Value<DateTime>? entryDate,
      Value<String?>? reflections,
      Value<String?>? gratitude,
      Value<String?>? notes,
      Value<String?>? wins,
      Value<String?>? lessons,
      Value<String?>? nextWeekPlan,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return JournalTableCompanion(
      id: id ?? this.id,
      journalType: journalType ?? this.journalType,
      entryDate: entryDate ?? this.entryDate,
      reflections: reflections ?? this.reflections,
      gratitude: gratitude ?? this.gratitude,
      notes: notes ?? this.notes,
      wins: wins ?? this.wins,
      lessons: lessons ?? this.lessons,
      nextWeekPlan: nextWeekPlan ?? this.nextWeekPlan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (journalType.present) {
      map['journal_type'] = Variable<String>(
          $JournalTableTable.$converterjournalType.toSql(journalType.value));
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (reflections.present) {
      map['reflections'] = Variable<String>(reflections.value);
    }
    if (gratitude.present) {
      map['gratitude'] = Variable<String>(gratitude.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (wins.present) {
      map['wins'] = Variable<String>(wins.value);
    }
    if (lessons.present) {
      map['lessons'] = Variable<String>(lessons.value);
    }
    if (nextWeekPlan.present) {
      map['next_week_plan'] = Variable<String>(nextWeekPlan.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalTableCompanion(')
          ..write('id: $id, ')
          ..write('journalType: $journalType, ')
          ..write('entryDate: $entryDate, ')
          ..write('reflections: $reflections, ')
          ..write('gratitude: $gratitude, ')
          ..write('notes: $notes, ')
          ..write('wins: $wins, ')
          ..write('lessons: $lessons, ')
          ..write('nextWeekPlan: $nextWeekPlan, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AssessmentTableTable assessmentTable =
      $AssessmentTableTable(this);
  late final $ReminderTableTable reminderTable = $ReminderTableTable(this);
  late final $CognitiveExerciseTableTable cognitiveExerciseTable =
      $CognitiveExerciseTableTable(this);
  late final $MoodEntryTableTable moodEntryTable = $MoodEntryTableTable(this);
  late final $DailyTrackingTableTable dailyTrackingTable =
      $DailyTrackingTableTable(this);
  late final $SleepTrackingTableTable sleepTrackingTable =
      $SleepTrackingTableTable(this);
  late final $CyclingTrackingTableTable cyclingTrackingTable =
      $CyclingTrackingTableTable(this);
  late final $WordDictionaryTableTable wordDictionaryTable =
      $WordDictionaryTableTable(this);
  late final $UserProfileTableTable userProfileTable =
      $UserProfileTableTable(this);
  late final $CambridgeAssessmentTableTable cambridgeAssessmentTable =
      $CambridgeAssessmentTableTable(this);
  late final $MealPlanTableTable mealPlanTable = $MealPlanTableTable(this);
  late final $FeedingWindowTableTable feedingWindowTable =
      $FeedingWindowTableTable(this);
  late final $FastingTableTable fastingTable = $FastingTableTable(this);
  late final $SupplementsTableTable supplementsTable =
      $SupplementsTableTable(this);
  late final $SupplementLogsTableTable supplementLogsTable =
      $SupplementLogsTableTable(this);
  late final $PlanningTableTable planningTable = $PlanningTableTable(this);
  late final $JournalTableTable journalTable = $JournalTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        assessmentTable,
        reminderTable,
        cognitiveExerciseTable,
        moodEntryTable,
        dailyTrackingTable,
        sleepTrackingTable,
        cyclingTrackingTable,
        wordDictionaryTable,
        userProfileTable,
        cambridgeAssessmentTable,
        mealPlanTable,
        feedingWindowTable,
        fastingTable,
        supplementsTable,
        supplementLogsTable,
        planningTable,
        journalTable
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
          }) =>
              AssessmentTableCompanion(
            id: id,
            type: type,
            score: score,
            maxScore: maxScore,
            notes: notes,
            completedAt: completedAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required AssessmentType type,
            required int score,
            required int maxScore,
            Value<String?> notes = const Value.absent(),
            required DateTime completedAt,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              AssessmentTableCompanion.insert(
            id: id,
            type: type,
            score: score,
            maxScore: maxScore,
            notes: notes,
            completedAt: completedAt,
            createdAt: createdAt,
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
typedef $$ReminderTableTableCreateCompanionBuilder = ReminderTableCompanion
    Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  required ReminderType type,
  required ReminderFrequency frequency,
  required DateTime scheduledAt,
  Value<DateTime?> nextScheduled,
  Value<bool> isActive,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$ReminderTableTableUpdateCompanionBuilder = ReminderTableCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<ReminderType> type,
  Value<ReminderFrequency> frequency,
  Value<DateTime> scheduledAt,
  Value<DateTime?> nextScheduled,
  Value<bool> isActive,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$ReminderTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderTableTable> {
  $$ReminderTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ReminderType, ReminderType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ReminderFrequency, ReminderFrequency, String>
      get frequency => $composableBuilder(
          column: $table.frequency,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextScheduled => $composableBuilder(
      column: $table.nextScheduled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ReminderTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderTableTable> {
  $$ReminderTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextScheduled => $composableBuilder(
      column: $table.nextScheduled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReminderTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderTableTable> {
  $$ReminderTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderFrequency, String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextScheduled => $composableBuilder(
      column: $table.nextScheduled, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReminderTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReminderTableTable,
    ReminderEntry,
    $$ReminderTableTableFilterComposer,
    $$ReminderTableTableOrderingComposer,
    $$ReminderTableTableAnnotationComposer,
    $$ReminderTableTableCreateCompanionBuilder,
    $$ReminderTableTableUpdateCompanionBuilder,
    (
      ReminderEntry,
      BaseReferences<_$AppDatabase, $ReminderTableTable, ReminderEntry>
    ),
    ReminderEntry,
    PrefetchHooks Function()> {
  $$ReminderTableTableTableManager(_$AppDatabase db, $ReminderTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<ReminderType> type = const Value.absent(),
            Value<ReminderFrequency> frequency = const Value.absent(),
            Value<DateTime> scheduledAt = const Value.absent(),
            Value<DateTime?> nextScheduled = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ReminderTableCompanion(
            id: id,
            title: title,
            description: description,
            type: type,
            frequency: frequency,
            scheduledAt: scheduledAt,
            nextScheduled: nextScheduled,
            isActive: isActive,
            isCompleted: isCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            required ReminderType type,
            required ReminderFrequency frequency,
            required DateTime scheduledAt,
            Value<DateTime?> nextScheduled = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ReminderTableCompanion.insert(
            id: id,
            title: title,
            description: description,
            type: type,
            frequency: frequency,
            scheduledAt: scheduledAt,
            nextScheduled: nextScheduled,
            isActive: isActive,
            isCompleted: isCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReminderTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReminderTableTable,
    ReminderEntry,
    $$ReminderTableTableFilterComposer,
    $$ReminderTableTableOrderingComposer,
    $$ReminderTableTableAnnotationComposer,
    $$ReminderTableTableCreateCompanionBuilder,
    $$ReminderTableTableUpdateCompanionBuilder,
    (
      ReminderEntry,
      BaseReferences<_$AppDatabase, $ReminderTableTable, ReminderEntry>
    ),
    ReminderEntry,
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
typedef $$MoodEntryTableTableCreateCompanionBuilder = MoodEntryTableCompanion
    Function({
  Value<int> id,
  required MoodLevel mood,
  required int energyLevel,
  required int stressLevel,
  required int sleepQuality,
  Value<String?> notes,
  required DateTime entryDate,
  Value<DateTime> createdAt,
});
typedef $$MoodEntryTableTableUpdateCompanionBuilder = MoodEntryTableCompanion
    Function({
  Value<int> id,
  Value<MoodLevel> mood,
  Value<int> energyLevel,
  Value<int> stressLevel,
  Value<int> sleepQuality,
  Value<String?> notes,
  Value<DateTime> entryDate,
  Value<DateTime> createdAt,
});

class $$MoodEntryTableTableFilterComposer
    extends Composer<_$AppDatabase, $MoodEntryTableTable> {
  $$MoodEntryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MoodLevel, MoodLevel, String> get mood =>
      $composableBuilder(
          column: $table.mood,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get energyLevel => $composableBuilder(
      column: $table.energyLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stressLevel => $composableBuilder(
      column: $table.stressLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sleepQuality => $composableBuilder(
      column: $table.sleepQuality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MoodEntryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MoodEntryTableTable> {
  $$MoodEntryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get energyLevel => $composableBuilder(
      column: $table.energyLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stressLevel => $composableBuilder(
      column: $table.stressLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sleepQuality => $composableBuilder(
      column: $table.sleepQuality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MoodEntryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoodEntryTableTable> {
  $$MoodEntryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MoodLevel, String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get energyLevel => $composableBuilder(
      column: $table.energyLevel, builder: (column) => column);

  GeneratedColumn<int> get stressLevel => $composableBuilder(
      column: $table.stressLevel, builder: (column) => column);

  GeneratedColumn<int> get sleepQuality => $composableBuilder(
      column: $table.sleepQuality, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MoodEntryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MoodEntryTableTable,
    MoodEntryData,
    $$MoodEntryTableTableFilterComposer,
    $$MoodEntryTableTableOrderingComposer,
    $$MoodEntryTableTableAnnotationComposer,
    $$MoodEntryTableTableCreateCompanionBuilder,
    $$MoodEntryTableTableUpdateCompanionBuilder,
    (
      MoodEntryData,
      BaseReferences<_$AppDatabase, $MoodEntryTableTable, MoodEntryData>
    ),
    MoodEntryData,
    PrefetchHooks Function()> {
  $$MoodEntryTableTableTableManager(
      _$AppDatabase db, $MoodEntryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoodEntryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodEntryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodEntryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<MoodLevel> mood = const Value.absent(),
            Value<int> energyLevel = const Value.absent(),
            Value<int> stressLevel = const Value.absent(),
            Value<int> sleepQuality = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> entryDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MoodEntryTableCompanion(
            id: id,
            mood: mood,
            energyLevel: energyLevel,
            stressLevel: stressLevel,
            sleepQuality: sleepQuality,
            notes: notes,
            entryDate: entryDate,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required MoodLevel mood,
            required int energyLevel,
            required int stressLevel,
            required int sleepQuality,
            Value<String?> notes = const Value.absent(),
            required DateTime entryDate,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MoodEntryTableCompanion.insert(
            id: id,
            mood: mood,
            energyLevel: energyLevel,
            stressLevel: stressLevel,
            sleepQuality: sleepQuality,
            notes: notes,
            entryDate: entryDate,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MoodEntryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MoodEntryTableTable,
    MoodEntryData,
    $$MoodEntryTableTableFilterComposer,
    $$MoodEntryTableTableOrderingComposer,
    $$MoodEntryTableTableAnnotationComposer,
    $$MoodEntryTableTableCreateCompanionBuilder,
    $$MoodEntryTableTableUpdateCompanionBuilder,
    (
      MoodEntryData,
      BaseReferences<_$AppDatabase, $MoodEntryTableTable, MoodEntryData>
    ),
    MoodEntryData,
    PrefetchHooks Function()>;
typedef $$DailyTrackingTableTableCreateCompanionBuilder
    = DailyTrackingTableCompanion Function({
  Value<int> id,
  required DateTime entryDate,
  required int cycleDay,
  Value<double?> sleepHours,
  Value<double?> weight,
  Value<int?> mood,
  Value<bool> cycling,
  Value<bool> resistance,
  Value<bool> meditation,
  Value<bool> dive,
  Value<bool> hike,
  Value<bool> social,
  Value<bool> yoga,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$DailyTrackingTableTableUpdateCompanionBuilder
    = DailyTrackingTableCompanion Function({
  Value<int> id,
  Value<DateTime> entryDate,
  Value<int> cycleDay,
  Value<double?> sleepHours,
  Value<double?> weight,
  Value<int?> mood,
  Value<bool> cycling,
  Value<bool> resistance,
  Value<bool> meditation,
  Value<bool> dive,
  Value<bool> hike,
  Value<bool> social,
  Value<bool> yoga,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$DailyTrackingTableTableFilterComposer
    extends Composer<_$AppDatabase, $DailyTrackingTableTable> {
  $$DailyTrackingTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cycleDay => $composableBuilder(
      column: $table.cycleDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sleepHours => $composableBuilder(
      column: $table.sleepHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get cycling => $composableBuilder(
      column: $table.cycling, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get resistance => $composableBuilder(
      column: $table.resistance, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get meditation => $composableBuilder(
      column: $table.meditation, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dive => $composableBuilder(
      column: $table.dive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hike => $composableBuilder(
      column: $table.hike, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get social => $composableBuilder(
      column: $table.social, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get yoga => $composableBuilder(
      column: $table.yoga, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DailyTrackingTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyTrackingTableTable> {
  $$DailyTrackingTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cycleDay => $composableBuilder(
      column: $table.cycleDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sleepHours => $composableBuilder(
      column: $table.sleepHours, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get cycling => $composableBuilder(
      column: $table.cycling, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get resistance => $composableBuilder(
      column: $table.resistance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get meditation => $composableBuilder(
      column: $table.meditation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dive => $composableBuilder(
      column: $table.dive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hike => $composableBuilder(
      column: $table.hike, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get social => $composableBuilder(
      column: $table.social, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get yoga => $composableBuilder(
      column: $table.yoga, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyTrackingTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyTrackingTableTable> {
  $$DailyTrackingTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<int> get cycleDay =>
      $composableBuilder(column: $table.cycleDay, builder: (column) => column);

  GeneratedColumn<double> get sleepHours => $composableBuilder(
      column: $table.sleepHours, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<bool> get cycling =>
      $composableBuilder(column: $table.cycling, builder: (column) => column);

  GeneratedColumn<bool> get resistance => $composableBuilder(
      column: $table.resistance, builder: (column) => column);

  GeneratedColumn<bool> get meditation => $composableBuilder(
      column: $table.meditation, builder: (column) => column);

  GeneratedColumn<bool> get dive =>
      $composableBuilder(column: $table.dive, builder: (column) => column);

  GeneratedColumn<bool> get hike =>
      $composableBuilder(column: $table.hike, builder: (column) => column);

  GeneratedColumn<bool> get social =>
      $composableBuilder(column: $table.social, builder: (column) => column);

  GeneratedColumn<bool> get yoga =>
      $composableBuilder(column: $table.yoga, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyTrackingTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyTrackingTableTable,
    DailyEntry,
    $$DailyTrackingTableTableFilterComposer,
    $$DailyTrackingTableTableOrderingComposer,
    $$DailyTrackingTableTableAnnotationComposer,
    $$DailyTrackingTableTableCreateCompanionBuilder,
    $$DailyTrackingTableTableUpdateCompanionBuilder,
    (
      DailyEntry,
      BaseReferences<_$AppDatabase, $DailyTrackingTableTable, DailyEntry>
    ),
    DailyEntry,
    PrefetchHooks Function()> {
  $$DailyTrackingTableTableTableManager(
      _$AppDatabase db, $DailyTrackingTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyTrackingTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyTrackingTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyTrackingTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> entryDate = const Value.absent(),
            Value<int> cycleDay = const Value.absent(),
            Value<double?> sleepHours = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<int?> mood = const Value.absent(),
            Value<bool> cycling = const Value.absent(),
            Value<bool> resistance = const Value.absent(),
            Value<bool> meditation = const Value.absent(),
            Value<bool> dive = const Value.absent(),
            Value<bool> hike = const Value.absent(),
            Value<bool> social = const Value.absent(),
            Value<bool> yoga = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DailyTrackingTableCompanion(
            id: id,
            entryDate: entryDate,
            cycleDay: cycleDay,
            sleepHours: sleepHours,
            weight: weight,
            mood: mood,
            cycling: cycling,
            resistance: resistance,
            meditation: meditation,
            dive: dive,
            hike: hike,
            social: social,
            yoga: yoga,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime entryDate,
            required int cycleDay,
            Value<double?> sleepHours = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<int?> mood = const Value.absent(),
            Value<bool> cycling = const Value.absent(),
            Value<bool> resistance = const Value.absent(),
            Value<bool> meditation = const Value.absent(),
            Value<bool> dive = const Value.absent(),
            Value<bool> hike = const Value.absent(),
            Value<bool> social = const Value.absent(),
            Value<bool> yoga = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DailyTrackingTableCompanion.insert(
            id: id,
            entryDate: entryDate,
            cycleDay: cycleDay,
            sleepHours: sleepHours,
            weight: weight,
            mood: mood,
            cycling: cycling,
            resistance: resistance,
            meditation: meditation,
            dive: dive,
            hike: hike,
            social: social,
            yoga: yoga,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyTrackingTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyTrackingTableTable,
    DailyEntry,
    $$DailyTrackingTableTableFilterComposer,
    $$DailyTrackingTableTableOrderingComposer,
    $$DailyTrackingTableTableAnnotationComposer,
    $$DailyTrackingTableTableCreateCompanionBuilder,
    $$DailyTrackingTableTableUpdateCompanionBuilder,
    (
      DailyEntry,
      BaseReferences<_$AppDatabase, $DailyTrackingTableTable, DailyEntry>
    ),
    DailyEntry,
    PrefetchHooks Function()>;
typedef $$SleepTrackingTableTableCreateCompanionBuilder
    = SleepTrackingTableCompanion Function({
  Value<int> id,
  required DateTime sleepDate,
  Value<int?> score,
  Value<SleepQuality?> quality,
  Value<int?> durationMinutes,
  Value<int?> stress,
  Value<int?> deepSleepMinutes,
  Value<int?> lightSleepMinutes,
  Value<int?> remSleepMinutes,
  Value<RestlessnessLevel?> restlessness,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SleepTrackingTableTableUpdateCompanionBuilder
    = SleepTrackingTableCompanion Function({
  Value<int> id,
  Value<DateTime> sleepDate,
  Value<int?> score,
  Value<SleepQuality?> quality,
  Value<int?> durationMinutes,
  Value<int?> stress,
  Value<int?> deepSleepMinutes,
  Value<int?> lightSleepMinutes,
  Value<int?> remSleepMinutes,
  Value<RestlessnessLevel?> restlessness,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$SleepTrackingTableTableFilterComposer
    extends Composer<_$AppDatabase, $SleepTrackingTableTable> {
  $$SleepTrackingTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sleepDate => $composableBuilder(
      column: $table.sleepDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SleepQuality?, SleepQuality, String>
      get quality => $composableBuilder(
          column: $table.quality,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stress => $composableBuilder(
      column: $table.stress, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deepSleepMinutes => $composableBuilder(
      column: $table.deepSleepMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lightSleepMinutes => $composableBuilder(
      column: $table.lightSleepMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remSleepMinutes => $composableBuilder(
      column: $table.remSleepMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RestlessnessLevel?, RestlessnessLevel, String>
      get restlessness => $composableBuilder(
          column: $table.restlessness,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SleepTrackingTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepTrackingTableTable> {
  $$SleepTrackingTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sleepDate => $composableBuilder(
      column: $table.sleepDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stress => $composableBuilder(
      column: $table.stress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deepSleepMinutes => $composableBuilder(
      column: $table.deepSleepMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lightSleepMinutes => $composableBuilder(
      column: $table.lightSleepMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remSleepMinutes => $composableBuilder(
      column: $table.remSleepMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get restlessness => $composableBuilder(
      column: $table.restlessness,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SleepTrackingTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepTrackingTableTable> {
  $$SleepTrackingTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get sleepDate =>
      $composableBuilder(column: $table.sleepDate, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SleepQuality?, String> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<int> get stress =>
      $composableBuilder(column: $table.stress, builder: (column) => column);

  GeneratedColumn<int> get deepSleepMinutes => $composableBuilder(
      column: $table.deepSleepMinutes, builder: (column) => column);

  GeneratedColumn<int> get lightSleepMinutes => $composableBuilder(
      column: $table.lightSleepMinutes, builder: (column) => column);

  GeneratedColumn<int> get remSleepMinutes => $composableBuilder(
      column: $table.remSleepMinutes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RestlessnessLevel?, String>
      get restlessness => $composableBuilder(
          column: $table.restlessness, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SleepTrackingTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SleepTrackingTableTable,
    SleepEntry,
    $$SleepTrackingTableTableFilterComposer,
    $$SleepTrackingTableTableOrderingComposer,
    $$SleepTrackingTableTableAnnotationComposer,
    $$SleepTrackingTableTableCreateCompanionBuilder,
    $$SleepTrackingTableTableUpdateCompanionBuilder,
    (
      SleepEntry,
      BaseReferences<_$AppDatabase, $SleepTrackingTableTable, SleepEntry>
    ),
    SleepEntry,
    PrefetchHooks Function()> {
  $$SleepTrackingTableTableTableManager(
      _$AppDatabase db, $SleepTrackingTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepTrackingTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepTrackingTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepTrackingTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> sleepDate = const Value.absent(),
            Value<int?> score = const Value.absent(),
            Value<SleepQuality?> quality = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<int?> stress = const Value.absent(),
            Value<int?> deepSleepMinutes = const Value.absent(),
            Value<int?> lightSleepMinutes = const Value.absent(),
            Value<int?> remSleepMinutes = const Value.absent(),
            Value<RestlessnessLevel?> restlessness = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SleepTrackingTableCompanion(
            id: id,
            sleepDate: sleepDate,
            score: score,
            quality: quality,
            durationMinutes: durationMinutes,
            stress: stress,
            deepSleepMinutes: deepSleepMinutes,
            lightSleepMinutes: lightSleepMinutes,
            remSleepMinutes: remSleepMinutes,
            restlessness: restlessness,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime sleepDate,
            Value<int?> score = const Value.absent(),
            Value<SleepQuality?> quality = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<int?> stress = const Value.absent(),
            Value<int?> deepSleepMinutes = const Value.absent(),
            Value<int?> lightSleepMinutes = const Value.absent(),
            Value<int?> remSleepMinutes = const Value.absent(),
            Value<RestlessnessLevel?> restlessness = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SleepTrackingTableCompanion.insert(
            id: id,
            sleepDate: sleepDate,
            score: score,
            quality: quality,
            durationMinutes: durationMinutes,
            stress: stress,
            deepSleepMinutes: deepSleepMinutes,
            lightSleepMinutes: lightSleepMinutes,
            remSleepMinutes: remSleepMinutes,
            restlessness: restlessness,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SleepTrackingTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SleepTrackingTableTable,
    SleepEntry,
    $$SleepTrackingTableTableFilterComposer,
    $$SleepTrackingTableTableOrderingComposer,
    $$SleepTrackingTableTableAnnotationComposer,
    $$SleepTrackingTableTableCreateCompanionBuilder,
    $$SleepTrackingTableTableUpdateCompanionBuilder,
    (
      SleepEntry,
      BaseReferences<_$AppDatabase, $SleepTrackingTableTable, SleepEntry>
    ),
    SleepEntry,
    PrefetchHooks Function()>;
typedef $$CyclingTrackingTableTableCreateCompanionBuilder
    = CyclingTrackingTableCompanion Function({
  Value<int> id,
  required DateTime rideDate,
  Value<double?> distanceKm,
  Value<int?> totalTimeSeconds,
  Value<double?> avgMovingSpeedKmh,
  Value<int?> avgHeartRate,
  Value<int?> maxHeartRate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$CyclingTrackingTableTableUpdateCompanionBuilder
    = CyclingTrackingTableCompanion Function({
  Value<int> id,
  Value<DateTime> rideDate,
  Value<double?> distanceKm,
  Value<int?> totalTimeSeconds,
  Value<double?> avgMovingSpeedKmh,
  Value<int?> avgHeartRate,
  Value<int?> maxHeartRate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$CyclingTrackingTableTableFilterComposer
    extends Composer<_$AppDatabase, $CyclingTrackingTableTable> {
  $$CyclingTrackingTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get rideDate => $composableBuilder(
      column: $table.rideDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distanceKm => $composableBuilder(
      column: $table.distanceKm, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalTimeSeconds => $composableBuilder(
      column: $table.totalTimeSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get avgMovingSpeedKmh => $composableBuilder(
      column: $table.avgMovingSpeedKmh,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
      column: $table.avgHeartRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxHeartRate => $composableBuilder(
      column: $table.maxHeartRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CyclingTrackingTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CyclingTrackingTableTable> {
  $$CyclingTrackingTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get rideDate => $composableBuilder(
      column: $table.rideDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distanceKm => $composableBuilder(
      column: $table.distanceKm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalTimeSeconds => $composableBuilder(
      column: $table.totalTimeSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get avgMovingSpeedKmh => $composableBuilder(
      column: $table.avgMovingSpeedKmh,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
      column: $table.avgHeartRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxHeartRate => $composableBuilder(
      column: $table.maxHeartRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CyclingTrackingTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CyclingTrackingTableTable> {
  $$CyclingTrackingTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get rideDate =>
      $composableBuilder(column: $table.rideDate, builder: (column) => column);

  GeneratedColumn<double> get distanceKm => $composableBuilder(
      column: $table.distanceKm, builder: (column) => column);

  GeneratedColumn<int> get totalTimeSeconds => $composableBuilder(
      column: $table.totalTimeSeconds, builder: (column) => column);

  GeneratedColumn<double> get avgMovingSpeedKmh => $composableBuilder(
      column: $table.avgMovingSpeedKmh, builder: (column) => column);

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
      column: $table.avgHeartRate, builder: (column) => column);

  GeneratedColumn<int> get maxHeartRate => $composableBuilder(
      column: $table.maxHeartRate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CyclingTrackingTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CyclingTrackingTableTable,
    CyclingTrackingEntry,
    $$CyclingTrackingTableTableFilterComposer,
    $$CyclingTrackingTableTableOrderingComposer,
    $$CyclingTrackingTableTableAnnotationComposer,
    $$CyclingTrackingTableTableCreateCompanionBuilder,
    $$CyclingTrackingTableTableUpdateCompanionBuilder,
    (
      CyclingTrackingEntry,
      BaseReferences<_$AppDatabase, $CyclingTrackingTableTable,
          CyclingTrackingEntry>
    ),
    CyclingTrackingEntry,
    PrefetchHooks Function()> {
  $$CyclingTrackingTableTableTableManager(
      _$AppDatabase db, $CyclingTrackingTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CyclingTrackingTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CyclingTrackingTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CyclingTrackingTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> rideDate = const Value.absent(),
            Value<double?> distanceKm = const Value.absent(),
            Value<int?> totalTimeSeconds = const Value.absent(),
            Value<double?> avgMovingSpeedKmh = const Value.absent(),
            Value<int?> avgHeartRate = const Value.absent(),
            Value<int?> maxHeartRate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CyclingTrackingTableCompanion(
            id: id,
            rideDate: rideDate,
            distanceKm: distanceKm,
            totalTimeSeconds: totalTimeSeconds,
            avgMovingSpeedKmh: avgMovingSpeedKmh,
            avgHeartRate: avgHeartRate,
            maxHeartRate: maxHeartRate,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime rideDate,
            Value<double?> distanceKm = const Value.absent(),
            Value<int?> totalTimeSeconds = const Value.absent(),
            Value<double?> avgMovingSpeedKmh = const Value.absent(),
            Value<int?> avgHeartRate = const Value.absent(),
            Value<int?> maxHeartRate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CyclingTrackingTableCompanion.insert(
            id: id,
            rideDate: rideDate,
            distanceKm: distanceKm,
            totalTimeSeconds: totalTimeSeconds,
            avgMovingSpeedKmh: avgMovingSpeedKmh,
            avgHeartRate: avgHeartRate,
            maxHeartRate: maxHeartRate,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CyclingTrackingTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CyclingTrackingTableTable,
        CyclingTrackingEntry,
        $$CyclingTrackingTableTableFilterComposer,
        $$CyclingTrackingTableTableOrderingComposer,
        $$CyclingTrackingTableTableAnnotationComposer,
        $$CyclingTrackingTableTableCreateCompanionBuilder,
        $$CyclingTrackingTableTableUpdateCompanionBuilder,
        (
          CyclingTrackingEntry,
          BaseReferences<_$AppDatabase, $CyclingTrackingTableTable,
              CyclingTrackingEntry>
        ),
        CyclingTrackingEntry,
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
typedef $$MealPlanTableTableCreateCompanionBuilder = MealPlanTableCompanion
    Function({
  Value<int> id,
  required int dayNumber,
  required MealType mealType,
  required String mealName,
  Value<String?> description,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$MealPlanTableTableUpdateCompanionBuilder = MealPlanTableCompanion
    Function({
  Value<int> id,
  Value<int> dayNumber,
  Value<MealType> mealType,
  Value<String> mealName,
  Value<String?> description,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$MealPlanTableTableFilterComposer
    extends Composer<_$AppDatabase, $MealPlanTableTable> {
  $$MealPlanTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayNumber => $composableBuilder(
      column: $table.dayNumber, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MealType, MealType, String> get mealType =>
      $composableBuilder(
          column: $table.mealType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get mealName => $composableBuilder(
      column: $table.mealName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MealPlanTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MealPlanTableTable> {
  $$MealPlanTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayNumber => $composableBuilder(
      column: $table.dayNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealName => $composableBuilder(
      column: $table.mealName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MealPlanTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealPlanTableTable> {
  $$MealPlanTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealType, String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get mealName =>
      $composableBuilder(column: $table.mealName, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MealPlanTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealPlanTableTable,
    MealPlan,
    $$MealPlanTableTableFilterComposer,
    $$MealPlanTableTableOrderingComposer,
    $$MealPlanTableTableAnnotationComposer,
    $$MealPlanTableTableCreateCompanionBuilder,
    $$MealPlanTableTableUpdateCompanionBuilder,
    (MealPlan, BaseReferences<_$AppDatabase, $MealPlanTableTable, MealPlan>),
    MealPlan,
    PrefetchHooks Function()> {
  $$MealPlanTableTableTableManager(_$AppDatabase db, $MealPlanTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealPlanTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealPlanTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealPlanTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> dayNumber = const Value.absent(),
            Value<MealType> mealType = const Value.absent(),
            Value<String> mealName = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MealPlanTableCompanion(
            id: id,
            dayNumber: dayNumber,
            mealType: mealType,
            mealName: mealName,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int dayNumber,
            required MealType mealType,
            required String mealName,
            Value<String?> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MealPlanTableCompanion.insert(
            id: id,
            dayNumber: dayNumber,
            mealType: mealType,
            mealName: mealName,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealPlanTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealPlanTableTable,
    MealPlan,
    $$MealPlanTableTableFilterComposer,
    $$MealPlanTableTableOrderingComposer,
    $$MealPlanTableTableAnnotationComposer,
    $$MealPlanTableTableCreateCompanionBuilder,
    $$MealPlanTableTableUpdateCompanionBuilder,
    (MealPlan, BaseReferences<_$AppDatabase, $MealPlanTableTable, MealPlan>),
    MealPlan,
    PrefetchHooks Function()>;
typedef $$FeedingWindowTableTableCreateCompanionBuilder
    = FeedingWindowTableCompanion Function({
  Value<int> id,
  required int startHour,
  required int startMinute,
  required int endHour,
  required int endMinute,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$FeedingWindowTableTableUpdateCompanionBuilder
    = FeedingWindowTableCompanion Function({
  Value<int> id,
  Value<int> startHour,
  Value<int> startMinute,
  Value<int> endHour,
  Value<int> endMinute,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$FeedingWindowTableTableFilterComposer
    extends Composer<_$AppDatabase, $FeedingWindowTableTable> {
  $$FeedingWindowTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startHour => $composableBuilder(
      column: $table.startHour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endHour => $composableBuilder(
      column: $table.endHour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endMinute => $composableBuilder(
      column: $table.endMinute, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FeedingWindowTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedingWindowTableTable> {
  $$FeedingWindowTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startHour => $composableBuilder(
      column: $table.startHour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endHour => $composableBuilder(
      column: $table.endHour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endMinute => $composableBuilder(
      column: $table.endMinute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FeedingWindowTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedingWindowTableTable> {
  $$FeedingWindowTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startHour =>
      $composableBuilder(column: $table.startHour, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => column);

  GeneratedColumn<int> get endHour =>
      $composableBuilder(column: $table.endHour, builder: (column) => column);

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeedingWindowTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FeedingWindowTableTable,
    FeedingWindow,
    $$FeedingWindowTableTableFilterComposer,
    $$FeedingWindowTableTableOrderingComposer,
    $$FeedingWindowTableTableAnnotationComposer,
    $$FeedingWindowTableTableCreateCompanionBuilder,
    $$FeedingWindowTableTableUpdateCompanionBuilder,
    (
      FeedingWindow,
      BaseReferences<_$AppDatabase, $FeedingWindowTableTable, FeedingWindow>
    ),
    FeedingWindow,
    PrefetchHooks Function()> {
  $$FeedingWindowTableTableTableManager(
      _$AppDatabase db, $FeedingWindowTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedingWindowTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedingWindowTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedingWindowTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> startHour = const Value.absent(),
            Value<int> startMinute = const Value.absent(),
            Value<int> endHour = const Value.absent(),
            Value<int> endMinute = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              FeedingWindowTableCompanion(
            id: id,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int startHour,
            required int startMinute,
            required int endHour,
            required int endMinute,
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              FeedingWindowTableCompanion.insert(
            id: id,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FeedingWindowTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FeedingWindowTableTable,
    FeedingWindow,
    $$FeedingWindowTableTableFilterComposer,
    $$FeedingWindowTableTableOrderingComposer,
    $$FeedingWindowTableTableAnnotationComposer,
    $$FeedingWindowTableTableCreateCompanionBuilder,
    $$FeedingWindowTableTableUpdateCompanionBuilder,
    (
      FeedingWindow,
      BaseReferences<_$AppDatabase, $FeedingWindowTableTable, FeedingWindow>
    ),
    FeedingWindow,
    PrefetchHooks Function()>;
typedef $$FastingTableTableCreateCompanionBuilder = FastingTableCompanion
    Function({
  Value<int> id,
  required FastType fastType,
  required DateTime startTime,
  Value<DateTime?> endTime,
  Value<int?> durationHours,
  Value<bool> isCompleted,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$FastingTableTableUpdateCompanionBuilder = FastingTableCompanion
    Function({
  Value<int> id,
  Value<FastType> fastType,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<int?> durationHours,
  Value<bool> isCompleted,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

class $$FastingTableTableFilterComposer
    extends Composer<_$AppDatabase, $FastingTableTable> {
  $$FastingTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<FastType, FastType, String> get fastType =>
      $composableBuilder(
          column: $table.fastType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationHours => $composableBuilder(
      column: $table.durationHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FastingTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FastingTableTable> {
  $$FastingTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fastType => $composableBuilder(
      column: $table.fastType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationHours => $composableBuilder(
      column: $table.durationHours,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FastingTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FastingTableTable> {
  $$FastingTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FastType, String> get fastType =>
      $composableBuilder(column: $table.fastType, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationHours => $composableBuilder(
      column: $table.durationHours, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FastingTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FastingTableTable,
    FastingEntry,
    $$FastingTableTableFilterComposer,
    $$FastingTableTableOrderingComposer,
    $$FastingTableTableAnnotationComposer,
    $$FastingTableTableCreateCompanionBuilder,
    $$FastingTableTableUpdateCompanionBuilder,
    (
      FastingEntry,
      BaseReferences<_$AppDatabase, $FastingTableTable, FastingEntry>
    ),
    FastingEntry,
    PrefetchHooks Function()> {
  $$FastingTableTableTableManager(_$AppDatabase db, $FastingTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FastingTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FastingTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FastingTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<FastType> fastType = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<int?> durationHours = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FastingTableCompanion(
            id: id,
            fastType: fastType,
            startTime: startTime,
            endTime: endTime,
            durationHours: durationHours,
            isCompleted: isCompleted,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required FastType fastType,
            required DateTime startTime,
            Value<DateTime?> endTime = const Value.absent(),
            Value<int?> durationHours = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FastingTableCompanion.insert(
            id: id,
            fastType: fastType,
            startTime: startTime,
            endTime: endTime,
            durationHours: durationHours,
            isCompleted: isCompleted,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FastingTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FastingTableTable,
    FastingEntry,
    $$FastingTableTableFilterComposer,
    $$FastingTableTableOrderingComposer,
    $$FastingTableTableAnnotationComposer,
    $$FastingTableTableCreateCompanionBuilder,
    $$FastingTableTableUpdateCompanionBuilder,
    (
      FastingEntry,
      BaseReferences<_$AppDatabase, $FastingTableTable, FastingEntry>
    ),
    FastingEntry,
    PrefetchHooks Function()>;
typedef $$SupplementsTableTableCreateCompanionBuilder
    = SupplementsTableCompanion Function({
  Value<int> id,
  required String name,
  required String dosage,
  required SupplementTiming timing,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SupplementsTableTableUpdateCompanionBuilder
    = SupplementsTableCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> dosage,
  Value<SupplementTiming> timing,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$SupplementsTableTableReferences
    extends BaseReferences<_$AppDatabase, $SupplementsTableTable, Supplement> {
  $$SupplementsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SupplementLogsTableTable, List<SupplementLog>>
      _supplementLogsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.supplementLogsTable,
              aliasName: $_aliasNameGenerator(
                  db.supplementsTable.id, db.supplementLogsTable.supplementId));

  $$SupplementLogsTableTableProcessedTableManager get supplementLogsTableRefs {
    final manager = $$SupplementLogsTableTableTableManager(
            $_db, $_db.supplementLogsTable)
        .filter((f) => f.supplementId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_supplementLogsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SupplementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SupplementsTableTable> {
  $$SupplementsTableTableFilterComposer({
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

  ColumnFilters<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SupplementTiming, SupplementTiming, String>
      get timing => $composableBuilder(
          column: $table.timing,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> supplementLogsTableRefs(
      Expression<bool> Function($$SupplementLogsTableTableFilterComposer f) f) {
    final $$SupplementLogsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.supplementLogsTable,
        getReferencedColumn: (t) => t.supplementId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplementLogsTableTableFilterComposer(
              $db: $db,
              $table: $db.supplementLogsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SupplementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplementsTableTable> {
  $$SupplementsTableTableOrderingComposer({
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

  ColumnOrderings<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timing => $composableBuilder(
      column: $table.timing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SupplementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplementsTableTable> {
  $$SupplementsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SupplementTiming, String> get timing =>
      $composableBuilder(column: $table.timing, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> supplementLogsTableRefs<T extends Object>(
      Expression<T> Function($$SupplementLogsTableTableAnnotationComposer a)
          f) {
    final $$SupplementLogsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.supplementLogsTable,
            getReferencedColumn: (t) => t.supplementId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplementLogsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.supplementLogsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SupplementsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SupplementsTableTable,
    Supplement,
    $$SupplementsTableTableFilterComposer,
    $$SupplementsTableTableOrderingComposer,
    $$SupplementsTableTableAnnotationComposer,
    $$SupplementsTableTableCreateCompanionBuilder,
    $$SupplementsTableTableUpdateCompanionBuilder,
    (Supplement, $$SupplementsTableTableReferences),
    Supplement,
    PrefetchHooks Function({bool supplementLogsTableRefs})> {
  $$SupplementsTableTableTableManager(
      _$AppDatabase db, $SupplementsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplementsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplementsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplementsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> dosage = const Value.absent(),
            Value<SupplementTiming> timing = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SupplementsTableCompanion(
            id: id,
            name: name,
            dosage: dosage,
            timing: timing,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String dosage,
            required SupplementTiming timing,
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SupplementsTableCompanion.insert(
            id: id,
            name: name,
            dosage: dosage,
            timing: timing,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SupplementsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({supplementLogsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (supplementLogsTableRefs) db.supplementLogsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (supplementLogsTableRefs)
                    await $_getPrefetchedData<Supplement, $SupplementsTableTable,
                            SupplementLog>(
                        currentTable: table,
                        referencedTable: $$SupplementsTableTableReferences
                            ._supplementLogsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SupplementsTableTableReferences(db, table, p0)
                                .supplementLogsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.supplementId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SupplementsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SupplementsTableTable,
    Supplement,
    $$SupplementsTableTableFilterComposer,
    $$SupplementsTableTableOrderingComposer,
    $$SupplementsTableTableAnnotationComposer,
    $$SupplementsTableTableCreateCompanionBuilder,
    $$SupplementsTableTableUpdateCompanionBuilder,
    (Supplement, $$SupplementsTableTableReferences),
    Supplement,
    PrefetchHooks Function({bool supplementLogsTableRefs})>;
typedef $$SupplementLogsTableTableCreateCompanionBuilder
    = SupplementLogsTableCompanion Function({
  Value<int> id,
  required int supplementId,
  required DateTime logDate,
  Value<bool> taken,
  Value<DateTime?> takenAt,
  Value<DateTime> createdAt,
});
typedef $$SupplementLogsTableTableUpdateCompanionBuilder
    = SupplementLogsTableCompanion Function({
  Value<int> id,
  Value<int> supplementId,
  Value<DateTime> logDate,
  Value<bool> taken,
  Value<DateTime?> takenAt,
  Value<DateTime> createdAt,
});

final class $$SupplementLogsTableTableReferences extends BaseReferences<
    _$AppDatabase, $SupplementLogsTableTable, SupplementLog> {
  $$SupplementLogsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SupplementsTableTable _supplementIdTable(_$AppDatabase db) =>
      db.supplementsTable.createAlias($_aliasNameGenerator(
          db.supplementLogsTable.supplementId, db.supplementsTable.id));

  $$SupplementsTableTableProcessedTableManager get supplementId {
    final $_column = $_itemColumn<int>('supplement_id')!;

    final manager =
        $$SupplementsTableTableTableManager($_db, $_db.supplementsTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SupplementLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SupplementLogsTableTable> {
  $$SupplementLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get taken => $composableBuilder(
      column: $table.taken, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SupplementsTableTableFilterComposer get supplementId {
    final $$SupplementsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplementId,
        referencedTable: $db.supplementsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplementsTableTableFilterComposer(
              $db: $db,
              $table: $db.supplementsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SupplementLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplementLogsTableTable> {
  $$SupplementLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get taken => $composableBuilder(
      column: $table.taken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SupplementsTableTableOrderingComposer get supplementId {
    final $$SupplementsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplementId,
        referencedTable: $db.supplementsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplementsTableTableOrderingComposer(
              $db: $db,
              $table: $db.supplementsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SupplementLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplementLogsTableTable> {
  $$SupplementLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<bool> get taken =>
      $composableBuilder(column: $table.taken, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SupplementsTableTableAnnotationComposer get supplementId {
    final $$SupplementsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplementId,
        referencedTable: $db.supplementsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplementsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.supplementsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SupplementLogsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SupplementLogsTableTable,
    SupplementLog,
    $$SupplementLogsTableTableFilterComposer,
    $$SupplementLogsTableTableOrderingComposer,
    $$SupplementLogsTableTableAnnotationComposer,
    $$SupplementLogsTableTableCreateCompanionBuilder,
    $$SupplementLogsTableTableUpdateCompanionBuilder,
    (SupplementLog, $$SupplementLogsTableTableReferences),
    SupplementLog,
    PrefetchHooks Function({bool supplementId})> {
  $$SupplementLogsTableTableTableManager(
      _$AppDatabase db, $SupplementLogsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplementLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplementLogsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplementLogsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> supplementId = const Value.absent(),
            Value<DateTime> logDate = const Value.absent(),
            Value<bool> taken = const Value.absent(),
            Value<DateTime?> takenAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SupplementLogsTableCompanion(
            id: id,
            supplementId: supplementId,
            logDate: logDate,
            taken: taken,
            takenAt: takenAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int supplementId,
            required DateTime logDate,
            Value<bool> taken = const Value.absent(),
            Value<DateTime?> takenAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SupplementLogsTableCompanion.insert(
            id: id,
            supplementId: supplementId,
            logDate: logDate,
            taken: taken,
            takenAt: takenAt,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SupplementLogsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({supplementId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (supplementId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.supplementId,
                    referencedTable: $$SupplementLogsTableTableReferences
                        ._supplementIdTable(db),
                    referencedColumn: $$SupplementLogsTableTableReferences
                        ._supplementIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SupplementLogsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SupplementLogsTableTable,
    SupplementLog,
    $$SupplementLogsTableTableFilterComposer,
    $$SupplementLogsTableTableOrderingComposer,
    $$SupplementLogsTableTableAnnotationComposer,
    $$SupplementLogsTableTableCreateCompanionBuilder,
    $$SupplementLogsTableTableUpdateCompanionBuilder,
    (SupplementLog, $$SupplementLogsTableTableReferences),
    SupplementLog,
    PrefetchHooks Function({bool supplementId})>;
typedef $$PlanningTableTableCreateCompanionBuilder = PlanningTableCompanion
    Function({
  Value<int> id,
  required PlanType planType,
  required DateTime planDate,
  required String title,
  Value<String?> description,
  Value<bool> isCompleted,
  Value<int?> priority,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$PlanningTableTableUpdateCompanionBuilder = PlanningTableCompanion
    Function({
  Value<int> id,
  Value<PlanType> planType,
  Value<DateTime> planDate,
  Value<String> title,
  Value<String?> description,
  Value<bool> isCompleted,
  Value<int?> priority,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$PlanningTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlanningTableTable> {
  $$PlanningTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PlanType, PlanType, String> get planType =>
      $composableBuilder(
          column: $table.planType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get planDate => $composableBuilder(
      column: $table.planDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PlanningTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanningTableTable> {
  $$PlanningTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planType => $composableBuilder(
      column: $table.planType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get planDate => $composableBuilder(
      column: $table.planDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlanningTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanningTableTable> {
  $$PlanningTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlanType, String> get planType =>
      $composableBuilder(column: $table.planType, builder: (column) => column);

  GeneratedColumn<DateTime> get planDate =>
      $composableBuilder(column: $table.planDate, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlanningTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanningTableTable,
    PlanEntry,
    $$PlanningTableTableFilterComposer,
    $$PlanningTableTableOrderingComposer,
    $$PlanningTableTableAnnotationComposer,
    $$PlanningTableTableCreateCompanionBuilder,
    $$PlanningTableTableUpdateCompanionBuilder,
    (PlanEntry, BaseReferences<_$AppDatabase, $PlanningTableTable, PlanEntry>),
    PlanEntry,
    PrefetchHooks Function()> {
  $$PlanningTableTableTableManager(_$AppDatabase db, $PlanningTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanningTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanningTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanningTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<PlanType> planType = const Value.absent(),
            Value<DateTime> planDate = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int?> priority = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PlanningTableCompanion(
            id: id,
            planType: planType,
            planDate: planDate,
            title: title,
            description: description,
            isCompleted: isCompleted,
            priority: priority,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required PlanType planType,
            required DateTime planDate,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int?> priority = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PlanningTableCompanion.insert(
            id: id,
            planType: planType,
            planDate: planDate,
            title: title,
            description: description,
            isCompleted: isCompleted,
            priority: priority,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanningTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanningTableTable,
    PlanEntry,
    $$PlanningTableTableFilterComposer,
    $$PlanningTableTableOrderingComposer,
    $$PlanningTableTableAnnotationComposer,
    $$PlanningTableTableCreateCompanionBuilder,
    $$PlanningTableTableUpdateCompanionBuilder,
    (PlanEntry, BaseReferences<_$AppDatabase, $PlanningTableTable, PlanEntry>),
    PlanEntry,
    PrefetchHooks Function()>;
typedef $$JournalTableTableCreateCompanionBuilder = JournalTableCompanion
    Function({
  Value<int> id,
  required JournalType journalType,
  required DateTime entryDate,
  Value<String?> reflections,
  Value<String?> gratitude,
  Value<String?> notes,
  Value<String?> wins,
  Value<String?> lessons,
  Value<String?> nextWeekPlan,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$JournalTableTableUpdateCompanionBuilder = JournalTableCompanion
    Function({
  Value<int> id,
  Value<JournalType> journalType,
  Value<DateTime> entryDate,
  Value<String?> reflections,
  Value<String?> gratitude,
  Value<String?> notes,
  Value<String?> wins,
  Value<String?> lessons,
  Value<String?> nextWeekPlan,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$JournalTableTableFilterComposer
    extends Composer<_$AppDatabase, $JournalTableTable> {
  $$JournalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<JournalType, JournalType, String>
      get journalType => $composableBuilder(
          column: $table.journalType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reflections => $composableBuilder(
      column: $table.reflections, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gratitude => $composableBuilder(
      column: $table.gratitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wins => $composableBuilder(
      column: $table.wins, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lessons => $composableBuilder(
      column: $table.lessons, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nextWeekPlan => $composableBuilder(
      column: $table.nextWeekPlan, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$JournalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalTableTable> {
  $$JournalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get journalType => $composableBuilder(
      column: $table.journalType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reflections => $composableBuilder(
      column: $table.reflections, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gratitude => $composableBuilder(
      column: $table.gratitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wins => $composableBuilder(
      column: $table.wins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lessons => $composableBuilder(
      column: $table.lessons, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nextWeekPlan => $composableBuilder(
      column: $table.nextWeekPlan,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$JournalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalTableTable> {
  $$JournalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JournalType, String> get journalType =>
      $composableBuilder(
          column: $table.journalType, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get reflections => $composableBuilder(
      column: $table.reflections, builder: (column) => column);

  GeneratedColumn<String> get gratitude =>
      $composableBuilder(column: $table.gratitude, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get wins =>
      $composableBuilder(column: $table.wins, builder: (column) => column);

  GeneratedColumn<String> get lessons =>
      $composableBuilder(column: $table.lessons, builder: (column) => column);

  GeneratedColumn<String> get nextWeekPlan => $composableBuilder(
      column: $table.nextWeekPlan, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$JournalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $JournalTableTable,
    JournalEntry,
    $$JournalTableTableFilterComposer,
    $$JournalTableTableOrderingComposer,
    $$JournalTableTableAnnotationComposer,
    $$JournalTableTableCreateCompanionBuilder,
    $$JournalTableTableUpdateCompanionBuilder,
    (
      JournalEntry,
      BaseReferences<_$AppDatabase, $JournalTableTable, JournalEntry>
    ),
    JournalEntry,
    PrefetchHooks Function()> {
  $$JournalTableTableTableManager(_$AppDatabase db, $JournalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<JournalType> journalType = const Value.absent(),
            Value<DateTime> entryDate = const Value.absent(),
            Value<String?> reflections = const Value.absent(),
            Value<String?> gratitude = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> wins = const Value.absent(),
            Value<String?> lessons = const Value.absent(),
            Value<String?> nextWeekPlan = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              JournalTableCompanion(
            id: id,
            journalType: journalType,
            entryDate: entryDate,
            reflections: reflections,
            gratitude: gratitude,
            notes: notes,
            wins: wins,
            lessons: lessons,
            nextWeekPlan: nextWeekPlan,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required JournalType journalType,
            required DateTime entryDate,
            Value<String?> reflections = const Value.absent(),
            Value<String?> gratitude = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> wins = const Value.absent(),
            Value<String?> lessons = const Value.absent(),
            Value<String?> nextWeekPlan = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              JournalTableCompanion.insert(
            id: id,
            journalType: journalType,
            entryDate: entryDate,
            reflections: reflections,
            gratitude: gratitude,
            notes: notes,
            wins: wins,
            lessons: lessons,
            nextWeekPlan: nextWeekPlan,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JournalTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $JournalTableTable,
    JournalEntry,
    $$JournalTableTableFilterComposer,
    $$JournalTableTableOrderingComposer,
    $$JournalTableTableAnnotationComposer,
    $$JournalTableTableCreateCompanionBuilder,
    $$JournalTableTableUpdateCompanionBuilder,
    (
      JournalEntry,
      BaseReferences<_$AppDatabase, $JournalTableTable, JournalEntry>
    ),
    JournalEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AssessmentTableTableTableManager get assessmentTable =>
      $$AssessmentTableTableTableManager(_db, _db.assessmentTable);
  $$ReminderTableTableTableManager get reminderTable =>
      $$ReminderTableTableTableManager(_db, _db.reminderTable);
  $$CognitiveExerciseTableTableTableManager get cognitiveExerciseTable =>
      $$CognitiveExerciseTableTableTableManager(
          _db, _db.cognitiveExerciseTable);
  $$MoodEntryTableTableTableManager get moodEntryTable =>
      $$MoodEntryTableTableTableManager(_db, _db.moodEntryTable);
  $$DailyTrackingTableTableTableManager get dailyTrackingTable =>
      $$DailyTrackingTableTableTableManager(_db, _db.dailyTrackingTable);
  $$SleepTrackingTableTableTableManager get sleepTrackingTable =>
      $$SleepTrackingTableTableTableManager(_db, _db.sleepTrackingTable);
  $$CyclingTrackingTableTableTableManager get cyclingTrackingTable =>
      $$CyclingTrackingTableTableTableManager(_db, _db.cyclingTrackingTable);
  $$WordDictionaryTableTableTableManager get wordDictionaryTable =>
      $$WordDictionaryTableTableTableManager(_db, _db.wordDictionaryTable);
  $$UserProfileTableTableTableManager get userProfileTable =>
      $$UserProfileTableTableTableManager(_db, _db.userProfileTable);
  $$CambridgeAssessmentTableTableTableManager get cambridgeAssessmentTable =>
      $$CambridgeAssessmentTableTableTableManager(
          _db, _db.cambridgeAssessmentTable);
  $$MealPlanTableTableTableManager get mealPlanTable =>
      $$MealPlanTableTableTableManager(_db, _db.mealPlanTable);
  $$FeedingWindowTableTableTableManager get feedingWindowTable =>
      $$FeedingWindowTableTableTableManager(_db, _db.feedingWindowTable);
  $$FastingTableTableTableManager get fastingTable =>
      $$FastingTableTableTableManager(_db, _db.fastingTable);
  $$SupplementsTableTableTableManager get supplementsTable =>
      $$SupplementsTableTableTableManager(_db, _db.supplementsTable);
  $$SupplementLogsTableTableTableManager get supplementLogsTable =>
      $$SupplementLogsTableTableTableManager(_db, _db.supplementLogsTable);
  $$PlanningTableTableTableManager get planningTable =>
      $$PlanningTableTableTableManager(_db, _db.planningTable);
  $$JournalTableTableTableManager get journalTable =>
      $$JournalTableTableTableManager(_db, _db.journalTable);
}
