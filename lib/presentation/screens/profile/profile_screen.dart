import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/logic/blocs/profile/profile_bloc.dart';
import 'package:helpflutter/data/repositories/profile_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(repository: context.read<ProfileRepository>())
            ..add(LoadProfile()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile header
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: state.user.profileImageUrl != null
                          ? NetworkImage(state.user.profileImageUrl!)
                          : null,
                      child: state.user.profileImageUrl == null
                          ? Text(state.user.fullName[0])
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.user.fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(state.user.email),
                    Text(state.user.phone),
                    const Divider(height: 32),
                    const Text(
                      'Request History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.history.length,
                      itemBuilder: (context, index) {
                        final item = state.history[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(item.situation[0]),
                            ),
                            title: Text(item.situation),
                            subtitle: Text(
                              'Notified: ${item.notifiedContacts.join(', ')}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  item.status,
                                  style: TextStyle(
                                    color: item.status == 'Sent'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            } else if (state is ProfileError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Container();
          },
        ),
      ),
    );
  }
}
