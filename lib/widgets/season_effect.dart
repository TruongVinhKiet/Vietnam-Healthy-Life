import 'dart:math';
import 'package:flutter/material.dart';
import 'settings_provider.dart';
import 'season_effect_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';

enum Season {
  spring, // Tháng 3, 4, 5 - Hoa rơi
  summer, // Tháng 6, 7, 8 - Mưa
  autumn, // Tháng 9, 10, 11 - Lá rụng
  winter, // Tháng 12, 1, 2 - Tuyết rơi
}

enum WeatherEffect { none, rain, snow, sun, thunder, clouds, fog }

class SeasonEffect extends StatefulWidget {
  final Widget child;
  final DateTime currentDate;
  final bool enabled;

  const SeasonEffect({
    super.key,
    required this.child,
    required this.currentDate,
    this.enabled = true,
  });

  static Season getSeasonFromDate(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter; // Tháng 12, 1, 2
  }

  @override
  State<SeasonEffect> createState() => _SeasonEffectState();
}

class _SeasonEffectState extends State<SeasonEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  WeatherEffect _weatherEffect = WeatherEffect.none;
  double _flash = 0.0; // for thunder flash effect
  bool _showLightning = false;
  final List<Offset> _lightningPath = [];
  double _rainTilt = 0.0; // radians, small tilt from vertical for all raindrops

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initializeParticles();
    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }

  void _initializeParticles() {
    _particles.clear();
    final season = SeasonEffect.getSeasonFromDate(widget.currentDate);
    // read intensity from settings (low/medium/high)
    double intensityMultiplier = 1.0; // default medium
    try {
      final s = _findSettings(context);
      final ef = s?.effectIntensity?.toString() ?? 'medium';
      if (ef == 'low') {
        intensityMultiplier = 0.6;
      } else if (ef == 'high') {
        intensityMultiplier = 1.6;
      } else {
        intensityMultiplier = 1.0;
      }
    } catch (e) {
      intensityMultiplier = 1.0;
    }
    // decide particle count based on season or weather (more prominent)
    int particleCount;
    switch (_weatherEffect) {
      case WeatherEffect.rain:
        particleCount = 300;
        break;
      case WeatherEffect.thunder:
        particleCount = 380;
        break;
      case WeatherEffect.snow:
        particleCount = 220;
        break;
      case WeatherEffect.sun:
        particleCount = 90;
        break;
      case WeatherEffect.clouds:
      case WeatherEffect.fog:
        particleCount = 200;
        break;
      default:
        particleCount = season == Season.summer ? 140 : 100;
    }

    final effectiveCount = max(
      8,
      (particleCount * intensityMultiplier).round(),
    );
    // prepare a shared rain tilt angle for consistent slanted fall
    if (_weatherEffect == WeatherEffect.rain ||
        _weatherEffect == WeatherEffect.thunder) {
      // If user provided a wind direction in settings, use it to control tilt
      try {
        final s = _findSettings(context);
        double? userWindDeg;
        if (s != null) {
          try {
            // SettingsProvider exposes windDirection as double
            userWindDeg = (s.windDirection is double)
                ? s.windDirection as double
                : (s.windDirection?.toDouble());
          } catch (e) {
            userWindDeg = null;
          }
        }
        if (userWindDeg != null) {
          final rad = userWindDeg * pi / 180.0;
          // Map wind direction to a tilt angle (horizontal component). Use sin(rad) scaled to reasonable tilt.
          _rainTilt = (sin(rad)) * 0.45; // max ~0.45 rad tilt
        } else {
          // small random tilt if user didn't set direction
          final base = (_random.nextDouble() - 0.5) * 0.6; // -0.3..0.3
          _rainTilt = (_weatherEffect == WeatherEffect.thunder)
              ? base * 1.6
              : base;
        }
      } catch (e) {
        final base = (_random.nextDouble() - 0.5) * 0.6;
        _rainTilt = (_weatherEffect == WeatherEffect.thunder)
            ? base * 1.6
            : base;
      }
    } else {
      _rainTilt = 0.0;
    }

    for (int i = 0; i < effectiveCount; i++) {
      final baseSpeedRaw =
          (_weatherEffect == WeatherEffect.rain ||
              _weatherEffect == WeatherEffect.thunder)
          ? (_random.nextDouble() * 1.6 + 0.6)
          : (_random.nextDouble() * 0.6 + 0.2);
      final baseSpeed =
          baseSpeedRaw * (1.0 + (intensityMultiplier - 1.0) * 0.6);
      final baseSize = (_weatherEffect == WeatherEffect.snow)
          ? (_random.nextDouble() * 10 + 5) * (0.9 + intensityMultiplier * 0.2)
          : (_weatherEffect == WeatherEffect.rain
                    ? (_random.nextDouble() * 2 + 2.0)
                    : (_random.nextDouble() * 6 + 3)) *
                (0.9 + intensityMultiplier * 0.15);
      // For rain/thunder, lock rotation to _rainTilt and reduce rotationSpeed so drops don't spin
      final rot =
          (_weatherEffect == WeatherEffect.rain ||
              _weatherEffect == WeatherEffect.thunder)
          ? _rainTilt
          : (_random.nextDouble() * 2 * pi);
      final rotSpeed =
          (_weatherEffect == WeatherEffect.rain ||
              _weatherEffect == WeatherEffect.thunder)
          ? (_random.nextDouble() - 0.5) * 0.02
          : (_random.nextDouble() - 0.5) * 0.2;
      _particles.add(
        Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: baseSpeed,
          size: baseSize,
          rotation: rot,
          rotationSpeed: rotSpeed,
          season: season,
          effect: _weatherEffect,
        ),
      );
    }
  }

  void _updateParticles() {
    for (var particle in _particles) {
      // movement depends on particle.effect - tuned for higher prominence
      switch (particle.effect) {
        case WeatherEffect.rain:
          // Use shared rain tilt so all drops fall consistently in the same direction
          // tilt is angle from vertical. dx = sin(tilt)*fall, dy = cos(tilt)*fall
          // Add a smooth sway based on particle position to avoid frame-to-frame random jitter
          final fall = particle.speed * 0.12;
          particle.x +=
              sin(_rainTilt) * fall * (0.95 + (particle.speed * 0.15));
          particle.y +=
              cos(_rainTilt) * fall * (0.95 + (particle.speed * 0.15));
          // smooth lateral sway (sinusoidal) instead of random jitter for fluid motion
          final sway =
              sin(particle.y * 12.0 + particle.rotation * 4.0) *
              0.006 *
              (1.0 + particle.speed * 0.2);
          particle.x += sway;
          break;
        case WeatherEffect.thunder:
          // Use shared tilt but stronger fall and smoother lateral movement for thunder storms
          final fallT = particle.speed * 0.16;
          particle.x +=
              sin(_rainTilt) * fallT * (1.05 + (particle.speed * 0.25));
          particle.y +=
              cos(_rainTilt) * fallT * (0.95 + (particle.speed * 0.25));
          // smoother, larger sway for stormy conditions
          final swayT =
              sin(particle.y * 8.0 + particle.rotation * 3.0) *
              0.02 *
              (1.0 + particle.speed * 0.4);
          particle.x += swayT;
          break;
        case WeatherEffect.snow:
          // large, slower drifting snowflakes; apply wind tilt influence
          particle.y += particle.speed * 0.045;
          particle.x +=
              sin(_rainTilt) * particle.speed * 0.06 +
              sin(particle.y * 6) * 0.008;
          break;
        case WeatherEffect.sun:
          // gentle rising sparkles
          particle.y -= particle.speed * 0.008;
          particle.x += cos(particle.rotation) * 0.004;
          break;
        case WeatherEffect.clouds:
        case WeatherEffect.fog:
          // clouds/fog drift according to wind tilt and slow per-particle jitter
          particle.x +=
              sin(_rainTilt) * particle.speed * 0.03 +
              (particle.speed * 0.008) * (particle.rotation.sign);
          break;
        default:
          particle.y += particle.speed * 0.03;
      }

      // Horizontal sway for leaves/flowers
      if (particle.season == Season.autumn ||
          particle.season == Season.spring) {
        particle.x += sin(particle.y * 10) * 0.015;
      }

      particle.rotation += particle.rotationSpeed;

      // Recycle when out of bounds with some variation for richness
      if (particle.y > 1.2) {
        particle.y = -0.2 - _random.nextDouble() * 0.2;
        particle.x = _random.nextDouble();
        particle.rotation = _random.nextDouble() * 2 * pi;
      }
      if (particle.x < -0.2 || particle.x > 1.2) {
        particle.x = _random.nextDouble();
      }
    }

    // thunder: stronger, more frequent flash and prepare bolt path
    if (_weatherEffect == WeatherEffect.thunder) {
      // higher chance of flash for dramatic effect
      if (_random.nextDouble() < 0.035) {
        _flash = 1.0;
        // create lightning path
        _createLightningPath();
      }
      _flash = (_flash - 0.06).clamp(0.0, 1.0);
    } else {
      _flash = (_flash - 0.02).clamp(0.0, 1.0);
    }
  }

  void _createLightningPath() {
    _showLightning = true;
    _lightningPath.clear();
    final segments = 4 + _random.nextInt(5);
    double x = _random.nextDouble();
    double y = -0.1;
    for (int i = 0; i < segments; i++) {
      x += (_random.nextDouble() - 0.5) * 0.25;
      y += 0.18 + _random.nextDouble() * 0.22;
      _lightningPath.add(Offset(x.clamp(0.0, 1.0), y.clamp(-0.2, 1.2)));
    }
    // Hide after a short moment
    Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)), () {
      if (mounted) {
        setState(() {
          _showLightning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect widget.enabled and global falling_leaves setting
    final settings = _findSettings(context);
    final enableParticles =
        widget.enabled &&
        (
          // Only show falling leaves when seasonal UI is on AND user enabled leaves
          ((settings?.seasonalUiEnabled ?? false) &&
              (settings?.fallingLeavesEnabled ?? false)) ||
          // Weather effects only when both toggles are on
          ((settings?.weatherEffectsEnabled ?? false) &&
              (settings?.weatherEnabled ?? false))
        );

    final season = SeasonEffect.getSeasonFromDate(widget.currentDate);
    // determine weather effect mode
    WeatherEffect weatherEffect = WeatherEffect.none;
    try {
      if (settings != null &&
          settings.weatherEnabled &&
          settings.weatherLastData != null) {
        final w = settings.weatherLastData;
        String cond = '';
        try {
          cond = (w['weather'] != null && w['weather'].isNotEmpty)
              ? w['weather'][0]['main'].toString().toLowerCase()
              : '';
        } catch (e) {
          cond = '';
        }
        if (cond.contains('rain') || cond.contains('drizzle')) {
          weatherEffect = WeatherEffect.rain;
        } else if (cond.contains('snow')) {
          weatherEffect = WeatherEffect.snow;
        } else if (cond.contains('thunder')) {
          weatherEffect = WeatherEffect.thunder;
        } else if (cond.contains('clear')) {
          weatherEffect = WeatherEffect.sun;
        } else if (cond.contains('cloud')) {
          weatherEffect = WeatherEffect.clouds;
        } else if (cond.contains('mist') ||
            cond.contains('fog') ||
            cond.contains('haze')) {
          weatherEffect = WeatherEffect.fog;
        }
      }
    } catch (e) {
      weatherEffect = WeatherEffect.none;
    }
    // update local _weatherEffect and reinit particles if changed
    if (_weatherEffect != weatherEffect) {
      _weatherEffect = weatherEffect;
      _initializeParticles();
    }

    // choose background image: priority
    // 1) if weather_enabled and last data exists -> weather asset
    // 2) else if seasonal_ui_enabled -> seasonal_custom_bg or seasonal asset
    // 3) else if background_image_url present -> use it
    Widget? backgroundWidget;
    String bgKey = 'none';
    try {
      if (settings != null &&
          settings.weatherEnabled &&
          settings.weatherLastData != null) {
        // Use weather-based background
        final w = settings.weatherLastData;
        String cond = '';
        try {
          cond = (w['weather'] != null && w['weather'].isNotEmpty)
              ? w['weather'][0]['main'].toString().toLowerCase()
              : '';
        } catch (e) {
          cond = '';
        }
        String asset = 'assets/weather/clear.png';
        if (cond.contains('clear')) {
          asset = 'assets/weather/clear.png';
        } else if (cond.contains('cloud')) {
          asset = 'assets/weather/clouds.png';
        } else if (cond.contains('rain') || cond.contains('drizzle')) {
          asset = 'assets/weather/rain.png';
        } else if (cond.contains('snow')) {
          asset = 'assets/weather/snow.png';
        } else if (cond.contains('thunder')) {
          asset = 'assets/weather/thunder.png';
        } else if (cond.contains('mist') ||
            cond.contains('fog') ||
            cond.contains('haze')) {
          asset = 'assets/weather/fog.png';
        }

        backgroundWidget = Image.asset(asset, fit: BoxFit.cover);
        bgKey = asset;
      } else if (settings != null && settings.seasonalUiEnabled) {
        // if user provided seasonal_custom_bg, use it
        final custom = settings.seasonalCustomBg;
        if (custom != null && custom.isNotEmpty) {
          final resolved = custom.startsWith('http')
              ? custom
              : '${ApiConfig.baseUrl}$custom';
          backgroundWidget = Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: resolved,
              fit: BoxFit.cover,
              placeholder: (c, u) => Container(color: Colors.black12),
              errorWidget: (c, u, e) => Container(color: Colors.black12),
            ),
          );
          bgKey = resolved;
        } else {
          // map season to assets/season
          String asset = 'assets/season/spring.png';
          switch (season) {
            case Season.spring:
              asset = 'assets/season/spring.png';
              break;
            case Season.summer:
              asset = 'assets/season/summer.png';
              break;
            case Season.autumn:
              asset = 'assets/season/autumn.png';
              break;
            case Season.winter:
              asset = 'assets/season/winter.png';
              break;
          }
          backgroundWidget = Image.asset(asset, fit: BoxFit.cover);
          bgKey = asset;
        }
      } else if (settings != null &&
          settings.backgroundImageEnabled == true &&
          settings.backgroundImageUrl != null &&
          settings.backgroundImageUrl!.isNotEmpty) {
        final url = settings.backgroundImageUrl!;
        final resolved = url.startsWith('http')
            ? url
            : '${ApiConfig.baseUrl}$url';
        backgroundWidget = CachedNetworkImage(
          imageUrl: resolved,
          fit: BoxFit.cover,
          placeholder: (c, u) => Container(color: Colors.black12),
          errorWidget: (c, u, e) => Container(color: Colors.black12),
        );
        bgKey = resolved;
      }
    } catch (e) {
      // ignore image load errors
      backgroundWidget = null;
    }

    // Notify SeasonEffectProvider whether we have a background to display and desired scrim
    try {
      final seasonNotifier = SeasonEffectNotifier.maybeOf(context);
      if (seasonNotifier != null) {
        if (backgroundWidget != null) {
          double scrim = 0.22;
          if (_weatherEffect == WeatherEffect.sun) {
            scrim = 0.10;
          } else if (_weatherEffect == WeatherEffect.rain) {
            scrim = 0.30;
          } else if (_weatherEffect == WeatherEffect.thunder) {
            scrim = 0.36;
          } else if (_weatherEffect == WeatherEffect.snow) {
            scrim = 0.16;
          }
          seasonNotifier.setBackgroundAvailability(true, scrim: scrim);
        } else {
          seasonNotifier.setBackgroundAvailability(false, scrim: 0.0);
        }
      }
    } catch (e) {
      // ignore
    }

    final children = <Widget>[];
    // Build a background container that crossfades between images when bgKey changes
    if (backgroundWidget != null) {
      children.add(
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: SizedBox(
              key: ValueKey<String>(bgKey),
              width: double.infinity,
              height: double.infinity,
              child: backgroundWidget,
            ),
          ),
        ),
      );
      // scrim overlay to improve contrast for foreground UI
      double scrimOpacity = 0.22;
      if (_weatherEffect == WeatherEffect.sun) {
        scrimOpacity = 0.10;
      } else if (_weatherEffect == WeatherEffect.rain) {
        scrimOpacity = 0.30;
      } else if (_weatherEffect == WeatherEffect.thunder) {
        scrimOpacity = 0.36;
      } else if (_weatherEffect == WeatherEffect.snow) {
        scrimOpacity = 0.16;
      }
      children.add(
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Colors.black.withAlpha((scrimOpacity * 255).round()),
            ),
          ),
        ),
      );
    }
    children.add(widget.child);
    if (enableParticles) {
      children.add(
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: SeasonPainter(
                particles: _particles,
                season: season,
                weatherEffect: _weatherEffect,
                flash: _flash,
                lightningPath: _lightningPath,
                showLightning: _showLightning,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: children);
  }

  // helper to find SettingsNotifier without importing directly to avoid cycles
  dynamic _findSettings(BuildContext context) {
    try {
      // SettingsProvider exposes maybeSettings extension
      return context.maybeSettings();
    } catch (e) {
      return null;
    }
  }
}

class Particle {
  double x;
  double y;
  final double speed;
  final double size;
  double rotation;
  final double rotationSpeed;
  final Season season;
  final WeatherEffect effect;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.season,
    this.effect = WeatherEffect.none,
  });
}

class SeasonPainter extends CustomPainter {
  final List<Particle> particles;
  final Season season;
  final WeatherEffect weatherEffect;
  final double flash;
  final List<Offset> lightningPath;
  final bool showLightning;

  SeasonPainter({
    required this.particles,
    required this.season,
    this.weatherEffect = WeatherEffect.none,
    this.flash = 0.0,
    this.lightningPath = const [],
    this.showLightning = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // If thunder flash active, draw after particles as overlay
    for (var particle in particles) {
      final paint = Paint();
      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(particle.rotation);

      // choose drawing by particle.effect first, else fallback to season
      switch (particle.effect) {
        case WeatherEffect.rain:
          _drawRainDrop(canvas, particle, paint);
          break;
        case WeatherEffect.snow:
          _drawSnowflake(canvas, particle.size, paint);
          break;
        case WeatherEffect.sun:
          _drawSunSpark(canvas, particle.size, paint);
          break;
        case WeatherEffect.thunder:
          _drawRainDrop(canvas, particle, paint);
          break;
        case WeatherEffect.clouds:
        case WeatherEffect.fog:
          _drawFogBlob(canvas, particle.size, paint);
          break;
        case WeatherEffect.none:
          switch (season) {
            case Season.spring:
              _drawPetal(canvas, particle.size, paint);
              break;
            case Season.summer:
              _drawRainDrop(canvas, particle, paint);
              break;
            case Season.autumn:
              _drawLeaf(canvas, particle.size, paint);
              break;
            case Season.winter:
              _drawSnowflake(canvas, particle.size, paint);
              break;
          }
      }

      canvas.restore();
    }

    // thunder flash overlay
    if (weatherEffect == WeatherEffect.thunder && flash > 0.01) {
      final paint = Paint()
        ..color = Colors.white.withAlpha((flash.clamp(0.0, 0.9) * 255).round());
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      // draw lightning bolt if provided
      if (showLightning && lightningPath.isNotEmpty) {
        final boltPath = Path();
        for (int i = 0; i < lightningPath.length; i++) {
          final p = lightningPath[i];
          final pt = Offset(p.dx * size.width, p.dy * size.height);
          if (i == 0) {
            boltPath.moveTo(pt.dx, pt.dy);
          } else {
            boltPath.lineTo(pt.dx, pt.dy);
          }
        }
        // Glow
        final glow = Paint()
          ..color = Colors.white.withAlpha(
            ((0.14 * flash.clamp(0.0, 1.0)) * 255).round(),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawPath(boltPath, glow);
        // Bright core
        final core = Paint()
          ..color = Colors.white.withAlpha(
            ((0.95 * flash.clamp(0.0, 1.0)) * 255).round(),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(boltPath, core);
      }
    }

    // sun gentle overlay (glow at top-right)
    if (weatherEffect == WeatherEffect.sun) {
      final gradient = RadialGradient(
        colors: [
          Colors.yellow.withAlpha((0.18 * 255).round()),
          Colors.transparent,
        ],
        radius: 0.6,
        center: const Alignment(0.8, -0.8),
      );
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      final paint = Paint()..shader = gradient.createShader(rect);
      canvas.drawRect(rect, paint);
    }
  }

  void _drawPetal(Canvas canvas, double size, Paint paint) {
    // Cánh hoa màu hồng/trắng
    final colors = [Colors.pink.shade200, Colors.white, Colors.pink.shade100];
    paint.color = colors[Random().nextInt(colors.length)].withAlpha(
      (0.7 * 255).round(),
    );

    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset.zero, radius: size / 2));
    canvas.drawPath(path, paint);
  }

  void _drawRainDrop(Canvas canvas, Particle particle, Paint paint) {
    // Draw an elongated ellipse (ellipse aligned with fall direction because canvas is rotated)
    final isThunder = particle.effect == WeatherEffect.thunder;
    // base size influenced by particle.size and speed
    final base = max(1.0, particle.size * (isThunder ? 1.0 : 0.7));
    // elongation factor: faster drops are more stretched
    final elong = (isThunder ? 2.2 : 1.6) + (particle.speed * 0.5);
    final width = base * 0.7; // narrower horizontally
    final height = base * elong; // stretched vertically (along fall direction)

    // glow (soft oval)
    final glow = Paint()
      ..isAntiAlias = true
      ..color = Colors.lightBlue.withAlpha(
        ((isThunder ? 0.20 : 0.12) * 255).round(),
      )
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isThunder ? 10 : 6);
    final glowRect = Rect.fromCenter(
      center: Offset.zero,
      width: width * 2.4,
      height: height * 1.6,
    );
    canvas.drawOval(glowRect, glow);

    // main droplet ellipse
    final core = Paint()
      ..isAntiAlias = true
      ..color = Colors.lightBlue.withAlpha(
        ((isThunder ? 0.95 : 0.78) * 255).round(),
      );
    final coreRect = Rect.fromCenter(
      center: Offset(0, 0),
      width: width,
      height: height,
    );
    canvas.drawOval(coreRect, core);

    // small leading highlight (ellipse) closer to the lower tip (leading edge)
    final hl = Paint()
      ..isAntiAlias = true
      ..color = Colors.white.withAlpha(((isThunder ? 0.9 : 0.7) * 255).round());
    final hlOffset = Offset(0, height * 0.38);
    final hlRect = Rect.fromCenter(
      center: hlOffset,
      width: width * 0.5,
      height: height * 0.28,
    );
    canvas.drawOval(hlRect, hl);
  }

  void _drawSunSpark(Canvas canvas, double size, Paint paint) {
    paint.color = Colors.yellow.withAlpha((0.6 * 255).round());
    canvas.drawCircle(Offset.zero, size * 1.2, paint);
  }

  void _drawFogBlob(Canvas canvas, double size, Paint paint) {
    paint.color = Colors.white.withAlpha((0.12 * 255).round());
    canvas.drawCircle(Offset.zero, size * 2.0, paint);
  }

  void _drawLeaf(Canvas canvas, double size, Paint paint) {
    // Lá màu vàng/cam/nâu
    final colors = [
      Colors.orange.shade700,
      Colors.yellow.shade800,
      Colors.brown.shade400,
      Colors.red.shade400,
    ];
    paint.color = colors[Random().nextInt(colors.length)].withAlpha(
      (0.7 * 255).round(),
    );

    final path = Path();
    path.moveTo(-size / 2, 0);
    path.quadraticBezierTo(0, -size / 3, size / 2, 0);
    path.quadraticBezierTo(0, size / 3, -size / 2, 0);
    canvas.drawPath(path, paint);
  }

  void _drawSnowflake(Canvas canvas, double size, Paint paint) {
    // Bông tuyết màu trắng
    paint.color = Colors.white.withAlpha((0.8 * 255).round());
    paint.strokeWidth = 1.5;
    paint.strokeCap = StrokeCap.round;

    // Vẽ 6 nhánh
    for (int i = 0; i < 6; i++) {
      canvas.save();
      canvas.rotate(i * pi / 3);
      canvas.drawLine(Offset.zero, Offset(0, size), paint);
      // Nhánh phụ
      canvas.drawLine(
        Offset(0, size * 0.6),
        Offset(-size * 0.3, size * 0.4),
        paint,
      );
      canvas.drawLine(
        Offset(0, size * 0.6),
        Offset(size * 0.3, size * 0.4),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(SeasonPainter oldDelegate) => true;
}
