import 'package:chats/Core/Utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Core/Utils/Colors.dart';
import '../../../Core/Network/API.dart';
import '../../../Core/widgets/component.dart';
import '../../Call_Screen/View/Call_Page.dart';
import '../../Camera_Screen/View/Camera_Page.dart';
import '../../Friend_Screen/View/Friend_Request_Page.dart';
import '../../Profile_Screen/View/Profile_Screen.dart';
import '../../Status_Screen/view/statusInfo_Page.dart';
import '../Model_View/home_cubit.dart';
import 'Home_Screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  static String id = 'HomeScreen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  HomeCubit cubit = HomeCubit();
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 5, initialIndex: 2, vsync: this);

    tabController.animation!.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != HomeCubit.current && mounted) {
        setState(() {
          cubit.ChangePage(value);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: TabBarView(
            controller: tabController,
            dragStartBehavior: DragStartBehavior.down,
            physics: const BouncingScrollPhysics(),
            children: [
              HomeScreen(controller: ScrollController()),
              const statusInfoPage(),
              CameraScreen(), // CameraScreen as the initial screen
              const callPage(),

            ],
          ),
          floatingActionButton: HomeCubit.current == 0 ? FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                addChatUserDialog(context);
              });
            },
            child: const Icon(Icons.add_comment_outlined, color: ColorApp.kwhiteColor),
          ) : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 0.1, // Height of the line
                color: Colors.grey, // Color of the line
              ),
              SizedBox(
                height: AppSize.s90,
                child: BottomNavigationBar(
                  currentIndex: HomeCubit.current,
                  iconSize: AppSize.s30,
                  onTap: (index) {
                    setState(() {
                      cubit.ChangePage(index);
                      tabController.animateTo(index);
                    });
                  },
                  selectedItemColor: Theme.of(context).secondaryHeaderColor,
                  unselectedItemColor: Theme.of(context).secondaryHeaderColor,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.chat_bubble),
                      label: '',
                      backgroundColor: Theme.of(context).primaryColorDark,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.play_arrow_sharp,size: 40,),
                      label: '',
                      backgroundColor: Theme.of(context).primaryColorDark,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.camera_alt_outlined),
                      label: '',
                      backgroundColor: Theme.of(context).primaryColorDark,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.people_outline_rounded),
                      label: '',
                      backgroundColor: Theme.of(context).primaryColorDark,
                    ),

                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
