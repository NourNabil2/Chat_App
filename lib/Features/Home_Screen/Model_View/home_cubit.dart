import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Core/Utils/Colors.dart';
part 'home_state.dart';


class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  static HomeCubit get(context) => BlocProvider.of(context);
   Color unselectedColorReverse = Colors.black;
  static int current=2;
  void ChangePage (index)
  {
    current=index;
    emit(BottomState());
  }








}
