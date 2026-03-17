import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/data/models/dependent.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/dependent_repository.dart';
import 'package:helpflutter/logic/blocs/contacts/contacts_bloc.dart';
import 'package:helpflutter/logic/blocs/dependent/dependent_bloc.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ContactsBloc(repository: context.read<ContactRepository>())
                ..add(LoadContacts()),
        ),
        BlocProvider(
          create: (context) =>
              DependentsBloc(repository: context.read<DependentRepository>())
                ..add(LoadDependents()),
        ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Contacts'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Emergency Contacts'),
                Tab(text: 'Dependents'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [EmergencyContactsTab(), DependentsTab()],
          ),
        ),
      ),
    );
  }
}

class EmergencyContactsTab extends StatelessWidget {
  const EmergencyContactsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsBloc, ContactsState>(
      builder: (context, state) {
        if (state is ContactsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ContactsLoaded) {
          final contacts = state.contacts;
          if (contacts.isEmpty) {
            return const Center(child: Text('No contacts yet.'));
          }
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ContactExpansionTile(contact: contact);
            },
          );
        } else if (state is ContactsError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return Container();
      },
    );
  }
}

class DependentsTab extends StatelessWidget {
  const DependentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DependentsBloc, DependentsState>(
      builder: (context, state) {
        if (state is DependentsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DependentsLoaded) {
          final dependents = state.dependents;
          if (dependents.isEmpty) {
            return const Center(child: Text('No dependents yet.'));
          }
          return ListView.builder(
            itemCount: dependents.length,
            itemBuilder: (context, index) {
              final dependent = dependents[index];
              return DependentExpansionTile(dependent: dependent);
            },
          );
        } else if (state is DependentsError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return Container();
      },
    );
  }
}

class ContactExpansionTile extends StatelessWidget {
  final Contact contact;

  const ContactExpansionTile({super.key, required this.contact});

  Color _getStatusColor(ContactStatus status) {
    switch (status) {
      case ContactStatus.accepted:
        return Colors.green;
      case ContactStatus.rejected:
        return Colors.red;
      case ContactStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusText(ContactStatus status) {
    return status.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(contact.status),
          child: Text(contact.fullName[0]),
        ),
        title: Text(contact.fullName),
        subtitle: Text('Status: ${_getStatusText(contact.status)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${contact.email}'),
                Text('Phone: ${contact.phone}'),
                Text('Situations: ${contact.situations.join(', ')}'),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      // Show confirmation dialog then delete
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Contact'),
                          content: Text(
                            'Are you sure you want to delete ${contact.fullName}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<ContactsBloc>().add(
                                  DeleteContact(contactId: contact.id),
                                );
                                Navigator.pop(ctx);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DependentExpansionTile extends StatelessWidget {
  final Dependent dependent;

  const DependentExpansionTile({super.key, required this.dependent});

  Color _getStatusColor(ContactStatus status) {
    switch (status) {
      case ContactStatus.accepted:
        return Colors.green;
      case ContactStatus.rejected:
        return Colors.red;
      case ContactStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(dependent.status),
          child: Text(dependent.fullName[0]),
        ),
        title: Text(dependent.fullName),
        subtitle: Text(
          'Status: ${dependent.status.toString().split('.').last}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${dependent.email}'),
                Text('Phone: ${dependent.phone}'),
                if (dependent.status == ContactStatus.pending) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.read<DependentsBloc>().add(
                            UpdateDependentsStatus(
                              dependentId: dependent.id,
                              status: ContactStatus.accepted,
                            ),
                          );
                        },
                        child: const Text('Accept'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          context.read<DependentsBloc>().add(
                            UpdateDependentsStatus(
                              dependentId: dependent.id,
                              status: ContactStatus.rejected,
                            ),
                          );
                        },
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
