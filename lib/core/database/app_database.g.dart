// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> publisher =
      GeneratedColumn<String>(
        'publisher',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($GamesTable.$converterpublishern);
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headerImageMeta = const VerificationMeta(
    'headerImage',
  );
  @override
  late final GeneratedColumn<String> headerImage = GeneratedColumn<String>(
    'header_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _libraryImageMeta = const VerificationMeta(
    'libraryImage',
  );
  @override
  late final GeneratedColumn<String> libraryImage = GeneratedColumn<String>(
    'library_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _platformSourceMeta = const VerificationMeta(
    'platformSource',
  );
  @override
  late final GeneratedColumn<String> platformSource = GeneratedColumn<String>(
    'platform_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> consoles =
      GeneratedColumn<String>(
        'consoles',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($GamesTable.$converterconsolesn);
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> remoteUpdatedAt =
      GeneratedColumn<DateTime>(
        'remote_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    platform,
    code,
    name,
    publisher,
    description,
    headerImage,
    libraryImage,
    addedAt,
    platformSource,
    isSynced,
    consoles,
    remoteUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('header_image')) {
      context.handle(
        _headerImageMeta,
        headerImage.isAcceptableOrUnknown(
          data['header_image']!,
          _headerImageMeta,
        ),
      );
    }
    if (data.containsKey('library_image')) {
      context.handle(
        _libraryImageMeta,
        libraryImage.isAcceptableOrUnknown(
          data['library_image']!,
          _libraryImageMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('platform_source')) {
      context.handle(
        _platformSourceMeta,
        platformSource.isAcceptableOrUnknown(
          data['platform_source']!,
          _platformSourceMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {platform, code};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      publisher: $GamesTable.$converterpublishern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}publisher'],
        ),
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      headerImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}header_image'],
      ),
      libraryImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_image'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      ),
      platformSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform_source'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      consoles: $GamesTable.$converterconsolesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}consoles'],
        ),
      ),
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remote_updated_at'],
      ),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterpublisher =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterpublishern =
      NullAwareTypeConverter.wrap($converterpublisher);
  static TypeConverter<List<String>, String> $converterconsoles =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterconsolesn =
      NullAwareTypeConverter.wrap($converterconsoles);
}

class Game extends DataClass implements Insertable<Game> {
  /// The store (`steam` or `psn`) and the game's code there: together they
  /// identify the game, so ids of different stores can never clash.
  final String platform;
  final String code;
  final String name;
  final List<String>? publisher;
  final String? description;
  final String? headerImage;
  final String? libraryImage;
  final DateTime? addedAt;
  final String platformSource;
  final bool isSynced;

  /// The consoles of a PlayStation game, as a list of names (`PS5`, `PS4`).
  final List<String>? consoles;

  /// When the platform last updated the game's trophies, as it said.
  final DateTime? remoteUpdatedAt;
  const Game({
    required this.platform,
    required this.code,
    required this.name,
    this.publisher,
    this.description,
    this.headerImage,
    this.libraryImage,
    this.addedAt,
    required this.platformSource,
    required this.isSynced,
    this.consoles,
    this.remoteUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['platform'] = Variable<String>(platform);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(
        $GamesTable.$converterpublishern.toSql(publisher),
      );
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || headerImage != null) {
      map['header_image'] = Variable<String>(headerImage);
    }
    if (!nullToAbsent || libraryImage != null) {
      map['library_image'] = Variable<String>(libraryImage);
    }
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<DateTime>(addedAt);
    }
    map['platform_source'] = Variable<String>(platformSource);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || consoles != null) {
      map['consoles'] = Variable<String>(
        $GamesTable.$converterconsolesn.toSql(consoles),
      );
    }
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<DateTime>(remoteUpdatedAt);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      platform: Value(platform),
      code: Value(code),
      name: Value(name),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      headerImage: headerImage == null && nullToAbsent
          ? const Value.absent()
          : Value(headerImage),
      libraryImage: libraryImage == null && nullToAbsent
          ? const Value.absent()
          : Value(libraryImage),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
      platformSource: Value(platformSource),
      isSynced: Value(isSynced),
      consoles: consoles == null && nullToAbsent
          ? const Value.absent()
          : Value(consoles),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      platform: serializer.fromJson<String>(json['platform']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      publisher: serializer.fromJson<List<String>?>(json['publisher']),
      description: serializer.fromJson<String?>(json['description']),
      headerImage: serializer.fromJson<String?>(json['headerImage']),
      libraryImage: serializer.fromJson<String?>(json['libraryImage']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
      platformSource: serializer.fromJson<String>(json['platformSource']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      consoles: serializer.fromJson<List<String>?>(json['consoles']),
      remoteUpdatedAt: serializer.fromJson<DateTime?>(json['remoteUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'platform': serializer.toJson<String>(platform),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'publisher': serializer.toJson<List<String>?>(publisher),
      'description': serializer.toJson<String?>(description),
      'headerImage': serializer.toJson<String?>(headerImage),
      'libraryImage': serializer.toJson<String?>(libraryImage),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
      'platformSource': serializer.toJson<String>(platformSource),
      'isSynced': serializer.toJson<bool>(isSynced),
      'consoles': serializer.toJson<List<String>?>(consoles),
      'remoteUpdatedAt': serializer.toJson<DateTime?>(remoteUpdatedAt),
    };
  }

  Game copyWith({
    String? platform,
    String? code,
    String? name,
    Value<List<String>?> publisher = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> headerImage = const Value.absent(),
    Value<String?> libraryImage = const Value.absent(),
    Value<DateTime?> addedAt = const Value.absent(),
    String? platformSource,
    bool? isSynced,
    Value<List<String>?> consoles = const Value.absent(),
    Value<DateTime?> remoteUpdatedAt = const Value.absent(),
  }) => Game(
    platform: platform ?? this.platform,
    code: code ?? this.code,
    name: name ?? this.name,
    publisher: publisher.present ? publisher.value : this.publisher,
    description: description.present ? description.value : this.description,
    headerImage: headerImage.present ? headerImage.value : this.headerImage,
    libraryImage: libraryImage.present ? libraryImage.value : this.libraryImage,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
    platformSource: platformSource ?? this.platformSource,
    isSynced: isSynced ?? this.isSynced,
    consoles: consoles.present ? consoles.value : this.consoles,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      platform: data.platform.present ? data.platform.value : this.platform,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      description: data.description.present
          ? data.description.value
          : this.description,
      headerImage: data.headerImage.present
          ? data.headerImage.value
          : this.headerImage,
      libraryImage: data.libraryImage.present
          ? data.libraryImage.value
          : this.libraryImage,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      platformSource: data.platformSource.present
          ? data.platformSource.value
          : this.platformSource,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      consoles: data.consoles.present ? data.consoles.value : this.consoles,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('platform: $platform, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('publisher: $publisher, ')
          ..write('description: $description, ')
          ..write('headerImage: $headerImage, ')
          ..write('libraryImage: $libraryImage, ')
          ..write('addedAt: $addedAt, ')
          ..write('platformSource: $platformSource, ')
          ..write('isSynced: $isSynced, ')
          ..write('consoles: $consoles, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    platform,
    code,
    name,
    publisher,
    description,
    headerImage,
    libraryImage,
    addedAt,
    platformSource,
    isSynced,
    consoles,
    remoteUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.platform == this.platform &&
          other.code == this.code &&
          other.name == this.name &&
          other.publisher == this.publisher &&
          other.description == this.description &&
          other.headerImage == this.headerImage &&
          other.libraryImage == this.libraryImage &&
          other.addedAt == this.addedAt &&
          other.platformSource == this.platformSource &&
          other.isSynced == this.isSynced &&
          other.consoles == this.consoles &&
          other.remoteUpdatedAt == this.remoteUpdatedAt);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<String> platform;
  final Value<String> code;
  final Value<String> name;
  final Value<List<String>?> publisher;
  final Value<String?> description;
  final Value<String?> headerImage;
  final Value<String?> libraryImage;
  final Value<DateTime?> addedAt;
  final Value<String> platformSource;
  final Value<bool> isSynced;
  final Value<List<String>?> consoles;
  final Value<DateTime?> remoteUpdatedAt;
  final Value<int> rowid;
  const GamesCompanion({
    this.platform = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.publisher = const Value.absent(),
    this.description = const Value.absent(),
    this.headerImage = const Value.absent(),
    this.libraryImage = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.platformSource = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.consoles = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamesCompanion.insert({
    required String platform,
    required String code,
    required String name,
    this.publisher = const Value.absent(),
    this.description = const Value.absent(),
    this.headerImage = const Value.absent(),
    this.libraryImage = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.platformSource = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.consoles = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : platform = Value(platform),
       code = Value(code),
       name = Value(name);
  static Insertable<Game> custom({
    Expression<String>? platform,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? publisher,
    Expression<String>? description,
    Expression<String>? headerImage,
    Expression<String>? libraryImage,
    Expression<DateTime>? addedAt,
    Expression<String>? platformSource,
    Expression<bool>? isSynced,
    Expression<String>? consoles,
    Expression<DateTime>? remoteUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (platform != null) 'platform': platform,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (publisher != null) 'publisher': publisher,
      if (description != null) 'description': description,
      if (headerImage != null) 'header_image': headerImage,
      if (libraryImage != null) 'library_image': libraryImage,
      if (addedAt != null) 'added_at': addedAt,
      if (platformSource != null) 'platform_source': platformSource,
      if (isSynced != null) 'is_synced': isSynced,
      if (consoles != null) 'consoles': consoles,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamesCompanion copyWith({
    Value<String>? platform,
    Value<String>? code,
    Value<String>? name,
    Value<List<String>?>? publisher,
    Value<String?>? description,
    Value<String?>? headerImage,
    Value<String?>? libraryImage,
    Value<DateTime?>? addedAt,
    Value<String>? platformSource,
    Value<bool>? isSynced,
    Value<List<String>?>? consoles,
    Value<DateTime?>? remoteUpdatedAt,
    Value<int>? rowid,
  }) {
    return GamesCompanion(
      platform: platform ?? this.platform,
      code: code ?? this.code,
      name: name ?? this.name,
      publisher: publisher ?? this.publisher,
      description: description ?? this.description,
      headerImage: headerImage ?? this.headerImage,
      libraryImage: libraryImage ?? this.libraryImage,
      addedAt: addedAt ?? this.addedAt,
      platformSource: platformSource ?? this.platformSource,
      isSynced: isSynced ?? this.isSynced,
      consoles: consoles ?? this.consoles,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(
        $GamesTable.$converterpublishern.toSql(publisher.value),
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (headerImage.present) {
      map['header_image'] = Variable<String>(headerImage.value);
    }
    if (libraryImage.present) {
      map['library_image'] = Variable<String>(libraryImage.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (platformSource.present) {
      map['platform_source'] = Variable<String>(platformSource.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (consoles.present) {
      map['consoles'] = Variable<String>(
        $GamesTable.$converterconsolesn.toSql(consoles.value),
      );
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<DateTime>(remoteUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('platform: $platform, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('publisher: $publisher, ')
          ..write('description: $description, ')
          ..write('headerImage: $headerImage, ')
          ..write('libraryImage: $libraryImage, ')
          ..write('addedAt: $addedAt, ')
          ..write('platformSource: $platformSource, ')
          ..write('isSynced: $isSynced, ')
          ..write('consoles: $consoles, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrophiesTable extends Trophies with TableInfo<$TrophiesTable, Trophy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrophiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _apiNameMeta = const VerificationMeta(
    'apiName',
  );
  @override
  late final GeneratedColumn<String> apiName = GeneratedColumn<String>(
    'api_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coloredIconMeta = const VerificationMeta(
    'coloredIcon',
  );
  @override
  late final GeneratedColumn<String> coloredIcon = GeneratedColumn<String>(
    'colored_icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAchievedMeta = const VerificationMeta(
    'isAchieved',
  );
  @override
  late final GeneratedColumn<bool> isAchieved = GeneratedColumn<bool>(
    'is_achieved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_achieved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<double> rarity = GeneratedColumn<double>(
    'rarity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gamePlatformMeta = const VerificationMeta(
    'gamePlatform',
  );
  @override
  late final GeneratedColumn<String> gamePlatform = GeneratedColumn<String>(
    'game_platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameCodeMeta = const VerificationMeta(
    'gameCode',
  );
  @override
  late final GeneratedColumn<String> gameCode = GeneratedColumn<String>(
    'game_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    apiName,
    displayName,
    description,
    icon,
    coloredIcon,
    isAchieved,
    achievedAt,
    type,
    hidden,
    rarity,
    gamePlatform,
    gameCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trophies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trophy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('api_name')) {
      context.handle(
        _apiNameMeta,
        apiName.isAcceptableOrUnknown(data['api_name']!, _apiNameMeta),
      );
    } else if (isInserting) {
      context.missing(_apiNameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('colored_icon')) {
      context.handle(
        _coloredIconMeta,
        coloredIcon.isAcceptableOrUnknown(
          data['colored_icon']!,
          _coloredIconMeta,
        ),
      );
    }
    if (data.containsKey('is_achieved')) {
      context.handle(
        _isAchievedMeta,
        isAchieved.isAcceptableOrUnknown(data['is_achieved']!, _isAchievedMeta),
      );
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    }
    if (data.containsKey('game_platform')) {
      context.handle(
        _gamePlatformMeta,
        gamePlatform.isAcceptableOrUnknown(
          data['game_platform']!,
          _gamePlatformMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gamePlatformMeta);
    }
    if (data.containsKey('game_code')) {
      context.handle(
        _gameCodeMeta,
        gameCode.isAcceptableOrUnknown(data['game_code']!, _gameCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_gameCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {apiName, gamePlatform, gameCode};
  @override
  Trophy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trophy(
      apiName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      coloredIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colored_icon'],
      ),
      isAchieved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_achieved'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rarity'],
      ),
      gamePlatform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_platform'],
      )!,
      gameCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_code'],
      )!,
    );
  }

  @override
  $TrophiesTable createAlias(String alias) {
    return $TrophiesTable(attachedDatabase, alias);
  }
}

class Trophy extends DataClass implements Insertable<Trophy> {
  final String apiName;
  final String displayName;
  final String? description;
  final String? icon;
  final String? coloredIcon;
  final bool isAchieved;
  final DateTime? achievedAt;

  /// `bronze`, `silver`, `gold` or `platinum`, for PlayStation trophies.
  final String? type;
  final bool hidden;

  /// The share of players who earned it, from 0 to 100.
  final double? rarity;
  final String gamePlatform;
  final String gameCode;
  const Trophy({
    required this.apiName,
    required this.displayName,
    this.description,
    this.icon,
    this.coloredIcon,
    required this.isAchieved,
    this.achievedAt,
    this.type,
    required this.hidden,
    this.rarity,
    required this.gamePlatform,
    required this.gameCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['api_name'] = Variable<String>(apiName);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || coloredIcon != null) {
      map['colored_icon'] = Variable<String>(coloredIcon);
    }
    map['is_achieved'] = Variable<bool>(isAchieved);
    if (!nullToAbsent || achievedAt != null) {
      map['achieved_at'] = Variable<DateTime>(achievedAt);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    map['hidden'] = Variable<bool>(hidden);
    if (!nullToAbsent || rarity != null) {
      map['rarity'] = Variable<double>(rarity);
    }
    map['game_platform'] = Variable<String>(gamePlatform);
    map['game_code'] = Variable<String>(gameCode);
    return map;
  }

  TrophiesCompanion toCompanion(bool nullToAbsent) {
    return TrophiesCompanion(
      apiName: Value(apiName),
      displayName: Value(displayName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      coloredIcon: coloredIcon == null && nullToAbsent
          ? const Value.absent()
          : Value(coloredIcon),
      isAchieved: Value(isAchieved),
      achievedAt: achievedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(achievedAt),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      hidden: Value(hidden),
      rarity: rarity == null && nullToAbsent
          ? const Value.absent()
          : Value(rarity),
      gamePlatform: Value(gamePlatform),
      gameCode: Value(gameCode),
    );
  }

  factory Trophy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trophy(
      apiName: serializer.fromJson<String>(json['apiName']),
      displayName: serializer.fromJson<String>(json['displayName']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<String?>(json['icon']),
      coloredIcon: serializer.fromJson<String?>(json['coloredIcon']),
      isAchieved: serializer.fromJson<bool>(json['isAchieved']),
      achievedAt: serializer.fromJson<DateTime?>(json['achievedAt']),
      type: serializer.fromJson<String?>(json['type']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      rarity: serializer.fromJson<double?>(json['rarity']),
      gamePlatform: serializer.fromJson<String>(json['gamePlatform']),
      gameCode: serializer.fromJson<String>(json['gameCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'apiName': serializer.toJson<String>(apiName),
      'displayName': serializer.toJson<String>(displayName),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<String?>(icon),
      'coloredIcon': serializer.toJson<String?>(coloredIcon),
      'isAchieved': serializer.toJson<bool>(isAchieved),
      'achievedAt': serializer.toJson<DateTime?>(achievedAt),
      'type': serializer.toJson<String?>(type),
      'hidden': serializer.toJson<bool>(hidden),
      'rarity': serializer.toJson<double?>(rarity),
      'gamePlatform': serializer.toJson<String>(gamePlatform),
      'gameCode': serializer.toJson<String>(gameCode),
    };
  }

  Trophy copyWith({
    String? apiName,
    String? displayName,
    Value<String?> description = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<String?> coloredIcon = const Value.absent(),
    bool? isAchieved,
    Value<DateTime?> achievedAt = const Value.absent(),
    Value<String?> type = const Value.absent(),
    bool? hidden,
    Value<double?> rarity = const Value.absent(),
    String? gamePlatform,
    String? gameCode,
  }) => Trophy(
    apiName: apiName ?? this.apiName,
    displayName: displayName ?? this.displayName,
    description: description.present ? description.value : this.description,
    icon: icon.present ? icon.value : this.icon,
    coloredIcon: coloredIcon.present ? coloredIcon.value : this.coloredIcon,
    isAchieved: isAchieved ?? this.isAchieved,
    achievedAt: achievedAt.present ? achievedAt.value : this.achievedAt,
    type: type.present ? type.value : this.type,
    hidden: hidden ?? this.hidden,
    rarity: rarity.present ? rarity.value : this.rarity,
    gamePlatform: gamePlatform ?? this.gamePlatform,
    gameCode: gameCode ?? this.gameCode,
  );
  Trophy copyWithCompanion(TrophiesCompanion data) {
    return Trophy(
      apiName: data.apiName.present ? data.apiName.value : this.apiName,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      coloredIcon: data.coloredIcon.present
          ? data.coloredIcon.value
          : this.coloredIcon,
      isAchieved: data.isAchieved.present
          ? data.isAchieved.value
          : this.isAchieved,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      type: data.type.present ? data.type.value : this.type,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      gamePlatform: data.gamePlatform.present
          ? data.gamePlatform.value
          : this.gamePlatform,
      gameCode: data.gameCode.present ? data.gameCode.value : this.gameCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trophy(')
          ..write('apiName: $apiName, ')
          ..write('displayName: $displayName, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('coloredIcon: $coloredIcon, ')
          ..write('isAchieved: $isAchieved, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('type: $type, ')
          ..write('hidden: $hidden, ')
          ..write('rarity: $rarity, ')
          ..write('gamePlatform: $gamePlatform, ')
          ..write('gameCode: $gameCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    apiName,
    displayName,
    description,
    icon,
    coloredIcon,
    isAchieved,
    achievedAt,
    type,
    hidden,
    rarity,
    gamePlatform,
    gameCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trophy &&
          other.apiName == this.apiName &&
          other.displayName == this.displayName &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.coloredIcon == this.coloredIcon &&
          other.isAchieved == this.isAchieved &&
          other.achievedAt == this.achievedAt &&
          other.type == this.type &&
          other.hidden == this.hidden &&
          other.rarity == this.rarity &&
          other.gamePlatform == this.gamePlatform &&
          other.gameCode == this.gameCode);
}

class TrophiesCompanion extends UpdateCompanion<Trophy> {
  final Value<String> apiName;
  final Value<String> displayName;
  final Value<String?> description;
  final Value<String?> icon;
  final Value<String?> coloredIcon;
  final Value<bool> isAchieved;
  final Value<DateTime?> achievedAt;
  final Value<String?> type;
  final Value<bool> hidden;
  final Value<double?> rarity;
  final Value<String> gamePlatform;
  final Value<String> gameCode;
  final Value<int> rowid;
  const TrophiesCompanion({
    this.apiName = const Value.absent(),
    this.displayName = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.coloredIcon = const Value.absent(),
    this.isAchieved = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.hidden = const Value.absent(),
    this.rarity = const Value.absent(),
    this.gamePlatform = const Value.absent(),
    this.gameCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrophiesCompanion.insert({
    required String apiName,
    required String displayName,
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.coloredIcon = const Value.absent(),
    this.isAchieved = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.hidden = const Value.absent(),
    this.rarity = const Value.absent(),
    required String gamePlatform,
    required String gameCode,
    this.rowid = const Value.absent(),
  }) : apiName = Value(apiName),
       displayName = Value(displayName),
       gamePlatform = Value(gamePlatform),
       gameCode = Value(gameCode);
  static Insertable<Trophy> custom({
    Expression<String>? apiName,
    Expression<String>? displayName,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<String>? coloredIcon,
    Expression<bool>? isAchieved,
    Expression<DateTime>? achievedAt,
    Expression<String>? type,
    Expression<bool>? hidden,
    Expression<double>? rarity,
    Expression<String>? gamePlatform,
    Expression<String>? gameCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (apiName != null) 'api_name': apiName,
      if (displayName != null) 'display_name': displayName,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (coloredIcon != null) 'colored_icon': coloredIcon,
      if (isAchieved != null) 'is_achieved': isAchieved,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (type != null) 'type': type,
      if (hidden != null) 'hidden': hidden,
      if (rarity != null) 'rarity': rarity,
      if (gamePlatform != null) 'game_platform': gamePlatform,
      if (gameCode != null) 'game_code': gameCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrophiesCompanion copyWith({
    Value<String>? apiName,
    Value<String>? displayName,
    Value<String?>? description,
    Value<String?>? icon,
    Value<String?>? coloredIcon,
    Value<bool>? isAchieved,
    Value<DateTime?>? achievedAt,
    Value<String?>? type,
    Value<bool>? hidden,
    Value<double?>? rarity,
    Value<String>? gamePlatform,
    Value<String>? gameCode,
    Value<int>? rowid,
  }) {
    return TrophiesCompanion(
      apiName: apiName ?? this.apiName,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      coloredIcon: coloredIcon ?? this.coloredIcon,
      isAchieved: isAchieved ?? this.isAchieved,
      achievedAt: achievedAt ?? this.achievedAt,
      type: type ?? this.type,
      hidden: hidden ?? this.hidden,
      rarity: rarity ?? this.rarity,
      gamePlatform: gamePlatform ?? this.gamePlatform,
      gameCode: gameCode ?? this.gameCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (apiName.present) {
      map['api_name'] = Variable<String>(apiName.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (coloredIcon.present) {
      map['colored_icon'] = Variable<String>(coloredIcon.value);
    }
    if (isAchieved.present) {
      map['is_achieved'] = Variable<bool>(isAchieved.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<double>(rarity.value);
    }
    if (gamePlatform.present) {
      map['game_platform'] = Variable<String>(gamePlatform.value);
    }
    if (gameCode.present) {
      map['game_code'] = Variable<String>(gameCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrophiesCompanion(')
          ..write('apiName: $apiName, ')
          ..write('displayName: $displayName, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('coloredIcon: $coloredIcon, ')
          ..write('isAchieved: $isAchieved, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('type: $type, ')
          ..write('hidden: $hidden, ')
          ..write('rarity: $rarity, ')
          ..write('gamePlatform: $gamePlatform, ')
          ..write('gameCode: $gameCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _gamePlatformMeta = const VerificationMeta(
    'gamePlatform',
  );
  @override
  late final GeneratedColumn<String> gamePlatform = GeneratedColumn<String>(
    'game_platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameCodeMeta = const VerificationMeta(
    'gameCode',
  );
  @override
  late final GeneratedColumn<String> gameCode = GeneratedColumn<String>(
    'game_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trophyDisplayNameMeta = const VerificationMeta(
    'trophyDisplayName',
  );
  @override
  late final GeneratedColumn<String> trophyDisplayName =
      GeneratedColumn<String>(
        'trophy_display_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gamePlatform,
    gameCode,
    trophyDisplayName,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_platform')) {
      context.handle(
        _gamePlatformMeta,
        gamePlatform.isAcceptableOrUnknown(
          data['game_platform']!,
          _gamePlatformMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gamePlatformMeta);
    }
    if (data.containsKey('game_code')) {
      context.handle(
        _gameCodeMeta,
        gameCode.isAcceptableOrUnknown(data['game_code']!, _gameCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_gameCodeMeta);
    }
    if (data.containsKey('trophy_display_name')) {
      context.handle(
        _trophyDisplayNameMeta,
        trophyDisplayName.isAcceptableOrUnknown(
          data['trophy_display_name']!,
          _trophyDisplayNameMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gamePlatform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_platform'],
      )!,
      gameCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_code'],
      )!,
      trophyDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trophy_display_name'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final int id;
  final String gamePlatform;
  final String gameCode;
  final String? trophyDisplayName;
  final DateTime timestamp;
  const Activity({
    required this.id,
    required this.gamePlatform,
    required this.gameCode,
    this.trophyDisplayName,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_platform'] = Variable<String>(gamePlatform);
    map['game_code'] = Variable<String>(gameCode);
    if (!nullToAbsent || trophyDisplayName != null) {
      map['trophy_display_name'] = Variable<String>(trophyDisplayName);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      gamePlatform: Value(gamePlatform),
      gameCode: Value(gameCode),
      trophyDisplayName: trophyDisplayName == null && nullToAbsent
          ? const Value.absent()
          : Value(trophyDisplayName),
      timestamp: Value(timestamp),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<int>(json['id']),
      gamePlatform: serializer.fromJson<String>(json['gamePlatform']),
      gameCode: serializer.fromJson<String>(json['gameCode']),
      trophyDisplayName: serializer.fromJson<String?>(
        json['trophyDisplayName'],
      ),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gamePlatform': serializer.toJson<String>(gamePlatform),
      'gameCode': serializer.toJson<String>(gameCode),
      'trophyDisplayName': serializer.toJson<String?>(trophyDisplayName),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  Activity copyWith({
    int? id,
    String? gamePlatform,
    String? gameCode,
    Value<String?> trophyDisplayName = const Value.absent(),
    DateTime? timestamp,
  }) => Activity(
    id: id ?? this.id,
    gamePlatform: gamePlatform ?? this.gamePlatform,
    gameCode: gameCode ?? this.gameCode,
    trophyDisplayName: trophyDisplayName.present
        ? trophyDisplayName.value
        : this.trophyDisplayName,
    timestamp: timestamp ?? this.timestamp,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      gamePlatform: data.gamePlatform.present
          ? data.gamePlatform.value
          : this.gamePlatform,
      gameCode: data.gameCode.present ? data.gameCode.value : this.gameCode,
      trophyDisplayName: data.trophyDisplayName.present
          ? data.trophyDisplayName.value
          : this.trophyDisplayName,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('gamePlatform: $gamePlatform, ')
          ..write('gameCode: $gameCode, ')
          ..write('trophyDisplayName: $trophyDisplayName, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gamePlatform, gameCode, trophyDisplayName, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.gamePlatform == this.gamePlatform &&
          other.gameCode == this.gameCode &&
          other.trophyDisplayName == this.trophyDisplayName &&
          other.timestamp == this.timestamp);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<int> id;
  final Value<String> gamePlatform;
  final Value<String> gameCode;
  final Value<String?> trophyDisplayName;
  final Value<DateTime> timestamp;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.gamePlatform = const Value.absent(),
    this.gameCode = const Value.absent(),
    this.trophyDisplayName = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    this.id = const Value.absent(),
    required String gamePlatform,
    required String gameCode,
    this.trophyDisplayName = const Value.absent(),
    required DateTime timestamp,
  }) : gamePlatform = Value(gamePlatform),
       gameCode = Value(gameCode),
       timestamp = Value(timestamp);
  static Insertable<Activity> custom({
    Expression<int>? id,
    Expression<String>? gamePlatform,
    Expression<String>? gameCode,
    Expression<String>? trophyDisplayName,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gamePlatform != null) 'game_platform': gamePlatform,
      if (gameCode != null) 'game_code': gameCode,
      if (trophyDisplayName != null) 'trophy_display_name': trophyDisplayName,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  ActivitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? gamePlatform,
    Value<String>? gameCode,
    Value<String?>? trophyDisplayName,
    Value<DateTime>? timestamp,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      gamePlatform: gamePlatform ?? this.gamePlatform,
      gameCode: gameCode ?? this.gameCode,
      trophyDisplayName: trophyDisplayName ?? this.trophyDisplayName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gamePlatform.present) {
      map['game_platform'] = Variable<String>(gamePlatform.value);
    }
    if (gameCode.present) {
      map['game_code'] = Variable<String>(gameCode.value);
    }
    if (trophyDisplayName.present) {
      map['trophy_display_name'] = Variable<String>(trophyDisplayName.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('gamePlatform: $gamePlatform, ')
          ..write('gameCode: $gameCode, ')
          ..write('trophyDisplayName: $trophyDisplayName, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $SteamCatalogTable extends SteamCatalog
    with TableInfo<$SteamCatalogTable, SteamCatalogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SteamCatalogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _appIdMeta = const VerificationMeta('appId');
  @override
  late final GeneratedColumn<int> appId = GeneratedColumn<int>(
    'app_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [appId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'steam_catalog';
  @override
  VerificationContext validateIntegrity(
    Insertable<SteamCatalogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('app_id')) {
      context.handle(
        _appIdMeta,
        appId.isAcceptableOrUnknown(data['app_id']!, _appIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {appId};
  @override
  SteamCatalogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SteamCatalogData(
      appId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}app_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $SteamCatalogTable createAlias(String alias) {
    return $SteamCatalogTable(attachedDatabase, alias);
  }
}

class SteamCatalogData extends DataClass
    implements Insertable<SteamCatalogData> {
  final int appId;
  final String name;
  const SteamCatalogData({required this.appId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['app_id'] = Variable<int>(appId);
    map['name'] = Variable<String>(name);
    return map;
  }

  SteamCatalogCompanion toCompanion(bool nullToAbsent) {
    return SteamCatalogCompanion(appId: Value(appId), name: Value(name));
  }

  factory SteamCatalogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SteamCatalogData(
      appId: serializer.fromJson<int>(json['appId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'appId': serializer.toJson<int>(appId),
      'name': serializer.toJson<String>(name),
    };
  }

  SteamCatalogData copyWith({int? appId, String? name}) =>
      SteamCatalogData(appId: appId ?? this.appId, name: name ?? this.name);
  SteamCatalogData copyWithCompanion(SteamCatalogCompanion data) {
    return SteamCatalogData(
      appId: data.appId.present ? data.appId.value : this.appId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SteamCatalogData(')
          ..write('appId: $appId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(appId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SteamCatalogData &&
          other.appId == this.appId &&
          other.name == this.name);
}

class SteamCatalogCompanion extends UpdateCompanion<SteamCatalogData> {
  final Value<int> appId;
  final Value<String> name;
  const SteamCatalogCompanion({
    this.appId = const Value.absent(),
    this.name = const Value.absent(),
  });
  SteamCatalogCompanion.insert({
    this.appId = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<SteamCatalogData> custom({
    Expression<int>? appId,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (appId != null) 'app_id': appId,
      if (name != null) 'name': name,
    });
  }

  SteamCatalogCompanion copyWith({Value<int>? appId, Value<String>? name}) {
    return SteamCatalogCompanion(
      appId: appId ?? this.appId,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (appId.present) {
      map['app_id'] = Variable<int>(appId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SteamCatalogCompanion(')
          ..write('appId: $appId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GamesTable games = $GamesTable(this);
  late final $TrophiesTable trophies = $TrophiesTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $SteamCatalogTable steamCatalog = $SteamCatalogTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    games,
    trophies,
    activities,
    steamCatalog,
  ];
}

typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      required String platform,
      required String code,
      required String name,
      Value<List<String>?> publisher,
      Value<String?> description,
      Value<String?> headerImage,
      Value<String?> libraryImage,
      Value<DateTime?> addedAt,
      Value<String> platformSource,
      Value<bool> isSynced,
      Value<List<String>?> consoles,
      Value<DateTime?> remoteUpdatedAt,
      Value<int> rowid,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<String> platform,
      Value<String> code,
      Value<String> name,
      Value<List<String>?> publisher,
      Value<String?> description,
      Value<String?> headerImage,
      Value<String?> libraryImage,
      Value<DateTime?> addedAt,
      Value<String> platformSource,
      Value<bool> isSynced,
      Value<List<String>?> consoles,
      Value<DateTime?> remoteUpdatedAt,
      Value<int> rowid,
    });

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headerImage => $composableBuilder(
    column: $table.headerImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryImage => $composableBuilder(
    column: $table.libraryImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platformSource => $composableBuilder(
    column: $table.platformSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get consoles => $composableBuilder(
    column: $table.consoles,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headerImage => $composableBuilder(
    column: $table.headerImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryImage => $composableBuilder(
    column: $table.libraryImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platformSource => $composableBuilder(
    column: $table.platformSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consoles => $composableBuilder(
    column: $table.consoles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get headerImage => $composableBuilder(
    column: $table.headerImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get libraryImage => $composableBuilder(
    column: $table.libraryImage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get platformSource => $composableBuilder(
    column: $table.platformSource,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get consoles =>
      $composableBuilder(column: $table.consoles, builder: (column) => column);

  GeneratedColumn<DateTime> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, BaseReferences<_$AppDatabase, $GamesTable, Game>),
          Game,
          PrefetchHooks Function()
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> platform = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<List<String>?> publisher = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> headerImage = const Value.absent(),
                Value<String?> libraryImage = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String> platformSource = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<List<String>?> consoles = const Value.absent(),
                Value<DateTime?> remoteUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion(
                platform: platform,
                code: code,
                name: name,
                publisher: publisher,
                description: description,
                headerImage: headerImage,
                libraryImage: libraryImage,
                addedAt: addedAt,
                platformSource: platformSource,
                isSynced: isSynced,
                consoles: consoles,
                remoteUpdatedAt: remoteUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String platform,
                required String code,
                required String name,
                Value<List<String>?> publisher = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> headerImage = const Value.absent(),
                Value<String?> libraryImage = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String> platformSource = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<List<String>?> consoles = const Value.absent(),
                Value<DateTime?> remoteUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion.insert(
                platform: platform,
                code: code,
                name: name,
                publisher: publisher,
                description: description,
                headerImage: headerImage,
                libraryImage: libraryImage,
                addedAt: addedAt,
                platformSource: platformSource,
                isSynced: isSynced,
                consoles: consoles,
                remoteUpdatedAt: remoteUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, BaseReferences<_$AppDatabase, $GamesTable, Game>),
      Game,
      PrefetchHooks Function()
    >;
typedef $$TrophiesTableCreateCompanionBuilder =
    TrophiesCompanion Function({
      required String apiName,
      required String displayName,
      Value<String?> description,
      Value<String?> icon,
      Value<String?> coloredIcon,
      Value<bool> isAchieved,
      Value<DateTime?> achievedAt,
      Value<String?> type,
      Value<bool> hidden,
      Value<double?> rarity,
      required String gamePlatform,
      required String gameCode,
      Value<int> rowid,
    });
typedef $$TrophiesTableUpdateCompanionBuilder =
    TrophiesCompanion Function({
      Value<String> apiName,
      Value<String> displayName,
      Value<String?> description,
      Value<String?> icon,
      Value<String?> coloredIcon,
      Value<bool> isAchieved,
      Value<DateTime?> achievedAt,
      Value<String?> type,
      Value<bool> hidden,
      Value<double?> rarity,
      Value<String> gamePlatform,
      Value<String> gameCode,
      Value<int> rowid,
    });

class $$TrophiesTableFilterComposer
    extends Composer<_$AppDatabase, $TrophiesTable> {
  $$TrophiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get apiName => $composableBuilder(
    column: $table.apiName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coloredIcon => $composableBuilder(
    column: $table.coloredIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAchieved => $composableBuilder(
    column: $table.isAchieved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gamePlatform => $composableBuilder(
    column: $table.gamePlatform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameCode => $composableBuilder(
    column: $table.gameCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrophiesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrophiesTable> {
  $$TrophiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get apiName => $composableBuilder(
    column: $table.apiName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coloredIcon => $composableBuilder(
    column: $table.coloredIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAchieved => $composableBuilder(
    column: $table.isAchieved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gamePlatform => $composableBuilder(
    column: $table.gamePlatform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameCode => $composableBuilder(
    column: $table.gameCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrophiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrophiesTable> {
  $$TrophiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get apiName =>
      $composableBuilder(column: $table.apiName, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get coloredIcon => $composableBuilder(
    column: $table.coloredIcon,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAchieved => $composableBuilder(
    column: $table.isAchieved,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<double> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get gamePlatform => $composableBuilder(
    column: $table.gamePlatform,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gameCode =>
      $composableBuilder(column: $table.gameCode, builder: (column) => column);
}

class $$TrophiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrophiesTable,
          Trophy,
          $$TrophiesTableFilterComposer,
          $$TrophiesTableOrderingComposer,
          $$TrophiesTableAnnotationComposer,
          $$TrophiesTableCreateCompanionBuilder,
          $$TrophiesTableUpdateCompanionBuilder,
          (Trophy, BaseReferences<_$AppDatabase, $TrophiesTable, Trophy>),
          Trophy,
          PrefetchHooks Function()
        > {
  $$TrophiesTableTableManager(_$AppDatabase db, $TrophiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrophiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrophiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrophiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> apiName = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> coloredIcon = const Value.absent(),
                Value<bool> isAchieved = const Value.absent(),
                Value<DateTime?> achievedAt = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<double?> rarity = const Value.absent(),
                Value<String> gamePlatform = const Value.absent(),
                Value<String> gameCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrophiesCompanion(
                apiName: apiName,
                displayName: displayName,
                description: description,
                icon: icon,
                coloredIcon: coloredIcon,
                isAchieved: isAchieved,
                achievedAt: achievedAt,
                type: type,
                hidden: hidden,
                rarity: rarity,
                gamePlatform: gamePlatform,
                gameCode: gameCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String apiName,
                required String displayName,
                Value<String?> description = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> coloredIcon = const Value.absent(),
                Value<bool> isAchieved = const Value.absent(),
                Value<DateTime?> achievedAt = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<double?> rarity = const Value.absent(),
                required String gamePlatform,
                required String gameCode,
                Value<int> rowid = const Value.absent(),
              }) => TrophiesCompanion.insert(
                apiName: apiName,
                displayName: displayName,
                description: description,
                icon: icon,
                coloredIcon: coloredIcon,
                isAchieved: isAchieved,
                achievedAt: achievedAt,
                type: type,
                hidden: hidden,
                rarity: rarity,
                gamePlatform: gamePlatform,
                gameCode: gameCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrophiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrophiesTable,
      Trophy,
      $$TrophiesTableFilterComposer,
      $$TrophiesTableOrderingComposer,
      $$TrophiesTableAnnotationComposer,
      $$TrophiesTableCreateCompanionBuilder,
      $$TrophiesTableUpdateCompanionBuilder,
      (Trophy, BaseReferences<_$AppDatabase, $TrophiesTable, Trophy>),
      Trophy,
      PrefetchHooks Function()
    >;
typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<int> id,
      required String gamePlatform,
      required String gameCode,
      Value<String?> trophyDisplayName,
      required DateTime timestamp,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<int> id,
      Value<String> gamePlatform,
      Value<String> gameCode,
      Value<String?> trophyDisplayName,
      Value<DateTime> timestamp,
    });

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
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

  ColumnFilters<String> get gamePlatform => $composableBuilder(
    column: $table.gamePlatform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameCode => $composableBuilder(
    column: $table.gameCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trophyDisplayName => $composableBuilder(
    column: $table.trophyDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
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

  ColumnOrderings<String> get gamePlatform => $composableBuilder(
    column: $table.gamePlatform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameCode => $composableBuilder(
    column: $table.gameCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trophyDisplayName => $composableBuilder(
    column: $table.trophyDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gamePlatform => $composableBuilder(
    column: $table.gamePlatform,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gameCode =>
      $composableBuilder(column: $table.gameCode, builder: (column) => column);

  GeneratedColumn<String> get trophyDisplayName => $composableBuilder(
    column: $table.trophyDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>),
          Activity,
          PrefetchHooks Function()
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> gamePlatform = const Value.absent(),
                Value<String> gameCode = const Value.absent(),
                Value<String?> trophyDisplayName = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                gamePlatform: gamePlatform,
                gameCode: gameCode,
                trophyDisplayName: trophyDisplayName,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String gamePlatform,
                required String gameCode,
                Value<String?> trophyDisplayName = const Value.absent(),
                required DateTime timestamp,
              }) => ActivitiesCompanion.insert(
                id: id,
                gamePlatform: gamePlatform,
                gameCode: gameCode,
                trophyDisplayName: trophyDisplayName,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>),
      Activity,
      PrefetchHooks Function()
    >;
typedef $$SteamCatalogTableCreateCompanionBuilder =
    SteamCatalogCompanion Function({Value<int> appId, required String name});
typedef $$SteamCatalogTableUpdateCompanionBuilder =
    SteamCatalogCompanion Function({Value<int> appId, Value<String> name});

class $$SteamCatalogTableFilterComposer
    extends Composer<_$AppDatabase, $SteamCatalogTable> {
  $$SteamCatalogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get appId => $composableBuilder(
    column: $table.appId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SteamCatalogTableOrderingComposer
    extends Composer<_$AppDatabase, $SteamCatalogTable> {
  $$SteamCatalogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get appId => $composableBuilder(
    column: $table.appId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SteamCatalogTableAnnotationComposer
    extends Composer<_$AppDatabase, $SteamCatalogTable> {
  $$SteamCatalogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get appId =>
      $composableBuilder(column: $table.appId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$SteamCatalogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SteamCatalogTable,
          SteamCatalogData,
          $$SteamCatalogTableFilterComposer,
          $$SteamCatalogTableOrderingComposer,
          $$SteamCatalogTableAnnotationComposer,
          $$SteamCatalogTableCreateCompanionBuilder,
          $$SteamCatalogTableUpdateCompanionBuilder,
          (
            SteamCatalogData,
            BaseReferences<_$AppDatabase, $SteamCatalogTable, SteamCatalogData>,
          ),
          SteamCatalogData,
          PrefetchHooks Function()
        > {
  $$SteamCatalogTableTableManager(_$AppDatabase db, $SteamCatalogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SteamCatalogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SteamCatalogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SteamCatalogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> appId = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => SteamCatalogCompanion(appId: appId, name: name),
          createCompanionCallback:
              ({
                Value<int> appId = const Value.absent(),
                required String name,
              }) => SteamCatalogCompanion.insert(appId: appId, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SteamCatalogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SteamCatalogTable,
      SteamCatalogData,
      $$SteamCatalogTableFilterComposer,
      $$SteamCatalogTableOrderingComposer,
      $$SteamCatalogTableAnnotationComposer,
      $$SteamCatalogTableCreateCompanionBuilder,
      $$SteamCatalogTableUpdateCompanionBuilder,
      (
        SteamCatalogData,
        BaseReferences<_$AppDatabase, $SteamCatalogTable, SteamCatalogData>,
      ),
      SteamCatalogData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$TrophiesTableTableManager get trophies =>
      $$TrophiesTableTableManager(_db, _db.trophies);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$SteamCatalogTableTableManager get steamCatalog =>
      $$SteamCatalogTableTableManager(_db, _db.steamCatalog);
}
