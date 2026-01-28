import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import '../fitness_app_theme.dart';

class RDACardWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final double current;
  final double target;
  final String unit;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const RDACardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  createState() => _RDACardWidgetState();
}

class _RDACardWidgetState extends State<RDACardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.target > 0
        ? (widget.current / widget.target).clamp(0.0, 1.0)
        : 0.0;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color.withValues(alpha: 0.2),
                              widget.color.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(widget.icon, size: 20, color: widget.color),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: FitnessAppTheme.nearlyBlack,
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: FitnessAppTheme.grey.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.current.toStringAsFixed(1)} ${widget.unit}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                        ),
                      ),
                      Text(
                        '/ ${widget.target.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: FitnessAppTheme.grey.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _CircularProgressPainter(
                          progress: percentage * _progressAnimation.value,
                          color: widget.color,
                        ),
                        child: SizedBox(
                          height: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage * _progressAnimation.value,
                              backgroundColor: FitnessAppTheme.grey.withValues(
                                alpha: 0.1,
                              ),
                              valueColor: AlwaysStoppedAnimation(widget.color),
                              minHeight: 8,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}% hoàn thành',
                    style: TextStyle(
                      fontSize: 12,
                      color: FitnessAppTheme.grey.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // This is a placeholder - we're using LinearProgressIndicator above
    // But you could implement custom painting here for more complex effects
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RDASummaryView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const RDASummaryView({super.key, this.animationController, this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController ?? const AlwaysStoppedAnimation(1.0),
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation ?? const AlwaysStoppedAnimation(1.0),
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - (animation?.value ?? 1.0)),
              0.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 18,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: FitnessAppTheme.grey.withValues(alpha: 0.2),
                      offset: Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          FitnessAppTheme.nearlyDarkBlue.withValues(
                                            alpha: 0.2,
                                          ),
                                          FitnessAppTheme.nearlyBlue.withValues(
                                            alpha: 0.1,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.analytics_outlined,
                                      color: FitnessAppTheme.nearlyDarkBlue,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Nhu cầu dinh dưỡng',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          letterSpacing: -0.2,
                                          color: FitnessAppTheme.nearlyBlack,
                                        ),
                                      ),
                                      Text(
                                        'Cá nhân hóa cho bạn',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          letterSpacing: 0.0,
                                          color: FitnessAppTheme.grey.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/personalized-rda',
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          FitnessAppTheme.nearlyDarkBlue,
                                          FitnessAppTheme.nearlyBlue,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Xem tất cả',
                                          style: TextStyle(
                                            fontFamily:
                                                FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: [
                          RDACardWidget(
                            title: AppLocalizations.of(context)!.vitaminC,
                            subtitle: AppLocalizations.of(context)!.increaseResistance,
                            current: 45.0,
                            target: 75.0,
                            unit: 'mg',
                            color: Colors.orange,
                            icon: Icons.local_pharmacy_outlined,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/vitamins/detail',
                            ),
                          ),
                          RDACardWidget(
                            title: AppLocalizations.of(context)!.calcium,
                            subtitle: AppLocalizations.of(context)!.strongBones,
                            current: 800.0,
                            target: 1000.0,
                            unit: 'mg',
                            color: Colors.blue,
                            icon: Icons.grain_outlined,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/minerals/detail',
                            ),
                          ),
                          RDACardWidget(
                            title: AppLocalizations.of(context)!.fiber,
                            subtitle: AppLocalizations.of(context)!.goodDigestion,
                            current: 18.0,
                            target: 25.0,
                            unit: 'g',
                            color: Colors.green,
                            icon: Icons.eco_outlined,
                            onTap: () =>
                                Navigator.pushNamed(context, '/fibers/detail'),
                          ),
                          RDACardWidget(
                            title: AppLocalizations.of(context)!.omega3,
                            subtitle: AppLocalizations.of(context)!.cardiovascularHealth,
                            current: 150.0,
                            target: 250.0,
                            unit: 'mg',
                            color: Colors.teal,
                            icon: Icons.water_drop_outlined,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/fatty-acids/detail',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
