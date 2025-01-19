import 'package:flutter/material.dart';
import 'package:mobile/constants/const.dart';
import 'package:mobile/model/apis.module.dart';
import 'package:mobile/model/node.module.dart';

class NextModel {
  final String label;
  final List<NodeModel> nextModel;

  NextModel({
    required this.label,
    required this.nextModel,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'next': nextModel.map((node) => node.toJson()).toList(),
    };
  }

  factory NextModel.fromJson(Map<String, dynamic> json) {
    if (json['next'] == null || json['next'].isEmpty) {
      return NextModel(
        label: json['label'],
        nextModel: [],
      );
    }

    final data = json['next'][0];
    final fetchApi = apis.firstWhere((api) {
      return api.reactions.map((e) => e.id).contains(data['nodeId']) ||
          api.actions.map((e) => e.id).contains(data['nodeId']);
    }, orElse: () {
      return ApiModel(
        name: '',
        imageUrl: '',
        description: '',
        actions: [],
        reactions: [],
        auth: {},
      );
    });

    String apiName = '';
    Color color = Colors.black;
    for (var api in apis) {
      for (var action in api.actions) {
        if (action.id == data['nodeId']) {
          apiName = action.name;
          color = api.color ?? Colors.black;
        }
      }
      for (var reaction in api.reactions) {
        if (reaction.id == data['nodeId']) {
          apiName = reaction.name;
          color = api.color ?? Colors.black;
        }
      }
    }

    NodeModel node = NodeModel.fromJson({
      ...data,
      'name': apiName,
      'description': fetchApi.description,
      'imageUrl': fetchApi.imageUrl,
      'color': color,
      'type': fetchApi.reactions.map((e) => e.id).contains(data['nodeId'])
          ? 'trigger'
          : 'action',
    });

    return NextModel(
      label: json['label'],
      nextModel: [node],
    );
  }
}
