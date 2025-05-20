class Address {
  final String id;
  final String name;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'street': street,
    'city': city,
    'state': state,
    'pincode': pincode,
    'isDefault': isDefault,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    street: json['street'],
    city: json['city'],
    state: json['state'],
    pincode: json['pincode'],
    isDefault: json['isDefault'] ?? false,
  );
}
