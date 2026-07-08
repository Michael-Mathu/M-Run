import 'package:drift/drift.dart';

// ponytail: stub tables - will be converted to proper drift tables with build_runner
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().named('display_name')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get settingsJson => text().named('settings_json')();

  @override
  Set<Column> get primaryKey => {id};
}

class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  RealColumn get distanceM => real().named('distance_m')();

  @override
  Set<Column> get primaryKey => {id};
}