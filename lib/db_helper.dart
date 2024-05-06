import 'dart:async';
import 'dart:io';

import 'package:bionexus_admin/subpages/add_team.dart';
import 'package:bionexus_admin/subpages/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

void createTeam(context, path, name) {
  String clinicname = name;
  String certpath = path;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String email = FirebaseAuth.instance.currentUser!.email!;
  FirebaseFirestore.instance.collection("Teams").doc(uid).set({
    "clinic_name": clinicname,
    "root-user": email,
    "members": [email],
    "subscription_deadline": DateTime.now().add(const Duration(days: 14)),
    "in_trial": true,
    "verified": false,
    "certificate_url": certpath,
    "rated": false,
    "rating_desc": '',
    "rating_num": 5
  });
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

void joinTeam(String teamCode, context) {
  String email = FirebaseAuth.instance.currentUser!.email!;
  final team_check =
      FirebaseFirestore.instance.collection("Teams").doc(teamCode);

  team_check.get().then((snapshot) {
    if (snapshot.exists) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(email)
          .get()
          .then((value) {
        if (value["team-license"] != null) {
//remove from old team

          String oldTeamCode = '';
          String rootUser = '';
          List<dynamic> oldMembers = [];
          FirebaseFirestore.instance
              .collection("Users")
              .doc(email)
              .get()
              .then((value) {
            //GET OLD CODE
            oldTeamCode = value["team-license"];
            print(oldTeamCode);
          }).then((value) {
            //
            FirebaseFirestore.instance
                .collection("Teams")
                .doc(oldTeamCode)
                .get()
                .then((value) {
              oldMembers = value['members'];
              rootUser = value["root-user"];

              oldMembers.remove(email);
              //member removed
            }).then((value) {
              //update to old team
              FirebaseFirestore.instance
                  .collection("Teams")
                  .doc(oldTeamCode)
                  .update({"root-user": rootUser, "members": oldMembers}).then(
                      (value) {
                //new team
                FirebaseFirestore.instance
                    .collection("Users")
                    .doc(email)
                    .update({"team-license": teamCode})
                    .then((value) {
                      team_check.get().then((value) {
                        final members = value["members"];
                        team_check.update({
                          "members": [...members, email]
                        });
                      });
                    })
                    .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Joined team successfuly"))))
                    .then((value) =>
                        Future.delayed(const Duration(microseconds: 350), () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainScreen()));
                        }));
              });
            });
          });

          //remove old team
        } else {
//new team
          FirebaseFirestore.instance
              .collection("Users")
              .doc(email)
              .update({"team-license": teamCode})
              .then((value) {
                team_check.get().then((value) {
                  final members = value["members"];
                  team_check.update({
                    "members": [...members, email]
                  });
                });
              })
              .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Joined team successfuly"))))
              .then((value) =>
                  Future.delayed(const Duration(microseconds: 350), () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MainScreen()));
                  }));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid Team ID")));
    }
  });
}

void logout(context) {
  FirebaseAuth.instance.signOut();
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));

  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text("Logged out successfully"),
    duration: Duration(milliseconds: 500),
  ));
}

void changeTeam(context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => AddTeam()));
}

Future<String> getTeam() async {
  return await FirebaseFirestore.instance
      .collection("Users")
      .doc(FirebaseAuth.instance.currentUser!.email)
      .get()
      .then((value) => value["team-license"]);
}

// ABOVE THIS IS FOR USER TEAM JOIN AND CREATE AND SWITCH -----------------------------------------------------------------------------------------------------------------------------------------------------

class TransactionItem {
  String itemName;
  int? numOfItems;
  String? description;
  double price;
  bool service;
  int? numBuying;

  TransactionItem(
      {required this.itemName,
      this.numOfItems,
      this.description,
      this.numBuying,
      required this.price,
      required this.service});

  ifService() {
    return service;
  }

  setNumBuying(count) {
    numBuying = count;
  }

  getService() {
    return {
      "item_name": itemName,
      "description": description,
      "price": price,
    };
  }

  getItem() {
    return {
      "item_name": itemName,
      "price": price,
      "buyNum": numBuying,
      "number_of_items": numOfItems
    };
  }
}

class PatientInQueue {
  String _name;
  String _reason;
  DateTime _time;
  PatientInQueue(
      {required String name, required String reason, required Timestamp time})
      : _name = name,
        _reason = reason,
        _time = time.toDate();

  String get reason => _reason;
  String get name => _name;
  DateTime get time => _time;
}

class LabSpecimenRequest {
  String _name;
  String _requestedLab;
  String _info;
  DateTime _time;
  bool _allDone = false;
  bool _usePatient;
  LabSpecimenRequest(
      {required String name,
      required String requestedLab,
      required String info,
      required bool usePatient,
      required DateTime time})
      : _name = name,
        _time = time,
        _usePatient = usePatient,
        _info = info,
        _requestedLab = requestedLab;

  setAllDone() {
    _allDone = true;
  }

  bool get usePatient => _usePatient;
  String get info => _info;
  String get requestedLab => _requestedLab;
  String get name => _name;
  DateTime get time => _time;
  bool get allDone => _allDone;
}

class Birthdate {
  final DateTime _birthDate;

  Birthdate(this._birthDate);

  String getFormattedDate() {
    return DateFormat('MMMM-dd-yyyy').format(_birthDate);
  }

  int getCurrentAge() {
    final now = DateTime.now();
    int age = now.year - _birthDate.year;
    // Check if birthday has passed in the current year
    if ((now.month < _birthDate.month) ||
        (now.month == _birthDate.month && now.day < _birthDate.day)) {
      age--;
    }
    return age;
  }
}

class SingleRequest {
  String _download, _name;
  Timestamp _time;
  SingleRequest(String download, String name, Timestamp time)
      : _download = download,
        _time = time,
        _name = name;

  String get download => _download;
  String get name => _name;
  String get time =>
      "${DateFormat("MMMM dd, yyyy").format(_time.toDate())} - ${DateFormat.jm().format(_time.toDate())}";
}
