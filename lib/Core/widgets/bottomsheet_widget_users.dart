//custom options card (for copy, edit, delete, etc.)
import 'package:chats/Core/Functions/show_snack_bar.dart';
import 'package:chats/Core/Network/API.dart';
import 'package:flutter/material.dart';


void showBottomSheet_User(context,message) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).primaryColorDark,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            //black divider
            Container(
              height: 5,
              margin: EdgeInsets.symmetric(
                  vertical: 20, horizontal: 150),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),

            optionItem_Users(icon: Icon(Icons.delete,color: Theme.of(context).textTheme.bodyMedium!.color,), name: 'Delete Chat',
                onTap: () {
                  APIs.deleteallMessage(message).then((value) {
                    Navigator.pop(context);
                    Dialogs.showSnackbar(context, 'Deleted Chat Successfully');
                  },);
                },
              ),
          ],
        );
      });
}



class optionItem_Users extends StatelessWidget {
  final Icon icon;
  final String name;
  final Function() onTap;

  const optionItem_Users(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 10,
              top: 10,
              bottom: 10),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: Theme.of(context).textTheme.bodyMedium))
          ]),
        ));
  }
}