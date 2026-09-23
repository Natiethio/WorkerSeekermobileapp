import 'package:flutter/material.dart';

class ServiceCategory {
  final String name;
  final String icon;
  final String iconwhite;
  final String description;
  final String detail;
  final String heroimage;
  final List<String> images;
  final int order;

  ServiceCategory({
    required this.name,
    required this.icon,
    required this.iconwhite,
    required this.description,
    required this.detail,
    required this.heroimage,
    required this.images,
    this.order = 0,
  });
  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      iconwhite: json['iconwhite'] ?? '',
      description: json['description'] ?? '',
      detail: json['detail'] ?? '',
      heroimage: json['heroimage'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
    );
  }

}
