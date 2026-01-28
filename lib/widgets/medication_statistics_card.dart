import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class MedicationStatisticsCard extends StatefulWidget {
  const MedicationStatisticsCard({super.key});

  @override
  State<MedicationStatisticsCard> createState() =>
      _MedicationStatisticsCardState();
}

class _MedicationStatisticsCardState extends State<MedicationStatisticsCard> {
  bool _isLoading = true;
  Map<String, dynamic>? _statistics;
  String _selectedPeriod = '7'; // days

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Calculate start date based on selected period
      final endDate = DateTime.now();
      final startDate = endDate.subtract(
        Duration(days: int.parse(_selectedPeriod)),
      );

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/medications/statistics?start_date=${_formatDate(startDate)}&end_date=${_formatDate(endDate)}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _statistics = data['statistics'];
            _isLoading = false;
          });
        }
      } else {
        debugPrint('Failed to load statistics: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading medication statistics: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.medicationStats,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: [
                    DropdownMenuItem(value: '7', child: Text(l10n.days7)),
                    DropdownMenuItem(value: '14', child: Text(l10n.days14)),
                    DropdownMenuItem(value: '30', child: Text(l10n.days30)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPeriod = value);
                      _loadStatistics();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_statistics == null)
              Center(
                child: Text(
                  l10n.noData,
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: [
                  _buildStatRow(
                    l10n.totalDose,
                    _statistics!['total_doses']?.toString() ?? '0',
                    Icons.medication,
                    Colors.blue,
                  ),
                  const Divider(),
                  _buildStatRow(
                    l10n.taken,
                    _statistics!['taken_doses']?.toString() ?? '0',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  const Divider(),
                  _buildStatRow(
                    l10n.onTime,
                    _statistics!['on_time_doses']?.toString() ?? '0',
                    Icons.schedule,
                    Colors.teal,
                  ),
                  const Divider(),
                  _buildStatRow(
                    l10n.late,
                    _statistics!['late_doses']?.toString() ?? '0',
                    Icons.warning,
                    Colors.orange,
                  ),
                  const Divider(),
                  _buildStatRow(
                    l10n.missed,
                    _statistics!['missed_doses']?.toString() ?? '0',
                    Icons.cancel,
                    Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPercentageCard(
                        l10n.adherence,
                        _statistics!['adherence_rate']?.toString() ?? '0',
                        Colors.green,
                      ),
                      _buildPercentageCard(
                        l10n.onTimeShort,
                        _statistics!['on_time_rate']?.toString() ?? '0',
                        Colors.teal,
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageCard(String label, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
