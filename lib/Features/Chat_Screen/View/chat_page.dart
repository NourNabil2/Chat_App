import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats/Core/Functions/Time_Format.dart';
import 'package:chats/Core/Network/notification_service.dart';
import 'package:chats/Core/widgets/chat_buble.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:chats/Features/Profile_Screen/View_Data/profile_cubit.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Core/Network/API.dart';
import '../../../Core/Utils/Colors.dart';
import '../../../Core/Utils/constants.dart';
import '../../Profile_Screen/View/Profile_OtherUsers_Screen.dart';
import '../Data/message.dart';



class ChatPage extends StatefulWidget {
  static String id = 'ChatPage';
  final ChatUser user;

  ChatPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = ScrollController();

  bool showEmoji = false;

  List<Message> messagesList = [];

  TextEditingController controller = TextEditingController();

  bool _isUploading = false;

  void deleteAllMessages() {
    // Loop through the messagesList and check each message
    for (var message in messagesList) {
        APIs.deleteAllMessagesFromUser(message); // Call the delete API or function
    }
  }
// The deleteOldMessages method
  void deleteOldMessages() {
    DateTime currentTime = DateTime.now();
    debugPrint('Current time: ${currentTime}');

    if (messagesList.isEmpty) {
      debugPrint('The list is empty.');
      return;
    }

    for (var message in messagesList) {
      // Convert the sent timestamp to DateTime
      int messageTimestamp = int.parse(message.sent);
      DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(messageTimestamp);
      debugPrint('Message time: ${Format_Time.getDetailedFormattedTime(message.sent)}');

      // Calculate the difference between now and when the message was sent
      Duration difference = currentTime.difference(messageTime);
      debugPrint('Difference: ${difference.inHours} hours');

      // Delete the message if it is older than 1 day
      if (difference.inHours >= 24) {
        APIs.deleteMessage(message); // Call the delete API or function
        debugPrint('Message deleted: ${Format_Time.getDetailedFormattedTime(message.sent)}');
      }
    }
  }


  @override
  void initState() {
    // Call the deleteOldMessages function when exiting the chat page
    deleteAllMessages();
    super.initState();
  }

  Widget build(BuildContext context) {
    // ChatCubit Cubit = BlocProvider.of<ChatCubit>(context);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
    child: SafeArea(
    child: WillPopScope(
    //if emojis are shown & back button is pressed then hide emojis
    //or else simple close current screen on back button click
    onWillPop: () {
    if (showEmoji) {
      showEmoji = !showEmoji;
    return Future.value(false);
    } else {
    return Future.value(true);
    }
    },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent.withOpacity(0.3),
          automaticallyImplyLeading: false,
          flexibleSpace: appBar(context),
        ),
        body: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              image:ProfileCubit.get(context).selected == 0 ?  null : DecorationImage(
                  image: AssetImage(
                      ProfileCubit.get(context).selected == 1 ? bg_black : ProfileCubit.get(context).selected == 2 ? bg_black2 : bg_white
                  ), fit: BoxFit.cover)),
          child: Column(
            children: [
              Expanded(
                child:StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        messagesList = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                        if (messagesList.isNotEmpty) {
                          // Call the deleteOldMessages function to clean up old messages
                          deleteOldMessages();
                          return ListView.builder(
                            reverse: true,
                            itemCount: messagesList.length,
                            padding: const EdgeInsets.only(top: 10),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(message: messagesList[index]);
                            },
                          );
                        } else {
                          return Center(
                            child: Container(),
                          );
                        }
                    }
                  },
                ),

              ),

              //progress indicator for showing uploading
              if (_isUploading)
                const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(strokeWidth: 2))),
              chatInput(context),
              if (showEmoji)
                SizedBox(
                  height: 300,
                  child: EmojiPicker(
                    textEditingController: controller,
                    config: Config(
                      //columns: 8,emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0) ,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    )));


  }

  Widget appBar(context) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => Porfile_Other_Users(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
              return Container(
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(
                    color: ColorApp.bg_gray, // Color of the top border
                    width: 2.0, // Width of the top border
                  ),)),
                child: Row(
                  children: [
                    //back button
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon:
                         Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyMedium!.color,)),

                    //user profile picture
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        width: 40,
                        height:40, //todo
                        imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                        errorWidget: (context, url, error) => const CircleAvatar(
                            child: Icon(CupertinoIcons.person)),
                      ),
                    ),

                    //for adding some space
                    const SizedBox(width: 10),

                    //user name & last seen time
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //user name
                        Text(list.isNotEmpty ? list[0].name : widget.user.name,
                            style: Theme.of(context).textTheme.bodyMedium,

                        ),

                        //for adding some space
                        const SizedBox(height: 2),

                       // last seen time of user
                        Text(
                            list.isNotEmpty ? list[0].isOnline ? 'Online' : "" :"",
                            style: Theme.of(context).textTheme.bodySmall, ),
                      ],
                    )
                  ],
                ),
              );
            }));
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
          //take image from camera button
          CircleAvatar(
            backgroundColor: ColorApp.bg_gray,
            child: IconButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                // Pick a video
                final XFile? video = await picker.pickVideo(
                  source: ImageSource.camera, // You can also change this to ImageSource.gallery if needed
                  maxDuration: const Duration(seconds: 60), // Set a max duration if desired
                );

                if (video != null) {
                  log('Video Path: ${video.path}');
                  setState(() => _isUploading = true);

                  // Sending the video
                  await APIs.sendChatVideo(widget.user, File(video.path));

                  setState(() => _isUploading = false);
                }
              },
              icon: Icon(
                Icons.videocam_rounded, // Changed the icon to video camera icon
                color: Theme.of(context).iconTheme.color,
                size: 26,
              ),
            ),
          ),

          IconButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                // Pick an image
                final XFile? image = await picker.pickImage(
                    source: ImageSource.camera, imageQuality: 70);
                if (image != null) {
                  log('Image Path: ${image.path}');
                  setState(() => _isUploading = true);
                  await APIs.sendChatImage(
                      widget.user, File(image.path));
                  setState(() => _isUploading = false);
                }
              },
              icon: CircleAvatar(
                backgroundColor: ColorApp.bg_gray,
                child: Icon(Icons.camera_alt_rounded,
                    color: Theme.of(context).iconTheme.color, size: 26),
              )),
          //input field & buttons
          Expanded(
            child: Card(

              color: Theme.of(context).primaryColorLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.s30)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {
                         FocusScope.of(context).unfocus();
                         setState(() => showEmoji = !showEmoji);
                      },
                      icon: Icon(Icons.emoji_emotions,
                          color: Theme.of(context).iconTheme.color, size: 25)),

                  Expanded(
                      child: TextField(
                        style: TextStyle(color: Theme.of(context).iconTheme.color,backgroundColor: Theme.of(context).primaryColorLight,),
                        controller: controller,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: () {
                          // if (Cubit.showEmoji) setState(() => _showEmoji = !_showEmoji);
                        },
                        decoration: InputDecoration(
                            hintText: 'Type Something...',
                            hintStyle: TextStyle(color: Theme.of(context).iconTheme.color,fontSize: 12,overflow: TextOverflow.ellipsis),
                            border: InputBorder.none),
                      )),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);
                        // uploading & sending image one by one
                        for (var i in images) {
                          log('Image Path: ${i.path}');
                         setState(() => _isUploading = true);
                         await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: Icon(Icons.image,
                          color: Theme.of(context).iconTheme.color, size: 26)),



                  //adding some space
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
SizedBox(width: 10,),
          //send message button
          MaterialButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {

                if (messagesList.isEmpty) {
                  //on first message (add user to my_user collection of chat user)
                  APIs.sendFirstMessage(
                    widget.user,controller.text ,Type.text
                  );
                  NotificationHelper.sendNotification(
                      targetToken:  widget.user.pushToken,
                      title: APIs.me.name,body: 'Send you a new message');
                } else {
                //  simply send message
                  APIs.sendMessage(
                      widget.user, controller.text, Type.text);
                  NotificationHelper.sendNotification(
                      targetToken:  widget.user.pushToken,
                      title: APIs.me.name,body: 'Send you a new message');
                }
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
