import 'dart:developer';
import 'package:chats/Core/Functions/CashSaver.dart';
import 'package:chats/Features/Auth_screen/Model_view/Sign_cubit.dart';
import 'package:chats/Features/Chat_Screen/View/chat_page.dart';
import 'package:chats/Features/Home_Screen/Model_View/Chats_Cubit/chats_cubit.dart';
import 'package:chats/Features/Home_Screen/View/Home_Screen.dart';
import 'package:chats/Features/Profile_Screen/View_Data/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Core/Utils/Colors.dart';
import 'Features/Auth_screen/View/login_page.dart';
import 'Features/Auth_screen/View/resgister_page.dart';
import 'Features/Chat_Screen/Model_View/chat_cubit.dart';
import 'Features/Home_Screen/Model_View/freiend_request_cubit.dart';
import 'Features/Home_Screen/Model_View/home_cubit.dart';
import 'Features/Home_Screen/View/MainScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CashSaver.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats',
      enableSound: true,
      allowBubbles: true,
      showBadge: true,
      enableVibration: true,
    );
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SignCubit()),
        BlocProvider(create: (context) => FreiendRequestCubit()),
        BlocProvider(create: (context) => ChatCubit()),
        BlocProvider(create: (context) => HomeCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => ChatsCubit()..getMyUsersId()),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            debugShowMaterialGrid: false,
            themeMode: ProfileCubit.get(context).Darkmood
                ? ThemeMode.dark
                : ThemeMode.light,
            theme: ThemeData(
              secondaryHeaderColor: ColorApp.whitechat,
              primaryColorLight: ColorApp.kwhiteColor,
              primaryColorDark: ColorApp.kwhiteColor,
              primaryColor: ColorApp.whitechat,
              textTheme: const TextTheme(
                titleMedium: TextStyle(
                    color: ColorApp.whitechat,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    fontFamily: 'Urbanist'),
                titleSmall: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontFamily: 'Urbanist'),
                bodySmall: TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                    fontFamily: 'Urbanist'),
                labelSmall: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist'),
                bodyMedium: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Urbanist'),
              ),
              textButtonTheme: const TextButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(ColorApp.whitechat),
                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                ),
              ),
            ),
            darkTheme: ThemeData(
              secondaryHeaderColor: ColorApp.kwhiteColor,
              primaryColorLight: ColorApp.kPrimaryColor,
              primaryColorDark: ColorApp.mainDark,
              primaryColor: ColorApp.darkchat,
              iconTheme: const IconThemeData(color: ColorApp.kwhiteColor),
              textTheme: const TextTheme(
                titleMedium: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold),
                titleSmall: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Urbanist'),
                bodySmall: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontFamily: 'Urbanist'),
                bodyMedium: TextStyle(
                    color: ColorApp.kwhiteColor,
                    fontSize: 16,
                    fontFamily: 'Urbanist'),
                labelSmall: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist'),
              ),
              textButtonTheme: const TextButtonThemeData(
                style: ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                  backgroundColor: MaterialStatePropertyAll(ColorApp.darkchat),
                ),
              ),
            ),
            routes: {
              MainScreen.id: (context) => MainScreen(),
              LoginPage.id: (context) => LoginPage(),
              RegisterPage.id: (context) => RegisterPage(),
            },
            initialRoute: CashSaver.getData(key: 'Login') ?? false
                ? MainScreen.id
                : LoginPage.id,
          );
        },
      ),
    );
  }
}
