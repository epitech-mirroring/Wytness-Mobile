import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:mobile/constants/const.dart';
import 'package:mobile/model/apis.module.dart';
import 'package:mobile/model/workflows.module.dart';
import 'package:mobile/pages/widget/modal.dart';
import 'package:mobile/service/workflows.dart';
import 'package:uuid/uuid.dart';

class WorkflowPage extends StatefulWidget {
  const WorkflowPage({
    super.key,
    required this.workflow,
    this.index,
  });
  final WorkflowService workflow;
  final int? index;

  @override
  State<WorkflowPage> createState() => _WorkflowPageState();
}

class _WorkflowPageState extends State<WorkflowPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  final ShakeRotateConstant1 shakeConstant = ShakeRotateConstant1();
  List<bool> isRemove = [];
  List<ApiModel> selectedApi = [];

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      selectedApi = widget.workflow.workflows[widget.index!].apis;
    }
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    animation = Tween<double>(begin: 1, end: 0).animate(animationController);
    isRemove = List.generate(selectedApi.length + 1, (index) => false);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  bool isPlaying = false;

  Widget addApi({Key? key}) {
    return SizedBox(
      key: key,
      height: selectedApi.isEmpty ? dh(context) / 2 : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 80,
                width: 130,
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: SizedBox(
                          height: dh(context) / 1.1,
                          child: const ModalSheetWidget(),
                        ),
                      ),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          isRemove.add(false);
                          selectedApi.add(value);
                        });
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                  ),
                ),
              ),
            ],
          ),
          if (selectedApi.isEmpty)
            Column(
              children: [
                sh(20),
                const Text(
                  'Add your first API',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget apiItem(int index, {Key? key}) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        sw(50),
        Column(
          children: [
            GestureDetector(
              // onLongPress: () {
              //   setState(() {
              //     isRemove[index] = true;
              //   });
              // },
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: SizedBox(
                      height: dh(context) / 1.1,
                      child: const ModalSheetWidget(),
                    ),
                  ),
                ).then((value) {
                  if (value != null) {
                    setState(() {
                      selectedApi[index] = value;
                    });
                  }
                });
              },
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
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 90,
                      width: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sw(10),
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: selectedApi[index].imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              sw(8),
                              Text(
                                selectedApi[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                          sh(10),
                          Text(
                            selectedApi[index].actions.first,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if ((selectedApi.last != selectedApi[index])) ...[
              Container(
                height: 30,
                width: 1,
                color: Colors.black,
              ),
              Container(
                height: 10,
                width: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              )
            ] else ...[
              if (!isPlaying) ...[
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.black,
                ),
                Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                )
              ] else ...[
                Container(
                  height: 40,
                )
              ]
            ]
          ],
        ),
        Container(
          width: 50,
          height: 90,
          margin: const EdgeInsets.only(bottom: 30),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isRemove[index] == false ? 0 : 1,
            child: IconButton(
              onPressed: () {
                setState(() {
                  isRemove.removeAt(index);
                  selectedApi.removeAt(index);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      floatingActionButton: selectedApi.isEmpty
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xfff2545b),
              onPressed: () {
                if (animationController.isCompleted) {
                  animationController.reverse();
                } else {
                  animationController.forward();
                }
                setState(() {
                  isPlaying = !isPlaying;
                });
              },
              child: AnimatedIcon(
                icon: AnimatedIcons.pause_play,
                progress: animation,
                color: Colors.white,
              ),
            ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: CupertinoNavigationBarBackButton(
          color: Colors.blue,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (selectedApi.isNotEmpty)
            IconButton(
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController nameController =
                        TextEditingController(
                      text: widget.index == null
                          ? ''
                          : widget.workflow.workflows[widget.index!].name,
                    );
                    final TextEditingController descriptionController =
                        TextEditingController(
                      text: widget.index == null
                          ? ''
                          : widget
                              .workflow.workflows[widget.index!].description,
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
                          onPressed: () {
                            final workflowName = nameController.text.trim();
                            final workflowDescription =
                                descriptionController.text.trim();

                            if (workflowName.isNotEmpty &&
                                workflowDescription.isNotEmpty) {
                              widget.workflow.createWorkflow(
                                WorkflowModel(
                                  apis: selectedApi,
                                  name: workflowName,
                                  description: workflowDescription,
                                  uuid: widget.index != null
                                      ? widget.workflow.workflows[widget.index!]
                                          .uuid
                                      : const Uuid().v4(),
                                ),
                              );
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
                color: Colors.blue,
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
      body: GestureDetector(
        onTap: () {
          setState(() {
            isRemove = List.generate(selectedApi.length + 1, (index) => false);
          });
        },
        child: ReorderableListView.builder(
          header: sh(150),
          footer: addApi(key: const ValueKey('addApi')),
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
          itemCount: selectedApi.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > selectedApi.length) {
              return;
            }
            if (oldIndex < selectedApi.length) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = selectedApi.removeAt(oldIndex);
                selectedApi.insert(newIndex, item);
              });
            }
          },
          itemBuilder: (context, index) {
            return apiItem(index, key: ValueKey(selectedApi[index]));
          },
        ),
      ),
    );
  }
}
