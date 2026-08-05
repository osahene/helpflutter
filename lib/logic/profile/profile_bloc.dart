import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/user.dart';
import 'package:helpflutter/data/models/request_history.dart';
import 'package:helpflutter/data/repositories/profile_repository.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<ClearProfile>(_onClearProfile);
  }

  Future<void> _onClearProfile(
    ClearProfile event,
    Emitter<ProfileState> emit,
  ) async {
    await SecureStorage.clearSession();
    emit(ProfileInitial());
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      User? user = event.user ?? await SecureStorage.getCachedUser();
      user ??= await repository.getProfile();

      await SecureStorage.saveUser(user);

      // history failing must NOT wipe the profile
      List<RequestHistory> history = [];
      try {
        history = await repository.getRequestHistory();
      } catch (_) {}

      emit(ProfileLoaded(user: user, history: history));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
