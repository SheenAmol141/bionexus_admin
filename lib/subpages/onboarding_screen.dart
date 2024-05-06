// ignore_for_file: prefer_const_constructors

import 'package:bionexus_admin/subpages/fitted_video.dart';
import 'package:bionexus_admin/subpages/main_screen.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bionexus_admin/hex_color.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FittedVideo(),
        Opacity(
          opacity: .7,
          child: Container(
            color: DARK_GREEN,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
        Center(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 60,
                  ),
                  SizedBox(
                      width: 300,
                      child: Image.asset("assets/bionexuslogo.png")),
                  SizedBox(
                    height: 80,
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 70,
                child: Text(
                  "Ready to Streamline your Medical Management Process?",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: "montserrat",
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 80,
              ),
              Column(
                children: [
                  OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(AERO.withOpacity(0.3)),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                        side: MaterialStateProperty.all(BorderSide(
                            color: Colors.white,
                            width: 2,
                            style: BorderStyle.solid)),
                        padding: MaterialStatePropertyAll(EdgeInsets.symmetric(
                            horizontal:
                                (MediaQuery.of(context).size.width * .5) - 115,
                            vertical: 20)),
                      ),
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool("opened", true);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => LandingPage()));
                      },
                      child: Text("LEARN MORE",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              letterSpacing: 2,
                              fontFamily: "montserrat",
                              fontWeight: FontWeight.bold))),
                  SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(AERO.withOpacity(0.3)),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                        side: MaterialStateProperty.all(BorderSide(
                            color: Colors.white,
                            width: 2,
                            style: BorderStyle.solid)),
                        padding: MaterialStatePropertyAll(EdgeInsets.symmetric(
                            horizontal:
                                (MediaQuery.of(context).size.width * .5) - 115,
                            vertical: 20)),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => MaterialApp(
                                theme: ThemeData(
                                  appBarTheme: AppBarTheme(
                                      centerTitle: true,
                                      titleTextStyle: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600)
                                      // TextStyle(

                                      // color: Colors.white,
                                      // fontFamily: "montserrat",
                                      // fontWeight: FontWeight.bold
                                      // ),
                                      ),
                                  colorScheme: ThemeData()
                                      .colorScheme
                                      .copyWith(primary: AERO),
                                  backgroundColor: EMERALD,
                                  elevatedButtonTheme: ElevatedButtonThemeData(
                                    style: ButtonStyle(
                                      padding: MaterialStatePropertyAll(
                                        EdgeInsets.all(20),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              AERO),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      textStyle: MaterialStatePropertyAll(
                                          GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              letterSpacing: 1)),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  fontFamily: "montserrat",
                                  primaryColor: PROCESS_CYAN,
                                  radioTheme: RadioThemeData(
                                    fillColor: MaterialStatePropertyAll(AERO),
                                  ),
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AERO, width: 3.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  checkboxTheme: CheckboxThemeData(fillColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return AERO;
                                    } else {
                                      return Colors.transparent;
                                    }
                                  })),
                                  outlinedButtonTheme: OutlinedButtonThemeData(
                                    style: ButtonStyle(
                                        side: MaterialStatePropertyAll(
                                          BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(
                                          const EdgeInsets.all(24),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                AERO),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        textStyle:
                                            MaterialStatePropertyAll(TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          letterSpacing: 2,
                                          fontFamily: "montserrat",
                                          fontWeight: FontWeight.bold,
                                        ))),
                                  ),
                                ),
                                home: MainScreen())));
                      },
                      child: Text("GET STARTED",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              letterSpacing: 2,
                              fontFamily: "montserrat",
                              fontWeight: FontWeight.bold))),
                  SizedBox(
                    height: 60,
                  )
                ],
              )
            ],
          ),
        ))
      ],
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 120),
              width: MediaQuery.of(context).size.width,
              color: const Color.fromARGB(255, 46, 96, 182),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 130.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 200,
                      child: Image.asset(
                        "assets/bio.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: SizedBox(
                        child: Column(
                          children: [
                            Text(
                              "Manage",
                              style: GoogleFonts.montserrat(
                                  fontSize: 70,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            Text(
                              "Healthcare.",
                              style: GoogleFonts.montserrat(
                                  fontSize: 70,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            Text(
                              "with ease.",
                              style: GoogleFonts.montserrat(
                                  fontSize: 70,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 50,
                            )
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            padding: MaterialStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 70, vertical: 20)),
                            backgroundColor: MaterialStatePropertyAll(EMERALD)),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) => MainScreen(),
                          ));
                        },
                        child: Text(
                          "Try it now",
                          style: TextStyle(fontSize: 20),
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                        width: 400, child: Image.asset("assets/phone.png")),
                  ],
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.all(80),
                color: Colors.white,
                child: Column(
                  children: [
                    Text(
                      "Available Plans",
                      style: TextStyle(fontSize: 40, color: SPACE_CADET),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      "Base Plan starts at PHP 2.999*",
                      style: TextStyle(fontSize: 40, color: SPACE_CADET),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Flex(
                      mainAxisSize: MainAxisSize.min,
                      direction: Axis.vertical,
                      verticalDirection: VerticalDirection.down,
                      children: [
                        Card(
                          color: SPACE_CADET,
                          child: Padding(
                            padding: const EdgeInsets.all(80.0),
                            child: Column(
                              children: [
                                Text("10%",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                                Text("Discount",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(
                                  height: 20,
                                ),
                                Text("Semi-Annual",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(
                                  height: 20,
                                ),
                                Text("16,200",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Card(
                          color: SPACE_CADET,
                          child: Padding(
                            padding: const EdgeInsets.all(80.0),
                            child: Column(
                              children: [
                                Text("15%",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                                Text("Discount",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(
                                  height: 20,
                                ),
                                Text("Annual",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(
                                  height: 20,
                                ),
                                Text("30,600",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Card(
                          color: SPACE_CADET,
                          child: Padding(
                            padding: const EdgeInsets.all(80.0),
                            child: Column(
                              children: [
                                Text("5%",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                                Text("Discount",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(
                                  height: 20,
                                ),
                                Text("Quarterly",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(
                                  height: 20,
                                ),
                                Text("8,550",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )),
            Container(
              padding: EdgeInsets.symmetric(vertical: 90),
              color: EMERALD,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection("Teams").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    double totalrating = 0;
                    int howmany = 0;
                    List<String> desc = [];
                    List<double> rating = [];
                    List<String> clinicnames = [];
                    for (DocumentSnapshot doc in snapshot.data!.docs.toList()) {
                      if (doc["rated"]) {
                        totalrating += doc["rating_num"];
                        howmany++;
                        desc.add(doc["rating_desc"]);
                        clinicnames.add(doc["clinic_name"]);
                        rating.add(doc["rating_num"]);
                        print("${doc["rating_desc"]}, ${doc["rating_num"]}");
                      }
                    }
                    if (desc.isNotEmpty) {
                      double totalratenum = totalrating / howmany;
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "Listen from our Clients!",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 50,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      "${totalratenum.toStringAsFixed(2)} stars | from ${desc.length} client/s",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 40,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    RatingBar.builder(
                                      initialRating: totalratenum,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemPadding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {},
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: desc.length > 5 ? 5 : desc.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(80.0),
                                    child: CardTemplate(
                                        child: Container(
                                      child: Column(
                                        children: [
                                          RatingBar.builder(
                                            initialRating: rating[index],
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemPadding: EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {},
                                          ),
                                          Text("From ${clinicnames[index]}",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 30,
                                                color: Colors.black,
                                              )),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            "${desc[index]}",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 25,
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                                  );
                                },
                              )
                            ],
                          ));
                    } else {
                      return Container(
                        height: 20,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Text(
                          "No ratings for now!",
                          style: GoogleFonts.montserrat(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        )),
                      );
                    }
                  } else {
                    return Container(
                      child: Text("none"),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
