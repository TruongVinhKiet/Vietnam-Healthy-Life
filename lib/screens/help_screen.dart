import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  final List<_FaqItem> _faqs = [
    _FaqItem(
      'Làm sao để thêm bữa ăn?',
      'Vào Trang chủ > Meals today, chọn bữa sáng/trưa/tối, tìm món ăn hoặc đồ uống, nhập khối lượng. Sau khi lưu, calo và macros cập nhật vào thống kê và Mediterranean diet.',
    ),
    _FaqItem(
      'Sao chép nhanh khẩu phần bữa trước?',
      'Dùng Meal Templates: tạo, lưu, rồi áp dụng lại cho bữa sáng/trưa/tối. Có thể chỉnh khẩu phần từng món trước khi lưu.',
    ),
    _FaqItem(
      'Quản lý công thức và khẩu phần riêng?',
      'Vào Recipes để tạo/sửa công thức cá nhân (dish/drink), tùy chỉnh Portion size, đơn vị và định lượng. Hệ thống tính lại dinh dưỡng theo khẩu phần bạn đặt.',
    ),
    _FaqItem(
      'Nhận gợi ý bữa ăn tự động mỗi ngày?',
      'Daily Meal Suggestions tạo thực đơn ngày dựa trên hồ sơ và mục tiêu. Bạn có thể chấp nhận/từ chối; bản chấp nhận sẽ cộng vào lịch sử bữa ăn.',
    ),
    _FaqItem(
      'Gợi ý thông minh (Smart suggestions) khác gì?',
      'Smart suggestions dùng hành vi, sở thích và điều kiện sức khỏe. Bạn có thể ghim (pin), bỏ ghim, đặt food preferences để điều chỉnh gợi ý.',
    ),
    _FaqItem(
      'Cách cập nhật mục tiêu hàng ngày?',
      'Tại Tài khoản > Hồ sơ, chỉnh chiều cao, cân nặng, giới tính, độ tuổi, mức vận động. Hệ thống tính BMR/TDEE, đặt mục tiêu năng lượng, protein, fat, carb, nước và đồng bộ về màn Trang chủ/Thống kê.',
    ),
    _FaqItem(
      'Đặt mục tiêu cho từng bữa (meal targets)?',
      'Trong mục Meal Targets, chọn ngày và phân bổ kcal/carb/protein/fat cho breakfast/lunch/snack/dinner. Các màn thống kê sẽ hiển thị theo phân bổ này.',
    ),
    _FaqItem(
      'Theo dõi lượng nước uống như thế nào?',
      'Trong Trang chủ hoặc Thống kê, nhấn nút cộng ở widget Nước để ghi ml (có thể chọn đồ uống khác). Dữ liệu reset tự động mỗi 00:00 (UTC+7) khi mở lại app.',
    ),
    _FaqItem(
      'Tạo đồ uống tùy chỉnh?',
      'Ở mục Nước, chọn “custom drink” để thêm đồ uống của bạn (ml, tên, tỉ lệ hydration). Có thể xem chi tiết và xóa đồ uống tùy chỉnh.',
    ),
    _FaqItem(
      'Tôi quên mật khẩu thì sao?',
      'Liên hệ quản trị hoặc sử dụng email đăng ký để khôi phục khi tính năng được bật.',
    ),
    _FaqItem(
      'Tài khoản bị chặn phải làm gì?',
      'Tại màn hình đăng nhập, ứng dụng sẽ hiển thị lý do và cho phép gửi yêu cầu gỡ chặn tới quản trị.',
    ),
    _FaqItem(
      'AI phân tích hình ảnh hoạt động ra sao?',
      'Vào Phân tích hình ảnh AI, chọn Chụp ảnh/Thư viện, gửi ảnh món ăn. Hệ thống (Gemini Vision) nhận diện món, ước tính calo, nước, macros và thêm vào “AI Analyzed Meals”. Bạn có thể chấp nhận hoặc từ chối từng kết quả.',
    ),
    _FaqItem(
      'Gợi ý món ăn thông minh lấy ở đâu?',
      'Backend dùng hồ sơ sức khỏe, lịch sử ăn, mục tiêu, điều kiện bệnh và tương tác thuốc-thực phẩm để gợi ý. Các thẻ gợi ý xuất hiện trong Trang chủ/Thống kê; bạn có thể xem chi tiết hoặc bỏ qua.',
    ),
    _FaqItem(
      'Nhắc thuốc và điều kiện sức khỏe hiển thị thế nào?',
      'Ở tab Sức khỏe, ứng dụng đồng bộ các điều kiện đang điều trị, thời gian dùng thuốc và cảnh báo tương tác dinh dưỡng/thuốc. Khi điều trị kết thúc (hoặc trạng thái completed) thẻ bệnh sẽ ẩn và hiển thị “Bạn đang rất khỏe mạnh”.',
    ),
    _FaqItem(
      'Theo dõi thuốc và cảnh báo tương tác?',
      'Mục Thuốc/Health điều kiện: log thuốc (medication log), xem lịch uống, cảnh báo tương tác với dưỡng chất hoặc thực phẩm, và theo dõi tình trạng điều trị.',
    ),
    _FaqItem(
      'Chat và tag @ hoạt động như thế nào?',
      'Trong Chat, gõ @ để chọn món/đồ uống/điều kiện sức khỏe và chèn tag @[type:id:name]. Tag hiển thị nền đậm, bấm để mở chi tiết. Bot trả lời sẽ kèm phân tích dinh dưỡng hoặc gợi ý.',
    ),
    _FaqItem(
      'Trao đổi với cộng đồng hoặc admin?',
      'Có hai luồng: Chatbot (AI dinh dưỡng) và Admin chat (hỗ trợ). Ngoài ra có Social community feed để xem/gửi thông điệp cộng đồng nếu được bật.',
    ),
    _FaqItem(
      'Thông báo và cảnh báo được gửi khi nào?',
      'Bạn sẽ nhận thông báo khi có gợi ý mới, cảnh báo dinh dưỡng/thuốc, nhắc nước, nhắc bữa, hoặc kết quả AI. Có thể đánh dấu đã đọc/đọc tất cả.',
    ),
  ];

  late final AnimationController _introController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeIn = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
          ),
        );
    // start after build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _introController.forward();
    });
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
          appBar: AppBar(
            title: Row(
              children: const [
                Hero(
                  tag: 'heroHelp',
                  child: Icon(Icons.help_outline, size: 24),
                ),
                SizedBox(width: 8),
                Text('Trợ giúp'),
              ],
            ),
          ),
          body: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [_heroCard(), const SizedBox(height: 16), _faqList()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha((0.08 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.help_outline, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Câu hỏi thường gặp',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nhấn vào từng mục để xem câu trả lời',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqList() {
    return Container(
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionPanelList.radio(
            expandedHeaderPadding: EdgeInsets.zero,
            animationDuration: const Duration(milliseconds: 300),
            children: _faqs
                .map(
                  (f) => ExpansionPanelRadio(
                    value: f.title,
                    headerBuilder: (_, isOpen) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        f.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    body: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        f.content,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }
}

class _FaqItem {
  final String title;
  final String content;
  _FaqItem(this.title, this.content);
}
