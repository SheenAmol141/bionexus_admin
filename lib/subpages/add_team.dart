import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTeam extends StatefulWidget {
  const AddTeam({super.key});

  @override
  State<AddTeam> createState() => _AddTeamState();
}

class _AddTeamState extends State<AddTeam> {
  TextEditingController _teamIdController = TextEditingController();
  bool root = false;

  void isRoot() {
    bool hasteam = false;
    final email = FirebaseAuth.instance.currentUser!.email;
    String team = "";

    FirebaseFirestore.instance
        .collection("Users")
        .doc(email)
        .get()
        .then((value) {
      if (value["team-license"] != null) {
        hasteam = true;
      }
    }).then((value) {
      if (hasteam) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(email)
            .get()
            .then((value) => team = value["team-license"])
            .then((value) {
          FirebaseFirestore.instance
              .collection("Teams")
              .doc(team)
              .get()
              .then((value) {
            if (value["root-user"] == email) {
              setState(() {
                root = true;
              });
            }
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isRoot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "TEAM",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "montserrat",
              fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: EMERALD,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Create or Join a team:',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Handle "Create a new team" button press
                    if (root) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "You are the root user of this team and cannot create a new team.")));
                    } else {
                      createTeam(context);
                    }
                  },
                  child: Text('Create a new team'),
                ),
              ],
            ),
            SizedBox(height: 40.0),
            TextField(
              controller: _teamIdController,
              decoration: const InputDecoration(
                hintText: 'Insert Team ID here',
              ),
            ),
            SizedBox(height: 10.0),
            OutlinedButton(
              onPressed: () {
                // Handle "Join an existing team" button with Team ID press
                final teamId = _teamIdController.text;
                if (root) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "You are the root user of this team and cannot join another team.")));
                } else {
                  joinTeam(teamId, context);
                }
                // Use the team ID to join the team (logic not shown here)
              },
              child: const Text('Join with Team ID'),
            ),
          ],
        ),
      ),
    );
  }
}
