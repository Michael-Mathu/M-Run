// ponytail: stub database for Month 2 development
// Run: flutter pub run build_runner build to generate real drift implementation
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();
}