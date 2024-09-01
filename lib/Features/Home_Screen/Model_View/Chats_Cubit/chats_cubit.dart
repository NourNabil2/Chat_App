
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:chats/Features/Home_Screen/View/Widgets/AppBar_Sliver_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit() : super(ChatsInitial());
  static ChatsCubit get(context) => BlocProvider.of(context);
  static bool isSearching = false;
  List<String> userIds = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return APIs.firestore
        .collection(kUsersCollections)
        .doc(APIs.user.uid)
        .collection('my_users')
        .snapshots()
        .listen((event) {
      userIds = event.docs.map((e) => e.id).toList();
      log("userIds: $userIds");
      emit(getmyuserID(userIds: userIds));
    });
  }

  List<ChatUser> UserList = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getAllUsers(userIds) {
    return APIs.firestore
        .collection(kUsersCollections)
        .where('id',
        whereIn: userIds.isEmpty
            ? ['']
            : userIds)
    //.where('id', isNotEqualTo: user.uid)
        .snapshots().listen((event) {
      final data = event.docs;

      for (var i in data) {
        UserList = data
            .map((e) =>
            ChatUser.fromJson(e.data()))
            .toList() ??
            [];

        log("Data1: ${jsonEncode(i.data())}");
      }
      emit(getAlluser(UserList: UserList));
    },);
  }

void ChangeSearchIcon()
{
  isSearching = !isSearching;
  emit(SearchIconState(UserList: UserList));
}

  void search(query) {
    if (query.isEmpty) {
      emit(ChatsDisplaylist(UserList: UserList, searchList: [], isSearching: false));
    } else {
      List<ChatUser> searchList = UserList.where((user) {
        return user.name.toLowerCase().contains(query.toLowerCase()) || user.email.toLowerCase().contains(query.toLowerCase());
      }).toList();
      emit(ChatsDisplaylist(UserList: UserList, searchList: searchList, isSearching: true));
    }
    }
  }


