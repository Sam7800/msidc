import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/work_entry_section.dart';

/// Work Entry Provider - Manages work entry sections state
/// TODO: Implement full CRUD operations with database
class WorkEntryNotifier extends StateNotifier<AsyncValue<List<WorkEntrySection>>> {
  WorkEntryNotifier() : super(const AsyncValue.loading());

  /// Load all sections for a work entry
  Future<void> loadSections(int workEntryId) async {
    // TODO: Implement loading from database
    state = const AsyncValue.data([]);
  }

  /// Upsert (insert or update) a section
  Future<void> upsertSection(WorkEntrySection section) async {
    // TODO: Implement save to database
    // This will be connected to work_entry_repository
  }

  /// Delete a section
  Future<void> deleteSection(int sectionId) async {
    // TODO: Implement delete from database
  }
}

/// Provider instance
final workEntryProvider = StateNotifierProvider<WorkEntryNotifier, AsyncValue<List<WorkEntrySection>>>((ref) {
  return WorkEntryNotifier();
});
