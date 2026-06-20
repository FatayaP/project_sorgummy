import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryBarChart extends StatelessWidget {
  const CategoryBarChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.0,
        barTouchData: BarTouchData(
          enabled: false,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Color(0xFF9E9E9E), // AppColors.textLight
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Hama';
                    break;
                  case 1:
                    text = 'Tanam';
                    break;
                  case 2:
                    text = 'Pupuk';
                    break;
                  case 3:
                    text = 'Panen';
                    break;
                  case 4:
                    text = 'Air';
                    break;
                  default:
                    text = '';
                    break;
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFEEEEEE),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 0.85,
                color: const Color(0xFF2E7D32),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 0.68,
                color: const Color(0xFF558B2F),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 0.55,
                color: const Color(0xFF65B713),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 0.40,
                color: const Color(0xFF8BC34A),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                toY: 0.22,
                color: const Color(0xFFC5E1A5),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          ),
        ],
      ),
    );
  }
}
