import 'package:flutter/material.dart';

class ExtractionForm extends StatefulWidget {
  final TextEditingController urlController;
  final TextEditingController queryController;
  final bool isLoading;
  final VoidCallback onExtract;
  final VoidCallback onClear;

  const ExtractionForm({
    super.key,
    required this.urlController,
    required this.queryController,
    required this.isLoading,
    required this.onExtract,
    required this.onClear,
  });

  @override
  State<ExtractionForm> createState() => _ExtractionFormState();
}

class _ExtractionFormState extends State<ExtractionForm> {
  final List<String> _exampleQueries = [
    'Extract all product names and prices',
    'Get all article titles and publication dates',
    'List all job titles and company names',
    'Extract all links with their anchor text',
    'Get all headings and their descriptions',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E1E35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.05),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF6C63FF),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Configure Extraction',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // URL Field
          _buildLabel('Target URL', Icons.link_rounded),
          const SizedBox(height: 8),
          TextField(
            controller: widget.urlController,
            enabled: !widget.isLoading,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'https://example.com/page-to-scrape',
              prefixIcon: const Icon(
                Icons.language_rounded,
                color: Color(0xFF6060A0),
                size: 20,
              ),
              suffixIcon: widget.urlController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        widget.urlController.clear();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFF6060A0),
                        size: 18,
                      ),
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 20),

          // Query Field
          _buildLabel('Extraction Query', Icons.psychology_rounded),
          const SizedBox(height: 8),
          TextField(
            controller: widget.queryController,
            enabled: !widget.isLoading,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText:
                  'Describe what data to extract in plain English...\ne.g., "Extract all product names, prices, and ratings"',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 12),

          // Example chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _exampleQueries.map((q) {
              return InkWell(
                onTap: widget.isLoading
                    ? null
                    : () {
                        widget.queryController.text = q;
                        setState(() {});
                      },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    q,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9090C0),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _ExtractButton(
                  isLoading: widget.isLoading,
                  onPressed: widget.onExtract,
                ),
              ),
              const SizedBox(width: 12),
              _ClearButton(onPressed: widget.onClear),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8080A0),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ExtractButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _ExtractButton({required this.isLoading, required this.onPressed});

  @override
  State<_ExtractButton> createState() => _ExtractButtonState();
}

class _ExtractButtonState extends State<_ExtractButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          if (!widget.isLoading) widget.onPressed();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isLoading
                    ? [const Color(0xFF3A3A5A), const Color(0xFF2A2A4A)]
                    : _hovered
                        ? [
                            const Color(0xFF8878FF),
                            const Color(0xFF00EEFF),
                          ]
                        : [
                            const Color(0xFF6C63FF),
                            const Color(0xFF00D4FF),
                          ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF6C63FF)
                            .withOpacity(_hovered ? 0.5 : 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white54,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Extracting...',
                          style: TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Extract Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ClearButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A45)),
        ),
        child: const Icon(
          Icons.refresh_rounded,
          color: Color(0xFF6060A0),
          size: 20,
        ),
      ),
    );
  }
}
