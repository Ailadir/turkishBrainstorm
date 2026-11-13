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
  static const VerificationMeta _normalizedMeta = const VerificationMeta(
    'normalized',
  );
  @override
  late final GeneratedColumn<String> normalized = GeneratedColumn<String>(
    'normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _englishEditedMeta = const VerificationMeta(
    'englishEdited',
  );
  @override
  late final GeneratedColumn<bool> englishEdited = GeneratedColumn<bool>(
    'english_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("english_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('word'),
  );
  static const VerificationMeta _lemmaMeta = const VerificationMeta('lemma');
  @override
  late final GeneratedColumn<String> lemma = GeneratedColumn<String>(
    'lemma',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posMeta = const VerificationMeta('pos');
  @override
  late final GeneratedColumn<String> pos = GeneratedColumn<String>(
    'pos',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _morphemesMeta = const VerificationMeta(
    'morphemes',
  );
  @override
  late final GeneratedColumn<String> morphemes = GeneratedColumn<String>(
    'morphemes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
  static const VerificationMeta _noteEnMeta = const VerificationMeta('noteEn');
  @override
  late final GeneratedColumn<String> noteEn = GeneratedColumn<String>(
    'note_en',
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
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
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
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _needsAnalysisMeta = const VerificationMeta(
    'needsAnalysis',
  );
  @override
  late final GeneratedColumn<bool> needsAnalysis = GeneratedColumn<bool>(
    'needs_analysis',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_analysis" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    normalized,
    english,
    englishEdited,
    kind,
    lemma,
    pos,
    morphemes,
    note,
    noteEn,
    source,
    level,
    status,
    intervalDays,
    easeFactor,
    repetitions,
    lapses,
    dueAt,
    lastReviewedAt,
    needsAnalysis,
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
    if (data.containsKey('normalized')) {
      context.handle(
        _normalizedMeta,
        normalized.isAcceptableOrUnknown(data['normalized']!, _normalizedMeta),
      );
    } else if (isInserting) {
      context.missing(_normalizedMeta);
    }
    if (data.containsKey('english')) {
      context.handle(
        _englishMeta,
        english.isAcceptableOrUnknown(data['english']!, _englishMeta),
      );
    } else if (isInserting) {
      context.missing(_englishMeta);
    }
    if (data.containsKey('english_edited')) {
      context.handle(
        _englishEditedMeta,
        englishEdited.isAcceptableOrUnknown(
          data['english_edited']!,
          _englishEditedMeta,
        ),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('lemma')) {
      context.handle(
        _lemmaMeta,
        lemma.isAcceptableOrUnknown(data['lemma']!, _lemmaMeta),
      );
    }
    if (data.containsKey('pos')) {
      context.handle(
        _posMeta,
        pos.isAcceptableOrUnknown(data['pos']!, _posMeta),
      );
    }
    if (data.containsKey('morphemes')) {
      context.handle(
        _morphemesMeta,
        morphemes.isAcceptableOrUnknown(data['morphemes']!, _morphemesMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('note_en')) {
      context.handle(
        _noteEnMeta,
        noteEn.isAcceptableOrUnknown(data['note_en']!, _noteEnMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
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
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
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
    if (data.containsKey('needs_analysis')) {
      context.handle(
        _needsAnalysisMeta,
        needsAnalysis.isAcceptableOrUnknown(
          data['needs_analysis']!,
          _needsAnalysisMeta,
        ),
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
      normalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized'],
      )!,
      english: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english'],
      )!,
      englishEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}english_edited'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      lemma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lemma'],
      ),
      pos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pos'],
      ),
      morphemes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}morphemes'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      noteEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_en'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      needsAnalysis: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_analysis'],
      )!,
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

  /// The text as entered.
  final String turkish;

  /// `trNormalize(turkish)`; unique, used for de-duplication.
  final String normalized;
  final String english;

  /// True once the user typed/edited the English (packs must not overwrite it).
  final bool englishEdited;

  /// `word` | `phrase` | `sentence`.
  final String kind;
  final String? lemma;
  final String? pos;

  /// JSON `[{"s":"ler","id":"A3pl"}]` from Zemberek.
  final String morphemes;
  final String? note;
  final String? noteEn;
  final String? source;

  /// CEFR level `A1..B2`, set for pack words.
  final String? level;

  /// `new` | `learning` | `review` | `suspended`.
  final String status;
  final double intervalDays;
  final double easeFactor;
  final int repetitions;
  final int lapses;
  final DateTime? dueAt;
  final DateTime? lastReviewedAt;

  /// True until the background analysis job has filled lemma/pos/morphemes.
  final bool needsAnalysis;
  final DateTime createdAt;
  const Word({
    required this.id,
    required this.turkish,
    required this.normalized,
    required this.english,
    required this.englishEdited,
    required this.kind,
    this.lemma,
    this.pos,
    required this.morphemes,
    this.note,
    this.noteEn,
    this.source,
    this.level,
    required this.status,
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitions,
    required this.lapses,
    this.dueAt,
    this.lastReviewedAt,
    required this.needsAnalysis,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['turkish'] = Variable<String>(turkish);
    map['normalized'] = Variable<String>(normalized);
    map['english'] = Variable<String>(english);
    map['english_edited'] = Variable<bool>(englishEdited);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || lemma != null) {
      map['lemma'] = Variable<String>(lemma);
    }
    if (!nullToAbsent || pos != null) {
      map['pos'] = Variable<String>(pos);
    }
    map['morphemes'] = Variable<String>(morphemes);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || noteEn != null) {
      map['note_en'] = Variable<String>(noteEn);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(level);
    }
    map['status'] = Variable<String>(status);
    map['interval_days'] = Variable<double>(intervalDays);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['repetitions'] = Variable<int>(repetitions);
    map['lapses'] = Variable<int>(lapses);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['needs_analysis'] = Variable<bool>(needsAnalysis);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      turkish: Value(turkish),
      normalized: Value(normalized),
      english: Value(english),
      englishEdited: Value(englishEdited),
      kind: Value(kind),
      lemma: lemma == null && nullToAbsent
          ? const Value.absent()
          : Value(lemma),
      pos: pos == null && nullToAbsent ? const Value.absent() : Value(pos),
      morphemes: Value(morphemes),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      noteEn: noteEn == null && nullToAbsent
          ? const Value.absent()
          : Value(noteEn),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      status: Value(status),
      intervalDays: Value(intervalDays),
      easeFactor: Value(easeFactor),
      repetitions: Value(repetitions),
      lapses: Value(lapses),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      needsAnalysis: Value(needsAnalysis),
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
      normalized: serializer.fromJson<String>(json['normalized']),
      english: serializer.fromJson<String>(json['english']),
      englishEdited: serializer.fromJson<bool>(json['englishEdited']),
      kind: serializer.fromJson<String>(json['kind']),
      lemma: serializer.fromJson<String?>(json['lemma']),
      pos: serializer.fromJson<String?>(json['pos']),
      morphemes: serializer.fromJson<String>(json['morphemes']),
      note: serializer.fromJson<String?>(json['note']),
      noteEn: serializer.fromJson<String?>(json['noteEn']),
      source: serializer.fromJson<String?>(json['source']),
      level: serializer.fromJson<String?>(json['level']),
      status: serializer.fromJson<String>(json['status']),
      intervalDays: serializer.fromJson<double>(json['intervalDays']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      lapses: serializer.fromJson<int>(json['lapses']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      needsAnalysis: serializer.fromJson<bool>(json['needsAnalysis']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'turkish': serializer.toJson<String>(turkish),
      'normalized': serializer.toJson<String>(normalized),
      'english': serializer.toJson<String>(english),
      'englishEdited': serializer.toJson<bool>(englishEdited),
      'kind': serializer.toJson<String>(kind),
      'lemma': serializer.toJson<String?>(lemma),
      'pos': serializer.toJson<String?>(pos),
      'morphemes': serializer.toJson<String>(morphemes),
      'note': serializer.toJson<String?>(note),
      'noteEn': serializer.toJson<String?>(noteEn),
      'source': serializer.toJson<String?>(source),
      'level': serializer.toJson<String?>(level),
      'status': serializer.toJson<String>(status),
      'intervalDays': serializer.toJson<double>(intervalDays),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'repetitions': serializer.toJson<int>(repetitions),
      'lapses': serializer.toJson<int>(lapses),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'needsAnalysis': serializer.toJson<bool>(needsAnalysis),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Word copyWith({
    int? id,
    String? turkish,
    String? normalized,
    String? english,
    bool? englishEdited,
    String? kind,
    Value<String?> lemma = const Value.absent(),
    Value<String?> pos = const Value.absent(),
    String? morphemes,
    Value<String?> note = const Value.absent(),
    Value<String?> noteEn = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> level = const Value.absent(),
    String? status,
    double? intervalDays,
    double? easeFactor,
    int? repetitions,
    int? lapses,
    Value<DateTime?> dueAt = const Value.absent(),
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    bool? needsAnalysis,
    DateTime? createdAt,
  }) => Word(
    id: id ?? this.id,
    turkish: turkish ?? this.turkish,
    normalized: normalized ?? this.normalized,
    english: english ?? this.english,
    englishEdited: englishEdited ?? this.englishEdited,
    kind: kind ?? this.kind,
    lemma: lemma.present ? lemma.value : this.lemma,
    pos: pos.present ? pos.value : this.pos,
    morphemes: morphemes ?? this.morphemes,
    note: note.present ? note.value : this.note,
    noteEn: noteEn.present ? noteEn.value : this.noteEn,
    source: source.present ? source.value : this.source,
    level: level.present ? level.value : this.level,
    status: status ?? this.status,
    intervalDays: intervalDays ?? this.intervalDays,
    easeFactor: easeFactor ?? this.easeFactor,
    repetitions: repetitions ?? this.repetitions,
    lapses: lapses ?? this.lapses,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    needsAnalysis: needsAnalysis ?? this.needsAnalysis,
    createdAt: createdAt ?? this.createdAt,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      turkish: data.turkish.present ? data.turkish.value : this.turkish,
      normalized: data.normalized.present
          ? data.normalized.value
          : this.normalized,
      english: data.english.present ? data.english.value : this.english,
      englishEdited: data.englishEdited.present
          ? data.englishEdited.value
          : this.englishEdited,
      kind: data.kind.present ? data.kind.value : this.kind,
      lemma: data.lemma.present ? data.lemma.value : this.lemma,
      pos: data.pos.present ? data.pos.value : this.pos,
      morphemes: data.morphemes.present ? data.morphemes.value : this.morphemes,
      note: data.note.present ? data.note.value : this.note,
      noteEn: data.noteEn.present ? data.noteEn.value : this.noteEn,
      source: data.source.present ? data.source.value : this.source,
      level: data.level.present ? data.level.value : this.level,
      status: data.status.present ? data.status.value : this.status,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      needsAnalysis: data.needsAnalysis.present
          ? data.needsAnalysis.value
          : this.needsAnalysis,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('turkish: $turkish, ')
          ..write('normalized: $normalized, ')
          ..write('english: $english, ')
          ..write('englishEdited: $englishEdited, ')
          ..write('kind: $kind, ')
          ..write('lemma: $lemma, ')
          ..write('pos: $pos, ')
          ..write('morphemes: $morphemes, ')
          ..write('note: $note, ')
          ..write('noteEn: $noteEn, ')
          ..write('source: $source, ')
          ..write('level: $level, ')
          ..write('status: $status, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('lapses: $lapses, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('needsAnalysis: $needsAnalysis, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    turkish,
    normalized,
    english,
    englishEdited,
    kind,
    lemma,
    pos,
    morphemes,
    note,
    noteEn,
    source,
    level,
    status,
    intervalDays,
    easeFactor,
    repetitions,
    lapses,
    dueAt,
    lastReviewedAt,
    needsAnalysis,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.turkish == this.turkish &&
          other.normalized == this.normalized &&
          other.english == this.english &&
          other.englishEdited == this.englishEdited &&
          other.kind == this.kind &&
          other.lemma == this.lemma &&
          other.pos == this.pos &&
          other.morphemes == this.morphemes &&
          other.note == this.note &&
          other.noteEn == this.noteEn &&
          other.source == this.source &&
          other.level == this.level &&
          other.status == this.status &&
          other.intervalDays == this.intervalDays &&
          other.easeFactor == this.easeFactor &&
          other.repetitions == this.repetitions &&
          other.lapses == this.lapses &&
          other.dueAt == this.dueAt &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.needsAnalysis == this.needsAnalysis &&
          other.createdAt == this.createdAt);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> turkish;
  final Value<String> normalized;
  final Value<String> english;
  final Value<bool> englishEdited;
  final Value<String> kind;
  final Value<String?> lemma;
  final Value<String?> pos;
  final Value<String> morphemes;
  final Value<String?> note;
  final Value<String?> noteEn;
  final Value<String?> source;
  final Value<String?> level;
  final Value<String> status;
  final Value<double> intervalDays;
  final Value<double> easeFactor;
  final Value<int> repetitions;
  final Value<int> lapses;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> lastReviewedAt;
  final Value<bool> needsAnalysis;
  final Value<DateTime> createdAt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.turkish = const Value.absent(),
    this.normalized = const Value.absent(),
    this.english = const Value.absent(),
    this.englishEdited = const Value.absent(),
    this.kind = const Value.absent(),
    this.lemma = const Value.absent(),
    this.pos = const Value.absent(),
    this.morphemes = const Value.absent(),
    this.note = const Value.absent(),
    this.noteEn = const Value.absent(),
    this.source = const Value.absent(),
    this.level = const Value.absent(),
    this.status = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lapses = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.needsAnalysis = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String turkish,
    required String normalized,
    required String english,
    this.englishEdited = const Value.absent(),
    this.kind = const Value.absent(),
    this.lemma = const Value.absent(),
    this.pos = const Value.absent(),
    this.morphemes = const Value.absent(),
    this.note = const Value.absent(),
    this.noteEn = const Value.absent(),
    this.source = const Value.absent(),
    this.level = const Value.absent(),
    this.status = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lapses = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.needsAnalysis = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : turkish = Value(turkish),
       normalized = Value(normalized),
       english = Value(english);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? turkish,
    Expression<String>? normalized,
    Expression<String>? english,
    Expression<bool>? englishEdited,
    Expression<String>? kind,
    Expression<String>? lemma,
    Expression<String>? pos,
    Expression<String>? morphemes,
    Expression<String>? note,
    Expression<String>? noteEn,
    Expression<String>? source,
    Expression<String>? level,
    Expression<String>? status,
    Expression<double>? intervalDays,
    Expression<double>? easeFactor,
    Expression<int>? repetitions,
    Expression<int>? lapses,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<bool>? needsAnalysis,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (turkish != null) 'turkish': turkish,
      if (normalized != null) 'normalized': normalized,
      if (english != null) 'english': english,
      if (englishEdited != null) 'english_edited': englishEdited,
      if (kind != null) 'kind': kind,
      if (lemma != null) 'lemma': lemma,
      if (pos != null) 'pos': pos,
      if (morphemes != null) 'morphemes': morphemes,
      if (note != null) 'note': note,
      if (noteEn != null) 'note_en': noteEn,
      if (source != null) 'source': source,
      if (level != null) 'level': level,
      if (status != null) 'status': status,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (repetitions != null) 'repetitions': repetitions,
      if (lapses != null) 'lapses': lapses,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (needsAnalysis != null) 'needs_analysis': needsAnalysis,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? turkish,
    Value<String>? normalized,
    Value<String>? english,
    Value<bool>? englishEdited,
    Value<String>? kind,
    Value<String?>? lemma,
    Value<String?>? pos,
    Value<String>? morphemes,
    Value<String?>? note,
    Value<String?>? noteEn,
    Value<String?>? source,
    Value<String?>? level,
    Value<String>? status,
    Value<double>? intervalDays,
    Value<double>? easeFactor,
    Value<int>? repetitions,
    Value<int>? lapses,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? lastReviewedAt,
    Value<bool>? needsAnalysis,
    Value<DateTime>? createdAt,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      turkish: turkish ?? this.turkish,
      normalized: normalized ?? this.normalized,
      english: english ?? this.english,
      englishEdited: englishEdited ?? this.englishEdited,
      kind: kind ?? this.kind,
      lemma: lemma ?? this.lemma,
      pos: pos ?? this.pos,
      morphemes: morphemes ?? this.morphemes,
      note: note ?? this.note,
      noteEn: noteEn ?? this.noteEn,
      source: source ?? this.source,
      level: level ?? this.level,
      status: status ?? this.status,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      lapses: lapses ?? this.lapses,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      needsAnalysis: needsAnalysis ?? this.needsAnalysis,
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
    if (normalized.present) {
      map['normalized'] = Variable<String>(normalized.value);
    }
    if (english.present) {
      map['english'] = Variable<String>(english.value);
    }
    if (englishEdited.present) {
      map['english_edited'] = Variable<bool>(englishEdited.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (lemma.present) {
      map['lemma'] = Variable<String>(lemma.value);
    }
    if (pos.present) {
      map['pos'] = Variable<String>(pos.value);
    }
    if (morphemes.present) {
      map['morphemes'] = Variable<String>(morphemes.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (noteEn.present) {
      map['note_en'] = Variable<String>(noteEn.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (needsAnalysis.present) {
      map['needs_analysis'] = Variable<bool>(needsAnalysis.value);
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
          ..write('normalized: $normalized, ')
          ..write('english: $english, ')
          ..write('englishEdited: $englishEdited, ')
          ..write('kind: $kind, ')
          ..write('lemma: $lemma, ')
          ..write('pos: $pos, ')
          ..write('morphemes: $morphemes, ')
          ..write('note: $note, ')
          ..write('noteEn: $noteEn, ')
          ..write('source: $source, ')
          ..write('level: $level, ')
          ..write('status: $status, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('lapses: $lapses, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('needsAnalysis: $needsAnalysis, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WordMorphemesTable extends WordMorphemes
    with TableInfo<$WordMorphemesTable, WordMorpheme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordMorphemesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _morphemeIdMeta = const VerificationMeta(
    'morphemeId',
  );
  @override
  late final GeneratedColumn<String> morphemeId = GeneratedColumn<String>(
    'morpheme_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surfaceMeta = const VerificationMeta(
    'surface',
  );
  @override
  late final GeneratedColumn<String> surface = GeneratedColumn<String>(
    'surface',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [wordId, morphemeId, surface, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_morphemes';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordMorpheme> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('morpheme_id')) {
      context.handle(
        _morphemeIdMeta,
        morphemeId.isAcceptableOrUnknown(data['morpheme_id']!, _morphemeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_morphemeIdMeta);
    }
    if (data.containsKey('surface')) {
      context.handle(
        _surfaceMeta,
        surface.isAcceptableOrUnknown(data['surface']!, _surfaceMeta),
      );
    } else if (isInserting) {
      context.missing(_surfaceMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId, position};
  @override
  WordMorpheme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordMorpheme(
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      morphemeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}morpheme_id'],
      )!,
      surface: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $WordMorphemesTable createAlias(String alias) {
    return $WordMorphemesTable(attachedDatabase, alias);
  }
}

class WordMorpheme extends DataClass implements Insertable<WordMorpheme> {
  final int wordId;
  final String morphemeId;
  final String surface;
  final int position;
  const WordMorpheme({
    required this.wordId,
    required this.morphemeId,
    required this.surface,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    map['morpheme_id'] = Variable<String>(morphemeId);
    map['surface'] = Variable<String>(surface);
    map['position'] = Variable<int>(position);
    return map;
  }

  WordMorphemesCompanion toCompanion(bool nullToAbsent) {
    return WordMorphemesCompanion(
      wordId: Value(wordId),
      morphemeId: Value(morphemeId),
      surface: Value(surface),
      position: Value(position),
    );
  }

  factory WordMorpheme.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordMorpheme(
      wordId: serializer.fromJson<int>(json['wordId']),
      morphemeId: serializer.fromJson<String>(json['morphemeId']),
      surface: serializer.fromJson<String>(json['surface']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'morphemeId': serializer.toJson<String>(morphemeId),
      'surface': serializer.toJson<String>(surface),
      'position': serializer.toJson<int>(position),
    };
  }

  WordMorpheme copyWith({
    int? wordId,
    String? morphemeId,
    String? surface,
    int? position,
  }) => WordMorpheme(
    wordId: wordId ?? this.wordId,
    morphemeId: morphemeId ?? this.morphemeId,
    surface: surface ?? this.surface,
    position: position ?? this.position,
  );
  WordMorpheme copyWithCompanion(WordMorphemesCompanion data) {
    return WordMorpheme(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      morphemeId: data.morphemeId.present
          ? data.morphemeId.value
          : this.morphemeId,
      surface: data.surface.present ? data.surface.value : this.surface,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordMorpheme(')
          ..write('wordId: $wordId, ')
          ..write('morphemeId: $morphemeId, ')
          ..write('surface: $surface, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordId, morphemeId, surface, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordMorpheme &&
          other.wordId == this.wordId &&
          other.morphemeId == this.morphemeId &&
          other.surface == this.surface &&
          other.position == this.position);
}

class WordMorphemesCompanion extends UpdateCompanion<WordMorpheme> {
  final Value<int> wordId;
  final Value<String> morphemeId;
  final Value<String> surface;
  final Value<int> position;
  final Value<int> rowid;
  const WordMorphemesCompanion({
    this.wordId = const Value.absent(),
    this.morphemeId = const Value.absent(),
    this.surface = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordMorphemesCompanion.insert({
    required int wordId,
    required String morphemeId,
    required String surface,
    required int position,
    this.rowid = const Value.absent(),
  }) : wordId = Value(wordId),
       morphemeId = Value(morphemeId),
       surface = Value(surface),
       position = Value(position);
  static Insertable<WordMorpheme> custom({
    Expression<int>? wordId,
    Expression<String>? morphemeId,
    Expression<String>? surface,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (morphemeId != null) 'morpheme_id': morphemeId,
      if (surface != null) 'surface': surface,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordMorphemesCompanion copyWith({
    Value<int>? wordId,
    Value<String>? morphemeId,
    Value<String>? surface,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return WordMorphemesCompanion(
      wordId: wordId ?? this.wordId,
      morphemeId: morphemeId ?? this.morphemeId,
      surface: surface ?? this.surface,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (morphemeId.present) {
      map['morpheme_id'] = Variable<String>(morphemeId.value);
    }
    if (surface.present) {
      map['surface'] = Variable<String>(surface.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordMorphemesCompanion(')
          ..write('wordId: $wordId, ')
          ..write('morphemeId: $morphemeId, ')
          ..write('surface: $surface, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MorphemesTable extends Morphemes
    with TableInfo<$MorphemesTable, Morpheme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MorphemesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
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
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    status,
    intervalDays,
    easeFactor,
    repetitions,
    lapses,
    dueAt,
    lastReviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'morphemes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Morpheme> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
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
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
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
  Morpheme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Morpheme(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
    );
  }

  @override
  $MorphemesTable createAlias(String alias) {
    return $MorphemesTable(attachedDatabase, alias);
  }
}

class Morpheme extends DataClass implements Insertable<Morpheme> {
  final String id;
  final String status;
  final double intervalDays;
  final double easeFactor;
  final int repetitions;
  final int lapses;
  final DateTime? dueAt;
  final DateTime? lastReviewedAt;
  const Morpheme({
    required this.id,
    required this.status,
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitions,
    required this.lapses,
    this.dueAt,
    this.lastReviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<String>(status);
    map['interval_days'] = Variable<double>(intervalDays);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['repetitions'] = Variable<int>(repetitions);
    map['lapses'] = Variable<int>(lapses);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    return map;
  }

  MorphemesCompanion toCompanion(bool nullToAbsent) {
    return MorphemesCompanion(
      id: Value(id),
      status: Value(status),
      intervalDays: Value(intervalDays),
      easeFactor: Value(easeFactor),
      repetitions: Value(repetitions),
      lapses: Value(lapses),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
    );
  }

  factory Morpheme.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Morpheme(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      intervalDays: serializer.fromJson<double>(json['intervalDays']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      lapses: serializer.fromJson<int>(json['lapses']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(status),
      'intervalDays': serializer.toJson<double>(intervalDays),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'repetitions': serializer.toJson<int>(repetitions),
      'lapses': serializer.toJson<int>(lapses),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
    };
  }

  Morpheme copyWith({
    String? id,
    String? status,
    double? intervalDays,
    double? easeFactor,
    int? repetitions,
    int? lapses,
    Value<DateTime?> dueAt = const Value.absent(),
    Value<DateTime?> lastReviewedAt = const Value.absent(),
  }) => Morpheme(
    id: id ?? this.id,
    status: status ?? this.status,
    intervalDays: intervalDays ?? this.intervalDays,
    easeFactor: easeFactor ?? this.easeFactor,
    repetitions: repetitions ?? this.repetitions,
    lapses: lapses ?? this.lapses,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
  );
  Morpheme copyWithCompanion(MorphemesCompanion data) {
    return Morpheme(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Morpheme(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('lapses: $lapses, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    intervalDays,
    easeFactor,
    repetitions,
    lapses,
    dueAt,
    lastReviewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Morpheme &&
          other.id == this.id &&
          other.status == this.status &&
          other.intervalDays == this.intervalDays &&
          other.easeFactor == this.easeFactor &&
          other.repetitions == this.repetitions &&
          other.lapses == this.lapses &&
          other.dueAt == this.dueAt &&
          other.lastReviewedAt == this.lastReviewedAt);
}

class MorphemesCompanion extends UpdateCompanion<Morpheme> {
  final Value<String> id;
  final Value<String> status;
  final Value<double> intervalDays;
  final Value<double> easeFactor;
  final Value<int> repetitions;
  final Value<int> lapses;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> lastReviewedAt;
  final Value<int> rowid;
  const MorphemesCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lapses = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MorphemesCompanion.insert({
    required String id,
    this.status = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lapses = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Morpheme> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<double>? intervalDays,
    Expression<double>? easeFactor,
    Expression<int>? repetitions,
    Expression<int>? lapses,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (repetitions != null) 'repetitions': repetitions,
      if (lapses != null) 'lapses': lapses,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MorphemesCompanion copyWith({
    Value<String>? id,
    Value<String>? status,
    Value<double>? intervalDays,
    Value<double>? easeFactor,
    Value<int>? repetitions,
    Value<int>? lapses,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? lastReviewedAt,
    Value<int>? rowid,
  }) {
    return MorphemesCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      lapses: lapses ?? this.lapses,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MorphemesCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('lapses: $lapses, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PacksTable extends Packs with TableInfo<$PacksTable, Pack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    level,
    kind,
    version,
    installedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
    );
  }

  @override
  $PacksTable createAlias(String alias) {
    return $PacksTable(attachedDatabase, alias);
  }
}

class Pack extends DataClass implements Insertable<Pack> {
  final String id;
  final String title;
  final String? level;

  /// `words` | `grammar`.
  final String kind;
  final int version;
  final DateTime installedAt;
  const Pack({
    required this.id,
    required this.title,
    this.level,
    required this.kind,
    required this.version,
    required this.installedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(level);
    }
    map['kind'] = Variable<String>(kind);
    map['version'] = Variable<int>(version);
    map['installed_at'] = Variable<DateTime>(installedAt);
    return map;
  }

  PacksCompanion toCompanion(bool nullToAbsent) {
    return PacksCompanion(
      id: Value(id),
      title: Value(title),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      kind: Value(kind),
      version: Value(version),
      installedAt: Value(installedAt),
    );
  }

  factory Pack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pack(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      level: serializer.fromJson<String?>(json['level']),
      kind: serializer.fromJson<String>(json['kind']),
      version: serializer.fromJson<int>(json['version']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'level': serializer.toJson<String?>(level),
      'kind': serializer.toJson<String>(kind),
      'version': serializer.toJson<int>(version),
      'installedAt': serializer.toJson<DateTime>(installedAt),
    };
  }

  Pack copyWith({
    String? id,
    String? title,
    Value<String?> level = const Value.absent(),
    String? kind,
    int? version,
    DateTime? installedAt,
  }) => Pack(
    id: id ?? this.id,
    title: title ?? this.title,
    level: level.present ? level.value : this.level,
    kind: kind ?? this.kind,
    version: version ?? this.version,
    installedAt: installedAt ?? this.installedAt,
  );
  Pack copyWithCompanion(PacksCompanion data) {
    return Pack(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      level: data.level.present ? data.level.value : this.level,
      kind: data.kind.present ? data.kind.value : this.kind,
      version: data.version.present ? data.version.value : this.version,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pack(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('kind: $kind, ')
          ..write('version: $version, ')
          ..write('installedAt: $installedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, level, kind, version, installedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pack &&
          other.id == this.id &&
          other.title == this.title &&
          other.level == this.level &&
          other.kind == this.kind &&
          other.version == this.version &&
          other.installedAt == this.installedAt);
}

class PacksCompanion extends UpdateCompanion<Pack> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> level;
  final Value<String> kind;
  final Value<int> version;
  final Value<DateTime> installedAt;
  final Value<int> rowid;
  const PacksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.level = const Value.absent(),
    this.kind = const Value.absent(),
    this.version = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PacksCompanion.insert({
    required String id,
    required String title,
    this.level = const Value.absent(),
    required String kind,
    required int version,
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       kind = Value(kind),
       version = Value(version);
  static Insertable<Pack> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? level,
    Expression<String>? kind,
    Expression<int>? version,
    Expression<DateTime>? installedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (level != null) 'level': level,
      if (kind != null) 'kind': kind,
      if (version != null) 'version': version,
      if (installedAt != null) 'installed_at': installedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PacksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? level,
    Value<String>? kind,
    Value<int>? version,
    Value<DateTime>? installedAt,
    Value<int>? rowid,
  }) {
    return PacksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      kind: kind ?? this.kind,
      version: version ?? this.version,
      installedAt: installedAt ?? this.installedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PacksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('kind: $kind, ')
          ..write('version: $version, ')
          ..write('installedAt: $installedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MorphemeExamplesTable extends MorphemeExamples
    with TableInfo<$MorphemeExamplesTable, MorphemeExample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MorphemeExamplesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _morphemeIdMeta = const VerificationMeta(
    'morphemeId',
  );
  @override
  late final GeneratedColumn<String> morphemeId = GeneratedColumn<String>(
    'morpheme_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES packs (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    morphemeId,
    turkish,
    english,
    packId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'morpheme_examples';
  @override
  VerificationContext validateIntegrity(
    Insertable<MorphemeExample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('morpheme_id')) {
      context.handle(
        _morphemeIdMeta,
        morphemeId.isAcceptableOrUnknown(data['morpheme_id']!, _morphemeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_morphemeIdMeta);
    }
    if (data.containsKey('turkish')) {
      context.handle(
        _turkishMeta,
        turkish.isAcceptableOrUnknown(data['turkish']!, _turkishMeta),
      );
    } else if (isInserting) {
      context.missing(_turkishMeta);
    }
    if (data.containsKey('english')) {
      context.handle(
        _englishMeta,
        english.isAcceptableOrUnknown(data['english']!, _englishMeta),
      );
    } else if (isInserting) {
      context.missing(_englishMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MorphemeExample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MorphemeExample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      morphemeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}morpheme_id'],
      )!,
      turkish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}turkish'],
      )!,
      english: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
    );
  }

  @override
  $MorphemeExamplesTable createAlias(String alias) {
    return $MorphemeExamplesTable(attachedDatabase, alias);
  }
}

class MorphemeExample extends DataClass implements Insertable<MorphemeExample> {
  final int id;
  final String morphemeId;
  final String turkish;
  final String english;
  final String packId;
  const MorphemeExample({
    required this.id,
    required this.morphemeId,
    required this.turkish,
    required this.english,
    required this.packId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['morpheme_id'] = Variable<String>(morphemeId);
    map['turkish'] = Variable<String>(turkish);
    map['english'] = Variable<String>(english);
    map['pack_id'] = Variable<String>(packId);
    return map;
  }

  MorphemeExamplesCompanion toCompanion(bool nullToAbsent) {
    return MorphemeExamplesCompanion(
      id: Value(id),
      morphemeId: Value(morphemeId),
      turkish: Value(turkish),
      english: Value(english),
      packId: Value(packId),
    );
  }

  factory MorphemeExample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MorphemeExample(
      id: serializer.fromJson<int>(json['id']),
      morphemeId: serializer.fromJson<String>(json['morphemeId']),
      turkish: serializer.fromJson<String>(json['turkish']),
      english: serializer.fromJson<String>(json['english']),
      packId: serializer.fromJson<String>(json['packId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'morphemeId': serializer.toJson<String>(morphemeId),
      'turkish': serializer.toJson<String>(turkish),
      'english': serializer.toJson<String>(english),
      'packId': serializer.toJson<String>(packId),
    };
  }

  MorphemeExample copyWith({
    int? id,
    String? morphemeId,
    String? turkish,
    String? english,
    String? packId,
  }) => MorphemeExample(
    id: id ?? this.id,
    morphemeId: morphemeId ?? this.morphemeId,
    turkish: turkish ?? this.turkish,
    english: english ?? this.english,
    packId: packId ?? this.packId,
  );
  MorphemeExample copyWithCompanion(MorphemeExamplesCompanion data) {
    return MorphemeExample(
      id: data.id.present ? data.id.value : this.id,
      morphemeId: data.morphemeId.present
          ? data.morphemeId.value
          : this.morphemeId,
      turkish: data.turkish.present ? data.turkish.value : this.turkish,
      english: data.english.present ? data.english.value : this.english,
      packId: data.packId.present ? data.packId.value : this.packId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MorphemeExample(')
          ..write('id: $id, ')
          ..write('morphemeId: $morphemeId, ')
          ..write('turkish: $turkish, ')
          ..write('english: $english, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, morphemeId, turkish, english, packId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MorphemeExample &&
          other.id == this.id &&
          other.morphemeId == this.morphemeId &&
          other.turkish == this.turkish &&
          other.english == this.english &&
          other.packId == this.packId);
}

class MorphemeExamplesCompanion extends UpdateCompanion<MorphemeExample> {
  final Value<int> id;
  final Value<String> morphemeId;
  final Value<String> turkish;
  final Value<String> english;
  final Value<String> packId;
  const MorphemeExamplesCompanion({
    this.id = const Value.absent(),
    this.morphemeId = const Value.absent(),
    this.turkish = const Value.absent(),
    this.english = const Value.absent(),
    this.packId = const Value.absent(),
  });
  MorphemeExamplesCompanion.insert({
    this.id = const Value.absent(),
    required String morphemeId,
    required String turkish,
    required String english,
    required String packId,
  }) : morphemeId = Value(morphemeId),
       turkish = Value(turkish),
       english = Value(english),
       packId = Value(packId);
  static Insertable<MorphemeExample> custom({
    Expression<int>? id,
    Expression<String>? morphemeId,
    Expression<String>? turkish,
    Expression<String>? english,
    Expression<String>? packId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (morphemeId != null) 'morpheme_id': morphemeId,
      if (turkish != null) 'turkish': turkish,
      if (english != null) 'english': english,
      if (packId != null) 'pack_id': packId,
    });
  }

  MorphemeExamplesCompanion copyWith({
    Value<int>? id,
    Value<String>? morphemeId,
    Value<String>? turkish,
    Value<String>? english,
    Value<String>? packId,
  }) {
    return MorphemeExamplesCompanion(
      id: id ?? this.id,
      morphemeId: morphemeId ?? this.morphemeId,
      turkish: turkish ?? this.turkish,
      english: english ?? this.english,
      packId: packId ?? this.packId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (morphemeId.present) {
      map['morpheme_id'] = Variable<String>(morphemeId.value);
    }
    if (turkish.present) {
      map['turkish'] = Variable<String>(turkish.value);
    }
    if (english.present) {
      map['english'] = Variable<String>(english.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MorphemeExamplesCompanion(')
          ..write('id: $id, ')
          ..write('morphemeId: $morphemeId, ')
          ..write('turkish: $turkish, ')
          ..write('english: $english, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }
}

class $WordPacksTable extends WordPacks
    with TableInfo<$WordPacksTable, WordPack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordPacksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES packs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [wordId, packId, rank];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordPack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    } else if (isInserting) {
      context.missing(_rankMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId, packId};
  @override
  WordPack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordPack(
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
    );
  }

  @override
  $WordPacksTable createAlias(String alias) {
    return $WordPacksTable(attachedDatabase, alias);
  }
}

class WordPack extends DataClass implements Insertable<WordPack> {
  final int wordId;
  final String packId;
  final int rank;
  const WordPack({
    required this.wordId,
    required this.packId,
    required this.rank,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    map['pack_id'] = Variable<String>(packId);
    map['rank'] = Variable<int>(rank);
    return map;
  }

  WordPacksCompanion toCompanion(bool nullToAbsent) {
    return WordPacksCompanion(
      wordId: Value(wordId),
      packId: Value(packId),
      rank: Value(rank),
    );
  }

  factory WordPack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordPack(
      wordId: serializer.fromJson<int>(json['wordId']),
      packId: serializer.fromJson<String>(json['packId']),
      rank: serializer.fromJson<int>(json['rank']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'packId': serializer.toJson<String>(packId),
      'rank': serializer.toJson<int>(rank),
    };
  }

  WordPack copyWith({int? wordId, String? packId, int? rank}) => WordPack(
    wordId: wordId ?? this.wordId,
    packId: packId ?? this.packId,
    rank: rank ?? this.rank,
  );
  WordPack copyWithCompanion(WordPacksCompanion data) {
    return WordPack(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      packId: data.packId.present ? data.packId.value : this.packId,
      rank: data.rank.present ? data.rank.value : this.rank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordPack(')
          ..write('wordId: $wordId, ')
          ..write('packId: $packId, ')
          ..write('rank: $rank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordId, packId, rank);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordPack &&
          other.wordId == this.wordId &&
          other.packId == this.packId &&
          other.rank == this.rank);
}

class WordPacksCompanion extends UpdateCompanion<WordPack> {
  final Value<int> wordId;
  final Value<String> packId;
  final Value<int> rank;
  final Value<int> rowid;
  const WordPacksCompanion({
    this.wordId = const Value.absent(),
    this.packId = const Value.absent(),
    this.rank = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordPacksCompanion.insert({
    required int wordId,
    required String packId,
    required int rank,
    this.rowid = const Value.absent(),
  }) : wordId = Value(wordId),
       packId = Value(packId),
       rank = Value(rank);
  static Insertable<WordPack> custom({
    Expression<int>? wordId,
    Expression<String>? packId,
    Expression<int>? rank,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (packId != null) 'pack_id': packId,
      if (rank != null) 'rank': rank,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordPacksCompanion copyWith({
    Value<int>? wordId,
    Value<String>? packId,
    Value<int>? rank,
    Value<int>? rowid,
  }) {
    return WordPacksCompanion(
      wordId: wordId ?? this.wordId,
      packId: packId ?? this.packId,
      rank: rank ?? this.rank,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordPacksCompanion(')
          ..write('wordId: $wordId, ')
          ..write('packId: $packId, ')
          ..write('rank: $rank, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranslationCacheTable extends TranslationCache
    with TableInfo<$TranslationCacheTable, TranslationCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [key, payload, provider, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translation_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranslationCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
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
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  TranslationCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationCacheData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TranslationCacheTable createAlias(String alias) {
    return $TranslationCacheTable(attachedDatabase, alias);
  }
}

class TranslationCacheData extends DataClass
    implements Insertable<TranslationCacheData> {
  final String key;
  final String payload;
  final String provider;
  final DateTime createdAt;
  const TranslationCacheData({
    required this.key,
    required this.payload,
    required this.provider,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    map['provider'] = Variable<String>(provider);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TranslationCacheCompanion toCompanion(bool nullToAbsent) {
    return TranslationCacheCompanion(
      key: Value(key),
      payload: Value(payload),
      provider: Value(provider),
      createdAt: Value(createdAt),
    );
  }

  factory TranslationCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationCacheData(
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
      provider: serializer.fromJson<String>(json['provider']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
      'provider': serializer.toJson<String>(provider),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TranslationCacheData copyWith({
    String? key,
    String? payload,
    String? provider,
    DateTime? createdAt,
  }) => TranslationCacheData(
    key: key ?? this.key,
    payload: payload ?? this.payload,
    provider: provider ?? this.provider,
    createdAt: createdAt ?? this.createdAt,
  );
  TranslationCacheData copyWithCompanion(TranslationCacheCompanion data) {
    return TranslationCacheData(
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
      provider: data.provider.present ? data.provider.value : this.provider,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationCacheData(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('provider: $provider, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, payload, provider, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationCacheData &&
          other.key == this.key &&
          other.payload == this.payload &&
          other.provider == this.provider &&
          other.createdAt == this.createdAt);
}

class TranslationCacheCompanion extends UpdateCompanion<TranslationCacheData> {
  final Value<String> key;
  final Value<String> payload;
  final Value<String> provider;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TranslationCacheCompanion({
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.provider = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranslationCacheCompanion.insert({
    required String key,
    required String payload,
    required String provider,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       payload = Value(payload),
       provider = Value(provider);
  static Insertable<TranslationCacheData> custom({
    Expression<String>? key,
    Expression<String>? payload,
    Expression<String>? provider,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (provider != null) 'provider': provider,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranslationCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? payload,
    Value<String>? provider,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TranslationCacheCompanion(
      key: key ?? this.key,
      payload: payload ?? this.payload,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationCacheCompanion(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('provider: $provider, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _morphemeIdMeta = const VerificationMeta(
    'morphemeId',
  );
  @override
  late final GeneratedColumn<String> morphemeId = GeneratedColumn<String>(
    'morpheme_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseMeta = const VerificationMeta(
    'exercise',
  );
  @override
  late final GeneratedColumn<String> exercise = GeneratedColumn<String>(
    'exercise',
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
  List<GeneratedColumn> get $columns => [
    id,
    wordId,
    morphemeId,
    exercise,
    result,
    reviewedAt,
  ];
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
    }
    if (data.containsKey('morpheme_id')) {
      context.handle(
        _morphemeIdMeta,
        morphemeId.isAcceptableOrUnknown(data['morpheme_id']!, _morphemeIdMeta),
      );
    }
    if (data.containsKey('exercise')) {
      context.handle(
        _exerciseMeta,
        exercise.isAcceptableOrUnknown(data['exercise']!, _exerciseMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseMeta);
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
      ),
      morphemeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}morpheme_id'],
      ),
      exercise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise'],
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
  final int? wordId;
  final String? morphemeId;

  /// [ExerciseType] name.
  final String exercise;

  /// [ReviewGrade] name, or `pass` / `fail` for Brainstorm.
  final String result;
  final DateTime reviewedAt;
  const ReviewLogData({
    required this.id,
    this.wordId,
    this.morphemeId,
    required this.exercise,
    required this.result,
    required this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || wordId != null) {
      map['word_id'] = Variable<int>(wordId);
    }
    if (!nullToAbsent || morphemeId != null) {
      map['morpheme_id'] = Variable<String>(morphemeId);
    }
    map['exercise'] = Variable<String>(exercise);
    map['result'] = Variable<String>(result);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    return map;
  }

  ReviewLogCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogCompanion(
      id: Value(id),
      wordId: wordId == null && nullToAbsent
          ? const Value.absent()
          : Value(wordId),
      morphemeId: morphemeId == null && nullToAbsent
          ? const Value.absent()
          : Value(morphemeId),
      exercise: Value(exercise),
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
      wordId: serializer.fromJson<int?>(json['wordId']),
      morphemeId: serializer.fromJson<String?>(json['morphemeId']),
      exercise: serializer.fromJson<String>(json['exercise']),
      result: serializer.fromJson<String>(json['result']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int?>(wordId),
      'morphemeId': serializer.toJson<String?>(morphemeId),
      'exercise': serializer.toJson<String>(exercise),
      'result': serializer.toJson<String>(result),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
    };
  }

  ReviewLogData copyWith({
    int? id,
    Value<int?> wordId = const Value.absent(),
    Value<String?> morphemeId = const Value.absent(),
    String? exercise,
    String? result,
    DateTime? reviewedAt,
  }) => ReviewLogData(
    id: id ?? this.id,
    wordId: wordId.present ? wordId.value : this.wordId,
    morphemeId: morphemeId.present ? morphemeId.value : this.morphemeId,
    exercise: exercise ?? this.exercise,
    result: result ?? this.result,
    reviewedAt: reviewedAt ?? this.reviewedAt,
  );
  ReviewLogData copyWithCompanion(ReviewLogCompanion data) {
    return ReviewLogData(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      morphemeId: data.morphemeId.present
          ? data.morphemeId.value
          : this.morphemeId,
      exercise: data.exercise.present ? data.exercise.value : this.exercise,
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
          ..write('morphemeId: $morphemeId, ')
          ..write('exercise: $exercise, ')
          ..write('result: $result, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, wordId, morphemeId, exercise, result, reviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLogData &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.morphemeId == this.morphemeId &&
          other.exercise == this.exercise &&
          other.result == this.result &&
          other.reviewedAt == this.reviewedAt);
}

class ReviewLogCompanion extends UpdateCompanion<ReviewLogData> {
  final Value<int> id;
  final Value<int?> wordId;
  final Value<String?> morphemeId;
  final Value<String> exercise;
  final Value<String> result;
  final Value<DateTime> reviewedAt;
  const ReviewLogCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.morphemeId = const Value.absent(),
    this.exercise = const Value.absent(),
    this.result = const Value.absent(),
    this.reviewedAt = const Value.absent(),
  });
  ReviewLogCompanion.insert({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.morphemeId = const Value.absent(),
    required String exercise,
    required String result,
    this.reviewedAt = const Value.absent(),
  }) : exercise = Value(exercise),
       result = Value(result);
  static Insertable<ReviewLogData> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<String>? morphemeId,
    Expression<String>? exercise,
    Expression<String>? result,
    Expression<DateTime>? reviewedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (morphemeId != null) 'morpheme_id': morphemeId,
      if (exercise != null) 'exercise': exercise,
      if (result != null) 'result': result,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
    });
  }

  ReviewLogCompanion copyWith({
    Value<int>? id,
    Value<int?>? wordId,
    Value<String?>? morphemeId,
    Value<String>? exercise,
    Value<String>? result,
    Value<DateTime>? reviewedAt,
  }) {
    return ReviewLogCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      morphemeId: morphemeId ?? this.morphemeId,
      exercise: exercise ?? this.exercise,
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
    if (morphemeId.present) {
      map['morpheme_id'] = Variable<String>(morphemeId.value);
    }
    if (exercise.present) {
      map['exercise'] = Variable<String>(exercise.value);
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
          ..write('morphemeId: $morphemeId, ')
          ..write('exercise: $exercise, ')
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
  late final $WordMorphemesTable wordMorphemes = $WordMorphemesTable(this);
  late final $MorphemesTable morphemes = $MorphemesTable(this);
  late final $PacksTable packs = $PacksTable(this);
  late final $MorphemeExamplesTable morphemeExamples = $MorphemeExamplesTable(
    this,
  );
  late final $WordPacksTable wordPacks = $WordPacksTable(this);
  late final $TranslationCacheTable translationCache = $TranslationCacheTable(
    this,
  );
  late final $ReviewLogTable reviewLog = $ReviewLogTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    words,
    wordMorphemes,
    morphemes,
    packs,
    morphemeExamples,
    wordPacks,
    translationCache,
    reviewLog,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_morphemes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'packs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('morpheme_examples', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_packs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'packs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_packs', kind: UpdateKind.delete)],
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
  required String normalized,
  required String english,
  Value<bool> englishEdited,
  Value<String> kind,
  Value<String?> lemma,
  Value<String?> pos,
  Value<String> morphemes,
  Value<String?> note,
  Value<String?> noteEn,
  Value<String?> source,
  Value<String?> level,
  Value<String> status,
  Value<double> intervalDays,
  Value<double> easeFactor,
  Value<int> repetitions,
  Value<int> lapses,
  Value<DateTime?> dueAt,
  Value<DateTime?> lastReviewedAt,
  Value<bool> needsAnalysis,
  Value<DateTime> createdAt,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  Value<String> turkish,
  Value<String> normalized,
  Value<String> english,
  Value<bool> englishEdited,
  Value<String> kind,
  Value<String?> lemma,
  Value<String?> pos,
  Value<String> morphemes,
  Value<String?> note,
  Value<String?> noteEn,
  Value<String?> source,
  Value<String?> level,
  Value<String> status,
  Value<double> intervalDays,
  Value<double> easeFactor,
  Value<int> repetitions,
  Value<int> lapses,
  Value<DateTime?> dueAt,
  Value<DateTime?> lastReviewedAt,
  Value<bool> needsAnalysis,
  Value<DateTime> createdAt,
});

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordMorphemesTable, List<WordMorpheme>>
  _wordMorphemesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordMorphemes,
    aliasName: 'words__id__word_morphemes__word_id',
  );

  $$WordMorphemesTableProcessedTableManager get wordMorphemesRefs {
    final manager = $$WordMorphemesTableTableManager(
      $_db,
      $_db.wordMorphemes,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordMorphemesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordPacksTable, List<WordPack>>
  _wordPacksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordPacks,
    aliasName: 'words__id__word_packs__word_id',
  );

  $$WordPacksTableProcessedTableManager get wordPacksRefs {
    final manager = $$WordPacksTableTableManager(
      $_db,
      $_db.wordPacks,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordPacksRefsTable($_db));
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

  ColumnFilters<String> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get englishEdited => $composableBuilder(
    column: $table.englishEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get morphemes => $composableBuilder(
    column: $table.morphemes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteEn => $composableBuilder(
    column: $table.noteEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
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

  ColumnFilters<bool> get needsAnalysis => $composableBuilder(
    column: $table.needsAnalysis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordMorphemesRefs(
    Expression<bool> Function($$WordMorphemesTableFilterComposer f) f,
  ) {
    final $$WordMorphemesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordMorphemes,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordMorphemesTableFilterComposer(
            $db: $db,
            $table: $db.wordMorphemes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordPacksRefs(
    Expression<bool> Function($$WordPacksTableFilterComposer f) f,
  ) {
    final $$WordPacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordPacks,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPacksTableFilterComposer(
            $db: $db,
            $table: $db.wordPacks,
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

  ColumnOrderings<String> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get englishEdited => $composableBuilder(
    column: $table.englishEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get morphemes => $composableBuilder(
    column: $table.morphemes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteEn => $composableBuilder(
    column: $table.noteEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
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

  ColumnOrderings<bool> get needsAnalysis => $composableBuilder(
    column: $table.needsAnalysis,
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

  GeneratedColumn<String> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get english =>
      $composableBuilder(column: $table.english, builder: (column) => column);

  GeneratedColumn<bool> get englishEdited => $composableBuilder(
    column: $table.englishEdited,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get lemma =>
      $composableBuilder(column: $table.lemma, builder: (column) => column);

  GeneratedColumn<String> get pos =>
      $composableBuilder(column: $table.pos, builder: (column) => column);

  GeneratedColumn<String> get morphemes =>
      $composableBuilder(column: $table.morphemes, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get noteEn =>
      $composableBuilder(column: $table.noteEn, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

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

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsAnalysis => $composableBuilder(
    column: $table.needsAnalysis,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> wordMorphemesRefs<T extends Object>(
    Expression<T> Function($$WordMorphemesTableAnnotationComposer a) f,
  ) {
    final $$WordMorphemesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordMorphemes,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordMorphemesTableAnnotationComposer(
            $db: $db,
            $table: $db.wordMorphemes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordPacksRefs<T extends Object>(
    Expression<T> Function($$WordPacksTableAnnotationComposer a) f,
  ) {
    final $$WordPacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordPacks,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPacksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordPacks,
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
          PrefetchHooks Function({
            bool wordMorphemesRefs,
            bool wordPacksRefs,
            bool reviewLogRefs,
          })
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
                Value<String> normalized = const Value.absent(),
                Value<String> english = const Value.absent(),
                Value<bool> englishEdited = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> lemma = const Value.absent(),
                Value<String?> pos = const Value.absent(),
                Value<String> morphemes = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> noteEn = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<bool> needsAnalysis = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                turkish: turkish,
                normalized: normalized,
                english: english,
                englishEdited: englishEdited,
                kind: kind,
                lemma: lemma,
                pos: pos,
                morphemes: morphemes,
                note: note,
                noteEn: noteEn,
                source: source,
                level: level,
                status: status,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                repetitions: repetitions,
                lapses: lapses,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                needsAnalysis: needsAnalysis,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String turkish,
                required String normalized,
                required String english,
                Value<bool> englishEdited = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> lemma = const Value.absent(),
                Value<String?> pos = const Value.absent(),
                Value<String> morphemes = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> noteEn = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<bool> needsAnalysis = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                turkish: turkish,
                normalized: normalized,
                english: english,
                englishEdited: englishEdited,
                kind: kind,
                lemma: lemma,
                pos: pos,
                morphemes: morphemes,
                note: note,
                noteEn: noteEn,
                source: source,
                level: level,
                status: status,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                repetitions: repetitions,
                lapses: lapses,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                needsAnalysis: needsAnalysis,
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
              ({
                wordMorphemesRefs = false,
                wordPacksRefs = false,
                reviewLogRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordMorphemesRefs) db.wordMorphemes,
                    if (wordPacksRefs) db.wordPacks,
                    if (reviewLogRefs) db.reviewLog,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordMorphemesRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          WordMorpheme
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._wordMorphemesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordMorphemesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wordPacksRefs)
                        await $_getPrefetchedData<Word, $WordsTable, WordPack>(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._wordPacksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordPacksRefs,
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
      PrefetchHooks Function({
        bool wordMorphemesRefs,
        bool wordPacksRefs,
        bool reviewLogRefs,
      })
    >;
typedef $$WordMorphemesTableCreateCompanionBuilder =
    WordMorphemesCompanion Function({
      required int wordId,
      required String morphemeId,
      required String surface,
      required int position,
      Value<int> rowid,
    });
typedef $$WordMorphemesTableUpdateCompanionBuilder =
    WordMorphemesCompanion Function({
      Value<int> wordId,
      Value<String> morphemeId,
      Value<String> surface,
      Value<int> position,
      Value<int> rowid,
    });

final class $$WordMorphemesTableReferences
    extends BaseReferences<_$AppDatabase, $WordMorphemesTable, WordMorpheme> {
  $$WordMorphemesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_morphemes__word_id__words__id');

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

class $$WordMorphemesTableFilterComposer
    extends Composer<_$AppDatabase, $WordMorphemesTable> {
  $$WordMorphemesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get morphemeId => $composableBuilder(
    column: $table.morphemeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
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

class $$WordMorphemesTableOrderingComposer
    extends Composer<_$AppDatabase, $WordMorphemesTable> {
  $$WordMorphemesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get morphemeId => $composableBuilder(
    column: $table.morphemeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
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

class $$WordMorphemesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordMorphemesTable> {
  $$WordMorphemesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get morphemeId => $composableBuilder(
    column: $table.morphemeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get surface =>
      $composableBuilder(column: $table.surface, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

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

class $$WordMorphemesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordMorphemesTable,
          WordMorpheme,
          $$WordMorphemesTableFilterComposer,
          $$WordMorphemesTableOrderingComposer,
          $$WordMorphemesTableAnnotationComposer,
          $$WordMorphemesTableCreateCompanionBuilder,
          $$WordMorphemesTableUpdateCompanionBuilder,
          (WordMorpheme, $$WordMorphemesTableReferences),
          WordMorpheme,
          PrefetchHooks Function({bool wordId})
        > {
  $$WordMorphemesTableTableManager(_$AppDatabase db, $WordMorphemesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordMorphemesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordMorphemesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordMorphemesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> wordId = const Value.absent(),
                Value<String> morphemeId = const Value.absent(),
                Value<String> surface = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordMorphemesCompanion(
                wordId: wordId,
                morphemeId: morphemeId,
                surface: surface,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int wordId,
                required String morphemeId,
                required String surface,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => WordMorphemesCompanion.insert(
                wordId: wordId,
                morphemeId: morphemeId,
                surface: surface,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordMorphemesTable, WordMorpheme>(table),
                  $$WordMorphemesTableReferences(db, table, e),
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
                        referencedTable: $$WordMorphemesTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$WordMorphemesTableReferences
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

typedef $$WordMorphemesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordMorphemesTable,
      WordMorpheme,
      $$WordMorphemesTableFilterComposer,
      $$WordMorphemesTableOrderingComposer,
      $$WordMorphemesTableAnnotationComposer,
      $$WordMorphemesTableCreateCompanionBuilder,
      $$WordMorphemesTableUpdateCompanionBuilder,
      (WordMorpheme, $$WordMorphemesTableReferences),
      WordMorpheme,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$MorphemesTableCreateCompanionBuilder = MorphemesCompanion Function({
  required String id,
  Value<String> status,
  Value<double> intervalDays,
  Value<double> easeFactor,
  Value<int> repetitions,
  Value<int> lapses,
  Value<DateTime?> dueAt,
  Value<DateTime?> lastReviewedAt,
  Value<int> rowid,
});
typedef $$MorphemesTableUpdateCompanionBuilder = MorphemesCompanion Function({
  Value<String> id,
  Value<String> status,
  Value<double> intervalDays,
  Value<double> easeFactor,
  Value<int> repetitions,
  Value<int> lapses,
  Value<DateTime?> dueAt,
  Value<DateTime?> lastReviewedAt,
  Value<int> rowid,
});

class $$MorphemesTableFilterComposer
    extends Composer<_$AppDatabase, $MorphemesTable> {
  $$MorphemesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
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
}

class $$MorphemesTableOrderingComposer
    extends Composer<_$AppDatabase, $MorphemesTable> {
  $$MorphemesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
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
}

class $$MorphemesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MorphemesTable> {
  $$MorphemesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

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

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );
}

class $$MorphemesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MorphemesTable,
          Morpheme,
          $$MorphemesTableFilterComposer,
          $$MorphemesTableOrderingComposer,
          $$MorphemesTableAnnotationComposer,
          $$MorphemesTableCreateCompanionBuilder,
          $$MorphemesTableUpdateCompanionBuilder,
          (Morpheme, BaseReferences<_$AppDatabase, $MorphemesTable, Morpheme>),
          Morpheme,
          PrefetchHooks Function()
        > {
  $$MorphemesTableTableManager(_$AppDatabase db, $MorphemesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MorphemesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MorphemesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MorphemesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MorphemesCompanion(
                id: id,
                status: status,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                repetitions: repetitions,
                lapses: lapses,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> status = const Value.absent(),
                Value<double> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MorphemesCompanion.insert(
                id: id,
                status: status,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                repetitions: repetitions,
                lapses: lapses,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MorphemesTable, Morpheme>(table),
                  BaseReferences<_$AppDatabase, $MorphemesTable, Morpheme>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MorphemesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MorphemesTable,
      Morpheme,
      $$MorphemesTableFilterComposer,
      $$MorphemesTableOrderingComposer,
      $$MorphemesTableAnnotationComposer,
      $$MorphemesTableCreateCompanionBuilder,
      $$MorphemesTableUpdateCompanionBuilder,
      (Morpheme, BaseReferences<_$AppDatabase, $MorphemesTable, Morpheme>),
      Morpheme,
      PrefetchHooks Function()
    >;
typedef $$PacksTableCreateCompanionBuilder = PacksCompanion Function({
  required String id,
  required String title,
  Value<String?> level,
  required String kind,
  required int version,
  Value<DateTime> installedAt,
  Value<int> rowid,
});
typedef $$PacksTableUpdateCompanionBuilder = PacksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> level,
  Value<String> kind,
  Value<int> version,
  Value<DateTime> installedAt,
  Value<int> rowid,
});

final class $$PacksTableReferences
    extends BaseReferences<_$AppDatabase, $PacksTable, Pack> {
  $$PacksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MorphemeExamplesTable, List<MorphemeExample>>
  _morphemeExamplesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.morphemeExamples,
    aliasName: 'packs__id__morpheme_examples__pack_id',
  );

  $$MorphemeExamplesTableProcessedTableManager get morphemeExamplesRefs {
    final manager = $$MorphemeExamplesTableTableManager(
      $_db,
      $_db.morphemeExamples,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _morphemeExamplesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordPacksTable, List<WordPack>>
  _wordPacksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordPacks,
    aliasName: 'packs__id__word_packs__pack_id',
  );

  $$WordPacksTableProcessedTableManager get wordPacksRefs {
    final manager = $$WordPacksTableTableManager(
      $_db,
      $_db.wordPacks,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordPacksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PacksTableFilterComposer extends Composer<_$AppDatabase, $PacksTable> {
  $$PacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> morphemeExamplesRefs(
    Expression<bool> Function($$MorphemeExamplesTableFilterComposer f) f,
  ) {
    final $$MorphemeExamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.morphemeExamples,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MorphemeExamplesTableFilterComposer(
            $db: $db,
            $table: $db.morphemeExamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordPacksRefs(
    Expression<bool> Function($$WordPacksTableFilterComposer f) f,
  ) {
    final $$WordPacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordPacks,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPacksTableFilterComposer(
            $db: $db,
            $table: $db.wordPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PacksTableOrderingComposer
    extends Composer<_$AppDatabase, $PacksTable> {
  $$PacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PacksTable> {
  $$PacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  Expression<T> morphemeExamplesRefs<T extends Object>(
    Expression<T> Function($$MorphemeExamplesTableAnnotationComposer a) f,
  ) {
    final $$MorphemeExamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.morphemeExamples,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MorphemeExamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.morphemeExamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordPacksRefs<T extends Object>(
    Expression<T> Function($$WordPacksTableAnnotationComposer a) f,
  ) {
    final $$WordPacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordPacks,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPacksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PacksTable,
          Pack,
          $$PacksTableFilterComposer,
          $$PacksTableOrderingComposer,
          $$PacksTableAnnotationComposer,
          $$PacksTableCreateCompanionBuilder,
          $$PacksTableUpdateCompanionBuilder,
          (Pack, $$PacksTableReferences),
          Pack,
          PrefetchHooks Function({
            bool morphemeExamplesRefs,
            bool wordPacksRefs,
          })
        > {
  $$PacksTableTableManager(_$AppDatabase db, $PacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PacksCompanion(
                id: id,
                title: title,
                level: level,
                kind: kind,
                version: version,
                installedAt: installedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> level = const Value.absent(),
                required String kind,
                required int version,
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PacksCompanion.insert(
                id: id,
                title: title,
                level: level,
                kind: kind,
                version: version,
                installedAt: installedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PacksTable, Pack>(table),
                  $$PacksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({morphemeExamplesRefs = false, wordPacksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (morphemeExamplesRefs) db.morphemeExamples,
                    if (wordPacksRefs) db.wordPacks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (morphemeExamplesRefs)
                        await $_getPrefetchedData<
                          Pack,
                          $PacksTable,
                          MorphemeExample
                        >(
                          currentTable: table,
                          referencedTable: $$PacksTableReferences
                              ._morphemeExamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PacksTableReferences(
                                db,
                                table,
                                p0,
                              ).morphemeExamplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wordPacksRefs)
                        await $_getPrefetchedData<Pack, $PacksTable, WordPack>(
                          currentTable: table,
                          referencedTable: $$PacksTableReferences
                              ._wordPacksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PacksTableReferences(
                                db,
                                table,
                                p0,
                              ).wordPacksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
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

typedef $$PacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PacksTable,
      Pack,
      $$PacksTableFilterComposer,
      $$PacksTableOrderingComposer,
      $$PacksTableAnnotationComposer,
      $$PacksTableCreateCompanionBuilder,
      $$PacksTableUpdateCompanionBuilder,
      (Pack, $$PacksTableReferences),
      Pack,
      PrefetchHooks Function({bool morphemeExamplesRefs, bool wordPacksRefs})
    >;
typedef $$MorphemeExamplesTableCreateCompanionBuilder =
    MorphemeExamplesCompanion Function({
      Value<int> id,
      required String morphemeId,
      required String turkish,
      required String english,
      required String packId,
    });
typedef $$MorphemeExamplesTableUpdateCompanionBuilder =
    MorphemeExamplesCompanion Function({
      Value<int> id,
      Value<String> morphemeId,
      Value<String> turkish,
      Value<String> english,
      Value<String> packId,
    });

final class $$MorphemeExamplesTableReferences
    extends
        BaseReferences<_$AppDatabase, $MorphemeExamplesTable, MorphemeExample> {
  $$MorphemeExamplesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PacksTable _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('morpheme_examples__pack_id__packs__id');

  $$PacksTableProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $$PacksTableTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MorphemeExamplesTableFilterComposer
    extends Composer<_$AppDatabase, $MorphemeExamplesTable> {
  $$MorphemeExamplesTableFilterComposer({
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

  ColumnFilters<String> get morphemeId => $composableBuilder(
    column: $table.morphemeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get turkish => $composableBuilder(
    column: $table.turkish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnFilters(column),
  );

  $$PacksTableFilterComposer get packId {
    final $$PacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MorphemeExamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $MorphemeExamplesTable> {
  $$MorphemeExamplesTableOrderingComposer({
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

  ColumnOrderings<String> get morphemeId => $composableBuilder(
    column: $table.morphemeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get turkish => $composableBuilder(
    column: $table.turkish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnOrderings(column),
  );

  $$PacksTableOrderingComposer get packId {
    final $$PacksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MorphemeExamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MorphemeExamplesTable> {
  $$MorphemeExamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get morphemeId => $composableBuilder(
    column: $table.morphemeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get turkish =>
      $composableBuilder(column: $table.turkish, builder: (column) => column);

  GeneratedColumn<String> get english =>
      $composableBuilder(column: $table.english, builder: (column) => column);

  $$PacksTableAnnotationComposer get packId {
    final $$PacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MorphemeExamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MorphemeExamplesTable,
          MorphemeExample,
          $$MorphemeExamplesTableFilterComposer,
          $$MorphemeExamplesTableOrderingComposer,
          $$MorphemeExamplesTableAnnotationComposer,
          $$MorphemeExamplesTableCreateCompanionBuilder,
          $$MorphemeExamplesTableUpdateCompanionBuilder,
          (MorphemeExample, $$MorphemeExamplesTableReferences),
          MorphemeExample,
          PrefetchHooks Function({bool packId})
        > {
  $$MorphemeExamplesTableTableManager(
    _$AppDatabase db,
    $MorphemeExamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MorphemeExamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MorphemeExamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MorphemeExamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> morphemeId = const Value.absent(),
                Value<String> turkish = const Value.absent(),
                Value<String> english = const Value.absent(),
                Value<String> packId = const Value.absent(),
              }) => MorphemeExamplesCompanion(
                id: id,
                morphemeId: morphemeId,
                turkish: turkish,
                english: english,
                packId: packId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String morphemeId,
                required String turkish,
                required String english,
                required String packId,
              }) => MorphemeExamplesCompanion.insert(
                id: id,
                morphemeId: morphemeId,
                turkish: turkish,
                english: english,
                packId: packId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MorphemeExamplesTable, MorphemeExample>(table),
                  $$MorphemeExamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
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
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $$MorphemeExamplesTableReferences
                            ._packIdTable(db),
                        referencedColumn: $$MorphemeExamplesTableReferences
                            ._packIdTable(db)
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

typedef $$MorphemeExamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MorphemeExamplesTable,
      MorphemeExample,
      $$MorphemeExamplesTableFilterComposer,
      $$MorphemeExamplesTableOrderingComposer,
      $$MorphemeExamplesTableAnnotationComposer,
      $$MorphemeExamplesTableCreateCompanionBuilder,
      $$MorphemeExamplesTableUpdateCompanionBuilder,
      (MorphemeExample, $$MorphemeExamplesTableReferences),
      MorphemeExample,
      PrefetchHooks Function({bool packId})
    >;
typedef $$WordPacksTableCreateCompanionBuilder = WordPacksCompanion Function({
  required int wordId,
  required String packId,
  required int rank,
  Value<int> rowid,
});
typedef $$WordPacksTableUpdateCompanionBuilder = WordPacksCompanion Function({
  Value<int> wordId,
  Value<String> packId,
  Value<int> rank,
  Value<int> rowid,
});

final class $$WordPacksTableReferences
    extends BaseReferences<_$AppDatabase, $WordPacksTable, WordPack> {
  $$WordPacksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_packs__word_id__words__id');

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

  static $PacksTable _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('word_packs__pack_id__packs__id');

  $$PacksTableProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $$PacksTableTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordPacksTableFilterComposer
    extends Composer<_$AppDatabase, $WordPacksTable> {
  $$WordPacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
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

  $$PacksTableFilterComposer get packId {
    final $$PacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordPacksTableOrderingComposer
    extends Composer<_$AppDatabase, $WordPacksTable> {
  $$WordPacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
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

  $$PacksTableOrderingComposer get packId {
    final $$PacksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordPacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordPacksTable> {
  $$WordPacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

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

  $$PacksTableAnnotationComposer get packId {
    final $$PacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordPacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordPacksTable,
          WordPack,
          $$WordPacksTableFilterComposer,
          $$WordPacksTableOrderingComposer,
          $$WordPacksTableAnnotationComposer,
          $$WordPacksTableCreateCompanionBuilder,
          $$WordPacksTableUpdateCompanionBuilder,
          (WordPack, $$WordPacksTableReferences),
          WordPack,
          PrefetchHooks Function({bool wordId, bool packId})
        > {
  $$WordPacksTableTableManager(_$AppDatabase db, $WordPacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordPacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordPacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordPacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> wordId = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordPacksCompanion(
                wordId: wordId,
                packId: packId,
                rank: rank,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int wordId,
                required String packId,
                required int rank,
                Value<int> rowid = const Value.absent(),
              }) => WordPacksCompanion.insert(
                wordId: wordId,
                packId: packId,
                rank: rank,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordPacksTable, WordPack>(table),
                  $$WordPacksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false, packId = false}) {
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
                        referencedTable: $$WordPacksTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$WordPacksTableReferences
                            ._wordIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $$WordPacksTableReferences
                            ._packIdTable(db),
                        referencedColumn: $$WordPacksTableReferences
                            ._packIdTable(db)
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

typedef $$WordPacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordPacksTable,
      WordPack,
      $$WordPacksTableFilterComposer,
      $$WordPacksTableOrderingComposer,
      $$WordPacksTableAnnotationComposer,
      $$WordPacksTableCreateCompanionBuilder,
      $$WordPacksTableUpdateCompanionBuilder,
      (WordPack, $$WordPacksTableReferences),
      WordPack,
      PrefetchHooks Function({bool wordId, bool packId})
    >;
typedef $$TranslationCacheTableCreateCompanionBuilder =
    TranslationCacheCompanion Function({
      required String key,
      required String payload,
      required String provider,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TranslationCacheTableUpdateCompanionBuilder =
    TranslationCacheCompanion Function({
      Value<String> key,
      Value<String> payload,
      Value<String> provider,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TranslationCacheTableFilterComposer
    extends Composer<_$AppDatabase, $TranslationCacheTable> {
  $$TranslationCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TranslationCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $TranslationCacheTable> {
  $$TranslationCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranslationCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranslationCacheTable> {
  $$TranslationCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TranslationCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranslationCacheTable,
          TranslationCacheData,
          $$TranslationCacheTableFilterComposer,
          $$TranslationCacheTableOrderingComposer,
          $$TranslationCacheTableAnnotationComposer,
          $$TranslationCacheTableCreateCompanionBuilder,
          $$TranslationCacheTableUpdateCompanionBuilder,
          (
            TranslationCacheData,
            BaseReferences<
              _$AppDatabase,
              $TranslationCacheTable,
              TranslationCacheData
            >,
          ),
          TranslationCacheData,
          PrefetchHooks Function()
        > {
  $$TranslationCacheTableTableManager(
    _$AppDatabase db,
    $TranslationCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranslationCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranslationCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationCacheCompanion(
                key: key,
                payload: payload,
                provider: provider,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String payload,
                required String provider,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationCacheCompanion.insert(
                key: key,
                payload: payload,
                provider: provider,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TranslationCacheTable, TranslationCacheData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $TranslationCacheTable,
                    TranslationCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TranslationCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranslationCacheTable,
      TranslationCacheData,
      $$TranslationCacheTableFilterComposer,
      $$TranslationCacheTableOrderingComposer,
      $$TranslationCacheTableAnnotationComposer,
      $$TranslationCacheTableCreateCompanionBuilder,
      $$TranslationCacheTableUpdateCompanionBuilder,
      (
        TranslationCacheData,
        BaseReferences<
          _$AppDatabase,
          $TranslationCacheTable,
          TranslationCacheData
        >,
      ),
      TranslationCacheData,
      PrefetchHooks Function()
    >;
typedef $$ReviewLogTableCreateCompanionBuilder = ReviewLogCompanion Function({
  Value<int> id,
  Value<int?> wordId,
  Value<String?> morphemeId,
  required String exercise,
  required String result,
  Value<DateTime> reviewedAt,
});
typedef $$ReviewLogTableUpdateCompanionBuilder = ReviewLogCompanion Function({
  Value<int> id,
  Value<int?> wordId,
  Value<String?> morphemeId,
  Value<String> exercise,
  Value<String> result,
  Value<DateTime> reviewedAt,
});

final class $$ReviewLogTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewLogTable, ReviewLogData> {
  $$ReviewLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('review_log__word_id__words__id');

  $$WordsTableProcessedTableManager? get wordId {
    final $_column = $_itemColumn<int>('word_id');
    if ($_column == null) return null;
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

  ColumnFilters<String> get morphemeId => $composableBuilder(
    column: $table.morphemeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exercise => $composableBuilder(
    column: $table.exercise,
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

  ColumnOrderings<String> get morphemeId => $composableBuilder(
    column: $table.morphemeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exercise => $composableBuilder(
    column: $table.exercise,
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

  GeneratedColumn<String> get morphemeId => $composableBuilder(
    column: $table.morphemeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exercise =>
      $composableBuilder(column: $table.exercise, builder: (column) => column);

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
                Value<int?> wordId = const Value.absent(),
                Value<String?> morphemeId = const Value.absent(),
                Value<String> exercise = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
              }) => ReviewLogCompanion(
                id: id,
                wordId: wordId,
                morphemeId: morphemeId,
                exercise: exercise,
                result: result,
                reviewedAt: reviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> wordId = const Value.absent(),
                Value<String?> morphemeId = const Value.absent(),
                required String exercise,
                required String result,
                Value<DateTime> reviewedAt = const Value.absent(),
              }) => ReviewLogCompanion.insert(
                id: id,
                wordId: wordId,
                morphemeId: morphemeId,
                exercise: exercise,
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
  $$WordMorphemesTableTableManager get wordMorphemes =>
      $$WordMorphemesTableTableManager(_db, _db.wordMorphemes);
  $$MorphemesTableTableManager get morphemes =>
      $$MorphemesTableTableManager(_db, _db.morphemes);
  $$PacksTableTableManager get packs =>
      $$PacksTableTableManager(_db, _db.packs);
  $$MorphemeExamplesTableTableManager get morphemeExamples =>
      $$MorphemeExamplesTableTableManager(_db, _db.morphemeExamples);
  $$WordPacksTableTableManager get wordPacks =>
      $$WordPacksTableTableManager(_db, _db.wordPacks);
  $$TranslationCacheTableTableManager get translationCache =>
      $$TranslationCacheTableTableManager(_db, _db.translationCache);
  $$ReviewLogTableTableManager get reviewLog =>
      $$ReviewLogTableTableManager(_db, _db.reviewLog);
}
