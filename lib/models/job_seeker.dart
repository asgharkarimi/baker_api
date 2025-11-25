class JobSeeker {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final bool isMarried;
  final List<String> skills;
  final String location;
  final int expectedSalary;
  final double rating;
  final bool isSmoker;
  final bool hasAddiction;
  final DateTime createdAt;

  JobSeeker({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.isMarried,
    required this.skills,
    required this.location,
    required this.expectedSalary,
    this.rating = 0.0,
    this.isSmoker = false,
    this.hasAddiction = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';
}
