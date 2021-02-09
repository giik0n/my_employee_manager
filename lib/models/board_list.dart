import 'package:my_employee_manager/models/board_item_object.dart';

class BoardListObject {
  String id;
  String title;
  int position;
  List<BoardItemObject> items;

  BoardListObject({this.title, this.items, this.id, this.position}) {
    if (this.title == null) {
      this.title = "";
    }
    if (this.id == null) {
      this.id = "";
    }
    if (this.items == null) {
      this.items = [];
    }
  }
}
