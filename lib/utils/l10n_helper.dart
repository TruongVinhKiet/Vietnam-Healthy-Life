import 'package:my_diary/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Helper extension để dễ dàng truy cập AppLocalizations
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

