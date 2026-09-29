import 'package:flutter/material.dart';

class CargoListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargo Management')),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          int risk = (30 + (index % 50));
          bool isHighRisk = risk >= 75;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.inventory, color: isHighRisk ? Colors.red : Colors.green),
              title: Text('CARGO-${1000 + index}'),
              subtitle: Text('Destination: ${index % 2 == 0 ? 'Maitri' : 'Bharati'}\nStatus: IN_TRANSIT'),
              trailing: CircularProgressIndicator(
                value: risk / 100, 
                color: isHighRisk ? Colors.red : (risk > 50 ? Colors.orange : Colors.green),
                backgroundColor: Colors.grey[800],
              ),
              onTap: () {
                // Navigate to detail
              },
            ),
          );
        },
      ),
    );
  }
}
