import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/data/models/titbit.dart';

abstract class TitbitRepository {
  /// A page of the signed-in user's Titbit inbox (weather tips, hazard
  /// warnings, seasonal advisories, admin campaigns, system notices).
  Future<TitbitPage> getTitbits({int page = 1, String? category, bool? unread});

  /// The count of unread Titbits, for the dashboard bell badge.
  Future<int> getUnreadCount();

  /// Marks a single Titbit as read and returns the updated record.
  Future<Titbit> markRead(String id);

  /// Registers this device's FCM token with the backend so it can receive
  /// push notifications.
  Future<void> registerDevice(String token, String platform);

  /// Unregisters a device token (e.g. on logout).
  Future<void> unregisterDevice(String token);
}

class TitbitRepositoryImpl implements TitbitRepository {
  final ApiService apiService;

  TitbitRepositoryImpl({required this.apiService});

  @override
  Future<TitbitPage> getTitbits({
    int page = 1,
    String? category,
    bool? unread,
  }) async {
    final response = await apiService.getTitbits(
      page: page,
      category: category,
      unread: unread,
    );
    return TitbitPage.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await apiService.getUnreadTitbitCount();
    final data = response.data as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }

  @override
  Future<Titbit> markRead(String id) async {
    final response = await apiService.markTitbitRead(id);
    return Titbit.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> registerDevice(String token, String platform) async {
    await apiService.registerDevice(token, platform);
  }

  @override
  Future<void> unregisterDevice(String token) async {
    await apiService.unregisterDevice(token);
  }
}
