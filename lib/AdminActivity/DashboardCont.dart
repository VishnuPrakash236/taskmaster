import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:screenshot/screenshot.dart';

import '../EmpActivity/update_task.dart';

class DashboardCont extends StatelessWidget {
  DashboardCont({
    super.key,
    required this.taskType,
    required this.taskTitle,
    required this.priority,
    required this.taskdate,
    required this.taskComp,
    required this.taskMap,
  });

  final Map<String, dynamic> taskMap;

  final String taskTitle;
  final String priority;
  final String taskType;
  final String taskdate;
  final String taskComp;

  @override
  Widget build(BuildContext context) {
    Color priColor = Colors.blue;
    if (priority.compareTo("High") == 0) {
      priColor = Color.fromARGB(129, 235, 73, 73);
    } else if (priority.compareTo("Medium") == 0) {
      priColor = Color.fromARGB(167, 236, 233, 16);
    } else if (priority.compareTo("Low") == 0) {
      priColor = Color.fromARGB(167, 16, 236, 16);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateTaskScreen(task: taskMap),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
        padding: EdgeInsets.zero,
        // width: 200,
        // height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          border: Border.all(color: Color.fromARGB(40, 0, 0, 0), width: 4),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    taskTitle,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const Icon(
                    Icons.more_vert,
                    color: Color(0xff212435),
                    size: 24,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    height: 30,
                    decoration: BoxDecoration(
                      color: priColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Color(0x4d9e9e9e), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        priority,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(3),
                    constraints: const BoxConstraints(
                      // minHeight: 0,
                      // minWidth: 0,
                      // maxHeight: double.infinity,
                      // maxWidth: double.infinity,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Color(0x4d9e9e9e), width: 1),
                    ),
                    child: Text(
                      taskType,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0xff000000),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 20, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.date_range,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                        child: Text(taskdate),
                      ),

                    ],
                  ),
                  Expanded(
                    child: LinearPercentIndicator(
                      // width:200,
                      lineHeight: 10,
                      curve: Curves.bounceIn,
                      percent: int.tryParse(taskComp) != null
                          ? int.parse(taskComp) / 100
                          : 0.0,
                      progressColor: Colors.blue,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Row(
                      children: [
                        Text('${taskComp}'),
                        const Icon(
                          Icons.percent_outlined,
                          size: 15,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}