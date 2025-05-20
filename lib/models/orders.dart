// order.dart

enum PaymentMethod { cod, upi, card, wallet, netBanking }

String paymentMethodToString(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cod:
      return 'Cash on Delivery';
    case PaymentMethod.upi:
      return 'UPI';
    case PaymentMethod.card:
      return 'Credit/Debit Card';
    case PaymentMethod.wallet:
      return 'Wallet';
    case PaymentMethod.netBanking:
      return 'Net Banking';
  }
}

class Address {
  final String id, name, phone, street, city, state, pincode;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
  });

  @override
  String toString() => '$name, $street, $city, $state - $pincode';
}

class Order {
  final String id;
  final Map<String, dynamic> product;
  final PaymentMethod paymentMethod;
  final Address shippingAddress;
  final DateTime dateTime;

  Order({
    required this.id,
    required this.product,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.dateTime,
  });
}

class OrderRepository {
  OrderRepository._privateConstructor();
  static final OrderRepository _instance =
      OrderRepository._privateConstructor();
  factory OrderRepository() => _instance;

  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(Order order) {
    _orders.add(order);
  }
}
