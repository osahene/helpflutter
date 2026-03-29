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
        appBar: AppBar(
          title: const Text('Add Trusted Contact'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: BlocListener<RegisterContactBloc, RegisterContactState>(
          listener: (context, state) {
            if (state is RegisterContactSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Contact registered successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              Navigator.pop(context);
            } else if (state is RegisterContactFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: BlocBuilder<RegisterContactBloc, RegisterContactState>(
            builder: (context, state) {
              if (state is RegisterContactLoading) {
                return const LoadingIndicator(message: 'Registering...');
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Contact Information',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),
                      // First & Last name row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: Validators.validateName,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: Validators.validateName,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: Validators.validateAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+233XXXXXXXXX',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),
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
                          prefixIcon: Icon(Icons.family_restroom),
                        ),
                        validator: (value) =>
                            Validators.validateRelation(value),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Notify for these situations:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2),
                            checkmarkColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_selectedSituations.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Select at least one situation',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
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
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Register Contact',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
