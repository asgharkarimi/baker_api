class EquipmentAd {
  final String id;
  final String title;
  final String description;
  final int price;
  final String location;
  final String phoneNumber;
  final List<String> images;
  final List<String> videos;
  final DateTime createdAt;

  EquipmentAd({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.phoneNumber,
    required this.images,
    required this.videos,
    required this.createdAt,
  });
}
