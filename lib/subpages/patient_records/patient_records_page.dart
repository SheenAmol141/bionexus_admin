import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/subpages/tps_pages/all_transactions_tab.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:bionexus_admin/subpages/patient_records/patient_transactions.dart'
    hide ReceiptDetailsPage;

class PatientRecordsPage extends StatelessWidget {
  final String teamCode;
  const PatientRecordsPage({super.key, required this.teamCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AERO,
        foregroundColor: Colors.white,
        hoverColor: EMERALD,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Material(child: MyForm(teamCode)),
          ));
        },
      ),
      body: Container(
        color: CupertinoColors.lightBackgroundGray,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Teams")
              .doc(teamCode)
              .collection("Patients")
              .snapshots(),
          builder: (context, snapshot) {
            try {
              List<DocumentSnapshot> patientDocSnapshots = [];

              for (DocumentSnapshot doc
                  in snapshot.data!.docs.reversed.toList()) {
                patientDocSnapshots.add(doc);
                print(doc);
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SectionTitlesTemplate("Patients"),
                  ),
                  Container(
                    height: 1,
                    color: Color.fromARGB(255, 187, 187, 187),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(
                            height: 20,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: patientDocSnapshots.length,
                          itemBuilder: (context, index) {
                            DateTime timestampToDateTime(Timestamp timestamp) {
                              return timestamp.toDate();
                            }

                            Birthdate bday = Birthdate(timestampToDateTime(
                                patientDocSnapshots[index]["birthdate"]));

                            return CardTemplate(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${patientDocSnapshots[index]["name"]}",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Sex: ${patientDocSnapshots[index]["is_male"] ? 'Male' : 'Female'}",
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "Age: ${bday.getCurrentAge()}",
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "Birth Date: ${bday.getFormattedDate()}",
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w400),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextButton.icon(
                                  icon: Icon(Icons.arrow_right_rounded),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => MoreAboutPage(
                                          docSnapshot:
                                              patientDocSnapshots[index],
                                          teamCode: teamCode),
                                    ));
                                  },
                                  label: Text("More about this patient"),
                                )
                              ],
                            ));
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } catch (e) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AERO,
                    ),
                    const SizedBox(
                      width: 400,
                      child: Text(
                          "Page is loading, if stuck please check your internet connection."),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  MyForm(this.teamCode);
  String teamCode;

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _firstName = "";
  String _lastName = "";
  bool _isMale = true; // Default to male
  String _healthInsurance = "";
  String _allergies = "";
  late DateTime _birthDate;

  @override
  void initState() {
    super.initState();
    _birthDate = DateTime.now();
  }

  Future<void> _selectBirthdate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        _birthDate = selectedDate;
      });
    }
  }

  bool bdayselected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a Patient"),
        backgroundColor: EMERALD,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "First Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your first name.";
                  }
                  return null;
                },
                onSaved: (newValue) => _firstName = newValue!,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Last Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your last name.";
                  }
                  return null;
                },
                onSaved: (newValue) => _lastName = newValue!,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text("Gender:"),
                  Radio(
                    value: true,
                    groupValue: _isMale,
                    onChanged: (newValue) =>
                        setState(() => _isMale = newValue!),
                  ),
                  Text("Male"),
                  Radio(
                    value: false,
                    groupValue: _isMale,
                    onChanged: (newValue) =>
                        setState(() => _isMale = newValue!),
                  ),
                  Text("Female"),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Health Insurance (leave empty if none)"),
                onSaved: (newValue) => _healthInsurance = newValue!,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Allergies (leave empty if none)"),
                onSaved: (newValue) => _allergies = newValue!,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      _selectBirthdate(context).then((value) => setState(() {
                            bdayselected = true;
                          }));
                    },
                    child: Text(
                      bdayselected
                          ? "Birthdate: ${DateFormat('MMMM dd yyyy').format(_birthDate)}"
                          : "Click to select your Birthdate here",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Birthdate a = Birthdate(_birthDate);
                  int birthdate = a.getCurrentAge();
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Process form data (e.g., print or submit to server)
                    String name = "$_firstName $_lastName";
                    print("First Name: $_firstName");
                    print("Last Name: $_lastName");
                    print("Male: $_isMale");
                    print("Health Insurance: $_healthInsurance");
                    print("Allergies: $_allergies");
                    print("Birthdate: $birthdate");

                    FirebaseFirestore.instance
                        .collection("Teams")
                        .doc(widget.teamCode)
                        .collection("Patients")
                        .doc(name)
                        .set({
                          "name": name,
                          "fname": _firstName,
                          "lname": _lastName,
                          "is_male": _isMale,
                          "health_insurance": _healthInsurance,
                          "allergies": _allergies,
                          "birthdate": _birthDate,
                        })
                        .then((value) => Navigator.pop(context))
                        .then((value) => ScaffoldMessenger.of(context)
                            .showSnackBar(
                                SnackBar(content: Text("Patient Created"))));
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Birthdate {
  final DateTime _birthDate;

  Birthdate(this._birthDate);

  String getFormattedDate() {
    return DateFormat('MMMM-dd-yyyy').format(_birthDate);
  }

  int getCurrentAge() {
    final now = DateTime.now();
    int age = now.year - _birthDate.year;
    // Check if birthday has passed in the current year
    if ((now.month < _birthDate.month) ||
        (now.month == _birthDate.month && now.day < _birthDate.day)) {
      age--;
    }
    return age;
  }
}

class MoreAboutPage extends StatefulWidget {
  MoreAboutPage({super.key, required this.docSnapshot, required this.teamCode});
  String teamCode;
  DocumentSnapshot docSnapshot;

  @override
  State<MoreAboutPage> createState() => _MoreAboutPageState();
}

class _MoreAboutPageState extends State<MoreAboutPage> {
  bool notransac = false;

  void initnotransac() {
    // ignore: avoid_single_cascade_in_expression_statements
    FirebaseFirestore.instance
      ..collection("Teams")
          .doc(widget.teamCode)
          .collection("Patients")
          .doc(widget.docSnapshot["name"])
          .collection("Transactions")
          .get()
          .then((value) {
        if (value.docs.toList().isEmpty) {
          setState(() {
            notransac = true;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    DateTime timestampToDateTime(Timestamp timestamp) {
      return timestamp.toDate();
    }

    Birthdate bday =
        Birthdate(timestampToDateTime(widget.docSnapshot["birthdate"]));

    StreamBuilder stream = StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Teams")
          .doc(widget.teamCode)
          .collection("Patients")
          .doc(widget.docSnapshot["name"])
          .collection("Transactions")
          .snapshots(),
      builder: (context, snapshot) {
        try {
          List<DocumentSnapshot> _transactions = [];
          for (DocumentSnapshot doc in snapshot.data!.docs.reversed.toList()) {
            _transactions.add(doc);
          }
          if (_transactions.length == 0) {
            return Container(
              child: const CardTemplate(child: Text("No Transactions")),
            );
          } else {
            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                DocumentSnapshot currentDoc = _transactions[index];
                String dateminutetime =
                    "${DateFormat.jm().format(currentDoc["time_of_transaction"].toDate())}";
                String datetime =
                    "${DateFormat("MMMM dd, yyyy").format(currentDoc["time_of_transaction"].toDate())}";
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Teams")
                        .doc(widget.teamCode)
                        .collection("Transactions")
                        .doc(currentDoc.id)
                        .collection("Items")
                        .snapshots(),
                    builder: (context, snapshots) {
                      if (snapshots.hasData) {
                        if (snapshots.connectionState ==
                            ConnectionState.waiting) {
                          return CardTemplate(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AERO,
                              ),
                            ),
                          );
                        } else {
                          double total = 0;
                          for (DocumentSnapshot item
                              in snapshots.data!.docs.toList()) {
                            if (item["service"]) {
                              total += item["price"];
                            } else {
                              total += (item["price"] * item["buyNum"]);
                            }
                          }
                          return CardTemplate(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentDoc["name"] != ''
                                    ? "$datetime - $dateminutetime | ${currentDoc["name"]}"
                                    : "$datetime - $dateminutetime | anonymous",
                                style: GoogleFonts.montserrat(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Total: ",
                                  ),
                                  Text(
                                    "${NumberFormat.currency(symbol: '\$ ').format(total)} ",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextButton.icon(
                                icon: Icon(Icons.arrow_right_rounded),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ReceiptDetailsPage(
                                      currentDoc,
                                      widget.teamCode,
                                      walkin: currentDoc["walkin"],
                                      total: total,
                                    ),
                                  ));
                                },
                                label: Text("More details"),
                              )
                            ],
                          ));
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AERO,
                          ),
                        );
                      }
                    });
              },
              separatorBuilder: (context, index) => SizedBox(
                height: 20,
              ),
              itemCount: 1,
            );
          }
        } catch (e) {
          return Center(
            child: CircularProgressIndicator(
              color: AERO,
            ),
          );
        }
      },
    );

    return Scaffold(
      //return scaffold ----------------------------------
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: EMERALD,
        title: Text("More about ${widget.docSnapshot["name"]}"),
      ),
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SectionTitlesTemplate("Patient Profile"),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CardTemplate(
                child: Column(
                  children: [
                    Text(
                      "${widget.docSnapshot["name"]}",
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sex:",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.docSnapshot["is_male"] ? 'Male' : 'Female',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const Divider()
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Age:",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${bday.getCurrentAge()}",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const Divider()
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Birth Date:",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              bday.getFormattedDate(),
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const Divider()
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const SectionTitlesTemplate("More Details"),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CardTemplate(
                child: Column(
                  children: [
                    const Divider(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Allergies:",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(),
                            Text(
                              widget.docSnapshot["allergies"] == ''
                                  ? "none"
                                  : widget.docSnapshot["allergies"],
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                        const Divider()
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Health Insurance:",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.docSnapshot["health_insurance"] == ''
                                  ? "none"
                                  : widget.docSnapshot["health_insurance"],
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const Divider()
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const SectionTitlesTemplate("Most Recent Transaction"),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: stream,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PatientAllTransactions(context,
                              teamCode: widget.teamCode,
                              name: widget.docSnapshot["name"]),
                        ));
                      },
                      child: Text("View All Transactions.")),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
