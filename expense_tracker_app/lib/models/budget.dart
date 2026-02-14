class Budget {
  final String category;
  final double limit;
  final DateTime month;

  Budget({
    required this.category,
    required this.limit,
    required this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'limit': limit,
      'month': month.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: json['category'],
      limit: json['limit'].toDouble(),
      month: DateTime.parse(json['month']),
    );
  }
}