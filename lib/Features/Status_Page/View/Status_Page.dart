import 'dart:developer';
import 'dart:io';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Status_Page/View/My_Status_Screen.dart';
import 'package:chats/Features/Status_Page/View/User_Status_Screen.dart';
import 'package:chats/Features/Status_Page/View/widget/customDivider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:status_view/status_view.dart';
import '../../../Core/Network/API.dart';
import '../../Home_Screen/Data/Users.dart';

class UserStoryPage extends StatefulWidget {
  final List<ChatUser> userList;
  final List<ChatUser> alluserList;

  UserStoryPage({required this.userList, required this.alluserList, Key? key}) : super(key: key);

  @override
  State<UserStoryPage> createState() => _UserStoryPageState();
}

class _UserStoryPageState extends State<UserStoryPage> {
  String? _image;
  final ScrollController Scrollcontroller = ScrollController();
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
              const Text('Upload Story',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(20, 10)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.sendStoryMedia(File(_image!), isPublic: false);
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/add_image.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(20, 15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.sendStoryMedia(File(_image!), isPublic: false);
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
    final List<ChatUser> visiblePublicStories = widget.alluserList.where((user) => user.status_p > 0).toList();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(AppSize.s15),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MystatusPage(user: APIs.me),
                          ),
                        );
                      },
                      child: StatusView(
                        radius: 30,
                        seenColor: Theme.of(context).primaryColor,
                        indexOfSeenStatus: 0,
                        strokeWidth: 2,
                        numberOfStatus: APIs.me.status,
                        unSeenColor: Theme.of(context).secondaryHeaderColor,
                        centerImageUrl: APIs.me.image,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'My Story',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        _showBottomSheet(context);
                      },
                      icon: const Icon(
                        CupertinoIcons.add_circled_solid,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const CenteredTextDivider(text: 'Friend Stories'),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  controller: Scrollcontroller,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.userList.length,
                  itemBuilder: (context, index) {
                    if (widget.userList[index].status_f == 0) {
                      return Container();
                    }
                    return Padding(
                      padding: EdgeInsets.all(AppSize.s8),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatusPage(user: widget.userList[index], public: false),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            StatusView(
                              radius: 40,
                              seenColor: Theme.of(context).primaryColor,
                              indexOfSeenStatus: 0,
                              strokeWidth: 2,
                              numberOfStatus: widget.userList[index].status_f,
                              unSeenColor: Theme.of(context).secondaryHeaderColor,
                              centerImageUrl: widget.userList[index].image,
                            ),
                            SizedBox(height: 5),
                            Text(
                              widget.userList[index].name,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const CenteredTextDivider(text: 'Public Stories'),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: visiblePublicStories.length,
                  itemBuilder: (context, index) {
                    final user = visiblePublicStories[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatusPage(user: user, public: true),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(AppSize.s8)),
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                          image: DecorationImage(
                            image: NetworkImage(user.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Add a gradient overlay at the bottom for the text
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(AppSize.s8),
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                width: double.infinity,
                                child: Text(
                                  user.name,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
