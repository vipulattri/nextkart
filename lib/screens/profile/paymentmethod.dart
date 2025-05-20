import 'package:flutter/material.dart';

enum PaymentMethod { cod, upi, card, netBanking, wallet }

class PaymentMethodSelectionScreen extends StatefulWidget {
  final PaymentMethod? selectedMethod;

  const PaymentMethodSelectionScreen({super.key, this.selectedMethod});

  @override
  State<PaymentMethodSelectionScreen> createState() =>
      _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState
    extends State<PaymentMethodSelectionScreen> {
  late PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod ?? PaymentMethod.cod;
  }

  void _onMethodSelected(PaymentMethod? method) {
    setState(() {
      _selectedMethod = method;
    });
  }

  void _confirmSelection() {
    if (_selectedMethod == null) return;

    Navigator.pop(context, _selectedMethod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.cod,
            groupValue: _selectedMethod,
            title: const Text('Cash on Delivery (COD)'),
            onChanged: _onMethodSelected,
            secondary: const Icon(Icons.money),
          ),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.upi,
            groupValue: _selectedMethod,
            title: const Text('UPI'),
            onChanged: _onMethodSelected,
            secondary: const Icon(Icons.account_balance_wallet),
          ),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.card,
            groupValue: _selectedMethod,
            title: const Text('Credit/Debit Card'),
            onChanged: _onMethodSelected,
            secondary: const Icon(Icons.credit_card),
          ),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.netBanking,
            groupValue: _selectedMethod,
            title: const Text('Net Banking'),
            onChanged: _onMethodSelected,
            secondary: const Icon(Icons.account_balance),
          ),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.wallet,
            groupValue: _selectedMethod,
            title: const Text('Wallet'),
            onChanged: _onMethodSelected,
            secondary: const Icon(Icons.account_balance_wallet_outlined),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _selectedMethod != null ? _confirmSelection : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text(
            'Confirm Payment Method',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
