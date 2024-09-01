import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Features/Status_Page/Model/Status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Features/Home_Screen/Data/Users.dart';
import '../../Features/Profile_Screen/View/Profile_OtherUsers_Screen.dart';
import '../../main.dart';


class ProfileDialog extends StatelessWidget {
   ProfileDialog({super.key, required this.user});

  final ChatUser user;
   final Size mq =Size(350, 700)  ;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
          width: mq.width * .6,
          height: mq.height * .35,
          child: Stack(
            children: [
              //user profile picture
              Positioned(
                top: mq.height * .075,
                left: mq.width * .15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .25),
                  child: CachedNetworkImage(
                    width: mq.width * .5,
                    fit: BoxFit.cover,
                    imageUrl: user.image,
                    errorWidget: (context, url, error) =>
                    const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
              ),

              //user name
              Positioned(
                left: mq.width * .04,
                top: mq.height * .02,
                width: mq.width * .55,
                child: Text(user.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500)),
              ),

              //info button
              Positioned(
                  right: 8,
                  top: 6,
                  child: MaterialButton(
                    onPressed: () {
                      //for hiding image dialog
                      Navigator.pop(context);

                      //move to view profile screen
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => Porfile_Other_Users(user: user)));
                    },
                    minWidth: 0,
                    padding: const EdgeInsets.all(0),
                    shape: const CircleBorder(),
                    child: const Icon(Icons.info_outline,
                        color: Colors.blue, size: 30),
                  ))
            ],
          )),
    );
  }
}



class StoryDialog extends StatelessWidget {
  StoryDialog({super.key, required this.user});

  final ChatUser user;
  final Size mq =Size(350, 700)  ;
  List<Status> StatusList =[] ;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
          width: mq.width * .6,
          height: mq.height * .35,
          child: StreamBuilder(
            stream: APIs.getStoryImage(user),
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
                  return StreamBuilder(
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ??
                              []),
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
                            if (StatusList.isNotEmpty) {
                              return Stack(
                                children: [
                                  //user profile picture
                                  Positioned(
                                    top: mq.height * .075,
                                    left: mq.width * .15,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(mq.height * .25),
                                      child: CachedNetworkImage(
                                        width: mq.width * .5,
                                        fit: BoxFit.cover,
                                        imageUrl: StatusList[1].status,
                                        errorWidget: (context, url, error) =>
                                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                                      ),
                                    ),
                                  ),

                                  //user name
                                  Positioned(
                                    left: mq.width * .04,
                                    top: mq.height * .02,
                                    width: mq.width * .55,
                                    child: Text(StatusList[0].fromname,
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.w500)),
                                  ),

                                  //info button
                                  Positioned(
                                      right: 8,
                                      top: 6,
                                      child: MaterialButton(
                                        onPressed: () {
                                          //for hiding image dialog
                                          Navigator.pop(context);

                                          //move to view profile screen
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => Porfile_Other_Users(user: user)));
                                        },
                                        minWidth: 0,
                                        padding: const EdgeInsets.all(0),
                                        shape: const CircleBorder(),
                                        child: const Icon(Icons.info_outline,
                                            color: Colors.blue, size: 30),
                                      ))
                                ],
                              );
                            } else {
                              return const Center(
                                child: Text(
                                    'No connection Found'),
                              ); // ToDO:: Handel this
                            }
                        }
                      }

                      );

              }
            }

          )),
    );
  }
}