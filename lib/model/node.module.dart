import 'package:flutter/material.dart';
import 'package:mobile/model/next.module.dart';

class NodeModel {
  final int id;
  final int? nodeId;
  final List<NextModel>? next;
  final String name;
  final String description;
  final String type;
  List<String>? labels;
  final String? imageUrl;
  final String? apiName;
  final Color? color;

  NodeModel({
    required this.id,
    this.nodeId,
    required this.name,
    required this.description,
    required this.type,
    this.labels,
    this.imageUrl,
    this.color,
    this.apiName,
    this.next,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'],
      nodeId: json['nodeId'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      labels: json.containsKey('labels')
          ? (json['labels'] as List).map((label) => label.toString()).toList()
          : null,
      imageUrl: json['imageUrl'],
      color: json['color'],
      next: json.containsKey('next') &&
              json['next'] != null &&
              json['next'] is List &&
              (json['next'] as List).isNotEmpty
          ? (json['next'] as List)
              .map((next) => NextModel.fromJson(next))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nodeId': nodeId,
      'name': name,
      'description': description,
      'type': type,
      'labels': labels,
      'imageUrl': imageUrl,
      'color': color?.value ?? 0,
      'apiName': apiName,
      'next': next?.map((next) => next.toJson()).toList() ?? [],
    };
  }
}
