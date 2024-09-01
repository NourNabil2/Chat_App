
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/Utils/Colors.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Core/widgets/Selection_Background.dart';
import 'package:chats/Core/widgets/component.dart';
import 'package:chats/Core/widgets/custom_button.dart';
import 'package:chats/Core/widgets/custom_text_field.dart';

import 'package:chats/Features/Auth_screen/View/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';


import '../../../Core/Functions/CashSaver.dart';
import '../../../Core/Functions/show_snack_bar.dart';
import '../../Home_Screen/Data/Users.dart';
import '../View_Data/profile_cubit.dart';


class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  ProfileScreen({super.key, required this.user});

  static String id = 'ProfileScreen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  Widget BuildSettingScreen() {

    return SliverFillRemaining(

      child: BlocBuilder<ProfileCubit, ProfileState>(

  builder: (context, state) {
    return Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
              child: Form(
                        key: _formKey,
                        child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30), // TODO
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpansionPanelList(
                      expandIconColor: Theme.of(context).secondaryHeaderColor,
                      elevation: 0,
                      animationDuration: const Duration(milliseconds:700),
                      expansionCallback: (panelIndex, isExpanded) {
                        ProfileCubit.get(context).ExpandChange();
                      },
                      children: [
                        ExpansionPanel(
                          backgroundColor: Theme.of(context).primaryColorDark,
                            isExpanded:  ProfileCubit.get(context).isExpand,
                            headerBuilder: (context, isExpanded) {
                              return  Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppString.info,style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              );
                            }, body: BuildItem() ),
                      ],
                    ),
                    Splite(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text( AppString.stheme ,style: Theme.of(context).textTheme.bodyMedium),
                        FlutterSwitch(value: ProfileCubit.get(context).Darkmood , onToggle: (value) => ProfileCubit.get(context).changeTheme(),
                          toggleColor:        Theme.of(context).primaryColorLight,
                          activeToggleColor:  Theme.of(context).primaryColorDark,
                          activeColor:        Theme.of(context).primaryColor,
                          inactiveIcon:   const Icon(CupertinoIcons.sun_min_fill),
                          activeIcon:     const Icon(CupertinoIcons.moon_fill),
                        ),
                      ],
                    ),
                    Splite(context),
                    Text(AppString.themechat,style: Theme.of(context).textTheme.bodyMedium,),
                    customSelection(ProfileCubit.get(context).selected,context,ProfileCubit),
                    Splite(context),
                    CustomButon(text: AppString.sLog,onTap: () async {
                      //for showing progress dialog
                      Dialogs.showProgressBar(context);
                      await APIs.updateActiveStatus(false);
                      //sign out from app
                      await APIs.auth.signOut().then((value) async {
                        await GoogleSignIn().signOut().then((value) {
                          CashSaver.SaveData(key: 'Login', value: false);
                          APIs.auth = FirebaseAuth.instance;
                          //replacing home screen with login screen
                          Navigator.pushNamedAndRemoveUntil(context, LoginPage.id , (route) => false);
                        });
                      });
                    },),


                  ],
                ),
              ),
                        ),
                      ),
            );
  },
),

    );
  }


  @override
  Widget build(BuildContext context) {

    return CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent:
          AlwaysScrollableScrollPhysics(),
        ),
        shrinkWrap: true,
        slivers: [
          SliverAppBar(
            leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(CupertinoIcons.back,color: Theme.of(context).scaffoldBackgroundColor,)),
            systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
            backgroundColor: Theme.of(context).primaryColor,
            expandedHeight: 270,
            elevation: 0.0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.zoomBackground
              ],
              background: Container(
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).primaryColor,Theme.of(context).primaryColorLight,],)),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                      //     profile picture
                          _image != null
                              ?
                      //   local image
                          ClipRRect(
                              borderRadius:
                              BorderRadius.circular(50),
                              child: Image.file(File(_image!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover))
                              :
                      //   image from server
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              width: 100,
                              height:100,
                              fit: BoxFit.cover,
                              imageUrl: widget.user.image,
                              errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(CupertinoIcons.person)),
                            ),
                          ),

                      //edit image button
                          Positioned(
                            bottom: -10,
                            right: -10,
                            child: IconButton(
                              onPressed: () {
                                _showBottomSheet();
                              },
                              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor), ),
                              color: Theme.of(context).primaryColor,
                              icon:  Icon(Icons.edit, color: Theme.of(context).primaryColorDark ),
                            ),
                          )
                        ],
                      ),
// for adding some space
                      SizedBox(height: 10),
// user email label
                      Text(widget.user.email,
                          style: Theme.of(context).textTheme.bodyMedium
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(  preferredSize: const Size.fromHeight(0.0),
              child: Container(
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0),
                  ),
                ),
                child: Container(
                  width: 40.0,
                  height: 5.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
              ),
            ),
          ),
          BuildSettingScreen(),
        ]
    );
}

  void _showBottomSheet() {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).primaryColor,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(2))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
            EdgeInsets.only(top: 10, bottom: 10),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: 20),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(20, 10)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/add_image.png')),
                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(20, 15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/camera.png')),
                ],
              )
            ],
          );
        });
  }


  Widget BuildItem()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [                    // name input field
        Text(AppString.name),
        CustomFormTextField(
          initialValue: widget.user.name,
          onSaved: (val) => APIs.me.name = val ?? 'your name',
        ),
        // about input field
        Text(AppString.about),
        CustomFormTextField(
          initialValue: widget.user.about,
          onSaved: (val) => APIs.me.about = val ?? 'About me',
        ),
        Center(
          child: TextButton(onPressed: ()
          {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              APIs.updateUserInfo().then((value) {
                Dialogs.showSnackbar(
                    context, 'Profile Updated Successfully!'); //todo
              });
            }
          }, child: Text(AppString.sedit),style: Theme.of(context).textButtonTheme.style ),
        ),
      ],
    );
  }

}
