import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/work_entry.dart';
import '../../../data/models/work_entry_section.dart';
import '../../../data/models/section_attachment.dart';
import '../../../data/models/milestone.dart';
import '../database_helper.dart';

// Riverpod providers
final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);
final workEntryRepositoryProvider = Provider<WorkEntryRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return WorkEntryRepository(db);
});

/// WorkEntryRepository - Handles all CRUD operations for work entries, sections, attachments, and milestones
///
/// This is the main repository for the 33-section work entry form.
/// It provides methods to:
/// - Create/Read/Update/Delete work entries
/// - Create/Read/Update/Delete work entry sections (33+ types)
/// - Create/Read/Delete section attachments (photos, PDFs)
/// - Create/Read/Update/Delete milestones (MS-I to MS-V)
class WorkEntryRepository {
  final DatabaseHelper _db;

  WorkEntryRepository(this._db);

  // ============================================
  // WORK ENTRY CRUD
  // ============================================

  /// Get work entry by project ID
  Future<WorkEntry?> getWorkEntryByProjectId(int projectId) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'work_entries',
      where: 'project_id = ?',
      whereArgs: [projectId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return WorkEntry.fromJson(maps.first);
  }

  /// Get work entry by ID
  Future<WorkEntry?> getWorkEntryById(int id) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'work_entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return WorkEntry.fromJson(maps.first);
  }

  /// Create work entry
  Future<int> createWorkEntry(WorkEntry workEntry) async {
    final database = await _db.database;
    final id = await database.insert(
      'work_entries',
      workEntry.toJsonForInsert(),
    );
    return id;
  }

  /// Update work entry
  Future<int> updateWorkEntry(WorkEntry workEntry) async {
    final database = await _db.database;
    return await database.update(
      'work_entries',
      {
        'last_updated_by': workEntry.lastUpdatedBy,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [workEntry.id],
    );
  }

  /// Delete work entry (cascades to sections, attachments, milestones)
  Future<int> deleteWorkEntry(int id) async {
    final database = await _db.database;
    return await database.delete(
      'work_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================
  // WORK ENTRY SECTION CRUD
  // ============================================

  /// Get all sections for a work entry
  Future<List<WorkEntrySection>> getSectionsByWorkEntryId(
      int workEntryId) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'work_entry_sections',
      where: 'work_entry_id = ?',
      whereArgs: [workEntryId],
      orderBy: 'section_name ASC',
    );

    return List.generate(maps.length, (i) => WorkEntrySection.fromJson(maps[i]));
  }

  /// Get section by work entry ID and section name
  Future<WorkEntrySection?> getSectionByName(
      int workEntryId, String sectionName) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'work_entry_sections',
      where: 'work_entry_id = ? AND section_name = ?',
      whereArgs: [workEntryId, sectionName],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return WorkEntrySection.fromJson(maps.first);
  }

  /// Get section by ID
  Future<WorkEntrySection?> getSectionById(int id) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'work_entry_sections',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return WorkEntrySection.fromJson(maps.first);
  }

  /// Create or update section (upsert)
  Future<int> upsertSection(WorkEntrySection section) async {
    final database = await _db.database;

    // Check if section exists
    final existing = await getSectionByName(
      section.workEntryId,
      section.sectionName,
    );

    if (existing != null) {
      // Update existing section
      final updateData = section.toJsonForSQLite();
      updateData.remove('id'); // Remove id field to avoid datatype mismatch error
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await database.update(
        'work_entry_sections',
        updateData,
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return existing.id!;
    } else {
      // Insert new section
      return await database.insert(
        'work_entry_sections',
        section.toJsonForInsert(),
      );
    }
  }

  /// Delete section
  Future<int> deleteSection(int id) async {
    final database = await _db.database;
    return await database.delete(
      'work_entry_sections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get sections by status
  Future<List<WorkEntrySection>> getSectionsByStatus(
      int workEntryId, String status) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'work_entry_sections',
      where: 'work_entry_id = ? AND status = ?',
      whereArgs: [workEntryId, status],
      orderBy: 'section_name ASC',
    );

    return List.generate(maps.length, (i) => WorkEntrySection.fromJson(maps[i]));
  }

  /// Get sections by person responsible
  Future<List<WorkEntrySection>> getSectionsByPerson(
      int workEntryId, String personName) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'work_entry_sections',
      where: 'work_entry_id = ? AND person_responsible LIKE ?',
      whereArgs: [workEntryId, '%$personName%'],
      orderBy: 'section_name ASC',
    );

    return List.generate(maps.length, (i) => WorkEntrySection.fromJson(maps[i]));
  }

  // ============================================
  // SECTION ATTACHMENT CRUD
  // ============================================

  /// Get attachments by section ID
  Future<List<SectionAttachment>> getAttachmentsBySectionId(
      int sectionId) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'section_attachments',
      where: 'section_id = ?',
      whereArgs: [sectionId],
      orderBy: 'uploaded_at DESC',
    );

    return List.generate(
        maps.length, (i) => SectionAttachment.fromJson(maps[i]));
  }

  /// Get attachment by ID
  Future<SectionAttachment?> getAttachmentById(int id) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'section_attachments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return SectionAttachment.fromJson(maps.first);
  }

  /// Create attachment
  Future<int> createAttachment(SectionAttachment attachment) async {
    final database = await _db.database;
    return await database.insert(
      'section_attachments',
      attachment.toJsonForInsert(),
    );
  }

  /// Delete attachment
  Future<int> deleteAttachment(int id) async {
    final database = await _db.database;
    return await database.delete(
      'section_attachments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================
  // MILESTONE CRUD
  // ============================================

  /// Get all milestones for a work entry
  Future<List<Milestone>> getMilestonesByWorkEntryId(int workEntryId) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'milestones',
      where: 'work_entry_id = ?',
      whereArgs: [workEntryId],
      orderBy: 'milestone_name ASC',
    );

    return List.generate(maps.length, (i) => Milestone.fromJson(maps[i]));
  }

  /// Get milestone by ID
  Future<Milestone?> getMilestoneById(int id) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'milestones',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Milestone.fromJson(maps.first);
  }

  /// Create milestone
  Future<int> createMilestone(Milestone milestone) async {
    final database = await _db.database;
    return await database.insert(
      'milestones',
      milestone.toJsonForInsert(),
    );
  }

  /// Update milestone
  Future<int> updateMilestone(Milestone milestone) async {
    final database = await _db.database;
    return await database.update(
      'milestones',
      {
        ...milestone.toJsonForInsert(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [milestone.id],
    );
  }

  /// Delete milestone
  Future<int> deleteMilestone(int id) async {
    final database = await _db.database;
    return await database.delete(
      'milestones',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Upsert milestone (create or update by work_entry_id and milestone_name)
  Future<int> upsertMilestone(Milestone milestone) async {
    final database = await _db.database;

    // Check if milestone exists
    final List<Map<String, dynamic>> maps = await database.query(
      'milestones',
      where: 'work_entry_id = ? AND milestone_name = ?',
      whereArgs: [milestone.workEntryId, milestone.milestoneName],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      // Update existing
      final existing = Milestone.fromJson(maps.first);
      await database.update(
        'milestones',
        {
          ...milestone.toJsonForInsert(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return existing.id!;
    } else {
      // Insert new
      return await database.insert(
        'milestones',
        milestone.toJsonForInsert(),
      );
    }
  }

  // ============================================
  // STATISTICS & ANALYTICS
  // ============================================

  /// Get section completion statistics
  Future<Map<String, int>> getSectionStatistics(int workEntryId) async {
    final database = await _db.database;
    final result = await database.rawQuery('''
      SELECT
        status,
        COUNT(*) as count
      FROM work_entry_sections
      WHERE work_entry_id = ?
      GROUP BY status
    ''', [workEntryId]);

    final stats = <String, int>{};
    for (final row in result) {
      stats[row['status'] as String] = row['count'] as int;
    }
    return stats;
  }

  /// Get total sections count
  Future<int> getTotalSectionsCount(int workEntryId) async {
    final database = await _db.database;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM work_entry_sections WHERE work_entry_id = ?',
      [workEntryId],
    );
    return result.first['count'] as int;
  }

  /// Get completed sections count
  Future<int> getCompletedSectionsCount(int workEntryId) async {
    final database = await _db.database;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM work_entry_sections WHERE work_entry_id = ? AND status = ?',
      [workEntryId, 'completed'],
    );
    return result.first['count'] as int;
  }
}
