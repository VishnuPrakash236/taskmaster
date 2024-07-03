import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../DatabaseHelper/database_helper.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class PrintReportScreen extends StatefulWidget {
  @override
  _PrintReportScreenState createState() => _PrintReportScreenState();
}

class _PrintReportScreenState extends State<PrintReportScreen> {
  late Future<List<Map<String, dynamic>>> _employeeTasksFuture;
  late dynamic snapdata;
  GlobalKey chartKey = GlobalKey();
  Uint8List? chartImageBytes;

  @override
  void initState() {
    super.initState();
    // No async calls here to ensure proper lifecycle handling
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchEmployeeTasks(); // Fetch tasks after dependencies change
  }

  Future<void> _fetchEmployeeTasks() async {
    _employeeTasksFuture = _getEmployeeTasks();
  }

  Future<List<Map<String, dynamic>>> _getEmployeeTasks() async {
    List<Map<String, dynamic>> employeeTasks = [];
    List<String> employeeNames = await DatabaseHelper.instance.queryAllEmployeeNames();

    for (String employeeName in employeeNames) {
      List<Map<String, dynamic>> tasks = await DatabaseHelper.instance.getTasksForUser(employeeName);
      for (var task in tasks) {
        employeeTasks.add({
          'employeeName': employeeName,
          'taskName': task[DatabaseHelper.columnTaskName],
          'completedPercentage': task[DatabaseHelper.columnCompletedPercentage],
          'taskStatus': task[DatabaseHelper.columnStatus], // Add task status
          'dueDate': task[DatabaseHelper.columnDueDate],
        });
      }
    }
    return employeeTasks;
  }

  Future<void> _captureChart() async {
    try {
      RenderRepaintBoundary boundary = chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        setState(() {
          chartImageBytes = byteData.buffer.asUint8List();
        });
      }
    } catch (e) {
      print("Error capturing chart: $e");
    }
  }

  Future<void> _generatePDF(List<Map<String, dynamic>> employeeTasks) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    final formattedDate = "${now.day}/${now.month}/${now.year}";

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'Task Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 50),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date: $formattedDate'),
                  pw.Text('GRASPEAR SOLUTIONS'),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(
                  color: PdfColors.yellow900,
                  fontWeight: pw.FontWeight.bold,
                ),
                data: <List<dynamic>>[
                  <String>['Employee', 'Task', 'Completed (%)', 'Status', 'Due Date'],
                  ...employeeTasks.map((task) {
                    String statusText = task['taskStatus'] ?? 'Not Started';
                    PdfColor statusColor = PdfColors.deepOrange;
                    if (statusText == 'In Progress') {
                      statusColor = PdfColors.blue;
                    } else if (statusText == 'Completed') {
                      statusColor = PdfColors.green;
                    }

                    return [
                      task['employeeName'],
                      task['taskName'],
                      task['completedPercentage'].toString() == 'null'
                          ? '0'
                          : task['completedPercentage'].toString(),
                      pw.Text(
                        statusText,
                        style: pw.TextStyle(color: statusColor),
                      ),
                      task['dueDate'] != null ? task['dueDate'] : '',
                    ];
                  }),
                ],
              ),
              if (chartImageBytes != null) pw.SizedBox(height: 20),
              if (chartImageBytes != null)
                pw.Expanded(
                  child: pw.Image(
                    pw.MemoryImage(chartImageBytes!),
                  ),
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<List<charts.Series<EmployeeOverall, String>>> _createSampleData() async {
    List<Map<String, dynamic>> data = await DatabaseHelper.instance.getOverAll();
    List<EmployeeOverall> employeeOverallData = data.map((record) {
      return EmployeeOverall(
        record['name'],
        (record['OverAllPercentage'] is int)
            ? record['OverAllPercentage']
            : int.tryParse(record['OverAllPercentage'].toString()) ?? 0,
      );
    }).toList();

    return [
      charts.Series<EmployeeOverall, String>(
        id: 'EmployeeOverall',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (EmployeeOverall employee, _) => employee.employeeName,
        measureFn: (EmployeeOverall employee, _) => employee.overallPercentage,
        data: employeeOverallData,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print Report'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              await _captureChart();
              if (snapdata.hasData) {
                _generatePDF(snapdata.data!);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _employeeTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No employee tasks found.'));
          } else {
            snapdata = snapshot;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    DataTable(
                      columns: [
                        DataColumn(label: Text('Employee')),
                        DataColumn(label: Text('Task')),
                        DataColumn(label: Text('Completed (%)')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Due Date')),
                      ],
                      rows: snapshot.data!.map((task) {
                        Color statusColor = Colors.orange;
                        if (task['taskStatus'] == 'In Progress') {
                          statusColor = Colors.blue;
                        } else if (task['taskStatus'] == 'Completed') {
                          statusColor = Colors.green;
                        }

                        return DataRow(cells: [
                          DataCell(Text(task['employeeName'])),
                          DataCell(Text(task['taskName'])),
                          DataCell(Text(
                            (task['completedPercentage'].toString()) == 'null'
                                ? '0'
                                : task['completedPercentage'].toString(),
                          )),
                          DataCell(
                            Text(
                              task['taskStatus'] ?? 'Not Started',
                              style: TextStyle(color: statusColor),
                            ),
                          ),
                          DataCell(Text(task['dueDate'] != null ? task['dueDate'] : '')),
                        ]);
                      }).toList(),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FutureBuilder<List<charts.Series<EmployeeOverall, String>>>(
                            future: _createSampleData(),
                            builder: (context, chartSnapshot) {
                              if (chartSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (chartSnapshot.hasError) {
                                return Center(child: Text('Error: ${chartSnapshot.error}'));
                              } else if (!chartSnapshot.hasData || chartSnapshot.data!.isEmpty) {
                                return Center(child: Text('No chart data found.'));
                              } else {
                                return RepaintBoundary(
                                  key: chartKey,
                                  child: Container(
                                    height: 300,
                                    width: 700,
                                    child: charts.BarChart(
                                      chartSnapshot.data!,
                                      animate: true,
                                      vertical: false,
                                      behaviors: [
                                        charts.ChartTitle('Employee Task Performance',
                                            behaviorPosition: charts.BehaviorPosition.top,
                                            titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class EmployeeOverall {
  final String employeeName;
  final int overallPercentage;

  EmployeeOverall(this.employeeName, this.overallPercentage);
}
