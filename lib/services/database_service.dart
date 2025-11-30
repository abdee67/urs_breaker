import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'goal_breaker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        complexity INTEGER,
        steps TEXT
      )
    ''');
  }

  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    // Remove id if it's null so autoincrement works
    var map = goal.toMap();
    if (map['id'] == null) {
      map.remove('id');
    }
    return await db.insert(
      'goals',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return Goal.fromMap(maps[i]);
    });
  }
}
