import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ActivityLineChart extends StatelessWidget {
  const ActivityLineChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFEEEEEE),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: false, // Titles are handled outside the chart in the container
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 0.45),
              FlSpot(1, 0.55),
              FlSpot(2, 0.38),
              FlSpot(3, 0.72),
              FlSpot(4, 0.60),
              FlSpot(5, 0.80),
              FlSpot(6, 0.65),
            ],
            isCurved: true,
            color: const Color(0xFF65B713), // Neon green
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF65B713),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF65B713).withOpacity(0.18),
                  const Color(0xFF65B713).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
