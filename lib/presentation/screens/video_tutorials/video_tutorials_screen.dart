import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/repositories/tutorial_repository.dart';
import 'package:helpflutter/logic/blocs/tutorials/tutorial_bloc.dart';

class VideoTutorialsScreen extends StatelessWidget {
  const VideoTutorialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TutorialsBloc(repository: context.read<TutorialRepository>())
            ..add(LoadTutorials()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Video Tutorials')),
        body: BlocBuilder<TutorialsBloc, TutorialState>(
          builder: (context, state) {
            if (state is TutorialLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TutorialLoaded) {
              final tutorials = state.tutorials;
              // Group by category
              final Map<String, List> grouped = {};
              for (var tutorial in tutorials) {
                grouped.putIfAbsent(tutorial.category, () => []).add(tutorial);
              }
              final categories = grouped.keys.toList();
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryTutorials = grouped[category]!;
                  return ExpansionTile(
                    title: Text(
                      category.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: categoryTutorials.map((tutorial) {
                      return ListTile(
                        leading: Image.network(
                          tutorial.thumbnailUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(tutorial.title),
                        onTap: () {
                          // TODO: Play video
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Playing ${tutorial.title}'),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
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
