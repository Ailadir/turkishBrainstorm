// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _turkishMeta = const VerificationMeta(
    'turkish',
  );
  @override
  late final GeneratedColumn<String> turkish = GeneratedColumn<String>(
    'turkish',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootMeta = const VerificationMeta('root');
  @override
  late final GeneratedColumn<String> root = GeneratedColumn<String>(
    'root',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _suffixesMeta = const VerificationMeta(
    'suffixes',
  );
  @override
  late final GeneratedColumn<String> suffixes = GeneratedColumn<String>(
    'suffixes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _englishMeta = const VerificationMeta(
    'english',
  );
  @override
  late final GeneratedColumn<String> english = GeneratedColumn<String>(
    'english',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    turkish,
    root,
    suffixes,
    english,
    note,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('turkish')) {
      context.handle(
        _turkishMeta,
        turkish.isAcceptableOrUnknown(data['turkish']!, _turkishMeta),
      );
    } else if (isInserting) {
      context.missing(_turkishMeta);
    }
    if (data.containsKey('root')) {
      context.handle(
        _rootMeta,
        root.isAcceptableOrUnknown(data['root']!, _rootMeta),
      );
    }
    if (data.containsKey('suffixes')) {
      context.handle(
        _suffixesMeta,
        suffixes.isAcceptableOrUnknown(data['suffixes']!, _suffixesMeta),
      );
    }
    if (data.containsKey('english')) {
      context.handle(
        _englishMeta,
        english.isAcceptableOrUnknown(data['english']!, _englishMeta),
      );
    } else if (isInserting) {
      context.missing(_englishMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      turkish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}turkish'],
      )!,
      root: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root'],
      )!,
      suffixes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suffixes'],
      )!,
      english: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;

  /// The full word as encountered.
  final String turkish;

  /// Root/lemma from Zemberek analysis.
  final String root;

  /// Suffix morpheme ids as a JSON array string (editable if ambiguous).
  final String suffixes;

  /// Primary English translation.
  final String english;

  /// Example sentence / context from the source, optional.
  final String? note;

  /// Where the word was found (e.g. manhwa title), optional.
  final String? source;
  final DateTime createdAt;
  const Word({
    required this.id,
    required this.turkish,
    required this.root,
    required this.suffixes,
    required this.english,
    this.note,
    this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['turkish'] = Variable<String>(turkish);
    map['root'] = Variable<String>(root);
    map['suffixes'] = Variable<String>(suffixes);
    map['english'] = Variable<String>(english);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      turkish: Value(turkish),
      root: Value(root),
      suffixes: Value(suffixes),
      english: Value(english),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      turkish: serializer.fromJson<String>(json['turkish']),
      root: serializer.fromJson<String>(json['root']),
      suffixes: serializer.fromJson<String>(json['suffixes']),
      english: serializer.fromJson<String>(json['english']),
      note: serializer.fromJson<String?>(json['note']),
      source: serializer.fromJson<String?>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'turkish': serializer.toJson<String>(turkish),
      'root': serializer.toJson<String>(root),
      'suffixes': serializer.toJson<String>(suffixes),
      'english': serializer.toJson<String>(english),
      'note': serializer.toJson<String?>(note),
      'source': serializer.toJson<String?>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Word copyWith({
    int? id,
    String? turkish,
    String? root,
    String? suffixes,
    String? english,
    Value<String?> note = const Value.absent(),
    Value<String?> source = const Value.absent(),
    DateTime? createdAt,
  }) => Word(
    id: id ?? this.id,
    turkish: turkish ?? this.turkish,
    root: root ?? this.root,
    suffixes: suffixes ?? this.suffixes,
    english: english ?? this.english,
    note: note.present ? note.value : this.note,
    source: source.present ? source.value : this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      turkish: data.turkish.present ? data.turkish.value : this.turkish,
      root: data.root.present ? data.root.value : this.root,
      suffixes: data.suffixes.present ? data.suffixes.value : this.suffixes,
      english: data.english.present ? data.english.value : this.english,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('turkish: $turkish, ')
          ..write('root: $root, ')
          ..write('suffixes: $suffixes, ')
          ..write('english: $english, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    turkish,
    root,
    suffixes,
    english,
    note,
    source,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.turkish == this.turkish &&
          other.root == this.root &&
          other.suffixes == this.suffixes &&
          other.english == this.english &&
          other.note == this.note &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> turkish;
  final Value<String> root;
  final Value<String> suffixes;
  final Value<String> english;
  final Value<String?> note;
  final Value<String?> source;
  final Value<DateTime> createdAt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.turkish = const Value.absent(),
    this.root = const Value.absent(),
    this.suffixes = const Value.absent(),
    this.english = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String turkish,
    this.root = const Value.absent(),
    this.suffixes = const Value.absent(),
    required String english,
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : turkish = Value(turkish),
       english = Value(english);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? turkish,
    Expression<String>? root,
    Expression<String>? suffixes,
    Expression<String>? english,
    Expression<String>? note,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (turkish != null) 'turkish': turkish,
      if (root != null) 'root': root,
      if (suffixes != null) 'suffixes': suffixes,
      if (english != null) 'english': english,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? turkish,
    Value<String>? root,
    Value<String>? suffixes,
    Value<String>? english,
    Value<String?>? note,
    Value<String?>? source,
    Value<DateTime>? createdAt,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      turkish: turkish ?? this.turkish,
      root: root ?? this.root,
      suffixes: suffixes ?? this.suffixes,
      english: english ?? this.english,
      note: note ?? this.note,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (turkish.present) {
      map['turkish'] = Variable<String>(turkish.value);
    }
    if (root.present) {
      map['root'] = Variable<String>(root.value);
    }
    if (suffixes.present) {
      map['suffixes'] = Variable<String>(suffixes.value);
    }
    if (english.present) {
      map['english'] = Variable<String>(english.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('turkish: $turkish, ')
          ..write('root: $root, ')
          ..write('suffixes: $suffixes, ')
          ..write('english: $english, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PracticeStatesTable extends PracticeStates
    with TableInfo<$PracticeStatesTable, PracticeState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<double> intervalDays = GeneratedColumn<double>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordId,
    mode,
    intervalDays,
    easeFactor,
    repetitions,
    dueAt,
    lastReviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {wordId, mode},
  ];
  @override
  PracticeState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interval_days'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
    );
  }

  @override
  $PracticeStatesTable createAlias(String alias) {
    return $PracticeStatesTable(attachedDatabase, alias);
  }
}

class PracticeState extends DataClass implements Insertable<PracticeState> {
  final int id;
  final int wordId;

  /// Persisted as the [PracticeMode] enum name.
  final String mode;
  final double intervalDays;
  final double easeFactor;
  final int repetitions;
  final DateTime dueAt;
  final DateTime? lastReviewedAt;
  const PracticeState({
    required this.id,
    required this.wordId,
    required this.mode,
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitions,
    required this.dueAt,
    this.lastReviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_id'] = Variable<int>(wordId);
    map['mode'] = Variable<String>(mode);
    map['interval_days'] = Variable<double>(intervalDays);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['repetitions'] = Variable<int>(repetitions);
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    return map;
  }

  PracticeStatesCompanion toCompanion(bool nullToAbsent) {
    return PracticeStatesCompanion(
      id: Value(id),
      wordId: Value(wordId),
      mode: Value(mode),
      intervalDays: Value(intervalDays),
      easeFactor: Value(easeFactor),
      repetitions: Value(repetitions),
      dueAt: Value(dueAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
    );
  }

  factory PracticeState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeState(
      id: serializer.fromJson<int>(json['id']),
      wordId: serializer.fromJson<int>(json['wordId']),
      mode: serializer.fromJson<String>(json['mode']),
      intervalDays: serializer.fromJson<double>(json['intervalDays']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int>(wordId),
      'mode': serializer.toJson<String>(mode),
      'intervalDays': serializer.toJson<double>(intervalDays),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'repetitions': serializer.toJson<int>(repetitions),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
    };
  }

  PracticeState copyWith({
    int? id,
    int? wordId,
    String? mode,
    double? intervalDays,
    double? easeFactor,
    int? repetitions,
    DateTime? dueAt,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
  }) => PracticeState(
    id: id ?? this.id,
    wordId: wordId ?? this.wordId,
    mode: mode ?? this.mode,
    intervalDays: intervalDays ?? this.intervalDays,
    easeFactor: easeFactor ?? this.easeFactor,
    repetitions: repetitions ?? this.repetitions,
    dueAt: dueAt ?? this.dueAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
  );
  PracticeState copyWithCompanion(PracticeStatesCompanion data) {
    return PracticeState(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      mode: data.mode.present ? data.mode.value : this.mode,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeState(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('mode: $mode, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wordId,
    mode,
    intervalDays,
    easeFactor,
    repetitions,
    dueAt,
    lastReviewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeState &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.mode == this.mode &&
          other.intervalDays == this.intervalDays &&
          other.easeFactor == this.easeFactor &&
          other.repetitions == this.repetitions &&
          other.dueAt == this.dueAt &&
          other.lastReviewedAt == this.lastReviewedAt);
}

class PracticeStatesCompanion extends UpdateCompanion<PracticeState> {
  final Value<int> id;
  final Value<int> wordId;
  final Value<String> mode;
  final Value<double> intervalDays;
  final Value<double> easeFactor;
  final Value<int> repetitions;
  final Value<DateTime> dueAt;
  final Value<DateTime?> lastReviewedAt;
  const PracticeStatesCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.mode = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
  });
  PracticeStatesCompanion.insert({
    this.id = const Value.absent(),
    required int wordId,
    required String mode,
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    required DateTime dueAt,
    this.lastReviewedAt = const Value.absent(),
  }) : wordId = Value(wordId),
       mode = Value(mode),
       dueAt = Value(dueAt);
  static Insertable<PracticeState> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<String>? mode,
    Expression<double>? intervalDays,
    Expression<double>? easeFactor,
    Expression<int>? repetitions,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (mode != null) 'mode': mode,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (repetitions != null) 'repetitions': repetitions,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
    });
  }

  PracticeStatesCompanion copyWith({
    Value<int>? id,
    Value<int>? wordId,
    Value<String>? mode,
    Value<double>? intervalDays,
    Value<double>? easeFactor,
    Value<int>? repetitions,
    Value<DateTime>? dueAt,
    Value<DateTime?>? lastReviewedAt,
  }) {
    return PracticeStatesCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      mode: mode ?? this.mode,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<double>(intervalDays.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeStatesCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('mode: $mode, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogTable extends ReviewLog
    with TableInfo<$ReviewLogTable, ReviewLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, wordId, mode, result, reviewedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
    );
  }

  @override
  $ReviewLogTable createAlias(String alias) {
    return $ReviewLogTable(attachedDatabase, alias);
  }
}

class ReviewLogData extends DataClass implements Insertable<ReviewLogData> {
  final int id;
  final int wordId;

  /// Persisted as the [PracticeMode] enum name.
  final String mode;

  /// Persisted as the [ReviewGrade] enum name.
  final String result;
  final DateTime reviewedAt;
  const ReviewLogData({
    required this.id,
    required this.wordId,
    required this.mode,
    required this.result,
    required this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_id'] = Variable<int>(wordId);
    map['mode'] = Variable<String>(mode);
    map['result'] = Variable<String>(result);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    return map;
  }

  ReviewLogCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogCompanion(
      id: Value(id),
      wordId: Value(wordId),
      mode: Value(mode),
      result: Value(result),
      reviewedAt: Value(reviewedAt),
    );
  }

  factory ReviewLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLogData(
      id: serializer.fromJson<int>(json['id']),
      wordId: serializer.fromJson<int>(json['wordId']),
      mode: serializer.fromJson<String>(json['mode']),
      result: serializer.fromJson<String>(json['result']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int>(wordId),
      'mode': serializer.toJson<String>(mode),
      'result': serializer.toJson<String>(result),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
    };
  }

  ReviewLogData copyWith({
    int? id,
    int? wordId,
    String? mode,
    String? result,
    DateTime? reviewedAt,
  }) => ReviewLogData(
    id: id ?? this.id,
    wordId: wordId ?? this.wordId,
    mode: mode ?? this.mode,
    result: result ?? this.result,
    reviewedAt: reviewedAt ?? this.reviewedAt,
  );
  ReviewLogData copyWithCompanion(ReviewLogCompanion data) {
    return ReviewLogData(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      mode: data.mode.present ? data.mode.value : this.mode,
      result: data.result.present ? data.result.value : this.result,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogData(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('mode: $mode, ')
          ..write('result: $result, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, wordId, mode, result, reviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLogData &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.mode == this.mode &&
          other.result == this.result &&
          other.reviewedAt == this.reviewedAt);
}

class ReviewLogCompanion extends UpdateCompanion<ReviewLogData> {
  final Value<int> id;
  final Value<int> wordId;
  final Value<String> mode;
  final Value<String> result;
  final Value<DateTime> reviewedAt;
  const ReviewLogCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.mode = const Value.absent(),
    this.result = const Value.absent(),
    this.reviewedAt = const Value.absent(),
  });
  ReviewLogCompanion.insert({
    this.id = const Value.absent(),
    required int wordId,
    required String mode,
    required String result,
    this.reviewedAt = const Value.absent(),
  }) : wordId = Value(wordId),
       mode = Value(mode),
       result = Value(result);
  static Insertable<ReviewLogData> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<String>? mode,
    Expression<String>? result,
    Expression<DateTime>? reviewedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (mode != null) 'mode': mode,
      if (result != null) 'result': result,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
    });
  }

  ReviewLogCompanion copyWith({
    Value<int>? id,
    Value<int>? wordId,
    Value<String>? mode,
    Value<String>? result,
    Value<DateTime>? reviewedAt,
  }) {
    return ReviewLogCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      mode: mode ?? this.mode,
      result: result ?? this.result,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('mode: $mode, ')
          ..write('result: $result, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $PracticeStatesTable practiceStates = $PracticeStatesTable(this);
  late final $ReviewLogTable reviewLog = $ReviewLogTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    words,
    practiceStates,
    reviewLog,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('practice_states', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('review_log', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  required String turkish,
  Value<String> root,
  Value<String> suffixes,
  required String english,
  Value<String?> note,
  Value<String?> source,
  Value<DateTime> createdAt,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  Value<String> turkish,
  Value<String> root,
  Value<String> suffixes,
  Value<String> english,
  Value<String?> note,
  Value<String?> source,
  Value<DateTime> createdAt,
});

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PracticeStatesTable, List<PracticeState>>
  _practiceStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.practiceStates,
    aliasName: 'words__id__practice_states__word_id',
  );

  $$PracticeStatesTableProcessedTableManager get practiceStatesRefs {
    final manager = $$PracticeStatesTableTableManager(
      $_db,
      $_db.practiceStates,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_practiceStatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReviewLogTable, List<ReviewLogData>>
  _reviewLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewLog,
    aliasName: 'words__id__review_log__word_id',
  );

  $$ReviewLogTableProcessedTableManager get reviewLogRefs {
    final manager = $$ReviewLogTableTableManager(
      $_db,
      $_db.reviewLog,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get turkish => $composableBuilder(
    column: $table.turkish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get root => $composableBuilder(
    column: $table.root,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suffixes => $composableBuilder(
    column: $table.suffixes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> practiceStatesRefs(
    Expression<bool> Function($$PracticeStatesTableFilterComposer f) f,
  ) {
    final $$PracticeStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceStates,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeStatesTableFilterComposer(
            $db: $db,
            $table: $db.practiceStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reviewLogRefs(
    Expression<bool> Function($$ReviewLogTableFilterComposer f) f,
  ) {
    final $$ReviewLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLog,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogTableFilterComposer(
            $db: $db,
            $table: $db.reviewLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get turkish => $composableBuilder(
    column: $table.turkish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get root => $composableBuilder(
    column: $table.root,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suffixes => $composableBuilder(
    column: $table.suffixes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get turkish =>
      $composableBuilder(column: $table.turkish, builder: (column) => column);

  GeneratedColumn<String> get root =>
      $composableBuilder(column: $table.root, builder: (column) => column);

  GeneratedColumn<String> get suffixes =>
      $composableBuilder(column: $table.suffixes, builder: (column) => column);

  GeneratedColumn<String> get english =>
      $composableBuilder(column: $table.english, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> practiceStatesRefs<T extends Object>(
    Expression<T> Function($$PracticeStatesTableAnnotationComposer a) f,
  ) {
    final $$PracticeStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceStates,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reviewLogRefs<T extends Object>(
    Expression<T> Function($$ReviewLogTableAnnotationComposer a) f,
  ) {
    final $$ReviewLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLog,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, $$WordsTableReferences),
          Word,
          PrefetchHooks Function({bool practiceStatesRefs, bool reviewLogRefs})
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> turkish = const Value.absent(),
                Value<String> root = const Value.absent(),
                Value<String> suffixes = const Value.absent(),
                Value<String> english = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                turkish: turkish,
                root: root,
                suffixes: suffixes,
                english: english,
                note: note,
                source: source,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String turkish,
                Value<String> root = const Value.absent(),
                Value<String> suffixes = const Value.absent(),
                required String english,
                Value<String?> note = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                turkish: turkish,
                root: root,
                suffixes: suffixes,
                english: english,
                note: note,
                source: source,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordsTable, Word>(table),
                  $$WordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({practiceStatesRefs = false, reviewLogRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (practiceStatesRefs) db.practiceStates,
                    if (reviewLogRefs) db.reviewLog,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (practiceStatesRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          PracticeState
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._practiceStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).practiceStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reviewLogRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          ReviewLogData
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._reviewLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, $$WordsTableReferences),
      Word,
      PrefetchHooks Function({bool practiceStatesRefs, bool reviewLogRefs})
    >;
typedef $$PracticeStatesTableCreateCompanionBuilder =
    PracticeStatesCompanion Function({
      Value<int> id,
      required int wordId,
      required String mode,
      Value<double> intervalDays,
      Value<double> easeFactor,
      Value<int> repetitions,
      required DateTime dueAt,
      Value<DateTime?> lastReviewedAt,
    });
typedef $$PracticeStatesTableUpdateCompanionBuilder =
    PracticeStatesCompanion Function({
      Value<int> id,
      Value<int> wordId,
      Value<String> mode,
      Value<double> intervalDays,
      Value<double> easeFactor,
      Value<int> repetitions,
      Value<DateTime> dueAt,
      Value<DateTime?> lastReviewedAt,
    });

final class $$PracticeStatesTableReferences
    extends BaseReferences<_$AppDatabase, $PracticeStatesTable, PracticeState> {
  $$PracticeStatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('practice_states__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PracticeStatesTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeStatesTable> {
  $$PracticeStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeStatesTable> {
  $$PracticeStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeStatesTable> {
  $$PracticeStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<double> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeStatesTable,
          PracticeState,
          $$PracticeStatesTableFilterComposer,
          $$PracticeStatesTableOrderingComposer,
          $$PracticeStatesTableAnnotationComposer,
          $$PracticeStatesTableCreateCompanionBuilder,
          $$PracticeStatesTableUpdateCompanionBuilder,
          (PracticeState, $$PracticeStatesTableReferences),
          PracticeState,
          PrefetchHooks Function({bool wordId})
        > {
  $$PracticeStatesTableTableManager(
    _$AppDatabase db,
    $PracticeStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<double> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
              }) => PracticeStatesCompanion(
                id: id,
                wordId: wordId,
                mode: mode,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                repetitions: repetitions,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wordId,
                required String mode,
                Value<double> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                required DateTime dueAt,
                Value<DateTime?> lastReviewedAt = const Value.absent(),
              }) => PracticeStatesCompanion.insert(
                id: id,
                wordId: wordId,
                mode: mode,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                repetitions: repetitions,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PracticeStatesTable, PracticeState>(table),
                  $$PracticeStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.wordId,
                        referencedTable: $$PracticeStatesTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$PracticeStatesTableReferences
                            ._wordIdTable(db)
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
        ),
      );
}

typedef $$PracticeStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeStatesTable,
      PracticeState,
      $$PracticeStatesTableFilterComposer,
      $$PracticeStatesTableOrderingComposer,
      $$PracticeStatesTableAnnotationComposer,
      $$PracticeStatesTableCreateCompanionBuilder,
      $$PracticeStatesTableUpdateCompanionBuilder,
      (PracticeState, $$PracticeStatesTableReferences),
      PracticeState,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$ReviewLogTableCreateCompanionBuilder = ReviewLogCompanion Function({
  Value<int> id,
  required int wordId,
  required String mode,
  required String result,
  Value<DateTime> reviewedAt,
});
typedef $$ReviewLogTableUpdateCompanionBuilder = ReviewLogCompanion Function({
  Value<int> id,
  Value<int> wordId,
  Value<String> mode,
  Value<String> result,
  Value<DateTime> reviewedAt,
});

final class $$ReviewLogTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewLogTable, ReviewLogData> {
  $$ReviewLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('review_log__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewLogTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogTable> {
  $$ReviewLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogTable> {
  $$ReviewLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogTable> {
  $$ReviewLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewLogTable,
          ReviewLogData,
          $$ReviewLogTableFilterComposer,
          $$ReviewLogTableOrderingComposer,
          $$ReviewLogTableAnnotationComposer,
          $$ReviewLogTableCreateCompanionBuilder,
          $$ReviewLogTableUpdateCompanionBuilder,
          (ReviewLogData, $$ReviewLogTableReferences),
          ReviewLogData,
          PrefetchHooks Function({bool wordId})
        > {
  $$ReviewLogTableTableManager(_$AppDatabase db, $ReviewLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
              }) => ReviewLogCompanion(
                id: id,
                wordId: wordId,
                mode: mode,
                result: result,
                reviewedAt: reviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wordId,
                required String mode,
                required String result,
                Value<DateTime> reviewedAt = const Value.absent(),
              }) => ReviewLogCompanion.insert(
                id: id,
                wordId: wordId,
                mode: mode,
                result: result,
                reviewedAt: reviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewLogTable, ReviewLogData>(table),
                  $$ReviewLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.wordId,
                        referencedTable: $$ReviewLogTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$ReviewLogTableReferences
                            ._wordIdTable(db)
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
        ),
      );
}

typedef $$ReviewLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewLogTable,
      ReviewLogData,
      $$ReviewLogTableFilterComposer,
      $$ReviewLogTableOrderingComposer,
      $$ReviewLogTableAnnotationComposer,
      $$ReviewLogTableCreateCompanionBuilder,
      $$ReviewLogTableUpdateCompanionBuilder,
      (ReviewLogData, $$ReviewLogTableReferences),
      ReviewLogData,
      PrefetchHooks Function({bool wordId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$PracticeStatesTableTableManager get practiceStates =>
      $$PracticeStatesTableTableManager(_db, _db.practiceStates);
  $$ReviewLogTableTableManager get reviewLog =>
      $$ReviewLogTableTableManager(_db, _db.reviewLog);
}
