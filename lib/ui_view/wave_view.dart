import 'dart:math' as math;
import 'package:my_diary/fitness_app_theme.dart';
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

class WaveView extends StatefulWidget {
  final double percentageValue;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool compact;
  final bool showText; // Add parameter to hide text

  const WaveView({
    super.key,
    this.percentageValue = 100.0,
    this.primaryColor,
    this.secondaryColor,
    this.compact = false,
    this.showText = true, // Default show text
  });

  @override
  _WaveViewState createState() => _WaveViewState();
}

class _WaveViewState extends State<WaveView> with TickerProviderStateMixin {
  late final AnimationController animationController;
  late final AnimationController waveAnimationController;
  Offset bottleOffset1 = Offset(0, 0);
  List<Offset> animList1 = [];
  Offset bottleOffset2 = Offset(60, 0);
  List<Offset> animList2 = [];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });

    waveAnimationController.addListener(() {
      animList1.clear();
      for (int i = -4 - bottleOffset1.dx.toInt(); i <= 64 + 4; i++) {
        animList1.add(
          Offset(
            i.toDouble() + bottleOffset1.dx.toInt(),
            math.sin(
                      (waveAnimationController.value * 360 - i) %
                          360 *
                          vector.degrees2Radians,
                    ) *
                    4 +
                (((100 - widget.percentageValue) * 0.5)),
          ),
        );
      }
      animList2.clear();
      for (int i = -4 - bottleOffset2.dx.toInt(); i <= 64 + 4; i++) {
        animList2.add(
          Offset(
            i.toDouble() + bottleOffset2.dx.toInt(),
            math.sin(
                      (waveAnimationController.value * 360 - i) %
                          360 *
                          vector.degrees2Radians,
                    ) *
                    4 +
                (((100 - widget.percentageValue) * 0.5)),
          ),
        );
      }
      // trigger repaint
      setState(() {});
    });

    waveAnimationController.repeat();
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    waveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor ?? FitnessAppTheme.nearlyDarkBlue;
    final secondary = widget.secondaryColor ?? FitnessAppTheme.nearlyDarkBlue;
    return Container(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
        builder: (context, child) => Stack(
          children: <Widget>[
            ClipPath(
              clipper: WaveClipper(animationController.value, animList1),
              child: Container(
                decoration: BoxDecoration(
                  color: secondary.withAlpha((0.5 * 255).round()),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  gradient: LinearGradient(
                    colors: [
                      secondary.withAlpha((0.2 * 255).round()),
                      secondary.withAlpha((0.5 * 255).round()),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            ClipPath(
              clipper: WaveClipper(animationController.value, animList2),
              child: Container(
                decoration: BoxDecoration(
                  color: primary,
                  gradient: LinearGradient(
                    colors: [primary.withAlpha((0.4 * 255).round()), primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
            // Percentage text overlay (can be hidden)
            if (widget.showText)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.percentageValue.round().toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w700,
                          fontSize: widget.compact ? 13 : 18,
                          color: FitnessAppTheme.white,
                          shadows: widget.compact ? [
                            Shadow(
                              offset: Offset(0.5, 0.5),
                              blurRadius: 1.5,
                              color: Colors.black.withAlpha((0.4 * 255).round()),
                            ),
                          ] : null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: widget.compact ? 0.5 : 2.0),
                        child: Text(
                          '%',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w700,
                            fontSize: widget.compact ? 9 : 12,
                            color: FitnessAppTheme.white,
                            shadows: widget.compact ? [
                              Shadow(
                                offset: Offset(0.5, 0.5),
                                blurRadius: 1.5,
                                color: Colors.black.withAlpha((0.4 * 255).round()),
                              ),
                            ] : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;
  final List<Offset> waveList1;

  WaveClipper(this.animation, this.waveList1);

  @override
  Path getClip(Size size) {
    final Path path = Path();
    if (waveList1.isEmpty) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      path.moveTo(waveList1.first.dx, waveList1.first.dy);
      for (final pt in waveList1) {
        path.lineTo(pt.dx / 64.0 * size.width, pt.dy / 64.0 * size.height);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0.0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldDelegate) =>
      animation != oldDelegate.animation || waveList1 != oldDelegate.waveList1;
}
