class Status {
  Status({

    required this.status,
    required this.image,
    required this.seen,
    required this.type,
    required this.fromId,
    required this.fromname,
    required this.sent,
  });


  late final String status;
  late final List<dynamic> seen;
  late final String fromId;
  late final String image;
  late final String fromname;
  late final String sent;
  late final Type_s type;

  Status.fromJson(Map<String, dynamic> json) {

    status = json['status'].toString();
    image = json['image'].toString();
    seen = json['seen'].toList();
    type = json['type'].toString() == Type_s.image.name ? Type_s.image : Type_s.text;
    fromId = json['fromId'].toString();
    fromname = json['from_name'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['status'] = status;
    data['image'] = image;
    data['seen'] = seen;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['from_name'] = fromname;
    data['sent'] = sent;
    return data;
  }
}

enum Type_s { text, image, video }