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
    return await openDatabase(
      path,
      version: 2, // Bumped version for migration
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create goals table with new schema
    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        complexity INTEGER,
        milestones TEXT,
        assumptions TEXT,
        risks TEXT,
        thought_signature TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from v1 to v2
      // Drop old table and recreate (simple migration, loses data)
      // In production, you'd want to migrate existing data
      await db.execute('DROP TABLE IF EXISTS goals');
      await _onCreate(db, newVersion);
    }
  }

  Future<int> insertGoal(Goal goal) async {
    final db = await database;
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

  Future<void> updateGoal(Goal goal) async {
    final db = await database;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(int id) async {
    final db = await database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
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

  Future<Goal?> getGoalById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Goal.fromMap(maps.first);
  }
}
