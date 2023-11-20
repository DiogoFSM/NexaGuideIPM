class Review {
  final String username;
  final String placeName;
  final double rating;
  final String reviewText;

  Review({
    required this.username,
    required this.placeName,
    required this.rating,
    required this.reviewText,
  });

  factory Review.fromSqfliteDatabase(Map<String, dynamic> map) => Review(
      username: map['username'] ?? '',
      placeName: map['placeName'] ?? '',
      rating: map['rating']?.toDouble() ?? 0,
      reviewText: map['reviewText'] ?? '',
  );

  @override
  String toString() {
    return "[$username] $placeName ($rating)";
  }
}