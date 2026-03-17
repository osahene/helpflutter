import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/alert_repository.dart';
import 'package:helpflutter/logic/blocs/alert/alert_bloc.dart';

class AlertConfirmationScreen extends StatefulWidget {
  final String situation;
  final IconData situationIcon;
  final Color situationColor;

  const AlertConfirmationScreen({
    super.key,
    required this.situation,
    required this.situationIcon,
    required this.situationColor,
  });

  @override
  State<AlertConfirmationScreen> createState() =>
      _AlertConfirmationScreenState();
}

class _AlertConfirmationScreenState extends State<AlertConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _includeLocation = true;
  late Future<int> _contactsCountFuture;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Use post-frame callback to safely access context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _contactsCountFuture = _getAcceptedContactsCount();
      });
    });
  }

  Future<int> _getAcceptedContactsCount() async {
    final contactRepo = context.read<ContactRepository>();
    final accepted = await contactRepo.getContacts();
    return accepted.length;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AlertBloc(alertRepository: context.read<AlertRepository>()),
      child: BlocListener<AlertBloc, AlertState>(
        listener: (context, state) {
          if (state is AlertSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Alert Sent!'),
                content: const Text(
                  'Your trusted contacts have been notified. Stay safe.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context); // back to home
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is AlertFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Confirm Alert'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.situationColor.withValues(alpha: 0.2),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Animated icon
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + _pulseController.value * 0.1,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.situationColor.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            child: Icon(
                              widget.situationIcon,
                              size: 80,
                              color: widget.situationColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.situation == 'SOS'
                          ? 'EMERGENCY SOS'
                          : widget.situation,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.situationColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This alert will be sent to your trusted contacts.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Location toggle
                    // Card(
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 8,
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Icon(
                    //           Icons.location_on,
                    //           color: widget.situationColor,
                    //         ),
                    //         const SizedBox(width: 12),
                    //         const Expanded(
                    //           child: Text('Share my current location'),
                    //         ),
                    //         Switch(
                    //           value: _includeLocation,
                    //           onChanged: (val) =>
                    //               setState(() => _includeLocation = val),
                    //           activeColor: widget.situationColor,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 16),

                    // Optional message field
                    const SizedBox(height: 20),

                    // Contact count with FutureBuilder
                    FutureBuilder<int>(
                      future: _contactsCountFuture,
                      builder: (context, snapshot) {
                        int count = snapshot.data ?? 0;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: widget.situationColor.withValues(
                              alpha: 0.2,
                            ),
                            child: Icon(
                              Icons.people,
                              color: widget.situationColor,
                            ),
                          ),
                          title:
                              snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const Text('Loading contacts...')
                              : Text('Notify $count trusted contacts'),
                          subtitle: const Text(
                            'All accepted contacts will be alerted',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to contact picker (optional)
                          },
                        );
                      },
                    ),
                    const Spacer(),

                    // Send button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AlertBloc>().add(
                            SendAlert(
                              situation: widget.situation,
                              includeLocation: _includeLocation,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.situationColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'SEND ALERT',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
