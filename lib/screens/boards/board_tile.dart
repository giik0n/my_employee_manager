import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/board.dart';
import 'package:my_employee_manager/provider/board_users_provider.dart';
import 'package:my_employee_manager/provider/task_provider.dart';
import 'package:my_employee_manager/screens/board_activity/board_view.dart';
import 'package:my_employee_manager/screens/home/home.dart';
import 'package:my_employee_manager/services/alert_dialogs.dart';
import 'package:provider/provider.dart';

class BoardTile extends StatefulWidget {
  final Board board;
  final MessageHandler handler;

  BoardTile({this.board, this.handler});

  @override
  _BoardTileState createState() => _BoardTileState();
}

class _BoardTileState extends State<BoardTile> {
  var _tapPosition;

  @override
  Widget build(BuildContext context) {
    MyAlertDialog myAlertDialog = MyAlertDialog();

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTapDown: (TapDownDetails details) {
          _storePosition(details);
        },
        onLongPress: () async {
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject();
          int selected = await showMenu(
            context: context,
            position: RelativeRect.fromRect(
                _tapPosition & Size(40, 40), // smaller rect, the touch area
                Offset.zero & overlay.size // Bigger rect, the entire screen
                ),
            items: <PopupMenuItem<int>>[
              PopupMenuItem<int>(
                child: Text("Update name"),
                value: 0,
              ),
              PopupMenuItem<int>(
                child: Text("Delete"),
                value: 1,
              ),
            ],
            elevation: 8.0,
          );
          switch (selected) {
            case 0:
              myAlertDialog.showUpdateBoardAlertDialog(context, widget.board);
              break;
            case 1:
              myAlertDialog.showDeleteBoardAlertDialog(
                  context, widget.board.id);
              break;
            default:
          }
        },
        onTap: () {
          Provider.of<TaskProvider>(context, listen: false)
              .initProviderListener(widget.board.id);

          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              var myBoardView =
                  MyBoardView(widget.board, handler: widget.handler);
              return myBoardView;
            },
          ));
        },
        child: Container(
          height: 64.0,
          child: Card(
            semanticContainer: true,
            margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
            child: ListTile(
              title: Text(widget.board.title),
            ),
          ),
        ),
      ),
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}
