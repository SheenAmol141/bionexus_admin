import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/subpages/handle_roles_page.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

String teamCode = '';

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
            .then((value) {
          team = value["team-license"];
          teamCode = value["team-license"];
        }).then((value) {
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
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Change team card
              TeamCard(teamID: teamID, root: root),
              SizedBox(
                height: 20,
              ),
              Container(child: root ? ManageTeamMembersCard() : null),
              SizedBox(
                height: root ? 20 : 0,
              ),
              RateCard()
            ],
          ),
        ),
      ),
    );
  }
}

class RateCard extends StatelessWidget {
  double rate = 3;
  final key = GlobalKey<FormState>();
  final controller = TextEditingController();
  RateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardTemplate(
        child: Column(
      children: [
        SectionTitlesTemplate("Care to rate our Service?"),
        Form(
            key: key,
            child: Column(
              children: [
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    rate = rating;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  maxLines: null,
                  minLines: 3,
                  controller: controller,
                  decoration: InputDecoration(label: Text("Description")),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Name must not be empty!";
                    } else if (value.length < 3) {
                      return "Name must not be less than 3 characters!";
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Upload Rating?"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel")),
                              TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection("Teams")
                                        .doc(teamCode)
                                        .update({
                                      "rating_num": rate,
                                      "rating_desc": controller.text,
                                      "rated": true
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text("Confirm"))
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Upload Rating"))
              ],
            )),
      ],
    ));
  }
}

class ManageTeamMembersCard extends StatefulWidget {
  const ManageTeamMembersCard({super.key});

  @override
  State<ManageTeamMembersCard> createState() => _ManageTeamMembersCardState();
}

class _ManageTeamMembersCardState extends State<ManageTeamMembersCard> {
// variables ------------------------------------------------
  Container manageWidget = Container(child: Text("loaded success"));
  bool loaded = false;
  String teamCode = '';
  String email = FirebaseAuth.instance.currentUser!.email!;
  List<dynamic> members = [];

  List<MemberSettingsTemplate> memberList = [];

//functions ------------------------------------------------
  loadManageWidget() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(email)
        .get()
        .then((value) =>
            teamCode = value["team-license"]) // INIT TEAMCODE OF ROOT
        .then((value) => FirebaseFirestore.instance
            .collection("Teams")
            .doc(teamCode)
            .get()
            .then((value) => members = value["members"])) // INIT MEMBER LIST
        .then((value) {
      members.remove(email); //remove root from list

      for (var member in members) {
        memberList.add(MemberSettingsTemplate(member: member));
      }

      print("Tabs create done");

      manageWidget = Container(
        child: Column(
          children: [...memberList, Divider()],
        ),
      );
      setState(() {
        loaded = true;
      });
    });
  }

  // INIT STATE ------------------------------------------------
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadManageWidget();
  }

  // BUILD METHOD ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CardTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitlesTemplate("Manage Your Team"),
          SizedBox(
            height: 20,
          ),
          Container(
            child: loaded
                ? manageWidget
                : Center(
                    child: CircularProgressIndicator(
                      color: AERO,
                    ),
                  ),
          )
        ],
      ),
    );
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
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    changeTeam(context);
                  },
                  child: const Text("Change Team")),
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
            ],
          )
        ],
      ),
    );
  }
}
