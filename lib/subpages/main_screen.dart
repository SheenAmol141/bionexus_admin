// ignore_for_file: prefer_const_constructors
import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/subpages/add_team.dart';
import 'package:bionexus_admin/subpages/fitted_video.dart';
import 'package:bionexus_admin/subpages/inventory_page.dart';
import 'package:bionexus_admin/subpages/lab_pages/lab_records_page.dart';
import 'package:bionexus_admin/subpages/lab_pages/lab_specimen_requests_page.dart';
import 'package:bionexus_admin/subpages/onboarding_screen.dart';
import 'package:bionexus_admin/subpages/patient_records/patient_records_page.dart';
import 'package:bionexus_admin/subpages/patients_queue_page.dart';
import 'package:bionexus_admin/subpages/services_page.dart';
import 'package:bionexus_admin/subpages/settings_page.dart';
import 'package:bionexus_admin/subpages/transactional_processing_system_page.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_content.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isAdmin = false;
  bool loaded = false;
  bool noTeam = false;
  bool lateSubscription = false;
  bool nearSubscription = false;
  String teamCode = '';
  int daysnear = 0;
  bool verified = false;

  String clinic = '';
  void isItLate() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      teamCode = value["team-license"];
    }).then((value) {
      FirebaseFirestore.instance
          .collection("Teams")
          .doc(teamCode)
          .get()
          .then((value) {
        if (value["verified"]) {
          setState(() {
            verified = true;
            clinic = value["clinic_name"];
          });
        }
        if (value["subscription_deadline"]
                .toDate()
                .difference(DateTime.now())
                .inDays <
            0) {
          print(lateSubscription);
          setState(() {
            lateSubscription = true;
          });
        }
      });
    });
  }

  void isItNear() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      teamCode = value["team-license"];
    }).then((value) {
      FirebaseFirestore.instance
          .collection("Teams")
          .doc(teamCode)
          .get()
          .then((value) {
        daysnear = value["subscription_deadline"]
            .toDate()
            .difference(DateTime.now())
            .inDays;
        if (daysnear <= 7) {
          print(nearSubscription);
          setState(() {
            nearSubscription = true;
          });
        }
      });
    });
  }

  void isitAdmin() {
    String email = FirebaseAuth.instance.currentUser!.email!;
    late FirebaseFirestore db = FirebaseFirestore.instance;

    db.collection("Admins").doc(email).get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          isAdmin = true;
        });
      }
      setState(() {
        loaded = true;
      });
    }).then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Signed in"),
          duration: Duration(milliseconds: 500),
        )));
  }

  void isitinTeam() {
    String email = FirebaseAuth.instance.currentUser!.email!;
    late FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("Users").doc(email).get().then((snapshot) {
      print(snapshot["team-license"]);
      if (snapshot["team-license"] == null) {
        print("teamlicense is null");
        setState(() {
          noTeam = true;
        });
      } else {
        isItLate();
        isItNear();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      isitAdmin();
      isitinTeam();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null
        ? loaded
            ? isAdmin
                ? AdminContent()
                : lateSubscription
                    ? LateSubscription()
                    : nearSubscription
                        ? Scaffold(
                            body: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SectionTitlesTemplate(
                                        "Your team's Due Date for payment is ${daysnear == 1 ? "tomorrow" : daysnear == 0 ? "in less than a day" : "in $daysnear days"}. Please settle your payment to avoid losing access to your team"),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            nearSubscription = false;
                                          });
                                        },
                                        child: Text("Close")),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) {
                                              return Scaffold(
                                                body: Center(
                                                  child:
                                                      Text("Payment Details"),
                                                ),
                                              );
                                            },
                                          ));
                                        },
                                        child: Text("Proceed to Payment"))
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ClientContent(
                            team: noTeam,
                            verified: verified,
                            clinic: clinic,
                          )
            : Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
        : Stack(
            // --------------------------------------------------------------------------------------------------- loginScreen

            children: [
              FittedVideo(),
              Opacity(
                opacity: .9,
                child: Container(
                  color: DARK_GREEN,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SizedBox(
                        //   height: 100,
                        // ),
                        SizedBox(
                            width: 420,
                            child: Image.asset("assets/bionexuslogo.png")),
                        // SizedBox(
                        //   height: 100,
                        // ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30))),
                            width: MediaQuery.of(context).size.width,
                            height: 400,
                            child: SignInScreen(providers: [
                              EmailAuthProvider(),
                            ], actions: [
                              AuthStateChangeAction<UserCreated>(
                                  (context, state) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Account created successfully"),
                                        duration: Duration(milliseconds: 500)));
                                isitAdmin();
                                isitinTeam();
                                FirebaseFirestore.instance
                                    .collection("Users")
                                    .doc(FirebaseAuth
                                        .instance.currentUser!.email)
                                    .set({
                                  "uid": FirebaseAuth.instance.currentUser!.uid,
                                  "team-license": null,
                                  "email":
                                      FirebaseAuth.instance.currentUser!.email,
                                  "Inventory": false,
                                  "Patient Records": false,
                                  "Patients Queue": false,
                                  "TPS": false,
                                  "Medical Services": false,
                                  "Lab Records": false,
                                  "Lab Specimen Requests": false,
                                });
                              }),
                              AuthStateChangeAction<SignedIn>((context, state) {
                                isitAdmin();
                                isitinTeam();
                              })
                            ]),
                          ),
                        ),
                        Container(
                          color: Colors.grey[350],
                          height: 1,
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: 400,
                                child: OutlinedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll(AERO),
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4))),
                                      side: MaterialStateProperty.all(
                                          BorderSide(
                                              color: Colors.white,
                                              width: 2,
                                              style: BorderStyle.solid)),
                                      padding: MaterialStatePropertyAll(
                                          EdgeInsets.symmetric(
                                              horizontal: 40, vertical: 20)),
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LandingPage()));
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Learn more about BioNexus",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                letterSpacing: 1,
                                                fontFamily: "montserrat",
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}

class LateSubscription extends StatelessWidget {
  const LateSubscription({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "Logout",
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AERO,
        onPressed: () {
          logout(context);
        },
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SectionTitlesTemplate(
                  "Your Subscription has not been paid. Please Pay to Access your Team"),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) {
                        return Scaffold(
                          body: Center(
                            child: Text("Payment Details"),
                          ),
                        );
                      },
                    ));
                  },
                  child: Text("Proceed to Payment"))
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ClientContent extends StatefulWidget {
  bool team;
  bool verified;
  String clinic;
  ClientContent(
      {super.key,
      required this.team,
      required this.verified,
      required this.clinic});

  @override
  State<ClientContent> createState() => _ClientContentState();
}

class _ClientContentState extends State<ClientContent> {
  bool loaded = false;
  late DocumentSnapshot userData;
  late DocumentSnapshot teamData;

  String currentPage = "";

  void getTeamData(teamcode) {
    FirebaseFirestore.instance
        .collection("Teams")
        .doc(teamcode)
        .get()
        .then((value) {
      setState(() {
        teamData = value;
      });
    });
  }

  void getUserData(String email) {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(email)
        .get()
        .then((value) {
      getTeamData(value["team-license"]);
      setState(() {
        userData = value;
        loaded = true;
      });
      ;
    });
  }

  void changePage(page) {
    if (teamData["root-user"] == userData["email"]) {
      if (currentPage == page) {
      } else {
        setState(() {
          currentPage = page;
        });
      }
    } else if (userData[page]) {
      if (currentPage == page) {
      } else {
        setState(() {
          currentPage = page;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You do you have permission to view $page")));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData(FirebaseAuth.instance.currentUser!.email!);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _text = TextStyle(color: Colors.white);
    TextStyle _listText = TextStyle(color: PRUSSIAN_BLUE);

    // VARIABLES ---------------------

    return widget.team
        ? AddTeam()
        : !widget.verified
            ? Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Your Team is not yet Verified."),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            logout(context);
                          },
                          child: Text("logout"))
                    ],
                  ),
                ),
              )
            : loaded
                ? Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(
                          currentPage.isEmpty ? "BIONEXUS" : currentPage,
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      iconTheme: IconThemeData(color: Colors.white),
                      backgroundColor: EMERALD,
                    ),
                    drawer: Drawer(
                      child: ListView(
                        children: [
                          UserAccountsDrawerHeader(
                            decoration: BoxDecoration(color: EMERALD),
                            accountName: Text(
                              widget.clinic,
                              style: _text,
                            ),
                            accountEmail: Text(
                              '${FirebaseAuth.instance.currentUser!.email}',
                              style: _text,
                            ),
                          ),
                          ListTile(
                            tileColor: currentPage == "Patients Queue"
                                ? Colors.grey.withOpacity(0.2)
                                : null,
                            trailing: Icon(Icons.queue_rounded),
                            // iconColor: AERO,
                            title: Text(
                              "Patients Queue",
                              style: _listText,
                            ),
                            onTap: (() {
                              changePage("Patients Queue");
                              print(currentPage);
                              Navigator.pop(context);
                            }),
                          ),
                          ListTile(
                            tileColor: currentPage == "Patient Records"
                                ? Colors.grey.withOpacity(0.2)
                                : null,
                            trailing: Icon(Icons.file_present_rounded),
                            // iconColor: AERO,
                            title: Text(
                              "Patient Records",
                              style: _listText,
                            ),
                            onTap: (() {
                              changePage("Patient Records");
                              print(currentPage);
                              Navigator.pop(context);
                            }),
                          ),
                          ListTile(
                            tileColor: currentPage == "Inventory"
                                ? Colors.grey.withOpacity(0.2)
                                : null,
                            trailing: Icon(Icons.inventory_2_rounded),
                            // iconColor: AERO,
                            title: Text(
                              "Inventory",
                              style: _listText,
                            ),
                            onTap: (() {
                              changePage("Inventory");
                              print(currentPage);
                              Navigator.pop(context);
                            }),
                          ),
                          ListTile(
                            tileColor: currentPage == "Medical Services"
                                ? Colors.grey.withOpacity(0.2)
                                : null,
                            trailing: Icon(Icons.medical_services),
                            // iconColor: AERO,
                            title: Text(
                              "Medical Services",
                              style: _listText,
                            ),
                            onTap: (() {
                              changePage("Medical Services");
                              print(currentPage);
                              Navigator.pop(context);
                            }),
                          ),
                          ListTile(
                            tileColor: currentPage == "Lab Specimen Requests"
                                ? Colors.grey.withOpacity(0.2)
                                : null,
                            trailing: Icon(Icons.science_rounded),
                            // iconColor: AERO,
                            title: Text(
                              "Lab Specimen Requests",
                              style: _listText,
                            ),
                            onTap: (() {
                              changePage("Lab Specimen Requests");
                              print(currentPage);
                              Navigator.pop(context);
                            }),
                          ),
                          ListTile(
                            tileColor: currentPage == "Lab Records"
                                ? Colors.grey.withOpacity(0.2)
                                : null,
                            trailing: Icon(Icons.query_stats_rounded),
                            // iconColor: AERO,
                            title: Text(
                              "Lab Records",
                              style: _listText,
                            ),
                            onTap: (() {
                              changePage("Lab Records");
                              print(currentPage);
                              Navigator.pop(context);
                            }),
                          ),
                          ListTile(
                            tileColor: currentPage == "TPS"
                                ? Colors.grey.withOpacity(0.2)
                                : null,
                            trailing: Icon(Icons.receipt_long_outlined),
                            // iconColor: AERO,
                            title: Text(
                              "TPS",
                              style: _listText,
                            ),
                            onTap: (() {
                              changePage("TPS");
                              print(currentPage);
                              Navigator.pop(context);
                            }),
                          ),
                          Divider(),
                          ListTile(
                            tileColor: currentPage == "Settings"
                                ? Colors.grey.withOpacity(0.3)
                                : null,
                            trailing: Icon(Icons.settings),
                            // iconColor: AERO,
                            title: Text(
                              "Settings",
                              style: _listText,
                            ),
                            onTap: (() {
                              setState(() {
                                currentPage = "Settings";
                              });
                              print(currentPage);
                              Navigator.pop(context);
                            }),
                          ),
                          ListTile(
                            trailing: Icon(Icons.exit_to_app),
                            // iconColor: AERO,
                            title: Text(
                              "Log Out",
                              style: _listText,
                            ),

                            onTap: () {
                              logout(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    body: currentPage.isEmpty
                        ? Center(
                            child: Text("Welcome to Bionexus"),
                          )
                        : currentPage == "Settings"
                            ? SettingsPage()
                            : currentPage == "Patients Queue"
                                ? PatientsQueuePage()
                                : currentPage == "Lab Records"
                                    ? LabRecordsPage()
                                    : currentPage == "Inventory"
                                        ? InventoryPage()
                                        : currentPage == "TPS"
                                            ? TPS(
                                                teamCode:
                                                    userData["team-license"])
                                            : currentPage == "Patient Records"
                                                ? PatientRecordsPage(
                                                    teamCode: userData[
                                                        "team-license"])
                                                : currentPage ==
                                                        "Medical Services"
                                                    ? MedicalServicesPage()
                                                    : currentPage ==
                                                            "Lab Specimen Requests"
                                                        ? LabSpecimenRequestsPage()
                                                        : Container(
                                                            child: Center(
                                                              child:
                                                                  Text("WIP"),
                                                            ),
                                                          ))
                : Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: AERO,
                      ),
                    ),
                  );
  }
}
