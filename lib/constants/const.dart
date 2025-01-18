import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/service/workflows.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/model/apis.module.dart';

List<ApiModel> apis = [];

double dh(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double dw(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

Widget sh(double height) {
  return Container(height: height);
}

Widget sw(double width) {
  return Container(width: width);
}

late SharedPreferences localUser;

WorkflowService workflowService = WorkflowService();