import 'dart:convert';

class BoardItemObject {
  String id;
  String title, description;
  int position;
  DateTime createdAt;
  DateTime deadline;
  DateTime startAt;
  DateTime doneAt;
  bool isDone;
  List<dynamic> executors;
  List<dynamic> images;
  double storyPoint;

  BoardItemObject(this.id, this.title, this.description, this.position,
      this.createdAt, this.isDone, this.executors,
      [this.deadline,
      this.startAt,
      this.doneAt,
      this.storyPoint,
      this.images]) {
    if (this.title == null) {
      this.title = "";
    }
    if (this.description == null) {
      this.description = "";
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      '"id"': '"' + id + '"',
      '"title"': '"' + title + '"',
      '"description"': '"' + description + '"',
      '"position"': '"' + position.toString() + '"',
      '"createdAt"': '"' + createdAt.toString() + '"',
      '"isDone"': '"' + isDone.toString() + '"',
      '"executors"': json.encode(executors),
      '"images"': json.encode(images),
    };
    if (deadline != null) {
      map.putIfAbsent('"deadline"', () => '"' + deadline.toString() + '"');
    }
    if (startAt != null) {
      map.putIfAbsent('"startAt"', () => '"' + startAt.toString() + '"');
    }
    if (doneAt != null) {
      map.putIfAbsent('"doneAt"', () => '"' + doneAt.toString() + '"');
    }
    if (storyPoint != null) {
      map.putIfAbsent('"storyPoint"', () => '"' + storyPoint.toString() + '"');
    }
    return map;
  }

  factory BoardItemObject.fromJson(Map<String, dynamic> myJson) {
    return BoardItemObject(
      myJson['id'],
      myJson['title'],
      myJson['description'],
      int.parse(myJson['position']),
      DateTime.parse(myJson['createdAt']),
      myJson['isDone'] == "true",
      List<dynamic>.from(myJson['executors']),
      (myJson.containsKey('deadline'))
          ? DateTime.parse(myJson['deadline'])
          : null,
      (myJson.containsKey('startAt'))
          ? DateTime.parse(myJson['startAt'])
          : null,
      (myJson.containsKey('doneAt')) ? DateTime.parse(myJson['doneAt']) : null,
      (myJson.containsKey('storyPoint'))
          ? double.parse(myJson['storyPoint'])
          : null,
      List<dynamic>.from(myJson['executors']),
    );
  }

  void setDeadline(DateTime deadline) {
    this.deadline = deadline;
  }

  void setStartAt(DateTime startAt) {
    this.startAt = startAt;
  }

  void setDoneAt(DateTime doneAt) {
    this.doneAt = doneAt;
  }
}
