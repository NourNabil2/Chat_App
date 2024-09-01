import 'package:flutter/material.dart';

Widget CustomButton(context,function,text,icon){
  return  ElevatedButton(
    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColorDark)),
    onPressed: function ,
    child: Row(
      children: [
        icon == null ? Container() :Icon( icon , color: Theme.of(context).textTheme.bodyMedium?.color ,),
        Text('$text',style: Theme.of(context).textTheme.bodyMedium,),
      ],
    ),
  );
}