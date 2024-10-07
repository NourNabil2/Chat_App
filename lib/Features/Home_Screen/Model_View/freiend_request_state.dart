part of 'freiend_request_cubit.dart';

@immutable
sealed class FreiendRequestState {}

final class FreiendRequestInitial extends FreiendRequestState {}
class FriendRequestsUpdated extends FreiendRequestState {
  final friendRequestList;

  FriendRequestsUpdated({required this.friendRequestList});
}