import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helpflutter/logic/emergency/emergency_bloc.dart';

class AlertConfirmationScreen extends StatefulWidget {
  final String emergencyType;
  final IconData icon;
  final Color color;

  const AlertConfirmationScreen({
    super.key,
    required this.emergencyType,
    required this.icon,
    required this.color,
  });

  @override
  State<AlertConfirmationScreen> createState() =>
      _AlertConfirmationScreenState();
}

class _AlertConfirmationScreenState extends State<AlertConfirmationScreen> {
  bool _isSending = false;

  Future<void> _sendAlert() async {
    setState(() => _isSending = true);
    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        setState(() => _isSending = false);
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    context.read<EmergencyBloc>().add(
      SendEmergencyAlert(widget.emergencyType, position),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmergencyBloc, EmergencyState>(
      listener: (context, state) {
        if (state is EmergencySent) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Alert Sent'),
              content: const Text(
                'Your emergency alert has been sent to your contacts.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else if (state is EmergencyError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          setState(() => _isSending = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Confirm Alert')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, size: 100, color: widget.color),
                      const SizedBox(height: 20),
                      Text(
                        widget.emergencyType,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Are you sure you want to send this alert?',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSending
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _sendAlert,
                        child: _isSending
                            ? const CircularProgressIndicator()
                            : const Text('Send'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
