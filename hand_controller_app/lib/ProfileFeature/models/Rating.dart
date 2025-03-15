class Rating {
  String ratingId;
  String ratingReceiverId;
  String ratingSenderId;
  int starsNumber;

  Rating({required this.ratingSenderId, required this.starsNumber, required this.ratingId, required this.ratingReceiverId});

  Map<String, dynamic> toMap() {
    return {
      'ratingSenderId': ratingSenderId,
      'ratingReceiverId': ratingReceiverId,
      'starsNumber': starsNumber,
      'ratingId': ratingId,
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map, String id) {
    return Rating(
      ratingReceiverId: map['ratingReceiverId'],
      ratingSenderId: map['ratingSenderId'],
      starsNumber: map['starsNumber'],
      ratingId: id,
    );
  }

}
