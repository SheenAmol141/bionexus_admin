// ignore_for_file: prefer_const_constructors

import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/subpages/admin_pages/licenses_page.dart';
import 'package:bionexus_admin/subpages/admin_pages/sales_page.dart';
import 'package:bionexus_admin/subpages/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
            ? LicensesPage()
            : currentPage == "Licenses"
                ? LicensesPage()
                : currentPage == "Sales"
                    ? SalesPage()
                    : null);
  }
}
