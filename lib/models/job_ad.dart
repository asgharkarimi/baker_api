class JobAd {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String category;
  final int dailyBags;
  final int salary;
  final String location;
  final String phoneNumber;
  final String description;
  final List<String> images;
  final bool isApproved;
  final int views;
  final DateTime createdAt;

  JobAd({
    required this.id,
    this.userId = '',
    this.userName = '',
    required this.title,
    required this.category,
    required this.dailyBags,
    required this.salary,
    required this.location,
    required this.phoneNumber,
    required this.description,
    this.images = const [],
    this.isApproved = false,
    this.views = 0,
    required this.createdAt,
  });

  factory JobAd.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return JobAd(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? user?['id']?.toString() ?? '',
      userName: user?['name'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      dailyBags: json['dailyBags'] ?? json['daily_bags'] ?? 0,
      salary: json['salary'] ?? 0,
      location: json['location'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
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
      'category': category,
      'dailyBags': dailyBags,
      'salary': salary,
      'location': location,
      'phoneNumber': phoneNumber,
      'description': description,
      'images': images,
    };
  }
}
