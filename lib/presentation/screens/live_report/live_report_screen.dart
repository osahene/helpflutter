import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:helpflutter/core/constants/app_constants.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';
import 'package:helpflutter/logic/blocs/live_report/live_report_bloc.dart';

enum MediaType { image, video, audio }

class MediaAttachment {
  final String path;
  final MediaType type;

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
  Set<String> _selectedOrgIds = {}; // Store organization names as IDs
  final List<MediaAttachment> _mediaAttachments = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final organizations = AppConstants.nationalEmergencies;

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
                SnackBar(
                  content: const Text('Report sent successfully'),
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

                // Organization selection
                const Text(
                  'Notify Organizations',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Select All chip
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedOrgIds.length == organizations.length,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedOrgIds = organizations
                                .map((e) => e['name']!)
                                .toSet();
                          } else {
                            _selectedOrgIds.clear();
                          }
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: theme.colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      checkmarkColor: theme.colorScheme.primary,
                    ),
                    // Individual organization chips
                    ...organizations.map((org) {
                      final name = org['name']!;
                      final isSelected = _selectedOrgIds.contains(name);
                      return FilterChip(
                        label: Text(name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedOrgIds.add(name);
                            } else {
                              _selectedOrgIds.remove(name);
                            }
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                        checkmarkColor: theme.colorScheme.primary,
                        avatar: Text(
                          org['icon']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                if (_selectedOrgIds.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Select at least one organization',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
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
                      onTap: () => _pickMedia(MediaType.image),
                    ),
                    const SizedBox(width: 12),
                    _buildMediaButton(
                      icon: Icons.videocam,
                      label: 'Video',
                      onTap: () => _pickMedia(MediaType.video),
                    ),
                    const SizedBox(width: 12),
                    _buildMediaButton(
                      icon: Icons.mic,
                      label: 'Audio',
                      onTap: () => _pickMedia(MediaType.audio),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Preview of selected media
                if (_mediaAttachments.isNotEmpty)
                  Container(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mediaAttachments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                                image: media.type == MediaType.image
                                    ? DecorationImage(
                                        image: FileImage(File(media.path)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: media.type != MediaType.image
                                  ? Center(
                                      child: Icon(
                                        media.type == MediaType.video
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
                  child: ElevatedButton(
                    onPressed:
                        _selectedSituation != null && _selectedOrgIds.isNotEmpty
                        ? () {
                            context.read<LiveReportBloc>().add(
                              SendLiveReport(
                                situation: _selectedSituation!,
                                message: _messageController.text,
                                recipientIds: _selectedOrgIds.toList(),
                                mediaPaths: _mediaAttachments
                                    .map((e) => e.path)
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
                    child: const Text(
                      'Send Report',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickMedia(MediaType type) async {
    XFile? pickedFile;
    switch (type) {
      case MediaType.image:
        pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        break;
      case MediaType.video:
        pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
        break;
      case MediaType.audio:
        // For audio, you might use a different package; here we'll simulate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio recording not implemented yet')),
        );
        return;
    }

    if (pickedFile != null) {
      setState(() {
        _mediaAttachments.add(
          MediaAttachment(path: pickedFile!.path, type: type),
        );
      });
    }
  }
}
