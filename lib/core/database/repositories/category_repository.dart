import '../../../data/models/category.dart';
import '../database_helper.dart';

/// CategoryRepository - Handles all CRUD operations for categories
///
/// This repository abstracts the data source (SQLite now, API later)
/// and provides a clean interface for UI to interact with category data.
class CategoryRepository {
  final DatabaseHelper _db;

  CategoryRepository(this._db);

  /// Get all categories
  Future<List<Category>> getCategories() async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'categories',
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Category.fromJson(maps[i]));
  }

  /// Get category by ID
  Future<Category?> getCategoryById(int id) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Category.fromJson(maps.first);
  }

  /// Get category by name
  Future<Category?> getCategoryByName(String name) async {
    final database = await _db.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Category.fromJson(maps.first);
  }

  /// Create category
  Future<int> createCategory(Category category) async {
    final database = await _db.database;
    final id = await database.insert(
      'categories',
      category.toJsonForInsert(),
    );
    return id;
  }

  /// Update category
  Future<int> updateCategory(Category category) async {
    final database = await _db.database;
    return await database.update(
      'categories',
      {
        'name': category.name,
        'color': category.color,
        'icon': category.icon,
        'description': category.description,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Delete category
  Future<int> deleteCategory(int id) async {
    final database = await _db.database;
    return await database.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check if category name exists (for validation)
  Future<bool> categoryNameExists(String name, {int? excludeId}) async {
    final database = await _db.database;
    final whereClause = excludeId != null ? 'name = ? AND id != ?' : 'name = ?';
    final whereArgs = excludeId != null ? [name, excludeId] : [name];

    final List<Map<String, dynamic>> maps = await database.query(
      'categories',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  /// Get count of projects in category
  Future<int> getProjectCount(int categoryId) async {
    final database = await _db.database;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM projects WHERE category_id = ?',
      [categoryId],
    );
    return result.first['count'] as int;
  }
}
