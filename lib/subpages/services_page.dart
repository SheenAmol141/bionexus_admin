import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/main.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MedicalServicesPage extends StatefulWidget {
  const MedicalServicesPage({super.key});

  @override
  State<MedicalServicesPage> createState() => _MedicalServicesPageState();
}

class _MedicalServicesPageState extends State<MedicalServicesPage> {
  final fstore = FirebaseFirestore.instance;

  List<DocumentSnapshot> items = [];

// DocumentReference reference = FirebaseFirestore.instance.collection('collection').doc("document");
//     reference.snapshots().listen((querySnapshot) {

//       setState(() {
//         field =querySnapshot.get("field");
//       });
//     });

  void listen() async {
    fstore
        .collection("Teams")
        .doc(await getTeam())
        .collection("Inventory")
        .snapshots();
  }

  void getInventory() async {
    fstore
        .collection("Teams")
        .doc(await getTeam())
        .collection("Inventory")
        .get()
        .then((querysnap) {
      for (var doc in querysnap.docs) {
        items.add(doc);
      }
      print(items);

      setState(() {});
    });
  }

  bool loaded = false;
  String currentUserTeam = "";
  getcurrentUserTeam() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      print(value["team-license"]);

      setState(() {
        loaded = true;
        currentUserTeam = value["team-license"];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcurrentUserTeam();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: loaded
            ? Scaffold(
                floatingActionButton: FloatingActionButton(
                    backgroundColor: AERO,
                    foregroundColor: Colors.white,
                    focusColor: EMERALD,
                    hoverColor: EMERALD,
                    child: Icon(Icons.add),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                const Material(child: AddInventoryItem())))),
                body: Container(
                  color: CupertinoColors.extraLightBackgroundGray,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: fstore
                        .collection("Teams")
                        .doc(currentUserTeam)
                        .collection("Medical Services")
                        .snapshots(),
                    builder: (context, snapshot) {
                      items = [];
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs.reversed.toList()) {
                          items.add(doc);
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(
                            height: 20,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return CardTemplate(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("${items[index]["item_name"]}",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 25)),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        width: MediaQuery.of(context)
                                                .size
                                                .width -
                                            (MediaQuery.of(context).size.width *
                                                .1),
                                        child: Text(
                                            "${items[index]["description"]}")),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(children: [
                                      const Icon(
                                        Icons.price_change,
                                        size: 30,
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(NumberFormat.currency(symbol: '')
                                          .format(items[index]["price"]))
                                    ]),
                                  ],
                                ),
                              ],
                            ));
                          },
                        ),
                      );
                    },
                  ),
                ),
              )
            : Scaffold(body: Center(child: CircularProgressIndicator())));
  }
}

class AddInventoryItem extends StatelessWidget {
  const AddInventoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _price = TextEditingController();
    TextEditingController _description = TextEditingController();
    TextEditingController _itemName = TextEditingController();
    final key = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add a Medical Service",
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600, color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: EMERALD,
      ),
      body: Form(
        key: key,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _itemName,
                decoration: InputDecoration(labelText: "Medical Service Name"),
                validator: (value) => value == ''
                    ? "Should not be empty"
                    : value!.length < 3
                        ? "Should not be less than 3"
                        : null,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                controller: _description,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: null,
                autocorrect: true,
                validator: (value) =>
                    value == '' ? "Should not be empty" : null,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) =>
                    value == '' ? "Should not be empty" : null,
                controller: _price,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  MoneyInputFormatter(
                      leadingSymbol: MoneySymbols.DOLLAR_SIGN,
                      useSymbolPadding: true,
                      mantissaLength: 2 // the length of the fractional side
                      )
                ],
                decoration: InputDecoration(labelText: "Price"),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    // add item to firestore
                    final good = key.currentState!.validate();
                    if (good) {
                      FirebaseFirestore.instance
                          .collection("Teams")
                          .doc(await getTeam())
                          .collection("Medical Services")
                          .doc("${_itemName.text}")
                          .set({
                        "item_name": _itemName.text,
                        "description": _description.text,
                        "price":
                            (double.parse(toNumericString(_price.text)) / 100)
                      }).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Item added successfuly")));
                        Navigator.of(context).pop();
                      });

                      print(double.parse(toNumericString(_price.text)) / 100);
                    }
                  },
                  child: Text("Add Service"))
            ],
          ),
        ),
      ),
    );
  }
}
