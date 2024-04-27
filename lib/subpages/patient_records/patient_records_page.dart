import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
                      padding: EdgeInsets.all(20),
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
                                    fontSize: 18, fontWeight: FontWeight.w500),
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
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MoreAboutPage(
                                        docSnapshot: patientDocSnapshots[index],
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

class MoreAboutPage extends StatelessWidget {
  MoreAboutPage({super.key, required this.docSnapshot, required this.teamCode});
  String teamCode;
  DocumentSnapshot docSnapshot;
  @override
  Widget build(BuildContext context) {
    DateTime timestampToDateTime(Timestamp timestamp) {
      return timestamp.toDate();
    }

    Birthdate bday = Birthdate(timestampToDateTime(docSnapshot["birthdate"]));

    // StreamBuilder stream = StreamBuilder(
    //     stream: FirebaseFirestore.instance
    //         .collection("Teams")
    //         .doc(teamCode)
    //         .collection("Patients")
    //         .doc(docSnapshot["name"])
    //         .collection("Transactions")
    //         .snapshots(),
    //     builder: (context, snapshot) {
    //       try {

    //       }catch (e) {

    //       }
    //     },);

    return Scaffold(
      //return scaffold ----------------------------------
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: EMERALD,
        title: Text("More about ${docSnapshot["name"]}"),
      ),
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          SectionTitlesTemplate("Patient Profile"),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CardTemplate(
              child: Column(
                children: [
                  Text(
                    "${docSnapshot["name"]}",
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
                            docSnapshot["is_male"] ? 'Male' : 'Female',
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
                  // Text(
                  //   "Age: ${bday.getCurrentAge()}",
                  //   style: GoogleFonts.montserrat(fontWeight: FontWeight.w400),
                  // ),
                  // Text(
                  //   "Birth Date: ${bday.getFormattedDate()}",
                  //   style: GoogleFonts.montserrat(fontWeight: FontWeight.w400),
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                ],
              ),
            ),
          ),
          const SectionTitlesTemplate("More Details"),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CardTemplate(
              child: Column(
                children: [
                  const Divider(),
                  Column(
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
                          Expanded(child: Container()),
                          Expanded(
                            child: Text(
                              docSnapshot["allergies"] == ''
                                  ? "none"
                                  : docSnapshot["allergies"],
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.right,
                            ),
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
                            docSnapshot["health_insurance"] == ''
                                ? "none"
                                : docSnapshot["health_insurance"],
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
          const SectionTitlesTemplate("Transactions"),
        ],
      ),
    );
  }
}
