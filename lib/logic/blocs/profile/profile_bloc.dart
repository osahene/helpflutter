import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/user.dart';
import 'package:helpflutter/data/models/request_history.dart';
import 'package:helpflutter/data/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await repository.getUserProfile();
      final history = await repository.getRequestHistory();
      emit(ProfileLoaded(user: user, history: history));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
