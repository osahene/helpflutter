import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/core/constants/app_constants.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';
import 'package:helpflutter/logic/blocs/live_report/live_report_bloc.dart';

class LiveReportScreen extends StatefulWidget {
  const LiveReportScreen({super.key});

  @override
  State<LiveReportScreen> createState() => _LiveReportScreenState();
}

class _LiveReportScreenState extends State<LiveReportScreen> {
  String? _selectedSituation;
  final _messageController = TextEditingController();
  // For simplicity, we'll just do text reports for now

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LiveReportBloc(repository: context.read<LiveReportRepository>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Live Report')),
        body: BlocListener<LiveReportBloc, LiveReportState>(
          listener: (context, state) {
            if (state is LiveReportSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report sent successfully')),
              );
              Navigator.pop(context);
            } else if (state is LiveReportFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedSituation,
                  items: AppConstants.situations.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedSituation = value),
                  decoration: const InputDecoration(labelText: 'Situation'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Placeholder for recipient selection (contacts or agencies)
                // For now, we'll just have a send button
                ElevatedButton(
                  onPressed: () {
                    if (_selectedSituation != null &&
                        _messageController.text.isNotEmpty) {
                      context.read<LiveReportBloc>().add(
                        SendTextReport(
                          situation: _selectedSituation!,
                          message: _messageController.text,
                          recipientIds: ['emergency'], // dummy
                        ),
                      );
                    }
                  },
                  child: const Text('Send Report'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
