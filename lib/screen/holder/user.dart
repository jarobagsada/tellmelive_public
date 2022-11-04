import 'package:miumiu/screen/chat/chat_holder.dart';

class User {
  int category_id;
  var user_id;
  String name;
  String online;
  String message;
  int count;
  String profile_img;
  int type;
  int miu;
  int nomessage;
  String title;
  bool ischeck;
  int status;
  String gender;
  String app_id;
  String age;
  int blocked;
  int youblocked;
  bool active;
  List<dynamic> historyList;

  User(
      {this.user_id,
      this.category_id,
      this.name,
      this.online,
      this.message,
      this.count,
      this.profile_img,
      this.type,
        this.title,
        this.blocked,
        this.youblocked,
      this.ischeck,
        this.nomessage,
        this.status,
        this.gender,
        this.age,
        this.app_id,
        this.active,
      this.miu,
      this.historyList});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      user_id: json["user_id"],
      category_id: json["id"],
      name: json["name"],
      youblocked:json["youblocked"],
      blocked:json["blocked"],
      online: json["online"],
      app_id: json["app_id"],
      message: json["message"],
      count: json["count"],
      status: json["status"],
      nomessage: json["nomessage"],
      type: json["type"],
      title: json["title"],
      ischeck: json["ischeck"],
      miu: json["miu"],
      gender: json["gender"],
      age: json["age"],
      active: json["active"],
      profile_img: json["profile_img"],
      historyList : json["history"],
    );
  }

  get history => null;
}
