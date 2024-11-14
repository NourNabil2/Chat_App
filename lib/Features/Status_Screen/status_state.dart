part of 'status_cubit.dart';

@immutable
sealed class StatusState {}

final class StatusInitial extends StatusState {}

class allUsersSucess extends StatusState {
  List<ChatUser> UserList;

  allUsersSucess({required this.UserList});

}

class StatusgetmyuserID extends StatusState {
  List<String> userIds ;
  StatusgetmyuserID({required this.userIds});
}

class StatusgetAlluser extends StatusState {
  List<ChatUser> UserList;

  StatusgetAlluser({required this.UserList});

}