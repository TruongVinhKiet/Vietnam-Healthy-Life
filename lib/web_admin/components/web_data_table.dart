import 'package:flutter/material.dart';

class WebDataTable<T> extends StatefulWidget {
  final List<DataColumn> columns;
  final List<T> rows;
  final DataTableRowBuilder<T> rowBuilder;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final Function(int)? onPageChanged;
  final String? searchHint;
  final Function(String)? onSearch;
  final List<Widget>? actions;
  final bool sortable;
  final Function(int, bool)? onSort;

  const WebDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowBuilder,
    this.isLoading = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.onPageChanged,
    this.searchHint,
    this.onSearch,
    this.actions,
    this.sortable = false,
    this.onSort,
  });

  @override
  State<WebDataTable<T>> createState() => _WebDataTableState<T>();
}

class _WebDataTableState<T> extends State<WebDataTable<T>> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Toolbar
          if (widget.searchHint != null || widget.actions != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  if (widget.searchHint != null) ...[
                    Flexible(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: widget.searchHint,
                            prefixIcon: const Icon(Icons.search, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                          ),
                          onSubmitted: widget.onSearch,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (widget.actions != null) ...widget.actions!,
                ],
              ),
            ),

          // Table
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : widget.rows.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Không có dữ liệu',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ClipRect(
                        child: ListView.builder(
                          itemCount: widget.rows.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Container(
                                color: Colors.grey.shade50,
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: widget.columns.map((col) {
                                    return Expanded(
                                      child: Text(
                                        (col.label as Text).data ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }
                            final row = widget.rowBuilder(
                                context, widget.rows[index - 1], index - 1);
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: row.cells.map((cell) {
                                  return Expanded(
                                    child: DefaultTextStyle(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                      child: cell.child,
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ),
          ),

          // Pagination
          if (widget.totalPages > 1)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.grey.shade50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${widget.totalItems} mục',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.chevron_left),
                        onPressed: widget.currentPage > 1
                            ? () => widget.onPageChanged
                                ?.call(widget.currentPage - 1)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${widget.currentPage}/${widget.totalPages}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.chevron_right),
                        onPressed: widget.currentPage < widget.totalPages
                            ? () => widget.onPageChanged
                                ?.call(widget.currentPage + 1)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

typedef DataTableRowBuilder<T> = DataRow Function(
  BuildContext context,
  T item,
  int index,
);
