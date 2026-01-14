import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

// class backGroundWidget extends StatelessWidget {
//   const backGroundWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                                 const Color.fromARGB(255, 35, 8, 114),

//                 const Color.fromARGB(223, 58, 5, 190),
//               ],
//             ),
//           ),
//         ),
//         Align(
//           alignment: AlignmentDirectional(-0.11, 0.2),
//           child: Container(
//             height: 300,
//             width: 300,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color:   const Color.fromARGB(255, 32, 238, 204)
//               ,
//             ),
//           ),
//         ),
//         // Align(
//         //   alignment: AlignmentDirectional(0.5, 0.8),
//         //   child: Container(
//         //     height: 300,
//         //     width: 300,
//         //     decoration: BoxDecoration(
//         //         shape: BoxShape.circle, color: AppColors.pinkColor),
//         //   ),
//         // ),
//         BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 100, sigmaY: 180),
//           child: Container(
//             decoration: BoxDecoration(color: Colors.transparent),
//           ),
//         ),
//       ],
//     );
//   }
// }

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> _positions;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(reverse: true);

    // Initialize 3 random positions for the blobs
    _positions = List.generate(
      3,
      (_) => Offset(_random.nextDouble(), _random.nextDouble()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _animatedPosition(Offset offset, double progress) {
    // Move in a sine wave pattern
    final dx = offset.dx + 0.1 * sin(2 * pi * progress);
    final dy = offset.dy + 0.1 * cos(2 * pi * progress);
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 35, 8, 114),
                    Color.fromARGB(223, 58, 5, 190),
                  ],
                ),
              ),
            ),
            // Blobs
            for (int i = 0; i < _positions.length; i++)
              Positioned(
                left: _animatedPosition(_positions[i], _controller.value).dx *
                    size.width,
                top: _animatedPosition(_positions[i], _controller.value).dy *
                    size.height,
                child: Container(
                  height: 200 + i * 50,
                  width: 200 + i * 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 0
                        ? Colors.cyan.withOpacity(0.4)
                        : i == 1
                            ? Colors.pinkAccent.withOpacity(0.3)
                            : Colors.amber.withOpacity(0.2),
                  ),
                ),
              ),
            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 180),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        );
      },
    );
  }
}
