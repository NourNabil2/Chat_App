import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats/Core/Functions/Time_Format.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Status_Page/Model/Status.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final Status user;
  final void Function(Status) onDelete; // Callback for deleting the story

  const ProfileWidget({super.key, required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 24,
              backgroundImage: CachedNetworkImageProvider(user.image),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.fromname,
                    style: statusStyle(),
                  ),
                  Text(
                    Format_Time.getLastMessageTime(context: context, time: user.sent),
                    style: statusStyle(),
                  ),
                ],
              ),
            ),
            // View count and delete dropdown button
            Column(
              children: [
                // Dropdown button for deleting the story
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Delete') {
                      onDelete(user); // Handle delete action
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'Delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete Story", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ];
                  },
                  icon: Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
