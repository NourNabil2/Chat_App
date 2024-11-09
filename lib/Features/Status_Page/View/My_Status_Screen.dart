import 'dart:developer';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/Utils/Colors.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:chats/Features/Status_Page/Model/Status.dart';
import 'package:chats/Features/Status_Page/View/widget/profile_status.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class MystatusPage extends StatefulWidget {
  final ChatUser user;
  const MystatusPage({super.key, required this.user});

  @override
  State<MystatusPage> createState() => _statusPageState();
}

class _statusPageState extends State<MystatusPage> {
  final controller = StoryController();
  List<Status> StatusList = [];
  List<StoryItem> storyItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: APIs.getAllStoryMedia(widget.user),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              );
            case ConnectionState.none:
              return const Center(child: Text('No Network'));

            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              StatusList = data?.map((e) => Status.fromJson(e.data())).toList() ?? [];

              storyItems.clear(); // Clear previous items

              for (var status in StatusList) {
                // Validate URL before adding to storyItems
                if (status.status != null && status.status.isNotEmpty) {
                  if (status.type == Type_s.image) {
                    log('Adding image story: ${status.status}');
                    storyItems.add(
                      StoryItem.pageImage(
                        url: status.status, // URL of the image
                        controller: controller,
                        duration: const Duration(seconds: 5), // Adjust duration
                        loadingWidget: Image.asset(kindicator),
                      ),
                    );
                  } else {
                    log('Adding video story: ${status.status}');
                    storyItems.add(
                      StoryItem.pageVideo(
                        status.status, // URL of the video
                        controller: controller,
                        shown: true, // Ensure video is shown and plays automatically
                      ),
                    );
                  }
                } else {
                  // Log or handle the case where the URL is missing or invalid
                  log('Invalid URL for status with type: ${status.type}');
                }
              }

              if (StatusList.isNotEmpty && storyItems.isNotEmpty) {
                return InteractiveViewer(
                  child: Stack(
                    children: [
                      StoryView(
                        onVerticalSwipeComplete: (direction) {
                          if (direction == Direction.down) {
                            Navigator.pop(context);
                          }
                        },
                        storyItems: storyItems,
                        onComplete: () {
                          Navigator.pop(context);
                        },
                        indicatorForegroundColor: ColorApp.kwhiteColor,
                        controller: controller,
                      ),
                      ProfileWidget(user: StatusList.first),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('No stories available'),
                );
              }
          }
        },
      ),
    );
  }
}
