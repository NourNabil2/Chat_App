import 'package:bloc/bloc.dart';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Features/Chat_Screen/Data/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());
  bool showEmoji = false;
  List<Message> messagesList = [];
  CollectionReference messages =
      APIs.firestore.collection(kMessagesCollections);

  void show_Emoji()
  {
    showEmoji = !showEmoji;
  }

  void sendmessage({
    required String message,
  }) {
    try {
      messages.add({kMessage: message, kCreatedAt: DateTime.now()});
    } on Exception catch (e) {}
  }
}
