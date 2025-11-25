class JobAd {
  final String id;
  final String title;
  final String category;
  final int dailyBags;
  final int salary;
  final String location;
  final String phoneNumber;
  final String description;
  final DateTime createdAt;

  JobAd({
    required this.id,
    required this.title,
    required this.category,
    required this.dailyBags,
    required this.salary,
    required this.location,
    required this.phoneNumber,
    required this.description,
    required this.createdAt,
  });
}
