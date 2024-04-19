// ignore_for_file: prefer_const_constructors
import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/subpages/add_team.dart';
import 'package:bionexus_admin/subpages/patients_queue_page.dart';
import 'package:bionexus_admin/subpages/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isAdmin = false;
  bool loaded = false;
  bool noTeam = false;

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
      Future.delayed(Duration(seconds: 0), () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Signed in"),
          duration: Duration(milliseconds: 500),
        ));
      });
    });
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
                : ClientContent(team: noTeam)
            : Center(
                child: CircularProgressIndicator(),
              )
        : Stack(
            // --------------------------------------------------------------------------------------------------- loginScreen

            children: [
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
                  Column(
                    children: [
                      SizedBox(
                        height: 200,
                      ),
                      SizedBox(
                          width: 420,
                          child: Image.asset("assets/bionexuslogo.png")),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    height: 500,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      //Login container
                      child: SignInScreen(providers: [
                        EmailAuthProvider(),
                      ], actions: [
                        AuthStateChangeAction<UserCreated>((context, state) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Account created successfully"),
                              duration: Duration(milliseconds: 500)));
                          isitAdmin();
                          isitinTeam();
                          FirebaseFirestore.instance
                              .collection("Users")
                              .doc(FirebaseAuth.instance.currentUser!.email)
                              .set({
                            "uid": FirebaseAuth.instance.currentUser!.uid,
                            "team-license": null
                          });
                        }),
                        AuthStateChangeAction<SignedIn>((context, state) {
                          isitAdmin();
                          isitinTeam();
                        })
                      ]),
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}

class AdminContent extends StatefulWidget {
  const AdminContent({super.key});

  @override
  State<AdminContent> createState() => _AdminContentState();
}

class _AdminContentState extends State<AdminContent> {
  String currentPage = "";
  @override
  Widget build(BuildContext context) {
    TextStyle _text = TextStyle(color: Colors.white);
    TextStyle _listText = TextStyle(color: PRUSSIAN_BLUE);

    // VARIABLES ---------------------

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "BIONEXUS - ADMIN",
            style: TextStyle(
                color: Colors.white,
                fontFamily: "montserrat",
                fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: EMERALD,
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: EMERALD),
                accountName: Text(
                  'Hello ${FirebaseAuth.instance.currentUser!.displayName ?? "unnamed"}!',
                  style: _text,
                ),
                accountEmail: Text(
                  '${FirebaseAuth.instance.currentUser!.email}',
                  style: _text,
                ),
              ),
              ListTile(
                tileColor: currentPage.isEmpty
                    ? Colors.grey.withOpacity(0.3)
                    : currentPage == "Licenses"
                        ? Colors.grey.withOpacity(0.2)
                        : null,
                trailing: Icon(Icons.badge),
                // iconColor: AERO,
                title: Text(
                  "Licenses",
                  style: _listText,
                ),
                onTap: (() {
                  setState(() {
                    currentPage = "Licenses";
                  });
                  print(currentPage);
                  Navigator.pop(context);
                }),
              ),
              ListTile(
                tileColor: currentPage == "Sales"
                    ? Colors.grey.withOpacity(0.3)
                    : null,
                trailing: Icon(Icons.bar_chart_rounded),
                // iconColor: AERO,
                title: Text(
                  "Sales",
                  style: _listText,
                ),
                onTap: (() {
                  setState(() {
                    currentPage = "Sales";
                  });
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
                child: Text("Licenses"),
              )
            : currentPage == "Licenses"
                ? Center(
                    child: Text("Licenses"),
                  )
                : currentPage == "Sales"
                    ? Center(
                        child: Text("Sales"),
                      )
                    : currentPage == "Settings"
                        ? Center(
                            child: Text("Settings"),
                          )
                        : null);
  }
}

// ignore: must_be_immutable
class ClientContent extends StatefulWidget {
  bool team;
  ClientContent({super.key, required this.team});

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
      setState(() {
        currentPage = page;
      });
    } else if (userData[page]) {
      setState(() {
        currentPage = page;
      });
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
        : loaded
            ? Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(currentPage.isEmpty ? "BIONEXUS" : currentPage,
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600, color: Colors.white)),
                  iconTheme: IconThemeData(color: Colors.white),
                  backgroundColor: EMERALD,
                ),
                drawer: Drawer(
                  child: ListView(
                    children: [
                      UserAccountsDrawerHeader(
                        decoration: BoxDecoration(color: EMERALD),
                        accountName: Text(
                          'Hello ${FirebaseAuth.instance.currentUser!.displayName ?? "unnamed"}!',
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
                        trailing: Icon(Icons.medical_services),
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
                            : Container(
                                child: Center(
                                  child: Text("WIP"),
                                ),
                              ))
            : Center(
                child: CircularProgressIndicator(
                color: AERO,
              ));
  }
}
