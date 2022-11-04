import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:miumiu/screen/activity_user_detail.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/user.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:intl/intl.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:http/http.dart' as https;
import 'package:rflutter_alert/rflutter_alert.dart';



// class fetch_history {
//    String message ;
//    String time  ;
//
//   fetch_history({this.message,this.time});
//   factory fetch_history.fromJson(Map<String, dynamic> json){
//
//     return fetch_history(
//       message: json["message"],
//       time: json["time"]
//     );
//   }
//
//
// }


class Broadcast_message_history extends StatefulWidget {

  @override
  _Broadcast_message_historyState createState() => _Broadcast_message_historyState();
}

class _Broadcast_message_historyState extends State<Broadcast_message_history> {




  var routeData ;
  var message ;
  var time ;




  void initstate(){
    super.initState();
    Fetchhistory();

  }


  Widget build(BuildContext context) {


    routeData = ModalRoute.of(context).settings.arguments;

    print("-----event_id-----"+routeData);
    Fetchhistory();

    return SafeArea(
      child: Container(
        child: Scaffold(

          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                      color: Color(0xff1b98ea),
                      width: double.infinity,
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      GestureDetector(
                        onTap:(){
              Navigator.pop(context);
            },


                        child: Icon(
                          Icons.arrow_back_ios_outlined,
                          size: 20,
                            color: Colors.white,
                        ),
                      ),
                      Text(AppLocalizations.of(context).translate("Broadcast message history"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: "OpenSans bold"
                      ),
                      ),
                      Text(".")
                    ],
                  ),
                  ),
                  SizedBox(height: 20),

                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      child: ListView.builder(
                        reverse: true,
                          shrinkWrap: true,

                          itemCount: message==null? 0: message.length,
                          itemBuilder: (context, index){
                        return Padding(
                          padding: const EdgeInsets.only(top: 7.0),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(width: 20.0),

                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 120,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Card(

                                        color:Color(0xFFb3edff),

                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0) ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(

                                                message[index]["message"],
                                            style: TextStyle(
                                              fontSize: 15.0
                                            ),),
                                          )

                                      ),


                                    ],

                                  ),
                                ),
                              ),
                              SizedBox(width: 100.0),
                              FractionallySizedBox(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  alignment: Alignment.centerRight,

                                  width: 100.0,

                                  child: Column(

                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Card
                                        (color: Color(0xFFbbff99),

                                          child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(message[index]["time"]),
                                        )),
                                    ],

                                  ),
                                ),
                              )
                            ],
                          ),
                        ) ;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          )
        ),

      ),
    );
  }
  Future<https.Response> Fetchhistory() async {
    String url = WebServices.GetMessageshow +SessionManager.getString
      (Constant.Token)+"&language=${SessionManager.getString(Constant.Language_code)}"+"&event_id="+ routeData;
    print(url);
    https.Response response = await https.get(Uri.parse(url));
    print("response----" + response.body);
    print(message.toString());

    if (response.statusCode == 200) {
      var data = json.decode(response.body) ;
      if (data["status"]==200){

        setState(() {
          message= data["message"];
          time = data["message"];
        });
      }
    }
    else {

      throw Exception('Failed to load history');
    }
  }

  get _appbar {
    return PreferredSize(

      preferredSize: Size.fromHeight(70.0), // here the desired height
      child: AppBar(

        title: CustomWigdet.TextView(
            text:
            AppLocalizations.of(context).translate("Broadcast message history"),
            textAlign: TextAlign.center,
            color: Custom_color.WhiteColor,
            fontFamily: "OpenSans Bold"),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30))),

      ),
    );
  }

}
