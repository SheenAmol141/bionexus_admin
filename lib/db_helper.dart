import 'package:bionexus_admin/subpages/add_team.dart';
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
  FirebaseFirestore.instance.collection("Teams").doc(uid).set({
    "root-user": email,
    "members": [email]
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
                  .set({"root-user": rootUser, "members": oldMembers}).then(
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
// ABOVE THIS IS FOR USER TEAM JOIN AND CREATE AND SWITCH -----------------------------------------------------------------------------------------------------------------------------------------------------