import 'dart:js';

import 'package:bionexus_admin/subpages/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

void createTeam(context) {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String email = FirebaseAuth.instance.currentUser!.email!;
  FirebaseFirestore.instance
      .collection("Teams")
      .doc(uid)
      .set({"root-user": email});
  FirebaseFirestore.instance
      .collection("Users")
      .doc(email)
      .update({"team-license": uid})
      .then((value) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Created team successfuly"))))
      .then((value) => Future.delayed(const Duration(microseconds: 350), () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MainScreen()));
          }));
}

void joinTeam(String team_code, context) {
  String email = FirebaseAuth.instance.currentUser!.email!;
  final team_check =
      FirebaseFirestore.instance.collection("Teams").doc(team_code);

  team_check.get().then((snapshot) {
    if (snapshot.exists) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(email)
          .update({"team-license": team_code})
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Joined team successfuly"))))
          .then(
              (value) => Future.delayed(const Duration(microseconds: 350), () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MainScreen()));
                  }));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid Team ID")));
    }
  });
}

logout(context) {
  FirebaseAuth.instance.signOut();
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));

  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text("Logged out successfully"),
    duration: Duration(milliseconds: 500),
  ));
}
