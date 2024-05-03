import 'dart:io';
import 'dart:typed_data';

import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';

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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Create a team?"),
                            content: Text(
                                "To create a team, you will need to upload a picture of your BIR Registration Certificate of your Establishment."),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) {
                                        return ValidatePage();
                                      },
                                    ));
                                  },
                                  child: Text("Confirm"))
                            ],
                          );
                        },
                      );
                      // Navigator.of(context).push(MaterialPageRoute(builder: (context) {

                      // },));
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

class ValidatePage extends StatefulWidget {
  const ValidatePage({super.key});

  @override
  State<ValidatePage> createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  PlatformFile? certfile;
  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<FormState>();
    final controller = TextEditingController();
    return Material(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: EMERALD,
          title: Text(
            "TEAM",
            style: GoogleFonts.montserrat(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SectionTitlesTemplate("Create your team"),
                  Form(
                      key: key,
                      child: TextFormField(
                        controller: controller,
                        decoration:
                            InputDecoration(label: Text("Name of your Clinic")),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Name must not be empty!";
                          } else if (value.length < 3) {
                            return "Name must not be less than 3 characters!";
                          }
                        },
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  const Text("Upload BIR Certificate of Registration"),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  "Upload BIR Certificate of Registration"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      print("kweb: $kIsWeb");
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
                          },
                        );
                      },
                      icon: Icon(
                        Icons.upload_rounded,
                        color: AERO,
                      ),
                      label: Text("Upload File",
                          style: GoogleFonts.montserrat(color: AERO))),
                  SizedBox(
                    height: 20,
                  ),
                  certfile != null
                      ? Column(
                          children: [
                            kIsWeb
                                ? Image.memory(certfile!.bytes!)
                                : Image.file(File(certfile!.path!)),
                            ElevatedButton(
                                onPressed: () async {
                                  if (key.currentState!.validate()) {
                                    createTeam(
                                        context,
                                        await uploadCertificate(certfile!),
                                        controller.text);
                                  }
                                },
                                child: Text("Upload and create team"))
                          ],
                        )
                      : Container()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final file = result.files.first;
    setState(() {
      certfile = file;
    });
  }

  Future<String> uploadCertificate(PlatformFile imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final fileName = '${user.uid}.${imageFile.extension}';
    final reference =
        FirebaseStorage.instance.ref().child('Certificates').child(fileName);

    final bytes = await imageFile.bytes;
    final uploadTask = reference.putData(bytes!);

    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }
}
