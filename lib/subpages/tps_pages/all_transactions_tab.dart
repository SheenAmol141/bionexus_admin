// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AllTransactions extends StatefulWidget {
  AllTransactions(this.scafcontext, {super.key, required this.teamCode});
  String teamCode;
  BuildContext scafcontext;

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Teams")
            .doc(widget.teamCode)
            .collection("Transactions")
            .orderBy("time_of_transaction", descending: false)
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
                List<DocumentSnapshot> docs = [];
                docs = snapshot.data!.docs.reversed.toList();

                if (docs.isEmpty) {
                  return Container(
                    child: Center(
                      child: Text("No transactions found"),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                        child: ListView.separated(
                      itemBuilder: (context, index) {
                        DocumentSnapshot currentDoc = docs[index];
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentDoc["name"] != ''
                                            ? "$datetime - $dateminutetime | ${currentDoc["name"]}"
                                            : "$datetime - $dateminutetime | anonymous",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
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
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                ReceiptDetailsPage(
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
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AERO,
                                    ),
                                  ),
                                );
                              }
                            });
                      },
                      separatorBuilder: (context, index) => SizedBox(
                        height: 20,
                      ),
                      itemCount: docs.length,
                    )),
                  );
                }
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

class ReceiptDetailsPage extends StatelessWidget {
  ReceiptDetailsPage(this.doc, this.teamCode,
      {super.key, required this.walkin, required this.total});
  DocumentSnapshot doc;
  String teamCode;
  bool walkin;
  double total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: EMERALD,
        title: Text("Receipt Details"),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Teams")
                  .doc(teamCode)
                  .collection("Transactions")
                  .doc(doc.id)
                  .collection("Items")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AERO,
                    ),
                  );
                } else {
                  List<TransactionItem> _items = [];
                  for (DocumentSnapshot _doc
                      in snapshot.data!.docs.reversed.toList()) {
                    if (_doc["service"]) {
                      _items.add(TransactionItem(
                          itemName: _doc["item_name"],
                          price: double.parse(_doc["price"].toString()),
                          service: true,
                          description: _doc["description"]));
                    } else {
                      _items.add(TransactionItem(
                          itemName: _doc["item_name"],
                          price: double.parse(_doc["price"].toString()),
                          service: false,
                          numBuying: _doc["buyNum"]));
                    }
                    print(_doc["item_name"]);
                  }

                  return Column(
                    children: [
                      SectionTitlesTemplate(("Items/Services included")),
                      SizedBox(
                        height: 20,
                      ),
                      ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            TransactionItem currentItem = _items[index];
                            if (currentItem.ifService()) {
                              return CardTemplate(
                                  child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Medical Service: ${currentItem.getService()["item_name"]}",
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              size: 20,
                                            ),
                                            Text(
                                              NumberFormat.currency(symbol: '')
                                                  .format(currentItem
                                                      .getService()["price"]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(
                                        "${currentItem.getService()["description"]}"),
                                  ],
                                ),
                              ));
                            } else {
                              return CardTemplate(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Item: ${currentItem.getItem()["item_name"]}",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.attach_money,
                                            size: 20,
                                          ),
                                          Text(
                                            NumberFormat.currency(symbol: '')
                                                .format(currentItem
                                                        .getItem()["price"] *
                                                    currentItem
                                                        .getItem()["buyNum"]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          "${currentItem.getItem()["buyNum"]} pc/s"),
                                      Text("  x "),
                                      Icon(
                                        Icons.attach_money,
                                        size: 16,
                                      ),
                                      Text(
                                        NumberFormat.currency(symbol: '')
                                                .format(currentItem
                                                    .getItem()["price"]) +
                                            " per pc",
                                      ),
                                    ],
                                  ),
                                ],
                              ));
                            }
                          },
                          separatorBuilder: (context, index) => SizedBox(
                                height: 20,
                              ),
                          itemCount: _items.length),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          child: walkin
                              ? CardTemplate(
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Total:",
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          "${NumberFormat.currency(symbol: '\$ ').format(total)} ",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Time of Transaction: ${DateFormat("MMMM dd, yyyy").format(doc["time_of_transaction"].toDate())} ${DateFormat.jm().format(doc["time_of_transaction"].toDate()).toString()}",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Text(
                                            "This is a Walk In Transaction",
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 17),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "Name: ${doc["name"].toString().isEmpty ? "anonymous" : doc["name"]}",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17),
                                    )
                                  ],
                                ))
                              : CardTemplate(
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Total:",
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          "${NumberFormat.currency(symbol: '\$ ').format(total)} ",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Time of Transaction: ${DateFormat("MMMM dd, yyyy").format(doc["time_of_transaction"].toDate())} ${DateFormat.jm().format(doc["time_of_transaction"].toDate()).toString()}",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Name: ${doc["name"].toString().isEmpty ? "anonymous" : doc["name"]}",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17),
                                    )
                                  ],
                                ))),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }
}
