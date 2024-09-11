

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/widgets/bottomsheet_widget_users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../../Features/Chat_Screen/Data/message.dart';
import '../../Features/Chat_Screen/View/chat_page.dart';
import '../../Features/Home_Screen/Data/Users.dart';
import '../Functions/Time_Format.dart';
import 'Profile_Dialog_Pic.dart';


class ChatUserCardState extends StatefulWidget {
  final ChatUser user;

  const ChatUserCardState({super.key, required this.user});
  @override
  State<ChatUserCardState> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCardState> {
  Message? _message;
  int _streak = 0; // To hold the streak count
  bool _isUploading = false;
  @override
  void initState() {
    super.initState();
    _fetchStreak(); // Fetch the streak count when the widget is initialized
  }

  // Fetch the streak count for the user
  void _fetchStreak() async {
    _streak = await APIs.getStreak(widget.user);
    setState(() {}); // Update the UI after fetching the streak
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: APIs.getLastMessage(widget.user),
      builder: (context, snapshot) {
        final data = snapshot.data?.docs;
        final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

        final notread = data?.map((e) => Message.fromJson(e.data())).where((element) => element.read.isEmpty).toList() ?? [];

        if (list.isNotEmpty) _message = list[0];

        return InkWell(
          onLongPress: () {
            if (_message != null) {
              showBottomSheet_User(context, _message);
            }
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(user: widget.user),
              ),
            );
          },
          child: ListTile(
            // User profile picture
            leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ProfileDialog(user: widget.user),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      width: 50,
                      height: 50,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: widget.user.isOnline ? Colors.green.shade400 : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),

            // User name
            title: Text(
              widget.user.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // Last message
            subtitle: Text(
              _message != null
                  ? _message!.type == Type.image ?
              _message!.read.isEmpty && _message!.fromId != APIs.user.uid ?
              '🟥 Tap to View Image ${_streak == 0 ? '' : "| $_streak 🔥"}'
              :
              '☐ Opened ${_streak == 0 ? '' : "| $_streak 🔥"}'
              : _message!.read.isEmpty && _message!.fromId != APIs.user.uid ?
                  '🟦 Tap to View chat ${_streak == 0 ? '' : "| $_streak 🔥"}'
                  : '☐ Tap to View chat ${_streak == 0 ? '' : "| $_streak 🔥"}'
                  : widget.user.about,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),

            trailing: _message == null
                ?           //take image from camera button
            IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Pick an image
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 70);
                  if (image != null) {
                    log('Image Path: ${image.path}');
                    setState(() => _isUploading = true);
                    await APIs.sendChatImage(
                        widget.user, File(image.path));
                    setState(() => _isUploading = false);
                  }
                },
                icon: Icon(Icons.camera_alt_rounded,
                    color: Theme.of(context).iconTheme.color, size: 26))
                : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                ? Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${notread.length}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            )
                : IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Pick an image
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 70);
                  if (image != null) {
                    log('Image Path: ${image.path}');
                    setState(() => _isUploading = true);
                    await APIs.sendChatImage(
                        widget.user, File(image.path));
                    setState(() => _isUploading = false);
                  }
                },
                icon: Icon(Icons.camera_alt_rounded,
                    color: Theme.of(context).iconTheme.color, size: 26))
          ),
        );
      },
    );
  }
}








