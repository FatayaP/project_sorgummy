import 'package:flutter/material.dart';

class SorgumStatusBadge extends StatelessWidget {
  final String status;

  const SorgumStatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isActive = status.trim().toLowerCase() == 'active' || status.trim().toLowerCase() == 'aktif';
    
    final Color bgColor = isActive ? Colors.green.withOpacity(0.2) : const Color(0xFF9E9E9E).withOpacity(0.1);
    final Color textColor = isActive ? Colors.green[700]! : const Color(0xFF9E9E9E);
    final Color borderColor = isActive ? Colors.green.withOpacity(0.3) : const Color(0xFF9E9E9E).withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        status.trim(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
