import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats/Core/Functions/Time_Format.dart';
import 'package:chats/Features/Status_Page/Model/Status.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final Status user;
  const ProfileWidget({super.key,required this.user});
  @override
  Widget build(BuildContext context) => Material(
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  Format_Time.getLastMessageTime(
                      context: context, time: user.sent),
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}