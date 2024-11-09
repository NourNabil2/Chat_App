import 'dart:developer';
import 'dart:io'; // Import for File type
import 'package:chats/Core/Functions/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:chats/Features/Home_Screen/Model_View/Chats_Cubit/chats_cubit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../../Core/Network/API.dart';
import '../../../Core/Utils/constants.dart';
import '../../Status_Page/View/widget/customDivider.dart';

class SelectUsers extends StatefulWidget {
  final File? selectedMedia; // Changed to selectedMedia to support both images and videos
  final bool isVideo; // Flag to determine if the selected media is a video

  const SelectUsers({super.key, this.selectedMedia, this.isVideo = false}); // Default isVideo to false

  @override
  State<SelectUsers> createState() => _SelectUsersState();
}

class _SelectUsersState extends State<SelectUsers> {
  List<ChatUser> userList = [];
  List<ChatUser> searchList = [];
  List<ChatUser> selectedUsers = []; // List to store selected users
  bool _isUploading = false; // Boolean to track uploading state

  // Function to send the selected media (image or video) to multiple users
  void _sendMedia() async {
    if (widget.selectedMedia != null && selectedUsers.isNotEmpty) {
      setState(() {
        _isUploading = true; // Start showing the loading indicator
      });

      try {
        if (widget.isVideo) {
          await APIs.sendChatVideoToMultipleUsers(selectedUsers, widget.selectedMedia!);
        } else {
          await APIs.sendChatImageToMultipleUsers(selectedUsers, widget.selectedMedia!);
        }
        Dialogs.showSnackbar(context, 'Sent Successfully');

        // Add strike to each selected user
        for (var user in selectedUsers) {
          await APIs.addOrUpdateStreak(user.id);
        }
      } catch (e) {
        Dialogs.showSnackbar(context, 'Error sending media');
      } finally {
        setState(() {
          _isUploading = false; // Stop showing the loading indicator
        });
        Navigator.pop(context); // Close the screen after sending
      }
    } else if (selectedUsers.isEmpty) {
      Dialogs.showSnackbar(context, 'No User Selected');
    } else {
      Dialogs.showSnackbar(context, 'Unexpected Error');
    }
  }

  // Function to send the selected image as a story
  void _sendStoryImage() async {
    if (widget.selectedMedia != null && !widget.isVideo) {
      setState(() {
        _isUploading = true;
      });

      await APIs.sendStoryMedia(widget.selectedMedia!,isPublic: false).then((_) {
        Dialogs.showSnackbar(context, 'Story Image Sent Successfully');
      }).catchError((error) {
        Dialogs.showSnackbar(context, 'Failed to send story image');
      }).whenComplete(() {
        setState(() {
          _isUploading = false;
        });
        Navigator.pop(context);
      });
    }
  }

  // Function to send the selected video as a story
  void _sendStoryVideo() async {
    if (widget.selectedMedia != null && widget.isVideo) {
      setState(() {
        _isUploading = true;
      });

      await APIs.sendStoryMedia(widget.selectedMedia!, isVideo: false,isPublic: false).then((_) {
        Dialogs.showSnackbar(context, 'Story Video Sent Successfully');
      }).catchError((error) {
        Dialogs.showSnackbar(context, 'Failed to send story video');
      }).whenComplete(() {
        setState(() {
          _isUploading = false;
        });
        Navigator.pop(context);
      });
    }
  }
  ///public
  // Function to send the selected image as a story
  void _sendStoryImage_public() async {
    if (widget.selectedMedia != null && !widget.isVideo) {
      setState(() {
        _isUploading = true;
      });

      await APIs.sendStoryMedia(widget.selectedMedia!,isPublic: true).then((_) {
        Dialogs.showSnackbar(context, 'Story Image Sent Successfully');
      }).catchError((error) {
        Dialogs.showSnackbar(context, 'Failed to send story image');
      }).whenComplete(() {
        setState(() {
          _isUploading = false;
        });
        Navigator.pop(context);
      });
    }
  }

  // Function to send the selected video as a story
  void _sendStoryVideo_public() async {
    if (widget.selectedMedia != null && widget.isVideo) {
      setState(() {
        _isUploading = true;
      });

      await APIs.sendStoryMedia(widget.selectedMedia!, isVideo: true,isPublic: false).then((_) {
        Dialogs.showSnackbar(context, 'Story Video Sent Successfully');
      }).catchError((error) {
        Dialogs.showSnackbar(context, 'Failed to send story video');
      }).whenComplete(() {
        setState(() {
          _isUploading = false;
        });
        Navigator.pop(context);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsCubit, ChatsState>(
      listener: (context, state) {
        if (state is SearchIconState) {
          BlocProvider.of<ChatsCubit>(context).getMyUsersId();
        }
      },
      builder: (context, state) {
        userList = (state is getAlluser) ? state.UserList : [];
        searchList = (state is ChatsDisplaylist) ? state.searchList : [];

        return ModalProgressHUD(
          inAsyncCall: _isUploading,
          progressIndicator: CircularProgressIndicator(),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: widget.isVideo ? _sendStoryVideo : _sendStoryImage,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: NetworkImage(APIs.me.image),
                          ),
                          title: Text("My Story . Friend Only", style: Theme.of(context).textTheme.bodyMedium),
                          trailing: Icon(Icons.send),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: widget.isVideo ? _sendStoryVideo_public : _sendStoryImage_public,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: NetworkImage(APIs.me.image),
                          ),
                          title: Text("My Story . Public", style: Theme.of(context).textTheme.bodyMedium),
                          trailing: Icon(Icons.send),
                        ),
                      ),
                    ),
                    const CenteredTextDivider(text: 'My friends'),
                    Expanded(
                      child: ListView.builder(
                        itemCount: ChatsCubit.isSearching ? searchList.length : userList.length,
                        itemBuilder: (context, index) {
                          ChatUser user = ChatsCubit.isSearching ? searchList[index] : userList[index];
                          bool isSelected = selectedUsers.contains(user);

                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(AppSize.s8),
                                child: ListTile(
                                  key: Key('KEY_$index'),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: user.image != null && user.image.isNotEmpty
                                        ? NetworkImage(user.image)
                                        : null,
                                    child: user.image == null || user.image.isEmpty
                                        ? Text(
                                      user.name[0].toUpperCase(),
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    )
                                        : null,
                                  ),
                                  title: Text(user.name, style: Theme.of(context).textTheme.bodyMedium),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? selected) {
                                      setState(() {
                                        if (selected == true) {
                                          selectedUsers.add(user);
                                        } else {
                                          selectedUsers.remove(user);
                                        }
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                ),
                              ),
                              if (index != (ChatsCubit.isSearching ? searchList.length : userList.length) - 1)
                                const Divider(color: Colors.grey, thickness: 0.2, height: 0.1),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    onPressed: _sendMedia,
                    tooltip: 'Send Media',
                    child: Icon(Icons.send, color: Theme.of(context).secondaryHeaderColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
