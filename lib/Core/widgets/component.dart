import 'package:chats/Core/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Functions/show_snack_bar.dart';
import '../Network/API.dart';

Widget signInWithText() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Expanded(child: Divider()),
      const SizedBox(
        width: 16,
      ),
      Text(
        'Or Sign in with',
        style: GoogleFonts.inter(
          fontSize: 12.0,
          color: const Color(0xFF969AA8),
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(
        width: 16,
      ),
      const Expanded(child: Divider()),
    ],
  );
}

void addChatUserDialog(context) {
  String username = ''; // Changed from email to username
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).primaryColorDark,
        contentPadding: const EdgeInsets.only(
            left: 24, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        //title
        title: Row(
          children: [
            Icon(
              Icons.person_add,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            Text('  Add User', style: Theme.of(context).textTheme.bodyMedium,)
          ],
        ),

        //content
        content: CustomFormTextField(
          hintText: 'Username', // Updated hint text
          onChanged: (value) => username = value, // Updated variable name
        ),

        //actions
        actions: [
          //cancel button
          MaterialButton(
              onPressed: () {
                //hide alert dialog
                Navigator.pop(context);
              },
              child: Text('Cancel',
                style: Theme.of(context).textTheme.bodyMedium, )),

          //add button
          MaterialButton(
              onPressed: () async {
                //hide alert dialog
                Navigator.pop(context);
                if (username.isNotEmpty) {
                  await APIs.sendFriendRequestByUsername(username, context).then((value) { // Updated API call
                    if (!value) {
                      Dialogs.showSnackbar(
                          context, 'User does not exist!');
                    }
                    else {
                      Dialogs.showSnackbar(
                          context, 'Friend request sent successfully!');
                    }
                  });
                }
              },
              child: Text(
                'Add',
                style: Theme.of(context).textTheme.bodyMedium,
              ))
        ],
      ));
}


Widget Box({ double height =0 , double width =0})
{
  return SizedBox(
    height: height,
    width: width,
  );
}

Widget Splite(context) {
return Padding(
padding: const EdgeInsets.all(8.0),
child: Container(height: 1,decoration: BoxDecoration(color: Theme.of(context).primaryColor),),
);
}