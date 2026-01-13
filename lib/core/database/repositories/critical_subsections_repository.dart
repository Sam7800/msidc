import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

/// Repository for managing critical subsections (alert/critical activities)
class CriticalSubsectionsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Mark a subsection as critical
  Future<int> markAsCritical(
    int projectId,
    String sectionName,
    String optionName,
  ) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'critical_subsections',
      {
        'project_id': projectId,
        'section_name': sectionName,
        'option_name': optionName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove a subsection from critical
  Future<int> removeCritical(
    int projectId,
    String sectionName,
    String optionName,
  ) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'critical_subsections',
      where: 'project_id = ? AND section_name = ? AND option_name = ?',
      whereArgs: [projectId, sectionName, optionName],
    );
  }

  /// Toggle critical status and return new state (true = now critical, false = now not critical)
  Future<bool> toggleCritical(
    int projectId,
    String sectionName,
    String optionName,
  ) async {
    final isCriticalNow = await isCritical(projectId, sectionName, optionName);

    if (isCriticalNow) {
      await removeCritical(projectId, sectionName, optionName);
      return false;
    } else {
      await markAsCritical(projectId, sectionName, optionName);
      return true;
    }
  }

  /// Check if a subsection is marked as critical
  Future<bool> isCritical(
    int projectId,
    String sectionName,
    String optionName,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'critical_subsections',
      where: 'project_id = ? AND section_name = ? AND option_name = ?',
      whereArgs: [projectId, sectionName, optionName],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Get all critical subsections for a specific project
  Future<List<Map<String, dynamic>>> getCriticalSubsectionsByProjectId(
    int projectId,
  ) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT
        cs.*,
        p.name as project_name,
        p.sr_no as project_sr_no,
        c.name as category_name,
        wes.person_responsible,
        wes.pending_with
      FROM critical_subsections cs
      INNER JOIN projects p ON cs.project_id = p.id
      INNER JOIN categories c ON p.category_id = c.id
      LEFT JOIN work_entries we ON we.project_id = p.id
      LEFT JOIN work_entry_sections wes ON wes.work_entry_id = we.id AND wes.section_name = cs.section_name
      WHERE cs.project_id = ?
      ORDER BY cs.section_name ASC, cs.option_name ASC
    ''', [projectId]);
  }

  /// Get all critical subsections across all projects
  Future<List<Map<String, dynamic>>> getAllCriticalSubsections() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT
        cs.*,
        p.name as project_name,
        p.sr_no as project_sr_no,
        c.name as category_name,
        wes.person_responsible,
        wes.pending_with
      FROM critical_subsections cs
      INNER JOIN projects p ON cs.project_id = p.id
      INNER JOIN categories c ON p.category_id = c.id
      LEFT JOIN work_entries we ON we.project_id = p.id
      LEFT JOIN work_entry_sections wes ON wes.work_entry_id = we.id AND wes.section_name = cs.section_name
      ORDER BY p.name ASC, cs.section_name ASC
    ''');
  }

  /// Get critical subsections filtered by category
  Future<List<Map<String, dynamic>>> getCriticalSubsectionsByCategory(
    int categoryId,
  ) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT
        cs.*,
        p.name as project_name,
        p.sr_no as project_sr_no,
        c.name as category_name,
        wes.person_responsible,
        wes.pending_with
      FROM critical_subsections cs
      INNER JOIN projects p ON cs.project_id = p.id
      INNER JOIN categories c ON p.category_id = c.id
      LEFT JOIN work_entries we ON we.project_id = p.id
      LEFT JOIN work_entry_sections wes ON wes.work_entry_id = we.id AND wes.section_name = cs.section_name
      WHERE c.id = ?
      ORDER BY p.name ASC, cs.section_name ASC
    ''', [categoryId]);
  }

  /// Delete all critical subsections for a specific project
  Future<int> deleteAllForProject(int projectId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'critical_subsections',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  /// Get count of critical subsections for a project
  Future<int> getCriticalCount(int projectId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM critical_subsections WHERE project_id = ?',
      [projectId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get count of all critical subsections across all projects
  Future<int> getTotalCriticalCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM critical_subsections',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
