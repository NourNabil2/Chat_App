
import 'dart:developer';

import 'package:chats/Core/widgets/Card_User.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:chats/Features/Home_Screen/Model_View/Chats_Cubit/chats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


// ignore: camel_case_types
class chatsList extends StatefulWidget {
  const chatsList({super.key});

  @override
  State<chatsList> createState() => _chatsListState();
}

// ignore: camel_case_types
class _chatsListState extends State<chatsList> {
  List<ChatUser> UserList = [];
  List<ChatUser> searchList = []; // TODO
@override
  void initState() {
  log('-- chatsList initState');
  BlocProvider.of<ChatsCubit>(context).getMyUsersId();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsCubit, ChatsState>(
      listener: (context, state) {
        if (mounted) {
          if (state is SearchIconState) {
            BlocProvider.of<ChatsCubit>(context).getMyUsersId();
          }
        }
      },

      builder: (context, state) {

        UserList = (state is getAlluser) ? state.UserList : [];
        searchList = (state is ChatsDisplaylist) ? state.searchList : [];
        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              bool isLastItem = index == (ChatsCubit.isSearching ? searchList.length : UserList.length) - 1;
              return Column(
                children: [
                  ChatUserCardState(
                    user: ChatsCubit.isSearching ? searchList[index] : UserList[index],
                  ),
                  if (!isLastItem) // Add a separator line if it's not the last item
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.2,
                      height: 0.1,
                    ),
                ],
              );
            },
            childCount: ChatsCubit.isSearching ? searchList.length : UserList.length,
          ),
        );
      },
    );
  }
}
