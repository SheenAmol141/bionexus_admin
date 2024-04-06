// ignore_for_file: prefer_const_constructors

import 'package:bionexus_admin/subpages/fitted_video.dart';
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
  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null
        ? MainContent()
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
                      child: SignInScreen(providers: [
                        EmailAuthProvider(),
                      ], actions: [
                        AuthStateChangeAction<UserCreated>((context, state) {
                          setState(() {});
                        }),
                        AuthStateChangeAction<SignedIn>((context, state) {
                          setState(() {});
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

class MainContent extends StatefulWidget {
  const MainContent({super.key});

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
              tileColor:  currentPage.isEmpty ? Colors.grey.withOpacity(0.2) : currentPage == "Licenses" ? Colors.grey.withOpacity(0.2) : null,
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
              tileColor: currentPage == "Sales" ? Colors.grey.withOpacity(0.2) : null,
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
              tileColor: currentPage == "Settings" ? Colors.grey.withOpacity(0.2) : null,
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
                  : currentPage == "Settings" ? Center(
                      child: Text("Settings"),
                    ) : null
    );
  }
}
