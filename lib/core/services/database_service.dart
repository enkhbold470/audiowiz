import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:audiowiz/core/models/recording.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  
  DatabaseService._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }
  
  Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'audiowiz.db');
    
    // Delete existing database during development
    try {
      await deleteDatabase(path);
      print('Deleted existing database to update schema');
    } catch (e) {
      print('Error deleting database: $e');
    }
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }
  
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recordings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE,
        title TEXT,
        filePath TEXT,
        createdAt TEXT,
        durationInSeconds INTEGER,
        transcription TEXT,
        summary TEXT,
        isProcessed INTEGER,
        isFavorite INTEGER,
        supabaseId TEXT
      )
    ''');
  }
  
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE recordings ADD COLUMN supabaseId TEXT');
      print('Database upgraded: Added supabaseId column');
    }
  }
  
  // CRUD operations for recordings
  
  Future<List<Recording>> getAllRecordings() async {
    final db = await database;
    final recordingsData = await db.query('recordings', orderBy: 'createdAt DESC');
    
    return recordingsData.map((recordingMap) => Recording.fromMap(recordingMap)).toList();
  }
  
  Future<Recording?> getRecordingById(int id) async {
    final db = await database;
    final recordingsData = await db.query(
      'recordings',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (recordingsData.isEmpty) return null;
    return Recording.fromMap(recordingsData.first);
  }
  
  Future<Recording?> getRecordingByUuid(String uuid) async {
    final db = await database;
    final recordingsData = await db.query(
      'recordings',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    
    if (recordingsData.isEmpty) return null;
    return Recording.fromMap(recordingsData.first);
  }
  
  Future<int> insertRecording(Recording recording) async {
    final db = await database;
    
    return await db.insert(
      'recordings',
      recording.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<int> updateRecording(Recording recording) async {
    final db = await database;
    return await db.update(
      'recordings',
      recording.toMap(),
      where: 'id = ?',
      whereArgs: [recording.id],
    );
  }
  
  Future<int> deleteRecording(int id) async {
    final db = await database;
    return await db.delete(
      'recordings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<List<Recording>> searchRecordings(String query) async {
    final db = await database;
    final recordingsData = await db.query(
      'recordings',
      where: 'title LIKE ? OR transcription LIKE ? OR summary LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    
    return recordingsData.map((recordingMap) => Recording.fromMap(recordingMap)).toList();
  }
  
  Future<List<Recording>> getFavoriteRecordings() async {
    final db = await database;
    final recordingsData = await db.query(
      'recordings',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    
    return recordingsData.map((recordingMap) => Recording.fromMap(recordingMap)).toList();
  }
} 