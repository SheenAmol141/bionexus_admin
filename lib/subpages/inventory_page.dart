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

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
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
                    child: const Icon(Icons.add),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                const Material(child: AddServicesItem())))),
                body: Container(
                  color: CupertinoColors.extraLightBackgroundGray,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: fstore
                        .collection("Teams")
                        .doc(currentUserTeam)
                        .collection("Inventory")
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(children: [
                                      const Icon(
                                        Icons.inventory_2_rounded,
                                        size: 30,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text("${items[index]["stock"]}")
                                    ]),
                                    Row(children: [
                                      const Icon(
                                        Icons.attach_money,
                                        size: 30,
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

class AddServicesItem extends StatelessWidget {
  const AddServicesItem({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _price = TextEditingController();
    TextEditingController _initialStock = TextEditingController();
    TextEditingController _itemName = TextEditingController();
    final key = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add an Item",
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
                decoration: InputDecoration(labelText: "Item Name"),
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                controller: _initialStock,
                decoration: InputDecoration(labelText: "Initial Stock"),
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
                decoration: InputDecoration(hintText: "Price"),
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
                          .collection("Inventory")
                          .doc("${_itemName.text}")
                          .set({
                        "item_name": _itemName.text,
                        "stock": int.parse(_initialStock.text),
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
                  child: Text("Add Item"))
            ],
          ),
        ),
      ),
    );
  }
}
