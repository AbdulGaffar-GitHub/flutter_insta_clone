import 'package:flutter/material.dart';

class LikeAnimantion extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;
  final bool smallLike;

  const LikeAnimantion({
    super.key,
    required this.child,
    required this.isAnimating,
    this.duration = const Duration(
      milliseconds: 150,
    ),
    this.onEnd,
    this.smallLike = false,
  });

  @override
  State<LikeAnimantion> createState() => _LikeAnimantionState();
}

class _LikeAnimantionState extends State<LikeAnimantion>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.duration.inMilliseconds ~/ 2,
      ),
    );
    scale = Tween<double>(begin: 1, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(covariant LikeAnimantion oldWidget) {
    // TODO: implement didUpdateWidget
      super.didUpdateWidget(oldWidget);
      if(widget.isAnimating != oldWidget.isAnimating){
        startAnimantion();
      }
  }

  startAnimantion() async{
    if(widget.isAnimating || widget.smallLike){
      await controller.forward();
      await controller.reverse();
      await Future.delayed(const Duration(milliseconds: 200,),);
      if(widget.onEnd != null){
        widget.onEnd!();
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
        scale: scale,
      child: widget.child,
    );
  }
}
