import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class SketchDrawingPad extends StatefulWidget {
  final String? initialDrawingData;
  final ValueChanged<String> onSaved;

  const SketchDrawingPad({
    Key? key,
    this.initialDrawingData,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<SketchDrawingPad> createState() => _SketchDrawingPadState();
}

class _SketchDrawingPadState extends State<SketchDrawingPad> {
  final List<List<Offset>> _strokes = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialDrawingData != null && widget.initialDrawingData!.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(widget.initialDrawingData!);
        for (final strokeData in decoded) {
          final List<Offset> stroke = [];
          for (final pointData in strokeData) {
            stroke.add(Offset(
              (pointData[0] as num).toDouble(),
              (pointData[1] as num).toDouble(),
            ));
          }
          _strokes.add(stroke);
        }
      } catch (e) {
        debugPrint("Gagal mendeserialisasi sketsa: $e");
      }
    }
  }

  String _serializeStrokes() {
    final List<List<List<double>>> data = _strokes.map((stroke) {
      return stroke.map((p) => [p.dx, p.dy]).toList();
    }).toList();
    return jsonEncode(data);
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
      });
    }
  }

  void _clear() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.clear();
      });
    }
  }

  void _save() {
    widget.onSaved(_serializeStrokes());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardLightGrey, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header / Control bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.draw_rounded, color: AppColors.primaryGreen, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Pad Tanda Tangan Catatan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textCharcoal,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo_rounded, color: AppColors.textLight, size: 20),
                      tooltip: 'Undo',
                      onPressed: _strokes.isEmpty ? null : _undo,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 20),
                      tooltip: 'Clear',
                      onPressed: _strokes.isEmpty ? null : _clear,
                    ),
                    IconButton(
                      icon: const Icon(Icons.save_outlined, color: AppColors.primaryGreen, size: 20),
                      tooltip: 'Save',
                      onPressed: _save,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardLightGrey),

          // Interactive canvas drawing zone
           ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: Container(
              height: 200,
              width: double.infinity,
              color: const Color(0xFFF7F8FA), // Signature pad light grey background
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double canvasWidth = constraints.maxWidth;
                  final double canvasHeight = constraints.maxHeight;

                  return GestureDetector(
                    // Gesture 1: Pan start (Add new line path within limits)
                    onPanStart: (details) {
                      final pos = details.localPosition;
                      final clampedPos = Offset(
                        pos.dx.clamp(4.0, canvasWidth - 4.0),
                        pos.dy.clamp(4.0, canvasHeight - 4.0),
                      );
                      setState(() {
                        _strokes.add([clampedPos]);
                      });
                    },
                    // Gesture 2: Pan update (Add coordinate nodes within limits)
                    onPanUpdate: (details) {
                      if (_strokes.isNotEmpty) {
                        final pos = details.localPosition;
                        final clampedPos = Offset(
                          pos.dx.clamp(4.0, canvasWidth - 4.0),
                          pos.dy.clamp(4.0, canvasHeight - 4.0),
                        );
                        setState(() {
                          _strokes.last.add(clampedPos);
                        });
                      }
                    },
                    child: CustomPaint(
                      painter: SketchCanvasPainter(strokes: _strokes),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SketchCanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  SketchCanvasPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textCharcoal // Professional dark ink color for signatures
      ..strokeWidth = 2.5 // Elegant pen line stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;

      if (stroke.length == 1) {
        // Draw a single dot if no drag happened
        canvas.drawCircle(stroke.first, 1.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke; // reset style
      } else {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SketchCanvasPainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}

// Optional helper component to draw a read-only preview thumbnail of sketches
class SketchThumbnailPreview extends StatelessWidget {
  final String drawingData;
  final double height;

  const SketchThumbnailPreview({
    Key? key,
    required this.drawingData,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<List<Offset>> strokes = [];
    if (drawingData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(drawingData);
        for (final strokeData in decoded) {
          final List<Offset> stroke = [];
          for (final pointData in strokeData) {
            stroke.add(Offset(
              (pointData[0] as num).toDouble(),
              (pointData[1] as num).toDouble(),
            ));
          }
          strokes.add(stroke);
        }
      } catch (e) {
        // fail silent
      }
    }

    if (strokes.isEmpty) return const SizedBox.shrink();

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardLightGrey.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: SketchCanvasPainter(strokes: strokes),
        ),
      ),
    );
  }
}
