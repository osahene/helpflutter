import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/data/models/dependent.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/dependent_repository.dart';
import 'package:helpflutter/logic/blocs/contacts/contacts_bloc.dart';
import 'package:helpflutter/logic/blocs/dependent/dependent_bloc.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

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
            bottom: TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Emergency Contacts'),
                Tab(text: 'Dependents'),
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade50, Colors.white],
              ),
            ),
            child: const TabBarView(
              children: [EmergencyContactsTab(), DependentsTab()],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Navigate to register contact
              Navigator.pushNamed(context, '/register-contact');
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Add Contact'),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contact_emergency,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No contacts yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first trusted contact',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ContactCard(contact: contact);
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.family_restroom,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No dependents yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dependents are people who trust you',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dependents.length,
            itemBuilder: (context, index) {
              final dependent = dependents[index];
              return DependentCard(dependent: dependent);
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

class ContactCard extends StatelessWidget {
  final Contact contact;

  const ContactCard({super.key, required this.contact});

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
    return SwipeActionCell(
      key: ValueKey(contact.id),
      trailingActions: [
        SwipeAction(
          onTap: (CompletionHandler handler) async {
            // Show confirmation then delete
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Contact'),
                content: Text('Delete ${contact.fullName}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              context.read<ContactsBloc>().add(
                DeleteContact(contactId: contact.id),
              );
            }
            handler(false);
          },
          color: Colors.red,
          icon: const Icon(Icons.delete, color: Colors.white),
        ),
      ],
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(
              contact.status,
            ).withValues(alpha: 0.2),
            child: Text(
              contact.fullName[0],
              style: TextStyle(
                color: _getStatusColor(contact.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            contact.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Relation: ${contact.relation} • Status: ${contact.status.toString().split('.').last}',
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.email_outlined, contact.email),
                  _infoRow(Icons.phone_outlined, contact.phone),
                  _infoRow(
                    Icons.warning_amber_outlined,
                    'Situations: ${contact.situations.join(', ')}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class DependentCard extends StatelessWidget {
  final Dependent dependent;

  const DependentCard({super.key, required this.dependent});

  Color _getStatusColor(DependentStatus status) {
    switch (status) {
      case DependentStatus.approved:
        return Colors.green;
      case DependentStatus.rejected:
        return Colors.red;
      case DependentStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ValueKey(dependent.id),
      trailingActions: [
        SwipeAction(
          onTap: (CompletionHandler handler) async {
            // Delete dependent
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Remove Dependent'),
                content: Text('Remove ${dependent.fullName}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              // You need a DeleteDependent event
              // context.read<DependentsBloc>().add(DeleteDependent(dependentId: dependent.id));
            }
            handler(false);
          },
          color: Colors.red,
          icon: const Icon(Icons.delete, color: Colors.white),
        ),
      ],
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(
              dependent.status,
            ).withValues(alpha: 0.2),
            child: Text(
              dependent.fullName[0],
              style: TextStyle(
                color: _getStatusColor(dependent.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            dependent.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Status: ${dependent.status.toString().split('.').last}',
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.email_outlined, dependent.email),
                  _infoRow(Icons.phone_outlined, dependent.phone),
                  if (dependent.status == ContactStatus.pending) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            context.read<DependentsBloc>().add(
                              UpdateDependentsStatus(
                                dependentId: dependent.id,
                                status: DependentStatus.approved,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check, color: Colors.green),
                          label: const Text('Accept'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            context.read<DependentsBloc>().add(
                              UpdateDependentsStatus(
                                dependentId: dependent.id,
                                status: DependentStatus.rejected,
                              ),
                            );
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text('Reject'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
