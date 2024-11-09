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



}
