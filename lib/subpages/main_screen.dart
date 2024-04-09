// ignore_for_file: prefer_const_constructors
import 'package:bionexus_admin/subpages/add_team.dart';
import 'package:bionexus_admin/subpages/fitted_video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:bionexus_admin/hex_color.dart';

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
      Future.delayed(Duration(seconds: 1), () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Signed in")));
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
                              content: Text("Account created successfully")));
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
                  FirebaseAuth.instance.signOut();
                  Future.delayed(Duration(milliseconds: 300), () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MainScreen()));
                  });
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

class ClientContent extends StatefulWidget {
  bool team;
  ClientContent({super.key, required this.team});

  @override
  State<ClientContent> createState() => _ClientContentState();
}

class _ClientContentState extends State<ClientContent> {
  String currentPage = "";
  @override
  Widget build(BuildContext context) {
    TextStyle _text = TextStyle(color: Colors.white);
    TextStyle _listText = TextStyle(color: PRUSSIAN_BLUE);

    // VARIABLES ---------------------

    return widget.team
        ? AddTeam()
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "BIONEXUS",
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
                        : currentPage == "Patient Queue"
                            ? Colors.grey.withOpacity(0.2)
                            : null,
                    trailing: Icon(Icons.badge),
                    // iconColor: AERO,
                    title: Text(
                      "Patient Queue",
                      style: _listText,
                    ),
                    onTap: (() {
                      setState(() {
                        currentPage = "Patient Queue";
                      });
                      print(currentPage);
                      Navigator.pop(context);
                    }),
                  ),
                  ListTile(
                    tileColor: currentPage == "Sales"
                        ? Colors.grey.withOpacity(0.3)
                        : null,
                    trailing: Icon(Icons.queue_rounded),
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
                      FirebaseAuth.instance.signOut();
                      Future.delayed(Duration(milliseconds: 300), () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => MainScreen()));
                      });
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
