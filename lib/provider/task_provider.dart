import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_employee_manager/models/board_list.dart';
import 'package:my_employee_manager/models/board_item_object.dart';
import 'package:path/path.dart';

class TaskProvider with ChangeNotifier {
  String boardId;
  String listId;
  List<BoardListObject> itemsBoard = [];
  void initProviderListener(String id) {
    boardId = id;
    CollectionReference reference = Firestore.instance
        .collection('allBoards')
        .document(id)
        .collection("Lists");

    reference.orderBy('position').snapshots().listen((querySnapshot) async {
      itemsBoard.clear();
      await Future.forEach(querySnapshot.documents, (snapshot) async {
        var tmpBoardList = BoardListObject(
            id: snapshot.documentID,
            title: snapshot.data['list_name'],
            position: snapshot.data['position']);

        await taskList(snapshot, tmpBoardList);
        itemsBoard.add(tmpBoardList);
      });

      notifyListeners();
    });
  }

  Future<void> taskList(
      DocumentSnapshot snapshot, BoardListObject tmpBoardList) async {
    snapshot.reference
        .collection('Tasks')
        .orderBy('position')
        .snapshots()
        .listen((event) async {
      await tmpBoardList.items.clear();
      await Future.forEach(event.documents, (element) {
        DateTime deadline;
        DateTime startAt;
        DateTime doneAt;
        double storyPoint;
        if (element.data.containsKey("deadline")) {
          deadline = element.data['deadline'].toDate();
        }
        if (element.data.containsKey("startAt")) {
          startAt = element.data['startAt'].toDate();
        }
        if (element.data.containsKey("doneAt")) {
          doneAt = element.data['doneAt'].toDate();
        }
        if (element.data.containsKey("storyPoint")) {
          storyPoint = element.data['storyPoint'];
        }
        tmpBoardList.items.add(
          BoardItemObject(
            element.documentID,
            element.data['task_name'],
            element.data['task_description'],
            element.data['position'],
            element.data['createdAt'].toDate(),
            element.data['isDone'] ?? false,
            element.data.containsKey("executors")
                ? element.data['executors']
                : [""],
            deadline,
            startAt,
            doneAt,
            storyPoint,
            element.data.containsKey("images") ? element.data['images'] : null,
          ),
        );
      });

      notifyListeners();
    });

    // QuerySnapshot value =
    //     await change.reference.collection('Tasks').getDocuments();

    // value.documents.forEach((element) {
    //   tmpBoardList.items.add(BoardItemObject(element.data['task_name']));
    // });
    // print(tmpBoardList.toString());
    // itemsBoard.add(tmpBoardList);
  }

  void deleteList(String id) async {
    await Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(id)
        .collection("Tasks")
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.forEach((element) {
        element.reference.delete();
      });
    });
    await Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(id)
        .delete()
        .whenComplete(() {
      notifyListeners();
    });
  }

  addList(BuildContext context, String name, int i) {
    Map<String, dynamic> item = {
      'list_name': name,
      'position': i,
    };
    // Call the user's CollectionReference to add a new user
    return Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .add(item)
        .then((value) => Navigator.pop(context))
        .catchError((error) => print("Failed to add user: $error"));
  }

  addTask(BuildContext context, String listId, BoardItemObject task) async {
    Map<String, Object> item = {
      'task_name': task.title,
      'task_description': task.description,
      'position': task.position,
      'createdAt': DateTime.now(),
      'isDone': task.isDone,
      'executors': task.executors,
      'images': task.images,
    };
    if (task.deadline != null) {
      item.putIfAbsent('deadline', () => task.deadline);
    }
    if (task.startAt != null) {
      item.putIfAbsent('startAt', () => task.startAt);
    }
    if (task.doneAt != null) {
      item.putIfAbsent('doneAt', () => task.doneAt);
    }
    if (task.storyPoint != null) {
      item.putIfAbsent('storyPoint', () => task.storyPoint);
    }
    // Call the user's CollectionReference to add a new user
    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection("Tasks")
        .add(item)
        .then((value) {
      if (context != null) Navigator.pop(context);
    }).catchError((error) => print("Failed to add user: $error"));
  }

  updateTask(BuildContext context, String listId, BoardItemObject task) async {
    // Call the user's CollectionReference to add a new user
    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection("Tasks")
        .document(task.id)
        .updateData({
      'task_name': task.title,
      'task_description': task.description
    }).then((value) {
      if (context != null) Navigator.pop(context);
    }).catchError((error) => print("Failed to add user: $error"));
  }

  void updateListPositions(List<BoardListObject> boardItems) {
    Future.forEach(boardItems, (element) {
      Firestore.instance
          .collection('allBoards')
          .document(boardId)
          .collection("Lists")
          .document(element.id)
          .updateData({'position': boardItems.indexOf(element)});
    });
  }

  void updateListTasksPositions(List<BoardListObject> boardItems) {
    Future.forEach(boardItems, (list) async {
      await Future.forEach(list.items, (element) {
        Firestore.instance
            .collection('allBoards')
            .document(boardId)
            .collection('Lists')
            .document(list.id)
            .collection('Tasks')
            .document(element.id)
            .updateData({'position': list.items.indexOf(element)});
      });
    });
  }

  void removeTaskFromList(String listId, BoardItemObject task) async {
    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection('Tasks')
        .document(task.id)
        .delete();
  }

  void deleteTask(String listId, BoardItemObject task) async {
    if (task.images != null && task.images.length > 0) {
      for (var i = 0; i < task.images.length; i++) {
        FirebaseStorage.instance
            .getReferenceFromUrl(task.images[i])
            .then((value) {
          value.delete();
        });
      }
    }

    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection('Tasks')
        .document(task.id)
        .delete();
  }

  void addTaskToList(String listId, BoardItemObject task) async {
    Map<String, Object> item = {
      'task_name': task.title,
      'task_description': task.description,
      'position': task.position,
      'createdAt': task.createdAt,
      if (task.deadline != null) 'deadline': task.deadline,
      if (task.startAt != null) 'startAt': task.startAt,
      if (task.doneAt != null) 'doneAt': task.doneAt,
      if (task.storyPoint != null) 'storyPoint': task.storyPoint,
      'isDone': task.isDone,
      'executors': task.executors,
      'images': task.images,
    };
    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection('Tasks')
        .document(task.id)
        .setData(item)
        .then((value) {
      //notifyListeners();
    });
  }

  addDeadLineToTask(
      BuildContext context, String listId, BoardItemObject task) async {
    // Call the user's CollectionReference to add a new user
    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection("Tasks")
        .document(task.id)
        .updateData({'deadline': task.deadline}).then((value) {
      notifyListeners();
    });
  }

  Future deleteDeadline(String listId, BoardItemObject task) async {
    await Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection("Tasks")
        .document(task.id)
        .updateData({'deadline': FieldValue.delete()}).then((value) {
      notifyListeners();
    });
  }

  void updateDatabaseTasks() async {
    QuerySnapshot boards =
        await Firestore.instance.collection('allBoards').getDocuments();
    Future.forEach(boards.documents, (element) async {
      QuerySnapshot boardLists = await Firestore.instance
          .collection('allBoards')
          .document(element.documentID)
          .collection('Lists')
          .getDocuments();
      Future.forEach(boardLists.documents, (element1) async {
        QuerySnapshot tasks = await Firestore.instance
            .collection('allBoards')
            .document(element.documentID)
            .collection('Lists')
            .document(element1.documentID)
            .collection('Tasks')
            .getDocuments();

        Future.forEach(tasks.documents, (element2) {
          Firestore.instance
              .collection('allBoards')
              .document(element.documentID)
              .collection('Lists')
              .document(element1.documentID)
              .collection('Tasks')
              .document(element2.documentID)
              .updateData({'executors': FieldValue.arrayUnion([])});
        });
      });
    });
  }

  void isDoneUpdate(String listId, BoardItemObject task) {
    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection('Lists')
        .document(listId)
        .collection('Tasks')
        .document(task.id)
        .updateData({'isDone': task.isDone});
  }

  void setStartAt(String boardId, String listId, BoardItemObject task) {
    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection("Tasks")
        .document(task.id)
        .updateData({'startAt': task.startAt});
  }

  void setDoneAt(String id, String listId, BoardItemObject task) {
    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection("Tasks")
        .document(task.id)
        .updateData({'doneAt': task.doneAt});
  }

  Future deletestartAt(String listId, BoardItemObject task) async {
    await Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection("Tasks")
        .document(task.id)
        .updateData({'startAt': FieldValue.delete()}).then((value) {
      notifyListeners();
    });
  }

  Future deleteDoneAt(String listId, BoardItemObject task) async {
    await Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection("Tasks")
        .document(task.id)
        .updateData({'doneAt': FieldValue.delete()}).then((value) {
      notifyListeners();
    });
  }

  Future setStoryPoint(
      String listId, BoardItemObject task, double storyPoint) async {
    return await Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection("Tasks")
        .document(task.id)
        .updateData({'storyPoint': storyPoint})
        .then((value) => true)
        .catchError((error) => false);
  }

  void deleteStoryPoint(String listId, BoardItemObject task) {
    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection("Lists")
        .document(listId)
        .collection("Tasks")
        .document(task.id)
        .updateData({'storyPoint': FieldValue.delete()});
  }

  Future<bool> pushImageToTask(PickedFile file, String listId,
      BoardItemObject task, context, Function update) async {
    showProgressDialog(context: context, loadingText: "Loading");
    StorageReference storageReference = FirebaseStorage.instance.ref();
    StorageReference ref = storageReference.child("task_images/");
    StorageUploadTask storageUploadTask =
        ref.child(basename(file.path)).putFile(File(file.path));
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    await taskSnapshot.ref.getDownloadURL().then((value) async {
      if (task.images == null) {
        task.images = List<dynamic>();
      }
      task.images.add(value);
      await Firestore.instance
          .collection('allBoards')
          .document(boardId)
          .collection('Lists')
          .document(listId)
          .collection('Tasks')
          .document(task.id)
          .updateData({
        'images': FieldValue.arrayUnion([value])
      });
      //update(() {});
      dismissProgressDialog();
    });
    return true;
  }

  void deleteImageFromTask(
      String listId, BoardItemObject itemObject, int index) async {
    Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .collection('Lists')
        .document(listId)
        .collection('Tasks')
        .document(itemObject.id)
        .updateData({
      'images': FieldValue.arrayRemove([itemObject.images[index]])
    });

    FirebaseStorage.instance
        .getReferenceFromUrl(itemObject.images[index])
        .then((value) {
      value.delete();
    });
  }
}
