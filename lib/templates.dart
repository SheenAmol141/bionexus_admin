import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionTitlesTemplate extends StatelessWidget {
  final child;
  const SectionTitlesTemplate(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(child,
        style:
            GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 25));
  }
}

class CardTemplate extends StatelessWidget {
  final Widget child;
  const CardTemplate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
          surfaceTintColor: Colors.transparent,
          color: Colors.white,
          elevation: 5,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: child,
          )),
    );
  }
}

class MemberSettingsTemplate extends StatefulWidget {
  final String member;
  const MemberSettingsTemplate({super.key, required this.member});

  @override
  State<MemberSettingsTemplate> createState() =>
      _MemberSettingsTemplateState(email: member);
}

class _MemberSettingsTemplateState extends State<MemberSettingsTemplate> {
  String email;
  _MemberSettingsTemplateState({required this.email}) {
    print(email);
  }

  bool yesPatientRecords = false;
  bool yesPatientsQueue = false;
  bool yesTPS = false;
  bool yesInventory = false;
  bool yesServices = false;
  bool yesLabRecords = false;
  bool yesLabRequest = false;

  final colRef = FirebaseFirestore.instance.collection("Users");

  void getBools() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(email)
        .get()
        .then((value) {
      setState(() {
        yesPatientRecords = value["Patient Records"];
        yesPatientsQueue = value["Patients Queue"];
        yesTPS = value["TPS"];
        yesInventory = value["Inventory"];
        yesServices = value["Medical Services"];
        yesLabRecords = value["Lab Records"];
        yesLabRequest = value["Lab Specimen Requests"];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBools();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          email,
          style:
              GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(
          "Roles",
          style:
              GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Checkbox(
                value: yesPatientRecords,
                onChanged: (bool) {
                  colRef.doc(email).update({"Patient Records": bool}).then(
                      (value) =>
                          colRef.doc(email).get().then((value) => setState(() {
                                yesPatientRecords = value["Patient Records"];
                              })));
                }),
            const Spacer20(),
            Text(
              "Patient Records",
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Spacer20(),
        Row(
          children: [
            Checkbox(
                value: yesPatientsQueue,
                onChanged: (bool) {
                  colRef.doc(email).update({"Patients Queue": bool}).then(
                      (value) =>
                          colRef.doc(email).get().then((value) => setState(() {
                                yesPatientsQueue = value["Patients Queue"];
                              })));
                }),
            const Spacer20(),
            Text(
              "Patients Queue",
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Spacer20(),
        Row(
          children: [
            Checkbox(
                value: yesTPS,
                onChanged: (bool) {
                  colRef.doc(email).update({"TPS": bool}).then((value) =>
                      colRef.doc(email).get().then((value) => setState(() {
                            yesTPS = value["TPS"];
                          })));
                }),
            const Spacer20(),
            Text(
              "TPS",
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Spacer20(),
        Row(
          children: [
            Checkbox(
                value: yesInventory,
                onChanged: (bool) {
                  colRef.doc(email).update({"Inventory": bool}).then((value) =>
                      colRef.doc(email).get().then((value) => setState(() {
                            yesInventory = value["Inventory"];
                          })));
                }),
            const Spacer20(),
            Text(
              "Inventory",
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Row(
          children: [
            Checkbox(
                value: yesServices,
                onChanged: (bool) {
                  colRef.doc(email).update({"Medical Services": bool}).then(
                      (value) =>
                          colRef.doc(email).get().then((value) => setState(() {
                                yesServices = value["Medical Services"];
                              })));
                }),
            const Spacer20(),
            Text(
              "Medical Services",
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Spacer20(),
        Row(
          children: [
            Checkbox(
                value: yesLabRecords,
                onChanged: (bool) {
                  colRef.doc(email).update({"Lab Records": bool}).then(
                      (value) =>
                          colRef.doc(email).get().then((value) => setState(() {
                                yesLabRecords = value["Lab Records"];
                              })));
                }),
            const Spacer20(),
            Text(
              "Lab Records",
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Spacer20(),
        Row(
          children: [
            Checkbox(
                value: yesLabRequest,
                onChanged: (bool) {
                  colRef
                      .doc(email)
                      .update({"Lab Specimen Requests": bool}).then((value) =>
                          colRef.doc(email).get().then((value) => setState(() {
                                yesLabRequest = value["Lab Specimen Requests"];
                              })));
                }),
            const Spacer20(),
            Text(
              "Lab Specimen Requests",
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Spacer20(),
      ],
    );
  }
}

class Spacer20 extends StatelessWidget {
  const Spacer20({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
    );
  }
}

class NumericTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      final int selectionIndexFromTheRight =
          newValue.text.length - newValue.selection.end;
      var value = newValue.text;
      if (newValue.text.length > 2) {
        value = value.replaceAll(RegExp(r'\D'), '');
        value = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ' ');
        print("Value ---- $value");
      }
      return TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(
            offset: value.length - selectionIndexFromTheRight),
      );
    } else {
      return newValue;
    }
  }
}

class InventoryItemWidget extends StatelessWidget {
  final String name;

  final int stock;

  final double price;

  InventoryItemWidget(
      {required this.name, required this.stock, required this.price});

  @override
  Widget build(BuildContext context) {
    return CardTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: $name'),
          SizedBox(height: 8.0),
          Text('Stock: $stock'),
          SizedBox(height: 8.0),
          Text('Price: \$$price'),
        ],
      ),
    );
  }
}
