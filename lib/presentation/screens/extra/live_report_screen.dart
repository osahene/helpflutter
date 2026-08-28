import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/data/models/agency.dart';
import 'package:helpflutter/data/models/live_report.dart';
import 'package:helpflutter/data/repositories/agency_repository.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';
import 'package:helpflutter/logic/live_report/live_report_bloc.dart';

class MediaAttachment {
  final String path;
  final String type; // 'image' | 'video' | 'audio'

  MediaAttachment({required this.path, required this.type});
}

class LiveReportScreen extends StatefulWidget {
  const LiveReportScreen({super.key});

  @override
  State<LiveReportScreen> createState() => _LiveReportScreenState();
}

class _LiveReportScreenState extends State<LiveReportScreen> {
  String? _selectedSituation;
  final _messageController = TextEditingController();
  final Set<String> _selectedAgencyIds = {};
  final List<MediaAttachment> _mediaAttachments = [];
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  List<Agency>? _agencies;
  String? _agenciesError;

  @override
  void initState() {
    super.initState();
    _loadAgencies();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _loadAgencies() async {
    setState(() => _agenciesError = null);
    try {
      final agencies = await context.read<AgencyRepository>().getAgencies();
      if (!mounted) return;
      setState(() => _agencies = agencies);
    } catch (e) {
      if (!mounted) return;
      setState(() => _agenciesError = 'Could not load agencies. Pull to retry.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) =>
          LiveReportBloc(repository: context.read<LiveReportRepository>()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Report'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: BlocListener<LiveReportBloc, LiveReportState>(
          listener: (context, state) {
            if (state is LiveReportSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report sent successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            } else if (state is LiveReportFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Situation dropdown
                const Text(
                  'Situation',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSituation,
                  items: AppConstants.situations.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedSituation = value),
                  decoration: InputDecoration(
                    hintText: 'Select situation',
                    prefixIcon: const Icon(Icons.warning_amber_rounded),
                    filled: true,
                    fillColor: theme.cardTheme.color,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Agency selection
                const Text(
                  'Notify Agencies',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildAgencySelector(theme),
                const SizedBox(height: 24),

                // Media attachments
                const Text(
                  'Attachments (optional)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMediaButton(
                      icon: Icons.photo_camera,
                      label: 'Photo',
                      onTap: () => _pickImageOrVideo(isVideo: false),
                    ),
                    const SizedBox(width: 12),
                    _buildMediaButton(
                      icon: Icons.videocam,
                      label: 'Video',
                      onTap: () => _pickImageOrVideo(isVideo: true),
                    ),
                    const SizedBox(width: 12),
                    _buildMediaButton(
                      icon: _isRecording ? Icons.stop_circle : Icons.mic,
                      label: _isRecording ? 'Stop' : 'Audio',
                      highlighted: _isRecording,
                      onTap: _toggleAudioRecording,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Preview of selected media
                if (_mediaAttachments.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mediaAttachments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final media = _mediaAttachments[index];
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade200,
                                image: media.type == 'image'
                                    ? DecorationImage(
                                        image: FileImage(File(media.path)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: media.type != 'image'
                                  ? Center(
                                      child: Icon(
                                        media.type == 'video'
                                            ? Icons.videocam
                                            : Icons.audiotrack,
                                        size: 40,
                                        color: theme.colorScheme.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _mediaAttachments.removeAt(index),
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),

                // Message field
                const Text(
                  'Additional Message (optional)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe the situation...',
                    filled: true,
                    fillColor: theme.cardTheme.color,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Send button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: BlocBuilder<LiveReportBloc, LiveReportState>(
                    builder: (context, state) {
                      final canSend = _selectedSituation != null &&
                          _selectedAgencyIds.isNotEmpty &&
                          state is! LiveReportLoading;
                      return ElevatedButton(
                        onPressed: canSend
                            ? () {
                                context.read<LiveReportBloc>().add(
                                  SendLiveReport(
                                    situation: _selectedSituation!,
                                    message: _messageController.text,
                                    agencyIds: _selectedAgencyIds.toList(),
                                    media: _mediaAttachments
                                        .map((e) => LiveReportMedia(
                                              path: e.path,
                                              type: e.type,
                                            ))
                                        .toList(),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: state is LiveReportLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Send Report',
                                style: TextStyle(fontSize: 18),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgencySelector(ThemeData theme) {
    if (_agenciesError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_agenciesError!, style: TextStyle(color: theme.colorScheme.error)),
          TextButton(onPressed: _loadAgencies, child: const Text('Retry')),
        ],
      );
    }

    if (_agencies == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    final agencies = _agencies!;
    if (agencies.isEmpty) {
      return const Text('No agencies are available to notify right now.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _selectedAgencyIds.length == agencies.length,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedAgencyIds
                      ..clear()
                      ..addAll(agencies.map((a) => a.id));
                  } else {
                    _selectedAgencyIds.clear();
                  }
                });
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: theme.colorScheme.primary,
            ),
            ...agencies.map((agency) {
              final isSelected = _selectedAgencyIds.contains(agency.id);
              return FilterChip(
                label: Text(agency.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAgencyIds.add(agency.id);
                    } else {
                      _selectedAgencyIds.remove(agency.id);
                    }
                  });
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                checkmarkColor: theme.colorScheme.primary,
                avatar: Text(agency.icon, style: const TextStyle(fontSize: 16)),
              );
            }),
          ],
        ),
        if (_selectedAgencyIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Select at least one agency',
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: highlighted
                ? theme.colorScheme.error.withValues(alpha: 0.1)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: highlighted ? theme.colorScheme.error : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: highlighted ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageOrVideo({required bool isVideo}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(isVideo ? Icons.videocam : Icons.photo_camera),
              title: Text(isVideo ? 'Record video' : 'Take photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final pickedFile = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _mediaAttachments.add(
          MediaAttachment(
            path: pickedFile.path,
            type: isVideo ? 'video' : 'image',
          ),
        );
      });
    }
  }

  Future<void> _toggleAudioRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        setState(() {
          _mediaAttachments.add(MediaAttachment(path: path, type: 'audio'));
        });
      }
      return;
    }

    if (!await _audioRecorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required to record a voice note')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/live_report_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    setState(() => _isRecording = true);
  }
}
