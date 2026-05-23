part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final User? user;
  const LoadProfile({this.user});

  @override
  List<Object?> get props => [user];
}
