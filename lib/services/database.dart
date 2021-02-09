import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_employee_manager/models/board.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});
  //collection reference
  final CollectionReference boardsCollection =
      Firestore.instance.collection("allBoards");
  final CollectionReference usersCollection =
      Firestore.instance.collection("Users");

  Future updateUserData(String email, List boards, String token) async {
    return await usersCollection.document(uid).setData({
      'name': "New user",
      'email': email,
      'token': token,
    });
  }

  List<Board> _boardsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      int wallpaper = null;
      if (doc.data.containsKey('wallpaper')) {
        wallpaper = doc.data['wallpaper'];
      }
      return Board(
        title: doc.data['title'],
        id: doc.documentID,
        createdBy: doc.data['created_by'],
        moderators: doc.data['moderators'],
        wallpaper: wallpaper,
      );
    }).toList();
  }

  Stream<List<Board>> get boards {
    return boardsCollection
        .where("members", arrayContains: uid)
        .snapshots()
        .map(_boardsFromSnapshot);
  }

  Future<void> addBoard(BuildContext context, String name, String id) {
    // Call the user's CollectionReference to add a new user
    return boardsCollection
        .add({
          'title': name,
          'created_by': id,
          'members': FieldValue.arrayUnion([id]), // Stokes and Sons
          'moderators': FieldValue.arrayUnion([id]), // Stokes and Sons
        })
        .then((value) => Navigator.pop(context))
        .catchError((error) => print("Failed to add user: $error"));
  }

  deleteBoard(String id) async {
    await boardsCollection
        .document(id)
        .collection('Lists')
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        await element.reference
            .collection("Tasks")
            .getDocuments()
            .then((value) {
          value.documents.forEach((element) {
            element.reference.delete();
          });
        });
        element.reference.delete();
      });
    });

    boardsCollection.document(id).delete();
  }

  updateBoardName(Board board, String text) {
    boardsCollection.document(board.id).updateData({"title": text});
  }
}
