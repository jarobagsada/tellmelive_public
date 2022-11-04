class Chat {
  String name;
  String latitude;
  String profile_img;
  String profile_img_map;
  String longitude;
  String user_id;
  String city;
  String state;
  String online;
  String message;
  String gender;
  String prof_interest;
  int you_liked;
  int liked_you;
  int count;
  int gender_interest;
  List<Activity> activity_holder;
  int allownavigation;
  String distance_hide;
  String hide_age;

  String profile_imgmap;
  String dob;

  Chat(
      {this.name,
      this.latitude,
      this.longitude,
      this.profile_img,
      this.profile_img_map,
      this.user_id,
      this.city,
      this.state,
      this.message,
        this.liked_you,
      this.count,
      this.online,
        this.you_liked,
        this.prof_interest,
        this.gender,
        this.gender_interest,
      this.activity_holder,
      this.allownavigation,
      this.profile_imgmap,
      this.dob,this.hide_age,
        this.distance_hide});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
        name: json["name"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        profile_img: json["profile_img"],
        profile_img_map: json["profile_img_map"],
        user_id: json["user_id"],
        city: json["city"],
        liked_you: json["liked_you"],
        state: json["state"],
        gender: json["gender"],
        prof_interest: json["prof_interest"],
        online: json["online"],
        you_liked: json["you_liked"],
        count: json["count"],
        gender_interest: json["gender_interest"],
        message: json["message"],
        allownavigation : json["allownavigation"],
        profile_imgmap : json["profile_imgmap"],
        activity_holder: json["activity"]
            .map<Activity>((value) => new Activity.fromJson(value))
            .toList(),
      dob : json["dob"],
        hide_age:json["hide_age"],
      distance_hide: json['distance_hide']

      //  // itemlist.map<Chat>((i) => Chat.fromJson(i)).toList();
        );
  }
}

class Activity {
  String id;
  String name;
  String image;
  int percent;

  Activity({this.id, this.name, this.image, this.percent});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        percent: json["percent"]);
  }
}
