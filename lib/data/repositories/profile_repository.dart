import 'package:helpflutter/data/models/user.dart';
import 'package:helpflutter/data/models/request_history.dart';

abstract class ProfileRepository {
  Future<User> getUserProfile();
  Future<List<RequestHistory>> getRequestHistory();
}

class MockProfileRepository implements ProfileRepository {
  @override
  Future<User> getUserProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    return User(
      id: '1',
      fullName: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+233501234567',
      profileImageUrl: 'https://via.placeholder.com/150',
    );
  }

  @override
  Future<List<RequestHistory>> getRequestHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      RequestHistory(
        id: 'h1',
        situation: 'Fire',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        notifiedContacts: ['Jane Smith', 'Police'],
        status: 'Sent',
      ),
      RequestHistory(
        id: 'h2',
        situation: 'Accident',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        notifiedContacts: ['John Doe'],
        status: 'Sent',
      ),
    ];
  }
}
