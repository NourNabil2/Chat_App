
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/Network/notification_service.dart';
import 'package:chats/Core/Utils/Colors.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:chats/Features/Status_Page/Model/Status.dart';
import 'package:chats/Features/Status_Page/View/widget/user_status.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StatusPage extends StatefulWidget {
  final ChatUser user;
  final bool public;
  const StatusPage({super.key, required this.user, required this.public});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final controllerStory = StoryController();
  TextEditingController controller = TextEditingController();
  List<Status> statusList = [];
  List<StoryItem> storyItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: widget.public ? APIs.getPublicStoryMedia(widget.user) : APIs.getPrivateStoryMedia(widget.user),
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
              statusList = data?.map((e) => Status.fromJson(e.data())).toList() ?? [];

              // Call function to delete outdated stories
              _deleteOutdatedStories(data);

              storyItems.clear(); // Clear previous items
              for (var status in statusList) {
                if (status.status != null && status.status.isNotEmpty) {
                  if (status.type == Type_s.image) {
                    storyItems.add(
                      StoryItem.pageImage(
                        url: status.status,
                        controller: controllerStory,
                        duration: const Duration(seconds: 5),
                        loadingWidget: Image.asset(kindicator),
                      ),
                    );
                  } else {
                    storyItems.add(
                      StoryItem.pageVideo(
                        status.status,
                        controller: controllerStory,
                        shown: true,
                      ),
                    );
                  }
                }
              }

              if (statusList.isNotEmpty && storyItems.isNotEmpty) {
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
                        controller: controllerStory,
                        onStoryShow: (StoryItem storyItem, int index) {
                          final mediaId = statusList[index].sent;
                          final friendEmail = widget.user.email;
                          APIs.markStoryAsSeen(mediaId: mediaId, friendEmail: friendEmail);
                        },
                      ),
                      userStatusWidget(user: statusList.first),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: chatInput(context),
                      ),
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

  // Function to delete stories older than 24 hours
  void _deleteOutdatedStories(dynamic data) {
    final now = DateTime.now();
    data?.forEach((doc) {
      int storyTime = int.parse(doc['sent']);
      DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(storyTime);

      if (now.difference(messageTime).inHours >= 24) {
        bool isVideo = doc['type'] == 'video' ? true : false ;
        APIs.deleteStoryMedia(mediaId: doc.id, isVideo: isVideo,mediaUrl: data['image'],context:context);
       // log('Deleted story with ID: ${doc.id} (older than 24 hours)');
      }
    });
  }

  Widget chatInput(context) {
    return Container(
      decoration: BoxDecoration(color:Colors.transparent.withOpacity(0.3), border: Border(
        top: BorderSide(
          color: ColorApp.bg_gray, // Color of the top border
          width: 2.0, // Width of the top border
        ),)),
      child: Row(
        children: [
          //input field & buttons
          Expanded(
            child: Card(

              color: Theme.of(context).primaryColorLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.s30)),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSize.s10),
                        child: TextField(
                          style: TextStyle(color: Theme.of(context).iconTheme.color,backgroundColor: Theme.of(context).primaryColorLight,),
                          controller: controller,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onTap: () {
                            controllerStory.pause();
                          },
                          decoration: InputDecoration(
                              hintText: 'Type Something...',
                              hintStyle: TextStyle(color: Theme.of(context).iconTheme.color,fontSize: 12,overflow: TextOverflow.ellipsis),
                              border: InputBorder.none),
                        ),
                      )),
                ],
              ),
            ),
          ),
          SizedBox(width: 10,),
          //send message button
          MaterialButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                  //  simply send message
                  APIs.sendMessage(
                      widget.user, '↺ Reply on your story \n ${controller.text}', null);
                  NotificationHelper.sendNotification(
                      targetToken:  widget.user.pushToken,
                      title: APIs.me.name,body: 'replay to your story');
                controller.text = '';
              }
            },
            minWidth: 0,
            padding:
            const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            child: Icon(Icons.send, color: Theme.of(context).primaryColorLight, size: 28),
          )
        ],
      ),
    );
  }
}
