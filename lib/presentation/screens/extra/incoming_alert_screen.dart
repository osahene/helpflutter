import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:helpflutter/data/models/incoming_alert.dart';
import 'package:helpflutter/data/repositories/incoming_alert_repository.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// A full-screen, "incoming call"-style interrupt shown when this device
/// receives a push notification with `type: incoming_alert` — one of the
/// user's emergency contacts has triggered an emergency alert and this
/// device is a registered, approved recipient.
///
/// Pushed with the emergency id carried in the notification payload; fetches
/// the rest of the detail itself via `GET /account/incoming-alert/<id>/`.
class IncomingAlertScreen extends StatefulWidget {
  final String emergencyId;

  const IncomingAlertScreen({super.key, required this.emergencyId});

  @override
  State<IncomingAlertScreen> createState() => _IncomingAlertScreenState();
}

enum _VerifyStatus { idle, loading, success, error }

class _IncomingAlertScreenState extends State<IncomingAlertScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _loadError;
  IncomingAlert? _alert;

  _VerifyStatus _verifyStatus = _VerifyStatus.idle;
  String? _verifyError;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect reduced-motion: only animate if the platform allows it. This
    // is re-checked here (not just in initState) since MediaQuery isn't
    // available yet at initState time.
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _pulseController.stop();
      _pulseController.value = 0;
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final repository = context.read<IncomingAlertRepository>();
      final alert = await repository.getIncomingAlert(widget.emergencyId);
      if (!mounted) return;
      setState(() {
        _alert = alert;
        _loading = false;
        _verifyStatus = alert.isVerified
            ? _VerifyStatus.success
            : _VerifyStatus.idle;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      setState(() {
        _loading = false;
        _loadError = status == 404
            ? "This alert isn't available — it may have already been "
                  'resolved, or your device isn\'t a recipient for it.'
            : 'Could not load this alert. Check your connection and try again.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load this alert. Check your connection and try again.';
      });
    }
  }

  Future<void> _verify() async {
    final alert = _alert;
    if (alert == null || alert.alertCode.isEmpty) return;
    setState(() {
      _verifyStatus = _VerifyStatus.loading;
      _verifyError = null;
    });
    try {
      final repository = context.read<IncomingAlertRepository>();
      await repository.verifyAlert(alert.alertCode);
      if (!mounted) return;
      setState(() => _verifyStatus = _VerifyStatus.success);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verifyStatus = _VerifyStatus.error;
        _verifyError = 'Could not verify — check your connection and try again.';
      });
    }
  }

  Future<void> _call(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _requestClose() async {
    if (_verifyStatus == _VerifyStatus.success) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave without verifying?'),
        content: const Text(
          "Tapping \"I've seen this\" lets your contact know you're aware "
          "of their alert. You can still close this without verifying.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Close anyway'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestClose();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A0505),
        body: SafeArea(
          child: _loading
              ? const _LoadingBody()
              : _loadError != null
              ? _ErrorBody(message: _loadError!, onDismiss: _requestClose)
              : _buildLoaded(context, _alert!),
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, IncomingAlert alert) {
    final meta = _situationMetaFor(alert.situation);
    final firstName = alert.reporter.name.trim().isEmpty
        ? 'them'
        : alert.reporter.name.trim().split(RegExp(r'\s+')).first;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 16),
                child: Column(
                  children: [
                    _IncomingBadge(color: meta.color, controller: _pulseController),
                    const SizedBox(height: 28),
                    _PulsingAvatar(
                      controller: _pulseController,
                      color: meta.color,
                      initials: _initialsOf(alert.reporter.name),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      alert.reporter.name.trim().isEmpty
                          ? 'Someone near you'
                          : alert.reporter.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'needs help — ${_relativeTime(alert.createdAt)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SituationBadge(meta: meta, label: alert.situationDisplay),
                    const SizedBox(height: 24),
                    _LocationSection(alert: alert),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _ActionBar(
              status: _verifyStatus,
              verifyError: _verifyError,
              onVerify: _verify,
              onCall: alert.reporter.phone.isEmpty
                  ? null
                  : () => _call(alert.reporter.phone),
              callLabel: 'Call $firstName',
              onNotNow: _requestClose,
            ),
          ],
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _CloseButton(onTap: _requestClose),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Situation visual identity — mirrors the color/icon language used for
// alert-type badges elsewhere in the app (e.g. the national-emergency
// service cards), extended to cover every backend alert type.
// ─────────────────────────────────────────────────────────────────────────

class _SituationMeta {
  final Color color;
  final IconData icon;
  const _SituationMeta(this.color, this.icon);
}

_SituationMeta _situationMetaFor(String situation) {
  switch (situation) {
    case 'fire':
      return const _SituationMeta(Color(0xFFE8500A), Icons.local_fire_department_rounded);
    case 'health':
      return const _SituationMeta(Color(0xFF1A9E5C), Icons.health_and_safety_rounded);
    case 'robbery':
      return const _SituationMeta(Color(0xFF8A1C1C), Icons.security_rounded);
    case 'violence':
      return const _SituationMeta(Color(0xFFB71C1C), Icons.warning_amber_rounded);
    case 'flood':
      return const _SituationMeta(Color(0xFF1976D2), Icons.water_damage_rounded);
    case 'other':
    default:
      return const _SituationMeta(Color(0xFF6B7280), Icons.emergency_rounded);
  }
}

// Note: `.characters` below comes from package:characters (re-exported by
// flutter/widgets.dart), which handles multi-codepoint grapheme clusters
// correctly — unlike indexing a String by UTF-16 code unit.
String _initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
}

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().toUtc().difference(dt.toUtc());
  if (diff.inSeconds < 5) return 'just now';
  if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

// ─────────────────────────────────────────────────────────────────────────
// Loading / error states
// ─────────────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Loading alert…',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBody({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white70, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onDismiss,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Dismiss'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Header badge + pulsing avatar
// ─────────────────────────────────────────────────────────────────────────

class _IncomingBadge extends StatelessWidget {
  final Color color;
  final AnimationController controller;

  const _IncomingBadge({required this.color, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.isAnimating ? controller.value : 1.0;
        return Opacity(
          opacity: 0.65 + (0.35 * t),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text(
              'INCOMING ALERT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingAvatar extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final String initials;

  const _PulsingAvatar({
    required this.controller,
    required this.color,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.isAnimating ? controller.value : 0.0;
        final ringScale = 1.0 + (t * 0.28);
        final ringOpacity = (1 - t) * 0.45;
        return SizedBox(
          width: 168,
          height: 168,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: ringOpacity),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 28, spreadRadius: 2),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SituationBadge extends StatelessWidget {
  final _SituationMeta meta;
  final String label;

  const _SituationBadge({required this.meta, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Location: embedded map or "not yet available" placeholder
// ─────────────────────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  final IncomingAlert alert;

  const _LocationSection({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_rounded, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                alert.locationDisplay,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: alert.location != null
                ? _AlertMap(location: alert.location!)
                : const _NoLocationPlaceholder(),
          ),
        ),
      ],
    );
  }
}

class _AlertMap extends StatelessWidget {
  final AlertLocation location;

  const _AlertMap({required this.location});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(location.latitude, location.longitude);
    return FlutterMap(
      options: MapOptions(initialCenter: point, initialZoom: 15),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.helpoohelp.helpflutter',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 44,
              height: 44,
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFFE53935),
                size: 44,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NoLocationPlaceholder extends StatelessWidget {
  const _NoLocationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.06),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_rounded, color: Colors.white.withValues(alpha: 0.5), size: 28),
          const SizedBox(height: 8),
          Text(
            'Location not yet available',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Bottom action bar
// ─────────────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final _VerifyStatus status;
  final String? verifyError;
  final VoidCallback onVerify;
  final VoidCallback? onCall;
  final String callLabel;
  final VoidCallback onNotNow;

  const _ActionBar({
    required this.status,
    required this.verifyError,
    required this.onVerify,
    required this.onCall,
    required this.callLabel,
    required this.onNotNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (verifyError != null) ...[
            Text(
              verifyError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: status == _VerifyStatus.loading || status == _VerifyStatus.success
                  ? null
                  : onVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: status == _VerifyStatus.success
                    ? const Color(0xFF1A9E5C)
                    : Colors.white,
                disabledBackgroundColor: status == _VerifyStatus.success
                    ? const Color(0xFF1A9E5C)
                    : Colors.white70,
                foregroundColor: status == _VerifyStatus.success
                    ? Colors.white
                    : const Color(0xFF1A0505),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _buildVerifyLabel(status),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.call_rounded, size: 18),
              label: Text(callLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onNotNow,
            child: Text(
              status == _VerifyStatus.success ? 'Close' : 'Not now',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyLabel(_VerifyStatus status) {
    switch (status) {
      case _VerifyStatus.loading:
        return const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        );
      case _VerifyStatus.success:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 20),
            SizedBox(width: 8),
            Text('Verified', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
          ],
        );
      case _VerifyStatus.error:
        return const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5));
      case _VerifyStatus.idle:
        return const Text(
          "I've seen this",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
        );
    }
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.close_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
