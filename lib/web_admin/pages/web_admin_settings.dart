import 'package:flutter/material.dart';

class WebAdminSettings extends StatefulWidget {
  const WebAdminSettings({super.key});

  @override
  State<WebAdminSettings> createState() => _WebAdminSettingsState();
}

class _WebAdminSettingsState extends State<WebAdminSettings> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoRefresh = true;
  int _refreshInterval = 30;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt hệ thống',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // General Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Cài đặt chung',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Chế độ tối'),
                      subtitle: const Text('Bật/tắt giao diện tối'),
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() => _darkMode = value);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Thông báo'),
                      subtitle: const Text('Nhận thông báo khi có sự kiện mới'),
                      value: _notifications,
                      onChanged: (value) {
                        setState(() => _notifications = value);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Tự động làm mới'),
                      subtitle: const Text('Tự động tải lại dữ liệu định kỳ'),
                      value: _autoRefresh,
                      onChanged: (value) {
                        setState(() => _autoRefresh = value);
                      },
                    ),
                    if (_autoRefresh) ...[
                      const SizedBox(height: 8),
                      ListTile(
                        title: const Text('Khoảng thời gian làm mới (giây)'),
                        subtitle: Slider(
                          value: _refreshInterval.toDouble(),
                          min: 10,
                          max: 300,
                          divisions: 29,
                          label: '$_refreshInterval giây',
                          onChanged: (value) {
                            setState(() => _refreshInterval = value.toInt());
                          },
                        ),
                        trailing: Text('$_refreshInterval'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Display Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.display_settings, color: Colors.purple),
                        const SizedBox(width: 8),
                        const Text(
                          'Hiển thị',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Số mục trên trang'),
                      subtitle: const Text('Số lượng mục hiển thị trong bảng'),
                      trailing: DropdownButton<int>(
                        value: 20,
                        items: [10, 20, 50, 100].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã lưu cài đặt')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lưu cài đặt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
