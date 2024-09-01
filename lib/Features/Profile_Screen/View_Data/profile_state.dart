part of 'profile_cubit.dart';


sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class changeThemeState extends ProfileState {}

final class changeSelecteState extends ProfileState {}

final class ExpandChangeState extends ProfileState {}
