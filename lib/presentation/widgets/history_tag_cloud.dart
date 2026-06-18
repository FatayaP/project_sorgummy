import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class InteractiveHistoryCanvasTagCloud extends StatelessWidget {
  final List<String> keywords;
  final ValueChanged<String> onTagTapped;
  final ValueChanged<String> onTagLongPressed;
  final ValueChanged<String> onTagDoubleTapped;

  const InteractiveHistoryCanvasTagCloud({
    Key? key,
    required this.keywords,
    required this.onTagTapped,
    required this.onTagLongPressed,
    required this.onTagDoubleTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'Belum ada riwayat pencarian',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.start,
        children: keywords.map((tag) {
          return InteractiveHistoryTag(
            text: tag,
            onTap: () => onTagTapped(tag),
            onLongPress: () => onTagLongPressed(tag),
            onDoubleTap: () => onTagDoubleTapped(tag),
          );
        }).toList(),
      ),
    );
  }
}

class InteractiveHistoryTag extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDoubleTap;

  const InteractiveHistoryTag({
    Key? key,
    required this.text,
    required this.onTap,
    required this.onLongPress,
    required this.onDoubleTap,
  }) : super(key: key);

  @override
  State<InteractiveHistoryTag> createState() => _InteractiveHistoryTagState();
}

class _InteractiveHistoryTagState extends State<InteractiveHistoryTag> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const double paddingX = 16.0;
    const double tagHeight = 34.0;
    final double tagWidth = textPainter.width + (paddingX * 2);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() {
          _isActive = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isActive = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isActive = false;
        });
      },
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      child: CustomPaint(
        size: Size(tagWidth, tagHeight),
        painter: SingleTagPainter(
          text: widget.text,
          isActive: _isActive,
        ),
      ),
    );
  }
}

class SingleTagPainter extends CustomPainter {
  final String text;
  final bool isActive;

  SingleTagPainter({
    required this.text,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(20),
    );

    // Draw background capsule with harmonic palette
    final paint = Paint()
      ..color = isActive
          ? AppColors.primaryGreen.withOpacity(0.15)
          : const Color(0xFFF4F6F4)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isActive
          ? AppColors.primaryGreen
          : const Color(0xFFE0E5E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw dynamic capsule shadow for active states
    if (isActive) {
      canvas.drawRRect(
        rrect.inflate(1),
        Paint()
          ..color = AppColors.primaryGreen.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);

    // Draw Tag Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? AppColors.primaryGreen : AppColors.textCharcoal,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant SingleTagPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.isActive != isActive;
  }
}
