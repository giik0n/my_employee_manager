import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/board.dart';
import 'package:my_employee_manager/models/board_item_object.dart';
import 'package:my_employee_manager/models/board_list.dart';
import 'package:my_employee_manager/provider/task_provider.dart';
import 'package:my_employee_manager/services/database.dart';

class MyAlertDialog {
  final TaskProvider taskProvider;
  DatabaseService databaseService = DatabaseService();

  MyAlertDialog([this.taskProvider]);
  void showAddListDialog(BuildContext context, int listSize) async {
    String text = '';
    Widget cancelButton = FlatButton(
      color: Theme.of(context).primaryColor,
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      color: Theme.of(context).primaryColor,
      child: Text("Continue"),
      onPressed: () {
        if (text.length > 0) {
          taskProvider.addList(context, text, listSize + 1);
          //Navigator.pop(context);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      title: Text("Add new list"),
      content: TextField(
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: "Title",
        ),
        onChanged: (value) => text = value,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Add task dialog
  void showAddTaskDialog(BuildContext context, String listId, int size) async {
    BoardItemObject task =
        BoardItemObject(null, '', '', size, DateTime.now(), false, []);

    Widget cancelButton = FlatButton(
      color: Theme.of(context).primaryColor,
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      color: Theme.of(context).primaryColor,
      child: Text("Continue"),
      onPressed: () {
        if (task.title.length > 0) {
          taskProvider.addTask(context, listId, task);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      title: Text("Add new task"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: "Title"),
            onChanged: (value) => task.title = value,
          ),
          TextField(
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: "Description"),
            onChanged: (value) => task.description = value,
          ),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showDeleteAlertDialog(BuildContext context, BoardListObject list,
      [List<BoardListObject> boardItems]) async {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        boardItems.remove(list);
        taskProvider.deleteList(list.id);
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Deleting list"),
      content: Text("Would you like to continue deleting this list?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showDeleteBoardAlertDialog(BuildContext context, String id) async {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        databaseService.deleteBoard(id);
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Deleting Board"),
      content: Text("Would you like to continue deleting this board?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showUpdateBoardAlertDialog(BuildContext context, Board board) async {
    TextEditingController controller = TextEditingController();
    controller.text = board.title;
    String text = '';
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        if (text.length > 0) {
          databaseService.updateBoardName(board, text);
          //Navigator.pop(context);
        }
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Board name"),
      content: TextField(
        controller: controller,
        onChanged: (value) => text = value,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //update task
  void showUpdateTaskDialog(
      BuildContext context, String listId, BoardItemObject task) async {
    TextEditingController titleController = TextEditingController();
    titleController.text = task.title;
    TextEditingController descriptionController = TextEditingController();
    descriptionController.text = task.description;

    Widget cancelButton = FlatButton(
      color: Theme.of(context).primaryColor,
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      color: Theme.of(context).primaryColor,
      child: Text("Continue"),
      onPressed: () {
        if (task.title.length > 0) {
          taskProvider.updateTask(context, listId, task);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      title: Text("Update task"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: "Title"),
            onChanged: (value) => task.title = value,
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: "Description"),
            onChanged: (value) => task.description = value,
          ),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
