class Activity_holder{
  String id;
  String name;
  String image;
  int percent;

  Activity_holder({this.id,this.name,this.image,this.percent});

  factory Activity_holder.fromJson(Map<String, dynamic> json)
  {
    return Activity_holder(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      percent: json["percent"]
    );
  }
}