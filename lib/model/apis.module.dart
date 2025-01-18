import 'dart:ui';

import 'package:mobile/service/auth.service.dart';

class ApiModel {
  final String name;
  final String imageUrl;
  final String description;
  final List<Map<String, dynamic>> actions;
  final List<Map<String, dynamic>> reactions;
  Color? color;
  final Map<dynamic, dynamic> auth;

  ApiModel({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.actions,
    required this.reactions,
    this.color,
    required this.auth,
  });

  factory ApiModel.fromJson(Map<String, dynamic> json) {
    return ApiModel(
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      actions: (json['actions'] as List)
          .map((action) => Map<String, dynamic>.from(action))
          .toList(),
      reactions: (json['reactions'] as List)
          .map((reaction) => Map<String, dynamic>.from(reaction))
          .toList(),
      color: json.containsKey('color') ? parseColor(json['color']) : null,
      auth: json['auth'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'actions': actions,
      'reactions': reactions,
      'color': color?.value ?? 0,
      'auth': auth,
    };
  }
}
