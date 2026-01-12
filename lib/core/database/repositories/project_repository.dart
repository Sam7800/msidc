import '../../../data/models/project.dart';
import '../database_helper.dart';

/// ProjectRepository - Handles all CRUD operations for projects
class ProjectRepository {
  final DatabaseHelper _db;

  ProjectRepository(this._db);

  /// Get all projects
  Future<List<Project>> getProjects() async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.rawQuery('''
      SELECT
        p.*,
        c.name as category_name,
        c.color as category_color
      FROM projects p
      LEFT JOIN categories c ON p.category_id = c.id
      ORDER BY p.created_at DESC
    ''');

    return List.generate(maps.length, (i) => Project.fromJson(maps[i]));
  }

  /// Get projects by category
  Future<List<Project>> getProjectsByCategory(int categoryId) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.rawQuery('''
      SELECT
        p.*,
        c.name as category_name,
        c.color as category_color
      FROM projects p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.category_id = ?
      ORDER BY p.sr_no ASC
    ''', [categoryId]);

    return List.generate(maps.length, (i) => Project.fromJson(maps[i]));
  }

  /// Get project by ID
  Future<Project?> getProjectById(int id) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.rawQuery('''
      SELECT
        p.*,
        c.name as category_name,
        c.color as category_color
      FROM projects p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.id = ?
      LIMIT 1
    ''', [id]);

    if (maps.isEmpty) return null;
    return Project.fromJson(maps.first);
  }

  /// Get project by serial number
  Future<Project?> getProjectBySrNo(String srNo) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.rawQuery('''
      SELECT
        p.*,
        c.name as category_name,
        c.color as category_color
      FROM projects p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.sr_no = ?
      LIMIT 1
    ''', [srNo]);

    if (maps.isEmpty) return null;
    return Project.fromJson(maps.first);
  }

  /// Create project
  Future<int> createProject(Project project) async {
    final database = await _db.database;
    final id = await database.insert(
      'projects',
      project.toJsonForInsert(),
    );
    return id;
  }

  /// Update project
  Future<int> updateProject(Project project) async {
    final database = await _db.database;
    return await database.update(
      'projects',
      {
        'sr_no': project.srNo,
        'name': project.name,
        'category_id': project.categoryId,
        'status': project.status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  /// Delete project
  Future<int> deleteProject(int id) async {
    final database = await _db.database;
    return await database.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check if project serial number exists (for validation)
  Future<bool> projectSrNoExists(String srNo, {int? excludeId}) async {
    final database = await _db.database;
    final whereClause =
        excludeId != null ? 'sr_no = ? AND id != ?' : 'sr_no = ?';
    final whereArgs = excludeId != null ? [srNo, excludeId] : [srNo];

    final List<Map<String, dynamic>> maps = await database.query(
      'projects',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  /// Get projects by status
  Future<List<Project>> getProjectsByStatus(String status) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.rawQuery('''
      SELECT
        p.*,
        c.name as category_name,
        c.color as category_color
      FROM projects p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.status = ?
      ORDER BY p.created_at DESC
    ''', [status]);

    return List.generate(maps.length, (i) => Project.fromJson(maps[i]));
  }

  /// Search projects by name
  Future<List<Project>> searchProjects(String query) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.rawQuery('''
      SELECT
        p.*,
        c.name as category_name,
        c.color as category_color
      FROM projects p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.name LIKE ? OR p.sr_no LIKE ?
      ORDER BY p.created_at DESC
    ''', ['%$query%', '%$query%']);

    return List.generate(maps.length, (i) => Project.fromJson(maps[i]));
  }
}
