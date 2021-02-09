import 'dart:convert';

import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_employee_manager/models/board.dart';
import 'package:my_employee_manager/models/board_list.dart';
import 'package:my_employee_manager/models/board_item_object.dart';
import 'package:my_employee_manager/provider/board_users_provider.dart';
import 'package:my_employee_manager/provider/task_provider.dart';
import 'package:my_employee_manager/screens/ModalSheetBoard/myModalSheetBoard.dart';
import 'package:my_employee_manager/screens/board_activity/Board_settings.dart';
import 'package:my_employee_manager/screens/board_activity/board_analytics.dart';
import 'package:my_employee_manager/screens/board_activity/board_calendar.dart';
import 'package:my_employee_manager/services/alert_dialogs.dart';
import 'package:my_employee_manager/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:my_employee_manager/screens/home/home.dart' as handler1;

class MyBoardView extends StatefulWidget {
  final Board board;
  final handler1.MessageHandler handler;
  MyBoardView(this.board, {this.handler});

  @override
  _MyBoardViewState createState() => _MyBoardViewState();
}

class _MyBoardViewState extends State<MyBoardView> {
  var _tapPosition;
  TaskProvider taskProvider;
  List<BoardListObject> boardItems;
  List<BoardList> _lists = [];
  MyAlertDialog myAlertDialog;
  int _selectedIndex = 0;
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid;
  int wallpaperIndex;
  BoardViewController boardViewController;

  void changeWallpaperState(int index) {
    wallpaperIndex = index;

    setState(() {
      wallpaperIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      auth.currentUser().then((value) {
        setState(() {
          uid = value.uid;
        });
      });
    }
    boardViewController = new BoardViewController();

    taskProvider = Provider.of<TaskProvider>(context);
    boardItems = taskProvider.itemsBoard;
    myAlertDialog = MyAlertDialog(taskProvider);

    BoardSettings settingsWidget =
        BoardSettings(widget.board.id, changeWallpaperState);
    BoardSettings(widget.board.id, changeWallpaperState);
    List<String> labels = ["Board", "Calendar", "Analytics", "Settings"];
    List<Widget> fragments = [
      BoardView(
        lists: createLists(boardItems),
        boardViewController: boardViewController,
      ),
      BoardCalendar(uid, widget.board),
      BoardAnalytics(),
      settingsWidget
    ];
    if (wallpaperIndex == null) {
      wallpaperIndex = widget.board.wallpaper;
    }

    return Stack(children: [
      (widget.board.wallpaper == null)
          ? (MediaQuery.of(context).platformBrightness == Brightness.dark)
              ? Image.asset(
                  'assets/images/darkWallpaper.jpg',
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/images/board_background_forest.png',
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                )
          : Image.asset(
              imagePathes[wallpaperIndex],
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).primaryColor.withOpacity(0.5)
                : Theme.of(context).primaryColor,
            elevation: 0.0,
            title: Text(
              widget.board.title,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              _selectedIndex == 0
                  ? FlatButton(
                      onPressed: () {
                        myAlertDialog.showAddListDialog(
                          context,
                          boardItems.length,
                        );
                      },
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            selectedItemColor: Theme.of(context).accentColor,
            unselectedItemColor: Theme.of(context).primaryColorLight,
            currentIndex: _selectedIndex,
            onTap: (value) {
              setState(() {
                _selectedIndex = value;
                if (value == 3) {
                  Provider.of<BoardUsers>(context, listen: false)
                      .initProviderListener(widget.board.id);
                }
              });
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.dashboard),
                icon: Icon(Icons.dashboard_outlined),
                label: labels[0],
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.calendar_today),
                icon: Icon(Icons.calendar_today_outlined),
                label: labels[1],
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.analytics),
                icon: Icon(Icons.analytics_outlined),
                label: labels[2],
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.settings),
                icon: Icon(Icons.settings_outlined),
                label: labels[3],
              ),
            ],
          ),
        ),
        body: Stack(
          children: [fragments[_selectedIndex], widget.handler],
        ),
      ),
    ]);
  }

  List<BoardList> createLists(List<BoardListObject> itemsBoard) {
    _lists.clear();
    for (int i = 0; i < itemsBoard.length; i++) {
      _lists.add(_createBoardList(itemsBoard[i]));
    }
    return _lists;
  }

  Widget _createBoardList(BoardListObject list) {
    List<BoardItem> items = new List();

    for (int i = 0; i < list.items.length; i++) {
      items.insert(i, buildBoardItem(list.items[i]));
    }

    return BoardList(
      onStartDragList: (int listIndex) {
        HapticFeedback.heavyImpact();
      },
      onTapList: (int listIndex) async {},
      onDropList: (int listIndex, int oldListIndex) {
        HapticFeedback.lightImpact();
        //Update our local list data
        var list = boardItems[oldListIndex];

        boardItems.removeAt(oldListIndex);
        boardItems.insert(listIndex, list);
        taskProvider.updateListPositions(boardItems);
      },
      headerBackgroundColor: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).primaryColorLight.withOpacity(0.6),
      header: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: GestureDetector(
                  onTapDown: (details) {
                    _tapPosition = details.globalPosition;
                  },
                  onLongPress: () async {
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject();
                    int selected = await showMenu(
                      context: context,
                      position: RelativeRect.fromRect(
                          _tapPosition &
                              Size(40, 40), // smaller rect, the touch area
                          Offset.zero &
                              overlay.size // Bigger rect, the entire screen
                          ),
                      items: <PopupMenuItem<int>>[
                        PopupMenuItem<int>(
                          child: Text("Paste"),
                          value: 0,
                        ),
                      ],
                      elevation: 8.0,
                    );
                    switch (selected) {
                      case 0:
                        FlutterClipboard.paste().then((value) {
                          print(value);
                          // Do what ever you want with the value.
                          BoardItemObject task =
                              BoardItemObject.fromJson(jsonDecode(value));

                          print(task.isDone);
                          task.position = list.items.length + 1;
                          taskProvider.addTask(null, list.id, task);
                        });
                        break;
                      default:
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            list.title,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      FlatButton(
                        minWidth: 5.0,
                        onPressed: () {
                          myAlertDialog.showAddTaskDialog(
                              context, list.id, list.items.length);
                        },
                        child: Icon(
                          Icons.add,
                          size: 30.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ))),
      ],
      items: items,
      footer: (widget.board.moderators.contains(uid))
          ? FlatButton(
              onPressed: () {
                myAlertDialog.showDeleteAlertDialog(context, list, boardItems);
                taskProvider.updateListPositions(boardItems);
              },
              child: Container(
                width: 300,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).bottomAppBarColor.withOpacity(0.7),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Delete "${list.title}"',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget buildBoardItem(BoardItemObject itemObject) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
    CachedNetworkImage image;
    if (itemObject.images != null && itemObject.images.length > 0) {
      image = CachedNetworkImage(
        imageUrl: itemObject.images[itemObject.images.length - 1],
        placeholder: (context, url) => Container(
            height: 100,
            width: 220,
            child: Center(child: new CircularProgressIndicator())),
        errorWidget: (context, url, error) => new Icon(Icons.error),
      );
    }

    return BoardItem(
      onStartDragItem: (int listIndex, int itemIndex, BoardItemState state) {
        HapticFeedback.heavyImpact();
      },
      onDropItem: (int listIndex, int itemIndex, int oldListIndex,
          int oldItemIndex, BoardItemState state) {
        HapticFeedback.lightImpact();
        //Used to update our local item data
        var item = boardItems[oldListIndex].items[oldItemIndex];
        taskProvider.removeTaskFromList(boardItems[oldListIndex].id,
            boardItems[oldListIndex].items[oldItemIndex]);
        boardItems[oldListIndex].items.removeAt(oldItemIndex);
        item.position = boardItems[listIndex].items.length;
        taskProvider.addTaskToList(boardItems[listIndex].id, item);
        boardItems[listIndex].items.insert(itemIndex, item);
        taskProvider.updateListTasksPositions(boardItems);
      },
      onTapItem: (int listIndex, int itemIndex, BoardItemState state) async {
        var i = boardItems
            .indexWhere((element) => element.items.contains(itemObject));
        MyModalSheetBoard().showMyBottonSheet(context, taskProvider,
            boardItems[i].id, itemObject, widget.board, uid);
      },
      item: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 210,
                    child: Text(
                      itemObject.title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (details) async {
                      _tapPosition = details.globalPosition;

                      final RenderBox overlay =
                          Overlay.of(context).context.findRenderObject();
                      int selected = await showMenu(
                        context: context,
                        position: RelativeRect.fromRect(
                            _tapPosition &
                                Size(40, 40), // smaller rect, the touch area
                            Offset.zero &
                                overlay.size // Bigger rect, the entire screen
                            ),
                        items: <PopupMenuItem<int>>[
                          (widget.board.moderators.contains(uid))
                              ? PopupMenuItem<int>(
                                  child: Text("Update"),
                                  value: 0,
                                )
                              : null,
                          PopupMenuItem<int>(
                            child: Text("Copy"),
                            value: 1,
                          ),
                          (widget.board.moderators.contains(uid))
                              ? PopupMenuItem<int>(
                                  child: Text("Delete"),
                                  value: 2,
                                )
                              : null,
                        ],
                        elevation: 8.0,
                      );
                      switch (selected) {
                        case 0:
                          var i = boardItems.indexWhere(
                              (element) => element.items.contains(itemObject));
                          myAlertDialog.showUpdateTaskDialog(
                              context, boardItems[i].id, itemObject);
                          break;
                        case 1:
                          print(itemObject.toJson().toString());
                          FlutterClipboard.copy(itemObject.toJson().toString());

                          Fluttertoast.showToast(
                              msg: "Item copied",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.7),
                              textColor: Theme.of(context).textSelectionColor,
                              fontSize: 24.0);
                          break;
                        case 2:
                          var i = boardItems.indexWhere(
                              (element) => element.items.contains(itemObject));

                          taskProvider.deleteTask(boardItems[i].id, itemObject);
                          break;
                        default:
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(Icons.more_vert),
                    ),
                  ),
                ],
              ),
              (itemObject.images != null && itemObject.images.length > 0)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: 230,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: image,
                            // CachedNetworkImage(
                            //   imageUrl: itemObject
                            //       .images[itemObject.images.length - 1],
                            //   placeholder: (context, url) => Container(
                            //       height: 220,
                            //       width: 220,
                            //       child: Center(
                            //           child: new CircularProgressIndicator())),
                            //   errorWidget: (context, url, error) =>
                            //       new Icon(Icons.error),
                            // ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              (itemObject.description.length > 0)
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        width: 210,
                        child: Text(itemObject.description),
                      ),
                    )
                  : SizedBox.shrink(),
              if (itemObject.deadline != null && itemObject.isDone == false)
                Row(
                  children: [
                    Icon(
                        (itemObject.deadline
                                    .difference(DateTime.now())
                                    .inMilliseconds >
                                0)
                            ? Icons.timer
                            : Icons.timer_off,
                        color: (itemObject.deadline
                                    .difference(DateTime.now())
                                    .inMilliseconds >
                                0)
                            ? Theme.of(context).accentColor
                            : Colors.red),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      (itemObject.deadline
                                  .difference(DateTime.now())
                                  .inMilliseconds <
                              0)
                          ? itemObject.deadline
                                      .difference(DateTime.now())
                                      .inDays >
                                  -1
                              ? _printDuration(itemObject.deadline
                                      .difference(DateTime.now()))
                                  .replaceAll("-", "")
                              : itemObject.deadline
                                      .difference(DateTime.now())
                                      .inDays
                                      .toString()
                                      .replaceAll("-", "") +
                                  ' day(s)'
                          : itemObject.deadline
                                      .difference(DateTime.now())
                                      .inDays <
                                  1
                              ? _printDuration(itemObject.deadline
                                  .difference(DateTime.now()))
                              : itemObject.deadline
                                      .difference(DateTime.now())
                                      .inDays
                                      .toString() +
                                  ' day(s)',
                      style: TextStyle(
                          color: (itemObject.deadline
                                      .difference(DateTime.now())
                                      .inMilliseconds >
                                  0)
                              ? Theme.of(context).accentColor
                              : Colors.red),
                    )
                  ],
                ),
              if (itemObject.startAt != null && itemObject.doneAt != null)
                Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: Colors.greenAccent[400],
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.greenAccent[400],
                      ),
                    ),
                    if (itemObject.deadline != null &&
                        itemObject.doneAt.isAfter(itemObject.deadline))
                      Text(
                        " deadline overdue",
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              if (itemObject.doneAt == null && itemObject.startAt != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    "In progress",
                    style: TextStyle(
                      color: Colors.orangeAccent[200],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m";
  }
}
