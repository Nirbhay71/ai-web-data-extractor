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
    'Extract product names and prices',
    'Get article titles and dates',
    'List all jobs and locations',
    'Extract links with anchor text',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('TARGET URL'),
        const SizedBox(height: 8),
        TextField(
          controller: widget.urlController,
          enabled: !widget.isLoading,
          style: const TextStyle(color: Color(0xFF111111), fontSize: 18, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'https://example.com/',
            suffixIcon: widget.urlController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      widget.urlController.clear();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: Color(0xFF111111),
                      size: 24,
                    ),
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: 24),

        _buildLabel('EXTRACTION QUERY'),
        const SizedBox(height: 8),
        TextField(
          controller: widget.queryController,
          enabled: !widget.isLoading,
          maxLines: 2,
          style: const TextStyle(color: Color(0xFF111111), fontSize: 18, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            hintText: 'Describe what to extract...',
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _exampleQueries.map((q) {
            return InkWell(
              onTap: widget.isLoading
                  ? null
                  : () {
                      widget.queryController.text = q;
                      setState(() {});
                    },
              borderRadius: BorderRadius.circular(0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  q.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: Color(0xFF757575),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: _ExtractButton(
                isLoading: widget.isLoading,
                onPressed: widget.onExtract,
              ),
            ),
            const SizedBox(width: 16),
            _ClearButton(onPressed: widget.onClear),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Impact',
        fontSize: 18,
        color: Color(0xFF111111), 
        letterSpacing: 1.0,
      ),
    );
  }
}

class _ExtractButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _ExtractButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isLoading ? const Color(0xFFE5E5E5) : const Color(0xFF111111),
        padding: const EdgeInsets.symmetric(vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40), // Classic Nike Pill
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF111111),
              ),
            )
          : const Text(
              'EXTRACT',
              style: TextStyle(
                fontFamily: 'Impact',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500, // Thinner weight
                letterSpacing: 3.0,
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
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF111111),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        side: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
      ),
      child: const Text(
        'RESET',
        style: TextStyle(
          fontFamily: 'Impact',
          fontSize: 20,
          letterSpacing: 2.0,
          color: Color(0xFF111111),
        ),
      ),
    );
  }
}
