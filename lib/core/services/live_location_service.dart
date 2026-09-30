import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helpflutter/core/constants/api_service.dart';

/// Opt-in continuous location sharing for an active alert — off by default
/// (a trigger only ever captures one point, see AlertRepositoryImpl). This
/// is what AlertConfirmationScreen's "Share Live Location" switch turns on.
///
/// Foreground-only: this polls Geolocator while the app is alive in the
/// foreground and stops if the process is killed — it does NOT survive the
/// screen being locked or the app being fully backgrounded for long
/// stretches, because that needs a real Android/iOS foreground-location
/// service (its own manifest permissions, a persistent notification, and
/// Play Console's background-location policy declaration), which is a
/// separate, larger piece of work, not built here. The backend independently
/// auto-expires the window after Emergency.LIVE_LOCATION_DURATION regardless
/// of what this client does, so a killed app never leaves it silently "on"
/// server-side.
///
/// A plain static class, not a singleton instance — there is only ever at
/// most one live-location session running on this device at a time (mirrors
/// PushService's style), and any screen can check [isActive]/[expiresAt]
/// without needing to be handed a reference to anything.
class LiveLocationService {
  LiveLocationService._();

  static const Duration _updateInterval = Duration(seconds: 20);

  static final ValueNotifier<bool> isActive = ValueNotifier<bool>(false);
  static final ValueNotifier<DateTime?> expiresAt =
      ValueNotifier<DateTime?>(null);

  static String? _emergencyId;
  static Timer? _updateTimer;
  static Timer? _expiryTimer;

  static Future<void> start(String emergencyId, ApiService apiService) async {
    if (isActive.value) await stop(apiService);

    try {
      final response = await apiService.startLiveLocation(emergencyId);
      final expiresAtStr = response.data['live_location_expires_at'] as String?;
      expiresAt.value = expiresAtStr != null ? DateTime.parse(expiresAtStr) : null;
    } catch (e) {
      debugPrint('LiveLocationService.start failed: $e');
      return;
    }

    _emergencyId = emergencyId;
    isActive.value = true;

    _updateTimer = Timer.periodic(_updateInterval, (_) => _pushUpdate(apiService));
    _pushUpdate(apiService); // don't wait a full interval for the first point

    final remaining = expiresAt.value?.difference(DateTime.now());
    _expiryTimer = Timer(
      remaining != null && remaining > Duration.zero ? remaining : const Duration(hours: 1),
      () => stop(apiService),
    );
  }

  static Future<void> _pushUpdate(ApiService apiService) async {
    final emergencyId = _emergencyId;
    if (emergencyId == null) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      await apiService.updateLiveLocation(
        emergencyId,
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      // A single missed update is not worth surfacing to the user — the
      // next tick tries again, and the backend's own 1-hour expiry is the
      // real safety net regardless of how many updates land.
      debugPrint('LiveLocationService update failed: $e');
    }
  }

  static Future<void> stop(ApiService apiService) async {
    final emergencyId = _emergencyId;
    _updateTimer?.cancel();
    _expiryTimer?.cancel();
    _updateTimer = null;
    _expiryTimer = null;
    _emergencyId = null;
    isActive.value = false;
    expiresAt.value = null;

    if (emergencyId != null) {
      try {
        await apiService.stopLiveLocation(emergencyId);
      } catch (e) {
        debugPrint('LiveLocationService.stop failed: $e');
      }
    }
  }
}
