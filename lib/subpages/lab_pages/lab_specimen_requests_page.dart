import 'dart:io';

import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/subpages/settings_page.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LabSpecimenRequestsPage extends StatefulWidget {
  const LabSpecimenRequestsPage({super.key});

  @override
  State<LabSpecimenRequestsPage> createState() =>
      _LabSpecimenRequestsPageState();
}

class _LabSpecimenRequestsPageState extends State<LabSpecimenRequestsPage> {
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
                          if (!doc["all_done"]) {
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
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection("Teams")
                                                .doc(teamCode)
                                                .collection(
                                                    "Lab Specimen Requests")
                                                .doc(currentdoc.id)
                                                .update({
                                              'all_done': true
                                            }).then((value) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Request marked as Fullfilled!")));
                                            });
                                          },
                                          child: Text(
                                              "Mark Request as Fullfilled")),
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
  bool noPatient = false;
  String currentselectedpatient = '';

  setfirst() {
    FirebaseFirestore.instance
        .collection("Teams")
        .doc(widget.teamCode)
        .collection("Patients")
        .get()
        .then((value) {
      setState(() {
        try {
          currentselectedpatient = value.docs.reversed.toList().first["name"];
        } catch (e) {
          noPatient = true;
          usePatient = false;
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setfirst();
  }

  @override
  Widget build(BuildContext context) {
    final specReqKey = GlobalKey<FormState>();
    final falsePatientKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final infoController = TextEditingController();
    final requestedController = TextEditingController();

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: EMERALD,
          title: Text("Add a Specimen Request"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            Container(
                              child: noPatient
                                  ? Container()
                                  : Checkbox(
                                      value: usePatient,
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            usePatient = value!;
                                          },
                                        );
                                      },
                                    ),
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
                    Container(
                      child: usePatient
                          ? StatefulBuilder(
                              builder: (context, setStateRequest) {
                                print(widget.teamCode);
                                return StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("Teams")
                                      .doc(widget.teamCode)
                                      .collection("Patients")
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    try {
                                      List<DropdownMenuItem> dropitems = [];
                                      // snapshot.data!.docs.reversed.toList().first["name"];
                                      for (DocumentSnapshot doc in snapshot
                                          .data!.docs.reversed
                                          .toList()) {
                                        print(doc["name"]);
                                        dropitems.add(DropdownMenuItem(
                                          value: doc["name"],
                                          child: Text(doc["name"]),
                                        ));
                                      }

                                      print(dropitems);
                                      return DropdownButton(
                                        isExpanded: true,
                                        value: currentselectedpatient,
                                        items: dropitems,
                                        onChanged: (value) {
                                          setStateRequest(
                                            () {
                                              currentselectedpatient = value;
                                            },
                                          );
                                        },
                                      );
                                    } catch (e) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: AERO,
                                        ),
                                      );
                                    }
                                  },
                                );
                                // return Container();
                              },
                            )
                          : Form(
                              key: falsePatientKey,
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "This field must not be empty!";
                                  } else if (value.length < 3) {
                                    return "Characters must not be less than 3";
                                  }
                                },
                                controller: nameController,
                                maxLines: null,
                                decoration: InputDecoration(
                                    label: Text("Patient Name")),
                              ),
                            ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CardTemplate(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitlesTemplate("Request Details"),
                    SizedBox(
                      height: 20,
                    ),
                    Form(
                        key: specReqKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field must not be empty!";
                                } else if (value.length < 3) {
                                  return "Characters must not be less than 3";
                                }
                              },
                              controller: requestedController,
                              maxLines: null,
                              decoration: InputDecoration(
                                  label: Text(
                                      "Requested Documents (separate with a comma)")),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              validator: (value) {},
                              controller: infoController,
                              maxLines: null,
                              minLines: 3,
                              decoration: InputDecoration(
                                  label: Text("Additional Information")),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (usePatient) {
                      if (specReqKey.currentState!.validate()) {
                        LabSpecimenRequest request = LabSpecimenRequest(
                            time: DateTime.now(),
                            name: currentselectedpatient,
                            requestedLab: requestedController.text,
                            info: infoController.text,
                            usePatient: true);
                        showDialog(
                          context: context,
                          builder: (context) {
                            // FirebaseFirestore.instance.collection("Teams").doc(widget.teamCode).collection("Lab Specimen Requests").add({""});
                            return AlertDialog(
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
                                          .doc(widget.teamCode)
                                          .collection("Lab Specimen Requests")
                                          .add({
                                        "name": request.name,
                                        "requested_lab": request.requestedLab,
                                        "info": request.info,
                                        "use_patient": request.usePatient,
                                        "all_done": false,
                                        "time": request.time,
                                      }).then((value) {
                                        Navigator.pop(context);
                                        Navigator.pop(widget.scafcon);
                                        ScaffoldMessenger.of(widget.scafcon)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Pushed request successfully!")));
                                      });
                                    },
                                    child: Text("Confirm"))
                              ],
                              title: Text(
                                "Confirm Request?",
                                style: GoogleFonts.montserrat(
                                    fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            );
                          },
                        );
                      }
                    } else {
                      if (specReqKey.currentState!.validate() &&
                          falsePatientKey.currentState!.validate()) {
                        LabSpecimenRequest request = LabSpecimenRequest(
                            time: DateTime.now(),
                            name: nameController.text,
                            requestedLab: requestedController.text,
                            info: infoController.text,
                            usePatient: false);
                        showDialog(
                          context: context,
                          builder: (context) {
                            // FirebaseFirestore.instance.collection("Teams").doc(widget.teamCode).collection("Lab Specimen Requests").add({""});
                            return AlertDialog(
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
                                          .doc(widget.teamCode)
                                          .collection("Lab Specimen Requests")
                                          .add({
                                        "name": request.name,
                                        "requested_lab": request.requestedLab,
                                        "info": request.info,
                                        "use_patient": request.usePatient,
                                        "all_done": request.allDone,
                                        "time": request.time,
                                      }).then((value) {
                                        Navigator.pop(context);
                                        Navigator.pop(widget.scafcon);
                                        ScaffoldMessenger.of(widget.scafcon)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Pushed request successfully!")));
                                      });
                                    },
                                    child: Text("Confirm"))
                              ],
                              title: Text(
                                "Confirm Request?",
                                style: GoogleFonts.montserrat(
                                    fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text("Add Request")),
            ],
          ),
        ));
  }
}

class RequestDetailsPage extends StatelessWidget {
  RequestDetailsPage(
      {super.key, required this.currentDoc, required this.teamCode});
  DocumentSnapshot currentDoc;
  String teamCode;
  @override
  Widget build(BuildContext context) {
    LabSpecimenRequest currentreq = LabSpecimenRequest(
        name: currentDoc["name"],
        requestedLab: currentDoc["requested_lab"],
        info: currentDoc["info"],
        usePatient: currentDoc["use_patient"],
        time: currentDoc["time"].toDate());
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CardTemplate(
                  // initial details
                  child: Column(
                children: [
                  SectionTitlesTemplate(currentreq.name),
                  Divider(),
                  Text("Requested Documents"),
                  Text(
                    currentreq.requestedLab,
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500, fontSize: 17),
                  ),
                  Divider(),
                  Text("Time Requested"),
                  Text(
                    "${DateFormat("MMMM dd, yyyy").format(currentreq.time)} - ${DateFormat.jm().format(currentreq.time)}",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500, fontSize: 17),
                  ),
                  Divider(),
                  Container(
                    child: currentreq.info.isNotEmpty
                        ? Column(
                            children: [
                              Text("Additional Info"),
                              Text(
                                currentreq.info,
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500, fontSize: 17),
                              ),
                            ],
                          )
                        : null,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )),
              SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Teams")
                    .doc(teamCode)
                    .collection("Lab Specimen Requests")
                    .doc(currentDoc.id)
                    .collection("Specimens")
                    .orderBy("time")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    print("nodata");
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator(color: AERO),
                      ),
                    );
                  } else {
                    print("ye");
                    List<SingleRequest> requests = [];
                    for (DocumentSnapshot doc
                        in snapshot.data!.docs.reversed.toList()) {
                      requests.add(SingleRequest(
                          doc["download_url"], doc["name"], doc["time"]));
                    }
                    return Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => SizedBox(
                            height: 20,
                          ),
                          itemBuilder: (context, index) {
                            return CardTemplate(
                                child: Column(
                              children: [
                                SectionTitlesTemplate(requests[index].name),
                                Divider(),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Time Added:",
                                      ),
                                      Text(
                                        requests[index].time,
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w600),
                                      )
                                    ]),
                                Divider(),
                                Image.network(requests[index].download)
                              ],
                            ));
                          },
                          itemCount: requests.length,
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    );
                  }
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return AddDocumentForm(context,
                            doc: currentDoc.id,
                            name: currentreq.name,
                            teamCode: teamCode,
                            time: currentreq.time.toString());
                      },
                    ));
                  },
                  child: Text("Upload Specimen Document"))
            ],
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: EMERALD,
        title: const Text("View Request"),
      ),
    );
  }
}

class AddDocumentForm extends StatefulWidget {
  BuildContext scafcon;
  String name;
  String teamCode;
  String time;
  String doc;
  AddDocumentForm(this.scafcon,
      {super.key,
      required this.doc,
      required this.name,
      required this.teamCode,
      required this.time});

  @override
  State<AddDocumentForm> createState() => _AddDocumentFormState();
}

class _AddDocumentFormState extends State<AddDocumentForm> {
  @override
  void initState() {
    // TODO: implement initState
  }

  PlatformFile? docimage;
  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<FormState>();
    final controller = TextEditingController();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
              key: key,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Document name should not be empty!";
                      } else if (value.length < 3) {
                        return "Document name should not be less than 3 characters!";
                      }
                    },
                    decoration: InputDecoration(
                      label: Text("Document Name"),
                    ),
                    controller: controller,
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
                                title: Text(docimage != null
                                    ? "Change Upload Document Image?"
                                    : "Upload Upload Document Image"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel",
                                          style: GoogleFonts.montserrat(
                                              color: AERO))),
                                  TextButton(
                                      onPressed: () {
                                        // upload from here
                                        Navigator.pop(context);
                                        pickFile();
                                      },
                                      child: Text(
                                        "Upload Image from Device Storage",
                                        style:
                                            GoogleFonts.montserrat(color: AERO),
                                      ))
                                ],
                              );
                            });
                      },
                      child: Text(docimage != null
                          ? "Change Upload Document Image?"
                          : "Upload Document Image")),
                  docimage != null
                      ? Column(
                          children: [
                            kIsWeb
                                ? Image.memory(docimage!.bytes!)
                                : Image.file(File(docimage!.path!)),
                            ElevatedButton(
                                onPressed: () async {
                                  if (key.currentState!.validate()) {
                                    FirebaseFirestore.instance
                                        .collection("Teams")
                                        .doc(widget.teamCode)
                                        .collection("Lab Specimen Requests")
                                        .doc(widget.doc)
                                        .collection("Specimens")
                                        .add({
                                      "time": DateTime.now(),
                                      "name": controller.text,
                                      "download_url": await uploadDocReq(
                                          docimage!, teamCode)
                                    }).then((value) {
                                      ScaffoldMessenger.of(widget.scafcon)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Document Added to Request Success")));
                                      Navigator.pop(context);
                                    });
                                  }
                                },
                                child:
                                    Text("Upload and Add Document to Request"))
                          ],
                        )
                      : Container(),
                  SizedBox(
                    height: 20,
                  ),
                ],
              )),
        ),
      ),
      appBar: AppBar(
        backgroundColor: EMERALD,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Add Document to Request"),
      ),
    );
  }

  pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to upload")));
      return;
    }
    final file = result.files.first;

    int sizeInBytes = file.size;
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > 0.5) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File should be less than 500KB")));
    } else {
      setState(() {
        docimage = file;
      });
    }
  }

  Future<String> uploadDocReq(PlatformFile imageFile, teamCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final fileName = '${imageFile.name}.${imageFile.extension}';
    final reference = FirebaseStorage.instance
        .ref()
        .child('doc')
        // .child('/$teamCode/document_requests/${widget.time}/${widget.name}/')
        .child(fileName);

    final bytes = await imageFile.bytes;
    final uploadTask = reference.putData(bytes!);

    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }
}
