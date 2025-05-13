import 'package:flutter/material.dart';

class AnimatedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  AnimatedPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // Fade + Slide from right
           final offsetAnimation = Tween<Offset>(
             begin: const Offset(1.0, 0.0),
             end: Offset.zero,
           ).animate(CurvedAnimation(parent: animation, curve: curve));
           final fadeAnimation = CurvedAnimation(
             parent: animation,
             curve: curve,
           );

           return SlideTransition(
             position: offsetAnimation,
             child: FadeTransition(opacity: fadeAnimation, child: child),
           );
         },
       );
}
