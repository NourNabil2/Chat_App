import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Home_Screen/View/Widgets/ChatsList_widget.dart';
import 'package:flutter/material.dart';
import 'AppBar_Sliver_widget.dart';

class chatsPage extends StatefulWidget {
  final ScrollController controller;
  const chatsPage({super.key,required this.controller});

  @override
  State<chatsPage> createState() => _chatsPageState();
}
class _chatsPageState extends State<chatsPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return CustomScrollView(
        controller: widget.controller,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        shrinkWrap: true,
        slivers: const [
          appbarSliver(),
          chatsList(),
        ]);
  }
}




