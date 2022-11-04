class FcmPayloadModel{
   String to;
   Map<String, dynamic> data;

  FcmPayloadModel({ this.to,  this.data});

  FcmPayloadModel.fromJson(Map<String,dynamic> json)
  {
    to = json['to'];
    data = json['data'];
  }

  Map<String,dynamic> toMap()
  {
    return {
      'to':to,
      'data':data,
    };
  }
}