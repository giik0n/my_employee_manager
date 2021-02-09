import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/board.dart';
import 'package:my_employee_manager/screens/home/home.dart';
import 'package:provider/provider.dart';

import 'board_tile.dart';

class BoardList extends StatefulWidget {
  final MessageHandler handler;

  const BoardList({Key key, this.handler}) : super(key: key);
  @override
  _BoardListState createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> {
  @override
  Widget build(BuildContext context) {
    final boards = Provider.of<List<Board>>(context);

    return ListView.builder(
      itemCount: boards.length,
      itemBuilder: (context, index) {
        return BoardTile(
          handler: widget.handler,
          board: boards[index],
        );
      },
    );
  }
}
