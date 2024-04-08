import 'package:cloud_firestore/cloud_firestore.dart';

bool checkAdmin(String email) {
  final _db = FirebaseFirestore.instance;
  _db.collection("Admins").doc(email);


  return true;
}


Future<bool> doesAdminExist(String email) async {
  try {
    final docRef = FirebaseFirestore.instance.collection("Admins").doc(email);
    final snapshot = await docRef.get();
    return snapshot.exists;
  } catch (e) {
    // Handle potential errors (e.g., network issues)
    print(e.toString());
    return false; // Or return null to indicate an error
  }
}