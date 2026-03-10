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
  IntColumn get appId => integer()();
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

  @override
  Set<Column> get primaryKey => {appId};
}

class Trophies extends Table {
  TextColumn get apiName => text()();
  TextColumn get displayName => text()();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get coloredIcon => text().nullable()();
  BoolColumn get isAchieved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get achievedAt => dateTime().nullable()();
  IntColumn get gameId =>
      integer().references(Games, #appId, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {apiName, gameId};
}

class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameAppId =>
      integer().references(Games, #appId, onDelete: KeyAction.cascade)();
  TextColumn get trophyDisplayName => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
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

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 3) {
          await m.addColumn(games, games.isSynced);
        }
      },
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
