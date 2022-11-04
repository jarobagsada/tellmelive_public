import 'dart:async';
import 'dart:convert';


import 'package:any_link_preview/any_link_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/chat/chat_holder.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/fluttertoast_alert.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/showtoast_widgets.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../../utilmethod/constats.dart';
import '../../utilmethod/helper.dart';
import '../call_sio_agora/agoravideocall.dart';
import '../call_sio_agora/utils/common_methods.dart';
import '../call_sio_agora/utils/constants/api_constants.dart';
import '../call_sio_agora/utils/navigation.dart';
import '../callview/home/home_cubit.dart';
import '../holder/call_model.dart';
import '../holder/userauth_model.dart';



class Chat_Screen extends StatefulWidget {
  @override
  _Chat_ScreenState createState() => _Chat_ScreenState();
}

class _Chat_ScreenState extends State<Chat_Screen> {
  final _codeController = TextEditingController();

  TextEditingController textController;
  Size _screenSize;
  List<Chat_holder> messages = [];
  Map<String, dynamic> routeData;
  bool check_send;
  ScrollController listScrollController = new ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool notice_text;
  bool firsttime;
  bool miufirst_time;
  var customFormat = DateFormat('dd-MM-yyyy');
  Location _locationService = new Location();
  LocationData _currentLocation;
  String Prevoius_date = "";
  bool datefirstTime = false;
  bool isMatching = true;
  bool is_15min;
  bool is_1hour;
  ProgressDialog progressDialog;
 var MQ_Width;
  var MQ_Height;
  //========================== user Detail ====
  String User_Photo;
  String User_name;
  String User_id;
  String User_email;
  String User_mobile;
  String User_gender;
  String User_dateofbirth;

  List<UserAuthModel> listAuthusers = [];
  var receiver_Id;
  final _homeCubit = HomeCubit();


  @override
  void initState() {
    notice_text = false;
    firsttime = true;
    miufirst_time = true;
    textController = TextEditingController();
    messages = List<Chat_holder>();
    check_send = false;
    createSocket();
    getUserDetails();

    getUser();

    super.initState();
  }

  List<dynamic> historyList = [];

  Future<void> getUserDetails()async{
    setState(() {
      User_Photo = SessionManager.getString(Constant.Profile_img);
      User_id= SessionManager.getString(Constant.LogingId);
      print('getUserDetails User_id=$User_id');

      User_name=SessionManager.getString(Constant.Name);
       User_email=SessionManager.getString(Constant.Email);
       User_mobile=SessionManager.getString(Constant.Mobile_no);
      User_gender="male";//SessionManager.getString(Constant.GenderRoute);
      User_dateofbirth=SessionManager.getString(Constant.Dob);
    });

  }
  @override
  Widget build(BuildContext context) {
    routeData           = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    _screenSize         = MediaQuery.of(context).size;
     MQ_Width=MediaQuery.of(context).size.width;
     MQ_Height=MediaQuery.of(context).size.height;
    historyList = routeData['history'];

      onReceivedMessage(historyList, 2);
      routeData['history'] = [];




    return SafeArea(
        child: WillPopScope(
      onWillPop: () async{
        Navigator.pop(context, 1);
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _getAppbar,
        body: Container(
          child: Column(
            children: <Widget>[
              buildMessageList(),
              (routeData["blocked"] == 1 || routeData["youblocked"] == 1)
                  ? Container()
                  : buildInputArea()
            ],
          ),
        ),
      ),
    ));
  }

  createSocket() {
    if (messages != null && messages.isNotEmpty) {
      messages.clear();
    }

    
    Constant.socket = IO.io(WebServices.CHAT_SERVER, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true
    });

    Constant.socket.connect();


    pprintstatment(Constant.socket, "connect");
    pprintstatment(Constant.socket, "connect_error");
    pprintstatment(Constant.socket, "connect_timeout");
    pprintstatment(Constant.socket, "connecting");
    pprintstatment(Constant.socket, "disconnect");
    pprintstatment(Constant.socket, "error");
    pprintstatment(Constant.socket, "reconnect");

    Constant.socket.on('connect', (_) {
      Constant.socket.emit("new_user", {
        "chat_user_id": routeData["chat_user_id"],
        "user_id": routeData["user_id"],
        "name": routeData["name"]
      });

      if (firsttime) {
        routeData["realtime"] =
            DateTime.now().millisecondsSinceEpoch.toString();
        Constant.socket.emit("loadpremessage", routeData);
        firsttime = false;
      }
    });
    Constant.socket.on('message', (data) {
        print("--111-----" + data.toString());
        onReceivedMessage(data, 1);
    });


    Constant.socket.on('loadpreviousmessage', (data) {
        print("--22222-----" + data.toString());         
        onReceivedMessage(data, 2);
          
    });

    Constant.socket.on('mark_as_read', (data) => print("--mark---" + data));
    //  socket.on('message', (_) => print(_));
  }

  onSendMessage(String data, int type, {int location, double lat, double log}) {
    if (routeData["miu"] == "1") {
      if (miufirst_time) {
        Constant.socket.emit("miu", {
          "chat_user_id": routeData["chat_user_id"],
          "user_id": routeData["user_id"],
          "name": routeData["name"]
        });
        routeData["miu"] = "0";
        miufirst_time = false;
      }
    }
    routeData["timestamp"] = DateTime.now().millisecondsSinceEpoch.toString();
    // routeData["timestamp"] = DateTime.now().subtract(Duration(days: 2)).millisecondsSinceEpoch.toString();
    check_send = true;
    routeData["message"] = data;
    routeData["location"] = location ?? 0;
    routeData["lat"] = lat ?? 0;
    routeData["lan"] = log ?? 0;
    routeData["type"] = type;
    routeData["pretimestamp"] = Constant.datetime;

    print("------send data----------------" + routeData.toString());

    Constant.socket.emit('message', routeData);
    //messages.add(data);
  }

  onReceivedMessage(data, int check) {
    print("-------------on recevive medaa------@@@@@@@@@@@@@@---");
    print(" onReceivedMessage data=${data}");

    List<Chat_holder> list;
    try {
      list = data.map<Chat_holder>((i) =>
          Chat_holder.fromJson(i)).toSet().toList();
      print('onReceivedMessage ##list=$list\n data=${data}');
    }catch(error){
      print('onReceivedMessage ##catch error=$error');
    }
   

      
    if (routeData["miu"] != null && routeData["miu"] == "1") {
      if (list != null && list.isNotEmpty) {
        if (list[0].message == Constant.Miu) {
          notice_text = true;
        } else {
          notice_text = false;
        }
      }
    }

    print(list);
   try {
     if(list.length!=0) {

       /*if(messages.length!=0) {
          messages.retainWhere((x) {
            if(messages.contains(x.message_id)) {
              messages.remove(x.message_id);
            }

          });
        // messages.removeWhere((element) => element.message_id == element.message_id.codeUnitAt(1));
         //messages.sort((a, b) => a.message_id.compareTo(b.message_id));
       }*/
      // messages.addAll(list);
       messages.addAll(
         list..removeWhere((e) {
             bool flag = false;
             messages.forEach((x) {
               if (x.message_id.contains(e.message_id)) {
                 flag = true;
               }
             });

             return flag;
           }),
       );

     //  messages = messages.toSet().toList();


     }
   }catch(error){
     print('messages.addAll catch error=$error');
   }
    
    // messages = messages.reversed.toList();
    if (check == 1) {
      for (var items in messages) {
        //  print("------messa---" + items.message_id.toString() + "------chat-----" + data[0]["message_id"].toString());
        if (items.message_id != data[0]["message_id"]) {
          if (items.type == 3 || items.type == 4) {
            //    print("-----------index-----" + items.message_id.toString());
            items.type = 5;
          }
        }
      }
    }

    List.generate(messages.length, (index) {
      // print("-----message-----" + index.toString() + "---" + messages[index].type.toString());
    });

    // var contain =
    //     messages.where((element) => element.type == 3 || element == 4);
    // if (contain.isEmpty) {
    //   //value not exists
    //   print(
    //       "-----------aary me 3 or 4 nahi mila-------1111111111--location cancel---hogaya------");
    //   if (Constant.locationSubscription != null) {
    //     Constant.locationSubscription.cancel();
    //   }
    // } else {
    //   //value exists
    //   print(
    //       "-----------aary me 3 or 4  mila---gare baba----2222222222-----------");
    // }

    setState(() {
      try {
        Timer(
          Duration(milliseconds: 800),
              () =>
              listScrollController.jumpTo(listScrollController.position.maxScrollExtent),
        );
      }catch(error){
        print('catch listScrollController position error=$error');
      }

      // messages.addAll(list);
      //messages = messages.reversed.toList();

      //   messages.add(dataitam);
    });

    if (check_send) {
      for (var checkmessage in list) {
        if (checkmessage.sender_id !=SessionManager.getString(Constant.LogingId) && checkmessage.status == "1") {

          Constant.socket.emit("mark_as_read", checkmessage.sender_id);
        }
      }
    }
  }

  pprintstatment(IO.Socket socket, String messahe) {
    print('pprintstatment socket=${socket}\nmessahe=$messahe');
    socket.on(messahe,
        (data) => print("--error-----" + messahe + "----" + data.toString()));
  }

  Widget buildMessageList() {
    print("-------chatlist-time-- messages.length==${messages.length}" );

    return Expanded(
      child: messages.length!=0?Container(
        width: _screenSize.width,
        child: ListView.builder(
          controller: listScrollController,
          itemCount: messages == null ? 0 : messages.length,
          //  reverse: true,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
//              print("-----message builder---" + messages[index].toString());
            Chat_holder chat_list = messages[index];
            print("-------chatlist-time--------" + chat_list.datetime.toString());
            print("------datetime previous------" + Constant.datetime.toString());
            Constant.datetime = chat_list.messagedatetime.toString();
            print("------datetime previous-update-----" +
                Constant.datetime.toString());
            var date;

            if (chat_list.datetime != null && chat_list.datetime.isNotEmpty) {
              date = (chat_list.datetime != "") ? DateTime.fromMillisecondsSinceEpoch(int.parse(chat_list.datetime)) : null;
            }
            //   final DateFormat formatter = DateFormat('yyyy-MM-dd');
            //    var formattedDate = formatter.format(date); // Apr 8, 2020
            //    var formattedDate1 = DateFormat.jm().format(date); // Apr 8, 2020

//            print("----formatedate------"+formattedDate.toString());
//            print("---------date-----" + date.toString());
//            print("----formatedate2------"+formattedDate.toString());
//            print("----Date------"+DateFormat.M().format(date).toString());
//            print("----Date------"+DateFormat.Md().format(date).toString());
//            print("----Date------"+DateFormat.MEd().format(date).toString());
//            print("----Date------"+DateFormat.MMM().format(date).toString());
//            print("----Date------"+DateFormat.MMMd().format(date).toString());
//            print("----Date------"+DateFormat.MMMEd().format(date).toString());
//            print("----Date------"+DateFormat.MMMM().format(date).toString());
//            print("----Date------"+DateFormat.MMMMd().format(date).toString());
//            print("----Date------"+DateFormat.MMMMEEEEd().format(date).toString());
//            print("----Date------"+DateFormat.QQQ().format(date).toString());
//            print("----Date------"+DateFormat.QQQQ().format(date).toString());
//            print("----Date------"+DateFormat.y().format(date).toString());
//            print("----Date------"+DateFormat.yM().format(date).toString());
//            print("----Date------"+DateFormat.yMd().format(date).toString());
//            print("----Date------"+DateFormat.yMEd().format(date).toString());
//            print("----Date------"+DateFormat.yMMM().format(date).toString());
//            print("----Date------"+DateFormat.yMMMd().format(date).toString());
//            print("----Date------"+DateFormat.yMMMEd().format(date).toString());
//            print("----Date------"+DateFormat.yMMMM().format(date).toString());
//            print("----Date------"+DateFormat.yMMMMd().format(date).toString());
//            print("----Date------"+DateFormat.yMMMMEEEEd().format(date).toString());
//            print("----Date------"+DateFormat.yQQQ().format(date).toString());
//            print("----Date------"+DateFormat.yQQQQ().format(date).toString());
//
//
//
//
//            print(formatter.format(date)); // print short date
//            print(customFormat.format(date));

            return buildSingleMessage(chat_list, index, date);
          },
        ),
      ):Container(),
    );
  }

  Widget buildSingleMessage(Chat_holder chat, int index, var date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    print("------buildSingleMessage-- messages.length==${messages.length}" );
    // if(index>0)
    //   {
    //     Prevoius_date = formatter.format(date).toString();
    //   }
    //  print("-----dtadtat#####@@@@####-----" + formatter.format(date).toString());

    // checkdateString(formatter.format(date).toString());
    // print("------yester-------" + checkdateString(formatter.format(date)).toString());
    // print("-------previous date------" + Prevoius_date.toString());
    // print("-----isvisiblemacthed----" + isMatching.toString());
    var I_mgs;
    if(index!=0&&index!=messages.length){
      I_mgs=messages[index-1].message_id;
    }
    if(index==messages.length){
      I_mgs=messages[index-1].message_id;
    }
    print('I_mgs=$I_mgs');
    return  //I_mgs!=messages[index].message_id
        Padding(
      padding: EdgeInsets.only(
          top: index == 0 ? 15 : 0,
          bottom: index == (messages.length - 1) ? 15 : 0),
      child: Column(
        children: <Widget>[
          date != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomWigdet.TextView(
                      overflow: true,
                      text: formatter.format(date).toString(),
                      color: Custom_color.GreyLightColor,
                      fontSize: 12),
                )
              : Container(),
              chat.sender_id == routeData["user_id"]
              ? Container(
                  alignment: Alignment.centerRight,
                  child: chat.location == 0
                      ? Container(
                          padding: const EdgeInsets.all(10.0),
                          margin: const EdgeInsets.only(
                              top: 1, bottom: 1, right: 20.0, left: 70),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Custom_color.BlueLightColor,
                                  Custom_color.BlueSecondLightColor
                                ]),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: CustomWigdet.TextView(
                              overflow: true,
                              text: chat.message.toString(),
                              color: Custom_color.WhiteColor,
                              fontSize: 16),
                        )
                      : Container(
                          width: 220,
                          height: 150,
                          margin: const EdgeInsets.only(right: 20.0, left: 70),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0)),
                            child: Column(
                              children: [
                                Expanded(
                                  child: false?FlutterLinkPreview(
                                    url:"https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}",
                                    bodyStyle: TextStyle(
                                      fontSize: 18.0,
                                    ),
                                    titleStyle: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    showMultimedia: true,
                                    builder: (info) {
                                      if (info is WebInfo) {
                                        Constant.message_id = chat.message_id;
                                        Constant.user_id = chat.user_id;
                                        Constant.sender_id = chat.sender_id;
                                        Constant.receiver_id = chat.receiver_id;
                                        Constant.chat_user_id =
                                            chat.chat_user_id;
                                        Constant.message = chat.message;
                                        Constant.status = chat.status;
                                        Constant.messagedatetime =
                                            chat.messagedatetime;
                                        Constant.location = chat.location;
                                        Constant.type = chat.type;
                                        _updateGPSLocation(chat);

                                        return InkWell(
                                            onTap: () async {
                                              Constant.message_id =
                                                  chat.message_id;
                                              Constant.user_id = chat.user_id;
                                              Constant.sender_id =
                                                  chat.sender_id;
                                              Constant.receiver_id =
                                                  chat.receiver_id;
                                              Constant.chat_user_id =
                                                  chat.chat_user_id;
                                              Constant.message = chat.message;
                                              Constant.status = chat.status;
                                              Constant.messagedatetime =
                                                  chat.messagedatetime;
                                              Constant.location = chat.location;
                                              Constant.type = chat.type;

                                              Navigator.pushNamed(context,
                                                  Constant.ChatMapScreen,
                                                  arguments: {
                                                    "message_id":
                                                        chat.message_id,
                                                    "user_id": chat.user_id,
                                                    "sender_id": chat.sender_id,
                                                    "receiver_id":
                                                        chat.receiver_id,
                                                    "chat_user_id":
                                                        chat.chat_user_id,
                                                    "message": chat.message,
                                                    "status": chat.status,
                                                    "datetime": chat.datetime,
                                                    "location": chat.location,
                                                    "name": routeData["name"],
                                                    "lat": chat.lat.toString(),
                                                    "log": chat.log.toString(),
                                                    "type": chat.type,
                                                    "images": routeData["image"]
                                                  });
                                            },
                                            child: (info.image != null)
                                                ? Container(
                                                    padding: EdgeInsets.only(
                                                        top: 5,
                                                        left: 5,
                                                        right: 5),
                                                    child: Image.network(
                                                      info.image,
                                                      width: _screenSize.width,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Container());
                                      }

                                      return Container(
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ):
                                 /* AnyLinkPreview(
                                    link: "https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}",
                                    displayDirection: UIDirection.uiDirectionHorizontal,
                                    showMultimedia: false,
                                    bodyMaxLines: 5,
                                    bodyTextOverflow: TextOverflow.ellipsis,
                                    titleStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    bodyStyle: TextStyle(color: Colors.grey, fontSize: 12),
                                    errorBody: 'Show my custom error body',
                                    errorTitle: 'Show my custom error title',
                                    errorWidget: Container(
                                      color: Colors.grey[300],
                                      child: Text('Oops!'),
                                    ),
                                    errorImage: "https://google.com/",
                                    cache: Duration(days: 7),
                                    backgroundColor: Colors.grey[300],
                                    borderRadius: 12,
                                    removeElevation: false,
                                    boxShadow: [BoxShadow(blurRadius: 3, color: Colors.grey)],
                                    onTap: ()async{
                                      Constant.message_id =
                                          chat.message_id;
                                      Constant.user_id = chat.user_id;
                                      Constant.sender_id =
                                          chat.sender_id;
                                      Constant.receiver_id =
                                          chat.receiver_id;
                                      Constant.chat_user_id =
                                          chat.chat_user_id;
                                      Constant.message = chat.message;
                                      Constant.status = chat.status;
                                      Constant.messagedatetime =
                                          chat.messagedatetime;
                                      Constant.location = chat.location;
                                      Constant.type = chat.type;

                                      Navigator.pushNamed(context,
                                          Constant.ChatMapScreen,
                                          arguments: {
                                            "message_id":
                                            chat.message_id,
                                            "user_id": chat.user_id,
                                            "sender_id": chat.sender_id,
                                            "receiver_id":
                                            chat.receiver_id,
                                            "chat_user_id":
                                            chat.chat_user_id,
                                            "message": chat.message,
                                            "status": chat.status,
                                            "datetime": chat.datetime,
                                            "location": chat.location,
                                            "name": routeData["name"],
                                            "lat": chat.lat.toString(),
                                            "log": chat.log.toString(),
                                            "type": chat.type,
                                            "images": routeData["image"]
                                          });
                                    }, // This disables tap event
                                  )*/
                                  Card(
                                   // elevation: 5,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        //side: BorderSide(width: 1,color: Colors.white),
                                    borderRadius: BorderRadius.circular(30)),
                                    child: AnyLinkPreview.builder(
                                      link: "https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}",
                                      itemBuilder: (context, metadata, imageProvider) {
                                       return imageProvider!=null ?InkWell(
                                         child: Container(
                                            // margin: EdgeInsets.only(top: 2,bottom: 2),
                                            constraints: BoxConstraints(
                                              maxHeight: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width * 0.30,
                                            ),
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                         onTap: ()async{
                                           Constant.message_id =
                                               chat.message_id;
                                           Constant.user_id = chat.user_id;
                                           Constant.sender_id =
                                               chat.sender_id;
                                           Constant.receiver_id =
                                               chat.receiver_id;
                                           Constant.chat_user_id =
                                               chat.chat_user_id;
                                           Constant.message = chat.message;
                                           Constant.status = chat.status;
                                           Constant.messagedatetime =
                                               chat.messagedatetime;
                                           Constant.location = chat.location;
                                           Constant.type = chat.type;

                                           Navigator.pushNamed(context,
                                               Constant.ChatMapScreen,
                                               arguments: {
                                                 "message_id":
                                                 chat.message_id,
                                                 "user_id": chat.user_id,
                                                 "sender_id": chat.sender_id,
                                                 "receiver_id":
                                                 chat.receiver_id,
                                                 "chat_user_id":
                                                 chat.chat_user_id,
                                                 "message": chat.message,
                                                 "status": chat.status,
                                                 "datetime": chat.datetime,
                                                 "location": chat.location,
                                                 "name": routeData["name"],
                                                 "lat": chat.lat.toString(),
                                                 "log": chat.log.toString(),
                                                 "type": chat.type,
                                                 "images": routeData["image"]
                                               });
                                         },
                                       ):Container(
                                        child: Center(
                                        child: CircularProgressIndicator(),
                                        ),
                                        );

                                      }
                                    ),
                                  ),

                                ),
                                InkWell(
                                  onTap: () {
                                    if (chat.type != 5) {
                                      _asyncConfirmDialog(context, chat);
                                    }
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: chat.type == 3 || chat.type == 4
                                          ? Container(
                                              child: CustomWigdet.TextView(
                                                  text: AppLocalizations.of(
                                                          context)
                                                      .translate(
                                                          "Stop sharing"),
                                                  color: Custom_color
                                                      .OrangeLightColor,
                                                  fontFamily: "OpenSans Bold",
                                                  textAlign: TextAlign.center),
                                            )
                                          : Container(
                                              child: CustomWigdet.TextView(
                                                  text: AppLocalizations.of(
                                                          context)
                                                      .translate(
                                                          "Live location ended"),
                                                  color: Custom_color
                                                      .BlackTextColor,
                                                  fontFamily: "OpenSans Bold",
                                                  textAlign: TextAlign.center),
                                            )),
                                )
                              ],
                            ),
                          ),
                        ))
              : Container(
                  alignment: Alignment.centerLeft,
                  child: chat.location == 0
                      ? Container(
                          padding: const EdgeInsets.all(10.0),
                          margin: const EdgeInsets.only(
                              top: 1, bottom: 1, left: 20.0, right: 70),
                          decoration: BoxDecoration(
                            color: Custom_color.ColorDivider.withOpacity(0.2),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10),
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: CustomWigdet.TextView(
                              overflow: true,
                              text: chat.message.toString(),
                              color: Custom_color.BlackTextColor,
                              fontSize: 16),
                        )
                      : Container(
                          width: 220,
                          height: 150,
                          margin: const EdgeInsets.only(left: 20.0, right: 70),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0)),
                            child: Column(
                              children: [
                                Expanded(
                                  child: false?FlutterLinkPreview(
                                    url:
                                        "https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}",
                                    bodyStyle: TextStyle(
                                      fontSize: 18.0,
                                    ),
                                    titleStyle: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    showMultimedia: true,
                                    builder: (info) {
                                      if (info is WebInfo) {
                                        return InkWell(
                                            onTap: () async {
                                              //  _updateGPSLocation();

                                              Navigator.pushNamed(context,
                                                  Constant.ChatMapScreen,
                                                  arguments: {
                                                    "message_id":
                                                        chat.message_id,
                                                    "user_id": chat.user_id,
                                                    "sender_id": chat.sender_id,
                                                    "receiver_id":
                                                        chat.receiver_id,
                                                    "chat_user_id":
                                                        chat.chat_user_id,
                                                    "message": chat.message,
                                                    "status": chat.status,
                                                    "datetime": chat.datetime,
                                                    "location": chat.location,
                                                    "name": routeData["name"],
                                                    "lat": chat.lat.toString(),
                                                    "log": chat.log.toString(),
                                                    "type": chat.type,
                                                    "images": routeData["image"]
                                                  });

                                              /*
                                            //    String origin =
                                            //       "${_currentLocation.latitude},${_currentLocation.longitude}"; // lat,long like 123.34,68.56
                                            //  String destination = routeData["point_b"];

                                            if (Platform.isAndroid) {
                                              // final AndroidIntent intent = new AndroidIntent(
                                              //     action: 'action_view',
                                              //     data: Uri.encodeFull(
                                              //         "https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}"),
                                              //     package:
                                              //         'com.google.android.apps.maps');
                                              AndroidIntent intent = AndroidIntent(
                                                  action: 'action_view',
                                                  data:
                                                  "https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}",
                                                  package:
                                                  'com.google.android.apps.maps');
                                              await intent.launch();
                                            } else {
                                              String url =
                                                  "https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}";
                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              } else {
                                                throw 'Could not launch $url';
                                              }
                                            }

                                             */
                                            },
                                            child: (info.image != null)
                                                ? Container(
                                                    padding: EdgeInsets.only(
                                                        top: 5,
                                                        left: 5,
                                                        right: 5),
                                                    child: Image.network(
                                                      info.image,
                                                      width: _screenSize.width,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Container());
                                      }
                                      return Container(
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ): Card(
                                    // elevation: 5,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      //side: BorderSide(width: 1,color: Colors.white),
                                        borderRadius: BorderRadius.circular(30)),
                                    child: AnyLinkPreview.builder(
                                        link: "https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}",
                                        itemBuilder: (context, metadata, imageProvider) {
                                          return imageProvider!=null ?InkWell(
                                            child: Container(
                                              // margin: EdgeInsets.only(top: 2,bottom: 2),
                                              constraints: BoxConstraints(
                                                maxHeight: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.30,
                                              ),
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            onTap: ()async{
                                              //  _updateGPSLocation();

                                              Navigator.pushNamed(context,
                                                  Constant.ChatMapScreen,
                                                  arguments: {
                                                    "message_id":
                                                    chat.message_id,
                                                    "user_id": chat.user_id,
                                                    "sender_id": chat.sender_id,
                                                    "receiver_id":
                                                    chat.receiver_id,
                                                    "chat_user_id":
                                                    chat.chat_user_id,
                                                    "message": chat.message,
                                                    "status": chat.status,
                                                    "datetime": chat.datetime,
                                                    "location": chat.location,
                                                    "name": routeData["name"],
                                                    "lat": chat.lat.toString(),
                                                    "log": chat.log.toString(),
                                                    "type": chat.type,
                                                    "images": routeData["image"]
                                                  });

                                              /*
                                            //    String origin =
                                            //       "${_currentLocation.latitude},${_currentLocation.longitude}"; // lat,long like 123.34,68.56
                                            //  String destination = routeData["point_b"];

                                            if (Platform.isAndroid) {
                                              // final AndroidIntent intent = new AndroidIntent(
                                              //     action: 'action_view',
                                              //     data: Uri.encodeFull(
                                              //         "https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}"),
                                              //     package:
                                              //         'com.google.android.apps.maps');
                                              AndroidIntent intent = AndroidIntent(
                                                  action: 'action_view',
                                                  data:
                                                  "https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}",
                                                  package:
                                                  'com.google.android.apps.maps');
                                              await intent.launch();
                                            } else {
                                              String url =
                                                  "https://www.google.com/maps/search/?api=1&query=${chat.lat.toString()},${chat.log.toString()}";
                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              } else {
                                                throw 'Could not launch $url';
                                              }
                                            }

                                             */
                                            },
                                          ):Container(
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );

                                        }
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: chat.type == 3 || chat.type == 4
                                      ? Container(
                                          child: CustomWigdet.TextView(
                                              text: AppLocalizations.of(context)
                                                  .translate(
                                                      "View live location"),
                                              color:
                                                  Custom_color.BlueLightColor,
                                              fontFamily: "OpenSans Bold",
                                              textAlign: TextAlign.center),
                                        )
                                      : Container(
                                          child: CustomWigdet.TextView(
                                              text: AppLocalizations.of(context)
                                                  .translate(
                                                      "Live location ended"),
                                              color:
                                                  Custom_color.BlackTextColor,
                                              fontFamily: "OpenSans Bold",
                                              textAlign: TextAlign.center),
                                        ),
                                )
                              ],
                            ),
                          ),
                        ))
        ],
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      margin: EdgeInsets.only(bottom: 10, right: 20,left: 20),
      width: _screenSize.width,
      child: Column(
        children: <Widget>[
          notice_text
              ? Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: CustomWigdet.TextView(
                      text: AppLocalizations.of(context)
                          .translate("Please reply message")
                          .toUpperCase(),
                      color: Custom_color.BlackTextColor))
              : Container(),
          (routeData["active"])
              ? Row(
                  children: <Widget>[
                    buildChatInput(),
                    SizedBox(width: 10,),
                    buildSendButton(),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Widget buildSendButton() {
    return Container(
      width: 50,
      height: 50,
      child: FloatingActionButton(
        backgroundColor: Custom_color.BlueLightColor,
        onPressed: () async {
          if (await UtilMethod.SimpleCheckInternetConnection(
              context, _scaffoldKey)) {
            //Check if the textfield has text or not
            if (textController.text.isNotEmpty) {
              //Send the message as JSON data to send_message event
              //  socketIO.sendMessage('send_message', json.encode({'message': textController.text}));
              //Add the message to the list
              onSendMessage(textController.text, 1);
              //   this.setState(() => messages.add(textController.text));
              textController.text = '';
              //Scrolldown the list to show the latest message
//          scrollController.animateTo(
//            scrollController.position.maxScrollExtent,
//            duration: Duration(milliseconds: 600),
//            curve: Curves.ease,
//          );
            }
          }
        },
        child: Icon(
          Icons.send,
          size: 28,
        ),
      ),
    );
  }

  Widget buildChatInput() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Custom_color.GreyLightColor,
              width: 1,
            )),
        padding: const EdgeInsets.all(14),
       // margin: const EdgeInsets.only(left: 20.0, right: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration.collapsed(
                  hintText:
                      AppLocalizations.of(context).translate("Send a message"),
                ),
                controller: textController,
                keyboardType: TextInputType.multiline,
                maxLines: null
              ),
            ),
            InkWell(
                onTap: () {
                  _showModalBottomSheet(context);
                },
                child: false?Icon(
                  Icons.share,
                  size: 24,
                  color: Custom_color.BlackTextColor,
                ):Image.asset('assest/images_svg/share_location.png')
            )
          ],
        ),
      ),
    );
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      title: CustomWigdet.TextView(
          text: routeData["name"].toString(),
          color: Custom_color.BlackTextColor,
          fontFamily: "OpenSans Bold"),
      actions: <Widget>[
        InkWell(
          onTap: () {
            if (routeData["active"]) {
              Navigator.pushNamed(context, Constant.ChatUserDetail, arguments: {
                "user_id": routeData["chat_user_id"],
                "type": "3"
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8, right: 5),
            child: CircleAvatar(
              backgroundColor: Custom_color.PlacholderColor,
              radius: 20,
              backgroundImage: NetworkImage(routeData["image"],scale: 1.0),
            ),
          ),
        ),

        false?InkWell(
          child: Container(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8, left: 5),
            child: Icon(Icons.video_call,color: Colors.green,size: 28,),
          ),
          onTap: (){
            //registerUser('${User_mobile}',context);
            registerWithEmail('${User_email}','Narendra@#1111','Narendra');
            // Navigator.pushNamed(context, Constant.CallScreen, arguments: {
            //   "user_id": routeData["chat_user_id"],
            //   "type": "3"
            // });
            //Navigator.pop(context,MaterialPageRoute(builder: (context)=>AgoraVideoCall()));
            /*ApiConstants.chatUserId=int.parse('${routeData["chat_user_id"]}');
            print('Video  ApiConstants.chatUserId=${ ApiConstants.chatUserId}');
            Navigator.pushNamed(context, Constant.CallScreen, arguments: {
              "user_id": routeData["chat_user_id"],
              "type": "3"
            });*/
            setState(() { });

           // NavigationUtils.generateRoute;
            //navigationToNextScreen();
          },
        ):Container(),
        (routeData["active"])
            ? PopupMenuButton<String>(
                onSelected: choiceAction,
                icon: Icon(
                  Icons.more_vert,
                  color: Custom_color.BlackTextColor,
                ),
                itemBuilder: (BuildContext context) {
                  return Constant.choices.map((String choice) {
                    print("----chociciv----" + choice.toString());
                    if (routeData["youblocked"] == 1 &&
                        choice == "Block User") {
                      return null;
                    }
                    if (routeData["youblocked"] == 0 &&
                        choice == "Unblock User") {
                      return null;
                    } else {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: CustomWigdet.TextView(
                            text:
                                AppLocalizations.of(context).translate(choice),
                            color: Custom_color.BlackTextColor),
                      );
                    }
                  }).toList();
                },
              )
            : Container()
      ],
      bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: _screenSize.width,
                  height: 0.5,
                  color: Custom_color.BlueLightColor,
                ),
              ),
            ],
          ),
          preferredSize: Size.fromHeight(0.0)),
      leading: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: Icon(
          Icons.arrow_back,
          color: Custom_color.BlueLightColor,
        ),
        onTap: () {
          Navigator.pop(context, true);
        },
      ),
    );
  }

  _showModalBottomSheet(context) {
    is_15min = true;
    is_1hour = false;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              decoration: BoxDecoration(
                  color: Custom_color.WhiteColor,
                  borderRadius: BorderRadius.circular(16)),
              margin: EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWigdet.TextView(
                      fontSize: 16,
                      text: AppLocalizations.of(context)
                          .translate("Share live location"),
                      color: Custom_color.BlackTextColor),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              is_15min = true;
                              is_1hour = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: is_15min
                                  ? Custom_color.BlueLightColor
                                  : Custom_color.WhiteColorLight,
                            ),
                            padding: EdgeInsets.all(8),
                            child: CustomWigdet.TextView(
                                text: AppLocalizations.of(context)
                                    .translate("15 minutes"),
                                textAlign: TextAlign.center,
                                color: is_15min
                                    ? Custom_color.WhiteColor
                                    : Custom_color.BlackTextColor),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              is_15min = false;
                              is_1hour = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: is_1hour
                                  ? Custom_color.BlueLightColor
                                  : Custom_color.WhiteColorLight,
                            ),
                            padding: EdgeInsets.all(8),
                            child: CustomWigdet.TextView(
                                text: AppLocalizations.of(context)
                                    .translate("1 hour"),
                                textAlign: TextAlign.center,
                                color: is_1hour
                                    ? Custom_color.WhiteColor
                                    : Custom_color.BlackTextColor),
                          ),
                        ),
                      )
                    ],
                  ),
                  // ListTile(
                  //   dense: true,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     initPlatformState(context);
                  //   },
                  //   leading: Image.asset(
                  //     "assest/images/ar-camera.png",
                  //     width: 26,
                  //     height: 26,
                  //     color: Custom_color.BlackTextColor,
                  //   ),
                  //   title: CustomWigdet.TextView(
                  //       text: AppLocalizations.of(context)
                  //           .translate("Share your location"),
                  //       color: Custom_color.BlackTextColor,
                  //       fontFamily: "OpenSans Bold",
                  //       fontSize: 16),
                  // ),
                  SizedBox(
                    height: 18,
                  ),
                  CustomWigdet.RoundRaisedButton(
                      onPress: () {
                        Navigator.pop(context);
                        initPlatformState(context);
                      },
                      text: AppLocalizations.of(context)
                          .translate("Share your location")
                          .toUpperCase(),
                      paddingTop: 10,
                      paddingBottom: 10,
                      textColor: Custom_color.WhiteColor,
                      bgcolor: Custom_color.BlueLightColor,
                      fontFamily: "OpenSans Bold"),
                ],
              ),
            );
          });
        });
  }

  void choiceAction(String choice) {
    if (choice == Constant.View_Profile) {
      Navigator.pushNamed(context, Constant.ChatUserDetail,
          arguments: {"user_id": routeData["chat_user_id"], "type": "3"});
    } else if (choice == Constant.Block_User) {
      print('------block User-----');
      _asyncDialogBlock(context,true);
    } else if (choice == Constant.Unblock_User) {
      print('-----unblock user------');
      _GetUnBlockUser();
    }
    else if (choice == Constant.Report_User) {
      print('-----unblock user------');
       _asyncDialogBlock(context,false);
    }
    else if(choice == Constant.AllchatClear_User){
      print('-----All Chat Clear user------');


      _asyncDialogAllClearChat(context);

      //_GetAllChatClearUser();
    }
  }

  Future<void> initPlatformState(BuildContext context) async {
    try {
      final bool serviceStatus = await _locationService.requestService();
      print("---Service status---: $serviceStatus");
      if (serviceStatus) {
        requestPermission(context);
      }
//      else {
//        bool serviceStatusResult = await _locationService.requestService();
//        print(
//            "Service status activated after request---: $serviceStatusResult");
//        if (serviceStatusResult) {
//          initPlatformState();
//        }
//      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        print("--eroor--" + e.message);
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        print("--eroor2222--" + e.message);
      }
    }
  }

  Future<void> requestPermission(BuildContext context) async {

    final PermissionStatus permissionRequestedResult =
        await _locationService.requestPermission();
    if (permissionRequestedResult == PermissionStatus.granted) {
      try {
        _currentLocation = await _locationService.getLocation();
        onSendMessage("", is_15min ? 3 : 4,
            location: 1,
            lat: _currentLocation.latitude,
            log: _currentLocation.longitude);
      } on PlatformException catch (e) {
        print(e);
        if (e.code == 'PERMISSION_DENIED') {
          print("--eroor--" + e.message);
        } else if (e.code == 'SERVICE_STATUS_ERROR') {
          print("--eroor2222--" + e.message);
        }
      }
    } else if (permissionRequestedResult == PermissionStatus.deniedForever) {
      AppSettings.openAppSettings();
    }
  }

  checkdateString(String newDate) {
    if ((!datefirstTime && Prevoius_date.isEmpty)) {
      Prevoius_date = newDate;
      isMatching = true;
      datefirstTime = true;
    } else {
      if (newDate == Prevoius_date) {
        isMatching = false;
      } else {
        Prevoius_date = newDate;
        isMatching = true;
      }
    }
  }

  _updateGPSLocation(Chat_holder chat) async {
    //   _currentLocation = await _locationService.getLocation();
    if (chat.type == 3 || chat.type == 4) {
      await _locationService.changeSettings(
          accuracy: LocationAccuracy.high, interval: 10000);
      Constant.locationSubscription =
          _locationService.onLocationChanged.handleError((dynamic err) {
        // setState(() {
        //   _error = err.code;
        // });
        print("-----error------" + err.toString());
        Constant.locationSubscription.cancel();
        Constant.locationSubscription = null;
      }).listen((LocationData currentLocation) async {
        // Use current location
        _currentLocation = currentLocation;
        print("----location-----" +
            _currentLocation.latitude.toString() +
            "---log-----" +
            _currentLocation.longitude.toString());

        Constant.socket.emit("livelocation", {
          "realtime": DateTime.now().millisecondsSinceEpoch.toString(),
          "message_id": Constant.message_id,
          "user_id": Constant.user_id,
          "sender_id": Constant.sender_id,
          "receiver_id": Constant.receiver_id,
          "chat_user_id": Constant.chat_user_id,
          "message": Constant.message,
          "status": Constant.status,
          "datetime": Constant.messagedatetime,
          "location": Constant.location,
          "lat": _currentLocation.latitude,
          "lan": _currentLocation.longitude,
          "type": Constant.type
        });
      });

      stoplivelocationGet(chat);
    }
  }

  _stoplivelocation(Chat_holder chat) {
    Constant.socket.emit("stopsharing", {
      "message_id": chat.message_id,
      "user_id": chat.user_id,
      "sender_id": chat.sender_id,
      "receiver_id": chat.receiver_id,
      "chat_user_id": chat.chat_user_id,
      // "message": Constant.message,
      // "status": Constant.status,
      //  "datetime": chat.datetime,
      // "location": chat.location,
      // "lat": _currentLocation.latitude,
      // "lan": _currentLocation.longitude
    });

    stoplivelocationGet(chat);
  }

  stoplivelocationGet(Chat_holder chat) {
    Constant.socket.on("event_stopsharing", (data) {
      print('-------stopsharingdata-------' + data.toString());
      // Chat_holder chatholder =
      //     messages.firstWhere((item) => item.message_id == data["message_id"]);

      // if (chat.message_id == data["message_id"])
      {
        chat.type = 5;
      }
      setState(() {});
      var contain =
          messages.where((element) => element.type == 3 || element == 4);
      if (contain.isEmpty) {
        //value not exists
        print(
            "-----------aary me 3 or 4 nahi mila-------1111111111--location cancel---hogaya------");
        if (Constant.locationSubscription != null) {
          Constant.locationSubscription.cancel();
          Constant.locationSubscription = null;
        }
      } else {
        //value exists
        print(
            "-----------aary me 3 or 4  mila---gare baba----2222222222-----------");
      }
    });
  }

  Future _asyncDialogBlock(BuildContext context,bool isBlock) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  Center(
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xfff16cae).withOpacity(0.8),
                        Color(0xff3f86c6).withOpacity(0.8),
                      ],
                    )
                ),
            child: Dialog(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Container(
                     height: isBlock ?180:180,

                  child: Column(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        margin:  EdgeInsets.only(top: MQ_Height*0.01,),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomWigdet.TextView(
                                textAlign: TextAlign.start,
                                fontWeight: Helper.textFontH5,
                                fontSize: Helper.textSizeH12,
                                overflow: true,

                                text: isBlock ? AppLocalizations.of(context)
                                    .translate("Do you want to block the user") :  AppLocalizations.of(context)
                                    .translate("Do you want to report the user"),
                                color: Custom_color.BlackTextColor),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          false?Divider(
                            color: Custom_color.GreyColor,
                            height: 1,
                          ):Container(),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                               false? Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10)),
                                      color: Custom_color.WhiteColor,
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 10.0),
                                    child: CustomWigdet.FlatButtonSimple(
                                      onPress: () {
                                        Navigator.of(context).pop();
                                        isBlock ? _GetBlockUser() : reportUser();
                                      },
                                      textAlign: TextAlign.center,
                                      text: AppLocalizations.of(context)
                                          .translate("Confirm")
                                          .toUpperCase(),
                                      textColor: Custom_color.GreyLightColor,
                                    ),
                                  ),
                                ):
                               Container(
                                 alignment: Alignment.bottomCenter,
                                 margin: EdgeInsets.only(left: MQ_Width * 0.01,
                                     right: MQ_Width * 0.01,
                                     top: MQ_Height * 0.02,
                                     bottom:MQ_Height * 0.02,),
                                 height: 50,
                                 width: MQ_Width*0.33,
                                 decoration: BoxDecoration(
                                   color: Color(Helper.ButtonBorderPinkColor),
                                   border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                   borderRadius: BorderRadius.circular(10),
                                 ),
                                 child: FlatButton(
                                   onPressed: ()async{


                                     Navigator.of(context).pop();
                                     isBlock ? _GetBlockUser() : reportUser();
                                   },
                                   child: Text(
                                     // isLocationEnabled?'CLOSE':'OPEN',
                                     AppLocalizations.of(context)
                                         .translate("Confirm")
                                         .toUpperCase(),
                                     textAlign: TextAlign.center,
                                     style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                   ),
                                 ),
                               ),
                               false? VerticalDivider(
                                  width: 1,
                                  color: Custom_color.GreyColor,
                                ):Container(),
                                false?Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10)),
                                      color: Custom_color.WhiteColor,
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 10.0),
                                    child: CustomWigdet.FlatButtonSimple(
                                      onPress: () {
                                        Navigator.of(context).pop();
                                      },
                                      textAlign: TextAlign.center,
                                      text: AppLocalizations.of(context)
                                          .translate("Cancel")
                                          .toUpperCase(),
                                      textColor: Custom_color.GreyLightColor,
                                    ),
                                  ),
                                ):  Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(left: MQ_Width * 0.01,
                                      right: MQ_Width * 0.01,
                                      top: MQ_Height * 0.02,
                                      bottom: MQ_Height * 0.02,),

                                  height: 50,
                                  width: MQ_Width*0.33,
                                  decoration: BoxDecoration(
                                    color: Helper.ButtonBorderGreyColor,//Color(Helper.ButtonBorderPinkColor),
                                    border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: FlatButton(
                                    onPressed: ()async{
                                      Navigator.of(context).pop();

                                    },
                                    child: Text(
                                      // isLocationEnabled?'CLOSE':'OPEN',
                                      AppLocalizations.of(context)
                                          .translate("Cancel")
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }

  Future _asyncConfirmDialog(BuildContext context, Chat_holder chat) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xfff16cae).withOpacity(0.8),
                    Color(0xff3f86c6).withOpacity(0.8),
                  ],
                )
            ),
            child: Dialog(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Container(
                  height: 150,
                  child: Column(
                    children: <Widget>[
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: true,
                            text: AppLocalizations.of(context)
                                .translate("Stop sharing live location?"),
                            fontFamily: "OpenSans Bold",
                            color: Custom_color.BlackTextColor),
                      ),
                      Spacer(),
                      Column(
                        children: <Widget>[
                          Divider(
                            color: Custom_color.WhiteColor,
                            height: 1,
                          ),
                          IntrinsicHeight(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10)),
                                      color: Custom_color.GreenColor,
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 10.0),
                                    child: CustomWigdet.FlatButtonSimple(
                                        onPress: () {
                                          Navigator.pop(context);
                                          _stoplivelocation(chat);
                                        },
                                        textAlign: TextAlign.center,
                                        text: AppLocalizations.of(context)
                                            .translate("Stop")
                                            .toUpperCase(),
                                        textColor: Custom_color.WhiteColor,
                                        fontFamily: "OpenSans Bold"),
                                  ),
                                ),
                                VerticalDivider(
                                  width: 1,
                                  color: Custom_color.WhiteColor,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10)),
                                      color: Custom_color.RedColor,
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 10.0),
                                    child: CustomWigdet.FlatButtonSimple(
                                        onPress: () {
                                          Navigator.of(context).pop();
                                        },
                                        textAlign: TextAlign.center,
                                        text: AppLocalizations.of(context)
                                            .translate("Cancel")
                                            .toUpperCase(),
                                        textColor: Custom_color.WhiteColor,
                                        fontFamily: "OpenSans Bold"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }

  void _showDialog(Chat_holder chat) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: CustomWigdet.TextView(
              text: AppLocalizations.of(context)
                  .translate("Stop sharing live location?"),
              fontFamily: "OpenSans Bold",
              color: Custom_color.BlackTextColor),
          actions: <Widget>[
            CustomWigdet.FlatButtonSimple(
                onPress: () {
                  Navigator.pop(context);
                  _stoplivelocation(chat);
                },
                text: AppLocalizations.of(context)
                    .translate("Stop")
                    .toUpperCase(),
                fontFamily: "OpenSans Bold",
                textColor: Custom_color.BlueLightColor),
            SizedBox(
              width: 5,
            ),
            CustomWigdet.FlatButtonSimple(
                onPress: () {
                  Navigator.of(context).pop();
                },
                text: AppLocalizations.of(context)
                    .translate("Cancel")
                    .toUpperCase(),
                fontFamily: "OpenSans Bold",
                textColor: Custom_color.BlueLightColor),
            SizedBox(
              width: 5,
            ),
          ],
        );
      },
    );
  }

  Future reportUser() async 
  {
      try 
      {
      _showProgress(context);
      String url = WebServices.GetReportBlockUser +
          SessionManager.getString(Constant.Token) +
          "&user_id=" +
          routeData["chat_user_id"];
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"] == 200) {
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"]);
          setState(() {
            routeData["youblocked"] = 1;
          });
        } else {
          // messages = data["message"].toString();
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }
        }
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future _GetBlockUser() async {
    try {
      _showProgress(context);
      String url = WebServices.GetBlockUser +
          SessionManager.getString(Constant.Token) +
          "&user_id=" +
          routeData["chat_user_id"];
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"] == 200) {
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"]);
          setState(() {
            routeData["youblocked"] = 1;
          });
        } else {
          // messages = data["message"].toString();
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }
        }
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future _GetUnBlockUser() async {
    try {
      _showProgress(context);
      String url = WebServices.GetUnBlockUser +
          SessionManager.getString(Constant.Token) +
          "&user_id=" +
          routeData["chat_user_id"];
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"] == 200) {
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"]);
          setState(() {
            routeData["youblocked"] = 0;
          });
        } else {
          // messages = data["message"].toString();
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }
        }
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  //=========== All Chat Clear ==============


  Future _asyncDialogAllClearChat(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  Center(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xfff16cae).withOpacity(0.8),
                    Color(0xff3f86c6).withOpacity(0.8),
                  ],
                )
            ),
            child: Dialog(
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Container(
                  height: 160,

                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.spaceBetween,

                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        margin:  EdgeInsets.only(top: MQ_Height*0.01,),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomWigdet.TextView(
                                textAlign: TextAlign.center,
                                fontWeight: Helper.textFontH5,
                                fontSize: Helper.textSizeH12,
                                overflow: true,
                                text:  AppLocalizations.of(context)
                                    .translate("Do you want to all clear chat"),
                                color: Custom_color.BlackTextColor),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          false?Divider(
                            color: Custom_color.GreyColor,
                            height: 1,
                          ):Container(),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[

                                Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(left: MQ_Width * 0.01,
                                      right: MQ_Width * 0.01,
                                      top: MQ_Height * 0.02,
                                      bottom: MQ_Height * 0.02),
                                  height: 50,
                                  width: MQ_Width*0.33,
                                  decoration: BoxDecoration(
                                    color: Color(Helper.ButtonBorderPinkColor),
                                    border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: FlatButton(
                                    onPressed: ()async{


                                      Navigator.of(context).pop();
                                      _PostAllChatClearUser();

                                    },
                                    child: Text(
                                      // isLocationEnabled?'CLOSE':'OPEN',
                                      AppLocalizations.of(context)
                                          .translate("Confirm")
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                    ),
                                  ),
                                ),
                                false?VerticalDivider(
                                  width: 1,
                                  color: Custom_color.GreyColor,
                                ):Container(),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(left: MQ_Width * 0.01,
                                      right: MQ_Width * 0.01,
                                      top: MQ_Height * 0.02,
                                      bottom: MQ_Height * 0.02),

                                  height: 50,
                                  width: MQ_Width*0.33,
                                  decoration: BoxDecoration(
                                    color: Helper.ButtonBorderGreyColor,//Color(Helper.ButtonBorderPinkColor),
                                    border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: FlatButton(
                                    onPressed: ()async{
                                      Navigator.of(context).pop();

                                    },
                                    child: Text(
                                      // isLocationEnabled?'CLOSE':'OPEN',
                                      AppLocalizations.of(context)
                                          .translate("Cancel")
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }


  Future _PostAllChatClearUser() async {
    try {
      _showProgress(context);
      var requestBody={
        "firstuser": routeData["user_id"],
        "seconduser":routeData["chat_user_id"]
      };
      print('_PostAllChatClearUser requestBody=${requestBody}');
      String url = WebServices.GetAllChatClearUser + SessionManager.getString(Constant.Token);
         /* + "&user_id=" +
          routeData["chat_user_id"];*/
      print("_PostAllChatClearUserr Url=" + url.toString());
      https.Response response = await https.post(Uri.parse(url),body: requestBody,
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("_PostAllChatClearUser respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"] == true) {
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"]);

          setState(() {
            if(messages.length!=0) {
              messages.clear();
            }
            if(historyList.length!=0) {
              historyList.clear();
            }

          });
          onReceivedMessage(historyList, 2);


        } else {
          // messages = data["message"].toString();
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                AppLocalizations.of(context).translate("Token Expire"));
          }
        }
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  _showProgress(BuildContext context) {
    Constant.needsReloading = true;
    progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    progressDialog.style(
        message: AppLocalizations.of(context).translate("Loading"),
        progressWidget: CircularProgressIndicator());
    //progressDialog.show();
  }

  _hideProgress() {
    if (progressDialog != null) {
      progressDialog.hide();
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    print("disposing chat");
    try
    {
        if (Constant.socket != null) 
        {
            Constant.socket.disconnect();
            Constant.socket.close();
            Constant.socket.clearListeners();
        }
    }catch(e){print(e.toString());}
    super.dispose();
  }

//================== FCM Integraton =============

  /*Future registerUser(String mobile, BuildContext context) async{
    print('registerUser FCM mobile=$mobile');

    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential){
          _auth.signInWithCredential(_credential).then((AuthResult result){
           *//* Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => HomeScreen(result.user)
            ));*//*
          }).catchError((e){
            print(e);
          });
        },
        verificationFailed: null,
        codeSent: null,
        codeAutoRetrievalTimeout: null
    );


  }
*/

  Future<bool> registerWithPhoneUser(String phone, BuildContext context) async{
    print('registerUser FCM phone=$phone');
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber:'+91 $phone',
        timeout: Duration(seconds: 120),
        verificationCompleted: (AuthCredential credential) async{
         Navigator.of(context).pop();

          UserCredential result = await _auth.signInWithCredential(credential);

          User user = result.user;
          print("FCM user=$user");
          if(user != null){
            /*Navigator.push(context, MaterialPageRoute(
                builder: (context) => HomeScreen(user: user,)
            ));*/
          }else{
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (FirebaseAuthException exception){
          print(' FCM FirebaseAuthException =$exception');
        },
        codeSent: (String verificationId, [int forceResendingToken]){
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Give the code?"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                     false?TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],

                        controller: _codeController,
                      ):PinCodeTextField(
                       autofocus: true,
                       controller: _codeController,
                       // hideCharacter: true,
                       // inputFormatters: [FilteringTextInputFormatter.allow(new RegExp('[1234567890]'))],
                       highlight: false,
                       highlightColor: Custom_color.BlueLightColor,//Color(Helper.textHintColorH3).withOpacity(0.5),
                       defaultBorderColor: Colors.grey,//Color(Helper.otpBgTextColor).withOpacity(0.5),
                       hasTextBorderColor:Custom_color.BlueLightColor,//Colors.grey,//Color(Helper.otpBgTextColor).withOpacity(0.5),
                       highlightPinBoxColor:Custom_color.BlueLightColor,//Color(Helper.textHintColorH3).withOpacity(0.5),
                       pinBoxWidth: MQ_Width*0.15,
                       // pinBoxHeight: 44,

                       hasUnderline: false,
                       wrapAlignment: WrapAlignment.spaceAround,
                       pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,

                       // pinBoxOuterPadding:const EdgeInsets.fromLTRB(1, 1, 1, 10) ,
                       pinTextStyle:  TextStyle(color:Color(Helper.textHintColorH3),fontWeight: Helper.textFontH6,fontSize:Helper.textSizeH2,height: 1.6),
                       pinTextAnimatedSwitcherTransition:
                       ProvidedPinBoxTextAnimation.scalingTransition,
                       pinBoxColor:Custom_color.BlueLightColor,//Colors.black12,
                       //Color(Helper.otpBgTextColor).withOpacity(0.5),
                       pinTextAnimatedSwitcherDuration:
                       Duration(milliseconds: 300),
//                    highlightAnimation: true,
                       highlightAnimationBeginColor: Color(Helper.uiTextColor),
                       highlightAnimationEndColor: Custom_color.BlueLightColor,//Color(Helper.textHintColorH3).withOpacity(0.5),
                       keyboardType: TextInputType.number,
                       maxLength: 6,
                     )
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Confirm"),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async{
                        final code = _codeController.text.trim();
                        AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code,
                         );

                        UserCredential result = await _auth.signInWithCredential(credential);

                        User user = result.user;

                        if(user != null){
                          /*Navigator.push(context, MaterialPageRoute(
                              builder: (context) => HomeScreen(user: user,)
                          ));*/
                          SessionManager.setString(Constant.user_fcmUid, user.uid);

                          createUser(
                            name: User_name,//'name',
                            mobile:User_mobile,//'',
                            email: User_email,//'email',
                            uId: user.uid,
                            regId:User_id,
                          avatar:User_Photo,//'https://i.pravatar.cc/300',
                          gender:User_gender,
                          dateofbirth:User_dateofbirth,
                          anothercall:false,
                          online:0,
                          flag:0,
                          datetime:'${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}'
                          );
                        }else{
                          print("Error");
                        }
                      },
                    )
                  ],
                );
              }
          );
        },
        codeAutoRetrievalTimeout: null
    );
  }


  Future<UserCredential> registerWithEmail(String email,String password,String name)async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('FirebaseAuth signout error=$e');
    }
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      ).then((value)async{
        print('FirebaseAuth singIn user=${value.user}');
        if(value.user != null){
          /*Navigator.push(context, MaterialPageRoute(
                              builder: (context) => HomeScreen(user: user,)
                          ));*/
          SessionManager.setString(Constant.user_fcmUid,value.user.uid);
          getUser();

          print('FirebaseAuth singIn The account listAuthusers == ${listAuthusers.length} \n receiver_Id=$receiver_Id');


          _homeCubit.//get(context).
          fireVideoCall(
              callModel: CallModel(
                  id: 'call_${UniqueKey().hashCode.toString()}',
                  callerId: SessionManager.getString(Constant.user_fcmUid),//CacheHelper.getString(key: 'uId'),
                  callerAvatar: User_Photo,//AuthCubit.get(context).currentUser.avatar,
                  callerName: User_name,//AuthCubit.get(context).currentUser.name,
                  receiverId: receiver_Id,//routeData["chat_user_id"],//users[index].id,
                  receiverAvatar:"https://i.pravatar.cc/300",//users[index].avatar,
                  receiverName:routeData["name"],//users[index].name,
                  status: CallStatus.ringing.name,
                  createAt: DateTime.now().millisecondsSinceEpoch,
                  current: true
              ));
        }else{
          print("Error");
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        UserRegisterGmailFCM(email,password,name);
        print('No user found for that email.');
        showToast(msg: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        showToast(msg: 'Wrong password provided for that user.');
      }
      print('FirebaseAuthException  signIn FCM error=$e');
    }




  }

  Future<UserCredential> UserRegisterGmailFCM(String email,String password,String name){


      return FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).then((value)async{
        if(value.user != null){
          /*Navigator.push(context, MaterialPageRoute(
                              builder: (context) => HomeScreen(user: user,)
                          ));*/

          getUser();
          SessionManager.setString(Constant.user_fcmUid,value.user.uid);

          createUser(
              name: User_name,//'name',
              mobile:User_mobile,//'',
              email: User_email,//'email',
              uId: value.user.uid,
              regId:User_id,
              avatar:User_Photo,//'https://i.pravatar.cc/300',
              gender:User_gender,
              dateofbirth:User_dateofbirth,
              anothercall:false,
              online:0,
              flag:0,
              datetime:'${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}'
          );
        }else{
          print("Error");
        }
      }).catchError((e) async {
        // on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
          showToast(msg: 'The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
          showToast(msg: 'The account already exists for that email.');
          print('The account already SessionManager.getString(Constant.user_fcmUid)=${SessionManager.getString(Constant.user_fcmUid)}\n routeData["name"]=${routeData["name"]}\n CallStatus.ringing.name=${CallStatus.ringing.name}\nrouteData["chat_user_id"]=${routeData["chat_user_id"]}\n niqueKey().hashCode.toString()=${UniqueKey().hashCode.toString()}');

          // var homeCubit = HomeCubit();
          //  var users=homeCubit.users;
          getUser();

          print('The account listAuthusers == ${listAuthusers.length} \n receiver_Id=$receiver_Id');


          _homeCubit.//get(context).
          fireVideoCall(
              callModel: CallModel(
                  id: 'call_${UniqueKey().hashCode.toString()}',
                  callerId: SessionManager.getString(Constant.user_fcmUid),//CacheHelper.getString(key: 'uId'),
                  callerAvatar: User_Photo,//AuthCubit.get(context).currentUser.avatar,
                  callerName: User_name,//AuthCubit.get(context).currentUser.name,
                  receiverId: receiver_Id,//routeData["chat_user_id"],//users[index].id,
                  receiverAvatar:"https://i.pravatar.cc/300",//users[index].avatar,
                  receiverName:routeData["name"],//users[index].name,
                  status: CallStatus.ringing.name,
                  createAt: DateTime.now().millisecondsSinceEpoch,
                  current: true
              ));

        }else if (e.code == 'user-not-found') {
          print('No user found for that email.');
          showToast(msg: 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          showToast(msg: 'Wrong password provided for that user.');
        }else{
          showToast(msg: '${e.code}');
        }
        // }

        print(' register catchError=$e');

        //emit(ErrorRegisterState(onError.toString()));
        // ErrorRegisterState(onError.toString())
      });
    }




  void createUser({String name,String mobile, String email,String uId,String regId,String avatar,bool anothercall,
    String gender,
    String dateofbirth,
    int online,
    int flag,
    var datetime}) {
    UserAuthModel user = UserAuthModel.resister(
        name: name,
        mobile: mobile,
        id: uId,
        regId: regId,
        email: email,
        avatar: avatar,
        busy: false,
        gender: gender,
        dateofbirth: dateofbirth,
        anothercall:false,
        online:online,
        flag:flag,
        datetime:datetime);
   /* _authApi.createUser(user: user).then((value) {
      currentUser = user;
     // emit(SuccessRegisterState(uId));
    }).catchError((onError){
      print('$AuthCubit createUser catchError=$onError');

      //emit(ErrorRegisterState(onError.toString()));
    });*/
    FirebaseFirestore.instance
        .collection(userCollection)
        .doc(user.id)
        .set(user.toMap()).then((value) => (){
      print(' Call  routeData["chat_user_id"]=${routeData["chat_user_id"]}\n routeData["user_id"]=${routeData["user_id"]}');
     // if(users[index].busy!=null){
      if(routeData["chat_user_id"]==user.regId){
        showToast(msg: 'Successfully register f');
        _homeCubit.//get(context).
        fireVideoCall(
            callModel: CallModel(
                id: 'call_${UniqueKey().hashCode.toString()}',
                callerId: SessionManager.getString(Constant.user_fcmUid),//CacheHelper.getString(key: 'uId'),
                callerAvatar: User_Photo,//AuthCubit.get(context).currentUser.avatar,
                callerName: User_name,//AuthCubit.get(context).currentUser.name,
                receiverId: routeData["chat_user_id"],//users[index].id,
                receiverAvatar:"https://i.pravatar.cc/300",//users[index].avatar,
                receiverName:routeData["name"],//users[index].name,
                status: CallStatus.ringing.name,
                createAt: DateTime.now().millisecondsSinceEpoch,
                current: true
            ));

      }else{
       // showToast(msg: 'User is busy');
        FlutterToastAlert.flutterToastMSG('User is busy', context);
      }
      });
  }

  Future<void> getUser() async{

    FirebaseFirestore.instance
        //.collection(userCollection)
        .collection('Users')
        .get()
        .then((value) {
      if(value.size!=0){
        print('getUser value.size=${value.size}');
        for (var element in value.docs) {
          if(!listAuthusers.any((e) => e.id == element.id)){
            listAuthusers.add(UserAuthModel.fromJsonMap(map: element.data(),uId: element.id));
            print('getUser element["regId"]=${element['regId']}');
            if(routeData["chat_user_id"]==element['regId']){
               receiver_Id= element['uId'];

            }
          }else{
            print('getUser element["regId"]=${element['regId']}');
            listAuthusers[listAuthusers.indexWhere((e) => e.id == element.id)] = UserAuthModel.fromJsonMap(map: element.data(),uId: element.id);
            if(routeData["chat_user_id"]==element['regId']){
               receiver_Id= element['uId'];

            }
          }
        }
       // emit(SuccessGetUsersState());
      }else{
      //  emit(ErrorGetUsersState('No users found'));
        showToast(msg: 'No users found ');
      }
    });

    setState(() { });
  }


}
