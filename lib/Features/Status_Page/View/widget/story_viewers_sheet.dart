// story_viewers_sheet.dart

import 'package:chats/Core/Utils/Colors.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:flutter/material.dart';

class StoryViewersSheet extends StatelessWidget {
  final List<ChatUser> viewers;

  const StoryViewersSheet({
    Key? key,
    required this.viewers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Viewers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: ColorApp.mainDark),
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            itemCount: viewers.length,
            itemBuilder: (context, index) {
              final user = viewers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.image),
                ),
                title: Text(user.name),
              );
            },
          ),
        ],
      ),
    );
  }
}

