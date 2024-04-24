// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';

class TPS extends StatelessWidget {
  const TPS({super.key});

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
            NewTransaction(),
            Container(color: CupertinoColors.lightBackgroundGray)
          ]),
        ));
  }
}

//NEW TRANSACTION ---------------------------------------------------------------------------------
class NewTransaction extends StatefulWidget {
  const NewTransaction({
    super.key,
  });

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  List<Widget> items = [
    Container(
      height: 20,
    ),
  ];

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

          Widget wid = CardTemplate(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      ButtonSegment(value: "service", label: Text("Service")),
                      ButtonSegment(value: "item", label: Text("Item"))
                    ],
                    selected: currentSelected),
                Container(
                  child: currentSelected.first == "custom"
                      ? Form(
                          key: customKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                "Add a Custom Item/Service",
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
                                  Text("Is this a Service?")
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: "Item Name"),
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
                                    : null,
                              ),
                              Container(
                                child: !service
                                    ? SizedBox(
                                        height: 20,
                                      )
                                    : null,
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
                                decoration: InputDecoration(hintText: "Price"),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                )
              ],
            ),
          );

          return wid;
        },
      ),
    );
    items.add(addWidget);

    return Container(
      color: CupertinoColors.extraLightBackgroundGray,
      child: ListView.builder(
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: items[index],
            );
          },
          itemCount: items.length),
    );
  }
}
