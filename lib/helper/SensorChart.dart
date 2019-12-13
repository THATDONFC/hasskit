import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:intl/intl.dart';

class SensorChart extends StatefulWidget {
  final double stateMin;
  final double stateMax;
  final List<FlSpot> flSpots;

  const SensorChart(
      {@required this.stateMin,
      @required this.stateMax,
      @required this.flSpots});

  @override
  _SensorChartState createState() => _SensorChartState();
}

class _SensorChartState extends State<SensorChart> {
  List<Color> gradientColors = [
    ThemeInfo.colorIconActive,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 8 / 5,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
                color: const Color(0xff232d37)),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 12.0, left: 8.0, top: 12, bottom: 4),
              child: LineChart(
                mainData(
                    stateMin: widget.stateMin,
                    stateMax: widget.stateMax,
                    flSpots: widget.flSpots),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData(
      {double stateMin, double stateMax, List<FlSpot> flSpots}) {
    List<FlSpot> flSpots = [
      FlSpot(0, 3),
      FlSpot(2.6, 2),
      FlSpot(4.9, 5),
      FlSpot(6.8, 3.1),
      FlSpot(8, 4),
      FlSpot(9.5, 3),
      FlSpot(24, 4),
    ];
    flSpots = widget.flSpots;

    return LineChartData(
      gridData: FlGridData(
        horizontalInterval: (widget.stateMax - widget.stateMin) / 12,
        verticalInterval: 1,
        show: true,
        drawVerticalGrid: true,
        getDrawingHorizontalGridLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalGridLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: TextStyle(
              color: const Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return DateFormat('H')
                    .format(DateTime.now().subtract(Duration(hours: 24)));
              case 6:
                return DateFormat('H')
                    .format(DateTime.now().subtract(Duration(hours: 18)));
              case 12:
                return DateFormat('H')
                    .format(DateTime.now().subtract(Duration(hours: 12)));
              case 18:
                return DateFormat('H')
                    .format(DateTime.now().subtract(Duration(hours: 6)));

              case 24:
                return DateFormat('H').format(DateTime.now());
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          interval: (widget.stateMax - widget.stateMin),
          showTitles: true,
          textStyle: TextStyle(
            color: const Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            if (value <= widget.stateMin) {
              return value.toStringAsFixed(0);
            } else if (value >= widget.stateMin) {
              return value.toStringAsFixed(0);
            } else {
              log.d(
                  "value $value widget.stateMin ${widget.stateMin} widget.stateMax ${widget.stateMax}");
            }

            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 24,
      minY: widget.stateMin,
      maxY: widget.stateMax,
      lineBarsData: [
        LineChartBarData(
          spots: flSpots,
          isCurved: true,
          colors: gradientColors,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}
