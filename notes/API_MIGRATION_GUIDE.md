# API Migration Guide: SQLite → PostgreSQL + Python Backend

**Purpose:** This document outlines the strategy for migrating from local SQLite database to a REST API backend with PostgreSQL database.

---

## 🎯 Current Architecture (Phase 4-7)

```
Flutter App (msidcv1)
    ↓
Repository Layer
    ↓
LocalDataSource (SQLite)
    ↓
sqflite_common_ffi
    ↓
SQLite Database (msidc.db)
```

---

## 🚀 Future Architecture (Phase 10+)

```
Flutter App (msidcv1)
    ↓
Repository Layer
    ↓
RemoteDataSource (API Client)
    ↓
HTTP/REST API (dio/http package)
    ↓
Python Backend (FastAPI/Django)
    ↓
PostgreSQL Database
```

---

## 📐 Design Principles (API-Ready)

### 1. Repository Pattern

**Goal:** Abstract the data source behind a repository interface

```dart
// Abstract interface (stays same for SQLite and API)
abstract class CategoryDataSource {
  Future<List<Category>> getCategories();
  Future<Category> getCategoryById(int id);
  Future<int> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
}

// SQLite implementation (Phase 4-9)
class CategoryLocalDataSource implements CategoryDataSource {
  final DatabaseHelper _db;

  @override
  Future<List<Category>> getCategories() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromJson(maps[i]));
  }

  // ... other methods using SQLite
}

// API implementation (Phase 10+)
class CategoryRemoteDataSource implements CategoryDataSource {
  final Dio _dio;
  final String baseUrl = 'https://api.msidc.com/v1';

  @override
  Future<List<Category>> getCategories() async {
    final response = await _dio.get('$baseUrl/categories');
    return (response.data['data'] as List)
        .map((json) => Category.fromJson(json))
        .toList();
  }

  // ... other methods using API
}

// Repository (UI uses this - same for SQLite and API)
class CategoryRepository {
  final CategoryDataSource _dataSource;

  CategoryRepository(this._dataSource);

  Future<List<Category>> getCategories() => _dataSource.getCategories();
  Future<Category> getCategoryById(int id) => _dataSource.getCategoryById(id);
  // ... delegates to data source
}
```

---

### 2. JSON-Serializable Models

**Goal:** Models can serialize to/from JSON for API communication

```dart
class Category {
  final int? id;
  final String name;
  final String color;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    this.id,
    required this.name,
    required this.color,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // For SQLite: fromJson converts Map<String, dynamic> from DB
  // For API: fromJson converts JSON response from API
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      name: json['name'] as String,
      color: json['color'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // For SQLite: toJson creates Map for DB insert/update
  // For API: toJson creates JSON for API request body
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // For SQLite inserts (without id, timestamps)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'name': name,
      'color': color,
      'description': description,
    };
  }
}
```

---

### 3. Dependency Injection with Riverpod

**Goal:** Easily swap data sources by changing provider

```dart
// Current (Phase 4-9): SQLite
final categoryDataSourceProvider = Provider<CategoryDataSource>((ref) {
  return CategoryLocalDataSource(DatabaseHelper.instance);
});

// Future (Phase 10+): API
final categoryDataSourceProvider = Provider<CategoryDataSource>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.msidc.com/v1',
    headers: {'Authorization': 'Bearer ${ref.read(authTokenProvider)}'},
  ));
  return CategoryRemoteDataSource(dio);
});

// Repository provider (stays same)
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.read(categoryDataSourceProvider));
});

// UI uses repository (no changes needed)
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  return await repository.getCategories();
});
```

---

## 🔄 Migration Steps (Phase 10+)

### Step 1: Setup API Client

```dart
// lib/core/api/api_client.dart
class ApiClient {
  final Dio _dio;

  ApiClient(String baseUrl, String? authToken) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ));

    // Add interceptors for logging, error handling
    _dio.interceptors.add(LogInterceptor());
  }

  Dio get dio => _dio;
}
```

---

### Step 2: Create Remote Data Sources

For each repository, create a `RemoteDataSource`:

```dart
// lib/core/api/data_sources/category_remote_data_source.dart
class CategoryRemoteDataSource implements CategoryDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDataSource(this._apiClient);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/categories');
      return (response.data['data'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Category> getCategoryById(int id) async {
    try {
      final response = await _apiClient.dio.get('/categories/$id');
      return Category.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<int> createCategory(Category category) async {
    try {
      final response = await _apiClient.dio.post(
        '/categories',
        data: category.toJson(),
      );
      return response.data['data']['id'] as int;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return UnauthorizedException();
    } else if (e.response?.statusCode == 404) {
      return NotFoundException();
    } else {
      return ServerException(e.message);
    }
  }
}
```

---

### Step 3: Update Providers

**Change only the data source provider:**

```dart
// Before (SQLite)
final categoryDataSourceProvider = Provider<CategoryDataSource>((ref) {
  return CategoryLocalDataSource(DatabaseHelper.instance);
});

// After (API)
final categoryDataSourceProvider = Provider<CategoryDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CategoryRemoteDataSource(apiClient);
});

// Repository provider stays same
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.read(categoryDataSourceProvider));
});
```

---

### Step 4: Handle Authentication

```dart
// lib/presentation/providers/auth_provider.dart

// Update AuthState to include token
class AuthState {
  final bool isAuthenticated;
  final String? username;
  final String? authToken;  // Add this
  // ...
}

// Login method returns token from API
Future<bool> login(String username, String password) async {
  try {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });

    final token = response.data['token'] as String;

    state = state.copyWith(
      isAuthenticated: true,
      username: username,
      authToken: token,
    );

    return true;
  } catch (e) {
    // Handle error
    return false;
  }
}

// Provide token to API client
final apiClientProvider = Provider<ApiClient>((ref) {
  final authState = ref.watch(authProvider);
  return ApiClient(
    'https://api.msidc.com/v1',
    authState.authToken,
  );
});
```

---

### Step 5: Work Entry Sections (JSON Storage)

**SQLite Approach (Phase 4-9):**
- Store section data as JSON text in `work_entry_sections.section_data` column
- Parse JSON when reading, stringify when writing

**API Approach (Phase 10+):**
- Send/receive section data as nested JSON objects
- Backend stores in PostgreSQL as JSONB (indexed, queryable)

```dart
// Model stays same for both SQLite and API
class WorkEntrySection {
  final int? id;
  final int workEntryId;
  final String sectionName;
  final Map<String, dynamic> sectionData;  // JSON
  final String? personResponsible;
  final String? pendingWith;
  final String? heldWith;
  final String status;

  // fromJson and toJson work for both SQLite and API
  factory WorkEntrySection.fromJson(Map<String, dynamic> json) {
    return WorkEntrySection(
      id: json['id'] as int?,
      workEntryId: json['work_entry_id'] as int,
      sectionName: json['section_name'] as String,
      sectionData: json['section_data'] is String
          ? jsonDecode(json['section_data'])  // SQLite: parse string
          : json['section_data'],              // API: already parsed
      personResponsible: json['person_responsible'] as String?,
      pendingWith: json['pending_with'] as String?,
      heldWith: json['held_with'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'work_entry_id': workEntryId,
      'section_name': sectionName,
      'section_data': sectionData,  // API: nested JSON
      'person_responsible': personResponsible,
      'pending_with': pendingWith,
      'held_with': heldWith,
      'status': status,
    };
  }

  // For SQLite: stringify section_data
  Map<String, dynamic> toJsonForSQLite() {
    return {
      ...toJson(),
      'section_data': jsonEncode(sectionData),
    };
  }
}
```

---

## 📦 Dependencies for API (Phase 10+)

Add to `pubspec.yaml`:

```yaml
dependencies:
  # HTTP client
  dio: ^5.4.0

  # JSON serialization (optional, for code generation)
  json_annotation: ^4.8.1

dev_dependencies:
  # JSON code generation (optional)
  json_serializable: ^6.7.1
  build_runner: ^2.4.6
```

---

## 🔐 Backend API Contract (Python)

### Expected Endpoints

```
POST   /auth/login                    - Login, return JWT token
POST   /auth/logout                   - Logout
GET    /auth/me                       - Get current user

GET    /categories                    - List all categories
GET    /categories/:id                - Get category by ID
POST   /categories                    - Create category
PUT    /categories/:id                - Update category
DELETE /categories/:id                - Delete category

GET    /projects                      - List all projects (with filters)
GET    /projects/:id                  - Get project by ID
POST   /projects                      - Create project
PUT    /projects/:id                  - Update project
DELETE /projects/:id                  - Delete project

GET    /work-entries/:projectId       - Get work entry for project
POST   /work-entries                  - Create work entry
PUT    /work-entries/:id              - Update work entry

GET    /work-entry-sections/:workEntryId  - Get all sections
POST   /work-entry-sections               - Create section
PUT    /work-entry-sections/:id           - Update section
DELETE /work-entry-sections/:id           - Delete section

POST   /attachments                   - Upload file
GET    /attachments/:id               - Download file
DELETE /attachments/:id               - Delete file

GET    /milestones/:workEntryId       - Get milestones
POST   /milestones                    - Create milestone
PUT    /milestones/:id                - Update milestone
```

### Expected Response Format

```json
{
  "success": true,
  "data": { ... },
  "message": "Success",
  "timestamp": "2026-01-12T10:30:00Z"
}
```

### Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": { ... }
  },
  "timestamp": "2026-01-12T10:30:00Z"
}
```

---

## ✅ Migration Checklist

### Phase 10: API Migration

- [ ] Add dio dependency
- [ ] Create ApiClient class
- [ ] Create RemoteDataSource for each repository
- [ ] Update auth_provider to handle JWT tokens
- [ ] Replace LocalDataSource providers with RemoteDataSource
- [ ] Test all CRUD operations with API
- [ ] Handle offline mode (optional: cache with Hive/sqflite)
- [ ] Add retry logic for failed requests
- [ ] Add loading states for API calls
- [ ] Test error handling (401, 404, 500, network errors)

### Backend (Python Team)

- [ ] Setup PostgreSQL database
- [ ] Create Python backend (FastAPI/Django)
- [ ] Implement JWT authentication
- [ ] Create all API endpoints
- [ ] Setup CORS for Flutter app
- [ ] Add validation (pydantic models)
- [ ] Add database migrations (Alembic)
- [ ] Setup file upload for attachments
- [ ] Add API documentation (Swagger/OpenAPI)
- [ ] Deploy backend to server
- [ ] Configure HTTPS
- [ ] Setup logging and monitoring

---

## 🎯 Benefits of This Approach

1. **Minimal Changes:** Only data source providers change, UI stays same
2. **Gradual Migration:** Can migrate one repository at a time
3. **Testability:** Can mock data sources easily
4. **Offline Support:** Can keep SQLite for offline mode alongside API
5. **Type Safety:** Compile-time checking for data models
6. **Maintainability:** Clear separation of concerns

---

## 📝 Notes

- **SQLite → API migration is straightforward** with repository pattern
- **UI layer remains unchanged** - screens, widgets, providers stay same
- **Models are reusable** - same models for SQLite and API
- **Backend team has clear API contract** to implement
- **Can support offline mode** by using both SQLite cache and API

---

**Last Updated:** 2026-01-12
