// ignore_for_file: use_super_parameters, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'admin_user_activity_screen.dart';
import '../config/api_config.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> users = [];
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  // Notifications via SSE
  StreamSubscription<String>? _sseSub;
  int _notifCount = 0;
  final List<Map<String, dynamic>> _events = [];
  int _prevNotifCount = 0;
  late AnimationController _bellController;
  late Animation<double> _bellScale;
  // highlight slide/overlay when block/unblock
  final Set<int> _highlightUsers = {};
  final Map<int, bool> _highlightBlocked = {}; // true=blocked, false=unblocked
  int _newRegCount = 0;
  Timer? _newRegTimer;
  bool _hasUnblockBadge = false; // chấm đỏ khi có yêu cầu gỡ chặn mới

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _startSse();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bellScale = Tween(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bellController, curve: Curves.easeInOut),
    );
  }

  Future<String?> _getToken() async => AuthService.getToken();

  Future<void> _startSse() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final client = http.Client();
      final request = http.Request(
        'GET',
        Uri.parse('${ApiConfig.baseUrl}/admin/events'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      final response = await client.send(request);
      // SSE listener is defined below (single listener with simple parser)

      // Lightweight parser variables
      String? pendingEvent;
      _sseSub = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.startsWith('event:')) {
                pendingEvent = line.substring(6).trim();
              } else if (line.startsWith('data:')) {
                final dataStr = line.substring(5).trim();
                if (pendingEvent != null) {
                  try {
                    final payload = json.decode(dataStr);
                    setState(() {
                      _events.add({
                        'type': pendingEvent,
                        'data': payload,
                        'at': DateTime.now().toIso8601String(),
                      });
                      _prevNotifCount = _notifCount;
                      _notifCount = (_notifCount + 1).clamp(0, 999);
                    });
                    if (_notifCount > _prevNotifCount) {
                      _bellController.forward(from: 0);
                      Future.delayed(const Duration(milliseconds: 1400), () {
                        if (mounted) _bellController.stop();
                      });
                    }
                    // compact snackbar for new registrations
                    if (pendingEvent == 'user_registered' && mounted) {
                      _newRegCount += 1;
                      _newRegTimer?.cancel();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Có $_newRegCount đăng ký mới'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      _newRegTimer = Timer(const Duration(seconds: 2), () {
                        _newRegCount = 0;
                      });
                    } else if (pendingEvent == 'unblock_request') {
                      // show red dot on bell
                      if (mounted) {
                        setState(() {
                          _hasUnblockBadge = true;
                        });
                      }
                    }
                  } catch (_) {}
                }
              }
            },
            onDone: () {
              Future.delayed(const Duration(seconds: 3), _startSse);
            },
            onError: (e) {
              Future.delayed(const Duration(seconds: 5), _startSse);
            },
          );
    } catch (_) {}
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    _bellController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({int page = 1, String search = ''}) async {
    setState(() => isLoading = true);

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/users?page=$page&limit=20&search=$search',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data['users'];
          currentPage = data['pagination']['page'];
          totalPages = data['pagination']['totalPages'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tải danh sách người dùng')),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('L?i: $e')));
      }
    }
  }

  Future<void> _blockUser(int userId) async {
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chặn người dùng'),
        content: TextField(
          controller: reasonCtrl,
          decoration:
              const InputDecoration(labelText: 'Lý do chặn (tùy chọn)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('H?y'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ch?n'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final token = await _getToken();
      final resp = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId/block'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'reason': reasonCtrl.text}),
      );
      if (!mounted) return;
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã chặn người dùng')));
        // trigger highlight animation
        setState(() {
          _highlightUsers.add(userId);
          _highlightBlocked[userId] = true;
        });
        Timer(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(() {
            _highlightUsers.remove(userId);
            _highlightBlocked.remove(userId);
          });
        });
        _loadUsers(page: currentPage, search: searchQuery);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ch?n th?t b?i')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('L?i: $e')));
      }
    }
  }

  Future<void> _unblockUser(int userId) async {
    try {
      final token = await _getToken();
      final resp = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId/unblock'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'admin_response': 'manual unblocked'}),
      );
      if (!mounted) return;
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã gỡ chặn')));
        // trigger highlight animation
        setState(() {
          _highlightUsers.add(userId);
          _highlightBlocked[userId] = false;
        });
        Timer(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(() {
            _highlightUsers.remove(userId);
            _highlightBlocked.remove(userId);
          });
        });
        _loadUsers(page: currentPage, search: searchQuery);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('G? ch?n th?t b?i')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('L?i: $e')));
      }
    }
  }

  Future<void> _openUnblockRequests() async {
    try {
      final token = await _getToken();
      final resp = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/unblock-requests'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (!mounted) return;
        // clear badge after viewing
        setState(() => _hasUnblockBadge = false);
        await showDialog(
          context: context,
          builder: (_) => _UnblockRequestsDialog(
            requests: List<Map<String, dynamic>>.from(data['requests'] ?? []),
            onDecision: (userId, approved) {
              if (!approved) return;
              // backend already unblocked on approve; reflect UI immediately
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã chấp nhận và gỡ chặn người dùng'),
                ),
              );
              setState(() {
                _highlightUsers.add(userId);
                _highlightBlocked[userId] = false;
              });
              Timer(const Duration(milliseconds: 1200), () {
                if (!mounted) return;
                setState(() {
                  _highlightUsers.remove(userId);
                  _highlightBlocked.remove(userId);
                });
              });
              _loadUsers(page: currentPage, search: searchQuery);
            },
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tải yêu cầu gỡ chặn')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('L?i: $e')));
      }
    }
  }

  String _fmt(String? iso) {
    if (iso == null || iso.isEmpty) return 'Chua dang nh?p';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('HH:mm dd/MM').format(dt);
    } catch (_) {
      return iso;
    }
  }

  String? _resolveAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${ApiConfig.baseUrl}$url';
  }

  Widget _buildUserAvatar(Map<String, dynamic> user) {
    final avatarUrl = _resolveAvatarUrl(user['avatar_url']?.toString());
    final fullName = user['full_name']?.toString() ?? 'U';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
    
    return CircleAvatar(
      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
          ? NetworkImage(avatarUrl)
          : null,
      backgroundColor: avatarUrl == null || avatarUrl.isEmpty
          ? Colors.blue.shade100
          : null,
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Text(
              initial,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            )
          : null,
    );
  }

  // Delete user feature removed per request.
  Future<void> _showUserDetails(int userId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => _UserDetailsDialog(userDetails: data),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('L?i: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Thông báo',
                onPressed: _openUnblockRequests,
              ),
              if (_hasUnblockBadge)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (_notifCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: ScaleTransition(
                    scale: _bellScale,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          _notifCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    searchQuery = '';
                    _loadUsers();
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (value) {
                searchQuery = value;
                _loadUsers(search: value);
              },
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: users.isEmpty
                      ? const Center(child: Text('Không có người dùng nào'))
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final isBlocked =
                                (user['is_blocked'] ?? false) == true;
                            final uid = user['user_id'] as int;
                            final isHighlight = _highlightUsers.contains(uid);
                            final wasBlocked = _highlightBlocked[uid] ?? false;
                            final beginDx = isHighlight
                                ? (wasBlocked ? -12.0 : 12.0)
                                : 0.0;

                            return TweenAnimationBuilder<double>(
                              key: ValueKey(
                                'u_${uid}_${isHighlight}_$isBlocked',
                              ),
                              tween: Tween(begin: beginDx, end: 0.0),
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              builder: (context, dx, child) {
                                return Transform.translate(
                                  offset: Offset(dx, 0),
                                  child: Stack(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isBlocked
                                              ? Colors.red.withValues(
                                                  alpha: 0.04,
                                                )
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.04,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: child,
                                      ),
                                      // overlay highlight to emphasize change
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          ignoring: true,
                                          child: AnimatedOpacity(
                                            opacity: isHighlight ? 0.35 : 0.0,
                                            duration: const Duration(
                                              milliseconds: 500,
                                            ),
                                            curve: Curves.easeOut,
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: wasBlocked
                                                    ? Colors.redAccent
                                                    : Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: _buildUserAvatar(user),
                                title: Text(user['full_name'] ?? 'N/A'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['email'] ?? '',
                                      style: const TextStyle(fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${user['age'] ?? 'N/A'} tuổi · ${user['gender'] ?? 'N/A'} · Lần cuối: ${_fmt(user['last_login']?.toString())}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isBlocked)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.block,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Đã bị chặn',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.info_outline),
                                      onPressed: () =>
                                          _showUserDetails(user['user_id']),
                                      tooltip: 'Chi ti?t',
                                    ),
                                    if (!isBlocked)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.block,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Ch?n',
                                        onPressed: () =>
                                            _blockUser(user['user_id']),
                                      )
                                    else
                                      IconButton(
                                        icon: const Icon(
                                          Icons.lock_open,
                                          color: Colors.green,
                                        ),
                                        tooltip: 'G? ch?n',
                                        onPressed: () =>
                                            _unblockUser(user['user_id']),
                                      ),
                                    // Removed delete user action per request
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: currentPage > 1
                              ? () => _loadUsers(
                                  page: currentPage - 1,
                                  search: searchQuery,
                                )
                              : null,
                        ),
                        Text('Trang $currentPage / $totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: currentPage < totalPages
                              ? () => _loadUsers(
                                  page: currentPage + 1,
                                  search: searchQuery,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _UserDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> userDetails;

  const _UserDetailsDialog({required this.userDetails});

  @override
  Widget build(BuildContext context) {
    final user = userDetails['user'];
    final recentMeals = userDetails['recentMeals'] ?? [];

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Column(
          children: [
            AppBar(
              title: Text(user['full_name'] ?? 'Chi tiết người dùng'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Thông tin cá nhân', [
                      _buildInfoRow('Email', user['email']),
                      _buildInfoRow('Tu?i', '${user['age'] ?? 'N/A'}'),
                      _buildInfoRow('Giới tính', user['gender'] ?? 'N/A'),
                      _buildInfoRow(
                        'Chi?u cao',
                        '${user['height_cm'] ?? 'N/A'} cm',
                      ),
                      _buildInfoRow(
                        'Cân nặng',
                        '${user['weight_kg'] ?? 'N/A'} kg',
                      ),
                    ]),
                    const Divider(height: 32),
                    _buildSection('Mục tiêu', [
                      _buildInfoRow('Lo?i ch? d?', user['diet_type'] ?? 'N/A'),
                      _buildInfoRow('Mục tiêu', user['goal_type'] ?? 'N/A'),
                      _buildInfoRow(
                        'Calo mục tiêu',
                        '${user['daily_calorie_target'] ?? 'N/A'} kcal',
                      ),
                    ]),
                    const Divider(height: 32),
                    Text(
                      'Bữa ăn gần đây',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...recentMeals.map(
                      (meal) {
                        final calories = meal['total_calories'];
                        final caloriesValue = calories is num 
                            ? calories.toDouble() 
                            : (calories != null ? double.tryParse(calories.toString()) ?? 0.0 : 0.0);
                        return ListTile(
                          dense: true,
                          title: Text(meal['meal_type'] ?? ''),
                          subtitle: Text(meal['meal_date']?.toString() ?? ''),
                          trailing: Text('${caloriesValue.toStringAsFixed(0)} kcal'),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Analytics Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close details dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminUserActivityScreen(
                                userId: user['user_id'] is int
                                    ? user['user_id']
                                    : int.parse(user['user_id'].toString()),
                                userName: user['full_name'] ?? 'User',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.analytics),
                        label: const Text('Xem Analytics & Hoạt động'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text('$label:')),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnblockRequestsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> requests;
  final void Function(int userId, bool approved)? onDecision;
  const _UnblockRequestsDialog({required this.requests, this.onDecision});

  @override
  State<_UnblockRequestsDialog> createState() => _UnblockRequestsDialogState();
}

class _UnblockRequestsDialogState extends State<_UnblockRequestsDialog> {
  Future<String?> _getToken() async => AuthService.getToken();

  Future<void> _decide(int requestId, String decision) async {
    try {
      final token = await _getToken();
      final resp = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/unblock-requests/$requestId/decision',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'decision': decision, 'admin_response': decision}),
      );
      if (resp.statusCode == 200) {
        setState(() {
          final idx = widget.requests.indexWhere(
            (e) => e['request_id'] == requestId,
          );
          if (idx >= 0) {
            widget.requests[idx]['status'] = decision == 'approve'
                ? 'approved'
                : 'rejected';
          }
        });
        // Notify parent on approval so it can refresh users list and highlight
        if (decision == 'approve') {
          final idx = widget.requests.indexWhere(
            (e) => e['request_id'] == requestId,
          );
          if (idx >= 0) {
            final userId = widget.requests[idx]['user_id'];
            if (userId is int) {
              widget.onDecision?.call(userId, true);
            } else if (userId is num) {
              widget.onDecision?.call(userId.toInt(), true);
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Xử lý thất bại')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('L?i: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            AppBar(
              title: const Text('Yêu cầu gỡ chặn'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: widget.requests.isEmpty
                  ? const Center(child: Text('Không có yêu cầu nào'))
                  : ListView.separated(
                      itemCount: widget.requests.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final r = widget.requests[i];
                        return ListTile(
                          leading: CircleAvatar(child: Text('${r['user_id']}')),
                          title: Text(
                            r['full_name'] ?? 'user #${r['user_id']}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['email'] ?? ''),
                              if (r['message'] != null)
                                Text('L?i nh?n: ${r['message']}'),
                              Text('Trạng thái: ${r['status']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                tooltip: 'Ch?p nh?n',
                                onPressed: r['status'] == 'pending'
                                    ? () => _decide(r['request_id'], 'approve')
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                tooltip: 'T? ch?i',
                                onPressed: r['status'] == 'pending'
                                    ? () => _decide(r['request_id'], 'reject')
                                    : null,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

