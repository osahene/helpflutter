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

  // profile_bloc.dart
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      User? user;

      if (event.user != null) {
        // Use the user data passed from AuthBloc
        user = event.user;
      } else {
        // Fallback: Fetch from repository if no user was passed
        user = await repository.getUserProfile();
      }

      final history = await repository.getRequestHistory();

      // Safety check: ensure user is not null
      if (user != null) {
        emit(ProfileLoaded(user: user, history: history));
      } else {
        emit(const ProfileError("Failed to load user data"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
