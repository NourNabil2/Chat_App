import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/widgets/Shimmer_Loading.dart';
import 'package:chats/Core/widgets/component.dart';
import 'package:chats/Features/Friend_Screen/Data/FriendRequest.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Core/Utils/Colors.dart';

class FriendRequestPage extends StatefulWidget {
  const FriendRequestPage({super.key, required ChatUser user});

  @override
  State<FriendRequestPage> createState() => _FriendRequestPageState();
}

List<Friendrequest> FriendRequesList = [];

class _FriendRequestPageState extends State<FriendRequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(

        iconTheme: IconThemeData(color: Theme.of(context).hintColor),
        backgroundColor: Theme.of(context).primaryColorDark,
        elevation: 0,
        title: Text('Friend Requests',style: Theme.of(context).textTheme.bodyMedium,),
      ),
      floatingActionButton:
          FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        onPressed: () {
          setState(() {
            addChatUserDialog(context);
          });
        },
        child: const Icon(Icons.add_comment_outlined, color: ColorApp.kwhiteColor),
      ),

      body: StreamBuilder(
          stream: APIs.getFriendRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,));
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(child: Text('No friend requests'));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final data = snapshot.data?.docs;
            for (var i in data!) {

                FriendRequesList =
                    data.map((e) => Friendrequest.fromJson(e.data())).toList() ??
                        [];


            }

            if (FriendRequesList.isEmpty) {
              return Center(child: Text('No friend requests'));
            }

            if (FriendRequesList.isNotEmpty) {

              return ListView.builder(
                itemCount: FriendRequesList.length,
                itemBuilder: (context, index) {

                  final request = FriendRequesList[index];
                  return ListTile(

                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 30,
                      backgroundImage:CachedNetworkImageProvider( request.image,),

                    ),
                    title: Text(request.name, style: Theme.of(context).textTheme.bodyMedium,),

                    subtitle: Text('${request.about}',style:Theme.of(context).textTheme.bodySmall ,),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        CircleAvatar(
                          backgroundColor: Colors.white24,

                          child: IconButton(
                            icon: Icon(Icons.check,color: Theme.of(context).textTheme.bodyMedium?.color,),
                            onPressed: () {
                              setState(() {
                                FriendRequesList.remove(index);
                              });
                              APIs.acceptFriendRequest(request);
                            },
                          ),
                        ),
                        Box(width: 5),
                        CircleAvatar(
      backgroundColor: Colors.white24,
                          child: IconButton(
                            icon: Icon(Icons.clear, color: Theme.of(context).textTheme.bodyMedium?.color,),
                            onPressed: () {
                              setState(() {
                                FriendRequesList.remove(index);
                              });
                              APIs.deleteFriendRequest(request);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No connection Found'),
              ); // ToDO:: Handel this
            }
          }),
    );
  }
}