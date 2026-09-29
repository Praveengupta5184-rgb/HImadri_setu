import 'package:flutter/material.dart';

class InventoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Status')),
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          int qty = (50 + (index % 50));
          bool lowStock = qty < 60;
          return Card(
            color: lowStock ? Colors.red.withOpacity(0.1) : null,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Item $index'),
              subtitle: Text('Category: ${index % 3 == 0 ? "Food" : "Medical"} | Station: Maitri'),
              trailing: Chip(
                label: Text('$qty kg'),
                backgroundColor: lowStock ? Colors.red : Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}
