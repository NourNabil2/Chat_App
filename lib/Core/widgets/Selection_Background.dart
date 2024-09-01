import 'package:chats/Core/Utils/Colors.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Profile_Screen/View_Data/profile_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget customSelection( int selected , context,ProfileCubit)
{
  return SingleChildScrollView(
   // padding: EdgeInsets.all(8),
    scrollDirection: Axis.horizontal,
    child: Row(children: [
      customOutlineButton(1, selected , context , bg_black),
      customOutlineButton(2, selected , context , bg_black2),
      customOutlineButton(3, selected , context , bg_white),

    ],)
  );
}

Widget customOutlineButton(int index, int selected , context , image)
{
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        overlayColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color:Theme.of(context).primaryColor,width: 1.5 ,style: selected == index ? BorderStyle.solid :BorderStyle.none ),
      ),
      onPressed: () {
        ProfileCubit.get(context).changeSelecte(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(width: 75,height: 70,image,fit: BoxFit.fitWidth,),
        ),
      ),
    ),
  );
}