import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:my_employee_manager/models/board.dart';
import 'package:my_employee_manager/models/board_item_object.dart';
import 'package:my_employee_manager/models/board_list.dart';
import 'package:my_employee_manager/provider/task_provider.dart';
import 'package:my_employee_manager/screens/ModalSheetBoard/myModalSheetBoard.dart';
import 'package:my_employee_manager/services/alert_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toggle_switch/toggle_switch.dart';

class BoardCalendar extends StatefulWidget {
  final String uid;
  final Board board;
  BoardCalendar(this.uid, this.board, {Key key}) : super(key: key);

  @override
  _BoardCalendarState createState() => _BoardCalendarState();
}

class _BoardCalendarState extends State<BoardCalendar> {
  CalendarController _calendarController;
  TaskProvider _taskProvider;
  List<BoardListObject> _boardItems;
  List<DateTime> _dates = [];
  List<BoardItemObject> _tasks = [];
  List<BoardItemObject> _selectedTasks = [];
  int _myTasksIndex = 0;
  Map<DateTime, List<BoardItemObject>> _events =
      Map<DateTime, List<BoardItemObject>>();
  List<dynamic> _selectedEvents = [];
  DateTime _selectedDay = DateTime.now();
  String id = '';
  var _tapPosition;
  MyAlertDialog myAlertDialog;
  CalendarFormat calendarFormat = CalendarFormat.twoWeeks;

  @override
  void initState() {
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    id = widget.uid;
    _taskProvider = Provider.of<TaskProvider>(context);
    _boardItems = _taskProvider.itemsBoard;

    if (_tasks != null) _tasks.clear();
    _boardItems.forEach((list) {
      list.items.forEach((task) {
        _tasks.add(task);
      });
    });

    _tasks.forEach((element) {
      if (!_dates.contains(element.deadline) && element.deadline != null) {
        _dates.add(element.deadline);
      }
    });

    _dates.forEach((date) {
      _events.putIfAbsent(date, () {
        List<BoardItemObject> eventElements = [];
        _tasks.forEach((element) {
          if (element.deadline == date) {
            eventElements.add(element);
          }
        });
        return eventElements;
      });
    });
    myAlertDialog = MyAlertDialog(_taskProvider);
    setSelectedTasks();

    return (_events != null)
        ? SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Theme.of(context).canvasColor.withOpacity(0.9),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          calendarFormat = _calendarController.calendarFormat;
                        });
                      },
                      child: TableCalendar(
                        initialCalendarFormat: CalendarFormat.twoWeeks,
                        onDaySelected:
                            (DateTime day, List events, List holidays) {
                          setSelectedTasks();
                          _selectedDay = day;
                          _myTasksIndex = 0;
                          setState(() {
                            _selectedDay = day;
                          });
                          setState(() {
                            calendarFormat = _calendarController.calendarFormat;
                          });
                        },
                        onHeaderTapped: (DateTime date) {
                          setState(() {
                            calendarFormat = _calendarController.calendarFormat;
                          });
                        },
                        events: _events,
                        calendarStyle: CalendarStyle(
                            canEventMarkersOverflow: true,
                            markersColor: Colors.green,
                            selectedColor: Colors.lightBlueAccent,
                            todayColor: Colors.pinkAccent),
                        calendarController: _calendarController,
                      ),
                    ),
                  ),
                ),
                (_selectedTasks.length > 0)
                    ? Column(
                        children: [
                          ToggleSwitch(
                            fontSize: 16,
                            //inactiveFgColor: Theme.of(context).unselectedWidgetColor,
                            minWidth: double.infinity,
                            activeBgColor: Theme.of(context).accentColor,
                            inactiveBgColor: Theme.of(context).primaryColorDark,
                            initialLabelIndex: _myTasksIndex,
                            labels: [
                              'All tasks',
                              if (_selectedTasks
                                      .where((e) => e.executors.contains(id))
                                      .toList()
                                      .length >
                                  0)
                                'My tasks'
                            ],
                            onToggle: (index) {
                              _selectedDay = _selectedDay;
                              _myTasksIndex = index;
                              setSelectedTasks();
                              setState(() {});
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: calendarFormat == CalendarFormat.twoWeeks
                                  ? MediaQuery.of(context).size.height * 0.5
                                  : calendarFormat == CalendarFormat.month
                                      ? MediaQuery.of(context).size.height *
                                          0.35
                                      : MediaQuery.of(context).size.height *
                                          0.55,
                              child: Card(
                                color: Theme.of(context)
                                    .canvasColor
                                    .withOpacity(0.1),
                                child: ListView.builder(
                                  itemCount: _selectedTasks.length,
                                  itemBuilder: (context, index) {
                                    BoardItemObject itemObject =
                                        _selectedTasks[index];
                                    CachedNetworkImage image;
                                    if (itemObject.images != null &&
                                        itemObject.images.length > 0) {
                                      image = CachedNetworkImage(
                                        imageUrl: itemObject.images[
                                            itemObject.images.length - 1],
                                        placeholder: (context, url) => Container(
                                            height: 100,
                                            width: 220,
                                            child: Center(
                                                child:
                                                    new CircularProgressIndicator())),
                                        errorWidget: (context, url, error) =>
                                            new Icon(Icons.error),
                                      );
                                    }
                                    return Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          var i = _boardItems.indexWhere(
                                              (element) => element.items
                                                  .contains(itemObject));
                                          MyModalSheetBoard().showMyBottonSheet(
                                              context,
                                              _taskProvider,
                                              _boardItems[i].id,
                                              itemObject,
                                              widget.board,
                                              widget.uid);
                                        },
                                        child: Container(
                                          width: 260,
                                          child: Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 210,
                                                        child: Text(
                                                          itemObject.title,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTapDown:
                                                            (details) async {
                                                          _tapPosition = details
                                                              .globalPosition;

                                                          final RenderBox
                                                              overlay =
                                                              Overlay.of(
                                                                      context)
                                                                  .context
                                                                  .findRenderObject();
                                                          int selected =
                                                              await showMenu(
                                                            context: context,
                                                            position: RelativeRect
                                                                .fromRect(
                                                                    _tapPosition &
                                                                        Size(40,
                                                                            40), // smaller rect, the touch area
                                                                    Offset.zero &
                                                                        overlay
                                                                            .size // Bigger rect, the entire screen
                                                                    ),
                                                            items: <
                                                                PopupMenuItem<
                                                                    int>>[
                                                              (widget.board
                                                                      .moderators
                                                                      .contains(
                                                                          widget
                                                                              .uid))
                                                                  ? PopupMenuItem<
                                                                      int>(
                                                                      child: Text(
                                                                          "Update"),
                                                                      value: 0,
                                                                    )
                                                                  : null,
                                                              PopupMenuItem<
                                                                  int>(
                                                                child: Text(
                                                                    "Copy"),
                                                                value: 1,
                                                              ),
                                                              (widget.board
                                                                      .moderators
                                                                      .contains(
                                                                          widget
                                                                              .uid))
                                                                  ? PopupMenuItem<
                                                                      int>(
                                                                      child: Text(
                                                                          "Delete"),
                                                                      value: 2,
                                                                    )
                                                                  : null,
                                                            ],
                                                            elevation: 8.0,
                                                          );
                                                          switch (selected) {
                                                            case 0:
                                                              var i = _boardItems.indexWhere(
                                                                  (element) => element
                                                                      .items
                                                                      .contains(
                                                                          itemObject));
                                                              myAlertDialog
                                                                  .showUpdateTaskDialog(
                                                                      context,
                                                                      _boardItems[
                                                                              i]
                                                                          .id,
                                                                      itemObject);
                                                              break;
                                                            case 1:
                                                              print(itemObject
                                                                  .toJson()
                                                                  .toString());
                                                              FlutterClipboard
                                                                  .copy(itemObject
                                                                      .toJson()
                                                                      .toString());

                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "Item copied",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor: Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          0.7),
                                                                  textColor: Theme.of(
                                                                          context)
                                                                      .textSelectionColor,
                                                                  fontSize:
                                                                      24.0);
                                                              break;
                                                            case 2:
                                                              var i = _boardItems.indexWhere(
                                                                  (element) => element
                                                                      .items
                                                                      .contains(
                                                                          itemObject));

                                                              _taskProvider
                                                                  .deleteTask(
                                                                      _boardItems[
                                                                              i]
                                                                          .id,
                                                                      itemObject);
                                                              break;
                                                            default:
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 8.0),
                                                          child: Icon(
                                                              Icons.more_vert),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  (itemObject.images != null &&
                                                          itemObject.images
                                                                  .length >
                                                              0)
                                                      ? Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Container(
                                                              width: 230,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        5,
                                                                    blurRadius:
                                                                        7,
                                                                    offset: Offset(
                                                                        0,
                                                                        3), // changes position of shadow
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                child: image,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        )
                                                      : SizedBox.shrink(),
                                                  (itemObject.description
                                                              .length >
                                                          0)
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 8.0),
                                                          child: Container(
                                                            width: 210,
                                                            child: Text(itemObject
                                                                .description),
                                                          ),
                                                        )
                                                      : SizedBox.shrink(),
                                                  if (itemObject.deadline !=
                                                          null &&
                                                      itemObject.isDone ==
                                                          false)
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            (itemObject.deadline
                                                                        .difference(DateTime
                                                                            .now())
                                                                        .inMilliseconds >
                                                                    0)
                                                                ? Icons.timer
                                                                : Icons
                                                                    .timer_off,
                                                            color: (itemObject
                                                                        .deadline
                                                                        .difference(DateTime
                                                                            .now())
                                                                        .inMilliseconds >
                                                                    0)
                                                                ? Theme.of(
                                                                        context)
                                                                    .accentColor
                                                                : Colors.red),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          (itemObject.deadline
                                                                      .difference(
                                                                          DateTime
                                                                              .now())
                                                                      .inMilliseconds <
                                                                  0)
                                                              ? itemObject.deadline.difference(DateTime.now()).inDays >
                                                                      -1
                                                                  ? _printDuration(itemObject.deadline.difference(DateTime.now()))
                                                                      .replaceAll(
                                                                          "-", "")
                                                                  : itemObject
                                                                          .deadline
                                                                          .difference(DateTime
                                                                              .now())
                                                                          .inDays
                                                                          .toString()
                                                                          .replaceAll(
                                                                              "-",
                                                                              "") +
                                                                      ' day(s)'
                                                              : itemObject.deadline
                                                                          .difference(DateTime.now())
                                                                          .inDays <
                                                                      1
                                                                  ? _printDuration(itemObject.deadline.difference(DateTime.now()))
                                                                  : itemObject.deadline.difference(DateTime.now()).inDays.toString() + ' day(s)',
                                                          style: TextStyle(
                                                              color: (itemObject
                                                                          .deadline
                                                                          .difference(DateTime
                                                                              .now())
                                                                          .inMilliseconds >
                                                                      0)
                                                                  ? Theme.of(
                                                                          context)
                                                                      .accentColor
                                                                  : Colors.red),
                                                        )
                                                      ],
                                                    ),
                                                  if (itemObject.startAt !=
                                                          null &&
                                                      itemObject.doneAt != null)
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.check,
                                                          color: Colors
                                                              .greenAccent[400],
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Done',
                                                          style: TextStyle(
                                                            color: Colors
                                                                    .greenAccent[
                                                                400],
                                                          ),
                                                        ),
                                                        if (itemObject
                                                                    .deadline !=
                                                                null &&
                                                            itemObject.doneAt
                                                                .isAfter(itemObject
                                                                    .deadline))
                                                          Text(
                                                            " deadline overdue",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                      ],
                                                    ),
                                                  if (itemObject.doneAt ==
                                                          null &&
                                                      itemObject.startAt !=
                                                          null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 4),
                                                      child: Text(
                                                        "In progress",
                                                        style: TextStyle(
                                                          color: Colors
                                                                  .orangeAccent[
                                                              200],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );

                                    // child: Card(
                                    //   color: Theme.of(context).primaryColor,
                                    //   child: ListTile(
                                    //     title:
                                    //         Text(_selectedTasks[index].title),
                                    //     trailing: Text(
                                    //         DateFormat('yyyy-MM-dd kk:mm')
                                    //             .format(_selectedTasks[index]
                                    //                 .deadline)),
                                    //   ),
                                    // ),
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
          )
        : CircularProgressIndicator();
  }

  void setSelectedTasks() {
    _selectedTasks.clear();
    _tasks.forEach((element) {
      if (element.deadline != null &&
          element.deadline.day == _selectedDay.day) {
        if (_myTasksIndex == 0) {
          _selectedTasks.add(element);
        } else {
          if (element.executors.contains(id)) {
            _selectedTasks.add(element);
          }
        }
      }
    });
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m";
  }
}
