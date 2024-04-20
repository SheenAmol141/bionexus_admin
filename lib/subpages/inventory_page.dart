import 'package:bionexus_admin/db_helper.dart';
import 'package:bionexus_admin/hex_color.dart';
import 'package:bionexus_admin/main.dart';
import 'package:bionexus_admin/templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    void getInventory() {} // TODO: INVENTORY

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: AERO,
          foregroundColor: Colors.white,
          focusColor: EMERALD,
          hoverColor: EMERALD,
          child: Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  const Material(child: AddInventoryItem())))),
      body: ListView.separated(
          itemBuilder: (context, index) {},
          separatorBuilder: (context, index) => SizedBox(
                height: 20,
              ),
          itemCount: itemCount),
    );
  }
}

class AddInventoryItem extends StatelessWidget {
  const AddInventoryItem({super.key});

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
            children: [
              TextFormField(
                controller: _itemName,
                decoration: InputDecoration(hintText: "Item Name"),
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
                decoration: InputDecoration(hintText: "Initial Stock"),
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
