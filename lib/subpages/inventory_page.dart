import 'package:bionexus_admin/templates.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Material(child: AddInventoryItem())))),
      body: Container(),
    );
  }
}

// class AddInventoryItem extends StatelessWidget {
//   const AddInventoryItem({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: CardTemplate(
//           child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [],
//       )),
//     );
//   }
// }

class AddInventoryItem extends StatefulWidget {
  const AddInventoryItem({Key? key}) : super(key: key);

  @override
  State<AddInventoryItem> createState() => _AddInventoryItemState();
}

class _AddInventoryItemState extends State<AddInventoryItem> {
  final _itemNameController = TextEditingController();
  final _initialStockController = TextEditingController();
  double _price = 0.0;

  @override
  void dispose() {
    _itemNameController.dispose();
    _initialStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _itemNameController,
            decoration: const InputDecoration(
              labelText: "Item Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _initialStockController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Initial Stock",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Text("Price: \$"),
              Expanded(
                child: Stack(
                  children: [
                    // Show current price as text
                    Text(
                      _price.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    // Draggable widget to update price
                    Positioned.fill(
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _price = (_price + details.delta.dx / 10)
                                .clamp(0.0, double.infinity);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Handle form submission logic here
              // Access item name, initial stock, and price from controllers
              final itemName = _itemNameController.text;
              final initialStock =
                  int.tryParse(_initialStockController.text) ?? 0;

              // Add logic to save the inventory item (e.g., to a database)
            },
            child: const Text("Add Item"),
          ),
        ],
      ),
    );
  }
}
