import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../DatabaseHelper/database_helper.dart';

class OverallPercentageChartScreen extends StatefulWidget {
  @override
  _OverallPercentageChartScreenState createState() =>
      _OverallPercentageChartScreenState();
}

class _OverallPercentageChartScreenState
    extends State<OverallPercentageChartScreen> {
  late Future<List<Map<String, dynamic>>> _userData;

  @override
  void initState() {
    super.initState();
    _userData = DatabaseHelper.instance.getOverAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status Over View'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return BarChartWidget(userData: snapshot.data!);
          }
        },
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> userData;

  BarChartWidget({required this.userData});

  @override
  Widget build(BuildContextcontext) {
    return SizedBox(
      height: 500,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: userData.length * 70.0, // Further increased width
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barGroups: userData.asMap().entries.map((entry) {
                  int index = entry.key;
                  double percentage = double.tryParse(
                          entry.value['OverAllPercentage'] ?? '0') ??
                      0;
                  int randomColorIndex = Random().nextInt(barColors.length);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: percentage,
                        color: barColors[randomColorIndex],
                        // Assign random color
                        width: 20,
                      ),
                    ],
                  );
                }).toList(),

                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < userData.length) {
                          return Padding(
                            // Add padding for spacing
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            // Adjust padding as needed
                            child: Text(
                              userData[index]['name'],
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else {
                          return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}%');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false), // Hide top titles
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(width: 1),
                    bottom: BorderSide(width: 1),
                    top: BorderSide.none,
                    right: BorderSide.none,
                  ),
                ),
                groupsSpace: 50, // Further increased spacing
              ),
            ),
          ),
        ),
      ),
    );
  }

  final List<Color> barColors = [
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];
}
