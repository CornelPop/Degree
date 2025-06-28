import 'package:flutter_test/flutter_test.dart';
import 'package:hand_controller_app/ProfileFeature/models/Rating.dart';
import 'package:hand_controller_app/ProfileFeature/services/mock_rating_service.dart';

void main() {
  late MockRatingService service;

  setUp(() {
    service = MockRatingService();
  });

  test('addRating adds new rating and replaces existing one', () async {
    final rating = createRating(senderId: 'u1', receiverId: 'd1', stars: 4);
    await service.addRating(rating);
    await service.addRating(createRating(senderId: 'u1', receiverId: 'd1', stars: 5));

    final result = await service.getRatingsByDoctorId('d1');
    expect(result.length, 1);
    expect(result.first.starsNumber, 5);
  });

  test('getRatingsByDoctorId returns correct ratings', () async {
    await service.addRating(createRating(senderId: 'u1', receiverId: 'd1'));
    await service.addRating(createRating(senderId: 'u2', receiverId: 'd1'));
    await service.addRating(createRating(senderId: 'u3', receiverId: 'd2'));

    final result = await service.getRatingsByDoctorId('d1');
    expect(result.length, 2);
  });

  test('deleteRating removes rating', () async {
    await service.addRating(createRating(senderId: 'u1', receiverId: 'd1'));
    final ratings = await service.getRatingsByDoctorId('d1');
    final id = ratings.first.ratingId;
    await service.deleteRating(id);

    final after = await service.getRatingsByDoctorId('d1');
    expect(after.isEmpty, true);
  });

}

Rating createRating({
  String id = '',
  String senderId = 'u1',
  String receiverId = 'd1',
  int stars = 3,
}) {
  return Rating(
    ratingId: id,
    ratingReceiverId: receiverId,
    ratingSenderId: senderId,
    starsNumber: stars,
  );
}
