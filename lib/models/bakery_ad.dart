enum BakeryAdType { sale, rent }

class BakeryAd {
  final String id;
  final String title;
  final String description;
  final BakeryAdType type;
  final int? salePrice;
  final int? rentDeposit;
  final int? monthlyRent;
  final String location;
  final String phoneNumber;
  final List<String> images;
  final DateTime createdAt;

  BakeryAd({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.salePrice,
    this.rentDeposit,
    this.monthlyRent,
    required this.location,
    required this.phoneNumber,
    required this.images,
    required this.createdAt,
  });
}
