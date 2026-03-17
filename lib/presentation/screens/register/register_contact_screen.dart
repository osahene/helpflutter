import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/core/constants/app_constants.dart';
import 'package:helpflutter/core/utils/validators.dart';
import 'package:helpflutter/core/widgets/loading_indicator.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/logic/blocs/register_contact/register_contact_bloc.dart';

class RegisterContactScreen extends StatefulWidget {
  const RegisterContactScreen({super.key});

  @override
  State<RegisterContactScreen> createState() => _RegisterContactScreenState();
}

class _RegisterContactScreenState extends State<RegisterContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedRelation;
  final List<String> _selectedSituations = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RegisterContactBloc(repository: context.read<ContactRepository>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Register Contact')),
        body: BlocListener<RegisterContactBloc, RegisterContactState>(
          listener: (context, state) {
            if (state is RegisterContactSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact registered successfully'),
                ),
              );
              Navigator.pop(context);
            } else if (state is RegisterContactFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<RegisterContactBloc, RegisterContactState>(
            builder: (context, state) {
              if (state is RegisterContactLoading) {
                return const LoadingIndicator(message: 'Registering...');
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                        validator: Validators.validateName,
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                        validator: Validators.validateName,
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator: Validators.validateAddress,
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+233XXXXXXXXX',
                        ),
                        validator: Validators.validatePhone,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: Validators.validateEmail,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRelation,
                        items: AppConstants.relations.map((relation) {
                          return DropdownMenuItem(
                            value: relation,
                            child: Text(relation),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedRelation = value),
                        decoration: const InputDecoration(
                          labelText: 'Relation',
                        ),
                        validator: (value) =>
                            Validators.validateRelation(value),
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Situations to notify:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: AppConstants.situations.map((situation) {
                          final isSelected = _selectedSituations.contains(
                            situation,
                          );
                          return FilterChip(
                            label: Text(situation),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSituations.add(situation);
                                } else {
                                  _selectedSituations.remove(situation);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_selectedSituations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Select at least one situation',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              _selectedSituations.isNotEmpty) {
                            context.read<RegisterContactBloc>().add(
                              SubmitContact(
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                                address: _addressController.text,
                                phone: _phoneController.text,
                                email: _emailController.text,
                                relation: _selectedRelation!,
                                situations: _selectedSituations,
                              ),
                            );
                          }
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
