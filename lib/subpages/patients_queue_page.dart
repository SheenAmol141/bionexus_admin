import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PatientsQueuePage extends StatefulWidget {
  const PatientsQueuePage({super.key});

  @override
  State<PatientsQueuePage> createState() => _PatientsQueuePageState();
}

class _PatientsQueuePageState extends State<PatientsQueuePage> {
  String teamCode = '';
  void getTeams() async {
    String team = await getTeam();
    setState(() {
      teamCode = team;
    });
  }

  Future<void> deleteAllDocsWithCursor() async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef =
        firestore.collection("Teams").doc(teamCode).collection("Queue");

    // Get the first document (or start at a specific document if needed)
    QuerySnapshot querySnapshot = await collectionRef.limit(1).get();

    while (!querySnapshot.docs.isEmpty) {
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Get the next batch of documents (if needed)
      querySnapshot = await collectionRef
          .startAfterDocument(querySnapshot.docs.last)
          .limit(1)
          .get();
    }

    print('All documents in collection deleted using cursor');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTeams();
  }

  @override
  Widget build(BuildContext context) {
    try {
      CollectionReference queueref = FirebaseFirestore.instance
          .collection("Teams")
          .doc(teamCode)
          .collection("Queue");
      return Scaffold(
        backgroundColor: CupertinoColors.extraLightBackgroundGray,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AERO,
          hoverColor: EMERALD,
          onPressed: () => {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddPatientQueuePage(context),
            ))
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: StreamBuilder(
          stream: queueref.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text("no data"),
              );
            } else {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AERO,
                  ),
                );
              } else {
                // RUN WHEN ALL GOOD
                List<DocumentSnapshot> _docs = [];
                List<PatientInQueue> _queue = [];
                for (DocumentSnapshot doc in snapshot.data!.docs.toList()) {
                  _docs.add(doc);
                  _queue.add(PatientInQueue(
                      name: doc["name"],
                      reason: doc["reason"],
                      time: doc["time"]));
                }
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return CardTemplate(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SectionTitlesTemplate(_queue[index].name),
                                      Expanded(child: Container()),
                                      SizedBox(
                                        width: 80,
                                      ),
                                      Expanded(child: Container()),
                                      Text("${index + 1}")
                                    ],
                                  ),
                                  Divider(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Reason for visit:",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(_queue[index].reason),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Time Added:",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Expanded(child: Container()),
                                          Text(
                                            "${DateFormat("MMMM dd, yyyy").format(_queue[index].time)} ${DateFormat.jm().format(_queue[index].time)}",
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                          onPressed: () async {
                                            final docRef =
                                                queueref.doc(_docs[index].id);
                                            await docRef.delete();
                                          },
                                          child: Text("Remove from Queue"))
                                    ],
                                  ),
                                ],
                              ));
                            },
                            separatorBuilder: (context, index) => SizedBox(
                                  height: 20,
                                ),
                            itemCount: _queue.length),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: _docs.length == 0
                              ? null
                              : ElevatedButton(
                                  onPressed: () {
                                    deleteAllDocsWithCursor();
                                  },
                                  child: Text("Clear Queue")),
                        )
                      ],
                    ),
                  ),
                );
              }
            }
          },
        ),
      );
    } catch (e) {
      return Center(
        child: CircularProgressIndicator(color: AERO),
      );
    }
  }
}

class AddPatientQueuePage extends StatelessWidget {
  AddPatientQueuePage(this.scafcon, {super.key});
  BuildContext scafcon;

  @override
  Widget build(BuildContext context) {
    final time = DateTime.now();
    final nameController = TextEditingController();
    final reasonController = TextEditingController();
    final queueKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: EMERALD,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Add Patient in Queue",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
        ),
      ),
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: SingleChildScrollView(
        child: Form(
            key: queueKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(label: Text("Name")),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Name must not be empty!";
                      } else if (value.length < 3) {
                        return "Name must not be less than 3!";
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    maxLines: null,
                    minLines: 3,
                    controller: reasonController,
                    decoration:
                        InputDecoration(label: Text("Reason for Visit")),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Reason must not be empty!";
                      } else if (value.length < 3) {
                        return "Reason must not be less than 3!";
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (queueKey.currentState!.validate()) {
                          FirebaseFirestore.instance
                              .collection("Teams")
                              .doc(await getTeam())
                              .collection("Queue")
                              .add({
                                "name": nameController.text,
                                "reason": reasonController.text,
                                "time": time
                              })
                              .then((value) => Navigator.pop(context))
                              .then((value) => ScaffoldMessenger.of(scafcon)
                                  .showSnackBar(const SnackBar(
                                      content: Text(
                                          "Patient Added to Queue Successfully"))));
                        }
                      },
                      child: const Text("Add Patient to Queue"))
                ],
              ),
            )),
      ),
    );
  }
}
