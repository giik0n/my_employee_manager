import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/board.dart';
import 'package:my_employee_manager/models/user.dart';

class BoardUsers with ChangeNotifier {
  List<User> users;
  String boardId;
  StreamSubscription subUsers;
  StreamSubscription subBoard;
  Board board;
  void initProviderListener(String id) {
    users = List<User>();
    boardId = id;
    CollectionReference reference = Firestore.instance.collection('allBoards');

    subUsers = reference.document(id).snapshots().listen((event) async {
      users.clear();
      await Future.forEach(event.data['members'], (element) async {
        DocumentSnapshot doc = await Firestore.instance
            .collection('Users')
            .document(element)
            .get();
        users.add(User(doc.documentID, doc.data['name'], doc.data['email'],
            doc.data['token']));
      });

      notifyListeners();
    });
  }

  void removeUserFromBoard(String id, String uid) async {
    users.clear();
    var element = [];
    element.add(uid);
    await Firestore.instance
        .collection('allBoards')
        .document(id)
        .updateData({'members': FieldValue.arrayRemove(element)});
  }

  Future<bool> addNewMember(String addMemberEmail) async {
    users.clear();
    QuerySnapshot _myDoc = await Firestore.instance
        .collection('Users')
        .where('email', isEqualTo: addMemberEmail)
        .getDocuments();

    var id = _myDoc.documents.first.documentID;
    if (id.length > 0) {
      await Firestore.instance
          .collection('allBoards')
          .document(boardId)
          .updateData({
        'members': FieldValue.arrayUnion([id]),
      });
      return true;
    } else {
      return false;
    }
  }

  void removeFromModerators(String uid) async {
    var elements = [uid];
    await Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .updateData({'moderators': FieldValue.arrayRemove(elements)});
  }

  void addToModerators(String uid) async {
    var elements = [uid];
    await Firestore.instance
        .collection('allBoards')
        .document(boardId)
        .updateData({'moderators': FieldValue.arrayUnion(elements)});
  }

  getBoardById(String id) {
    subBoard = Firestore.instance
        .collection('allBoards')
        .document(id)
        .snapshots()
        .listen((event) {
      board = Board(
          title: event.data['title'],
          id: event.documentID,
          createdBy: event.data['created_by'],
          moderators: event.data['moderators']);
    });
  }

  Future<List<User>> getUsersOfBoard(String id) async {
    List<User> boardUsers = [];
    DocumentSnapshot doc =
        await Firestore.instance.collection('allBoards').document(id).get();

    await Future.forEach(doc.data['members'], (element) async {
      DocumentSnapshot doc =
          await Firestore.instance.collection('Users').document(element).get();
      boardUsers.add(User(doc.documentID, doc.data['name'], doc.data['email'],
          doc.data['token']));
    });
    return boardUsers;
  }
}
