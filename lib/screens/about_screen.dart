import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    // Delay body content slightly so Hero flight stands out
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.15, 0.8, curve: Curves.easeOut),
          ),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha((0.10 * 255).round()),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final season = SeasonEffectNotifier.maybeOf(context);

    return SeasonEffect(
      currentDate: season?.selectedDate ?? DateTime.now(),
      enabled: season?.enabled ?? true,
      child: Container(
        color: FitnessAppTheme.background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 180,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Giới thiệu'),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          right: -40,
                          bottom: -40,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(
                                (0.08 * 255).round(),
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          top: 30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(
                                (0.06 * 255).round(),
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ScaleTransition(
                            scale: _scale,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: FitnessAppTheme.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      (0.06 * 255).round(),
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Hero(
                                    tag: 'aboutHeroIcon',
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade400,
                                            Colors.cyan.shade300,
                                          ],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.fitness_center,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'VietNam Healthy Life',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Phiên bản 1.0.0',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: FitnessAppTheme.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    (0.06 * 255).round(),
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Giới thiệu',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'VietNam Healthy Life là nền tảng theo dõi dinh dưỡng và sức khỏe dựa trên dữ liệu, kết nối đầy đủ với backend để hỗ trợ:',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  const SizedBox(height: 10),
                                  _bullet('Ghi bữa ăn, đồ uống, tính calo/macros/fiber, lịch sử và thống kê theo ngày/khung giờ.'),
                                  _bullet('Meal Templates, Recipes, Portion sizing giúp tái sử dụng thực đơn và khẩu phần riêng.'),
                                  _bullet('Meal Targets & per-meal targets; Water tracking với custom drinks, timeline, period summary, reset 00:00 (UTC+7).'),
                                  _bullet('Daily Meal Suggestions (tạo thực đơn ngày) và Smart Suggestions (ngữ cảnh, sở thích, bệnh lý, tương tác).'),
                                  _bullet('AI Image Analysis (Gemini Vision): nhận diện món, ước tính dinh dưỡng, duyệt/chấp nhận/ký bác kết quả.'),
                                  _bullet('Health & Medications: điều kiện sức khỏe, log thuốc, cảnh báo tương tác thuốc – dưỡng chất – thực phẩm.'),
                                  _bullet('Nutrient tracking/breakdown/deficiency check; amino, fatty acids, vitamins, minerals, fiber chi tiết.'),
                                  _bullet('Chatbot dinh dưỡng, Admin chat hỗ trợ, Social/community feed; @tag mở nhanh chi tiết món/đồ uống/điều kiện.'),
                                  _bullet('Notifications: gợi ý mới, cảnh báo dinh dưỡng/thuốc, nhắc nước/bữa, kết quả AI, có thể đánh dấu đã đọc.'),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _chip('Theo dõi bữa ăn', Colors.blue),
                                      _chip('Mục tiêu dinh dưỡng', Colors.green),
                                      _chip('Nước & Hydration', Colors.purple),
                                      _chip('AI Image', Colors.orange),
                                      _chip('Daily suggestions', Colors.teal),
                                      _chip('Smart suggestions', Colors.lightBlue),
                                      _chip('Templates & Portions', Colors.deepPurple),
                                      _chip('Health & thuốc', Colors.red),
                                      _chip('Chat & @tag', Colors.indigo),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _FeatureCard(
                                  icon: Icons.analytics_outlined,
                                  title: 'Thống kê thông minh',
                                  desc:
                                      'Xem tiến độ hàng ngày, hàng tuần và xu hướng dinh dưỡng trực quan.',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FeatureCard(
                                  icon: Icons.shield_moon_outlined,
                                  title: 'Tối ưu cho sức khỏe',
                                  desc:
                                      'Tùy chỉnh mục tiêu theo thể trạng và thói quen vận động của bạn.',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(
                (_hover ? 0.12 : 0.06 * 255).round(),
              ),
              blurRadius: _hover ? 14 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha((0.08 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(widget.desc, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
