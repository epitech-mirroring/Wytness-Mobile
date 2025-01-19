import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/constants/const.dart';
import 'package:mobile/model/node.module.dart';
import 'package:mobile/model/workflow.module.dart';
import 'package:mobile/pages/widget/modal.dart';
import 'package:http/http.dart' as http;

class WorkflowPage extends StatefulWidget {
  const WorkflowPage({super.key, required this.workflow});
  final WorkflowModel? workflow;

  @override
  State<WorkflowPage> createState() => _WorkflowPageState();
}

class _WorkflowPageState extends State<WorkflowPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  final ShakeRotateConstant1 shakeConstant = ShakeRotateConstant1();
  List<bool> isRemove = [];
  List<NodeModel> nodes = [];
  List<NodeModel> listNodes = [];

  @override
  void initState() {
    super.initState();
    if (widget.workflow != null) {
      nodes = widget.workflow?.nodes ?? [];
      if (widget.workflow != null) {
        nodes = widget.workflow?.nodes ?? [];
        if (nodes.isNotEmpty) {
          goThroughNodes(nodes.first);
          listNodes = listNodes.reversed.toList();
        }
      }
    }
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = Tween<double>(begin: 1, end: 0).animate(animationController);
    isRemove = List.generate(listNodes.length, (index) => false);
  }

  void goThroughNodes(NodeModel node) {
    for (var api in apis) {
      for (var action in api.actions) {
        if (action.id == node.id) {
          node.labels = action.labels;
          break;
        }
      }
      for (var trigger in api.reactions) {
        if (trigger.id == node.id) {
          node.labels = trigger.labels;
          break;
        }
      }
    }
    listNodes.add(node);

    if (node.next != null &&
        node.next!.isNotEmpty &&
        node.next!.first.nextModel.isNotEmpty) {
      goThroughNodes(node.next!.first.nextModel.first);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  bool isPlaying = false;

  Widget apiItem(int index, NodeModel apiModel, {Key? key}) {
    return Stack(
      key: key,
      alignment: Alignment.bottomCenter,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            sw(50),
            Column(
              children: [
                GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      isRemove[index] = true;
                    });
                  },
                  onTap: () {},
                  child: ShakeWidget(
                    duration: const Duration(seconds: 3),
                    shakeConstant: shakeConstant,
                    autoPlay: isRemove[index],
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              width: 1,
                              color: apiModel.color ?? Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SvgPicture.network(apiModel.imageUrl!),
                                ),
                              ),
                              sw(10),
                              Text(
                                apiModel.name,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                sh(53)
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -25),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isRemove[index] ? 1 : 0,
                child: IconButton(
                  onPressed: () async {
                    if (!isRemove[index] || index == listNodes.length - 1) {
                      return;
                    }
                    await http.delete(
                      Uri.parse(
                          '$url/api/workflows/${widget.workflow!.id}/nodes/${listNodes[index].id}'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization':
                            'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                      },
                    );
                    await http.patch(
                      Uri.parse(
                          '$url/api/workflows/${widget.workflow!.id}/nodes/${listNodes[index - 1].id}'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization':
                            'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                      },
                      body: jsonEncode({
                        'previous': listNodes[index + 1].id,
                        'label': listNodes[index + 1].labels![0]
                      }),
                    );
                    setState(() {
                      isRemove.removeAt(index);
                      listNodes.removeAt(index);
                    });
                  },
                  icon: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    padding: const EdgeInsets.all(5),
                    child: const Icon(
                      CupertinoIcons.trash,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          children: [
            if ((listNodes.first == apiModel)) ...[
              Container(
                height: 17,
                width: 17,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
              Container(
                height: 45,
                width: 3,
                color: Colors.transparent,
              ),
            ] else ...[
              if (!isPlaying) ...[
                Container(
                  height: 17,
                  width: 17,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xff574ae2),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  width: 3,
                  color: Colors.black,
                ),
                RotatedBox(
                  quarterTurns: 2,
                  child: CustomPaint(
                    size: const Size(17, 17),
                    painter: TrianglePainter(),
                  ),
                ),
              ] else ...[
                Container(
                  height: 40,
                )
              ]
            ]
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff574ae2),
        onPressed: () {
          showModalBottomSheet<NodeModel>(
            context: context,
            isScrollControlled: true,
            builder: (context) => ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: SizedBox(
                height: dh(context) / 1.1,
                child: ModalSheetWidget(
                  services: listNodes,
                ),
              ),
            ),
          ).then((NodeModel? value) async {
            if (value != null) {
              try {
                if (value.type == "trigger") {
                  final data = await http.post(
                    Uri.parse(
                        '$url/api/workflows/${widget.workflow!.id}/nodes'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization':
                          'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                    },
                    body: jsonEncode({
                      'id': value.id,
                      'config': {},
                    }),
                  );

                  setState(() {
                    isRemove.add(false);
                    listNodes.insert(
                      listNodes.length,
                      NodeModel.fromJson({
                        ...jsonDecode(data.body),
                        'name': value.name,
                        'description': value.description,
                        'imageUrl': value.imageUrl,
                        'color': value.color,
                        'type': value.type,
                        'labels': value.labels,
                      }),
                    );
                  });
                } else {
                  final data = await http.post(
                    Uri.parse(
                        '$url/api/workflows/${widget.workflow!.id}/nodes'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization':
                          'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                    },
                    body: jsonEncode({
                      'id': value.id,
                      'config': {},
                      if (listNodes.isNotEmpty) ...{
                        'previous': listNodes[0].id,
                        'label': value.labels![0]
                      }
                    }),
                  );
                  setState(() {
                    isRemove.add(false);
                    listNodes.insert(
                      0,
                      NodeModel.fromJson({
                        ...jsonDecode(data.body),
                        'name': value.name,
                        'description': value.description,
                        'imageUrl': value.imageUrl,
                        'color': value.color,
                        'type': value.type,
                        'labels': value.labels,
                      }),
                    );
                  });
                }
              } catch (e) {
                if (kDebugMode) {
                  print(e);
                }
              }
            }
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: CupertinoNavigationBarBackButton(
          color: const Color(0xff574ae2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  final TextEditingController nameController =
                      TextEditingController(
                    text: widget.workflow == null ? '' : widget.workflow!.name,
                  );
                  final TextEditingController descriptionController =
                      TextEditingController(
                    text: widget.workflow == null
                        ? ''
                        : widget.workflow!.description,
                  );

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
                            if (widget.workflow == null) {
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
                              } catch (e) {
                                if (kDebugMode) {
                                  print(e);
                                }
                              }
                            } else {
                              try {
                                await http.patch(
                                  Uri.parse(
                                      '$url/api/workflows/${widget.workflow!.id}'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization':
                                        'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}'
                                  },
                                  body: jsonEncode({
                                    "name": workflowName,
                                    "description": workflowDescription,
                                    "status": "enabled"
                                  }),
                                );
                              } catch (e) {
                                if (kDebugMode) {
                                  print(e);
                                }
                              }
                            }
                            Navigator.pop(context);
                            Navigator.pop(context);
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
            icon: const Icon(
              CupertinoIcons.cloud_download,
              color: Color(0xff574ae2),
            ),
          ),
        ],
        title: const Text('Wytness'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Stack(
          children: [
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: DottedBackgroundPainter(),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isRemove = List.generate(listNodes.length, (index) => false);
              });
            },
            child: ReorderableListView.builder(
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform(
                      transform: Matrix4.translationValues(
                        0,
                        animation.value * 10,
                        0,
                      ),
                      child: Transform.scale(
                        scale: 1.2,
                        child: child,
                      ),
                    );
                  },
                  child: child,
                );
              },
              header: Container(
                height: 100,
              ),
              reverse: true,
              itemCount: listNodes.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > listNodes.length) {
                  return;
                }
                if (oldIndex < listNodes.length) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = listNodes.removeAt(oldIndex);
                    listNodes.insert(newIndex, item);
                  });
                }
              },
              itemBuilder: (context, index) {
                return Transform.translate(
                  offset: Offset(0, 15 * index.toDouble()),
                  key: ValueKey(index),
                  child: apiItem(
                    index,
                    listNodes[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint dotPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    const double dotRadius = 2.0;
    const double spacing = 16.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint trianglePaint = Paint()
      ..color = const Color(0xff574ae2)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Path trianglePath = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(trianglePath, trianglePaint);

    canvas.drawPath(trianglePath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
