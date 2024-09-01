import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Friend_Screen/View/Friend_Request_Page.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:chats/Features/Home_Screen/Model_View/Chats_Cubit/chats_cubit.dart';
import 'package:chats/Features/Status_Page/View/Status_Screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:status_view/status_view.dart';

import '../../../Profile_Screen/View/Profile_Screen.dart';

class appbarSliver extends StatefulWidget {
  const appbarSliver({super.key});

  @override
  State<appbarSliver> createState() => _appbarSliverState();
}
List<ChatUser> UserList = [];
String? _image;
class _appbarSliverState extends State<appbarSliver> {
  void _showBottomSheet() {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).primaryColor,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(2))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: 20),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(20, 10)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.sendStoryImage(File(_image!));

                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/add_image.png')),
                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(20, 15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.sendStoryImage(File(_image!));

                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/camera.png')),
                ],
              )
            ],
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        UserList = (state is getAlluser) ? state.UserList : [] ;
        return SliverAppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark),
          backgroundColor: Theme.of(context).primaryColorDark,
          elevation: 0.0,
          pinned: true,
          stretch: true,
          leadingWidth: 90,
          leading: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: CircleAvatar(backgroundColor: Colors.white24,child: IconButton(onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context) => ProfileScreen(user: APIs.me),)) ,icon:const Icon( Icons.person),color: Theme.of(context).textTheme.bodyMedium?.color,),)),
              Expanded(
                child: CircleAvatar(
                    backgroundColor: Colors.white24,
                    child:IconButton(
                        onPressed: () {
                          ChatsCubit.get(context).ChangeSearchIcon();
                        },
                        icon: Icon(
                          size: 20,
                          ChatsCubit.isSearching
                              ? Icons.cancel
                              : Icons.search,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ))),
              ),
            ],
          ),
          actions: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Stack(alignment: Alignment.topLeft, children: [
                FriendRequesList.isNotEmpty ? Container(
                  width: AppSize.s10,
                  height: AppSize.s10,
                  decoration: BoxDecoration(
                      color: Colors.red,

                      borderRadius: BorderRadius.circular(10)),
                ) : Container(),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FriendRequestPage(user: APIs.me),
                          ));
                    },
                    icon: Icon(
                      Icons.person_add,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    )),
              ]),
            ),
SizedBox(width: 5,),
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.more_horiz,color: Theme.of(context).textTheme.bodyMedium?.color,),
            ),
          ],
          title: ChatsCubit.isSearching
              ? TextField(
            decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                hintText: AppString.searchBar),
            autofocus: true,
            style: Theme.of(context).textTheme.bodyMedium,
            //when search text changes then updated search list
            onChanged: (val) {
              //search logic
              ChatsCubit.get(context).search(val);
            },
          )
              : Center(child: Text('Chats',style: Theme.of(context).textTheme.titleMedium)), // todo :: make widget


        );
      },
    );
  }
}
