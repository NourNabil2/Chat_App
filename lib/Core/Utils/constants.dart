
import 'package:flutter/material.dart';


const kLogo = 'assets/images/logo.png';
const kLogoscreen = 'assets/images/login_screen.jpg';
const kindicator = 'assets/indicator/indicator1.gif';
const kGoogleSVG = 'assets/images/google_logo.svg';
const kMessagesCollections = 'messages';
const kUsersCollections = 'Users';
const kMessage = 'message';
const kName = 'name';
const kCreatedAt = 'createdAt';
Size? mq;
//background chat page
const bg_black = 'assets/images/bg_chat_black.jpg';
const bg_black2 = 'assets/images/bg_chat_black2.jpg';
const bg_white = 'assets/images/bg_chat_white.jpg';
const bg_Defualt = 'assets/images/cancel.png';
// String of App
class AppString
{
  static String stheme = 'Theme of App';
  static String sLog = 'LOGOUT';
  static String sedit = 'Update';
  static String name = 'Your Name';
  static String about = 'About You';
  static String themechat = 'Background';
  static String info = 'Information';
  static String hi = 'Say Hii! 👋';
  static String img = 'Image';
  static String chats = 'Chats';
  static String searchBar = 'Search';
}
class AppSize
{
  static double s4 = 4.0;
  static double s8 = 8.0;
  static double s10 = 10.0;
  static double s15 = 15.0;
  static double s30 = 30.0;
  static double s80 = 80.0;
  static double s160 = 160.0;
  static double expande = 270.0;
}

final RegExp EMAIL_VALIDATION_REGEX =
RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

final RegExp non_VALIDATION_REGEX =
RegExp('');

final RegExp PASSWORD_VALIDATION_REGEX =
RegExp(r"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$");

final RegExp NAME_VALIDATION_REGEX = RegExp(r"\b([A-ZÀ-ÿ][-,a-z. ']+[ ]*)+");

const String PLACEHOLDER_PFP =
    "https://t3.ftcdn.net/jpg/05/16/27/58/360_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg";

final RegExp PHONE_VALIDATION_REGEX = RegExp(r"^\d{9}$");
