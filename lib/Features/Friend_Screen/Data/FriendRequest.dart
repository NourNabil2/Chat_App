

import 'package:cloud_firestore/cloud_firestore.dart';

class Friendrequest {
  late  String id;
  late String from;
  late String name;
  late String about;
  late String image;

  Friendrequest({
    required this.id,
    required this.from,
    required this.name,
    required this.about,
    required this.image,

  });

  Friendrequest.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    from = json['from'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    image = json['Image'] ?? '';


  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['from'] = from;
    data['name'] = name;
    data['about'] = about;
    data['image'] = image;

    return data;
  }

}
