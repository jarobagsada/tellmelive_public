
class UserAuthModel{
   String id;
   String  regId;
   String name;
   String mobile;
   String email;
   String gender;
   String dateofbirth;
   String avatar;
   bool busy=false;
   bool anothercall=false;
   int online=0;
   int flag=0;
   var datetime;





   UserAuthModel({this.name,this.avatar});

  UserAuthModel.resister({this.id,this.regId,this.name,this.mobile,this.email, this.gender,
  this.dateofbirth,this.avatar,
    this.busy,this.anothercall,this.online,this.flag,this.datetime});

  UserAuthModel.fromJsonMap({Map<String, dynamic> map,String uId}){
    id = uId;
    regId=map['regId'];
    name = map["name"];
    mobile = map["mobile"];
    email = map["email"];
    avatar = map["avatar"];
    gender=map["gender"];
    dateofbirth=map["dateofbirth"];
    anothercall = map["anothercall"];
    online = map["online"];
    flag = map["flag"];
    datetime = map["datetime"];

  }

  Map<String,dynamic> toMap(){
    return {
      "uId": id,
      "regId":regId,
      "name": name,
      "mobile": mobile,
      "email": email,
      "avatar": avatar,
      "gender":gender,
       "dateofbirth":dateofbirth,
      "anothercall": anothercall,
      "online": online,
      "flag": flag,
      "datetime": datetime

    };
  }
}

class UserFcmTokenModel{
   String uId, token;

  UserFcmTokenModel({ this.uId, this.token});

  UserFcmTokenModel.fromJson(Map<String, dynamic> json) {
    uId = json['uId'];
    token = json['token'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'token': token,
    };
  }
}