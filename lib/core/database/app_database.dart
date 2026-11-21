import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return List<String>.from(json.decode(fromDb));
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

class Games extends Table {
  /// The store (`steam` or `psn`) and the game's code there: together they
  /// identify the game, so ids of different stores can never clash.
  TextColumn get platform => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get publisher =>
      text().map(const StringListConverter()).nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get headerImage => text().nullable()();
  TextColumn get libraryImage => text().nullable()();
  DateTimeColumn get addedAt => dateTime().nullable()();
  TextColumn get platformSource =>
      text().withDefault(const Constant('local'))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// The consoles of a PlayStation game, as a list of names (`PS5`, `PS4`).
  TextColumn get consoles =>
      text().map(const StringListConverter()).nullable()();

  /// When the platform last updated the game's trophies, as it said.
  DateTimeColumn get remoteUpdatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {platform, code};
}

class Trophies extends Table {
  TextColumn get apiName => text()();
  TextColumn get displayName => text()();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get coloredIcon => text().nullable()();
  BoolColumn get isAchieved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get achievedAt => dateTime().nullable()();

  /// `bronze`, `silver`, `gold` or `platinum`, for PlayStation trophies.
  TextColumn get type => text().nullable()();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();

  /// The share of players who earned it, from 0 to 100.
  RealColumn get rarity => real().nullable()();
  TextColumn get gamePlatform => text()();
  TextColumn get gameCode => text()();

  @override
  Set<Column> get primaryKey => {apiName, gamePlatform, gameCode};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (game_platform, game_code) REFERENCES games (platform, code) ON DELETE CASCADE',
  ];
}

class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get gamePlatform => text()();
  TextColumn get gameCode => text()();
  TextColumn get trophyDisplayName => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (game_platform, game_code) REFERENCES games (platform, code) ON DELETE CASCADE',
  ];
}

class SteamCatalog extends Table {
  IntColumn get appId => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {appId};
}

@DriftDatabase(tables: [Games, Trophies, Activities, SteamCatalog])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  /// Schema upgrades, plus `PRAGMA foreign_keys = ON` on every connection:
  /// SQLite ignores `onDelete: cascade` unless it is enabled.
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 3) {
          await m.addColumn(games, games.isSynced);
        }
      },
      beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
    );
  }
}

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'trophies_tracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
