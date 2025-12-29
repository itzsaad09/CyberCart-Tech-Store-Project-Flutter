class ShippingAddress {
  final String? id;
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String postalCode;
  final String? country;
  final String? phoneNumber;

  const ShippingAddress({
    this.id,
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    required this.postalCode,
    this.country,
    this.phoneNumber,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['_id'],
      fullName: json['fullName'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'],
      postalCode: json['postalCode'] ?? '',
      country: json['country'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country ?? 'Pakistan',
      'phoneNumber': phoneNumber,
    };
  }
}
