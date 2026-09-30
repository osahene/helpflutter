import 'dart:async';

import 'package:flutter/material.dart';
import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/core/services/live_location_service.dart';

/// Collapses to nothing when no live-location session is active — this is
/// the only way to tell a session is running and stop it early once the
/// "Alert Sent" dialog (where it was turned on) has been dismissed.
class LiveLocationBanner extends StatefulWidget {
  final double paddingH;
  const LiveLocationBanner({super.key, required this.paddingH});

  @override
  State<LiveLocationBanner> createState() => _LiveLocationBannerState();
}

class _LiveLocationBannerState extends State<LiveLocationBanner> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Re-render every 30s purely to keep the "Xm left" countdown text fresh
    // — LiveLocationService's own notifiers already trigger a rebuild on
    // start/stop, this just covers the time passing in between.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LiveLocationService.isActive,
      builder: (context, active, _) {
        if (!active) return const SizedBox.shrink();

        final expiresAt = LiveLocationService.expiresAt.value;
        final remaining = expiresAt?.difference(DateTime.now());
        final minutesLeft = remaining != null && remaining > Duration.zero
            ? remaining.inMinutes
            : 0;

        return Container(
          margin: EdgeInsets.fromLTRB(widget.paddingH, 10, widget.paddingH, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  minutesLeft > 0
                      ? 'Sharing live location — ${minutesLeft}m left'
                      : 'Sharing live location',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFFB71C1C),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => LiveLocationService.stop(ApiService()),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                child: const Text(
                  'Stop',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFFD32F2F)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
