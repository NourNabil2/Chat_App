import 'dart:developer';
import 'package:chats/Core/Functions/show_snack_bar.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Status_Page/View/widget/story_viewers_sheet.dart';
import 'package:flutter/material.dart';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/Utils/Colors.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:chats/Features/Status_Page/Model/Status.dart';
import 'package:chats/Features/Status_Page/View/widget/profile_status.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
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
  bool isDeleting = false;  // State to track the deletion process

  void _showViewersSheet(List<String> viewersIds) async {
    // Pause the story when the bottom sheet opens
    controller.pause();

    List<ChatUser> viewers = await APIs.fetchUsersByIds(viewersIds);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StoryViewersSheet(viewers: viewers),
    );
  }

  void _deleteStory(Status status) async {
    setState(() {
      isDeleting = true; // Set the deleting state to true
    });

    try {
      controller.pause();
      // Attempt to delete the story by calling the delete API
      final bool isDeleted = await APIs.deleteStoryMedia(
        isVideo: status.type == Type_s.image ? false : true ,
        mediaId: status.sent,
        mediaUrl: status.status,
        context: context
      );

      if (isDeleted) {
        // If deletion was successful, remove the story from the list
        setState(() {
          StatusList.remove(status);
        });
        // Show a success message to the user
        Dialogs.showSnackbar(context,'Story deleted successfully');

      } else {
        // Show an error message if deletion failed for any reason
       // Dialogs.showSnackbar(context,'Failed to delete story. Please try again.');

      }
    } catch (error) {
      // Handle unexpected errors by showing an error message
      Dialogs.showSnackbar(context,'An error occurred: $error');
    } finally {
      // Reset the deleting state after completion or failure
      setState(() {
        isDeleting = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isDeleting,  // Show the modal progress when deleting
      color: Colors.black54,  // Optional: Adjust the background color of the modal
      child: Scaffold(
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
                        // Add a profile widget on top of the story view
                        ProfileWidget(
                          user: StatusList.first,
                          onDelete: (status) {
                            _deleteStory(status); // Handle delete story
                          },
                        ),
                        // Move the seen count to the bottom center
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                // Extract the `fromId` values from each `Status` in `StatusList`
                                List<String> viewersIds = StatusList.map((status) => status.fromId).toList();
                                _showViewersSheet(viewersIds);
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.visibility, color: Colors.white, size: 16),
                                    SizedBox(width: 5),
                                    Text(
                                      "${StatusList.length ?? 0}",
                                      style: TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )

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
      ),
    );
  }
}
