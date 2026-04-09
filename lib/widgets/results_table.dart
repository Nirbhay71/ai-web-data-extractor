import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/csv_export_service.dart';

class ResultsTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final int totalCount;
  final VoidCallback onCsvExport;
  final VoidCallback onJsonExport;

  const ResultsTable({
    super.key,
    required this.data,
    required this.totalCount,
    required this.onCsvExport,
    required this.onJsonExport,
  });

  @override
  State<ResultsTable> createState() => _ResultsTableState();
}

class _ResultsTableState extends State<ResultsTable> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int _currentPage = 0;
  static const int _rowsPerPage = 15;

  List<String> get _columns => widget.data.isEmpty
      ? []
      : widget.data.first.keys.toList();

  List<Map<String, dynamic>> get _filteredData {
    if (_searchQuery.isEmpty) return widget.data;
    return widget.data.where((row) {
      return row.values.any(
        (v) => v.toString().toLowerCase().contains(_searchQuery.toLowerCase()),
      );
    }).toList();
  }

  List<Map<String, dynamic>> get _sortedData {
    final data = List<Map<String, dynamic>>.from(_filteredData);
    if (_sortColumnIndex != null) {
      final col = _columns[_sortColumnIndex!];
      data.sort((a, b) {
        final aVal = a[col]?.toString() ?? '';
        final bVal = b[col]?.toString() ?? '';
        final cmp = aVal.compareTo(bVal);
        return _sortAscending ? cmp : -cmp;
      });
    }
    return data;
  }

  List<Map<String, dynamic>> get _pageData {
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, _sortedData.length);
    return _sortedData.sublist(start, end);
  }

  int get _totalPages =>
      (_sortedData.length / _rowsPerPage).ceil().clamp(1, 99999);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildSearchAndControls(),
        const SizedBox(height: 12),
        _buildTable(),
        if (_totalPages > 1) ...[
          const SizedBox(height: 12),
          _buildPagination(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF00D4FF).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.table_chart_rounded,
            color: Color(0xFF00D4FF),
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Extracted Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              '${widget.totalCount} records • ${_columns.length} fields',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6060A0),
              ),
            ),
          ],
        ),
        const Spacer(),
        _ExportButton(
          icon: Icons.table_rows_rounded,
          label: 'CSV',
          color: const Color(0xFF2ECC71),
          onTap: widget.onCsvExport,
        ),
        const SizedBox(width: 8),
        _ExportButton(
          icon: Icons.data_object_rounded,
          label: 'JSON',
          color: const Color(0xFF00D4FF),
          onTap: widget.onJsonExport,
        ),
      ],
    );
  }

  Widget _buildSearchAndControls() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (v) => setState(() {
              _searchQuery = v;
              _currentPage = 0;
            }),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search results...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF6060A0),
                size: 18,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: const Color(0xFF0F0F1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1E1E35)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1E1E35)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildCopyRawButton(),
      ],
    );
  }

  Widget _buildCopyRawButton() {
    return InkWell(
      onTap: () async {
        final json = CsvExportService.toJson(widget.data);
        await Clipboard.setData(ClipboardData(text: json));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('JSON copied to clipboard'),
              backgroundColor: const Color(0xFF6C63FF),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E1E35)),
        ),
        child: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Color(0xFF6060A0), size: 16),
            SizedBox(width: 6),
            Text(
              'Copy JSON',
              style: TextStyle(color: Color(0xFF6060A0), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    if (_columns.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A1A30)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 48,
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              const Color(0xFF13132A),
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFF6C63FF).withOpacity(0.06);
                }
                return null;
              },
            ),
            columnSpacing: 24,
            headingRowHeight: 46,
            dataRowMinHeight: 42,
            dataRowMaxHeight: 56,
            dividerThickness: 0.5,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            border: TableBorder(
              horizontalInside: BorderSide(
                color: const Color(0xFF1A1A30),
                width: 0.5,
              ),
            ),
            columns: _columns.asMap().entries.map((entry) {
              final i = entry.key;
              final col = entry.value;
              return DataColumn(
                label: Text(
                  col.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8080A0),
                    letterSpacing: 0.8,
                  ),
                ),
                onSort: (colIdx, asc) {
                  setState(() {
                    _sortColumnIndex = colIdx;
                    _sortAscending = asc;
                  });
                },
              );
            }).toList(),
            rows: _pageData.asMap().entries.map((entry) {
              final rowMap = entry.value;
              return DataRow(
                cells: _columns.map((col) {
                  final val = rowMap[col]?.toString() ?? '—';
                  return DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: Tooltip(
                        message: val,
                        child: Text(
                          val,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFD0D0E8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: val));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied: ${val.length > 40 ? '${val.substring(0, 40)}...' : val}'),
                            backgroundColor: const Color(0xFF1E1E35),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Showing ${_currentPage * _rowsPerPage + 1}–${(_currentPage * _rowsPerPage + _pageData.length)} of ${_sortedData.length}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6060A0)),
        ),
        const SizedBox(width: 16),
        _PageButton(
          icon: Icons.chevron_left_rounded,
          enabled: _currentPage > 0,
          onTap: () => setState(() => _currentPage--),
        ),
        const SizedBox(width: 4),
        ...List.generate(_totalPages.clamp(0, 5), (i) {
          final page = i;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => setState(() => _currentPage = page),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _currentPage == page
                      ? const Color(0xFF6C63FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${page + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _currentPage == page
                          ? Colors.white
                          : const Color(0xFF6060A0),
                      fontWeight: _currentPage == page
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        _PageButton(
          icon: Icons.chevron_right_rounded,
          enabled: _currentPage < _totalPages - 1,
          onTap: () => setState(() => _currentPage++),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF1E1E35)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF8080A0) : const Color(0xFF2A2A45),
        ),
      ),
    );
  }
}

class _ExportButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withOpacity(0.15)
                : widget.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.color.withOpacity(_hovered ? 0.5 : 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: widget.color),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
