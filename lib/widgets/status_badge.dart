import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final bool isOnline;

  const StatusBadge({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? const Color(0xFF111111) : const Color(0xFFE51C23), 
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isOnline ? 'ONLINE' : 'OFFLINE',
          style: TextStyle(
            fontFamily: 'Helvetica Neue',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: isOnline ? const Color(0xFF111111) : const Color(0xFFE51C23),
          ),
        ),
      ],
    );
  }
}
