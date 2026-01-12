import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../core/database/repositories/category_repository.dart';
import '../../core/database/repositories/project_repository.dart';
import '../../core/database/repositories/work_entry_repository.dart';

/// Provider for DatabaseHelper singleton
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

/// Provider for CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CategoryRepository(dbHelper);
});

/// Provider for ProjectRepository
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return ProjectRepository(dbHelper);
});

/// Provider for WorkEntryRepository
final workEntryRepositoryProvider = Provider<WorkEntryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return WorkEntryRepository(dbHelper);
});
