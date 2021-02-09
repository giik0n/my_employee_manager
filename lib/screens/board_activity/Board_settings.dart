import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_employee_manager/models/board.dart';
import 'package:my_employee_manager/screens/board_activity/board_view.dart'
    as board;
import 'package:my_employee_manager/models/user.dart';
import 'package:my_employee_manager/provider/board_users_provider.dart';
import 'package:my_employee_manager/shared/constants.dart';
import 'package:provider/provider.dart';

class BoardSettings extends StatefulWidget {
  String boardId;
  Function changeParentState;
  BoardSettings(
    this.boardId,
    this.changeParentState,
  );

  @override
  _BoardSettingsState createState() => _BoardSettingsState();
}

class _BoardSettingsState extends State<BoardSettings> {
  String addMemberEmail = '';
  var _controller = TextEditingController();
  BoardUsers boardUsers;
  List<User> users;
  FirebaseAuth auth = FirebaseAuth.instance;
  String id;
  Board board;
  @override
  void deactivate() {
    boardUsers.subUsers.cancel();
    boardUsers.subBoard.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String userEmail = '';
    boardUsers = Provider.of<BoardUsers>(context);
    users = boardUsers.users;
    boardUsers.getBoardById(widget.boardId);
    board = boardUsers.board;

    if (id == null) {
      auth.currentUser().then((value) {
        setState(() {
          id = value.uid;
        });
      });
    }

    List<String> images = [];

    for (var i = 0; i < users.length; i++) {
      images.add("https://robohash.org/${users[i].uid}");
    }

    return Container(
      child: (board != null && users != null)
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Contributors (' + users.length.toString() + ')',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color:
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).backgroundColor,
                            ),
                            height: 200.0,
                            child: Scrollbar(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: users.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            child: Stack(children: [
                                              Container(
                                                //padding: EdgeInsets.all(8),
                                                color: Colors.transparent,
                                                width: 50,
                                                height: 50,
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                    images[index],
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                  padding: EdgeInsets.all(0),
                                                  alignment: Alignment.topRight,
                                                  color: Colors.yellow,
                                                  splashColor:
                                                      Colors.transparent,
                                                  icon: (board.moderators
                                                          .contains(
                                                              users[index].uid))
                                                      ? Icon(Icons.star)
                                                      : Icon(
                                                          Icons.star_outline),
                                                  onPressed: () {
                                                    if (board.moderators
                                                        .contains(id)) {
                                                      if (board.moderators
                                                          .contains(users[index]
                                                              .uid)) {
                                                        //delete user form moderators
                                                        if (board.createdBy !=
                                                            users[index].uid) {
                                                          board.moderators
                                                              .remove(
                                                                  users[index]);
                                                          boardUsers
                                                              .removeFromModerators(
                                                                  users[index]
                                                                      .uid);
                                                        } else {
                                                          Fluttertoast
                                                              .showToast(
                                                            msg:
                                                                "You cant delete creator from moderators",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                    .withOpacity(
                                                                        0.7),
                                                            textColor: Theme.of(
                                                                    context)
                                                                .textSelectionColor,
                                                          );
                                                        }
                                                        //setState(() {});
                                                      } else {
                                                        board.moderators.add(
                                                            users[index].uid);
                                                        //add user to moderators
                                                        boardUsers
                                                            .addToModerators(
                                                                users[index]
                                                                    .uid);
                                                        //setState(() {});
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                            ]),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                users[index].name,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Opacity(
                                                  opacity: 0.5,
                                                  child:
                                                      Text(users[index].email)),
                                            ],
                                          ),
                                          Spacer(),
                                          if (users[index].uid !=
                                              board.createdBy)
                                            if (board.moderators.contains(id) ||
                                                users[index].uid == id)
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  boardUsers
                                                      .removeUserFromBoard(
                                                          board.id,
                                                          users[index].uid);
                                                },
                                              ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Flexible(
                                  child: TextField(
                                    textInputAction: TextInputAction.send,
                                    maxLines: 1,
                                    onSubmitted: (String str) {
                                      addMember(str);
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    controller: _controller,
                                    decoration: InputDecoration(
                                        hintText: 'Add member by email',
                                        suffixIcon: IconButton(
                                            icon:
                                                Icon(Icons.add_circle_outline),
                                            onPressed: () {
                                              addMember(userEmail);
                                            })),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Only moderators can delete lists, tasks, moderators and users *',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: Text("Change board wallpaper"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color:
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).backgroundColor,
                            ),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (var i = 0; i < imagePathes.length; i++)
                                  GestureDetector(
                                    onTap: () async {
                                      await Firestore.instance
                                          .collection('allBoards')
                                          .document(board.id)
                                          .updateData({'wallpaper': i});
                                      widget.changeParentState(i);
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(4, 8, 4, 8),
                                      child: Container(
                                        width: 100,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.asset(
                                            imagePathes[i],
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          : CircularProgressIndicator(),
    );
  }

  Future<List<User>> getUsers(String searchValue) async {
    return await Firestore.instance
        .collection('Users')
        .where('name', isGreaterThanOrEqualTo: searchValue)
        .snapshots()
        .forEach((element) {
      element.documents.map((e) {
        User(e.documentID, e.data['name']);
      }).toList();
    });
  }

  void addMember(String str) async {
    bool isAdded = await boardUsers.addNewMember(str.trim());
    if (isAdded) {
      _controller.clear();
    }

    Fluttertoast.showToast(
        msg: isAdded ? "New member added!" : "No such user",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
        textColor: Theme.of(context).textSelectionColor,
        fontSize: 18.0);
  }
}
