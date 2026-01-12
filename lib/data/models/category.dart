import 'package:flutter/material.dart';

/// Category model - Project categories
class Category {
  final int? id;
  final String name;
  final String color; // Hex color like '#0061FF'
  final String icon; // Icon name like 'folder', 'engineering'
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    this.id,
    required this.name,
    required this.color,
    this.icon = 'folder', // Default icon
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (SQLite or API)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String? ?? 'folder',
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON (for SQLite or API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id, timestamps)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'name': name,
      'color': color,
      'icon': icon,
      'description': description,
    };
  }

  /// Copy with
  Category copyWith({
    int? id,
    String? name,
    String? color,
    String? icon,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Parse hex color string to Color object
  Color getColor() {
    final hexColor = color.replaceAll('#', '');
    return Color(int.parse('0xFF$hexColor'));
  }

  /// Get IconData from icon name
  IconData getIcon() {
    final iconMap = <String, IconData>{
      'folder': Icons.folder,
      'festival': Icons.festival,
      'handshake': Icons.handshake,
      'apartment': Icons.apartment,
      'route': Icons.route,
      'business': Icons.business,
      'engineering': Icons.engineering,
      'construction': Icons.construction,
      'account_balance': Icons.account_balance,
      'location_city': Icons.location_city,
      'domain': Icons.domain,
      'corporate_fare': Icons.corporate_fare,
      'factory': Icons.factory,
      'store': Icons.store,
      'workspaces': Icons.workspaces,
    };
    return iconMap[icon] ?? Icons.folder;
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, color: $color, icon: $icon)';
  }
}
