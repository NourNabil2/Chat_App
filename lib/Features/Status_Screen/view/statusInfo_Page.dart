import 'dart:developer';

import 'package:chats/Features/Status_Page/View/Status_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Core/widgets/Card_User.dart';
import '../../Home_Screen/Data/Users.dart';
import '../../Home_Screen/Model_View/Chats_Cubit/chats_cubit.dart';

class statusInfoPage extends StatefulWidget {
  const statusInfoPage({super.key});

  @override
  State<statusInfoPage> createState() => _statusInfoPageState();
}

class _statusInfoPageState extends State<statusInfoPage> {
  List<ChatUser> UserList = [];
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsCubit, ChatsState>(
      listener: (context, state) {
        if (state is SearchIconState) {
          BlocProvider.of<ChatsCubit>(context).getMyUsersId();
        }
      },
      builder: (context, state) {
        UserList = (state is getAlluser) ? state.UserList : [];
log('user Story list ${UserList.length}');
        return UserProfilePage(userList: UserList);
      },
    );
  }
}
