import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class EmptyChatWidget extends StatelessWidget {
  const EmptyChatWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Halo! Saya Sorgummi AI ✨',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textCharcoal,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ada yang ingin Anda tanyakan tentang sorgum?',
            style: TextStyle(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
