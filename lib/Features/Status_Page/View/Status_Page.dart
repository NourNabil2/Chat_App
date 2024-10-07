import 'dart:developer';
import 'dart:io';

import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Home_Screen/View/Widgets/AppBar_Sliver_widget.dart';
import 'package:chats/Features/Status_Page/View/widget/customDivider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:status_view/status_view.dart';

import '../../../Core/Network/API.dart';
import '../../Home_Screen/Data/Users.dart';
import 'Status_Screen.dart'; // Import your card user widget

class UserProfilePage extends StatefulWidget {
  final List<ChatUser> userList; // Assume ChatUser is your user model class


  UserProfilePage({required this.userList, Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? _image;
  void _showBottomSheet(BuildContext context) {
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

                          APIs.sendStoryMedia(File(_image!));

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

                          APIs.sendStoryMedia(File(_image!));

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
    log('user Story list statys ${widget.userList[1].status}');
    return Scaffold(
      body: Container(

        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(AppSize.s15),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                      Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            APIs.me.image,
                            errorBuilder: (context, url, error) =>
                            const CircleAvatar(
                              radius: 30,
                              child: Icon(CupertinoIcons.person),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'My Story',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Positioned(
                      right: -10,
                      child: IconButton(
                        onPressed: () {
                          _showBottomSheet(context);
                        },
                        icon: const Icon(
                          CupertinoIcons.add_circled_solid,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const CenteredTextDivider(text: 'Recent Updates'),
              widget.userList.isEmpty? Container() : Flexible(
                child: ListView.builder(
                  itemCount: widget.userList.length,
                  itemBuilder: (context, index) {
                    if (widget.userList[index].status == 0) {
                      return Container(); // Skip users with status 0
                    }

                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => statusPage(user: widget.userList[index]),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all( AppSize.s15),
                            child: Row(
                              children: [
                                StatusView(
                                  radius: 30,
                                  seenColor: Theme.of(context).primaryColor,
                                  indexOfSeenStatus: 0,
                                  strokeWidth: 2,
                                  numberOfStatus: widget.userList[index].status,
                                  unSeenColor: Theme.of(context).secondaryHeaderColor,
                                  centerImageUrl: widget.userList[index].image,
                                ),
                                SizedBox(width: AppSize.s10),
                                Expanded(
                                  child: Text(
                                    widget.userList[index].name,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 0.2,
                          height: 0.1,
                        ), // Add a divider between items
                      ],
                    );
                  },
                )

              ),
            ],
          ),
        ),
      ),
    );
  }


}
