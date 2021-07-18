
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePagination{
  Future<List<DocumentSnapshot>> fetchFirstList() async {
    return (await FirebaseFirestore.instance
            .collection("timeline")
            .doc("today")
            .collection("posts")
            .orderBy("timestamp",descending: true)
            .limit(30)
            .get()).docs;
  }

  Future<List<DocumentSnapshot>> fetchNextList(
      List<DocumentSnapshot> documentList) async {
    return (await FirebaseFirestore.instance
        .collection("timeline")
        .doc("today")
        .collection("posts")
        .orderBy("timestamp",descending: true)
        .startAfterDocument(documentList[documentList.length-1])
        .limit(30)
        .get()).docs;
  }

}

