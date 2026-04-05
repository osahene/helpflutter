import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/models/tutorial.dart';
import 'package:helpflutter/data/repositories/tutorial_repository.dart';
import 'package:helpflutter/logic/tutorial/tutorial_bloc.dart';
import 'package:helpflutter/presentation/screens/extra/video_player_screen.dart';

class VideoTutorialsScreen extends StatefulWidget {
  const VideoTutorialsScreen({super.key});

  @override
  State<VideoTutorialsScreen> createState() => _VideoTutorialsScreenState();
}

class _VideoTutorialsScreenState extends State<VideoTutorialsScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) =>
          TutorialsBloc(repository: context.read<TutorialRepository>())
            ..add(LoadTutorials()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Video Tutorials'),
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
        body: BlocBuilder<TutorialsBloc, TutorialState>(
          builder: (context, state) {
            if (state is TutorialLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TutorialLoaded) {
              final tutorials = state.tutorials;
              final categories = tutorials
                  .map((t) => t.category)
                  .toSet()
                  .toList();

              // Filter by selected category
              final filtered = _selectedCategory == null
                  ? tutorials
                  : tutorials
                        .where((t) => t.category == _selectedCategory)
                        .toList();

              return Column(
                children: [
                  // Category chips
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1, // +1 for "All"
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // "All" chip
                          return ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = null),
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                            labelStyle: TextStyle(
                              color: _selectedCategory == null
                                  ? theme.colorScheme.primary
                                  : Colors.black87,
                              fontWeight: _selectedCategory == null
                                  ? FontWeight.bold
                                  : null,
                            ),
                          );
                        }
                        final category = categories[index - 1];
                        return ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(
                              () => _selectedCategory = selected
                                  ? category
                                  : null,
                            );
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          labelStyle: TextStyle(
                            color: _selectedCategory == category
                                ? theme.colorScheme.primary
                                : Colors.black87,
                            fontWeight: _selectedCategory == category
                                ? FontWeight.bold
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  // Video grid
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_library,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No videos available',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final tutorial = filtered[index];
                              return _VideoCard(tutorial: tutorial);
                            },
                          ),
                  ),
                ],
              );
            } else if (state is TutorialError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Container();
          },
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Tutorial tutorial;

  const _VideoCard({required this.tutorial});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(
              videoUrl: tutorial.videoUrl,
              title: tutorial.title,
              thumbnailUrl: tutorial.thumbnailUrl,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'video_${tutorial.id}',
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  tutorial.thumbnailUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(color: Colors.grey.shade300);
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
              ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutorial.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tutorial.duration != null)
                        Text(
                          _formatDuration(tutorial.duration!),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Play icon overlay
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 50,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${duration.inHours}:' : ''}$minutes:$seconds';
  }
}
