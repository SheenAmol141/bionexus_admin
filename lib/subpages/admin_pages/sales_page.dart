import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/main.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

final firebase = FirebaseFirestore.instance;

class _SalesPageState extends State<SalesPage> {
  CollectionReference mainref = firebase.collection("Sales");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CardTemplate(
                child: Column(
                  children: [
                    SectionTitlesTemplate("Sales per Month"),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: AspectRatio(
                        aspectRatio: 16 / 11,
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("Sales")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(color: AERO),
                                );
                              } else {
                                List<SalesData> sales = [];
                                for (DocumentSnapshot doc
                                    in snapshot.data!.docs.reversed.toList()) {
                                  String name = doc.id;
                                  double price = doc["income"];
                                  print(doc["income"]);
                                  sales.add(SalesData(name, price));
                                }
                                return SFChart(sales);
                              }
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SFChart extends StatelessWidget {
  List<SalesData> salesarray;
  SFChart(this.salesarray, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
                child: SfCartesianChart(
                    // Initialize category axis
                    primaryXAxis: CategoryAxis(),
                    series: [
          FastLineSeries<SalesData, String>(
              // Bind data source
              dataSource: salesarray,
              xValueMapper: (SalesData sales, _) => sales.year,
              yValueMapper: (SalesData sales, _) => sales.sales)
        ]))));
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}
