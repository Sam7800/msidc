import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category.dart';
import '../../core/database/repositories/category_repository.dart';
import 'repository_providers.dart';

/// Category State
class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Category Provider (Notifier)
class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super(CategoryState()) {
    loadCategories();
  }

  /// Load all categories
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _repository.getCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Add new category
  Future<bool> addCategory(Category category) async {
    try {
      // Check if name already exists
      final exists = await _repository.categoryNameExists(category.name);
      if (exists) {
        state = state.copyWith(error: 'Category name already exists');
        return false;
      }

      final id = await _repository.createCategory(category);
      if (id > 0) {
        await loadCategories();
        return true;
      }
      state = state.copyWith(error: 'Failed to create category');
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update category
  Future<bool> updateCategory(Category category) async {
    try {
      // Check if name already exists (excluding current category)
      final exists = await _repository.categoryNameExists(
        category.name,
        excludeId: category.id,
      );
      if (exists) {
        state = state.copyWith(error: 'Category name already exists');
        return false;
      }

      final count = await _repository.updateCategory(category);
      if (count > 0) {
        await loadCategories();
        return true;
      }
      state = state.copyWith(error: 'Failed to update category');
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete category
  Future<bool> deleteCategory(int id) async {
    try {
      // Check if category has projects
      final projectCount = await _repository.getProjectCount(id);
      if (projectCount > 0) {
        state = state.copyWith(
          error: 'Cannot delete category with $projectCount project(s)',
        );
        return false;
      }

      final count = await _repository.deleteCategory(id);
      if (count > 0) {
        await loadCategories();
        return true;
      }
      state = state.copyWith(error: 'Failed to delete category');
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Get category by ID
  Future<Category?> getCategoryById(int id) async {
    try {
      return await _repository.getCategoryById(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

/// Category Provider
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryNotifier(repository);
});

/// Categories with project counts provider
final categoriesWithCountsProvider = FutureProvider<Map<Category, int>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final categories = await repository.getCategories();

  final Map<Category, int> counts = {};
  for (final category in categories) {
    final count = await repository.getProjectCount(category.id!);
    counts[category] = count;
  }

  return counts;
});
