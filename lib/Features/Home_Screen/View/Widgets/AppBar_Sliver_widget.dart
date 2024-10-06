// appbarSliver.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Profile_Screen/View/Profile_Screen.dart';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Features/Friend_Screen/View/Friend_Request_Page.dart';

import '../../Model_View/Chats_Cubit/chats_cubit.dart';
import '../../Model_View/freiend_request_cubit.dart';

class appbarSliver extends StatefulWidget {
  const appbarSliver({super.key});

  @override
  State<appbarSliver> createState() => _appbarSliverState();
}

class _appbarSliverState extends State<appbarSliver> {
  @override
  void initState() {
    super.initState();
    context.read<FreiendRequestCubit>().fetchFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FreiendRequestCubit, FreiendRequestState>(
      builder: (context, state) {
        int friendRequestCount = 0;

        if (state is FriendRequestsUpdated) {
          friendRequestCount = state.friendRequestList.length;
        }

        return SliverAppBar(
          backgroundColor: Theme.of(context).primaryColorDark,
          pinned: true,
          leadingWidth: 90,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navIcon(Icons.person, ProfileScreen(user: APIs.me)),
              _searchIcon(context),
            ],
          ),
          actions: [
            _friendRequestIcon(context, friendRequestCount),
            const SizedBox(width: 5),
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.more_horiz, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ],
          title: _buildTitle(context),
        );
      },
    );
  }

  Widget _navIcon(IconData icon, Widget page) {
    return CircleAvatar(
      backgroundColor: Colors.white24,
      child: IconButton(
        icon: Icon(icon),
        color: Theme.of(context).textTheme.bodyMedium?.color,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      ),
    );
  }

  Widget _searchIcon(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white24,
      child: IconButton(
        onPressed: () => ChatsCubit.get(context).ChangeSearchIcon(),
        icon: Icon(
          ChatsCubit.isSearching ? Icons.cancel : Icons.search,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _friendRequestIcon(BuildContext context, int friendRequestCount) {
    return CircleAvatar(
      backgroundColor: Colors.white24,
      child: Stack(alignment: Alignment.topLeft, children: [
        if (friendRequestCount > 0)
          Container(
            width: AppSize.s15,
            height: AppSize.s15,
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text('$friendRequestCount', style: Theme.of(context).textTheme.bodySmall)),
          ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FriendRequestPage(user: APIs.me)),
          ),
          icon: Icon(Icons.person_add, color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      ]),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return ChatsCubit.isSearching
        ? TextField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: AppString.searchBar,
        hintStyle: Theme.of(context).textTheme.bodyMedium,
      ),
      autofocus: true,
      style: Theme.of(context).textTheme.bodyMedium,
      onChanged: (val) => ChatsCubit.get(context).search(val),
    )
        : Center(child: Text('Chats', style: Theme.of(context).textTheme.titleMedium));
  }
}
