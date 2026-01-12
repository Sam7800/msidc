import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/repository_providers.dart';

/// Bell icon widget for marking sections as critical/alert activities
class CriticalBellIcon extends ConsumerStatefulWidget {
  final int? projectId;
  final String sectionName;
  final String optionName;
  final double iconSize;

  const CriticalBellIcon({
    super.key,
    required this.projectId,
    required this.sectionName,
    required this.optionName,
    this.iconSize = 20.0,
  });

  @override
  ConsumerState<CriticalBellIcon> createState() => _CriticalBellIconState();
}

class _CriticalBellIconState extends ConsumerState<CriticalBellIcon>
    with SingleTickerProviderStateMixin {
  bool _isCritical = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadCriticalStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCriticalStatus() async {
    if (widget.projectId == null) {
      if (mounted) {
        setState(() {
          _isCritical = false;
          _isLoading = false;
        });
      }
      return;
    }

    final repo = ref.read(criticalSubsectionsRepositoryProvider);
    final isCritical = await repo.isCritical(
      widget.projectId!,
      widget.sectionName,
      widget.optionName,
    );
    if (mounted) {
      setState(() {
        _isCritical = isCritical;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleCritical() async {
    if (widget.projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please save the project first'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Animate
    await _animationController.forward();
    await _animationController.reverse();

    // Toggle in database
    final repo = ref.read(criticalSubsectionsRepositoryProvider);
    final newStatus = await repo.toggleCritical(
      widget.projectId!,
      widget.sectionName,
      widget.optionName,
    );

    if (mounted) {
      setState(() {
        _isCritical = newStatus;
      });

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Added to Critical Activities'
                : 'Removed from Critical Activities',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          _isCritical ? Icons.notifications_active : Icons.notifications_outlined,
          color: _isCritical ? Colors.deepOrange : Colors.grey,
          size: widget.iconSize,
        ),
        onPressed: _toggleCritical,
        tooltip: _isCritical
            ? 'Remove from Critical Activities'
            : 'Mark as Critical Activity',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 20,
      ),
    );
  }
}
