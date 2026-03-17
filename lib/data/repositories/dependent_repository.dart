import 'package:helpflutter/data/models/dependent.dart';
import 'package:helpflutter/data/models/contact.dart';

abstract class DependentRepository {
  Future<List<Dependent>> getDependents();
  Future<void> updateDependentStatus(String dependentId, ContactStatus status);
}

class MockDependentRepository implements DependentRepository {
  final List<Dependent> _mockDependents = [
    Dependent(
      id: '101',
      fullName: 'Alice Wonder',
      phone: '+233501234569',
      email: 'alice@example.com',
      status: ContactStatus.pending,
    ),
    Dependent(
      id: '102',
      fullName: 'Bob Builder',
      phone: '+233501234570',
      email: 'bob@example.com',
      status: ContactStatus.accepted,
    ),
  ];

  @override
  Future<List<Dependent>> getDependents() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockDependents;
  }

  @override
  Future<void> updateDependentStatus(
    String dependentId,
    ContactStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockDependents.indexWhere((d) => d.id == dependentId);
    if (index != -1) {
      _mockDependents[index] = Dependent(
        id: _mockDependents[index].id,
        fullName: _mockDependents[index].fullName,
        phone: _mockDependents[index].phone,
        email: _mockDependents[index].email,
        status: status,
      );
    }
  }
}
