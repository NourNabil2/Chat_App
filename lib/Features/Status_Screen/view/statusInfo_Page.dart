import 'dart:developer';
import 'package:chats/Features/Status_Page/View/Status_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Home_Screen/Data/Users.dart';
import '../../Home_Screen/Model_View/Chats_Cubit/chats_cubit.dart';

class StatusInfoPage extends StatefulWidget {
  const StatusInfoPage({super.key});

  @override
  State<StatusInfoPage> createState() => _StatusInfoPageState();
}

class _StatusInfoPageState extends State<StatusInfoPage> {
  List<ChatUser> userList = [];
  List<ChatUser> allUserList = [];

  @override
  void initState() {
    super.initState();
    // Fetch all users and specific user stories on initialization
    final chatsCubit = ChatsCubit.get(context);
    chatsCubit.allUsers();
    chatsCubit.getMyUsersId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ChatsCubit, ChatsState>(
        listener: (context, state) {
          // Update user lists based on the state
          if (state is getAlluser) {
            userList = state.UserList;
            log('Updated userList with ${userList.length} users');
          } else if (state is allUsersSucess) {
            allUserList = state.UserList;
            log('Updated allUserList with ${allUserList.length} users');
          }
        },
        builder: (context, state) {
          return UserStoryPage(
            userList: userList,
            alluserList: allUserList,
          );
        },
      ),
    );
  }
}
