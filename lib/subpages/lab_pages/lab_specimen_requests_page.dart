import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class LabSpecimenRequestsPage extends StatefulWidget {
  const LabSpecimenRequestsPage({super.key});

  @override
  State<LabSpecimenRequestsPage> createState() =>
      _LabSpecimenRequestsPageState();
}

String teamCode = '';
bool load = false;

class _LabSpecimenRequestsPageState extends State<LabSpecimenRequestsPage> {
  void getTeams() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      setState(() {
        teamCode = value["team-license"];
        load = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    @override
    void initState() {
      super.initState();
      getTeams();
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddSpecimenRequestsPage(
                scafcon: context,
                teamCode: teamCode,
              ),
            ));
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: AERO,
          hoverColor: EMERALD,
        ),
        backgroundColor: CupertinoColors.extraLightBackgroundGray,
        body: Container(
            child: load
                ? StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Teams")
                        .doc(teamCode)
                        .collection("Lab Specimen Requests")
                        .snapshots(),
                    builder: (context, snapshot) {
                      return Center(
                          child: CircularProgressIndicator(
                        color: AERO,
                      ));
                    },
                  )
                : Container()));
  }
}

class AddSpecimenRequestsPage extends StatefulWidget {
  AddSpecimenRequestsPage({
    super.key,
    required this.teamCode,
    required this.scafcon,
  });
  BuildContext scafcon;
  String teamCode;

  @override
  State<AddSpecimenRequestsPage> createState() =>
      _AddSpecimenRequestsPageState();
}

class _AddSpecimenRequestsPageState extends State<AddSpecimenRequestsPage> {
  bool usePatient = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: EMERALD,
          title: Text("Add a Specimen Request"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CardTemplate(
                // SELECT PATIENT
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitlesTemplate("Select Patient"),
                    const SizedBox(
                      height: 10,
                    ),
                    StatefulBuilder(
                      builder: (context, setStateBox) {
                        return Row(
                          children: [
                            Checkbox(
                              value: usePatient,
                              onChanged: (value) {
                                setStateBox(
                                  () {
                                    usePatient = value!;
                                  },
                                );
                              },
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Existing Patient?"),
                          ],
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              StatefulBuilder(
                builder: (context, setStateRequest) {
                  return Container();
                },
              )
            ],
          ),
        ));
  }
}
