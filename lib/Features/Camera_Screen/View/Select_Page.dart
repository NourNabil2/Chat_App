import 'dart:developer';
import 'dart:io';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Features/Home_Screen/Model_View/Chats_Cubit/chats_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Home_Screen/View/Widgets/AppBar_Sliver_widget.dart';
import 'ChatList_Select_Page.dart';


class SelectPageScreen extends StatefulWidget {
  final File? selectedImage;
  final File? selectedVideo; // New parameter for video

  const SelectPageScreen({super.key, this.selectedImage, this.selectedVideo});

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
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(CupertinoIcons.back,color:Theme.of(context).hintColor,)),
        backgroundColor: Theme.of(context).primaryColorDark,
        elevation: 0,
        title: Text('Select to send',style: Theme.of(context).textTheme.bodyMedium,),
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: BlocConsumer<ChatsCubit, ChatsState>(
        listener: (context, state) {
          if (state is getmyuserID) {
            BlocProvider.of<ChatsCubit>(context).getAllUsers(state.userIds);
          }
        },
        builder: (context, state) {
          // Check which media file is selected
          final File? selectedMedia = widget.selectedImage ?? widget.selectedVideo;
          final bool isVideo = widget.selectedVideo != null; // Check if it's a video

          return Column(
            children: [
              Expanded(
                child: SelectUsers(selectedMedia: selectedMedia, isVideo: isVideo), // Pass the media to SelectUsers
              ),
            ],
          );
        },
      ),
    );
  }
}
