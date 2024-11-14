import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Profile_Screen/View_Data/profile_cubit.dart';
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
import '../../Map_Screen/View/Map_Screen.dart';
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
    tabController = TabController(length: 3, initialIndex: 1, vsync: this);

    tabController.animation!.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != HomeCubit.current && mounted) { // Check if mounted
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
            physics: const NeverScrollableScrollPhysics(), // Disables scrolling
            children: [
              //MapScreen(),
              HomeScreen(controller: ScrollController()),
              CameraScreen(), // CameraScreen as the initial screen
              const StatusInfoPage(),
             // const callPage(),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 0.1, // Height of the line
                color: Colors.grey, // Color of the line
              ),
              SizedBox(
                height: AppSize.s80,
                child: BottomNavigationBar(
                  backgroundColor: ProfileCubit.get(context).Darkmood ? ColorApp.mainDark: ColorApp.kwhiteColor,
                  currentIndex: HomeCubit.current,
                  iconSize: AppSize.s30,
                  onTap: (index) {
                    if (mounted) { // Check if mounted
                      setState(() {
                        cubit.ChangePage(index);
                        tabController.animateTo(index);
                      });
                    }
                  },
                  selectedItemColor: Theme.of(context).secondaryHeaderColor,
                  unselectedItemColor: Theme.of(context).secondaryHeaderColor,
                  items: [
                    BottomNavigationBarItem(
                      icon:  Icon(Icons.chat_bubble_outline,color: Theme.of(context).hintColor,),
                      label: '',
                      activeIcon: Icon(Icons.chat_bubble,color: Theme.of(context).hintColor,),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.camera_alt_outlined,color: Theme.of(context).hintColor,),
                      label: '',
                      activeIcon: Icon(Icons.camera_alt,color: Theme.of(context).hintColor,),

                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.people_outline_rounded,color: Theme.of(context).hintColor,),
                      activeIcon: Icon(Icons.people_alt_rounded,color: Theme.of(context).hintColor,),
                      label: '',
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

