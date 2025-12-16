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
  final double? lat;
  final double? lng;
  final bool isApproved;
  final int views;
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
    this.lat,
    this.lng,
    this.isApproved = false,
    this.views = 0,
    required this.createdAt,
  });

  factory BakeryAd.fromJson(Map<String, dynamic> json) {
    return BakeryAd(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] == 'sale' ? BakeryAdType.sale : BakeryAdType.rent,
      salePrice: json['salePrice'] ?? json['sale_price'],
      rentDeposit: json['rentDeposit'] ?? json['rent_deposit'],
      monthlyRent: json['monthlyRent'] ?? json['monthly_rent'],
      location: json['location'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      isApproved: json['isApproved'] ?? json['is_approved'] ?? false,
      views: json['views'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type == BakeryAdType.sale ? 'sale' : 'rent',
      'salePrice': salePrice,
      'rentDeposit': rentDeposit,
      'monthlyRent': monthlyRent,
      'location': location,
      'phoneNumber': phoneNumber,
      'images': images,
      'lat': lat,
      'lng': lng,
    };
  }
}
