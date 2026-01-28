import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';

class CameraNutritionScanner extends StatelessWidget {
  const CameraNutritionScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.cameraNutritionScanner);
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text('${l10n.cameraNutritionScanner} - ${l10n.comingSoon}');
          },
        ),
      ),
    );
  }
}
