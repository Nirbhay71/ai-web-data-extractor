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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchAndControls(),
        const SizedBox(height: 32),
        _buildTable(),
        if (_totalPages > 1) ...[
          const SizedBox(height: 32),
          _buildPagination(),
        ],
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
            style: const TextStyle(color: Color(0xFF111111), fontSize: 16, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              hintText: 'SEARCH RESULTS',
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFF757575),
                size: 24,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 24),
            ),
          ),
        ),
        const SizedBox(width: 24),
        _ExportButton(
          label: 'COPY CSV',
          onTap: widget.onCsvExport,
        ),
        const SizedBox(width: 12),
        _ExportButton(
          label: 'COPY JSON',
          onTap: widget.onJsonExport,
        ),
      ],
    );
  }

  Widget _buildTable() {
    if (_columns.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 80,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: const Color(0xFFE5E5E5),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFFF5F5F5);
                }
                return const Color(0xFFFFFFFF);
              },
            ),
            columnSpacing: 40,
            headingRowHeight: 64,
            dataRowMinHeight: 64,
            dataRowMaxHeight: 80,
            dividerThickness: 1.0,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: _columns.asMap().entries.map((entry) {
              final i = entry.key;
              final col = entry.value;
              return DataColumn(
                label: Text(
                  col.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Impact',
                    fontSize: 20,
                    color: Color(0xFF111111),
                    letterSpacing: 1.0,
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
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Tooltip(
                        message: val,
                        child: Text(
                          val,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF111111),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: val));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'COPIED: ${val.length > 40 ? '${val.substring(0, 40)}...' : val}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            backgroundColor: const Color(0xFF111111),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
          'SHOWING ${_currentPage * _rowsPerPage + 1} TO ${(_currentPage * _rowsPerPage + _pageData.length)} OF ${_sortedData.length}',
          style: const TextStyle(
            fontSize: 14, 
            color: Color(0xFF757575), 
            fontWeight: FontWeight.w700, 
            letterSpacing: 1.5
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF111111),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _currentPage < _totalPages - 1 ? () => setState(() => _currentPage++) : null,
          icon: const Icon(Icons.arrow_forward),
          color: const Color(0xFF111111),
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ExportButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF111111),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        side: const BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Impact',
          fontSize: 16,
          letterSpacing: 1.0,
          color: Color(0xFF111111),
        ),
      ),
    );
  }
}
