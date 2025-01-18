class WorkflowModel {
  final int id;
  final String name;
  final String description;
  final int ownerId;
  List<dynamic>? nodes;

  WorkflowModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.nodes,
  });

  factory WorkflowModel.fromJson(Map<String, dynamic> json) {
    return WorkflowModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['ownerId'],
      nodes: json.containsKey('nodes') ? json['node'] ?? [] : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'id': id,
      'nodes': nodes ?? [],
    };
  }
}
