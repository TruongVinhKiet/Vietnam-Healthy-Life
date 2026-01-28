import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_diary/config/api_config.dart';
import 'package:my_diary/models/daily_meal_suggestion.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/daily_meal_suggestion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimelineEvent {
  final DateTime time;
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  final bool isDone;
  final String? imageUrl;

  TimelineEvent({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.isDone,
    this.imageUrl,
  });
}

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  Timer? _clockTimer;
  DateTime _vnNow = _vnNowTime();

  final ScrollController _scrollController = ScrollController();
  bool _didAutoScroll = false;

  static const double _pxPerMinute = 2.0;
  static const double _timelineX = 80.0;
  static const double _cardHeight = 150.0;
  static const double _cardGap = 12.0;

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _me;
  Map<String, dynamic>? _settings;
  List<dynamic> _todayMedications = [];
  DailyMealSuggestions? _dailySuggestions;

  List<TimelineEvent> _events = [];

  static DateTime _vnNowTime() {
    final utc = DateTime.now().toUtc();
    return utc.add(const Duration(hours: 7));
  }

  static String _vnDateString([DateTime? date]) {
    final vn = date == null
        ? _vnNowTime()
        : DateTime(date.year, date.month, date.day);
    final y = vn.year.toString().padLeft(4, '0');
    final m = vn.month.toString().padLeft(2, '0');
    final d = vn.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _vnNow = _vnNowTime();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? prefs.getString('token');
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _didAutoScroll = false;
      final me = await AuthService.me();
      final settings = await AuthService.getSettings();
      final meds = await _fetchTodayMedications();
      final daily = await DailyMealSuggestionService.getSuggestions(
        date: DateTime(_vnNow.year, _vnNow.month, _vnNow.day),
      );

      if (!mounted) return;

      setState(() {
        _me = me;
        _settings = settings;
        _todayMedications = meds;
        _dailySuggestions =
            (daily['success'] == true &&
                daily['suggestions'] is DailyMealSuggestions)
            ? (daily['suggestions'] as DailyMealSuggestions)
            : null;
        _isLoading = false;
      });

      _rebuildEvents();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> _fetchTodayMedications() async {
    final token = await _getToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/medications/today'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    if (data is Map && data['medications'] is List) {
      return List<dynamic>.from(data['medications']);
    }

    if (data is List) return data;

    return [];
  }

  DateTime? _parseTimeToday(String? hhmmOrHhmmss) {
    if (hhmmOrHhmmss == null || hhmmOrHhmmss.isEmpty) return null;
    final parts = hhmmOrHhmmss.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return DateTime.utc(_vnNow.year, _vnNow.month, _vnNow.day, h, m);
  }

  void _rebuildEvents() {
    final vnDate = _vnDateString(_vnNow);

    final breakfast = _parseTimeToday(
      _settings?['meal_time_breakfast']?.toString() ?? '07:00',
    );
    final lunch = _parseTimeToday(
      _settings?['meal_time_lunch']?.toString() ?? '11:00',
    );
    final snack = _parseTimeToday(
      _settings?['meal_time_snack']?.toString() ?? '13:00',
    );
    final dinner = _parseTimeToday(
      _settings?['meal_time_dinner']?.toString() ?? '18:00',
    );

    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    final events = <TimelineEvent>[];

    void addMealEvent(String mealType, DateTime? time) {
      if (time == null) return;
      final suggestions = _dailySuggestions?.getSuggestionsForMeal(mealType);
      DailyMealSuggestion? picked;
      if (suggestions != null) {
        for (final s in suggestions) {
          if (s.isAccepted) {
            picked = s;
            break;
          }
        }
      }
      picked ??= (suggestions != null && suggestions.isNotEmpty)
          ? suggestions.first
          : null;

      final isAccepted = picked?.isAccepted ?? false;
      final name = picked?.displayName ?? '';
      final image = picked?.imageUrl;
      final portion = picked?.portionLabel;

      final subtitle = [
        if (name.isNotEmpty) name,
        if (portion != null && portion.isNotEmpty) portion,
      ].join('\n');

      events.add(
        TimelineEvent(
          time: time,
          title: DailyMealSuggestionService.getMealTypeName(mealType),
          subtitle: subtitle.isNotEmpty ? subtitle : '—',
          type: 'meal',
          icon: DailyMealSuggestionService.getMealIcon(mealType),
          isDone: isAccepted,
          imageUrl: (image != null && image.isNotEmpty) ? image : null,
        ),
      );
    }

    addMealEvent('breakfast', breakfast);
    addMealEvent('lunch', lunch);
    addMealEvent('snack', snack);
    addMealEvent('dinner', dinner);

    for (final med in _todayMedications) {
      try {
        final timeStr = med['medication_time']?.toString();
        final time = _parseTimeToday(timeStr);
        if (time == null) continue;

        final isDone = med['status']?.toString() == 'taken';
        final condition = med['condition_name']?.toString() ?? 'Medication';
        final drug = med['drug_name']?.toString();
        final notes = med['notes']?.toString();

        final subtitleLines = <String>[];
        if (drug != null && drug.isNotEmpty) subtitleLines.add(drug);
        if (notes != null && notes.isNotEmpty) subtitleLines.add(notes);

        events.add(
          TimelineEvent(
            time: time,
            title: condition,
            subtitle: subtitleLines.isNotEmpty ? subtitleLines.join('\n') : '—',
            type: 'medication',
            icon: Icons.medication_liquid,
            isDone: isDone,
          ),
        );
      } catch (_) {
        // ignore single item errors
      }
    }

    // Water reminders based on daily target (250ml every ~2 hours)
    try {
      final waterTargetRaw = _me?['daily_water_target'];
      final weightKg = toDouble(_me?['weight_kg']);
      final targetMl = (() {
        final t = toDouble(waterTargetRaw);
        if (t > 0) return t;
        if (weightKg > 0) return weightKg * 35.0;
        return 2000.0;
      })();

      final consumedMl = toDouble(
        _me?['today_water'] ?? _me?['today_water_ml'] ?? _me?['total_water'],
      );

      int totalServings = targetMl > 0 ? (targetMl / 250.0).ceil() : 0;
      if (totalServings < 0) totalServings = 0;

      int startMin = 7 * 60;
      int endMin = 23 * 60;

      int maxAt60 = ((endMin - startMin) ~/ 60) + 1;
      if (totalServings > maxAt60) {
        startMin = 0;
        endMin = 23 * 60;
        maxAt60 = ((endMin - startMin) ~/ 60) + 1;
      }
      if (totalServings > maxAt60) {
        totalServings = maxAt60;
      }

      int stepMin = 120;
      if (totalServings > 1) {
        final raw = ((endMin - startMin) / (totalServings - 1)).floor();
        stepMin = raw.clamp(60, 120);
      }

      DateTime timeAtMinutes(int minutes) {
        final h = (minutes ~/ 60).clamp(0, 23);
        final m = (minutes % 60).clamp(0, 59);
        return DateTime.utc(_vnNow.year, _vnNow.month, _vnNow.day, h, m);
      }

      final doneServings = (consumedMl / 250.0).floor();

      for (int i = 0; i < totalServings; i++) {
        final t = timeAtMinutes(startMin + stepMin * i);
        events.add(
          TimelineEvent(
            time: t,
            title: 'Uống nước',
            subtitle: 'Nước lọc\n250 ml',
            type: 'water',
            icon: Icons.water_drop_rounded,
            isDone: i < doneServings,
          ),
        );
      }
    } catch (_) {
      // ignore water scheduling failures
    }

    events.sort((a, b) => a.time.compareTo(b.time));

    if (!mounted) return;
    setState(() {
      _events = events;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScrollToNow();
    });

    debugPrint('[TimelineScreen] Built ${events.length} events for $vnDate');
  }

  void _autoScrollToNow() {
    if (_didAutoScroll) return;
    if (!_scrollController.hasClients) return;

    final startOfDay = DateTime.utc(_vnNow.year, _vnNow.month, _vnNow.day);
    final diffSeconds = _vnNow.difference(startOfDay).inSeconds.clamp(0, 86400);
    final nowY = (diffSeconds / 60.0) * _pxPerMinute;
    final dayHeight = 24 * 60 * _pxPerMinute;

    final target = (nowY - 240).clamp(0.0, dayHeight).toDouble();
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );

    _didAutoScroll = true;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final now = _vnNow;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline 24h'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _load,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final dayHeight = 24 * 60 * _pxPerMinute;
                final startOfDay = DateTime.utc(
                  now.year,
                  now.month,
                  now.day,
                  0,
                  0,
                  0,
                );
                final diffSeconds = now
                    .difference(startOfDay)
                    .inSeconds
                    .clamp(0, 86400);
                final nowY = (diffSeconds / 60.0) * _pxPerMinute;

                final cardLeft = _timelineX + 12;
                final cardWidth = (constraints.maxWidth - cardLeft - 16)
                    .clamp(180.0, 520.0)
                    .toDouble();

                double timeToY(DateTime t) {
                  final s = t.difference(startOfDay).inSeconds;
                  final clamped = s.clamp(0, 86400);
                  return (clamped / 60.0) * _pxPerMinute;
                }

                final placed = <Map<String, dynamic>>[];
                double lastBottom = -1e9;
                for (final e in _events) {
                  final markerY = timeToY(e.time);
                  var top = markerY - (_cardHeight / 2);
                  if (top < lastBottom + _cardGap) {
                    top = lastBottom + _cardGap;
                  }
                  top = top.clamp(0.0, dayHeight - _cardHeight).toDouble();
                  lastBottom = top + _cardHeight;
                  placed.add({'e': e, 'markerY': markerY, 'top': top});
                }

                final segments = <Map<String, dynamic>>[];
                double prevY = 0;
                TimelineEvent? prevEvent;
                for (final e in _events) {
                  final endY = timeToY(e.time);
                  segments.add({
                    'start': prevY,
                    'end': endY,
                    'prev': prevEvent,
                  });
                  prevY = endY;
                  prevEvent = e;
                }
                segments.add({
                  'start': prevY,
                  'end': dayHeight,
                  'prev': prevEvent,
                });

                final nowLabel = _formatTime(now);

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: SizedBox(
                    height: dayHeight + 24,
                    child: Stack(
                      children: [
                        for (int h = 0; h <= 24; h++) ...[
                          Positioned(
                            left: 0,
                            top: (h * 60 * _pxPerMinute)
                                .clamp(0.0, dayHeight)
                                .toDouble(),
                            right: 0,
                            child: Container(
                              height: 1,
                              color: Colors.grey.withValues(alpha: 0.12),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: ((h * 60 * _pxPerMinute) - 10)
                                .clamp(0.0, dayHeight - 20)
                                .toDouble(),
                            child: SizedBox(
                              width: _timelineX - 12,
                              child: Text(
                                '${h.toString().padLeft(2, '0')}:00',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                        Positioned(
                          left: _timelineX,
                          top: 0,
                          child: Container(
                            width: 4,
                            height: dayHeight,
                            color: Colors.grey.withValues(alpha: 0.25),
                          ),
                        ),
                        for (final seg in segments) ...[
                          if (seg['prev'] != null) ...[
                            Builder(
                              builder: (context) {
                                final TimelineEvent prev =
                                    seg['prev'] as TimelineEvent;
                                final double start = seg['start'] as double;
                                final double end = seg['end'] as double;
                                final coloredEnd = nowY
                                    .clamp(start, end)
                                    .toDouble();
                                final coloredHeight = (coloredEnd - start)
                                    .clamp(0.0, end - start)
                                    .toDouble();
                                if (coloredHeight <= 0)
                                  return const SizedBox.shrink();
                                final color = prev.isDone
                                    ? Colors.green
                                    : Colors.red;
                                return Positioned(
                                  left: _timelineX,
                                  top: start,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 4,
                                    height: coloredHeight,
                                    color: color.withValues(alpha: 0.85),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                        Positioned(
                          left: 0,
                          top: (nowY - 10)
                              .clamp(0.0, dayHeight - 20)
                              .toDouble(),
                          right: 0,
                          child: Row(
                            children: [
                              SizedBox(
                                width: _timelineX - 12,
                                child: Text(
                                  nowLabel,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: Colors.red.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final item in placed) ...[
                          Builder(
                            builder: (context) {
                              final TimelineEvent e =
                                  item['e'] as TimelineEvent;
                              final double markerY = item['markerY'] as double;
                              final double top = item['top'] as double;
                              final isPast = e.time.isBefore(now);
                              final statusColor = e.isDone
                                  ? Colors.green
                                  : isPast
                                  ? Colors.red
                                  : Colors.grey;

                              final cardCenter = top + (_cardHeight / 2);
                              final connectorTop = markerY < cardCenter
                                  ? markerY
                                  : cardCenter;
                              final connectorHeight = (markerY - cardCenter)
                                  .abs()
                                  .clamp(0.0, dayHeight)
                                  .toDouble();

                              return Stack(
                                children: [
                                  if (connectorHeight > 6)
                                    Positioned(
                                      left: _timelineX + 6,
                                      top: connectorTop.toDouble(),
                                      child: Container(
                                        width: 2,
                                        height: connectorHeight,
                                        color: statusColor.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    left: _timelineX - 6,
                                    top: (markerY - 10)
                                        .clamp(0.0, dayHeight - 20)
                                        .toDouble(),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: statusColor.withValues(
                                            alpha: 0.9,
                                          ),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: cardLeft,
                                    top: top,
                                    width: cardWidth,
                                    height: _cardHeight,
                                    child: _buildEventCard(e, statusColor),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEventCard(TimelineEvent e, Color statusColor) {
    final now = _vnNow;
    final isPast = e.time.isBefore(now);
    final isMissed = isPast && !e.isDone;

    String? missedText;
    if (isMissed) {
      if (e.type == 'meal') {
        missedText =
            'Bạn đã bỏ lỡ ${e.title.toLowerCase()}, hãy chú ý lần sau.';
      } else if (e.type == 'medication') {
        missedText = 'Bạn đã bỏ lỡ giờ uống thuốc, hãy chú ý lần sau.';
      } else if (e.type == 'water') {
        missedText = 'Bạn đã bỏ lỡ lượt uống nước, hãy chú ý lần sau.';
      } else {
        missedText = 'Bạn đã bỏ lỡ, hãy chú ý lần sau.';
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.7), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          if (e.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                e.imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(e.icon, color: statusColor, size: 24),
                  );
                },
              ),
            )
          else
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(e.icon, color: statusColor, size: 26),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(e.time),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  e.title,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  e.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.clip,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                if (missedText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    missedText,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            e.isDone
                ? Icons.check_circle
                : isPast
                ? Icons.cancel
                : Icons.radio_button_unchecked,
            color: statusColor,
          ),
        ],
      ),
    );
  }
}
