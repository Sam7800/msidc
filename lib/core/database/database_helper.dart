import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// DatabaseHelper - Complete database management for MSIDC
///
/// Database Schema:
/// 1. categories - Project categories
/// 2. projects - Projects within categories
/// 3. work_entries - Main work entry per project (1:1)
/// 4. work_entry_sections - 33+ sections with JSON data
/// 5. section_attachments - File uploads
/// 6. milestones - 5 milestones (MS-I to MS-V)
/// 7. critical_subsections - Critical activities tracking
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('msidc.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
    );

    return db;
  }

  /// Enable foreign keys
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add icon column to categories table
      await db.execute('ALTER TABLE categories ADD COLUMN icon TEXT DEFAULT "folder"');
    }
    if (oldVersion < 3) {
      // Add critical_subsections table
      await db.execute('''
        CREATE TABLE critical_subsections (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          project_id INTEGER NOT NULL,
          section_name TEXT NOT NULL,
          option_name TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
          UNIQUE(project_id, section_name, option_name)
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_critical_project ON critical_subsections(project_id)
      ''');

      await db.execute('''
        CREATE INDEX idx_critical_section ON critical_subsections(section_name)
      ''');
    }
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    // ============================================
    // CORE TABLES
    // ============================================

    // 1. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL,
        icon TEXT DEFAULT 'folder',
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_categories_name ON categories(name)
    ''');

    // 2. Projects Table
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sr_no TEXT NOT NULL,
        name TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        status TEXT DEFAULT 'Pending',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_projects_category ON projects(category_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_projects_status ON projects(status)
    ''');

    await db.execute('''
      CREATE INDEX idx_projects_sr_no ON projects(sr_no)
    ''');

    // ============================================
    // WORK ENTRY TABLES
    // ============================================

    // 3. Work Entries Table (one per project)
    await db.execute('''
      CREATE TABLE work_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL UNIQUE,
        last_updated_by TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX idx_work_entries_project ON work_entries(project_id)
    ''');

    // 4. Work Entry Sections Table (33+ sections)
    await db.execute('''
      CREATE TABLE work_entry_sections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        work_entry_id INTEGER NOT NULL,
        section_name TEXT NOT NULL,
        section_data TEXT NOT NULL,
        person_responsible TEXT,
        pending_with TEXT,
        held_with TEXT,
        tab_imprint TEXT,
        status TEXT DEFAULT 'not_started',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (work_entry_id) REFERENCES work_entries (id) ON DELETE CASCADE,
        UNIQUE(work_entry_id, section_name)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_sections_work_entry ON work_entry_sections(work_entry_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_sections_name ON work_entry_sections(section_name)
    ''');

    await db.execute('''
      CREATE INDEX idx_sections_status ON work_entry_sections(status)
    ''');

    await db.execute('''
      CREATE INDEX idx_sections_person ON work_entry_sections(person_responsible)
    ''');

    // 5. Section Attachments Table (for photo uploads)
    await db.execute('''
      CREATE TABLE section_attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        section_id INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT,
        file_size INTEGER,
        uploaded_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (section_id) REFERENCES work_entry_sections (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_attachments_section ON section_attachments(section_id)
    ''');

    // 6. Milestones Table (MS-I to MS-V)
    await db.execute('''
      CREATE TABLE milestones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        work_entry_id INTEGER NOT NULL,
        milestone_name TEXT NOT NULL,
        period_months INTEGER,
        physical_target_percent REAL,
        financial_target_amount REAL,
        physical_achieved_percent REAL,
        financial_achieved_amount REAL,
        variance_amount REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (work_entry_id) REFERENCES work_entries (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_milestones_work_entry ON milestones(work_entry_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_milestones_name ON milestones(milestone_name)
    ''');

    // 7. Critical Subsections Table (for alert/critical activities)
    await db.execute('''
      CREATE TABLE critical_subsections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        section_name TEXT NOT NULL,
        option_name TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
        UNIQUE(project_id, section_name, option_name)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_critical_project ON critical_subsections(project_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_critical_section ON critical_subsections(section_name)
    ''');
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete database (for testing)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'msidc.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
