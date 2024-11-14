import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'status_state.dart';

class StatusCubit extends Cubit<StatusState> {
  StatusCubit() : super(StatusInitial());
  static StatusCubit get(context) => BlocProvider.of(context);
  List<ChatUser> alluserList = [];

  List<String> userIds = [];


  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return APIs.firestore
        .collection(kUsersCollections)
        .doc(APIs.user.uid)
        .collection('my_users')
        .snapshots()
        .listen((event) {
      userIds = event.docs.map((e) => e.id).toList();
      log("My userIds: $userIds");
      getAllUsers(userIds);
      emit(StatusgetmyuserID(userIds: userIds));
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
    //.where('id', isNotEqualTo: APIs.me.id)
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
      emit(StatusgetAlluser(UserList: UserList));
    },);
  }


  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> allUsers() {
    return APIs.firestore
        .collection(kUsersCollections)
        .snapshots()
        .listen((event) {
      alluserList = event.docs
          .map((e) => ChatUser.fromJson(e.data()))
          .toList();

      log("Fetched Users: ${jsonEncode(alluserList)}");

      emit(allUsersSucess(UserList: alluserList)); // Emit the list to update the UI
    });
  }


}
