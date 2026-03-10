// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
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
  List<GeneratedColumn> get $columns => [
    appId,
    name,
    publisher,
    description,
    headerImage,
    libraryImage,
    addedAt,
    platformSource,
    isSynced,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {appId};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      appId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}app_id'],
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
}

class Game extends DataClass implements Insertable<Game> {
  final int appId;
  final String name;
  final List<String>? publisher;
  final String? description;
  final String? headerImage;
  final String? libraryImage;
  final DateTime? addedAt;
  final String platformSource;
  final bool isSynced;
  const Game({
    required this.appId,
    required this.name,
    this.publisher,
    this.description,
    this.headerImage,
    this.libraryImage,
    this.addedAt,
    required this.platformSource,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['app_id'] = Variable<int>(appId);
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
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      appId: Value(appId),
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
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      appId: serializer.fromJson<int>(json['appId']),
      name: serializer.fromJson<String>(json['name']),
      publisher: serializer.fromJson<List<String>?>(json['publisher']),
      description: serializer.fromJson<String?>(json['description']),
      headerImage: serializer.fromJson<String?>(json['headerImage']),
      libraryImage: serializer.fromJson<String?>(json['libraryImage']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
      platformSource: serializer.fromJson<String>(json['platformSource']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'appId': serializer.toJson<int>(appId),
      'name': serializer.toJson<String>(name),
      'publisher': serializer.toJson<List<String>?>(publisher),
      'description': serializer.toJson<String?>(description),
      'headerImage': serializer.toJson<String?>(headerImage),
      'libraryImage': serializer.toJson<String?>(libraryImage),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
      'platformSource': serializer.toJson<String>(platformSource),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Game copyWith({
    int? appId,
    String? name,
    Value<List<String>?> publisher = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> headerImage = const Value.absent(),
    Value<String?> libraryImage = const Value.absent(),
    Value<DateTime?> addedAt = const Value.absent(),
    String? platformSource,
    bool? isSynced,
  }) => Game(
    appId: appId ?? this.appId,
    name: name ?? this.name,
    publisher: publisher.present ? publisher.value : this.publisher,
    description: description.present ? description.value : this.description,
    headerImage: headerImage.present ? headerImage.value : this.headerImage,
    libraryImage: libraryImage.present ? libraryImage.value : this.libraryImage,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
    platformSource: platformSource ?? this.platformSource,
    isSynced: isSynced ?? this.isSynced,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      appId: data.appId.present ? data.appId.value : this.appId,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('appId: $appId, ')
          ..write('name: $name, ')
          ..write('publisher: $publisher, ')
          ..write('description: $description, ')
          ..write('headerImage: $headerImage, ')
          ..write('libraryImage: $libraryImage, ')
          ..write('addedAt: $addedAt, ')
          ..write('platformSource: $platformSource, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    appId,
    name,
    publisher,
    description,
    headerImage,
    libraryImage,
    addedAt,
    platformSource,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.appId == this.appId &&
          other.name == this.name &&
          other.publisher == this.publisher &&
          other.description == this.description &&
          other.headerImage == this.headerImage &&
          other.libraryImage == this.libraryImage &&
          other.addedAt == this.addedAt &&
          other.platformSource == this.platformSource &&
          other.isSynced == this.isSynced);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<int> appId;
  final Value<String> name;
  final Value<List<String>?> publisher;
  final Value<String?> description;
  final Value<String?> headerImage;
  final Value<String?> libraryImage;
  final Value<DateTime?> addedAt;
  final Value<String> platformSource;
  final Value<bool> isSynced;
  const GamesCompanion({
    this.appId = const Value.absent(),
    this.name = const Value.absent(),
    this.publisher = const Value.absent(),
    this.description = const Value.absent(),
    this.headerImage = const Value.absent(),
    this.libraryImage = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.platformSource = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  GamesCompanion.insert({
    this.appId = const Value.absent(),
    required String name,
    this.publisher = const Value.absent(),
    this.description = const Value.absent(),
    this.headerImage = const Value.absent(),
    this.libraryImage = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.platformSource = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Game> custom({
    Expression<int>? appId,
    Expression<String>? name,
    Expression<String>? publisher,
    Expression<String>? description,
    Expression<String>? headerImage,
    Expression<String>? libraryImage,
    Expression<DateTime>? addedAt,
    Expression<String>? platformSource,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (appId != null) 'app_id': appId,
      if (name != null) 'name': name,
      if (publisher != null) 'publisher': publisher,
      if (description != null) 'description': description,
      if (headerImage != null) 'header_image': headerImage,
      if (libraryImage != null) 'library_image': libraryImage,
      if (addedAt != null) 'added_at': addedAt,
      if (platformSource != null) 'platform_source': platformSource,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  GamesCompanion copyWith({
    Value<int>? appId,
    Value<String>? name,
    Value<List<String>?>? publisher,
    Value<String?>? description,
    Value<String?>? headerImage,
    Value<String?>? libraryImage,
    Value<DateTime?>? addedAt,
    Value<String>? platformSource,
    Value<bool>? isSynced,
  }) {
    return GamesCompanion(
      appId: appId ?? this.appId,
      name: name ?? this.name,
      publisher: publisher ?? this.publisher,
      description: description ?? this.description,
      headerImage: headerImage ?? this.headerImage,
      libraryImage: libraryImage ?? this.libraryImage,
      addedAt: addedAt ?? this.addedAt,
      platformSource: platformSource ?? this.platformSource,
      isSynced: isSynced ?? this.isSynced,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('appId: $appId, ')
          ..write('name: $name, ')
          ..write('publisher: $publisher, ')
          ..write('description: $description, ')
          ..write('headerImage: $headerImage, ')
          ..write('libraryImage: $libraryImage, ')
          ..write('addedAt: $addedAt, ')
          ..write('platformSource: $platformSource, ')
          ..write('isSynced: $isSynced')
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
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (app_id) ON DELETE CASCADE',
    ),
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
    gameId,
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
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {apiName, gameId};
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
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
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
  final int gameId;
  const Trophy({
    required this.apiName,
    required this.displayName,
    this.description,
    this.icon,
    this.coloredIcon,
    required this.isAchieved,
    this.achievedAt,
    required this.gameId,
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
    map['game_id'] = Variable<int>(gameId);
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
      gameId: Value(gameId),
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
      gameId: serializer.fromJson<int>(json['gameId']),
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
      'gameId': serializer.toJson<int>(gameId),
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
    int? gameId,
  }) => Trophy(
    apiName: apiName ?? this.apiName,
    displayName: displayName ?? this.displayName,
    description: description.present ? description.value : this.description,
    icon: icon.present ? icon.value : this.icon,
    coloredIcon: coloredIcon.present ? coloredIcon.value : this.coloredIcon,
    isAchieved: isAchieved ?? this.isAchieved,
    achievedAt: achievedAt.present ? achievedAt.value : this.achievedAt,
    gameId: gameId ?? this.gameId,
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
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
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
          ..write('gameId: $gameId')
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
    gameId,
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
          other.gameId == this.gameId);
}

class TrophiesCompanion extends UpdateCompanion<Trophy> {
  final Value<String> apiName;
  final Value<String> displayName;
  final Value<String?> description;
  final Value<String?> icon;
  final Value<String?> coloredIcon;
  final Value<bool> isAchieved;
  final Value<DateTime?> achievedAt;
  final Value<int> gameId;
  final Value<int> rowid;
  const TrophiesCompanion({
    this.apiName = const Value.absent(),
    this.displayName = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.coloredIcon = const Value.absent(),
    this.isAchieved = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.gameId = const Value.absent(),
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
    required int gameId,
    this.rowid = const Value.absent(),
  }) : apiName = Value(apiName),
       displayName = Value(displayName),
       gameId = Value(gameId);
  static Insertable<Trophy> custom({
    Expression<String>? apiName,
    Expression<String>? displayName,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<String>? coloredIcon,
    Expression<bool>? isAchieved,
    Expression<DateTime>? achievedAt,
    Expression<int>? gameId,
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
      if (gameId != null) 'game_id': gameId,
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
    Value<int>? gameId,
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
      gameId: gameId ?? this.gameId,
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
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
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
          ..write('gameId: $gameId, ')
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
  static const VerificationMeta _gameAppIdMeta = const VerificationMeta(
    'gameAppId',
  );
  @override
  late final GeneratedColumn<int> gameAppId = GeneratedColumn<int>(
    'game_app_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (app_id) ON DELETE CASCADE',
    ),
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
    gameAppId,
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
    if (data.containsKey('game_app_id')) {
      context.handle(
        _gameAppIdMeta,
        gameAppId.isAcceptableOrUnknown(data['game_app_id']!, _gameAppIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameAppIdMeta);
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
      gameAppId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_app_id'],
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
  final int gameAppId;
  final String? trophyDisplayName;
  final DateTime timestamp;
  const Activity({
    required this.id,
    required this.gameAppId,
    this.trophyDisplayName,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_app_id'] = Variable<int>(gameAppId);
    if (!nullToAbsent || trophyDisplayName != null) {
      map['trophy_display_name'] = Variable<String>(trophyDisplayName);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      gameAppId: Value(gameAppId),
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
      gameAppId: serializer.fromJson<int>(json['gameAppId']),
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
      'gameAppId': serializer.toJson<int>(gameAppId),
      'trophyDisplayName': serializer.toJson<String?>(trophyDisplayName),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  Activity copyWith({
    int? id,
    int? gameAppId,
    Value<String?> trophyDisplayName = const Value.absent(),
    DateTime? timestamp,
  }) => Activity(
    id: id ?? this.id,
    gameAppId: gameAppId ?? this.gameAppId,
    trophyDisplayName: trophyDisplayName.present
        ? trophyDisplayName.value
        : this.trophyDisplayName,
    timestamp: timestamp ?? this.timestamp,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      gameAppId: data.gameAppId.present ? data.gameAppId.value : this.gameAppId,
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
          ..write('gameAppId: $gameAppId, ')
          ..write('trophyDisplayName: $trophyDisplayName, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameAppId, trophyDisplayName, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.gameAppId == this.gameAppId &&
          other.trophyDisplayName == this.trophyDisplayName &&
          other.timestamp == this.timestamp);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<int> id;
  final Value<int> gameAppId;
  final Value<String?> trophyDisplayName;
  final Value<DateTime> timestamp;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.gameAppId = const Value.absent(),
    this.trophyDisplayName = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    this.id = const Value.absent(),
    required int gameAppId,
    this.trophyDisplayName = const Value.absent(),
    required DateTime timestamp,
  }) : gameAppId = Value(gameAppId),
       timestamp = Value(timestamp);
  static Insertable<Activity> custom({
    Expression<int>? id,
    Expression<int>? gameAppId,
    Expression<String>? trophyDisplayName,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameAppId != null) 'game_app_id': gameAppId,
      if (trophyDisplayName != null) 'trophy_display_name': trophyDisplayName,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  ActivitiesCompanion copyWith({
    Value<int>? id,
    Value<int>? gameAppId,
    Value<String?>? trophyDisplayName,
    Value<DateTime>? timestamp,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      gameAppId: gameAppId ?? this.gameAppId,
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
    if (gameAppId.present) {
      map['game_app_id'] = Variable<int>(gameAppId.value);
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
          ..write('gameAppId: $gameAppId, ')
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
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('trophies', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activities', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      Value<int> appId,
      required String name,
      Value<List<String>?> publisher,
      Value<String?> description,
      Value<String?> headerImage,
      Value<String?> libraryImage,
      Value<DateTime?> addedAt,
      Value<String> platformSource,
      Value<bool> isSynced,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<int> appId,
      Value<String> name,
      Value<List<String>?> publisher,
      Value<String?> description,
      Value<String?> headerImage,
      Value<String?> libraryImage,
      Value<DateTime?> addedAt,
      Value<String> platformSource,
      Value<bool> isSynced,
    });

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrophiesTable, List<Trophy>> _trophiesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.trophies,
    aliasName: $_aliasNameGenerator(db.games.appId, db.trophies.gameId),
  );

  $$TrophiesTableProcessedTableManager get trophiesRefs {
    final manager = $$TrophiesTableTableManager(
      $_db,
      $_db.trophies,
    ).filter((f) => f.gameId.appId.sqlEquals($_itemColumn<int>('app_id')!));

    final cache = $_typedResult.readTableOrNull(_trophiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivitiesTable, List<Activity>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: $_aliasNameGenerator(db.games.appId, db.activities.gameAppId),
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.gameAppId.appId.sqlEquals($_itemColumn<int>('app_id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
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

  Expression<bool> trophiesRefs(
    Expression<bool> Function($$TrophiesTableFilterComposer f) f,
  ) {
    final $$TrophiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appId,
      referencedTable: $db.trophies,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrophiesTableFilterComposer(
            $db: $db,
            $table: $db.trophies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.gameAppId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
  ColumnOrderings<int> get appId => $composableBuilder(
    column: $table.appId,
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
  GeneratedColumn<int> get appId =>
      $composableBuilder(column: $table.appId, builder: (column) => column);

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

  Expression<T> trophiesRefs<T extends Object>(
    Expression<T> Function($$TrophiesTableAnnotationComposer a) f,
  ) {
    final $$TrophiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appId,
      referencedTable: $db.trophies,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrophiesTableAnnotationComposer(
            $db: $db,
            $table: $db.trophies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.gameAppId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (Game, $$GamesTableReferences),
          Game,
          PrefetchHooks Function({bool trophiesRefs, bool activitiesRefs})
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
                Value<int> appId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<List<String>?> publisher = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> headerImage = const Value.absent(),
                Value<String?> libraryImage = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String> platformSource = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => GamesCompanion(
                appId: appId,
                name: name,
                publisher: publisher,
                description: description,
                headerImage: headerImage,
                libraryImage: libraryImage,
                addedAt: addedAt,
                platformSource: platformSource,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> appId = const Value.absent(),
                required String name,
                Value<List<String>?> publisher = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> headerImage = const Value.absent(),
                Value<String?> libraryImage = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String> platformSource = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => GamesCompanion.insert(
                appId: appId,
                name: name,
                publisher: publisher,
                description: description,
                headerImage: headerImage,
                libraryImage: libraryImage,
                addedAt: addedAt,
                platformSource: platformSource,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GamesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({trophiesRefs = false, activitiesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trophiesRefs) db.trophies,
                    if (activitiesRefs) db.activities,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trophiesRefs)
                        await $_getPrefetchedData<Game, $GamesTable, Trophy>(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._trophiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).trophiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.appId,
                              ),
                          typedResults: items,
                        ),
                      if (activitiesRefs)
                        await $_getPrefetchedData<Game, $GamesTable, Activity>(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._activitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).activitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameAppId == item.appId,
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
      (Game, $$GamesTableReferences),
      Game,
      PrefetchHooks Function({bool trophiesRefs, bool activitiesRefs})
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
      required int gameId,
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
      Value<int> gameId,
      Value<int> rowid,
    });

final class $$TrophiesTableReferences
    extends BaseReferences<_$AppDatabase, $TrophiesTable, Trophy> {
  $$TrophiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games.createAlias(
    $_aliasNameGenerator(db.trophies.gameId, db.games.appId),
  );

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.appId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.appId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.appId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.appId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (Trophy, $$TrophiesTableReferences),
          Trophy,
          PrefetchHooks Function({bool gameId})
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
                Value<int> gameId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrophiesCompanion(
                apiName: apiName,
                displayName: displayName,
                description: description,
                icon: icon,
                coloredIcon: coloredIcon,
                isAchieved: isAchieved,
                achievedAt: achievedAt,
                gameId: gameId,
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
                required int gameId,
                Value<int> rowid = const Value.absent(),
              }) => TrophiesCompanion.insert(
                apiName: apiName,
                displayName: displayName,
                description: description,
                icon: icon,
                coloredIcon: coloredIcon,
                isAchieved: isAchieved,
                achievedAt: achievedAt,
                gameId: gameId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrophiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
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
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$TrophiesTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$TrophiesTableReferences
                                    ._gameIdTable(db)
                                    .appId,
                              )
                              as T;
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
      (Trophy, $$TrophiesTableReferences),
      Trophy,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<int> id,
      required int gameAppId,
      Value<String?> trophyDisplayName,
      required DateTime timestamp,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<int> id,
      Value<int> gameAppId,
      Value<String?> trophyDisplayName,
      Value<DateTime> timestamp,
    });

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameAppIdTable(_$AppDatabase db) => db.games.createAlias(
    $_aliasNameGenerator(db.activities.gameAppId, db.games.appId),
  );

  $$GamesTableProcessedTableManager get gameAppId {
    final $_column = $_itemColumn<int>('game_app_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.appId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameAppIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  ColumnFilters<String> get trophyDisplayName => $composableBuilder(
    column: $table.trophyDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameAppId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameAppId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.appId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  ColumnOrderings<String> get trophyDisplayName => $composableBuilder(
    column: $table.trophyDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameAppId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameAppId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.appId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<String> get trophyDisplayName => $composableBuilder(
    column: $table.trophyDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameAppId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameAppId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.appId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (Activity, $$ActivitiesTableReferences),
          Activity,
          PrefetchHooks Function({bool gameAppId})
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
                Value<int> gameAppId = const Value.absent(),
                Value<String?> trophyDisplayName = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                gameAppId: gameAppId,
                trophyDisplayName: trophyDisplayName,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameAppId,
                Value<String?> trophyDisplayName = const Value.absent(),
                required DateTime timestamp,
              }) => ActivitiesCompanion.insert(
                id: id,
                gameAppId: gameAppId,
                trophyDisplayName: trophyDisplayName,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameAppId = false}) {
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
                    if (gameAppId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameAppId,
                                referencedTable: $$ActivitiesTableReferences
                                    ._gameAppIdTable(db),
                                referencedColumn: $$ActivitiesTableReferences
                                    ._gameAppIdTable(db)
                                    .appId,
                              )
                              as T;
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
      (Activity, $$ActivitiesTableReferences),
      Activity,
      PrefetchHooks Function({bool gameAppId})
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
