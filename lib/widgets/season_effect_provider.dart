import 'package:flutter/material.dart';

class SeasonEffectNotifier extends ChangeNotifier {
  bool _enabled = true;
  DateTime _selectedDate = DateTime.now();
  bool _hasBackground = false;
  double _backgroundScrim = 0.0; // 0..1 opacity for dark scrim over background

  bool get enabled => _enabled;
  DateTime get selectedDate => _selectedDate;

  void toggleEffect() {
    _enabled = !_enabled;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  bool get hasBackground => _hasBackground;
  double get backgroundScrim => _backgroundScrim;

  void setBackgroundAvailability(bool hasBg, {double scrim = 0.0}) {
    _hasBackground = hasBg;
    _backgroundScrim = scrim.clamp(0.0, 1.0);
    notifyListeners();
  }

  static SeasonEffectNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedSeasonEffect>()!
        .notifier;
  }

  static SeasonEffectNotifier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedSeasonEffect>()
        ?.notifier;
  }
}

class SeasonEffectProvider extends StatefulWidget {
  final Widget child;

  const SeasonEffectProvider({super.key, required this.child});

  @override
  State<SeasonEffectProvider> createState() => _SeasonEffectProviderState();
}

class _SeasonEffectProviderState extends State<SeasonEffectProvider> {
  final SeasonEffectNotifier _notifier = SeasonEffectNotifier();

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedSeasonEffect(notifier: _notifier, child: widget.child);
  }
}

class _InheritedSeasonEffect extends InheritedWidget {
  final SeasonEffectNotifier notifier;

  const _InheritedSeasonEffect({required this.notifier, required super.child});

  @override
  bool updateShouldNotify(_InheritedSeasonEffect oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
