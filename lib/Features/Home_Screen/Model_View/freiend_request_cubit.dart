import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../Core/Network/API.dart';
import '../../../Core/Utils/constants.dart';
import '../../Friend_Screen/Data/FriendRequest.dart';
import 'Chats_Cubit/chats_cubit.dart';

part 'freiend_request_state.dart';

class FreiendRequestCubit extends Cubit<FreiendRequestState> {
  FreiendRequestCubit() : super(FreiendRequestInitial());
  static ChatsCubit get(context) => BlocProvider.of(context);

  List<Friendrequest> friendRequests = [];

  // Method to fetch friend requests in real-time.
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? friendRequestSubscription;

  // Listen to friend requests updates in Firestore
  void fetchFriendRequests() {
    friendRequestSubscription = APIs.firestore
        .collection(kUsersCollections)
        .doc(APIs.user.uid)
        .collection('friendRequests')
        .snapshots()
        .listen((event) {
      friendRequests = event.docs.map((doc) => Friendrequest.fromJson(doc.data())).toList();
      emit(FriendRequestsUpdated(friendRequestList: friendRequests));
    });
  }

  // Method to cancel the subscription
  void cancelSubscription() {
    friendRequestSubscription?.cancel();
  }

  @override
  Future<void> close() {
    cancelSubscription();
    return super.close();
  }

}
