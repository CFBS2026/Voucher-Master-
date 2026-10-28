class Voucher {
  final int? id;
  final String code;
  final String profileName;
  final double price;
  final String generatedAt;

  Voucher({
    this.id,
    required this.code,
    required this.profileName,
    required this.price,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'profileName': profileName,
      'price': price,
      'generatedAt': generatedAt,
    };
  }

  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      id: map['id'],
      code: map['code'],
      profileName: map['profileName'],
      price: map['price'],
      generatedAt: map['generatedAt'],
    );
  }
}
