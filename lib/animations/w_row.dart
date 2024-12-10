import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnimatedScreen extends StatelessWidget {
  const AnimatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const textHeight = 120.0;
    final rowCount = (screenHeight / textHeight).ceil() + 2;

    return Scaffold(
      body: Column(
        children: List.generate(
          rowCount + 1,
          (index) => Expanded(
            child: MarqueeRow(rowOffset: index * 30.0),
          ),
        ),
      ),
    );
  }
}

class MarqueeRow extends StatefulWidget {
  final double rowOffset;

  const MarqueeRow({required this.rowOffset, super.key});

  @override
  MarqueeRowState createState() => MarqueeRowState();
}

class MarqueeRowState extends State<MarqueeRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const textWidth = 100.0;

    final itemsCount = (screenWidth / textWidth).ceil() + 2;
//  + widget.rowOffset
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            -_controller.value * textWidth * itemsCount,
            50,
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          for (int i = 0; i < itemsCount; i++)
            Row(children: [
              ...List.generate(
                itemsCount,
                (index) {
                  final animationValue = ((_controller.value +
                              ((widget.rowOffset / 30) + index) / itemsCount) %
                          1.0) *
                      2;
                  final opacity = animationValue > 1.0
                      ? 2.0 - animationValue
                      : animationValue;
                  return SizedBox(
                    width: textWidth,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: opacity == 0 ? 1 : opacity,
                      child: Transform.scale(
                        scaleX: -1,
                        child: SvgPicture.asset(
                          'assets/logo.svg',
                          color: const Color(0xff574ae2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ])
        ],
      ),
    );
  }
}
