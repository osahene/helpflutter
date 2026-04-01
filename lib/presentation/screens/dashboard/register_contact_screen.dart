import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/logic/contacts/contacts_bloc.dart';

class RegisterContactScreen extends StatefulWidget {
  const RegisterContactScreen({super.key});

  @override
  State<RegisterContactScreen> createState() => _RegisterContactScreenState();
}

class _RegisterContactScreenState extends State<RegisterContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedRelation;
  List<String> _selectedSituations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Contact')),
      body: BlocListener<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is ContactsLoaded) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Contact added')));
            Navigator.pop(context);
          } else if (state is ContactsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v == null || v.isEmpty
                      ? null
                      : (v.contains('@') ? null : 'Invalid email'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRelation,
                  items: const [
                    DropdownMenuItem(value: 'Father', child: Text('Father')),
                    DropdownMenuItem(value: 'Mother', child: Text('Mother')),
                    DropdownMenuItem(value: 'Brother', child: Text('Brother')),
                    DropdownMenuItem(value: 'Sister', child: Text('Sister')),
                    DropdownMenuItem(value: 'Friend', child: Text('Friend')),
                  ],
                  onChanged: (v) => setState(() => _selectedRelation = v),
                  decoration: const InputDecoration(labelText: 'Relation'),
                  validator: (v) => v == null ? 'Select relation' : null,
                ),
                const SizedBox(height: 16),
                const Text('Situations to notify:'),
                Wrap(
                  spacing: 8,
                  children: AppConstants.situations.map((s) {
                    final selected = _selectedSituations.contains(s);
                    return FilterChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
                            _selectedSituations.add(s);
                          } else {
                            _selectedSituations.remove(s);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedRelation != null) {
                      context.read<ContactsBloc>().add(
                        AddContact(
                          _firstNameController.text,
                          _lastNameController.text,
                          _phoneController.text,
                          _emailController.text,
                          _selectedRelation!,
                          _selectedSituations,
                        ),
                      );
                    } else if (_selectedRelation == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select relation')),
                      );
                    }
                  },
                  child: const Text('Add Contact'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
