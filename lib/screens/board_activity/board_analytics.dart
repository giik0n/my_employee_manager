import 'dart:collection';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/board_item_object.dart';
import 'package:my_employee_manager/models/board_list.dart';
import 'package:my_employee_manager/models/user.dart';
import 'package:my_employee_manager/provider/board_users_provider.dart';
import 'package:my_employee_manager/provider/task_provider.dart';
import 'package:provider/provider.dart';

class BoardAnalytics extends StatefulWidget {
  BoardAnalytics({Key key}) : super(key: key);

  @override
  _BoardAnalyticsState createState() => _BoardAnalyticsState();
}

class _BoardAnalyticsState extends State<BoardAnalytics> {
  TaskProvider taskProvider;
  List<BoardListObject> boardItems;
  BoardUsers boardUsers;
  List<User> users;

  @override
  Widget build(BuildContext context) {
    Color cardBackgroundColor = Theme.of(context).canvasColor.withOpacity(0.1);
    boardUsers = Provider.of<BoardUsers>(context, listen: false);
    taskProvider = Provider.of<TaskProvider>(context);
    if (users == null) {
      boardUsers.getUsersOfBoard(taskProvider.boardId).then((value) {
        users = value;
        setState(() {
          users = value;
        });
      });
    }

    boardItems = taskProvider.itemsBoard;
    int countDoneTasks = 0;
    int countInProgressTasks = 0;
    int countNotStartedTasks = 0;
    int countDeadlineOverdueTasks = 0;
    List<String> executors = [];
    List<BoardItemObject> tasks = [];
    Map<String, double> avgProductivity = Map();
    boardItems.forEach((element) {
      element.items.forEach((element2) {
        tasks.add(element2);
        element2.executors.forEach((element) {
          if (!executors.contains(element)) {
            executors.add(element);
          }
        });
        if (element2.doneAt != null) countDoneTasks++;
        if (element2.isDone == false && element2.startAt == null)
          countNotStartedTasks++;
        if ((element2.isDone == false &&
                element2.doneAt == null &&
                element2.deadline != null &&
                element2.deadline.isBefore(DateTime.now())) ||
            element2.deadline != null &&
                element2.doneAt != null &&
                element2.doneAt.isAfter(element2.deadline))
          countDeadlineOverdueTasks++;
        if (element2.startAt != null && element2.doneAt == null)
          countInProgressTasks++;
        // executors stats
      });
    });
    executors.forEach((executor) {
      List<double> pointsPerTask = [];
      List<int> taskDuration = [];
      tasks.forEach((task) {
        if (task.executors.contains(executor) &&
            task.doneAt != null &&
            task.storyPoint != null) {
          pointsPerTask.add(task.storyPoint / task.executors.length);
          //print(task.storyPoint / task.executors.length);
          taskDuration.add(task.doneAt.difference(task.startAt).inMinutes);
          //print(task.doneAt.difference(task.startAt).inMinutes);
        }
      });
      int value = ( //pointsPerTask.fold(0, (p, c) => p + c) /
          taskDuration.fold(0, (p, c) => p + c));
      if (value == 0) {
        value = 60;
      }
      print(value);
      if (pointsPerTask.isNotEmpty && taskDuration.isNotEmpty) {
        avgProductivity.putIfAbsent(executor,
            () => dp((pointsPerTask.fold(0, (p, c) => p + c) / value * 60), 2));
      }
    });

    var sortedKeys = avgProductivity.keys.toList(growable: false)
      ..sort((k1, k2) => avgProductivity[k1].compareTo(avgProductivity[k2]));
    LinkedHashMap<String, double> sortedMap = new LinkedHashMap.fromIterable(
        sortedKeys.reversed,
        key: (k) => k,
        value: (k) => avgProductivity[k]);
    avgProductivity = sortedMap;
    int barChartLenght =
        (avgProductivity.length <= 6) ? avgProductivity.length : 6;

    return (users != null)
        ? Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Scrollbar(
                child: ListView(
                  children: [
                    Card(
                      color: cardBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "Board tasks",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            PieChart(
                              PieChartData(
                                sections: <PieChartSectionData>[
                                  if (countDoneTasks > 0)
                                    PieChartSectionData(
                                      title: "Done (" +
                                          countDoneTasks.toString() +
                                          ")",
                                      value: double.parse(
                                          countDoneTasks.toString()),
                                      color: Colors.green,
                                    ),
                                  if (countInProgressTasks > 0)
                                    PieChartSectionData(
                                      title: "In progress (" +
                                          countInProgressTasks.toString() +
                                          ")",
                                      value: double.parse(
                                          countInProgressTasks.toString()),
                                      color: Colors.orange,
                                    ),
                                  if (countNotStartedTasks > 0)
                                    PieChartSectionData(
                                      title: "Not started (" +
                                          countNotStartedTasks.toString() +
                                          ")",
                                      value: double.parse(
                                          countNotStartedTasks.toString()),
                                      color: Colors.grey,
                                    ),
                                  if (countDeadlineOverdueTasks > 0)
                                    PieChartSectionData(
                                      title: "Deadline overdue (" +
                                          countDeadlineOverdueTasks.toString() +
                                          ")",
                                      value: double.parse(
                                          countDeadlineOverdueTasks.toString()),
                                      color: Colors.red,
                                    ),
                                ],
                                centerSpaceRadius: 80.0,
                                sectionsSpace: 4.0,
                                borderData: FlBorderData(
                                  show: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //Avg stopy points per hours
                    Card(
                      color: cardBackgroundColor,
                      child: Container(
                        //height: 250,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12.0,
                                bottom: 8,
                              ),
                              child: Text(
                                "Average story points per hour",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            Container(
                              height: 150,
                              child: BarChart(
                                BarChartData(
                                  barTouchData: BarTouchData(
                                    enabled: false,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipBgColor: Colors.transparent,
                                      tooltipPadding: const EdgeInsets.all(0),
                                      tooltipBottomMargin: 8,
                                      getTooltipItem: (
                                        BarChartGroupData group,
                                        int groupIndex,
                                        BarChartRodData rod,
                                        int rodIndex,
                                      ) {
                                        return BarTooltipItem(
                                          rod.y.toString(),
                                          TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: SideTitles(
                                      showTitles: true,
                                      getTextStyles: (value) => const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                      margin: 20,
                                      getTitles: (double value) {
                                        return users
                                            .firstWhere((element) =>
                                                element.uid ==
                                                avgProductivity.keys
                                                    .elementAt(value.toInt()))
                                            .name;
                                      },
                                    ),
                                    leftTitles: SideTitles(showTitles: false),
                                  ),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  barGroups: [
                                    for (var i = 0; i < barChartLenght; i++)
                                      BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                              y: avgProductivity.values
                                                  .elementAt(i),
                                              colors: [
                                                Colors.lightBlueAccent,
                                                Colors.pinkAccent
                                              ])
                                        ],
                                        showingTooltipIndicators: [0],
                                      ),
                                  ],
                                  // read about it in the below section
                                ),
                              ),
                            ),
                            Container(
                              height: 200,
                              child: Scrollbar(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: avgProductivity.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var key =
                                        avgProductivity.keys.elementAt(index);
                                    var value =
                                        avgProductivity.values.elementAt(index);
                                    Image photo = Image.network(
                                        "https://robohash.org/${key}");

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0, left: 8.0, bottom: 8),
                                      child: Card(
                                        //color: photoColor,
                                        color: Theme.of(context).primaryColor,
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            child: photo,
                                          ),
                                          title: Text(
                                            users
                                                .firstWhere((element) =>
                                                    element.uid == key)
                                                .name,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          trailing: Text(
                                            value.toString(),
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : Center(child: CircularProgressIndicator());
  }

  double dp(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }
}
