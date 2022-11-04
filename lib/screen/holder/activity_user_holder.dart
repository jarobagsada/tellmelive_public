import 'package:miumiu/screen/holder/chat.dart';

class Activity_User_Holder {
  String event_id;
  String title;
  String image;
  String location;
  String start_time;
  String end_time;
  String interest;
  String interest_desp;
  String comment;
  String latitude;
  String longitude;
  int is_subs;
  List<Category> categroy_holder;

  Activity_User_Holder(
      {this.event_id,
      this.title,
      this.image,
      this.location,
      this.start_time,
      this.end_time,
      this.interest,
      this.interest_desp,
      this.comment,
      this.latitude,
      this.longitude,
        this.categroy_holder,
      this.is_subs});

  factory Activity_User_Holder.fromJson(Map<String, dynamic> json) {
    return Activity_User_Holder(
        event_id: json["event_id"],
        title: json["title"],
        image: json["image"],
        location: json["location"],
        start_time: json["start_time"],
        end_time: json["end_time"],
        interest: json["interest"],
        interest_desp: json["interest_desp"],
        comment: json["comment"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        is_subs: json["is_subs"],
        categroy_holder: json["category"].map<Category>((value) => new Category.fromJson(value)).toList()
      //  // itemlist.map<Chat>((i) => Chat.fromJson(i)).toList();
    );

  }
}
class Category {
  var id;
  String name;
  String image;
  int percent;

  Category({this.id, this.name, this.image, this.percent});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        percent: json["percent"]);
  }
}
