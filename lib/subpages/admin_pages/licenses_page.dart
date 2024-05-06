import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/subpages/settings_page.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

DateFormat format = DateFormat('MMMM dd yyyy');

class LicensesPage extends StatefulWidget {
  const LicensesPage({super.key});

  @override
  State<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool descending = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text("Verified First"),
                  SizedBox(
                    width: 10,
                  ),
                  Switch(
                    value: descending,
                    onChanged: (value) {
                      setState(() {
                        descending = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Teams")
                    .orderBy("verified", descending: descending)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: AERO),
                    );
                  } else {
                    List<DocumentSnapshot> teamList = [];
                    for (DocumentSnapshot doc
                        in snapshot.data!.docs.reversed.toList()) {
                      teamList.add(doc);
                    }

                    return ListView.separated(
                        separatorBuilder: (context, index) => SizedBox(
                              height: 20,
                            ),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          DocumentSnapshot team = teamList[index];
                          print(team.id);
                          return CardTemplate(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionTitlesTemplate(team["clinic_name"]),
                              SizedBox(
                                height: 20,
                              ),
                              Text(team.id),
                              SizedBox(
                                height: 20,
                              ),
                              Text(team["verified"]
                                  ? "Verified"
                                  : "Not Verified"),
                              SizedBox(
                                height: 20,
                              ),
                              Text(team["root-user"]),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                  "Deadline of Subscription: ${format.format(team["subscription_deadline"].toDate()).toString()}"),
                              SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ManageSubscription(
                                        context,
                                        teamCode: team.id,
                                      ),
                                    ));
                                  },
                                  child: Text("Manage Subscription"))
                            ],
                          ));
                        },
                        itemCount: teamList.length);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManageSubscription extends StatefulWidget {
  ManageSubscription(this.scafcon, {super.key, required this.teamCode});

  BuildContext scafcon;

  String teamCode;

  @override
  State<ManageSubscription> createState() => _ManageSubscriptionState();
}

class _ManageSubscriptionState extends State<ManageSubscription> {
  void initTeam() {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Teams")
          .doc(widget.teamCode)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: AERO),
          );
        } else {
          DocumentSnapshot team = snapshot.data as DocumentSnapshot<Object?>;
          return Material(
            textStyle: GoogleFonts.montserrat(),
            child: Scaffold(
              backgroundColor: CupertinoColors.extraLightBackgroundGray,
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SectionTitlesTemplate("${team["clinic_name"]}"),
                      SizedBox(
                        height: 20,
                      ),
                      CardTemplate(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "More Details",
                              style: GoogleFonts.montserrat(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "TeamID:",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(child: Container()),
                                Expanded(
                                  child: Text(
                                    widget.teamCode,
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Root User:",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(child: Container()),
                                Expanded(
                                  child: Text(
                                    team["root-user"],
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Members:",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(child: Container()),
                                Expanded(
                                  child: Text(
                                    team["members"].toString(),
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            // Image.network(team["certificate_url"])
                            Text(
                              "BIR Certificate of Registration:",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Image(
                              image: NetworkImage(team["certificate_url"]),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child; // Image is loaded
                                }
                                return Center(
                                    child:
                                        CircularProgressIndicator()); // Display spinner while loading
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            team["verified"]
                                ? Container()
                                : ElevatedButton(
                                    onPressed: () {
                                      // DateTime time = DateTime.now();
                                      // FirebaseFirestore.instance
                                      //     .collection("Teams")
                                      //     .doc(teamCode)
                                      //     .update({
                                      //   "subscription_deadline": time.add(Duration(days: 30))
                                      // });
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text("Confirm?"),
                                          contentPadding: EdgeInsets.all(5),
                                          content: const Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: Text(
                                                "Do you wish to add 30 Days (1 Month) to the Subscription of this team?"),
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Cancel")),
                                            TextButton(
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection("Teams")
                                                      .doc(widget.teamCode)
                                                      .update({
                                                    "verified": true
                                                  }).then((value) {
                                                    Navigator.of(context).pop();
                                                  }).then((value) {
                                                    ScaffoldMessenger.of(
                                                            widget.scafcon)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "Team is now verified!")));
                                                  });
                                                },
                                                child: Text(
                                                  "Confirm",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ))
                                          ],
                                        ),
                                      );
                                    },
                                    child: Text("Verify this Team")),
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
                          Text(
                            "Subscription Details",
                            style: GoogleFonts.montserrat(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Deadline of Subscription:",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(child: Container()),
                              Expanded(
                                child: Text(
                                  format
                                      .format(team["subscription_deadline"]
                                          .toDate())
                                      .toString(),
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Days until Deadline:",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(child: Container()),
                              Expanded(
                                child: Text(
                                  team["subscription_deadline"]
                                      .toDate()
                                      .difference(DateTime.now())
                                      .inDays
                                      .toString(),
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                        ],
                      )),
                      SizedBox(
                        height: 20,
                      ),
                      Wrap(
                        direction: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  // DateTime time = DateTime.now();
                                  // FirebaseFirestore.instance
                                  //     .collection("Teams")
                                  //     .doc(teamCode)
                                  //     .update({
                                  //   "subscription_deadline": time.add(Duration(days: 30))
                                  // });
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Confirm?"),
                                      contentPadding: EdgeInsets.all(5),
                                      content: const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Text(
                                            "Do you wish to add 30 Days (1 Month) to the Subscription of this team?"),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel")),
                                        TextButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection("Teams")
                                                  .doc(widget.teamCode)
                                                  .update({
                                                "subscription_deadline": team[
                                                        "subscription_deadline"]
                                                    .toDate()
                                                    .add(Duration(days: 30))
                                              }).then((value) {
                                                Navigator.of(context).pop();
                                              }).then((value) {
                                                ScaffoldMessenger.of(
                                                        widget.scafcon)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            "30 Days (1 Month) added successfuly!")));
                                              });
                                            },
                                            child: Text(
                                              "Confirm",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ))
                                      ],
                                    ),
                                  );
                                },
                                child: Text("Add 30 Days (1 Month)")),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  // DateTime time = DateTime.now();
                                  // FirebaseFirestore.instance
                                  //     .collection("Teams")
                                  //     .doc(teamCode)
                                  //     .update({
                                  //   "subscription_deadline": time.add(Duration(days: 30))
                                  // });
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Confirm?"),
                                      contentPadding: EdgeInsets.all(5),
                                      content: const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Text(
                                            "Do you wish to add 90 Days (3 Months) to the Subscription of this team?"),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel")),
                                        TextButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection("Teams")
                                                  .doc(widget.teamCode)
                                                  .update({
                                                "subscription_deadline": team[
                                                        "subscription_deadline"]
                                                    .toDate()
                                                    .add(Duration(days: 30))
                                              }).then((value) {
                                                Navigator.of(context).pop();
                                              }).then((value) {
                                                ScaffoldMessenger.of(
                                                        widget.scafcon)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            "90 Days (3 Months) added successfuly!")));
                                              });
                                            },
                                            child: Text(
                                              "Confirm",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ))
                                      ],
                                    ),
                                  );
                                },
                                child: Text("Add 90 Days (3 Months)")),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  // DateTime time = DateTime.now();
                                  // FirebaseFirestore.instance
                                  //     .collection("Teams")
                                  //     .doc(teamCode)
                                  //     .update({
                                  //   "subscription_deadline": time.add(Duration(days: 30))
                                  // });
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Confirm?"),
                                      contentPadding: EdgeInsets.all(5),
                                      content: const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Text(
                                            "Do you wish to add 182 Days (Half a Year) to the Subscription of this team?"),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel")),
                                        TextButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection("Teams")
                                                  .doc(widget.teamCode)
                                                  .update({
                                                "subscription_deadline": team[
                                                        "subscription_deadline"]
                                                    .toDate()
                                                    .add(Duration(days: 182))
                                              }).then((value) {
                                                Navigator.of(context).pop();
                                              }).then((value) {
                                                ScaffoldMessenger.of(
                                                        widget.scafcon)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            "182 Days (Half a Year) added successfuly!")));
                                              });
                                            },
                                            child: Text(
                                              "Confirm",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ))
                                      ],
                                    ),
                                  );
                                },
                                child: Text("Add 182 Days (Half a Year)")),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  // DateTime time = DateTime.now();
                                  // FirebaseFirestore.instance
                                  //     .collection("Teams")
                                  //     .doc(teamCode)
                                  //     .update({
                                  //   "subscription_deadline": time.add(Duration(days: 30))
                                  // });
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Confirm?"),
                                      contentPadding: EdgeInsets.all(5),
                                      content: const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Text(
                                            "Do you wish to add 365 Days (1 Year) to the Subscription of this team?"),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel")),
                                        TextButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection("Teams")
                                                  .doc(widget.teamCode)
                                                  .update({
                                                "subscription_deadline": team[
                                                        "subscription_deadline"]
                                                    .toDate()
                                                    .add(Duration(days: 365))
                                              }).then((value) {
                                                Navigator.of(context).pop();
                                              }).then((value) {
                                                ScaffoldMessenger.of(
                                                        widget.scafcon)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            "365 Days (1 Year) added successfuly!")));
                                              });
                                            },
                                            child: Text(
                                              "Confirm",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ))
                                      ],
                                    ),
                                  );
                                },
                                child: Text("Add 365 Days (1 Year)")),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                backgroundColor: EMERALD,
                title: const Text("Manage Subscription"),
              ),
            ),
          );
        }
      },
    );
  }
}
