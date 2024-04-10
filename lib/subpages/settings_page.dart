import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String teamID = "";

  getTeamID() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((snapshot) {
      setState(() {
        teamID = snapshot["team-license"];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getTeamID();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CardTemplate(
              // Change team card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitlesTemplate("Your Team ID"),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Team ID: $teamID",
                    style: GoogleFonts.montserrat(fontSize: 17),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        changeTeam(context);
                      },
                      child: const Text("Change"))
                ],
              ),
            ),
          ],
        ));
  }
}
