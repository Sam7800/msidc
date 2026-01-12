import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project.dart';
import '../../core/database/repositories/project_repository.dart';
import 'repository_providers.dart';

/// Project State
class ProjectState {
  final List<Project> projects;
  final bool isLoading;
  final String? error;

  ProjectState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
  });

  ProjectState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Project Provider (Notifier)
class ProjectNotifier extends StateNotifier<ProjectState> {
  final ProjectRepository _repository;

  ProjectNotifier(this._repository) : super(ProjectState());

  /// Load all projects
  Future<void> loadAllProjects() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final projects = await _repository.getProjects();
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Load projects by category ID
  Future<void> loadProjectsByCategoryId(int categoryId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final projects = await _repository.getProjectsByCategory(categoryId);
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Load projects by status
  Future<void> loadProjectsByStatus(String status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final projects = await _repository.getProjectsByStatus(status);
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Search projects
  Future<void> searchProjects(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final projects = await _repository.searchProjects(query);
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Add new project
  Future<bool> addProject(Project project) async {
    try {
      // Check if SR No already exists
      final exists = await _repository.projectSrNoExists(project.srNo);
      if (exists) {
        state = state.copyWith(error: 'Project SR No already exists');
        return false;
      }

      final id = await _repository.createProject(project);
      if (id > 0) {
        await loadProjectsByCategoryId(project.categoryId);
        return true;
      }
      state = state.copyWith(error: 'Failed to create project');
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update project
  Future<bool> updateProject(Project project) async {
    try {
      // Check if SR No already exists (excluding current project)
      final exists = await _repository.projectSrNoExists(
        project.srNo,
        excludeId: project.id,
      );
      if (exists) {
        state = state.copyWith(error: 'Project SR No already exists');
        return false;
      }

      final count = await _repository.updateProject(project);
      if (count > 0) {
        await loadProjectsByCategoryId(project.categoryId);
        return true;
      }
      state = state.copyWith(error: 'Failed to update project');
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete project
  Future<bool> deleteProject(int id, int categoryId) async {
    try {
      final count = await _repository.deleteProject(id);
      if (count > 0) {
        await loadProjectsByCategoryId(categoryId);
        return true;
      }
      state = state.copyWith(error: 'Failed to delete project');
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Get project by ID
  Future<Project?> getProjectById(int id) async {
    try {
      return await _repository.getProjectById(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Get project by SR No
  Future<Project?> getProjectBySrNo(String srNo) async {
    try {
      return await _repository.getProjectBySrNo(srNo);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

/// Project Provider
final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectNotifier(repository);
});

/// Project count by category provider
final projectCountByCategoryProvider = FutureProvider<Map<int, int>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  final projects = await repository.getProjects();

  final Map<int, int> counts = {};
  for (final project in projects) {
    counts[project.categoryId] = (counts[project.categoryId] ?? 0) + 1;
  }

  return counts;
});
