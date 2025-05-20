import 'package:flutter/material.dart';
import 'package:nexkart6/screens/profile/addaddress.dart';
import 'package:provider/provider.dart';
import 'package:nexkart6/providers/adress_provider.dart'; // your AddAddressScreen import

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          addresses.isEmpty
              ? Center(
                child: Text(
                  'No saved addresses yet.',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(address.name),
                      subtitle: Text(
                        '${address.street}, ${address.city}, ${address.state} - ${address.pincode}\nPhone: ${address.phone}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.deepPurple),
                        onPressed: () {
                          // Edit existing address
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddAddressScreen(
                                    existingAddress: address,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to add new address screen without existing address
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
          );
        },
      ),
    );
  }
}
