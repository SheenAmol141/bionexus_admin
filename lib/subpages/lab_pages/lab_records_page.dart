import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/subpages/lab_pages/lab_specimen_requests_page.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LabRecordsPage extends StatefulWidget {
  const LabRecordsPage({super.key});

  @override
  State<LabRecordsPage> createState() => _LabRecordsPageState();
}

class _LabRecordsPageState extends State<LabRecordsPage> {
  String teamCode = '';
  bool load = false;
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
  void initState() {
    super.initState();
    getTeams();
  }

  @override
  Widget build(BuildContext context) {
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
                        .orderBy("time")
                        .snapshots(),
                    builder: (context, snapshot) {
                      try {
                        List<DocumentSnapshot> docs = [];
                        for (DocumentSnapshot doc
                            in snapshot.data!.docs.reversed.toList()) {
                          if (doc["all_done"]) {
                            docs.add(doc);
                          }
                        }

                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  DocumentSnapshot currentdoc = docs[index];
                                  LabSpecimenRequest currentreq =
                                      LabSpecimenRequest(
                                          name: currentdoc["name"],
                                          requestedLab:
                                              currentdoc["requested_lab"],
                                          info: currentdoc["info"],
                                          usePatient: currentdoc["use_patient"],
                                          time: currentdoc["time"].toDate());
                                  return CardTemplate(
                                      child: Column(
                                    children: [
                                      SectionTitlesTemplate(currentreq.name),
                                      Divider(),
                                      Text("Requested Documents"),
                                      Text(
                                        currentreq.requestedLab,
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17),
                                      ),
                                      Divider(),
                                      Text("Time Requested"),
                                      Text(
                                        "${DateFormat("MMMM dd, yyyy").format(currentreq.time)} - ${DateFormat.jm().format(currentreq.time)}",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17),
                                      ),
                                      Divider(),
                                      Container(
                                        child: currentreq.info.isNotEmpty
                                            ? Column(
                                                children: [
                                                  Text("Additional Info"),
                                                  Text(
                                                    currentreq.info,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 17),
                                                  ),
                                                  Divider(),
                                                ],
                                              )
                                            : null,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) {
                                                return RequestDetailsPage(
                                                    currentDoc: currentdoc,
                                                    teamCode: teamCode);
                                              },
                                            ));
                                          },
                                          child: Text("View Request Details")),
                                    ],
                                  ));
                                },
                                separatorBuilder: (context, index) => SizedBox(
                                      height: 20,
                                    ),
                                itemCount: docs.length),
                          ),
                        );
                      } catch (e) {
                        return Center(
                          child: CircularProgressIndicator(color: AERO),
                        );
                      }
                    },
                  )
                : Container()));
  }
}
