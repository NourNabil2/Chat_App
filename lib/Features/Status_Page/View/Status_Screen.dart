import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/Utils/Colors.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:chats/Features/Status_Page/Model/Status.dart';
import 'package:chats/Features/Status_Page/View/widget/profile_status.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class statusPage extends StatefulWidget {
  final ChatUser user;
  const statusPage({super.key,required this.user});

  @override
  State<statusPage> createState() => _statusPageState();
}

class _statusPageState extends State<statusPage> {
  final controller = StoryController();
  List<Status> StatusList =[] ;
  List<StoryItem> storyItems = [];
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: StreamBuilder(
          stream: APIs.getStoryImage( widget.user ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
            //if data is loading
              case ConnectionState.waiting:
                return CircularProgressIndicator(color: Theme.of(context).primaryColor,);
              case ConnectionState.none:
                return const Center(
                    child: Text('No Network'));

            //if some or all data is loaded then show it
              case ConnectionState.active:
              case ConnectionState.done:
                final data = snapshot.data?.docs;
                for (var i in data!) {
                  StatusList = data
                      .map((e) =>
                      Status.fromJson(e.data()))
                      .toList() ??
                      [];
                }
                for (var i = 0; i < StatusList.length; i++) {
                  storyItems.add(
                    StoryItem.pageImage(url: StatusList[i].status,
                      controller: controller,
                      duration: const Duration(seconds: 5),
                      loadingWidget: Image.asset(kindicator),


                    ),
                  );

                }

                if (StatusList.isNotEmpty) {
                  return InteractiveViewer(
                    child: Stack(
                      children:[
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
                                controller: controller),
                        ProfileWidget(user: StatusList.first , ),
                    ]
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                        'No connection Found'),
                  ); // ToDO:: Handel this
                }
            }
          }

         ),
    );

  }
}
