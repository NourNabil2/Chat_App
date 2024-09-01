import 'dart:developer';
import 'dart:io';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Features/Home_Screen/Model_View/Chats_Cubit/chats_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Home_Screen/View/Widgets/AppBar_Sliver_widget.dart';
import '../../Home_Screen/View/Widgets/ChatsList_widget.dart';
import '../../Home_Screen/View/Widgets/Chats_Page.dart';
import 'ChatList_Select_Page.dart';

class SelectPageScreen extends StatefulWidget {
  final File? selectedImage;
  const SelectPageScreen({super.key, this.selectedImage});

  @override
  State<SelectPageScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<SelectPageScreen> {
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
      body: BlocConsumer<ChatsCubit, ChatsState>(
        listener: (context, state) {
          if (state is getmyuserID) {
            BlocProvider.of<ChatsCubit>(context).getAllUsers(state.userIds);
          }
        },
        builder: (context, state) => Column(
          children: [
            Expanded(
              child: SelectUsers(
                selectedImage: widget.selectedImage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
