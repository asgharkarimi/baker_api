class JobCategory {
  final String id;
  final String title;

  JobCategory({required this.id, required this.title});

  static List<JobCategory> getCategories() {
    return [
      JobCategory(id: '1', title: 'شاطر بربری'),
      JobCategory(id: '2', title: 'چونه گیر بربری'),
      JobCategory(id: '3', title: 'خمیرگیر بربری'),
      JobCategory(id: '4', title: 'شاطر لواش'),
      JobCategory(id: '5', title: 'چونه گیر لواش'),
      JobCategory(id: '6', title: 'خمیرگیر لواش'),
    ];
  }
}
