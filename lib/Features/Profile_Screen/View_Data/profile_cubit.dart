import 'dart:developer';

import 'package:chats/Core/Functions/CashSaver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  static ProfileCubit get(context) => BlocProvider.of(context);

  bool Darkmood = CashSaver.getData(key: 'Theme') ?? false;
  bool isExpand =  false;
  int selected = CashSaver.getData(key: 'selected') ?? 1;

  void changeTheme()
  {
    Darkmood = !Darkmood ;
    CashSaver.SaveData(key: 'Theme', value: Darkmood);
    emit(changeThemeState());
  }

  void changeSelecte(int index)
  {
    CashSaver.SaveData(key: 'selected', value: index);
    selected = index ;
    log("$selected");
    emit(changeSelecteState());
  }

  void ExpandChange()
  {
    isExpand = !isExpand ;
    emit(ExpandChangeState());
  }

}
