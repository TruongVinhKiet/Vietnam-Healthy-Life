import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/ui_view/vitamin_view.dart';
import 'package:my_diary/ui_view/mineral_view.dart';
import 'package:my_diary/ui_view/amino_view.dart';
import 'package:my_diary/ui_view/fat_view.dart';
import 'package:my_diary/ui_view/fiber_view.dart';
import 'package:my_diary/screens/vitamins_screen.dart';
import 'package:my_diary/screens/minerals_screen.dart';
import 'package:my_diary/screens/amino_screen.dart';
import 'package:my_diary/screens/fats_screen.dart';
import 'package:my_diary/screens/fibers_screen.dart';
import 'package:my_diary/ui_view/title_view.dart';
import 'package:my_diary/l10n/app_localizations.dart';

/// Combined nutrition overview widget with tabs for Vitamins, Minerals, Amino Acids, Fat, and Fiber
class NutritionOverviewView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const NutritionOverviewView({
    super.key,
    this.animationController,
    this.animation,
  });

  @override
  State<NutritionOverviewView> createState() => _NutritionOverviewViewState();
}

class _NutritionOverviewViewState extends State<NutritionOverviewView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  List<String> _tabLabels = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      _tabLabels = [
        l10n.vitamins,
        l10n.minerals,
        l10n.aminoAcids,
        l10n.fat,
        l10n.fiber,
      ];
    } else {
      _tabLabels = ['Vitamin', 'Mineral', 'Amino Acids', 'Fat', 'Fiber'];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDetailTap() {
    Widget targetScreen;
    switch (_currentTabIndex) {
      case 0:
        targetScreen = const VitaminsScreen();
        break;
      case 1:
        targetScreen = const MineralsScreen();
        break;
      case 2:
        targetScreen = const AminoScreen();
        break;
      case 3:
        targetScreen = const FatsScreen();
        break;
      case 4:
        targetScreen = const FibersScreen();
        break;
      default:
        targetScreen = const VitaminsScreen();
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (ctx) => targetScreen),
    );
  }


  @override
  Widget build(BuildContext context) {
    final anim = widget.animation ?? const AlwaysStoppedAnimation(1.0);
    final a = anim.value;

    return FadeTransition(
      opacity: widget.animation ?? const AlwaysStoppedAnimation(1.0),
      child: Transform(
        transform: Matrix4.translationValues(0.0, 20 * (1.0 - a), 0.0),
        child: Column(
          children: <Widget>[
            // TitleView with dynamic detail navigation
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return TitleView(
                    titleTxt: l10n.nutritionOverview,
                    subTxt: l10n.details,
                    animation: widget.animation ?? const AlwaysStoppedAnimation(1.0),
                    animationController: widget.animationController,
                    onTap: _onDetailTap,
                  );
                },
              ),
            ),
            // TabBar - no left padding, tab starts from left edge
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 24, top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: FitnessAppTheme.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  labelColor: FitnessAppTheme.nearlyBlue,
                  unselectedLabelColor: FitnessAppTheme.grey,
                  indicator: BoxDecoration(
                    color: FitnessAppTheme.nearlyBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                  tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
                ),
              ),
            ),
            // TabBarView with smooth animations
            SizedBox(
              height: 420, // Increased height to prevent overflow in Vitamin tab
              child: TabBarView(
                controller: _tabController,
                physics: const ClampingScrollPhysics(), // Smooth scrolling physics for tabs
                children: [
                  // Tab 0: Vitamins
                  VitaminView(
                    animation: widget.animation,
                    animationController: widget.animationController,
                  ),
                  // Tab 1: Minerals
                  MineralView(
                    animation: widget.animation,
                    animationController: widget.animationController,
                  ),
                  // Tab 2: Amino Acids
                  AminoView(
                    animation: widget.animation,
                    animationController: widget.animationController,
                  ),
                  // Tab 3: Fat
                  FatView(
                    mainScreenAnimation: widget.animation,
                    mainScreenAnimationController: widget.animationController,
                  ),
                  // Tab 4: Fiber
                  FiberView(
                    mainScreenAnimation: widget.animation,
                    mainScreenAnimationController: widget.animationController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

