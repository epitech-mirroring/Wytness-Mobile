import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/constants/const.dart';
import 'package:mobile/model/apis.module.dart';
import 'package:mobile/model/node.module.dart';
import 'package:mobile/model/workflow.module.dart';
import 'package:mobile/pages/profile.dart';
import 'package:mobile/pages/workflow.dart';
import 'package:mobile/service/auth.service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final controller = ScrollController();
  late TabController tabController;
  Map<String, dynamic> data = {
    "workflows": 0,
    "executions": 0,
    "successfulExecutions": 0,
    "failedExecutions": 0,
    "dataUsedDownLoad": 0,
    "dataUsedUpload": 0,
    "nodesExecuted": 0
  };
  double scrollRate = 0;
  double titleAligment() {
    return (((scrollRate < 0 ? 0 : scrollRate) * 2) > (dw(context) / 2 - 75)
        ? dw(context) / 2 - 75
        : ((scrollRate < 0 ? 0 : scrollRate) * 2));
  }

  List<WorkflowModel> workflows = [];
  bool loading = false;
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        loading = true;
      } else {
        AuthService.services().then((value) {
          setState(() {});
          fetchDashBoard().then((value) {
            setState(() {
              data = value;
            });
          });
          fetchWorkflows();
          setState(() {
            loading = false;
          });
        });
      }
    });

    tabController = TabController(length: 3, vsync: this);
    tabController.index = 1;
    super.initState();
  }

  Future<void> fetchWorkflows() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$url/api/workflows?sort=statistics.duration.start&order=ASC'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
        },
      );
      if (response.statusCode == 200) {
        for (var workflow in (jsonDecode(response.body) as List)) {
          final stats = await http.get(
            Uri.parse('$url/api/statistics/workflows/${workflow['id']}'),
            headers: {
              'Content-Type': 'application',
              'Authorization':
                  'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
            },
          );

          final updatedWorkflow = WorkflowModel.fromJson({
            ...workflow,
            'executions': jsonDecode(stats.body)['executions'],
            'dataUsedDownLoad': jsonDecode(stats.body)['dataUsedDownLoad'],
          });

          final existingIndex =
              workflows.indexWhere((w) => w.id == workflow['id']);

          if (existingIndex != -1) {
            workflows[existingIndex] = updatedWorkflow;
          } else {
            workflows.add(updatedWorkflow);
          }
        }
        setState(() {});
        for (var id in workflows) {
          getNodes(id.id);
        }
        while (apis.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 100));

          setState(() {
            workflows = (jsonDecode(response.body) as List)
                .map((workflow) => WorkflowModel.fromJson(workflow))
                .toList();
          });
          for (var id in workflows) {
            getNodes(id.id);
          }
        }
      } else {
        throw Exception('Failed to create workflow');
      }
    } catch (e) {
      throw Exception('Error creating workflow: $e');
    }
  }

  void getNodes(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$url/api/workflows/$id/nodes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
        },
      );
      if (response.statusCode == 200) {
        List<NodeModel> nodes =
            (jsonDecode(response.body) as List<dynamic>).map((node) {
          final data = apis.firstWhere((api) {
            return api.reactions.map((e) => e.id).contains(node['nodeId']) ||
                api.actions.map((e) => e.id).contains(node['nodeId']);
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
              if (action.id == node['nodeId']) {
                apiName = action.name;
                color = api.color ?? Colors.black;
              }
            }
            for (var reaction in api.reactions) {
              if (reaction.id == node['nodeId']) {
                apiName = reaction.name;
                color = api.color ?? Colors.black;
              }
            }
          }
          return NodeModel.fromJson({
            ...node,
            'name': apiName,
            'description': data.description,
            'imageUrl': data.imageUrl,
            'color': color,
            'type': data.reactions.map((e) => e.id).contains(node['nodeId'])
                ? 'trigger'
                : 'action',
          });
        }).toList();
        setState(() {
          workflows.firstWhere((workflow) => workflow.id == id).nodes = nodes;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<Map<String, dynamic>> fetchDashBoard() async {
    try {
      final response = await http.get(
        Uri.parse('$url/api/statistics/users/me'),
        headers: {
          'Authorization':
              'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        children: [
          Scaffold(
            appBar: AppBar(
              leading: const SizedBox.shrink(),
              elevation: 1,
              backgroundColor: const Color(0xfff5f5f5),
              title: const Text(
                "Services",
                style: TextStyle(
                  color: Color(0xff574ae2),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Parkinsans',
                  letterSpacing: -0.8,
                ),
              ),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xff574ae2),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: const Color(0xfff5f5f5),
            body: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: apis.where((e) => e.auth.isNotEmpty).length,
                itemBuilder: (BuildContext context, int index) {
                  final api =
                      apis.where((e) => e.auth.isNotEmpty).toList()[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ExpansionTile(
                        backgroundColor: api.color == Colors.white
                            ? Colors.black
                            : api.color,
                        collapsedBackgroundColor: api.color == Colors.white
                            ? Colors.black
                            : api.color,
                        title: Text(
                          api.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        collapsedIconColor: Colors.white,
                        iconColor: Colors.white,
                        leading: SizedBox(
                          width: 35,
                          height: 35,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SvgPicture.network(
                              api.imageUrl,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        children: [
                          sh(10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              api.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          sh(10),
                          CupertinoButton(
                            onPressed: () {
                              if (!api.auth['connected']) {
                                launchUrl(
                                  Uri.parse(
                                    api.auth['url'],
                                  ),
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff574ae2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!api.auth['connected'])
                                      const Icon(
                                        CupertinoIcons.link,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    sw(2),
                                    Text(
                                      api.auth['connected']
                                          ? 'Connected'
                                          : "Link to ${api.name}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Scaffold(
            backgroundColor: const Color(0xfff5f5f5),
            appBar: AppBar(
              leading: const SizedBox.shrink(),
              elevation: 1,
              centerTitle: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xff574ae2),
                      width: 1,
                    ),
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                    colorFilter: const ColorFilter.mode(
                      Color(0xff574ae2),
                      BlendMode.srcIn,
                    ),
                    width: 40,
                  ),
                  sw(10),
                  const Text(
                    'Wytness',
                    style: TextStyle(
                      fontFamily: 'Parkinsans',
                      letterSpacing: -0.8,
                      color: Color(0xff574ae2),
                      fontSize: 25,
                    ),
                  ),
                  sw(70),
                ],
              ),
            ),
            body: SizedBox(
              height: dh(context),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    sh(30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: dw(context) / 2.5,
                          height: dw(context) / 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data['successfulExecutions'].toString(),
                                style: const TextStyle(
                                  fontSize: 55,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff2aa98c),
                                ),
                              ),
                              const Text(
                                "Successful run",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              const Text(
                                "(this year)",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: dw(context) / 2.5,
                          height: dw(context) / 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data['nodesExecuted'].toString(),
                                style: const TextStyle(
                                  fontSize: 55,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff2aa98c),
                                ),
                              ),
                              const Text(
                                "Nodes ran",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              const Text(
                                "(this year)",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    sh(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: dw(context) / 2.5,
                          height: dw(context) / 4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Builder(builder: (context) {
                            double palier = 0;
                            double percentage = 0;
                            if (data.containsKey('dataUsedDownLoad')) {
                              percentage =
                                  ((data['dataUsedDownLoad'] / 5000) * 100);
                              if (data['dataUsedDownLoad'] < 10) {
                                palier = 10;
                              } else if (data['dataUsedDownLoad'] < 50) {
                                palier = 50;
                              } else if (data['dataUsedDownLoad'] < 100) {
                                palier = 100;
                              } else if (data['dataUsedDownLoad'] < 5000) {
                                palier = 5000;
                              }
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                sh(10),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Data used",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_downward,
                                      color: Colors.black,
                                      size: 13,
                                    ),
                                    Text(
                                      "(Mb)",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                sh(10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      '${data['dataUsedDownLoad']}/$palier (${percentage.toStringAsFixed(2)}%)',
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                sh(10),
                                Container(
                                  width: 140,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 140 * percentage,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          }),
                        ),
                        Container(
                          width: dw(context) / 2.5,
                          height: dw(context) / 4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Builder(builder: (context) {
                            double palier = 0;
                            double percentage = 0;
                            if (data.containsKey('dataUsedDownLoad')) {
                              percentage =
                                  ((data['dataUsedDownLoad'] / 5000) * 100);
                              if (data['dataUsedDownLoad'] < 10) {
                                palier = 10;
                              } else if (data['dataUsedDownLoad'] < 50) {
                                palier = 50;
                              } else if (data['dataUsedDownLoad'] < 100) {
                                palier = 100;
                              } else if (data['dataUsedDownLoad'] < 5000) {
                                palier = 5000;
                              }
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                sh(10),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Data used",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_upward,
                                      color: Colors.black,
                                      size: 13,
                                    ),
                                    Text(
                                      "(Mb)",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                sh(10),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        '${data['dataUsedUpload']}/$palier (${percentage.toStringAsFixed(2)}%)',
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    )),
                                sh(10),
                                Container(
                                  width: 140,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 140 * percentage,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color(0xff2aa98c),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container()
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                    sh(20),
                    Container(
                      width: dw(context) - 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              sw(10),
                              const Icon(
                                Icons.keyboard_arrow_down_sharp,
                                color: Colors.black,
                              ),
                              sw(10),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Text(
                                  "Recent Workflows",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ListView.builder(
                            itemCount: workflows.take(4).length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              bool toogled =
                                  workflows[index].status != 'enabled';
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 10,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) {
                                          return WorkflowPage(
                                            workflow: workflows[index],
                                          );
                                        },
                                      ),
                                    ).then((value) {
                                      fetchWorkflows();
                                      setState(() {});
                                    });
                                  },
                                  child: Container(
                                    height: 60,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            List<NodeModel> nodes =
                                                workflows[index].nodes ?? [];
                                            List<NodeModel> listNodes = [];
                                            void goThroughNodes(
                                                NodeModel node) {
                                              listNodes.add(node);

                                              if (node.next != null &&
                                                  node.next!.isNotEmpty &&
                                                  node.next!.first.nextModel
                                                      .isNotEmpty) {
                                                goThroughNodes(node.next!.first
                                                    .nextModel.first);
                                              }
                                            }

                                            if (nodes.isNotEmpty) {
                                              goThroughNodes(nodes.first);
                                              listNodes =
                                                  listNodes.reversed.toList();
                                            }
                                            return Row(
                                              children: [
                                                sw(10),
                                                for (var node in listNodes.take(
                                                    listNodes.length == 2
                                                        ? 2
                                                        : 1))
                                                  Container(
                                                    width: 35,
                                                    height: 35,
                                                    color: node.color ==
                                                            Colors.white
                                                        ? const Color(
                                                            0xff574ae2)
                                                        : node.color,
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: SvgPicture.network(
                                                      node.imageUrl!,
                                                      colorFilter:
                                                          const ColorFilter
                                                              .mode(
                                                        Colors.white,
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                  ),
                                                if (listNodes.length > 2)
                                                  Container(
                                                    width: 35,
                                                    height: 35,
                                                    color: Colors.black,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "+${listNodes.length - 1}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                  ),
                                                sw(10),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    sh(5),
                                                    Text(
                                                      workflows[index].name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "${workflows[index].description} • ",
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                        ),
                                                        SvgPicture.asset(
                                                          'assets/download-regular.svg',
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          " ${((workflows[index].dataUsedDownLoad ?? 0) / 1000 / 1000).ceil()}Mo",
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        sw(3),
                                                        const Icon(
                                                          CupertinoIcons
                                                              .arrow_2_circlepath,
                                                          size: 12,
                                                        ),
                                                        Text(
                                                          " ${workflows[index].executions ?? 0}",
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    sh(5)
                                                  ],
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                if (workflows[index].status ==
                                                    'enabled') {
                                                  await http.patch(
                                                    Uri.parse(
                                                        '$url/api/workflows/${workflows[index].id}'),
                                                    headers: {
                                                      'Content-Type':
                                                          'application/json',
                                                      'Authorization':
                                                          'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                                                    },
                                                    body: jsonEncode({
                                                      "name":
                                                          workflows[index].name,
                                                      "description":
                                                          workflows[index]
                                                              .description,
                                                      "status": "disabled"
                                                    }),
                                                  );
                                                } else {
                                                  await http.patch(
                                                    Uri.parse(
                                                        '$url/api/workflows/${workflows[index].id}'),
                                                    headers: {
                                                      'Content-Type':
                                                          'application/json',
                                                      'Authorization':
                                                          'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                                                    },
                                                    body: jsonEncode({
                                                      "name":
                                                          workflows[index].name,
                                                      "description":
                                                          workflows[index]
                                                              .description,
                                                      "status": "enabled"
                                                    }),
                                                  );
                                                }
                                                fetchWorkflows();
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: Container(
                                                  width: 55,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: toogled
                                                        ? const Color(
                                                            0xffe76e50)
                                                        : const Color(
                                                            0xff574ae2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: toogled
                                                        ? MainAxisAlignment
                                                            .start
                                                        : MainAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 2,
                                                                left: 2),
                                                        child: Container(
                                                          width: 22,
                                                          height: 22,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: toogled
                                                                ? const Color(
                                                                    0xffffcbbe)
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    232,
                                                                    223,
                                                                    255),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              CupertinoIcons
                                                  .exclamationmark_triangle,
                                              size: 20,
                                              color: workflows[index].name ==
                                                      'error'
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            sw(4)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    sh(100)
                  ],
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: const Color(0xfff5f5f5),
            body: NotificationListener(
              onNotification: (v) {
                if (v is ScrollUpdateNotification) {
                  setState(() {
                    scrollRate += v.scrollDelta!;
                  });
                }
                return true;
              },
              child: NestedScrollView(
                controller: controller,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                headerSliverBuilder: (context, value) {
                  return [
                    SliverAppBar(
                      backgroundColor: const Color(0xfff5f5f5),
                      pinned: true,
                      stretch: true,
                      actions: [
                        IconButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            CupertinoIcons.person_circle,
                            size: 40,
                            color: Color(0xff574ae2),
                          ),
                        ),
                      ],
                      elevation: 1,
                      stretchTriggerOffset: 210,
                      toolbarHeight: 56,
                      onStretchTrigger: () async {},
                      expandedHeight: 110,
                      leading: const SizedBox.shrink(),
                      flexibleSpace: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            centerTitle: false,
                            expandedTitleScale: 2,
                            titlePadding: EdgeInsets.only(
                              bottom: scrollRate < 0
                                  ? 0
                                  : (scrollRate > 20 ? 20 : scrollRate),
                              left: 25 + titleAligment(),
                            ),
                            title: Text(
                              "Workflows",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Parkinsans',
                                letterSpacing: -0.8,
                                fontWeight: FontWeight.w700,
                                color: scrollRate > 20
                                    ? const Color(0xff574ae2)
                                    : Colors.black,
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: scrollRate > 20 ? 1 : 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xff574ae2),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ];
                },
                body: ListView.builder(
                  itemCount: workflows.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    bool toogled = workflows[index].status != 'enabled';
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 10,
                      ),
                      child: Slidable(
                        key: ValueKey(workflows[index].name),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                try {
                                  await http.delete(
                                    Uri.parse(
                                      '$url/api/workflows/${workflows[index].id}',
                                    ),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Authorization':
                                          'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                                    },
                                  );
                                } catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                                workflows.removeAt(index);
                                setState(() {});
                              },
                              borderRadius: BorderRadius.circular(10),
                              backgroundColor: CupertinoColors.systemRed,
                              foregroundColor: CupertinoColors.white,
                              icon: CupertinoIcons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) {
                                  return WorkflowPage(
                                    workflow: workflows[index],
                                  );
                                },
                              ),
                            ).then((value) {
                              fetchWorkflows();
                              setState(() {});
                            });
                          },
                          child: Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Builder(builder: (context) {
                                  List<NodeModel> nodes =
                                      workflows[index].nodes ?? [];
                                  List<NodeModel> listNodes = [];
                                  void goThroughNodes(NodeModel node) {
                                    listNodes.add(node);

                                    if (node.next != null &&
                                        node.next!.isNotEmpty &&
                                        node.next!.first.nextModel.isNotEmpty) {
                                      goThroughNodes(
                                          node.next!.first.nextModel.first);
                                    }
                                  }

                                  if (nodes.isNotEmpty) {
                                    goThroughNodes(nodes.first);
                                    listNodes = listNodes.reversed.toList();
                                  }
                                  return Row(
                                    children: [
                                      sw(10),
                                      for (var node in listNodes
                                          .take(listNodes.length == 2 ? 2 : 1))
                                        Container(
                                          width: 35,
                                          height: 35,
                                          color: node.color == Colors.white
                                              ? const Color(0xff574ae2)
                                              : node.color,
                                          padding: const EdgeInsets.all(8),
                                          child: SvgPicture.network(
                                            node.imageUrl!,
                                            colorFilter: const ColorFilter.mode(
                                              Colors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      if (listNodes.length > 2)
                                        Container(
                                          width: 35,
                                          height: 35,
                                          color: Colors.black,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "+${listNodes.length - 1}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      sw(10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          sh(5),
                                          Text(
                                            workflows[index].name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "${workflows[index].description} • ",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                'assets/download-regular.svg',
                                                width: 12,
                                              ),
                                              Text(
                                                " ${((workflows[index].dataUsedDownLoad ?? 0) / 1000 / 1000).ceil()}Mo",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              sw(3),
                                              const Icon(
                                                CupertinoIcons
                                                    .arrow_2_circlepath,
                                                size: 12,
                                              ),
                                              Text(
                                                " ${workflows[index].executions ?? 0}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          sh(5)
                                        ],
                                      )
                                    ],
                                  );
                                }),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (workflows[index].status ==
                                            'enabled') {
                                          await http.patch(
                                            Uri.parse(
                                                '$url/api/workflows/${workflows[index].id}'),
                                            headers: {
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization':
                                                  'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                                            },
                                            body: jsonEncode({
                                              "name": workflows[index].name,
                                              "description":
                                                  workflows[index].description,
                                              "status": "disabled"
                                            }),
                                          );
                                        } else {
                                          await http.patch(
                                            Uri.parse(
                                                '$url/api/workflows/${workflows[index].id}'),
                                            headers: {
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization':
                                                  'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                                            },
                                            body: jsonEncode({
                                              "name": workflows[index].name,
                                              "description":
                                                  workflows[index].description,
                                              "status": "enabled"
                                            }),
                                          );
                                        }
                                        fetchWorkflows();
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: Container(
                                          width: 55,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: toogled
                                                ? const Color(0xffe76e50)
                                                : const Color(0xff574ae2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: toogled
                                                ? MainAxisAlignment.start
                                                : MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 2, left: 2),
                                                child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color: toogled
                                                        ? const Color(
                                                            0xffffcbbe)
                                                        : const Color.fromARGB(
                                                            255, 232, 223, 255),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      CupertinoIcons.exclamationmark_triangle,
                                      size: 20,
                                      color: workflows[index].name == 'error'
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    sw(10)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: FloatingActionButton(
                onPressed: () async {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      final TextEditingController nameController =
                          TextEditingController(text: '');
                      final TextEditingController descriptionController =
                          TextEditingController(text: '');

                      return CupertinoAlertDialog(
                        title: const Text('Download your workflow'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                                'Enter a name and description for your workflow:'),
                            const SizedBox(height: 8),
                            CupertinoTextField(
                              controller: nameController,
                              placeholder: 'Workflow Name',
                            ),
                            const SizedBox(height: 8),
                            CupertinoTextField(
                              controller: descriptionController,
                              placeholder: 'Workflow Description',
                            ),
                          ],
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xff574ae2),
                              ),
                            ),
                          ),
                          CupertinoDialogAction(
                            onPressed: () async {
                              final workflowName = nameController.text.trim();
                              final workflowDescription =
                                  descriptionController.text.trim();

                              if (workflowName.isNotEmpty &&
                                  workflowDescription.isNotEmpty) {
                                try {
                                  await http.post(
                                    Uri.parse('$url/api/workflows'),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Authorization':
                                          'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                                    },
                                    body: jsonEncode({
                                      'name': workflowName,
                                      'description': workflowDescription,
                                      "mobile": true,
                                    }),
                                  );
                                  Navigator.pop(context);
                                  fetchWorkflows().then((value) {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) {
                                          return WorkflowPage(
                                            workflow: workflows.last,
                                          );
                                        },
                                      ),
                                    ).then((value) {
                                      fetchWorkflows();
                                      setState(() {});
                                    });
                                  });
                                } catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                              } else {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'Workflow textfields cannot be empty.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'OK',
                                          style: TextStyle(
                                            color: Color(0xff574ae2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Color(0xff574ae2),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                backgroundColor: const Color(0xff574ae2),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: SizedBox(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TabBar(
                enableFeedback: true,
                splashBorderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                indicatorColor: const Color(0xff574ae2),
                dividerColor: Colors.transparent,
                labelColor: const Color(0xff574ae2),
                controller: tabController,
                onTap: (index) {
                  setState(() {
                    tabController.index = index;
                  });
                },
                tabs: [
                  const Tab(
                    icon: Icon(CupertinoIcons.link),
                  ),
                  const Tab(
                    icon: Icon(
                      Icons.home,
                      size: 28,
                    ),
                  ),
                  Tab(
                    icon: SvgPicture.asset(
                      'assets/arrow-progress-regular.svg',
                      colorFilter: ColorFilter.mode(
                        tabController.index == 2
                            ? const Color(0xff574ae2)
                            : const Color.fromARGB(255, 78, 78, 78),
                        BlendMode.srcIn,
                      ),
                      width: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
