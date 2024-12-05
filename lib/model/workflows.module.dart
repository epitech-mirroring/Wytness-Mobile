import 'package:mobile/model/apis.module.dart';

class WorkflowModel {
  final String name;
  final String description;
  final String uuid;
  final List<ApiModel> apis;

  WorkflowModel({
    required this.name,
    required this.description,
    required this.apis,
    required this.uuid,
  });

  factory WorkflowModel.fromJson(Map<String, dynamic> json) {
    return WorkflowModel(
      uuid: json['uuid'],
      name: json['name'],
      description: json['description'],
      apis:
          (json['apis'] as List).map((api) => ApiModel.fromJson(api)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'apis': apis.map((api) => api.toJson()).toList(),
      'uuid': uuid,
    };
  }
}
