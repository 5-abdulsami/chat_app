class ChatUser {
  late String id;
  late bool isOnline;
  late String name;
  late String email;
  late String about;
  late String lastOnline;
  late String createdAt;
  late String image;
  late String pushToken;

  ChatUser(
      {required this.id,
      required this.isOnline,
      required this.name,
      required this.email,
      required this.about,
      required this.lastOnline,
      required this.createdAt,
      required this.image,
      required this.pushToken});

  ChatUser.fromJson(
    Map<String, dynamic> json,
  ) {
    id = json['id'] ?? '';
    isOnline = json['isOnline'];
    name = json['name'] ?? '';
    email = json['email'] ?? '';
    about = json['about'] ?? '';
    lastOnline = json['lastOnline'] ?? '';
    createdAt = json['createdAt'] ?? '';
    image = json['image'] ?? '';
    pushToken = json['pushToken'] ?? '';
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isOnline'] = isOnline;
    data['name'] = name;
    data['email'] = email;
    data['about'] = about;
    data['lastOnline'] = lastOnline;
    data['createdAt'] = createdAt;
    data['image'] = image;
    data['pushToken'] = pushToken;
    return data;
  }
}
