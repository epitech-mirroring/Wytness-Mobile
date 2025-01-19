import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/constants/const.dart';
import 'package:mobile/model/node.module.dart';

class ModalSheetWidget extends StatefulWidget {
  const ModalSheetWidget({super.key, required this.services});
  final List<NodeModel> services;

  @override
  State<ModalSheetWidget> createState() => _ModalSheetWidgetState();
}

class _ModalSheetWidgetState extends State<ModalSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sh(10),
        Container(
          height: 8,
          width: 50,
          decoration: BoxDecoration(
            color: const Color(0xff5b595e),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        sh(10),
        const SizedBox(
          height: 30,
          child: Text(
            'Create a new scenario',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: (dh(context) / 1.1) - 58,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: apis.length,
            itemBuilder: (BuildContext context, int index) {
              final api = apis[index];
              return ExpansionTile(
                title: Text(api.name),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: SvgPicture.network(api.imageUrl),
                  ),
                ),
                children: [
                  sh(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(api.description),
                  ),
                  if (widget.services.isNotEmpty) ...[
                    if (api.actions.isNotEmpty) sh(10),
                    if (api.actions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.arrow_2_squarepath),
                            sw(5),
                            const Text(
                              'Actions',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                              ),
                            )
                          ],
                        ),
                      ),
                    sh(10),
                    SizedBox(
                      height: api.actions.isEmpty ? 0 : 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: api.actions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final action = api.actions[index];
                          return Row(
                            children: [
                              sw(10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 1),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      NodeModel(
                                        name: action.name,
                                        description: api.description,
                                        id: action.id,
                                        nodeId: action.nodeId,
                                        imageUrl: api.imageUrl,
                                        apiName: api.name,
                                        type: action.type,
                                        labels: action.labels,
                                        color: api.color,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    action.name,
                                    style: const TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                  if (widget.services.isEmpty) ...[
                    if (api.reactions.isNotEmpty) sh(10),
                    if (api.reactions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.arrow_2_squarepath),
                            sw(5),
                            const Text(
                              'Reactions',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                              ),
                            )
                          ],
                        ),
                      ),
                    if (api.reactions.isNotEmpty) sh(10),
                    SizedBox(
                      height: api.reactions.isEmpty ? 0 : 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: api.reactions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final reaction = api.reactions[index];
                          return Row(
                            children: [
                              sw(10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 1),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      NodeModel(
                                        name: reaction.name,
                                        description: api.description,
                                        id: reaction.id,
                                        imageUrl: api.imageUrl,
                                        apiName: api.name,
                                        type: reaction.type,
                                        labels: reaction.labels,
                                        color: api.color,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    reaction.name,
                                    style: const TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                  sh(10),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}
