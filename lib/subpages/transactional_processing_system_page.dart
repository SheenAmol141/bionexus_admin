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
            Container(color: CupertinoColors.lightBackgroundGray)
          ]),
        ));
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
  String currentServicesSelected = 'loading';
  String currentItemSelected = 'loading';
  void getfirstService() {
    FirebaseFirestore.instance
        .collection("Teams")
        .doc(widget.teamCode)
        .collection("Medical Services")
        .get()
        .then((value) {
      currentServicesSelected = value.docs.reversed.first["item_name"];
    });
  }

  void getfirstItem() {
    FirebaseFirestore.instance
        .collection("Teams")
        .doc(widget.teamCode)
        .collection("Inventory")
        .get()
        .then((value) {
      currentItemSelected = value.docs.reversed.first["item_name"];
    });
  }

  // getMedServices ============================
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getfirstService();
    getfirstItem();
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
    final customKey = GlobalKey<FormState>();

    Container addWidget = Container(
      child: StatefulBuilder(
        builder: (context, setStateHere) {
          TextEditingController customNameController = TextEditingController();
          TextEditingController customPriceController = TextEditingController();
          TextEditingController customNumberController =
              TextEditingController();
          TextEditingController customDescriptionController =
              TextEditingController();

          void clearCustomForm() {
            setStateHere(
              () {
                customKey.currentState!.reset();
              },
            );
          }

          Widget wid = CardTemplate(
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
                                            numOfItems: int.parse(
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
                                                child: Center(
                                                  child: DropdownButton(
                                                    underline: Container(),
                                                    iconEnabledColor: Colors
                                                        .black
                                                        .withOpacity(0.5),
                                                    value: currentItemSelected,
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
                                                            child: Text(
                                                              e.getItem()[
                                                                  "item_name"],
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ));
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      print(value);
                                                      setStateHere(
                                                        () {
                                                          currentItemSelected =
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
                                                print(_itemSnapshotList);
                                                for (TransactionItem _itemItem
                                                    in _itemSnapshotList) {
                                                  if (_itemItem.getItem()[
                                                          "item_name"] ==
                                                      currentItemSelected) {
                                                    items.add(_itemItem);
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
                              : null,
                )
              ],
            ),
          );

          //BUILD THE ITEMS
          Widget widbuilder = ListView.builder(
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
                              NumberFormat.currency(symbol: '').format(
                                  itemMap["price"] *
                                      itemMap["number_of_items"]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text("${itemMap["number_of_items"]} pc/s"),
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
                              print(items);
                              setStateHere(
                                () {},
                              );
                            },
                            child: Icon(Icons.close_rounded))
                      ],
                    )
                  ],
                ));
              }
              return widget;
            },
          );
          List<Widget> widgetlists = [widbuilder];
          widgetlists.add(wid);
          return Column(
            children: widgetlists,
          );
//           ListView.builder(
//   itemCount: [widbuilder, wid].length,
//   itemBuilder: (_, i) => [widbuilder, wid][i],
// );
        },
      ),
    );

    // ADD CARD DONE -------------------------------------------------

    // SHOW FULL RECEIPT ========================================================

    // SHOW FULL RECEIPT ========================================================

    mainColumn.add(addWidget);

    // return Container(
    //   color: CupertinoColors.extraLightBackgroundGray,
    //   child: ListView.builder(
    //       itemBuilder: (context, index) {
    //         return Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 20),
    //           child: mainColumn[index],
    //         );
    //       },
    //       itemCount: mainColumn.length),

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: CupertinoColors.extraLightBackgroundGray,
      child: SingleChildScrollView(
        child: Column(
          children: mainColumn,
        ),
      ),
    );
  }
}
