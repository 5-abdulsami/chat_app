class ChatUser {
  String? id;
  bool? isOnline;
  String? name;
  String? email;
  String? about;
  String? lastOnline;
  String? createdAt;
  String? image;
  String? pushToken;

  ChatUser(
      {this.id,
      this.isOnline,
      this.name,
      this.email,
      this.about,
      this.lastOnline,
      this.createdAt,
      this.image,
      this.pushToken});

  ChatUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isOnline = json['isOnline'];
    name = json['name'];
    email = json['email'];
    about = json['about'];
    lastOnline = json['lastOnline'];
    createdAt = json['createdAt'];
    image = json['image'];
    pushToken = json['pushToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
