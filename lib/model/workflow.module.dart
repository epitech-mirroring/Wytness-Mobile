import 'package:mobile/model/node.module.dart';

class WorkflowModel {
  final int id;
  final String name;
  final String description;
  final String? status;
  final int ownerId;
  List<NodeModel>? nodes;
  final int? executions;
  final int? dataUsedDownLoad;

  WorkflowModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.nodes,
    this.status,
    this.executions,
    this.dataUsedDownLoad,
  });

  factory WorkflowModel.fromJson(Map<String, dynamic> json) {
    return WorkflowModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['ownerId'],
      executions: json.containsKey('executions') ? json['executions'] : 0,
      dataUsedDownLoad: json.containsKey('dataUsedDownLoad') ? json['dataUsedDownLoad'] : 0,
      nodes: json.containsKey('nodes')
          ? (json['nodes'] as List)
              .map((node) => NodeModel.fromJson(node))
              .toList()
          : [],
      status:
          json.containsKey('status') ? json['status'] ?? 'enabled' : 'enabled',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'id': id,
      'nodes': nodes?.map((node) => node.toJson()).toList() ?? [],
      'status': status ?? 'enabled',
      'executions': executions ?? 0,
      'dataUsedDownLoad': dataUsedDownLoad ?? 0,
    };
  }
}
