class Activity_List {
  String id;
  String user_id;
  String title;
  String image;
  String location;
  String start_time;
  String end_time;
  String interest;
  String interest_desp;
  String status;
  String s_msg;
  String s_color;
  String comment;
  List<Category> categroy_holder;
  int members;

  Activity_List(
      {this.id,
      this.title,
      this.image,
      this.location,
      this.start_time,
      this.end_time,
      this.interest,
      this.interest_desp,
      this.comment,
      this.categroy_holder,
      this.status,
      this.s_msg,
      this.s_color,
      this.members});

  factory Activity_List.fromJson(Map<String, dynamic> json) {
    return Activity_List(
        id: json["id"],
        title: json["title"],
        image: json["image"],
        location: json["location"],
        start_time: json["start_time"],
        end_time: json["end_time"],
        interest: json["interest"],
        interest_desp: json["interest_desp"],
        members: json["suscribedcount"],
        status: json["status"],
        s_msg: json["s_msg"],
        s_color: json["s_color"],
        categroy_holder: json["category"]
            .map<Category>((value) => new Category.fromJson(value))
            .toList(),
        comment: json["comment"]);
  }
}

class Category {
  int id;
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
