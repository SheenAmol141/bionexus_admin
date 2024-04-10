import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/subpages/handle_roles_page.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

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
    // TODO: implement initState
    super.initState();

    getTeamID();
    isRoot();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Change team card
            TeamCard(teamID: teamID, root: root),
          ],
        ));
  }
}

class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.teamID,
    required this.root,
  });

  final String teamID;
  final bool root;

  @override
  Widget build(BuildContext context) {
    return CardTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitlesTemplate("Your Team ID"),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text(
                "Team ID: $teamID",
                style: GoogleFonts.montserrat(fontSize: 17),
              ),
              const SizedBox(
                width: 20,
              ),
              Container(
                child: root
                    ? ElevatedButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: teamID));
                          // Optional: Show a snackbar to indicate successful copy
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Team ID copied to clipboard!'),
                            ),
                          );
                        },
                        child: const Text('Copy Team ID'),
                      )
                    : null,
              ),
              Container(
                child: root
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HandleRolesPage()));
                        },
                        child: const Text('Copy Team ID'),
                      )
                    : null,
              )
            ],
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
    );
  }
}
