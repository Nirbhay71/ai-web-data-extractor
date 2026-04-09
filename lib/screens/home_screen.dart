import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/csv_export_service.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/extraction_form.dart';
import '../widgets/results_table.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _urlController = TextEditingController();
  final _queryController = TextEditingController();

  bool _isLoading = false;
  bool _backendOnline = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _results = [];
  int _totalFound = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _checkBackend();
  }

  Future<void> _checkBackend() async {
    final online = await ApiService.isBackendReachable();
    if (mounted) setState(() => _backendOnline = online);
  }

  Future<void> _runExtraction() async {
    final url = _urlController.text.trim();
    final query = _queryController.text.trim();

    if (url.isEmpty || query.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both the URL and extraction query.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = [];
      _totalFound = 0;
    });

    try {
      final data = await ApiService.extractData(url: url, query: query);
      setState(() {
        _results = data;
        _totalFound = data.length;
        _isLoading = false;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _results = [];
      _totalFound = 0;
      _errorMessage = null;
      _urlController.clear();
      _queryController.clear();
    });
    _fadeController.reset();
  }

  void _copyAsCsv() {
    CsvExportService.copyToClipboard(_results);
    _showSnackbar('CSV copied to clipboard!', isSuccess: true);
  }

  void _copyAsJson() {
    final json = CsvExportService.toJson(_results);
    _showSnackbar('JSON copied to clipboard!', isSuccess: true);
    // Also copy
    CsvExportService.copyToClipboard(_results);
  }

  void _showSnackbar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: isSuccess
            ? const Color(0xFF2ECC71)
            : const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _queryController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSection(),
                        const SizedBox(height: 32),
                        ExtractionForm(
                          urlController: _urlController,
                          queryController: _queryController,
                          isLoading: _isLoading,
                          onExtract: _runExtraction,
                          onClear: _clearAll,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _buildErrorCard(),
                        ],
                        if (_results.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ResultsTable(
                              data: _results,
                              totalCount: _totalFound,
                              onCsvExport: _copyAsCsv,
                              onJsonExport: _copyAsJson,
                            ),
                          ),
                        ],
                        if (_isLoading) ...[
                          const SizedBox(height: 32),
                          _buildLoadingCard(),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A).withOpacity(0.8),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E1E35), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'AI Web Extractor',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          StatusBadge(isOnline: _backendOnline),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _checkBackend,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: const Color(0xFF6060A0),
            tooltip: 'Refresh backend status',
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
          ).createShader(bounds),
          child: const Text(
            'Extract Any Data\nFrom Any Website',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Powered by Google Gemini AI — just paste a URL, describe what you want, and get structured data instantly.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF8080A0),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _buildChip(Icons.flash_on_rounded, 'AI Powered'),
            _buildChip(Icons.table_chart_rounded, 'Structured Output'),
            _buildChip(Icons.download_rounded, 'CSV / JSON Export'),
            _buildChip(Icons.language_rounded, 'Any Website'),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB0B0C8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B2222)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Extraction Failed',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFD08080),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _errorMessage = null),
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF8B4444)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35)),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Extracting data...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scraping the page → Cleaning HTML → Analyzing with Gemini AI',
            style: TextStyle(color: Color(0xFF606080), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
