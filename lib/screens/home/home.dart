import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/user.dart';
import 'package:my_employee_manager/screens/add_board/add_board.dart';
import 'package:my_employee_manager/screens/boards/my_boards.dart';
import 'package:my_employee_manager/screens/settings/settings.dart';

class Home extends StatefulWidget {
  final User user;

  const Home({this.user});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  MessageHandler handler = MessageHandler();

  @override
  Widget build(BuildContext context) {
    List<Widget> fragments = <Widget>[
      MyBoards(user: widget.user, handler: handler),
      Settings(),
    ];
    List<String> labels = ["My Projects", "Settings"];
    updateTokens();
    return Scaffold(
      //backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(labels[_selectedIndex]),
        elevation: 0.0,
        actions: [
          _selectedIndex == 0
              ? (FlatButton(
                  child: new Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddBoard(
                        handler: handler,
                        user: widget.user,
                      ),
                    ));
                  },
                ))
              : SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.dashboard,
            ),
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            label: labels[0],
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.settings,
            ),
            icon: Icon(
              Icons.settings_outlined,
            ),
            label: labels[1],
          ),
        ],
      ),
      body:
          Stack(children: [Center(child: fragments[_selectedIndex]), handler]),
    );
  }

  updateTokens() async {
    String token = await FirebaseMessaging().getToken();
    Firestore.instance
        .collection('Users')
        .document(widget.user.uid)
        .updateData({'token': token});
  }
}

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _fcm.deleteInstanceID();
    _fcm.requestNotificationPermissions(IosNotificationSettings());

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final snackbar = SnackBar(
          backgroundColor: Theme.of(context).accentColor,
          content: Text(message['notification']['body']),
          //content: Text(message['notification']['data']['id']),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        final snackbar = SnackBar(
          content: Text(message['notification']['title']),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // final snackbar = SnackBar(
        //   content: Text(message['notification']['title']),
        //   action: SnackBarAction(
        //     label: "Go",
        //     onPressed: () => null,
        //   ),
        // );
        // Scaffold.of(context).showSnackBar(snackbar);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: null,
    );
  }
}
