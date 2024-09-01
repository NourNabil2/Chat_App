import 'dart:developer';
import 'dart:io'; // Import for File type
import 'package:chats/Core/Functions/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:chats/Features/Home_Screen/Model_View/Chats_Cubit/chats_cubit.dart';
import '../../../Core/Network/API.dart';

class SelectUsers extends StatefulWidget {
  final File? selectedImage;
  const SelectUsers({super.key, this.selectedImage});

  @override
  State<SelectUsers> createState() => _SelectUsersState();
}

class _SelectUsersState extends State<SelectUsers> {
  List<ChatUser> userList = [];
  List<ChatUser> searchList = [];
  List<ChatUser> selectedUsers = []; // List to store selected users

  // Function to send the selected image to multiple users
  void _sendImage() async{
    if (widget.selectedImage != null && selectedUsers.isNotEmpty) {
      // Call your function to send the image to multiple users
      APIs.sendChatImageToMultipleUsers(selectedUsers, widget.selectedImage!);
      Dialogs.showSnackbar(context, 'Send Successfully');
      // Add strike to each selected user
      for (var user in selectedUsers)   {
        await APIs.addOrUpdateStreak(user.id); // Assuming `addStrikeToUser` accepts a user ID
      }
      Navigator.pop(context);
    } else if (selectedUsers.isEmpty){
      Dialogs.showSnackbar(context, 'No User Selected');
    }else {
      Dialogs.showSnackbar(context, 'Unexpected Error');
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

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: ChatsCubit.isSearching ? searchList.length : userList.length,
                    itemBuilder: (context, index) {
                      ChatUser user = ChatsCubit.isSearching ? searchList[index] : userList[index];
                      bool isSelected = selectedUsers.contains(user); // Check if the user is selected
                      return Column(
                        children: [
                          ListTile(
                            key: Key('KEY_$index'),
                            title: Text(user.name, style: Theme.of(context).textTheme.bodyMedium), // Display user name only
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    selectedUsers.add(user); // Add user to selected list
                                  } else {
                                    selectedUsers.remove(user); // Remove user from selected list
                                  }
                                });
                              },
                            ),
                          ),
                          if (index != (ChatsCubit.isSearching ? searchList.length : userList.length) - 1) // Add a separator line if it's not the last item
                            const Divider(
                              color: Colors.grey,
                              thickness: 0.2,
                              height: 0.1,
                            ),
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
                onPressed: _sendImage, // You can use any icon you prefer
                tooltip: 'Send Image', // Call the function to send the image
                child:  Icon(Icons.send,color: Theme.of(context).secondaryHeaderColor,),
              ),
            ),
          ],
        );
      },
    );
  }
}
