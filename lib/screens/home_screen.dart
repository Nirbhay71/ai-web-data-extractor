import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/csv_export_service.dart';
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
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
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
      setState(() => _errorMessage = 'PLEASE FILL IN URL AND QUERY.');
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
        _errorMessage = e.toString().replaceFirst('Exception: ', '').toUpperCase();
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
    _showSnackbar('CSV COPIED', isSuccess: true);
  }

  void _copyAsJson() {
    final json = CsvExportService.toJson(_results);
    _showSnackbar('JSON COPIED', isSuccess: true);
    CsvExportService.copyToClipboard(_results);
  }

  void _showSnackbar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF111111),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        elevation: 0,
        margin: const EdgeInsets.all(24),
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
      backgroundColor: const Color(0xFFFFFFFF), 
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroSection(),
                        const SizedBox(height: 24),

                        ExtractionForm(
                          urlController: _urlController,
                          queryController: _queryController,
                          isLoading: _isLoading,
                          onExtract: _runExtraction,
                          onClear: _clearAll,
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 24),
                          _buildErrorCard(),
                        ],

                        if (_isLoading) ...[
                          const SizedBox(height: 24),
                          _buildLoading(),
                        ],

                        if (_results.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          const Divider(color: Color(0xFFE5E5E5), thickness: 2, height: 1),
                          const SizedBox(height: 24),
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
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1), 
        ),
      ),
      child: Row(
        children: [
          const Text(
            'DATAEXTRACTOR',
            style: TextStyle(
              fontFamily: 'Impact',
              fontSize: 24,
              fontWeight: FontWeight.w500, // Decreased from w900
              color: Color(0xFF111111),
              letterSpacing: 0.5, // Increased spacing for a thinner look
            ),
          ),
          const Spacer(),
          StatusBadge(isOnline: _backendOnline),
          const SizedBox(width: 16),
          InkWell(
            onTap: _checkBackend,
            borderRadius: BorderRadius.circular(0),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.sync, size: 20, color: Color(0xFF111111)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TURN THE WEB\nINTO DATA.',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 24),
        const Text(
          'Don\'t write scrapers. Type a sentence.\nPowered by Gemini 2.5 Flash API.',
          style: TextStyle(
            color: Color(0xFF757575), 
            fontSize: 20,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        border: Border.all(color: const Color(0xFFE51C23), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.warning_rounded, color: Color(0xFFE51C23), size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontFamily: 'Impact',
                color: Color(0xFFE51C23),
                fontSize: 18,
                letterSpacing: 1.0,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _errorMessage = null),
            icon: const Icon(Icons.close, size: 24, color: Color(0xFFE51C23)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF111111)),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'EXTRACTING',
            style: TextStyle(
              fontFamily: 'Impact',
              color: Color(0xFF111111),
              fontSize: 24,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'PLEASE WAIT WHILE WE PROCESS THE PAGE',
            style: TextStyle(color: Color(0xFF757575), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }
}
