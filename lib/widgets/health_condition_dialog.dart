import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../config/api_config.dart';
import '../services/local_notification_service.dart';

class HealthConditionDialog extends StatefulWidget {
  final Function() onConditionAdded;

  const HealthConditionDialog({Key? key, required this.onConditionAdded})
    : super(key: key);

  @override
  _HealthConditionDialogState createState() => _HealthConditionDialogState();
}

class _HealthConditionDialogState extends State<HealthConditionDialog> {
  List<dynamic> _conditions = [];
  List<dynamic> _filteredConditions = [];
  List<dynamic> _userConditions = []; // Danh sách bệnh user đang mắc
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConditions();
    _loadUserConditions(); // Load bệnh user đã có
  }

  Future<void> _loadConditions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health/conditions'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend trả về {success: true, conditions: [...]}
        final conditions = data['conditions'] ?? data;
        final conditionsList = (conditions is List) ? conditions : [];

        setState(() {
          _conditions = conditionsList;
          _filteredConditions = conditionsList;
          _isLoading = false;
        });
      } else {
        debugPrint(
          'Failed to load conditions: ${response.statusCode} ${response.body}',
        );
        throw Exception('Failed to load conditions');
      }
    } catch (e) {
      debugPrint('Error loading conditions: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.errorLoadingDiseaseList(e.toString()));
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadUserConditions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health/user/conditions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userConditions = data['conditions'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading user conditions: $e');
    }
  }

  void _filterConditions(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredConditions = _conditions;
      } else {
        _filteredConditions = _conditions.where((condition) {
          final nameVi = condition['name_vi'].toString().toLowerCase();
          final category =
              condition['category']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return nameVi.contains(searchLower) || category.contains(searchLower);
        }).toList();
      }
    });
  }

  void _showConditionDetail(dynamic condition) {
    // Kiểm tra xem user đã mắc bệnh này chưa
    final bool alreadyHas = _userConditions.any(
      (uc) => uc['condition_id'] == condition['condition_id'],
    );

    if (alreadyHas) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.alreadyHaveDisease(condition['name_vi']));
            },
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ConditionDetailDialog(
        condition: condition,
        onConditionAdded: widget.onConditionAdded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      return const Text(
                        'Chọn bệnh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchDisease,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterConditions,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredConditions.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? AppLocalizations.of(context)!.noData
                            : AppLocalizations.of(context)!.noResults,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredConditions.length,
                      itemBuilder: (context, index) {
                        final condition = _filteredConditions[index];
                        final bool alreadyHas = _userConditions.any(
                          (uc) =>
                              uc['condition_id'] == condition['condition_id'],
                        );

                        return Opacity(
                          opacity: alreadyHas ? 0.45 : 1.0,
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getCategoryColor(
                                  condition['category'],
                                ),
                                child: const Icon(
                                  Icons.medical_services,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                condition['name_vi'] ??
                                    condition['condition_name'] ??
                                    'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    condition['category'] ?? '',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  if (condition['description'] != null)
                                    Text(
                                      condition['description'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  if (alreadyHas)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Builder(
                                        builder: (context) {
                                          final l10n = AppLocalizations.of(
                                            context,
                                          )!;
                                          return Text(
                                            l10n.currentlyHaveThisCondition,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.orange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () => _showConditionDetail(condition),
                            ),
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

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Tim mạch':
        return Colors.red;
      case 'Chuyển hóa':
        return Colors.orange;
      case 'Gan':
        return Colors.brown;
      case 'Tiêu hóa':
        return Colors.green;
      case 'Huyết học':
        return Colors.purple;
      case 'Dinh dưỡng':
        return Colors.blue;
      case 'Miễn dịch':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ConditionDetailDialog extends StatefulWidget {
  final dynamic condition;
  final Function() onConditionAdded;

  const _ConditionDetailDialog({
    required this.condition,
    required this.onConditionAdded,
  });

  @override
  _ConditionDetailDialogState createState() => _ConditionDetailDialogState();
}

class _ConditionDetailDialogState extends State<_ConditionDetailDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  // 3 medication schedules
  TimeOfDay? _morningTime;
  final TextEditingController _morningNotesController = TextEditingController();

  TimeOfDay? _afternoonTime;
  final TextEditingController _afternoonNotesController =
      TextEditingController();

  TimeOfDay? _eveningTime;
  final TextEditingController _eveningNotesController = TextEditingController();

  bool _isSaving = false;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, String period) async {
    TimeOfDay initialTime;
    if (period == 'morning') {
      initialTime = _morningTime ?? const TimeOfDay(hour: 7, minute: 0);
    } else if (period == 'afternoon') {
      initialTime = _afternoonTime ?? const TimeOfDay(hour: 12, minute: 0);
    } else {
      initialTime = _eveningTime ?? const TimeOfDay(hour: 19, minute: 0);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (period == 'morning') {
          _morningTime = picked;
        } else if (period == 'afternoon') {
          _afternoonTime = picked;
        } else {
          _eveningTime = picked;
        }
      });
    }
  }

  Future<void> _saveCondition() async {
    final l10n = AppLocalizations.of(context)!;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.pleaseSelectStartDate);
            },
          ),
        ),
      );
      return;
    }

    // Check if at least one medication time is set
    if (_morningTime == null &&
        _afternoonTime == null &&
        _eveningTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.pleaseSelectAtLeastOneMedicationTime);
            },
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        throw Exception(l10n.notLoggedInNoToken);
      }

      // Build medication times array with period info
      List<String> medicationTimesArray = [];
      Map<String, dynamic> medicationDetails = {};

      if (_morningTime != null) {
        final timeStr =
            '${_morningTime!.hour.toString().padLeft(2, '0')}:${_morningTime!.minute.toString().padLeft(2, '0')}';
        medicationTimesArray.add(timeStr);
        medicationDetails[timeStr] = {
          'period': 'morning',
          'notes': _morningNotesController.text.trim(),
        };
      }

      if (_afternoonTime != null) {
        final timeStr =
            '${_afternoonTime!.hour.toString().padLeft(2, '0')}:${_afternoonTime!.minute.toString().padLeft(2, '0')}';
        medicationTimesArray.add(timeStr);
        medicationDetails[timeStr] = {
          'period': 'afternoon',
          'notes': _afternoonNotesController.text.trim(),
        };
      }

      if (_eveningTime != null) {
        final timeStr =
            '${_eveningTime!.hour.toString().padLeft(2, '0')}:${_eveningTime!.minute.toString().padLeft(2, '0')}';
        medicationTimesArray.add(timeStr);
        medicationDetails[timeStr] = {
          'period': 'evening',
          'notes': _eveningNotesController.text.trim(),
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/health/user/conditions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'condition_id': widget.condition['condition_id'],
          'treatment_start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
          'treatment_end_date': _endDate != null
              ? DateFormat('yyyy-MM-dd').format(_endDate!)
              : null,
          'medication_times': medicationTimesArray,
          'medication_details': medicationDetails,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        // Update medication notifications
        try {
          final responseData = json.decode(response.body);
          final userConditionId = responseData['user_condition_id'] as int?;
          final conditionName =
              widget.condition['name_vi']?.toString() ??
              widget.condition['name']?.toString() ??
              'Bệnh';

          // Build medications list for notification scheduling
          final medications = <Map<String, dynamic>>[];
          if (medicationTimesArray.isNotEmpty) {
            medications.add({
              'medication_id': userConditionId ?? 0,
              'medication_name': conditionName,
              'medication_times': medicationTimesArray,
              'period': 'Buổi sáng', // Default, will be updated per time
            });

            // Schedule notifications for each medication time
            for (var timeStr in medicationTimesArray) {
              final periodInfo =
                  medicationDetails[timeStr] as Map<String, dynamic>?;
              final period = periodInfo?['period']?.toString() ?? 'morning';
              final periodNames = {
                'morning': 'Buổi sáng',
                'afternoon': 'Buổi trưa',
                'evening': 'Buổi tối',
              };
              final periodName = periodNames[period] ?? 'Buổi sáng';

              final parts = timeStr.split(':');
              if (parts.length >= 2) {
                final hour = int.tryParse(parts[0]);
                final minute = int.tryParse(parts[1]);
                if (hour != null && minute != null) {
                  await LocalNotificationService()
                      .scheduleMedicationNotification(
                        medicationId: userConditionId ?? 0,
                        time: TimeOfDay(hour: hour, minute: minute),
                        medicationName: conditionName,
                        period: periodName,
                      );
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error scheduling medication notifications: $e');
        }

        if (!mounted) return;

        Navigator.pop(context); // Close detail dialog
        Navigator.pop(context); // Close main dialog
        widget.onConditionAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.diseaseAdded(widget.condition['name_vi']));
              },
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['error'] ??
            AppLocalizations.of(context)!.cannotAddDisease;
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final condition = widget.condition;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      condition['name_vi'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  condition['category'] ?? '',
                  style: TextStyle(color: Colors.blue[900], fontSize: 12),
                ),
              ),
              if (condition['description'] != null) ...[
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      l10n.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(condition['description']),
              ],
              if (condition['causes'] != null) ...[
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      l10n.causes,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(condition['causes']),
              ],
              const Divider(height: 32),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(
                    l10n.treatmentInfo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.treatmentStartDate,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        _startDate != null
                            ? dateFormat.format(_startDate!)
                            : l10n.selectDate,
                        style: TextStyle(
                          color: _startDate != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.treatmentEndDateOptional,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        _endDate != null
                            ? dateFormat.format(_endDate!)
                            : l10n.selectDate,
                        style: TextStyle(
                          color: _endDate != null ? Colors.black : Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 24),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(
                    l10n.medicationSchedule,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Morning Schedule
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Column(
                    children: [
                      _buildMedicationTimeCard(
                        l10n.morning,
                        Icons.wb_sunny,
                        Colors.orange,
                        _morningTime,
                        _morningNotesController,
                        () => _selectTime(context, 'morning'),
                      ),
                      const SizedBox(height: 12),
                      // Afternoon Schedule
                      _buildMedicationTimeCard(
                        l10n.afternoon,
                        Icons.light_mode,
                        Colors.amber,
                        _afternoonTime,
                        _afternoonNotesController,
                        () => _selectTime(context, 'afternoon'),
                      ),
                      const SizedBox(height: 12),
                      // Evening Schedule
                      _buildMedicationTimeCard(
                        l10n.evening,
                        Icons.nightlight_round,
                        Colors.indigo,
                        _eveningTime,
                        _eveningNotesController,
                        () => _selectTime(context, 'evening'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCondition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(
                              l10n.confirmAdd,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationTimeCard(
    String label,
    IconData icon,
    Color color,
    TimeOfDay? time,
    TextEditingController notesController,
    VoidCallback onSelectTime,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onSelectTime,
                  icon: Icon(Icons.access_time, size: 16, color: color),
                  label: Text(
                    time != null
                        ? time.format(context)
                        : AppLocalizations.of(context)!.selectTime,
                    style: TextStyle(color: color),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color),
                  ),
                ),
              ],
            ),
            if (time != null) ...[
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.notes,
                  hintText: 'VD: Uống sau bữa ăn',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: const Icon(Icons.notes, size: 20),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _morningNotesController.dispose();
    _afternoonNotesController.dispose();
    _eveningNotesController.dispose();
    super.dispose();
  }
}
