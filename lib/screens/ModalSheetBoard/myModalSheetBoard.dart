import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_employee_manager/models/board.dart';
import 'package:my_employee_manager/models/board_item_object.dart';
import 'package:my_employee_manager/models/user.dart';
import 'package:my_employee_manager/provider/board_users_provider.dart';
import 'package:my_employee_manager/provider/task_provider.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MyModalSheetBoard {
  TaskProvider _taskProvider;
  String _listId;
  String _currentUserId;
  BoardItemObject _itemObject;
  Board _board;
  final String serverToken =
      'AAAA4BJKUy4:APA91bEc3kDXCapflVI4FDdM4o2pglQeGt9ONlQdw8DxYqSF4HXIvASz7h7rbrQob98BokCfVWbOFbQ8OoxnLgtMIXkrT1Mz_yJadDZkJADLGfD05yELNrtdFLWawd94Vm0Op-z1BjRn';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  void showMyBottonSheet(context, TaskProvider taskProvider, String listId,
      BoardItemObject itemObject, Board board, String currentUserId) async {
    _taskProvider = taskProvider;
    _listId = listId;
    _itemObject = itemObject;
    _board = board;
    _currentUserId = currentUserId;

    BoardUsers boardUsers;
    boardUsers = Provider.of<BoardUsers>(context, listen: false);

    List<User> users = await boardUsers.getUsersOfBoard(taskProvider.boardId);

    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setMySheetState) {
              return Container(
                // height: MediaQuery.of(context).size.height * 0.6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    shrinkWrap: true,
                    //Widgets in Column
                    children: [
                      //CLOSE BUTTON
                      Row(
                        children: [
                          Spacer(),
                          IconButton(
                              icon: Icon(Icons.close_rounded),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ],
                      ),
                      //TITLE
                      (itemObject.title.length > 0)
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Text(
                                itemObject.title,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            )
                          : SizedBox.shrink(),

                      //DESCRIPTION
                      (itemObject.description.length > 0)
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Text(
                                itemObject.description,
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : SizedBox.shrink(),

                      //CREATING DATE
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Text(
                          "Created at: " +
                              DateFormat('yyyy-MM-dd kk:mm')
                                  .format(itemObject.createdAt),
                        ),
                      ),
                      //Images
                      Card(
                        child: Container(
                          height: 160,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext bc) {
                                          return SafeArea(
                                            child: Container(
                                              child: new Wrap(
                                                children: <Widget>[
                                                  new ListTile(
                                                      leading: new Icon(
                                                          Icons.photo_library),
                                                      title: new Text(
                                                          'Photo Library'),
                                                      onTap: () {
                                                        _imgFromGallery(context,
                                                            setMySheetState);
                                                        Navigator.of(context)
                                                            .pop();
                                                      }),
                                                  new ListTile(
                                                    leading: new Icon(
                                                        Icons.photo_camera),
                                                    title: new Text('Camera'),
                                                    onTap: () {
                                                      _imgFromCamera(context,
                                                          setMySheetState);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 150,
                                        width: 200,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      Positioned.fill(
                                        child: Align(
                                          child: Icon(
                                            Icons.add_circle_outline,
                                            size: 48,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                if (_itemObject.images != null &&
                                    _itemObject.images.length > 0)
                                  for (var i = _itemObject.images.length - 1;
                                      i >= 0;
                                      i--)
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Dialog(
                                                      child: Card(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    "Image preview",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .close),
                                                                  ),
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                            Container(
                                                                height: MediaQuery.of(context)
                                                                        .size
                                                                        .height *
                                                                    0.7,
                                                                child: PhotoViewGallery
                                                                    .builder(
                                                                        pageController: PageController(
                                                                            initialPage: _itemObject.images.length -
                                                                                1 -
                                                                                i),
                                                                        // scrollPhysics:
                                                                        //     const BouncingScrollPhysics(),
                                                                        builder: (BuildContext context,
                                                                            int
                                                                                index) {
                                                                          List<dynamic>
                                                                              reversed =
                                                                              _itemObject.images.reversed.toList();
                                                                          return PhotoViewGalleryPageOptions(
                                                                            imageProvider:
                                                                                NetworkImage(reversed[index]),
                                                                            initialScale:
                                                                                PhotoViewComputedScale.covered,
                                                                          );
                                                                        },
                                                                        itemCount: _itemObject
                                                                            .images
                                                                            .length,
                                                                        loadingBuilder: (context,
                                                                                event) =>
                                                                            Center(
                                                                              child: Container(
                                                                                width: 20.0,
                                                                                height: 20.0,
                                                                                child: CircularProgressIndicator(
                                                                                  value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                        backgroundDecoration:
                                                                            BoxDecoration(color: Colors.transparent))),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Hero(
                                                tag: 'imageHero',
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      _itemObject.images[i],
                                                  placeholder: (context, url) =>
                                                      Container(
                                                          height: 100,
                                                          width: 200,
                                                          child: Center(
                                                              child:
                                                                  new CircularProgressIndicator())),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          new Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: GestureDetector(
                                              onTap: () {
                                                Widget cancelButton =
                                                    FlatButton(
                                                  child: Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                                Widget continueButton =
                                                    FlatButton(
                                                  child: Text("Continue"),
                                                  onPressed: () {
                                                    _taskProvider
                                                        .deleteImageFromTask(
                                                            _listId,
                                                            _itemObject,
                                                            i);
                                                    _itemObject.images
                                                        .removeAt(i);
                                                    Navigator.of(context).pop();
                                                    setMySheetState(() {});
                                                  },
                                                );

                                                // set up the AlertDialog
                                                AlertDialog alert = AlertDialog(
                                                  title: Text("Deleting image"),
                                                  content: Text(
                                                      "Are you sure that you want to delete this iamge?"),
                                                  actions: [
                                                    cancelButton,
                                                    continueButton,
                                                  ],
                                                );

                                                // show the dialog
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return alert;
                                                  },
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black45,
                                                            blurRadius: 5.0,
                                                          ),
                                                        ]),
                                                    child: Icon(
                                                        Icons.cancel_outlined,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned.fill(
                                              child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: GestureDetector(
                                                onTap: () async {
                                                  showProgressDialog(
                                                      context: context,
                                                      loadingText:
                                                          "Downloading...");
                                                  await ImageDownloader
                                                      .downloadImage(_itemObject
                                                          .images[i]);
                                                  dismissProgressDialog();
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black45,
                                                            blurRadius: 5.0,
                                                          ),
                                                        ]),
                                                    child: Icon(
                                                        Icons.download_rounded,
                                                        color: Colors.white),
                                                  ),
                                                )),
                                          ))
                                        ],
                                      ),
                                    )
                              ],
                            ),
                          ),
                        ),
                      ),

                      ExpansionTile(
                        title: Text("More settings"),
                        children: [
                          StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setMyState) {
                              return Card(
                                child: itemObject.deadline != null
                                    ? ListTile(
                                        contentPadding:
                                            EdgeInsets.only(left: 16),
                                        onTap: () async {
                                          if (board.moderators
                                              .contains(_currentUserId)) {
                                            var tmp = await pickDateAndTime(
                                                context, itemObject.deadline);
                                            if (tmp != null) {
                                              itemObject.deadline = tmp;
                                              await taskProvider
                                                  .addDeadLineToTask(context,
                                                      listId, itemObject);
                                              setMyState(() {});
                                            }
                                          }
                                        },
                                        title: Text(
                                          'Deadline',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(DateFormat('yyyy-MM-dd kk:mm')
                                                .format(itemObject.deadline)),
                                            (board.moderators
                                                    .contains(_currentUserId))
                                                ? IconButton(
                                                    icon: Icon(
                                                      Icons.cancel,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () async {
                                                      await taskProvider
                                                          .deleteDeadline(
                                                              listId,
                                                              itemObject);
                                                      setMyState(() {
                                                        itemObject.deadline =
                                                            null;
                                                      });
                                                    })
                                                : SizedBox(
                                                    width: 16,
                                                  ),
                                          ],
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () async {
                                          if (board.moderators
                                              .contains(_currentUserId)) {
                                            var tmp = await pickDateAndTime(
                                                context, itemObject.deadline);
                                            if (tmp != null) {
                                              itemObject.deadline = tmp;
                                              await taskProvider
                                                  .addDeadLineToTask(context,
                                                      listId, itemObject);
                                              setMyState(() {});
                                            }
                                          }
                                        },
                                        child: Container(
                                          height: 56,
                                          color: Colors.transparent,
                                          child: Center(
                                            child: Text(
                                              'No deadline setted',
                                            ),
                                          ),
                                        ),
                                      ),
                              );
                            },
                          ),
                          //STORY POINT
                          Card(
                            child: GestureDetector(
                              onTap: _board.moderators.contains(_currentUserId)
                                  ? () async {
                                      var point = await _showDialog(
                                          context,
                                          (itemObject.storyPoint != null)
                                              ? itemObject.storyPoint
                                              : 1);
                                      if (point != null) {
                                        await taskProvider.setStoryPoint(
                                            listId, itemObject, point);
                                        itemObject.storyPoint = point;
                                        setMySheetState(() {});
                                      }
                                    }
                                  : null,
                              child: Container(
                                color: Colors.transparent,
                                height: 72,
                                child: Center(
                                  child: (_itemObject.storyPoint == null)
                                      ? Text("No Story Point setted")
                                      : ListTile(
                                          contentPadding:
                                              EdgeInsets.only(left: 16),
                                          title: Text("Story Point"),
                                          subtitle: Text("* for all executors"),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(itemObject.storyPoint
                                                  .toString()),
                                              _board.moderators
                                                      .contains(_currentUserId)
                                                  ? IconButton(
                                                      icon: Icon(Icons.cancel),
                                                      color: Colors.red,
                                                      onPressed: () {
                                                        taskProvider
                                                            .deleteStoryPoint(
                                                                listId,
                                                                itemObject);
                                                        itemObject.storyPoint =
                                                            null;
                                                        setMySheetState(() {});
                                                      })
                                                  : SizedBox(
                                                      width: 16,
                                                    )
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setMyRowState) {
                              return Column(
                                children: [
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Text('Executors'),
                                          ),
                                          Card(
                                            color: (MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.dark)
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context)
                                                    .primaryColorLight,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 75,
                                                child: Scrollbar(
                                                  child: ListView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    children: [
                                                      (board.moderators.contains(
                                                              _currentUserId))
                                                          ? GestureDetector(
                                                              onTap: () async {
                                                                //add new executor to current board
                                                                await showMyDialog(
                                                                    context,
                                                                    users);
                                                                setMyRowState(
                                                                    () {});
                                                              },
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    child:
                                                                        CircleAvatar(
                                                                      backgroundColor:
                                                                          Theme.of(context)
                                                                              .backgroundColor,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .add,
                                                                        size:
                                                                            30,
                                                                        color: Theme.of(context)
                                                                            .accentColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 8,
                                                                  ),
                                                                  Text('Add')
                                                                ],
                                                              ),
                                                            )
                                                          : SizedBox.shrink(),
                                                      //contributors
                                                      for (var i = 0;
                                                          i <
                                                              _itemObject
                                                                  .executors
                                                                  .length;
                                                          i++)
                                                        GestureDetector(
                                                          onTap: () {
                                                            //show executors menu maybe
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 8),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    child:
                                                                        CircleAvatar(
                                                                      backgroundImage:
                                                                          NetworkImage(
                                                                              "https://robohash.org/${_itemObject.executors[i]}"),
                                                                    )),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(users
                                                                    .firstWhere((element) =>
                                                                        element
                                                                            .uid ==
                                                                        _itemObject
                                                                            .executors[i])
                                                                    .name),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  (_itemObject.startAt != null)
                                      ? Text("Started at: " +
                                          _itemObject.startAt.toString())
                                      : SizedBox.shrink(),
                                  (_itemObject.doneAt != null)
                                      ? Text("Done at: " +
                                          _itemObject.doneAt.toString())
                                      : SizedBox.shrink(),
                                  (_itemObject.executors
                                              .contains(_currentUserId) &&
                                          itemObject.startAt == null)
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: double.infinity,
                                            child: RaisedButton(
                                              onPressed: () {
                                                itemObject.startAt =
                                                    DateTime.now();
                                                _itemObject.startAt =
                                                    DateTime.now();
                                                taskProvider.setStartAt(
                                                    board.id,
                                                    listId,
                                                    itemObject);
                                                setMyRowState(() {});
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(14.0),
                                                child: Text(
                                                  'Start',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                  (_itemObject.executors
                                              .contains(_currentUserId) &&
                                          itemObject.startAt != null &&
                                          itemObject.doneAt == null)
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: double.infinity,
                                            child: RaisedButton(
                                              onPressed: () {
                                                itemObject.doneAt =
                                                    DateTime.now();
                                                _itemObject.doneAt =
                                                    DateTime.now();
                                                taskProvider.setDoneAt(board.id,
                                                    listId, itemObject);

                                                itemObject.isDone = true;
                                                taskProvider.isDoneUpdate(
                                                    listId, itemObject);
                                                setMySheetState(() {});
                                                setMyRowState(() {});
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(14.0),
                                                child: Text(
                                                  'Done',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              );
                            },
                          ),
                          if (itemObject.doneAt != null)
                            ListTile(
                              contentPadding: EdgeInsets.only(left: 16),
                              title: Text('Done'),
                              trailing: StatefulBuilder(builder: (BuildContext
                                      context,
                                  void Function(void Function()) setCheckBox) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (itemObject.doneAt != null)
                                      Text(DateFormat('yyyy-MM-dd kk:mm')
                                          .format(itemObject.doneAt)),
                                    Checkbox(
                                      activeColor: Colors.greenAccent[400],
                                      onChanged: (bool value) async {
                                        if (board.moderators
                                            .contains(_currentUserId)) {
                                          if (value == false) {
                                            await taskProvider.deletestartAt(
                                                listId, itemObject);
                                            await taskProvider.deleteDoneAt(
                                                listId, itemObject);
                                            itemObject.isDone = value;
                                            taskProvider.isDoneUpdate(
                                                listId, itemObject);
                                          }
                                        }
                                        setCheckBox(() {});
                                        setMySheetState(() {
                                          itemObject.startAt = null;
                                          itemObject.doneAt = null;
                                        });
                                      },
                                      value: itemObject.isDone,
                                    ),
                                  ],
                                );
                              }),
                            ),
                        ],
                      ),
                      //DEADLINE
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Future<DateTime> pickDateAndTime(context, DateTime deadline) async {
    DateTime result;
    //Date
    DateTime date = await showDatePicker(
        context: context,
        firstDate: deadline != null
            ? DateTime(deadline.year - 5)
            : DateTime(DateTime.now().year - 5),
        lastDate: deadline != null
            ? DateTime(deadline.year + 5)
            : DateTime(DateTime.now().year + 5),
        initialDate: deadline != null ? deadline : DateTime.now());
    if (date == null) {
      return null;
    }
    //Time
    TimeOfDay time = await showTimePicker(
        context: context,
        initialTime: deadline != null
            ? TimeOfDay(hour: deadline.hour, minute: deadline.minute)
            : TimeOfDay.now());
    result = time != null
        ? DateTime(date.year, date.month, date.day, time.hour, time.minute)
        : DateTime(date.year, date.month, date.day, 0, 0);
    return result;
  }

  Future<double> _showDialog(context, double point) async {
    double result;
    await showDialog<double>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.decimal(
            minValue: 1,
            maxValue: 10,
            title: new Text("Pick a new story point"),
            initialDoubleValue: point,
          );
        }).then((double value) {
      if (value != null) {
        result = value;
      }
    });
    return result;
  }

  Future showMyDialog(context, List<User> users) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Container(
              height: 300,
              color: Colors.transparent,
              child: Stack(
                children: [
                  Container(
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 32,
                        ),
                        for (int i = 0; i < users.length; i++)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "https://robohash.org/${users[i].uid}"),
                            ),
                            title: Text(users[i].name),
                            subtitle: Text(users[i].email),
                            trailing: StatefulBuilder(
                              builder: (BuildContext context,
                                  void Function(void Function())
                                      setCheckboxState) {
                                return Checkbox(
                                  onChanged: (bool value) {
                                    if (_board.moderators
                                        .contains(_currentUserId)) {
                                      if (value) {
                                        _itemObject.executors.add(users[i].uid);
                                        var elements = [users[i].uid];
                                        Firestore.instance
                                            .collection('allBoards')
                                            .document(_board.id)
                                            .collection('Lists')
                                            .document(_listId)
                                            .collection('Tasks')
                                            .document(_itemObject.id)
                                            .updateData({
                                          'executors':
                                              FieldValue.arrayUnion(elements)
                                        });
                                        sendMessage(users[i].uid, "added to");
                                        setCheckboxState(() {});
                                      } else {
                                        _itemObject.executors
                                            .remove(users[i].uid);
                                        var elements = [users[i].uid];
                                        Firestore.instance
                                            .collection('allBoards')
                                            .document(_board.id)
                                            .collection('Lists')
                                            .document(_listId)
                                            .collection('Tasks')
                                            .document(_itemObject.id)
                                            .updateData({
                                          'executors':
                                              FieldValue.arrayRemove(elements)
                                        });
                                        sendMessage(
                                            users[i].uid, "removed from");
                                        setCheckboxState(() {});
                                      }
                                    }
                                  },
                                  value: _itemObject.executors
                                      .contains(users[i].uid),
                                );
                              },
                            ),
                          )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void sendMessage(String receiverId, String status) async {
    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    String token;

    DocumentSnapshot snap =
        await Firestore.instance.collection('Users').document(receiverId).get();
    token = snap.data['token'];
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'You was ' +
                status +
                ' task "' +
                _itemObject.title +
                '" on "' +
                _board.title +
                '" board',
            'title': 'this is a title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    );
  }

  _imgFromCamera(context, Function update) async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      int fileLength = await File(pickedFile.path).length();
      print(fileLength);
      if (fileLength > 3000000) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                    "Your file is too big, please select another. (Max size 3 MB)"),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Continue"))
                ],
              );
            });
      } else {
        confirmAndPush(context, pickedFile, update);
      }
    }
  }

  _imgFromGallery(context, Function update) async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      int fileLength = await File(pickedFile.path).length();
      print(fileLength);
      if (fileLength > 3000000) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                    "Your file is too big, please select another. (Max size 3 MB)"),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Continue"))
                ],
              );
            });
      } else {
        confirmAndPush(context, pickedFile, update);
      }
    }
  }

  confirmAndPush(context, PickedFile file, Function update) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: double.minPositive,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Confirm image?",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(file.path),
                      height: 200,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    FlatButton(
                      onPressed: () async {
                        //Navigator.of(context).pop();

                        await _taskProvider.pushImageToTask(
                            file, _listId, _itemObject, context, update);
                        update(() {});
                        Navigator.of(context).pop();
                      },
                      child: Text("Submit"),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
