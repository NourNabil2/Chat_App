
class ChatUser {
  ChatUser({
    required this.image,
    required this.status,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    required this.friendRequests,
  });
  late String image;
  late int status;
  late String about;
  late String name;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;
  late String pushToken;
  late String friendRequests;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    status = json['story'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
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
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['friendRequests'] = friendRequests;
    return data;
  }
}