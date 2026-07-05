class EventCategory {
  final int categoryID;
  final String categoryName;

  EventCategory({
    required this.categoryID,
    required this.categoryName,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      categoryID: json['categoryID'],
      categoryName: json['categoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryID': categoryID,
      'categoryName': categoryName,
    };
  }
}