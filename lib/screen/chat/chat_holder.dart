import 'dart:convert';

class Chat_holder{
  String message_id;
  String user_id;
  String name;
  String sender_id;
  String receiver_id;
  String chat_user_id;
  String message;
  String datetime;
  String status;
  int location;
  var lat;
  var log;
  int type;
  String messagedatetime;

  Chat_holder({this.user_id,this.name,this.chat_user_id,this.message,this.sender_id,this.receiver_id,this.message_id,this.datetime,this.status,this.location,this.lat,this.log,this.type,this.messagedatetime});

  factory Chat_holder.fromJson(Map<String, dynamic> json)
  {
    return Chat_holder(
        message_id:json["message_id"],
        user_id: json["user_id"],
        name: json["name"],
        sender_id:json["sender_id"],
        receiver_id:json["receiver_id"],
        chat_user_id: json["chat_user_id"],
        message: json["message"],
        datetime:json["datetime"],
        status: json["status"],
        location:json["location"],
        lat:json["lat"],
        log:json["lan"],
        type:json["type"],
        messagedatetime:json["messagedatetime"]
    );
  }

  factory Chat_holder.fromString(dvalue)
  {
    Map<String, dynamic> json   = jsonDecode(dvalue);
    return Chat_holder(
        message_id:json["message_id"],
        user_id: json["user_id"],
        name: json["name"],
        sender_id:json["sender_id"],
        receiver_id:json["receiver_id"],
        chat_user_id: json["chat_user_id"],
        message: json["message"],
        datetime:json["datetime"],
        status: json["status"],
        location:json["location"],
        lat:json["lat"],
        log:json["lan"],
        type:json["type"],
        messagedatetime:json["messagedatetime"]
    );

  }


}