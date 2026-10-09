import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:helpflutter/data/models/incoming_alert.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// A boxed, non-interactive map preview of where an alert was raised, with an
/// expand button that opens [AlertMapFullScreen]. Used in the Updates inbox
/// for alert notifications (mirrors the map box in HelpAdminNuxt's alert
/// detail).
class AlertMapPreview extends StatelessWidget {
  final AlertLocation location;
  final String title;
  final String? mapsLink;

  const AlertMapPreview({
    super.key,
    required this.location,
    required this.title,
    this.mapsLink,
  });

  void _expand(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AlertMapFullScreen(
          location: location,
          title: title,
          mapsLink: mapsLink,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 190,
        child: Stack(
          children: [
            // Taps anywhere on the preview expand it, rather than panning a
            // tiny map inside a scrolling sheet.
            Positioned.fill(
              child: AbsorbPointer(child: _AlertMap(location: location, zoom: 15)),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: () => _expand(context)),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 2,
                child: IconButton(
                  tooltip: 'View full screen',
                  icon: const Icon(Icons.fullscreen_rounded),
                  onPressed: () => _expand(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen, pannable/zoomable map of an alert's location.
class AlertMapFullScreen extends StatelessWidget {
  final AlertLocation location;
  final String title;
  final String? mapsLink;

  const AlertMapFullScreen({
    super.key,
    required this.location,
    required this.title,
    this.mapsLink,
  });

  Future<void> _openInMaps(BuildContext context) async {
    final link = mapsLink ??
        'https://www.google.com/maps/search/?api=1&query='
            '${location.latitude},${location.longitude}';
    final opened = await launchUrl(
      Uri.parse(link),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _AlertMap(location: location, zoom: 16),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openInMaps(context),
        icon: const Icon(Icons.directions_rounded),
        label: const Text('Open in Google Maps'),
      ),
    );
  }
}

class _AlertMap extends StatelessWidget {
  final AlertLocation location;
  final double zoom;

  const _AlertMap({required this.location, required this.zoom});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(location.latitude, location.longitude);
    return FlutterMap(
      options: MapOptions(initialCenter: point, initialZoom: zoom),
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
              alignment: Alignment.topCenter,
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
