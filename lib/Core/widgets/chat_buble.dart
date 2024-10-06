import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:video_player/video_player.dart';
import '../../Features/Chat_Screen/Data/message.dart';
import '../Functions/Time_Format.dart';
import '../Functions/show_snack_bar.dart';
import '../Network/API.dart';
import '../Utils/Colors.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  VideoPlayerController? _videoController;

// Initialize VideoPlayer using video URL
  Future<void> _initializeVideoPlayerFuture(String videoUrl) async {
    _videoController = VideoPlayerController.network(videoUrl);

    // Initialize the video controller
    await _videoController!.initialize();

    // Set the video to loop
    _videoController!.setLooping(true);

    // Automatically start playing the video
    _videoController!.play();

    // Call setState to rebuild the widget and show the video
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  // Sender or receiver message
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return _messageContent(isMe: false);
  }

  Widget _greenMessage() {
    return _messageContent(isMe: true);
  }

  Widget _messageContent({required bool isMe}) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
                widget.message.type == Type.image || widget.message.type == Type.video
                    ? 10
                    : 5),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColorLight,
              border: Border.all(color: ColorApp.kPrimaryColor),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomRight: Radius.circular(isMe ? 0 : 20),
                bottomLeft: Radius.circular(isMe ? 20 : 0),
              ),
            ),
            child: widget.message.type == Type.text
                ? _buildTextMessage()
                : widget.message.type == Type.image
                ? _buildImageMessage()
                : _buildVideoMessage(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.message.msg,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text(
          Format_Time.getFormattedTime(
              context: context, time: widget.message.sent),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildImageMessage() {
    return widget.message.msg.isNotEmpty
        ? InkWell(
      onTap: () => _showFullScreenImage(context,widget.message.msg),
          child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
          imageUrl: widget.message.msg,
          width: AppSize.s160,
          placeholder: (context, url) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) =>
          const Icon(Icons.error, size: 70, color: Colors.red),
                ),
              ),
        )
        : const Icon(Icons.error, size: 70, color: Colors.red);
  }

  Widget _buildVideoMessage() {
    return widget.message.msg.isNotEmpty
        ? ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: FutureBuilder<void>(
        future: _initializeVideoPlayerFuture(widget.message.msg),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {

            // Show the "Video is Ready" button
            return ElevatedButton(
              onPressed: () {
                // Show video in a full-screen dialog like Snapchat
                _showFullScreenVideo(context);
              },
              child: Text('Video is Ready'),
            );
          } else {
            // Show a loading indicator while video is being prepared
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
        },
      ),
    )
        : const Icon(Icons.error, size: 70, color: Colors.red);
  }

// Method to show the video in full-screen like Snapchat
  void _showFullScreenVideo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(0),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(_videoController!),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close full-screen view
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Method to show the image in full-screen
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(0),
        child: Stack(
          children: [
            // Display the image in full-screen
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop(); // Close full-screen view
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void showBottomSheet(bool isMe) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).primaryColorDark,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            _bottomSheetHandle(),
            widget.message.type == Type.text
                ? _OptionItem(
              icon: const Icon(Icons.copy_all_rounded,
                  color: Colors.blue, size: 26),
              name: 'Copy Text',
              onTap: () async {
                await Clipboard.setData(
                    ClipboardData(text: widget.message.msg));
                Navigator.pop(context);
                Dialogs.showSnackbar(context, 'Text Copied!');
              },
            )
                : _OptionItem(
              icon: const Icon(Icons.download_rounded,
                  color: Colors.blue, size: 26),
              name: 'Save Media',
              onTap: () async {
                try {
                  bool success = await _saveNetworkImage(widget.message.msg);
                  Navigator.pop(context);
                  if (success) {
                    Dialogs.showSnackbar(
                        context, 'Media Successfully Saved!');
                  }
                } catch (e) {
                  log('ErrorWhileSavingMedia: $e');
                }
              },
            ),
            if (isMe && widget.message.type == Type.text)
              _OptionItem(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                name: 'Edit Message',
                onTap: () {
                  Navigator.pop(context);
                  showMessageUpdateDialog();
                },
              ),
            if (isMe)
              _OptionItem(
                icon: const Icon(Icons.delete_forever,
                    color: Colors.red, size: 26),
                name: 'Delete Message',
                onTap: () async {
                  await APIs.deleteMessage(widget.message);
                  Navigator.pop(context);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _bottomSheetHandle() {
    return Container(
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 150),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Future<bool> _saveNetworkImage(String path) async {
    try {
      var response = await Dio().get(path, options: Options(responseType: ResponseType.bytes));
      final result = await SaverGallery.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        name: "media",
        androidExistNotSave: false,
      );
      log(result.toString());
      return true;
    } catch (e) {
      log('ErrorWhileSavingMedia: $e');
      return false;
    }
  }

  void showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.message, color: Colors.blue, size: 28),
            Text(' Update Message'),
          ],
        ),
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updatedMsg);
            },
            child: const Text('Update', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '   $name',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}