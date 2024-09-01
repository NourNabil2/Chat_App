import 'dart:developer';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Features/Home_Screen/Model_View/Chats_Cubit/chats_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Widgets/Chats_Page.dart';

class HomeScreen extends StatefulWidget {
  final ScrollController controller;
  const HomeScreen({super.key,required this.controller});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: BlocConsumer<ChatsCubit,ChatsState>(
                    listener: (context, state) {
                      if (state is getmyuserID )
                        {
                          BlocProvider.of<ChatsCubit>(context).getAllUsers(state.userIds);
                        }
                    },
                    builder: (context, state) =>  chatsPage(controller: widget.controller,)),
    );
  }


}


