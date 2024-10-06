
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
