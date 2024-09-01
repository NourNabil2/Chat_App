import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chats/Core/Functions/show_snack_bar.dart';
import 'package:chats/Features/Friend_Screen/Data/FriendRequest.dart';
import 'package:chats/Features/Status_Page/Model/Status.dart';
import 'package:chats/Features/Home_Screen/Data/Users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../../Features/Chat_Screen/Data/message.dart';
import '../Utils/constants.dart';


class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using ChatO!!",
      // Todo ::
      image: user.photoURL.toString(),
      status: 0,
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '',
      friendRequests: '',);

  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
  }


  // for sending push notification
  static Future<void> sendPushNotification(ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAq5paKI0:APA91bHrp5a_GWUbztUE-6KoV2f9HGWbXv02JyLFmU5RH_fu71D-FffK5bFUITkC2jdnnrjx0V-dgrxBmdPBneJihQsrhISj4yYDIDatwGIXgjPxlnwzxrzHFPVzQ0eix6oQ-z5zYlaj'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }


  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection(kUsersCollections).doc(user.uid).get())
        .exists;
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using We Chat!",
        // TODO:: const
        image: user.photoURL.toString(),
        status: 0,
        createdAt: time,
        isOnline: false,
        lastActive: time,
        friendRequests: '',
        pushToken: '',);

    return await firestore
        .collection(kUsersCollections)
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  ///************** Strike Related APIs **************
// Add or update the streak between me and a specific user
  static Future<void> addOrUpdateStreak(chatUser,) async {
    try {
      final ref = firestore
          .collection(kUsersCollections)
          .doc(user.uid)
          .collection('my_users')
          .doc(chatUser);

      // Get the current streak count
      final doc = await ref.get();

      if (doc.exists) {
        // Update the streak count
        await ref.update({
          'streakCount': FieldValue.increment(1),
        });
      } else {
        // Initialize the streak count if the document does not exist
        await ref.set({
          'streakCount': 1,
        });
      }

      log('Streak updated with user ${chatUser.id}');
    } catch (e) {
      log('Error updating streak: $e');
    }
  }

  // Get the streak count between me and a specific user
  static Future<int> getStreak(ChatUser chatUser) async {
    try {
      final ref = firestore
          .collection(kUsersCollections)
          .doc(user.uid)
          .collection('my_users')
          .doc(chatUser.id);

      final doc = await ref.get();

      if (doc.exists) {
        return doc.data()!['streakCount'] ?? 0;
      } else {
        return 0; // Return 0 if no streak record exists
      }
    } catch (e) {
      log('Error getting streak: $e');
      return 0;
    }
  }



  ///************** Friend Request Related APIs **************
// send Friend Request to User by email
  static Future<bool> sendFriendRequest(String email, context) async {
    final data = await firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    // Check if a friend request already exists
    final requestQuery = await firestore
        .collection('Users')
        .doc(data.docs.first.id)
        .collection('friendRequests')
        .where('from', isEqualTo: me.id)
        .get();

    // Check if a friend request already exists in my user
    final UserExistsQuery = await firestore
        .collection('Users')
        .doc(data.docs.first.id)
        .collection('my_users')
        .doc(me.id)
        .get();


    if (requestQuery.docs.isNotEmpty) {
      Dialogs.showSnackbar(context, 'Friend request already sent');
      throw Exception('Friend request already sent');
    } else if (UserExistsQuery.exists) {
      Dialogs.showSnackbar(context, 'already Friend');
      throw Exception('already Friend');
    }

    else if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      // Create a friend request document
      final s = await firestore
          .collection('Users')
          .doc(data.docs.first.id)
          .collection('friendRequests')
          .add({
        'id': data.docs.first.id,
        'from': user.uid,
        'name': me.name,
        'about': me.about,
        'Image': me.image,

      });
      return true;
    }
    else {
      //user doesn't exists

      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getFriendRequests() {
    return firestore
        .collection('Users')
        .doc(user.uid)
        .collection('friendRequests')
        .snapshots();
  }

  //delete FriendRequest
  static Future<void> deleteFriendRequest(Friendrequest request) async {
    final requestQuery = await firestore
        .collection('Users')
        .doc(request.id)
        .collection('friendRequests')
        .where('from', isEqualTo: request.from)
        .get();


    await firestore
        .collection('Users')
        .doc(user.uid)
        .collection('friendRequests')
        .doc(requestQuery.docs.first.id)
        .delete();
  }

  static Future<void> acceptFriendRequest(Friendrequest request) async {
    final requestQuery = await firestore
        .collection('Users')
        .doc(request.id)
        .collection('friendRequests')
        .where('from', isEqualTo: request.from)
        .get();

    // Update the friend request status to "accepted"
    await firestore
        .collection(kUsersCollections)
        .doc(user.uid)
        .collection('my_users')
        .doc(request.from)
        .set({}).then((value) async {
      await firestore
          .collection('Users')
          .doc(user.uid)
          .collection('friendRequests')
          .doc(requestQuery.docs.first.id)
          .delete();
    },);
  }


  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection(kUsersCollections).doc(user.uid).get().then((
        user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        //for setting user status to active
        APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }


  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection(kUsersCollections)
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    return firestore
        .collection(kUsersCollections)
        .where('id',
        whereIn: userIds.isEmpty
            ? ['']
            : userIds)
    //.where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(ChatUser chatUser, String msg,
      Type type) async {
    await firestore
        .collection(kUsersCollections)
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }


  // for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection(kUsersCollections).doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path
        .split('.')
        .last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection(kUsersCollections)
        .doc(user.uid)
        .update({'image': me.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection(kUsersCollections)
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection(kUsersCollections).doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** Story Related APIs **************
  // update profile picture of user
  static Stream<int> getStatusCount() {
    return firestore
        .collection('Status')
        .doc(me.email)
        .collection('image')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  static Timer deleteStatus(time, ext) {
    return Timer(const Duration(days: 1), () async {
      firestore
          .collection('Status/${me.email}/image/')
          .doc(time).delete();
      storage.ref().child(
          'Story_pictures/${me.email} ${DateTime
              .now()
              .millisecondsSinceEpoch}.$ext').delete();

      // Get friend request count
      final StatusCountStream = getStatusCount();
      final StatusCount = await StatusCountStream.first;

      firestore.collection('Users').doc(user.uid).update({
        'story': StatusCount,
      });
    },);
  }

  static Future<void> sendStoryImage(File file) async {
    //message sending time (also used as id)
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    //getting image file extension
    final ext = file.path
        .split('.')
        .last;

    //storage file ref with path
    final ref = storage.ref().child(
        'Story_pictures/${me.email} ${DateTime
            .now()
            .millisecondsSinceEpoch}.$ext');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    //message to send
    final Status status = Status(

        status: imageUrl,
        image: me.image,
        seen: [],
        fromname: me.name,
        type: Type_s.image,
        fromId: user.uid,
        sent: time);

    final sent = firestore
        .collection('Status/${me.email}/image/');
    await sent.doc(time).set(status.toJson());

    // Get friend request count
    final StatusCountStream = getStatusCount();
    final StatusCount = await StatusCountStream.first;

    firestore.collection('Users').doc(user.uid).update({
      'story': StatusCount,
    });

    deleteStatus(time, ext);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getStoryImage(
      ChatUser user) {
    return firestore
        .collection('Status/${user.email}/image/')
        .orderBy('sent', descending: true)
        .snapshots();
  }


  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) =>
      user.uid.hashCode <= id.hashCode
          ? '${user.uid}_$id'
          : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg,
      Type type) async {
    //message sending time (also used as id)
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(
            chatUser, type == Type.text ? msg : AppString.img));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(5)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path
        .split('.')
        .last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime
            .now()
            .millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
  //send to MultipleUsers image
  static Future<void> sendChatImageToMultipleUsers(List<ChatUser> users, File file) async {
    // Getting image file extension
    final ext = file.path.split('.').last;

    // Loop through each user in the selected users list
    for (ChatUser user in users) {
      // Storage file reference with path for each user
      final ref = storage.ref().child(
          'images/${getConversationID(user.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

      try {
        // Uploading image for each user
        await ref
            .putFile(file, SettableMetadata(contentType: 'image/$ext'))
            .then((p0) {
          log('Data Transferred to ${user.name}: ${p0.bytesTransferred / 1000} kb');
        });

        // Getting the image URL after uploading
        final imageUrl = await ref.getDownloadURL();

        // Sending message with the image URL to the user
        await sendMessage(user, imageUrl, Type.image);
      } catch (e) {
        log('Error sending image to ${user.name}: $e');
      }
    }
  }
  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //delete message
  static Future<void> deleteallMessage(Message message) async {
    // Get all documents in the 'messages' collection
    QuerySnapshot querySnapshot = await firestore.collection(
        'chats/${getConversationID(message.toId)}/messages/').get();

    // Iterate through all documents and delete them
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await firestore
          .collection('chats/${getConversationID(message.toId)}/messages/')
          .doc(doc.id)
          .delete();

      if (message.type == Type.image) {
        await storage.refFromURL(message.msg).delete();
      }
    }
  }
  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}

