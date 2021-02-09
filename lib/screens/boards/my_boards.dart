import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/board.dart';
import 'package:my_employee_manager/models/user.dart';
import 'package:my_employee_manager/screens/boards/boards_list.dart';
import 'package:my_employee_manager/screens/home/home.dart';
import 'package:my_employee_manager/services/database.dart';
import 'package:provider/provider.dart';

class MyBoards extends StatefulWidget {
  final User user;
  final MessageHandler handler;

  const MyBoards({this.user, this.handler});
  @override
  _MyBoardsState createState() => _MyBoardsState();
}

class _MyBoardsState extends State<MyBoards> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Board>>.value(
      initialData: List(),
      value: DatabaseService(uid: widget.user.uid).boards,
      child: BoardList(handler:widget.handler),
    );
  }
}
