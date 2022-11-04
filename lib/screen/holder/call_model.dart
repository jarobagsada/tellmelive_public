
import 'package:miumiu/screen/holder/userauth_model.dart';

class CallModel {
 String id;
  String token;
  String channelName;
  String callerId;
  String callerName;
  String callerAvatar;
  String receiverId;
  String receiverName;
  String receiverAvatar;
  String status;
  num createAt;
  bool current;
  UserAuthModel otherUser; //UI

  CallModel(
      {this.id,
      this.callerId,
      this.callerName,
      this.callerAvatar,
      this.receiverId,
      this.receiverName,
      this.receiverAvatar,
      this.status,
      this.createAt,this.current});

  CallModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    token = json['token'];
    channelName = json['channelName'];
    callerId = json['callerId'];
    callerName = json['callerName'];
    callerAvatar = json['callerAvatar'];
    receiverId = json['receiverId'];
    receiverName = json['receiverName'];
    receiverAvatar = json['receiverAvatar'];
    status = json['status'];
    createAt = json['createAt'];
    current = json['current'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'channelName': channelName,
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAvatar': receiverAvatar,
      'status': status,
      'createAt': createAt,
      'current': current
    };
  }
}
