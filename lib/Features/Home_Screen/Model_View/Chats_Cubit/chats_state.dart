part of 'chats_cubit.dart';

sealed class ChatsState {}

final class ChatsInitial extends ChatsState {}

class GEtUsers_Erorr extends ChatsState {}

class GEtUsers_Success extends ChatsState {}

class SearchIconState extends ChatsState {
  List<ChatUser> UserList;

  SearchIconState({required this.UserList});
}

class SearchListChangeState extends ChatsState {}

class ChatsDisplaylist extends ChatsState {
  List<ChatUser> searchList;
  List<ChatUser> UserList;
  bool isSearching;
  ChatsDisplaylist({required this.searchList,required this.UserList,required this.isSearching});
}

class getmyuserID extends ChatsState {
  List<String> userIds ;
  getmyuserID({required this.userIds});
}

class getAlluser extends ChatsState {
  List<ChatUser> UserList;

  getAlluser({required this.UserList});

}
