import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTeam extends StatefulWidget {
  const AddTeam({super.key});

  @override
  State<AddTeam> createState() => _AddTeamState();
}

void createTeam() {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String email = FirebaseAuth.instance.currentUser!.email!;
  FirebaseFirestore.instance
      .collection("Teams")
      .doc(uid)
      .set({"root-user": email});
  FirebaseFirestore.instance
      .collection("Users")
      .doc(email)
      .update({"team-license": uid});
}

class _AddTeamState extends State<AddTeam> {
  TextEditingController _teamIdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create or Join a Team'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
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
                    createTeam();
                  },
                  child: Text('Create a new team'),
                ),
              ],
            ),
            SizedBox(height: 40.0),
            TextField(
              controller: _teamIdController,
              decoration: InputDecoration(
                hintText: 'Insert Team ID here',
              ),
            ),
            SizedBox(height: 10.0),
            OutlinedButton(
              onPressed: () {
                // Handle "Join an existing team" button with Team ID press
                final teamId = _teamIdController.text;
                // Use the team ID to join the team (logic not shown here)
              },
              child: Text('Join with Team ID'),
            ),
          ],
        ),
      ),
    );
  }
}
