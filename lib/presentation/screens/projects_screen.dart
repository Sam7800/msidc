import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../data/models/project.dart';
import '../../data/models/category.dart';
import '../providers/project_provider.dart';
import '../widgets/dialogs/create_project_dialog.dart';
import 'project_detail_screen.dart';
import 'critical_activities_screen.dart';

/// Projects Screen - Shows projects within a selected category
///
/// Navigation: Categories → Projects (HERE) → Details
class ProjectsScreen extends ConsumerStatefulWidget {
  final Category category;

  const ProjectsScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.category.id != null) {
        ref
            .read(projectProvider.notifier)
            .loadProjectsByCategoryId(widget.category.id!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateProject() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateProjectDialog(
        preselectedCategory: widget.category,
      ),
    );

    if (result == true && mounted) {
      if (widget.category.id != null) {
        ref
            .read(projectProvider.notifier)
            .loadProjectsByCategoryId(widget.category.id!);
      }
    }
  }

  Future<void> _handleDeleteProject(Project project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted && project.id != null) {
      final success = await ref
          .read(projectProvider.notifier)
          .deleteProject(project.id!, project.categoryId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Project "${project.name}" deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final error = ref.read(projectProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to delete project'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final categoryColor = widget.category.getColor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: categoryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                widget.category.getIcon(),
                size: 18,
                color: categoryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Projects',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: categoryColor,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, size: 24),
            tooltip: 'Critical Activities',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CriticalActivitiesScreen(
                    categoryId: widget.category.id,
                  ),
                ),
              );
            },
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            tooltip: 'Create Project',
            onPressed: _handleCreateProject,
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            tooltip: Constants.tooltipRefresh,
            onPressed: () {
              if (widget.category.id != null) {
                ref
                    .read(projectProvider.notifier)
                    .loadProjectsByCategoryId(widget.category.id!);
              }
            },
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [categoryColor.withOpacity(0.3), categoryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: projectState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : projectState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        projectState.error!,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.category.id != null) {
                            ref
                                .read(projectProvider.notifier)
                                .loadProjectsByCategoryId(widget.category.id!);
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header with search
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Projects',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${projectState.projects.where((p) => _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery) || p.srNo.toLowerCase().contains(_searchQuery)).length} projects in this category',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 320,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value.toLowerCase();
                                  });
                                },
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search projects...',
                                  hintStyle: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 18,
                                            color: AppColors.textSecondary,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchQuery = '';
                                            });
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Projects List
                    Expanded(
                      child: projectState.projects.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 64,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No projects found',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No projects in this category yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _handleCreateProject,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create Project'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: categoryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Builder(
                              builder: (context) {
                                final filteredProjects = projectState.projects
                                    .where((p) =>
                                        _searchQuery.isEmpty ||
                                        p.name
                                            .toLowerCase()
                                            .contains(_searchQuery) ||
                                        p.srNo
                                            .toLowerCase()
                                            .contains(_searchQuery))
                                    .toList();

                                if (filteredProjects.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: AppColors.textTertiary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No projects found',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Try a different search term',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.textTertiary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 0, 24, 20),
                                  itemCount: filteredProjects.length,
                                  itemBuilder: (context, index) {
                                    final project = filteredProjects[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _ProjectListItem(
                                        project: project,
                                        categoryColor: categoryColor,
                                        categoryIcon: widget.category.getIcon(),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProjectDetailScreen(
                                                project: project,
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () =>
                                            _handleDeleteProject(project),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

/// Project List Item Widget
class _ProjectListItem extends StatefulWidget {
  final Project project;
  final Color categoryColor;
  final IconData categoryIcon;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectListItem({
    required this.project,
    required this.categoryColor,
    required this.categoryIcon,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_ProjectListItem> createState() => _ProjectListItemState();
}

class _ProjectListItemState extends State<_ProjectListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? widget.categoryColor : AppColors.border,
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.categoryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Serial Number Badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.project.srNo,
                        style: TextStyle(
                          color: widget.categoryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Project Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(widget.project.status)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _getStatusColor(widget.project.status)
                                      .withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.project.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(widget.project.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.error,
                    tooltip: 'Delete Project',
                    onPressed: widget.onDelete,
                  ),

                  const SizedBox(width: 8),

                  // Category Icon Badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.categoryIcon,
                      size: 20,
                      color: widget.categoryColor,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: _isHovered
                        ? widget.categoryColor
                        : AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'in progress':
        return AppColors.warning;
      case 'on hold':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
