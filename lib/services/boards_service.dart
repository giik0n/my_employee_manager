import 'package:cloud_firestore/cloud_firestore.dart';

class BoardsService {
  final String id;

  BoardsService({this.id});

  CollectionReference boardsCollection =
      Firestore.instance.collection("allBoards");

  Stream<DocumentSnapshot> get getBoardTitle {
    return boardsCollection.document(id).snapshots();
  }
}
