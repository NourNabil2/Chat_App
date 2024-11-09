class ChatUser {
  ChatUser({
    required this.image,
    required this.status,
    required this.status_p,
    required this.status_f,
    required this.about,
    required this.name,
    required this.userName,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    required this.friendRequests,
    this.unrepliedMessages = 0,
    this.unreadMessages = 0,
  });

  late String image;
  late int status;
  late int status_p;
  late int status_f;
  late String about;
  late String name;
  late String userName;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;
  late String pushToken;
  late String friendRequests;

  // Additional fields to track messages
  int unrepliedMessages; // Track the number of unreplied messages
  int unreadMessages;    // Track the number of unread messages

  // Computed properties
  bool get hasUnrepliedMessages => unrepliedMessages > 0;
  bool get hasUnreadMessages => unreadMessages > 0;

  ChatUser.fromJson(Map<String, dynamic> json)
      : unrepliedMessages = json['unreplied_messages'] ?? 0,
        unreadMessages = json['unread_messages'] ?? 0 {
    image = json['image'] ?? '';
    status = json['story'] != null ? int.tryParse(json['story'].toString()) ?? 0 : 0;
    status_p = json['story_p'] != null ? int.tryParse(json['story_p'].toString()) ?? 0 : 0;
    status_f = json['story_f'] != null ? int.tryParse(json['story_f'].toString()) ?? 0 : 0;
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    userName = json['userName'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] == 1 || json['is_online'] == true;
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
    friendRequests = json['friendRequests'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['story'] = status;
    data['story_p'] = status_p;
    data['story_f'] = status_f;
    data['about'] = about;
    data['name'] = name;
    data['userName'] = userName;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline ? 1 : 0;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['friendRequests'] = friendRequests;
    data['unreplied_messages'] = unrepliedMessages;
    data['unread_messages'] = unreadMessages;
    return data;
  }
}
