import 'database_helper.dart';

class OverAllPercentage {
  final String employeeName;

  OverAllPercentage({required this.employeeName});

  late Future<List<Map<String, dynamic>>> _tasksFuture;

  int total() {
    _tasksFuture = DatabaseHelper.instance.getTasksForUser(employeeName);
    return 0;
  }
}
