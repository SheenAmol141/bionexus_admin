// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:js_interop';

import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';

class TPS extends StatelessWidget {
  TPS({super.key, required this.teamCode});
  String teamCode;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: TabBar(
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                indicatorColor: Colors.white,
                labelStyle: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    icon: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_rounded),
                        SizedBox(
                          width: 10,
                        ),
                        Text("New Transaction")
                      ],
                    ),
                  ),
                  Tab(
                    icon: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Transaction History")
                      ],
                    ),
                  ),
                ]),
            backgroundColor: EMERALD,
          ),
          body: TabBarView(children: [
            NewTransaction(teamCode: teamCode),
            AllTransactions(teamCode: teamCode, context)
          ]),
        ));
  }
}

class AllTransactions extends StatelessWidget {
  AllTransactions(this.scafcontext, {super.key, required this.teamCode});
  String teamCode;
  BuildContext scafcontext;
  List<DocumentSnapshot> docs = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Teams")
            .doc(teamCode)
            .collection("Transactions")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            try {
              // try
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: AERO),
                );
              } else {
                print(teamCode);
                print("${snapshot.data!.docs.reversed.toList()} loaded");

                for (dynamic doc in snapshot.data!.docs.reversed.toList()) {
                  print("a");
                  docs.add(doc);
                }
                return Container(
                    child: ListView.separated(
                  itemBuilder: (context, index) {
                    return Text("a");
                  },
                  separatorBuilder: (context, index) => SizedBox(
                    height: 20,
                  ),
                  itemCount: docs.length,
                ));
              }
            } catch (e) {
              //catch
              return Center(
                child: Text("Something went wrong."),
              );
            }
          } else {
            return Container(
              child: Center(
                child: Text("No Data"),
              ),
            );
          }
        },
      ),
    );
  }
}

//NEW TRANSACTION ---------------------------------------------------------------------------------
class NewTransaction extends StatefulWidget {
  NewTransaction({
    super.key,
    required this.teamCode,
  });
  String teamCode;

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  bool usePatient = true;
  String currentServicesSelected = 'loading';
  String currentItemSelected = 'loading';
  void getfirstService() {
    FirebaseFirestore.instance
        .collection("Teams")
        .doc(widget.teamCode)
        .collection("Medical Services")
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        currentServicesSelected = value.docs.reversed.first["item_name"];
      }
    });
  }

  void getfirstItem() {
    FirebaseFirestore.instance
        .collection("Teams")
        .doc(widget.teamCode)
        .collection("Inventory")
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        currentItemSelected = value.docs.reversed.first["item_name"];
      }
    });
  }

  void isPatientEmpty() {
    FirebaseFirestore.instance
        .collection("Teams")
        .doc(widget.teamCode)
        .collection("Patients")
        .get()
        .then((value) {
      if (value.docs.toList() == []) {
        usePatient = false;
      }
    });
  }

  // getMedServices ============================
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getfirstService();
    getfirstItem();
    isPatientEmpty();
  }

  List<Widget> mainColumn = [
    Container(
      height: 20,
    ),
  ];
  List<TransactionItem> items = [];
  Set<String> currentSelected = {"custom"};
  bool service = false;

  @override
  Widget build(BuildContext context) {
    BuildContext scafcon = context;
    final customKey = GlobalKey<FormState>();
    final itemKey = GlobalKey<FormState>();

    Container addWidget = Container(
      child: StatefulBuilder(
        builder: (context, setStateHere) {
          String patientcurrentselected = '';
          TextEditingController numOfItems = TextEditingController();
          TextEditingController customNameController = TextEditingController();
          TextEditingController customPriceController = TextEditingController();
          TextEditingController customNumberController =
              TextEditingController();
          TextEditingController customDescriptionController =
              TextEditingController();
          TextEditingController selectPatientController =
              TextEditingController();

          void clearCustomForm() {
            setStateHere(
              () {
                customKey.currentState!.reset();
              },
            );
          }

          void initpatientcurrent() {}
          Widget punchWidget = CardTemplate(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton(
                    style: ButtonStyle(backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return AERO;
                        }
                        return Colors.white;
                      },
                    ),
                        //GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)
                        textStyle: MaterialStateProperty.resolveWith(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500);
                        }
                        return GoogleFonts.montserrat(
                            fontSize: 13, fontWeight: FontWeight.w500);
                      },
                    )),
                    onSelectionChanged: (selection) {
                      print(currentSelected);
                      setStateHere(
                        () {
                          currentSelected = selection;
                          print(currentSelected);
                        },
                      );
                    },
                    segments: [
                      ButtonSegment(value: "custom", label: Text("Custom")),
                      ButtonSegment(
                          value: "service", label: Text("Medical Service")),
                      ButtonSegment(value: "item", label: Text("Item"))
                    ],
                    selected: currentSelected),
                Container(
                  child: currentSelected.first ==
                          "custom" //current segmented is custom
                      ? Form(
                          key: customKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                "Add a Custom Medical Service/Item",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                      value: service,
                                      onChanged: (value) {
                                        setStateHere(
                                          () {
                                            service = !service;
                                          },
                                        );
                                      }),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Is this a Medical Service?")
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText:
                                        "${service ? "Medical Service Label" : "Item Name"}"),
                                controller: customNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Name not be empty";
                                  } else if (value.length < 3) {
                                    return "Name must be more than 3 characters";
                                  }
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                child: !service
                                    ? TextFormField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        keyboardType: TextInputType.number,
                                        controller: customNumberController,
                                        decoration: InputDecoration(
                                            labelText: "Number of Items"),
                                        validator: (value) => value == ''
                                            ? "Should not be empty"
                                            : null,
                                      )
                                    : TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        controller: customDescriptionController,
                                        decoration: InputDecoration(
                                            labelText: "Description"),
                                        maxLines: null,
                                        autocorrect: true,
                                        validator: (value) => value == ''
                                            ? "Should not be empty"
                                            : null,
                                      ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                validator: (value) =>
                                    value == '' ? "Should not be empty" : null,
                                controller: customPriceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  MoneyInputFormatter(
                                      leadingSymbol: MoneySymbols.DOLLAR_SIGN,
                                      useSymbolPadding: true,
                                      mantissaLength:
                                          2 // the length of the fractional side
                                      )
                                ],
                                decoration: InputDecoration(
                                    focusColor: AERO, labelText: "Price"),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    // punch custom item to receipt
                                    final good =
                                        customKey.currentState!.validate();
                                    if (good) {
                                      if (service) {
                                        TransactionItem item = TransactionItem(
                                            itemName: customNameController.text,
                                            price: (double.parse(
                                                    toNumericString(
                                                        customPriceController
                                                            .text)) /
                                                100),
                                            description:
                                                customDescriptionController
                                                    .text,
                                            service: service);
                                        items.add(item);
                                        print(items.length);
                                        print(item.getService());
                                        clearCustomForm();
                                      } else {
                                        TransactionItem item = TransactionItem(
                                            itemName: customNameController.text,
                                            price: (double.parse(
                                                    toNumericString(
                                                        customPriceController
                                                            .text)) /
                                                100),
                                            service: service,
                                            numBuying: int.parse(
                                                customNumberController.text));
                                        items.add(item);
                                        print(items.length);
                                        print(item.getItem());
                                        clearCustomForm();
                                      }
                                    }
                                  },
                                  child: Text("Punch to Receipt"))
                            ],
                          ),
                        ) //END OF CUSTOM --------------------------------------------------------------------------------------------------------------
                      : currentSelected.first ==
                              "service" //current segmented is MED SERVICES
                          ? StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("Teams")
                                  .doc(widget.teamCode)
                                  .collection("Medical Services")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                // MEDICAL SERVICES TEMPLATE MENU

                                List<TransactionItem> _serviceSnapshotList = [];
                                if (snapshot.hasData) {
                                  try {
                                    for (var doc in snapshot.data!.docs.reversed
                                        .toList()) {
                                      _serviceSnapshotList.add(
                                        TransactionItem(
                                          itemName: doc["item_name"],
                                          price: doc["price"],
                                          service: true,
                                          description: doc["description"],
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    _serviceSnapshotList = [
                                      TransactionItem(
                                          itemName: "loading",
                                          price: 0,
                                          service: true,
                                          description: "loading")
                                    ];
                                  }
                                }

                                try {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                90,
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    style: BorderStyle.solid,
                                                    width: 1,
                                                    color: Colors.black
                                                        .withOpacity(0.5)),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            child: Center(
                                              child: DropdownButton(
                                                isExpanded: true,
                                                underline: Container(),
                                                iconEnabledColor: Colors.black
                                                    .withOpacity(0.5),
                                                value:
                                                    currentServicesSelected, // --------------------------------------------------
                                                items: _serviceSnapshotList
                                                    .map((e) {
                                                  return DropdownMenuItem(
                                                      value: e.getService()[
                                                          "item_name"],
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            150,
                                                        child: Text(
                                                          e.getService()[
                                                              "item_name"],
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ));
                                                }).toList(),
                                                onChanged: (value) {
                                                  print(value);
                                                  setStateHere(
                                                    () {
                                                      currentServicesSelected =
                                                          value.toString();
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            print(_serviceSnapshotList);
                                            for (TransactionItem _itemService
                                                in _serviceSnapshotList) {
                                              if (_itemService.getService()[
                                                      "item_name"] ==
                                                  currentServicesSelected) {
                                                items.add(_itemService);
                                                setStateHere(
                                                  () {},
                                                );
                                                print("LETSGO");
                                              }
                                            }
                                          },
                                          child: Text("Punch to Receipt"))
                                    ],
                                  );
                                } catch (e) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: AERO,
                                    ),
                                  );
                                }
                              },
                            )
                          : currentSelected.first == "item"
                              ? StreamBuilder(
                                  // current segmented is ITEM ---------------------------
                                  stream: FirebaseFirestore.instance
                                      .collection("Teams")
                                      .doc(widget.teamCode)
                                      .collection("Inventory")
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    // ITEM TEMPLATE MENU

                                    List<TransactionItem> _itemSnapshotList =
                                        [];
                                    if (snapshot.hasData) {
                                      try {
                                        for (var doc in snapshot
                                            .data!.docs.reversed
                                            .toList()) {
                                          _itemSnapshotList.add(
                                            TransactionItem(
                                              itemName: doc["item_name"],
                                              price: doc["price"],
                                              service: false,
                                              numOfItems: doc["stock"],
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        _itemSnapshotList = [
                                          TransactionItem(
                                              itemName: "loading",
                                              price: 0,
                                              service: true,
                                              description: "loading")
                                        ];
                                      }
                                      print(_itemSnapshotList);
                                    }

                                    try {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    90,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        style:
                                                            BorderStyle.solid,
                                                        width: 1,
                                                        color: Colors.black
                                                            .withOpacity(0.5)),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5))),
                                                child: Column(
                                                  children: [
                                                    Center(
                                                      child: DropdownButton(
                                                        isExpanded: true,
                                                        underline: Container(),
                                                        iconEnabledColor: Colors
                                                            .black
                                                            .withOpacity(0.5),
                                                        value:
                                                            currentItemSelected,
                                                        items: _itemSnapshotList
                                                            .map((e) {
                                                          return DropdownMenuItem(
                                                              value: e.getItem()[
                                                                  "item_name"],
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    150,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      e.getItem()[
                                                                          "item_name"],
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      "Stock: ${e.getItem()["number_of_items"]}",
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          print(value);
                                                          setStateHere(
                                                            () {
                                                              currentItemSelected =
                                                                  value
                                                                      .toString();
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Form(
                                            key: itemKey,
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                  label: Text("Amount to buy")),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              controller: numOfItems,
                                              validator: (value) {
                                                if (value == '' ||
                                                    value == null) {
                                                  return "Amount should not be empty";
                                                } else {
                                                  for (TransactionItem _item
                                                      in _itemSnapshotList) {
                                                    if (_item.getItem()[
                                                            "item_name"] ==
                                                        currentItemSelected) {
                                                      if (_item.getItem()[
                                                              "number_of_items"] <
                                                          int.parse(numOfItems
                                                              .text)) {
                                                        return "Amount should be less than stock!";
                                                      }
                                                    }
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                for (TransactionItem _itemItem
                                                    in _itemSnapshotList) {
                                                  if (itemKey.currentState!
                                                      .validate()) {
                                                    if (_itemItem.getItem()[
                                                            "item_name"] ==
                                                        currentItemSelected) {
                                                      _itemItem.setNumBuying(
                                                          int.parse(
                                                              numOfItems.text));
                                                      items.add(_itemItem);
                                                      setStateHere(
                                                        () {},
                                                      );
                                                      print("LETSGO");
                                                    }
                                                  }
                                                }
                                              },
                                              child: Text("Punch to Receipt"))
                                        ],
                                      );
                                    } catch (e) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: AERO,
                                        ),
                                      );
                                    }
                                  },
                                )
                              : null,
                )
              ],
            ),
          );

          //BUILD THE ITEMS
          Widget widbuilder = ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 20,
              );
            },
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final snapshot = items[index];
              Widget widget;
              if (snapshot.ifService()) {
                Map<String, dynamic> itemMap = snapshot.getService();
                widget = CardTemplate(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Medical Service: ${itemMap["item_name"]}",
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 20,
                            ),
                            Text(
                              NumberFormat.currency(symbol: '')
                                  .format(itemMap["price"]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text("${itemMap["description"]}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    const Color.fromARGB(255, 255, 60, 57)),
                                padding: MaterialStatePropertyAll(
                                    EdgeInsets.all(2))),
                            onPressed: () {
                              items.removeAt(index);
                              print(items);
                              setStateHere(
                                () {},
                              );
                            },
                            child: Icon(Icons.close_rounded))
                      ],
                    ),
                  ],
                ));
              } else {
                Map<String, dynamic> itemMap = snapshot.getItem();
                widget = CardTemplate(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Item: ${itemMap["item_name"]}",
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 20,
                            ),
                            Text(
                              NumberFormat.currency(symbol: '')
                                  .format(itemMap["price"] * itemMap["buyNum"]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text("${itemMap["buyNum"]} pc/s"),
                        Text("  x "),
                        Icon(
                          Icons.attach_money,
                          size: 16,
                        ),
                        Text(
                          NumberFormat.currency(symbol: '')
                                  .format(itemMap["price"]) +
                              " per pc",
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    const Color.fromARGB(255, 255, 60, 57)),
                                padding: MaterialStatePropertyAll(
                                    EdgeInsets.all(2))),
                            onPressed: () {
                              items.removeAt(index);
                              setStateHere(
                                () {},
                              );
                            },
                            child: Icon(Icons.close_rounded)),
                      ],
                    )
                  ],
                ));
              }
              return widget;
            },
          );

          ElevatedButton confirmReceipt = ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(EMERALD),
                padding: MaterialStatePropertyAll(EdgeInsets.all(30))),
            onPressed: () {
              if (items.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("The transaction is empty!")));
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    actions: [
                      TextButton(
                          style: ButtonStyle(
                              textStyle: MaterialStatePropertyAll(
                                  GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w400))),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel")),
                      TextButton(
                        onPressed: () {
                          if (usePatient) {
                            print(patientcurrentselected);
                            DateTime currentTime = DateTime.now();

                            print("usepatient yes");
                            CollectionReference
                                patientYesCollection = //USEYES PATIENT INDIV COLLECTION
                                FirebaseFirestore.instance
                                    .collection("Teams")
                                    .doc(widget.teamCode)
                                    .collection("Patients")
                                    .doc(patientcurrentselected)
                                    .collection("Transactions");
                            CollectionReference
                                globalYesCollection = //USEYES GLOBAL COLLECTION
                                FirebaseFirestore.instance
                                    .collection("Teams")
                                    .doc(widget.teamCode)
                                    .collection("Transactions");

                            //do function

                            patientYesCollection //USEYES PATIENT INDIV COLLECTION -create transac doc
                                .doc("$currentTime | $patientcurrentselected")
                                .set({
                              "time_of_transaction": currentTime,
                              "name": patientcurrentselected,
                              "walkin": false
                            }).then((value) {
                              for (TransactionItem item in items) {
                                //USEYES PATIENT INDIV COLLECTION - start add item in transac doc
                                if (item.ifService()) {
                                  //USEYES PATIENT INDIV COLLECTION - SERVICE
                                  patientYesCollection
                                      .doc(
                                          "$currentTime | $patientcurrentselected")
                                      .collection("Items")
                                      .add({
                                    "item_name": item.getService()["item_name"],
                                    "description":
                                        item.getService()["description"],
                                    "price": item.getService()["price"],
                                    "service": true
                                  });
                                } else {
                                  //USEYES PATIENT INDIV COLLECTION - ITEM
                                  patientYesCollection
                                      .doc(
                                          "$currentTime | $patientcurrentselected")
                                      .collection("Items")
                                      .add({
                                    "item_name": item.getItem()["item_name"],
                                    "buyNum": item.getItem()["buyNum"],
                                    "price": item.getItem()["price"],
                                    "service": false
                                  });
                                }
                              }
                            });

                            globalYesCollection //USEYES PATIENT INDIV COLLECTION -create transac doc
                                .doc("$currentTime | $patientcurrentselected")
                                .set({
                              "time_of_transaction": currentTime,
                              "name": patientcurrentselected,
                              "walkin": false
                            }).then((value) {
                              for (TransactionItem item in items) {
                                //USEYES PATIENT INDIV COLLECTION - start add item in transac doc
                                if (item.ifService()) {
                                  //USEYES PATIENT INDIV COLLECTION - SERVICE
                                  globalYesCollection
                                      .doc(
                                          "$currentTime | $patientcurrentselected")
                                      .collection("Items")
                                      .add({
                                    "item_name": item.getService()["item_name"],
                                    "description":
                                        item.getService()["description"],
                                    "price": item.getService()["price"]
                                  });
                                } else {
                                  //USEYES PATIENT INDIV COLLECTION - ITEM
                                  globalYesCollection
                                      .doc(
                                          "$currentTime | $patientcurrentselected")
                                      .collection("Items")
                                      .add({
                                    "item_name": item.getItem()["item_name"],
                                    "buyNum": item.getItem()["buyNum"],
                                    "price": item.getItem()["price"]
                                  });
                                }
                              }
                            }).then((value) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(scafcon).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Receipt Confirmed and Uploaded!")));
                            });
                            //end of usepatient
                          } else {
                            print("usepatient no");

                            print(selectPatientController.text);
                            DateTime currentTime = DateTime.now();
                            CollectionReference
                                globalYesCollection = //USEYES GLOBAL COLLECTION
                                FirebaseFirestore.instance
                                    .collection("Teams")
                                    .doc(widget.teamCode)
                                    .collection("Transactions");

                            //do function

                            globalYesCollection //USEYES PATIENT INDIV COLLECTION -create transac doc
                                .doc(
                                    "$currentTime | ${selectPatientController.text}")
                                .set({
                              "time_of_transaction": currentTime,
                              "name": selectPatientController.text,
                              "walkin": true
                            }).then((value) {
                              for (TransactionItem item in items) {
                                //USEYES PATIENT INDIV COLLECTION - start add item in transac doc
                                if (item.ifService()) {
                                  //USEYES PATIENT INDIV COLLECTION - SERVICE
                                  globalYesCollection
                                      .doc(
                                          "$currentTime | ${selectPatientController.text}")
                                      .collection("Items")
                                      .add({
                                    "item_name": item.getService()["item_name"],
                                    "description":
                                        item.getService()["description"],
                                    "price": item.getService()["price"],
                                    "service": true
                                  });
                                } else {
                                  //USEYES PATIENT INDIV COLLECTION - ITEM
                                  globalYesCollection
                                      .doc(
                                          "$currentTime | ${selectPatientController.text}")
                                      .collection("Items")
                                      .add({
                                    "item_name": item.getItem()["item_name"],
                                    "buyNum": item.getItem()["buyNum"],
                                    "price": item.getItem()["price"],
                                    "service": false
                                  });
                                }
                              }
                            }).then((value) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(scafcon).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Receipt Confirmed and Uploaded!")));
                            });
                          }
                        },
                        style: ButtonStyle(
                            textStyle: MaterialStatePropertyAll(
                                GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600))),
                        child: Text("Confirm"),
                      )
                    ],
                    contentPadding: EdgeInsets.all(20),
                    content: Text(
                        "Do you wish to confirm and upload this transaction?"),
                    title: Text(
                      "Confirm Receipt",
                      style: GoogleFonts.montserrat(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }
            },
            child: Text("Confirm Receipt"),
          );
          bool inputpatient = false;

          final selectPatientKey = GlobalKey<FormState>();

          CardTemplate selectPatientForTransaction = CardTemplate(
              child: Container(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Teams")
                  .doc(widget.teamCode)
                  .collection("Patients")
                  .snapshots(),
              builder: (context, snapshot) {
                Widget walkinpatient = Form(
                  key: selectPatientKey,
                  child: TextFormField(
                    decoration: InputDecoration(label: Text("Name")),
                    controller: selectPatientController,
                    validator: (value) {
                      if (value == null || value == "") {
                        return "Name must not be empty!";
                      } else if (value!.length < 3) {
                        return "Name must be more than 3 characters!";
                      }
                    },
                  ),
                );

                List<DocumentSnapshot> _patients = [];

                if (snapshot.hasData) {
                  try {
                    for (DocumentSnapshot doc
                        in snapshot.data!.docs.reversed.toList()) {
                      _patients.add(doc);
                    }

                    patientcurrentselected = _patients.first["name"];
                    return StatefulBuilder(
                      builder: (context, setStateSwitch) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitlesTemplate("Buyer Details"),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Text("Use an Existing Patient?"),
                                SizedBox(
                                  width: 10,
                                ),
                                Switch(
                                  value: usePatient,
                                  onChanged: (value) {
                                    setStateSwitch(
                                      () {
                                        usePatient = value;
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            usePatient
                                ? StatefulBuilder(
                                    builder: (context, setStatepatient) {
                                      return DropdownButton(
                                        isExpanded: true,
                                        onChanged: (value) {
                                          setStatepatient(() {
                                            patientcurrentselected =
                                                value.toString();
                                          });
                                        },
                                        value: patientcurrentselected,
                                        items: _patients.map((e) {
                                          return DropdownMenuItem(
                                              value: e["name"],
                                              child: Text(e["name"]));
                                        }).toList(),
                                      );
                                    },
                                  )
                                : walkinpatient,
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    usePatient = false;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitlesTemplate("Buyer Details"),
                        SizedBox(height: 20),
                        walkinpatient,
                      ],
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AERO,
                    ),
                  );
                }
              },
            ),
          ));

          List<Widget> widgetlists = [
            SizedBox(
              height: 20,
            ),
            selectPatientForTransaction,
            SizedBox(
              height: 20,
            ),
            widbuilder,
            SizedBox(
              height: 20,
            ),
            punchWidget,
            SizedBox(
              height: 20,
            ),
            confirmReceipt,
            SizedBox(
              height: 20,
            )
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widgetlists,
          );
        },
      ),
    );

    // ADD CARD DONE -------------------------------------------------

    // SHOW FULL RECEIPT ========================================================

    mainColumn.add(addWidget);

    try {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: mainColumn,
          ),
        ),
      );
    } catch (e) {
      return Container(
        child: Text("$e"),
      );
    }
  }
}
