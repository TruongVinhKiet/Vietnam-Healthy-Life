import 'package:flutter/material.dart';

class NutrientDetailShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final List<Widget> chips;
  final Widget? overview;
  final List<Map<String, dynamic>>
  foods; // expects name, amount or amount_per_100g, unit
  final List<dynamic>? contraindications; // strings or {condition_name}
  // Key information rows shown to the right of the image
  // Each item: { 'label': String, 'value': String }
  // Icons are inferred from label keywords to avoid breaking callers.
  final List<Map<String, String>> infoRows;
  // Optional actions for the AppBar (admin-only edit/delete)
  final List<Widget>? actions;

  const NutrientDetailShell({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.chips = const [],
    this.overview,
    this.foods = const [],
    this.contraindications,
    this.infoRows = const [],
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              background: _buildHeader(),
            ),
            actions: actions,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info header card similar to animal lookup page
                  _buildInfoHeader(context),
                  const SizedBox(height: 12),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    Text(subtitle!, style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                  ],
                  // Removed chip row to avoid duplicate information below the header
                  if (overview != null) ...[
                    const SizedBox(height: 16),
                    _section(
                      context,
                      title: 'Lợi ích',
                      icon: Icons.info_outline,
                      color: Colors.blue,
                      child: overview!,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _section(
                    context,
                    title: 'Thực phẩm chứa nhiều',
                    icon: Icons.restaurant_menu,
                    color: Colors.green,
                    child: foods.isEmpty
                        ? const Text('Không có dữ liệu thực phẩm')
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: foods.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 12),
                            itemBuilder: (context, index) {
                              final f = foods[index];
                              final rank = index + 1;
                              final name = (f['name'] ?? '').toString();
                              final unit = (f['unit'] ?? '').toString();
                              final amt = f['amount'] ?? f['amount_per_100g'];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _rankColor(rank),
                                  child: Text(
                                    '$rank',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(name),
                                trailing: Text(
                                  amt != null ? '$amt $unit' : unit,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (contraindications != null) ...[
                    const SizedBox(height: 12),
                    _section(
                      context,
                      title: 'Chống chỉ định',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.orange,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in contraindications!)
                            Chip(
                              label: Text(
                                c is Map && c['condition_name'] != null
                                    ? c['condition_name'].toString()
                                    : c.toString(),
                              ),
                              backgroundColor: Colors.orange.shade50,
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoHeader(BuildContext context) {
    final theme = Theme.of(context);
    final gallery = foods
        .map((f) => (f['image_url'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .take(4)
        .toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: LayoutBuilder(
        builder: (context, cc) {
          final isWide = cc.maxWidth >= 640;
          final imageWidget = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.white,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? FittedBox(
                        fit: BoxFit.contain,
                        child: Image.network(imageUrl!),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(
                            Icons.science,
                            size: 56,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
          );

          final infoTable = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  for (int i = 0; i < infoRows.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _inferIcon(infoRows[i]['label'] ?? ''),
                              size: 18,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${(infoRows[i]['label'] ?? '').toString()}: ${(infoRows[i]['value'] ?? '').toString()}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (gallery.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: gallery.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Image.network(gallery[i], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 220, child: imageWidget),
                const SizedBox(width: 12),
                Expanded(child: infoTable),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [imageWidget, const SizedBox(height: 12), infoTable],
          );
        },
      ),
    );
  }

  IconData _inferIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('nhóm') || l.contains('group')) {
      return Icons.category_outlined;
    }
    if (l.contains('đơn vị') || l.contains('unit')) {
      return Icons.straighten;
    }
    if (l.contains('mã') || l.contains('code')) {
      return Icons.qr_code_2_outlined;
    }
    if (l.contains('vitamin')) return Icons.local_hospital_outlined;
    if (l.contains('khoáng') || l.contains('mineral')) {
      return Icons.terrain_outlined;
    }
    return Icons.info_outline;
  }

  Widget _buildHeader() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl!, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black26],
              ),
            ),
          ),
        ],
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.science, size: 72, color: Colors.white),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }
}

