import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/constants/const.dart';
import 'package:mobile/pages/workflow.dart';
import 'package:mobile/service/workflows.service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.workflow});
  final WorkflowService workflow;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = ScrollController();
  double scrollRate = 0;
  double titleAligment() {
    return (((scrollRate < 0 ? 0 : scrollRate) * 2) > (dw(context) / 2 - 75)
        ? dw(context) / 2 - 75
        : ((scrollRate < 0 ? 0 : scrollRate) * 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                stretch: true,
                elevation: 0,
                stretchTriggerOffset: 210,
                toolbarHeight: 70,
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
                        left: 20 + titleAligment(),
                      ),
                      title: const Text(
                        "Workflows 🔀",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ];
          },
          body: ListView.builder(
            itemCount: widget.workflow.workflows.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Slidable(
                  key: ValueKey(widget.workflow.workflows[index].name),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          widget.workflow.deleteWorkflow(
                              widget.workflow.workflows[index].name);
                          setState(() {});
                        },
                        backgroundColor: CupertinoColors.systemRed,
                        foregroundColor: CupertinoColors.white,
                        icon: CupertinoIcons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xff574ae2),
                          width: 1,
                        ),
                      ),
                      child: CupertinoListTile(
                        leading: const Icon(
                          CupertinoIcons.arrow_2_circlepath,
                          color: Color(0xff574ae2),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        title: Text(
                          widget.workflow.workflows[index].name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle:
                            Text(widget.workflow.workflows[index].description),
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) {
                                return WorkflowPage(
                                    workflow: widget.workflow, index: index);
                              },
                            ),
                          ).then((value) {
                            setState(() {});
                          });
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) {
                return WorkflowPage(workflow: widget.workflow);
              },
            ),
          ).then((value) {
            setState(() {});
          });
        },
        backgroundColor: const Color(0xfff2545b),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
