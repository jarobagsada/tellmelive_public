


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

// ignore: camel_case_types
class Broadcast_message extends StatefulWidget {

  @override
  Broadcast_messageState createState() => Broadcast_messageState();
}

class Broadcast_messageState extends State<Broadcast_message> {
  final msg = TextEditingController();

  String message = "";

  var routeData ;

  ProgressDialog progressDialog;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      routeData = ModalRoute.of(context).settings.arguments;

      print("------route-------" + routeData.toString());
    });

    super.initState();
  }

  void dispose() {
    msg.dispose();                          // Clean up the controller when the widget is disposed.
  }

  Widget build(BuildContext context) {


    routeData = ModalRoute.of(context).settings.arguments;
    print("-----event_id-----"+routeData);

    return SafeArea(
      child: Container(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assest/images/doodles.png'),
                  fit: BoxFit.cover
              ),
            ),
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
                      Text(AppLocalizations.of(context).translate("Message Broadcast"),
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
                SizedBox(height: 100),

                Container(

                  child: Stack(
                    children:[

                      Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration:
                          BoxDecoration(
                            border: Border.all(color: Custom_color.BlueDarkColor,),
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(25.0))
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 20.0),
                          child: Text(AppLocalizations.of(context)
                              .translate('What do you wanna share ?')),),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextFormField(
                            controller: msg,
                            maxLines: 5,
                            decoration: InputDecoration(
                                filled: true,
                              fillColor: Custom_color.WhiteColorLight,

                                border: OutlineInputBorder(),
                                hintText: AppLocalizations.of(context)
                                    .translate('Enter your message')),


                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlatButton(
                              color: Custom_color.GreenColor,
                              textColor: Colors.white,
                              child: Text(
                                AppLocalizations.of(context).translate('send'),

                              ),

                              onPressed: () {
                                message=msg.text ;
                               if(message!=""){
                                 _GetMessage(message);
                                 _GetMessageShow();

                               }
                               else{
                                 Alert(
                                   context: context,
                                   type: AlertType.warning,
                                   title: AppLocalizations.of(context).translate('Enter something'),
                                   buttons: [
                                     DialogButton(
                                       child: Text(
                                         'OK' ,
                                         style: TextStyle(color: Colors.white, fontSize: 20),
                                       ),
                                       onPressed: () => Navigator.pop(context),
                                       width: 120,
                                     )
                                   ],
                                 ).show();                 //Message is empty
                               }
                               print("Message : "+  message);
                              },
                            ),
                            SizedBox(width: 20.0),
                            FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              color: Custom_color.RedColor,
                              textColor: Colors.white,
                              child: Text(
                                AppLocalizations.of(context).translate('Cancel'),
                              ),
                            ),
                          ],
                        ),
      ]
                      ),

                    //     Column(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //
                    //   children: [
                    //     Align(
                    //
                    //       alignment: Alignment.bottomRight,
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: RawMaterialButton(
                    //
                    //
                    //           onPressed: () {
                    //             Navigator.pushNamed(context, Constant.Broadcasthistory,arguments: routeData) ;
                    //
                    //
                    //           },
                    //           elevation: 2.0,
                    //           fillColor: Colors.blue,
                    //           child: Icon(
                    //
                    //
                    //             Icons.history,
                    //             size: 32.0,
                    //           ),
                    //           padding: EdgeInsets.all(15.0),
                    //
                    //           shape: CircleBorder(),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // )

  ]


                    ),

                  ),
              ],
            ),
          ),

          ),
        ),
    );

  }

  get _appbar {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0), // here the desired height
      child: AppBar(
        title: CustomWigdet.TextView(
            text: ('Message Broadcast'),
            //AppLocalizations.of(context).translate("Activity")
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


  Future<https.Response> _GetMessageShow() async {
    try {

      _showProgress(context);
      Map jsondata = {"event_id":routeData};
      String url = WebServices.GetMessageshow +SessionManager.getString(Constant.Token)+"&language=${SessionManager.getString(Constant.Language_code)}" ;
      var response = await https.post(Uri.parse(url),
          body: jsondata);
      _hideProgress();
      print(url);
      print("response = " + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]==200) {
          print("-----logging-----");
          _hideProgress();
          Navigator.pushNamed(context, Constant.Broadcasthistory,arguments: routeData) ;




        }
      }
      else{
        print(response.statusCode) ;

      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();

    }

  }


  Future<https.Response> _GetMessage(message) async {
    try {


      Map jsondata = {"message" : message, "event_id":routeData,


      };
      String url = WebServices.GetMessage +SessionManager.getString(Constant.Token)+"&language=${SessionManager.getString(Constant.Language_code)}" ;
      var response = await https.post(Uri.parse(url),
          body: jsondata);

      print(url);
      print("response = " + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]==200) {
          print("-----logging-----");



          Navigator.pushNamed(context, Constant.Broadcastmessage, arguments: {
            "message":routeData["message"],

          });

        }
      }
      else{
        print(response.statusCode) ;

      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();

    }

  }


  _showProgress(BuildContext context) {
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
}
