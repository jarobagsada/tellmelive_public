class UserEvent {
  var id;
  String title;
  var is_subs;

  UserEvent({this.id, this.title, this.is_subs});

  factory UserEvent.fromJson(Map<String, dynamic> json) {
    return UserEvent(
      id: json["id"],
      is_subs: json["is_subs"],
      title: json["title"],
    );
  }
}
