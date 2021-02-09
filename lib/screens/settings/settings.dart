import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_employee_manager/services/auth.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String userName;
  FirebaseAuth auth = FirebaseAuth.instance;
  String id;
  TextEditingController controller = TextEditingController();
  AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    if (id == null) {
      auth.currentUser().then((value) {
        setState(() {
          id = value.uid;
        });
      });
    }

    if (userName == null) {
      getUserName();
      return CircularProgressIndicator();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 8,
          ),
          Card(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.92,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8),
                      child: Text('My name'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: controller,
                        onChanged: (value) {
                          setState(() {
                            userName = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: RaisedButton(
                          onPressed: () async {
                            String state =
                                await _auth.changeUserName(id, userName);

                            Fluttertoast.showToast(
                                msg: state,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.7),
                                textColor: Theme.of(context).textSelectionColor,
                                fontSize: 24.0);
                          },
                          child: Text('Save'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Spacer(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: RaisedButton(
              color: Colors.red,
              child: Text(
                "Log Out",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ),
        ],
      );
    }
  }

  void getUserName() async {
    String name = await _auth.getUserName(id);
    setState(() {
      userName = name;
      controller.text = name;
    });
  }
}
