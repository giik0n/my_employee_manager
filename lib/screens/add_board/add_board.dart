import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/user.dart';
import 'package:my_employee_manager/screens/home/home.dart';
import 'package:my_employee_manager/services/database.dart';

class AddBoard extends StatefulWidget {
  final User user;
  final MessageHandler handler;

  const AddBoard({this.user, this.handler});
  @override
  _AddBoardState createState() => _AddBoardState();
}

class _AddBoardState extends State<AddBoard> {
  String boardName = "";
  DatabaseService databaseService = new DatabaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add board"),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(hintText: "Board name"),
                onChanged: (value) {
                  setState(() {
                    boardName = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  onPressed: () {
                    if (boardName.length > 0) {
                      databaseService.addBoard(
                          context, boardName, widget.user.uid);
                    }
                  },
                  child: Text(
                    'Add',
                  ),
                ),
              ),
              widget.handler,
            ],
          ),
        ),
      ),
    );
  }
}
