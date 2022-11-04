import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/screen/settings/broadcast_message.dart';
import 'package:miumiu/utilmethod/fluttertoast_alert.dart';
import 'package:translator/translator.dart';
import 'package:flutter/material.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/user.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../utilmethod/helper.dart';

class Activity_User_Detail extends StatefulWidget {
  @override
  _Activity_User_DetailState createState() => _Activity_User_DetailState();
}

class _Activity_User_DetailState extends State<Activity_User_Detail> {
  String async(String tt) {
    final translator = GoogleTranslator();
    final tt = title;
    title = translator.translate(tt, from: 'de', to: 'en');

    return title;
  }

  Size _screenSize;
  var routeData;
  bool loading;
  var title,
      comma = " , ",
      gender,
      age,
      activty_from,
      image = "",
      profile_image = "",
      user_id,
      location,
      interest,
      interest_desp,
      comment,
      start_time,
      end_time,
      t1,
      t2,
      end_time_first,
      end_time_second,
      suscribedcount,
      action = "",
      storedata;

  List subscriberlist = [];

  ProgressDialog progressDialog;
  List<User> categroy_list = [];
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int active;
  var MQ_Height;
  var MQ_Width;

  List<Color> _kDefaultRainbowColors = const [
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.pinkAccent,
    Colors.pink,
    Colors.pink,
    Colors.pinkAccent,

  ];
  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }
  _getUserDetails(){
    Future.delayed(Duration.zero, () {
      routeData = ModalRoute.of(context).settings.arguments;
      action = routeData["action"];
      GetEventUser(routeData["event_id"].toString());
      print("------route-------" + routeData.toString());
    });
    loading = false;
    subscriberlist = [];
  }

  @override
  Widget build(BuildContext context) {
    routeData = ModalRoute.of(context).settings.arguments;
    _screenSize = MediaQuery.of(context).size;
    MQ_Height= MediaQuery.of(context).size.height;
    MQ_Width=MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: Stack(
            children: [
             // _widgetActivityUserDetailUI()
              _widgetActivityUserDetailNewUI()
            ],
        ),
      ),
    );
  }


  //================= Old UI Activity user details =========
  Widget _widgetActivityUserDetailUI(){
    return Visibility(
      visible: loading,
      replacement: Center(
        child: CircularProgressIndicator(),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            child: Column(
              children: <Widget>[
                Stack(alignment: Alignment.bottomCenter, children: [
                  Image(
                    fit: BoxFit.fill,
                    image: AssetImage("assest/images/create_activity.png"),
                  ),
                  Positioned(
                    top: 30,
                    child: Container(
                        width: MediaQuery.of(context).size.width-100,

                        child: CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: false,
                            text:title.toString(),
                            fontSize: 25,
                            fontFamily: "Kelvetica Nobis",
                            color: Colors.white

                        )
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Custom_color.BlueLightColor,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  !UtilMethod.isStringNullOrBlank(image)
                      ? Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () {
                          print("----ds-f-ds-d-g-f-gd-fg--------");
                          if (image != null) {
                            _asyncViewImage(context);
                          }
                        },
                        child: Container(
                          height: 140.0,
                          width: 140.0,
                          decoration: BoxDecoration(
                            color: Custom_color.PlacholderColor,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(image,scale: 1.0),
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Custom_color.WhiteColor,
                              width: 2.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      : Container(),
                  !UtilMethod.isStringNullOrBlank(action) &&
                      action == Constant.Activity
                      ? Positioned(
                    top: 180,
                    left: 230,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, Constant.Edit_Activity,
                            arguments:
                            routeData["event_id"]);
                        print("Edit Activity");
                      },
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: Custom_color.GreyLightColor,
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 20.0,
                          ),
                        ]),
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.white,
                          child: Image(
                            image: AssetImage(
                                "assest/images/edit_pink.png"),
                            width: 17,
                            height: 17,
                          ),
                        ),
                      ),
                    ),
                  )
                      : Container()
                ]),

                // FlatButton(onPressed:(){
                //   Navigator.pushNamed(context, Constant.Edit_Activity, arguments: routeData["event_id"].toString());
                //
                //
                // },
                //
                //     child: Text(AppLocalizations.of(context).translate("Edit Activity"))),

                // Container(
                //   width: _screenSize.width,
                //   height: 200,
                //   child: Card(
                //     elevation: 2,
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Column(
                //         children: <Widget>[
                //           CustomWigdet.TextView(
                //               text: title,
                //               color: Custom_color.BlueLightColor,
                //               fontFamily: "OpenSans Bold"),
                //           SizedBox(
                //             height: 8,
                //           ),
                //           Container(
                //             height: 149,
                //             width: _screenSize.width,
                //             decoration: BoxDecoration(
                //               shape: BoxShape.rectangle,
                //               color: Custom_color.PlacholderColor,
                //               borderRadius: BorderRadius.circular(5),
                //               image: DecorationImage(
                //                   image: NetworkImage(image),
                //                   fit: BoxFit.contain),
                //             ),
                //           ),
                //           //  Image.network(Constant.ImageURL+"5f00b5c392540.jpg",fit: BoxFit.cover)
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        ClipShadowPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)))),
                          shadow: BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 15.0,
                          ),
                          child: GestureDetector(
                            onTap: (){
                              print("to profile page");
                              Navigator.pushNamed(
                                  context, Constant.ChatUserDetail,
                                  arguments: {
                                    "user_id": user_id,
                                    "type": "1"
                                  });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 8.0, color: Color(0xff1b98ea)),
                                ),
                                color: Colors.white,
                              ),
                              child: ListTile(
                                // leading: Container(
                                //   padding: EdgeInsets.all(10),
                                //   decoration: BoxDecoration(
                                //
                                //     borderRadius:
                                //         BorderRadius.all(Radius.circular(5.0)),
                                //     color: Custom_color.BlueLightColor,
                                //   ),
                                //   child: Image.asset(
                                //     "assest/images/pin.png",
                                //     width: 18,
                                //     height: 18,
                                //     fit: BoxFit.contain,
                                //     color: Custom_color.WhiteColor,
                                //   ),
                                // ),

                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 2.0, top: 10, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CustomWigdet.TextView(
                                              overflow: true,
                                              text: activty_from,
                                              color:
                                              Custom_color.BlackTextColor,
                                              fontFamily: "Kelvetica Nobis"),
                                          SizedBox(width: 4),
                                          CustomWigdet.TextView(
                                              overflow: true,
                                              text: age,
                                              color:
                                              Custom_color.BlackTextColor,
                                              fontFamily: "Kelvetica Nobis"),
                                        ],
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.only(top: 5.0),
                                          child: gender == "Female"
                                              ? Image(
                                            image: AssetImage(
                                                "assest/images/female1.png"),
                                            width: 20,
                                            height: 20,
                                          )
                                              : Image(
                                            image: AssetImage(
                                                "assest/images/male.png"),
                                            width: 20,
                                            height: 20,
                                          ))
                                    ],
                                  ),
                                ),

                                title: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 30.0,
                                        width: 30.0,
                                        decoration: BoxDecoration(
                                          color: Custom_color
                                              .PlacholderColor,
                                          image: new DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                profile_image,scale: 1.0),
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      CustomWigdet.TextView(
                                          overflow: true,
                                          text: AppLocalizations.of(context)
                                              .translate("Activity from"),
                                          color: Custom_color.GreyLightColor,
                                          fontFamily: "Kelvetica Nobis"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ClipShadowPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)))),
                          shadow: BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 15.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 8.0, color: Color(0xff1b98ea)),
                              ),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              // leading: Container(
                              //   padding: EdgeInsets.all(10),
                              //   decoration: BoxDecoration(
                              //
                              //     borderRadius:
                              //         BorderRadius.all(Radius.circular(5.0)),
                              //     color: Custom_color.BlueLightColor,
                              //   ),
                              //   child: Image.asset(
                              //     "assest/images/pin.png",
                              //     width: 18,
                              //     height: 18,
                              //     fit: BoxFit.contain,
                              //     color: Custom_color.WhiteColor,
                              //   ),
                              // ),

                              subtitle: Padding(
                                padding: const EdgeInsets.only(
                                    left: 2.0, top: 10, bottom: 10),
                                child: CustomWigdet.TextView(
                                    overflow: true,
                                    text: location,
                                    color: Custom_color.BlackTextColor,
                                    fontFamily: "Kelvetica Nobis"),
                              ),

                              title: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Image(
                                      image: AssetImage(
                                          "assest/images/pin.png"),
                                      color: Custom_color.GreyLightColor,
                                      width: 18,
                                      height: 18,
                                    ),
                                    SizedBox(width: 10),
                                    CustomWigdet.TextView(
                                        overflow: true,
                                        text: AppLocalizations.of(context)
                                            .translate("Location"),
                                        color: Custom_color.GreyLightColor,
                                        fontFamily: "Kelvetica Nobis"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        categroy_list != null && categroy_list.isNotEmpty
                            ? ClipShadowPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)))),
                          shadow: BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 15.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 8.0,
                                    color: Color(0xff1b98ea)),
                              ),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              title: Padding(
                                padding:
                                const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Image(
                                      image: AssetImage(
                                          "assest/images/gym.png"),
                                      color:
                                      Custom_color.GreyLightColor,
                                      width: 18,
                                      height: 18,
                                    ),
                                    SizedBox(width: 10),
                                    CustomWigdet.TextView(
                                        text: AppLocalizations.of(
                                            context)
                                            .translate("Category"),
                                        color: Custom_color
                                            .GreyLightColor,
                                        fontFamily:
                                        "Kelvetica Nobis"),
                                  ],
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(
                                    left: 2.0, top: 10, bottom: 10),
                                child: CustomWigdet.TextView(
                                    overflow: true,
                                    text: _getListcategroyitem(
                                        categroy_list),
                                    color:
                                    Custom_color.BlackTextColor,
                                    fontFamily: "Kelvetica Nobis"),
                              ),
                            ),
                          ),
                        )
                            : Container(),

                        !UtilMethod.isStringNullOrBlank(interest)
                            ? ClipShadowPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)))),
                          shadow: BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 15.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 8.0,
                                    color: Color(0xff1b98ea)),
                              ),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              title: CustomWigdet.TextView(
                                  text: interest_desp,
                                  color: Custom_color.GreyLightColor,
                                  fontFamily: "Kelvitica Nobis"),
                              subtitle: CustomWigdet.TextView(
                                  overflow: true,
                                  text: interest,
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Bold"),
                            ),
                          ),
                        )
                            : Container(),
                        SizedBox(height: 20),
                        ClipShadowPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)))),
                          shadow: BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 15.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 8.0, color: Color(0xff1b98ea)),
                              ),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Image(
                                    image:
                                    AssetImage("assest/images/cal.png"),
                                    color: Custom_color.GreyLightColor,
                                    width: 18,
                                    height: 18,
                                  ),
                                  SizedBox(width: 10),
                                  CustomWigdet.TextView(
                                      overflow: true,
                                      text: AppLocalizations.of(context)
                                          .translate("Date"),
                                      color: Custom_color.GreyLightColor,
                                      fontFamily: "Kelvetica Nobis"),
                                ],
                              ),

                              // ,CustomWigdet.TextView(
                              //     overflow: true,
                              //     text:end_time==null && t1 == null && t2==null?
                              //     "$start_time" :
                              //     "$start_time -  $end_time "
                              //         "\n $t1 - $t2 ",
                              //
                              //     color: Custom_color.BlackTextColor,
                              //     fontFamily: "OpenSans Bold"),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(
                                    left: 2.0, top: 10),
                                child: CustomWigdet.TextView(
                                  text: end_time == "" || end_time == null
                                      ? "$start_time"
                                      : "$start_time " +
                                      AppLocalizations.of(context)
                                          .translate("To") +
                                      "  $end_time ",
                                  color: Custom_color.BlackTextColor,
                                  fontFamily:
                                  "itc-avant-garde-gothic-lt-bold",
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        !UtilMethod.isStringNullOrBlank(t1)
                            ? ClipShadowPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)))),
                          shadow: BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 15.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 8.0,
                                    color: Color(0xff1b98ea)),
                              ),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Image(
                                    image: AssetImage(
                                        "assest/images/clock.png"),
                                    color:
                                    Custom_color.GreyLightColor,
                                    width: 18,
                                    height: 18,
                                  ),
                                  SizedBox(width: 10),
                                  CustomWigdet.TextView(
                                      overflow: true,
                                      text:
                                      AppLocalizations.of(context)
                                          .translate("Time"),
                                      color:
                                      Custom_color.GreyLightColor,
                                      fontFamily: "Kelvetica Nobis"),
                                ],
                              ),

                              // ,CustomWigdet.TextView(
                              //     overflow: true,
                              //     text:end_time==null && t1 == null && t2==null?
                              //     "$start_time" :
                              //     "$start_time -  $end_time "
                              //         "\n $t1 - $t2 ",
                              //
                              //     color: Custom_color.BlackTextColor,
                              //     fontFamily: "OpenSans Bold"),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(
                                    left: 2.0, top: 10),
                                child: CustomWigdet.TextView(
                                  text: t2 == "" || t2==null
                                      ? "$t1"
                                      : "$t1  " +
                                      AppLocalizations.of(context)
                                          .translate("To") +
                                      "  $t2 ",
                                  color: Custom_color.BlackTextColor,
                                  fontFamily:
                                  "itc-avant-garde-gothic-lt-bold",
                                ),
                              ),
                            ),
                          ),
                        )
                            : Container(),

                        SizedBox(height: 20),
                        !UtilMethod.isStringNullOrBlank(
                            suscribedcount.toString())
                            ? ClipShadowPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)))),
                          shadow: BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 15.0,
                          ),
                          child:
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 8.0,
                                    color: Color(0xff1b98ea)),
                              ),
                              color: Colors.white,
                            ),
                            child:
                            InkWell(
                                onTap: () => {
                                  subscriberlist.length > 0 ?
                                  showMemberList() : print('no users')
                                },
                                child : ListTile(
                                  title:
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                          children : [
                                            Image(
                                              image: AssetImage(
                                                  "assest/images/membar.png"),
                                              color:
                                              Custom_color.GreyLightColor,
                                              width: 18,
                                              height: 18,
                                            ),
                                            SizedBox(width: 10),
                                            CustomWigdet.TextView(
                                                text:
                                                AppLocalizations.of(context)
                                                    .translate("Members"),
                                                color:
                                                Custom_color.GreyLightColor,
                                                fontFamily: "Kelvetica Nobis"),
                                          ]

                                      ),

                                      subscriberlist.length > 0  ?
                                      Image(
                                        image: AssetImage(
                                            "assest/images/right_arrow.png"),
                                        color:
                                        Custom_color.GreyLightColor,
                                        width: 10,
                                        height: 10,
                                      ) : Container()

                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2.0, top: 10),
                                    child: CustomWigdet.TextView(
                                        overflow: true,
                                        text: suscribedcount.toString(),
                                        color:
                                        Custom_color.BlackTextColor,
                                        fontFamily:
                                        "itc-avant-garde-gothic-lt-bold"),
                                  ),
                                )),
                          ),
                        )
                            : Container(),

                        SizedBox(height: 20),

                        //   SizedBox(height: 20),

                        !UtilMethod.isStringNullOrBlank(comment)
                            ? ClipShadowPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)))),
                          shadow: BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 15.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 8.0,
                                    color: Color(0xff1b98ea)),
                              ),
                              color: Colors.white,
                            ),
                            child: ListTile(
                                title: Row(
                                  children: [
                                    Image(
                                      image: AssetImage(
                                          "assest/images/info.png"),
                                      color:
                                      Custom_color.GreyLightColor,
                                      width: 18,
                                      height: 18,
                                    ),
                                    SizedBox(width: 10),
                                    CustomWigdet.TextView(
                                        text: AppLocalizations.of(
                                            context)
                                            .translate("About"),
                                        color: Custom_color
                                            .GreyLightColor,
                                        fontFamily:
                                        "Kelvetica Nobis"),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 2.0, top: 10),
                                  child: CustomWigdet.TextView(
                                      overflow: true,
                                      text: comment,
                                      color:
                                      Custom_color.BlackTextColor,
                                      fontFamily: "Kelvetica Nobis"),
                                )),
                          ),
                        )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                active == 1 || active == 0
                    ? Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          child: !UtilMethod.isStringNullOrBlank(
                              action) &&
                              action == Constant.Activity
                              ? Row(
                            children: [
                              CustomWigdet
                                  .RoundRaisedButtonIcon(
                                  onPress: () {
                                    _asyncConfirmDialog(
                                        context);
                                  },
                                  textColor: Custom_color
                                      .WhiteColor,
                                  fontFamily:
                                  "Kelvetica Nobis",
                                  bgcolor:
                                  Custom_color.RedColor,
                                  icon:
                                  Icons.delete_forever,
                                  fontSize: 11.0,
                                  fontWeight:
                                  FontWeight.bold,
                                  text: AppLocalizations.of(
                                      context) //delete  button in activity
                                      .translate("Delete")
                                      .toUpperCase()),
                              SizedBox(width: 15.0),
                              Container(
                                child: CustomWigdet
                                    .RoundRaisedButtonIcon(
                                  text: AppLocalizations.of(
                                      context)
                                      .translate(
                                      "Broadcast a message")
                                      .toUpperCase(), //Broadcast message
                                  icon: Icons.chat_bubble,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Kelvetica Nobis",

                                  bgcolor: Custom_color
                                      .BlueDarkColor,
                                  textColor: Custom_color
                                      .WhiteColorLight,
                                  onPress: () {
                                    if (suscribedcount > 0) {
                                      print(
                                          "------message brodcasted--------");
                                      print(
                                          "navigate to the message input page");
                                      Navigator.pushNamed(
                                          context,
                                          Constant
                                              .Broadcastmessage,
                                          arguments: routeData[
                                          "event_id"]
                                              .toString());
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(builder: (context) => Broadcast_message(routeData["event_id"].toString())),
                                      // );

                                    } else {
                                      print(
                                          "No one has subscribed your activity yet");
                                      Alert(
                                        context: context,
                                        type: AlertType.info,
                                        title: AppLocalizations
                                            .of(context)
                                            .translate(
                                            'Not enough Subscriber'),
                                        desc: AppLocalizations
                                            .of(context)
                                            .translate(
                                            'No one has subscribed to your activity yet'),
                                        buttons: [
                                          DialogButton(
                                            child: Text(
                                              AppLocalizations.of(
                                                  context)
                                                  .translate(
                                                  'Fine'),
                                              style: TextStyle(
                                                  color: Colors
                                                      .white,
                                                  fontSize: 20),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context),
                                            width: 120,
                                          )
                                        ],
                                      ).show();
                                    }
                                  },
                                ),
                              )
                            ],
                          )

                          // Color(0xfffb4592)
                              : (routeData["isSub"] != null &&
                              routeData["isSub"] == 0)
                              ? GestureDetector(
                            onTap: () {
                              _GetSubscribeSecond(
                                  context, "1");
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.only(
                                  bottom: 30.0,
                                  left: 150),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                        context)
                                        .translate(
                                        "I am interested"),
                                    style: TextStyle(
                                        color: Color(
                                            0xfffb4592),
                                        fontFamily:
                                        "itc-avant-garde-gothic-lt-bold",
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight
                                            .w500),
                                  ),
                                  SizedBox(width: 10),
                                  CircleAvatar(
                                    backgroundColor:
                                    Color(0xfffb4592),
                                    child: ImageIcon(
                                      AssetImage(
                                          "assest/images/mood_happy.png"),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : GestureDetector(
                            onTap: () {
                              _GetSubscribeSecond(
                                  context, "0");
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.only(
                                  bottom: 30.0,
                                  left: 150),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                        context)
                                        .translate(
                                        "I am not interested"),
                                    style: TextStyle(
                                        color: Color(
                                            0xfffb4592),
                                        fontFamily:
                                        "itc-avant-garde-gothic-lt-bold",
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight
                                            .w500),
                                  ),
                                  SizedBox(width: 10),
                                  CircleAvatar(
                                    backgroundColor:
                                    Color(0xfffb4592),
                                    child: ImageIcon(
                                      AssetImage(
                                          "assest/images/mood_bad.png"),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }


  //================= New UI Activity user details =========
  Widget _widgetActivityUserDetailNewUI(){
    return Visibility(
      visible: loading,
      replacement: false?Center(
        child: CircularProgressIndicator(),
      ):Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xfff16cae).withOpacity(0.3),
                  Color(0xff3f86c6).withOpacity(0.3),
                ],
              )
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              child: LoadingIndicator(
                indicatorType: Indicator.lineScalePulseOut,
                colors: _kDefaultRainbowColors,
                strokeWidth: 2.0,
                pathBackgroundColor:Colors.black45,
                // showPathBackground ? Colors.black45 : null,
              ),
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          color: Color(Helper.inBackgroundColor1),//Colors.transparent,
          child: ListView(
            children: <Widget>[
              Stack(alignment: Alignment.bottomCenter,
                  children: [
                Image(
                 fit: BoxFit.fill,
                 image: AssetImage("assest/images/blueimage.png"),//AssetImage("assest/images/create_activity.png"),
                  ),
                Positioned(
                  top: 25,
                  child: Container(
                      width: MediaQuery.of(context).size.width-100,

                      child: CustomWigdet.TextView(
                          textAlign: TextAlign.left,
                          overflow: false,
                          text:AppLocalizations.of(context).translate("Activity Details"),//title.toString(),
                          fontSize: Helper.textSizeH11,
                          fontWeight:Helper.textFontH4,
                          fontFamily: "Kelvetica Nobis",
                          color: Colors.white

                      )
                  ),
                ),
                Positioned(
                  top: 25,
                  left: 5,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: false?CircleAvatar(
                      radius: 17,
                      backgroundColor: Custom_color.BlueLightColor,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ):Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ),

               /*!UtilMethod.isStringNullOrBlank(image) ?
               Positioned(
                top:70,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        print("----ds-f-ds-d-g-f-gd-fg--------");
                        if (image != null) {
                          _asyncViewImage(context);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,

                              colors: [
                                // Color(0XFF8134AF),
                                // Color(0XFFDD2A7B),
                                // Color(0XFFFEDA77),
                                // Color(0XFFF58529),
                                Colors.purpleAccent.withOpacity(0.3),
                                Colors.pinkAccent.withOpacity(0.3),

                              ],
                            ),
                            shape: BoxShape.circle
                        ),
                        child: Container(
                            margin: EdgeInsets.all(10),
                          height: 210.0,
                          width: 210.0,
                          decoration: BoxDecoration(
                            color: Custom_color.PlacholderColor,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(image),
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Custom_color.WhiteColor,
                              width: 2.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    : Container(),*/
                !UtilMethod.isStringNullOrBlank(action) &&
                    action == Constant.Activity
                    ? Positioned(
                  top: 180,
                  left: 230,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          context, Constant.Edit_Activity,
                          arguments:
                          routeData["event_id"]);
                      print("Edit Activity");
                    },
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Custom_color.GreyLightColor,
                          offset: Offset(1.0, 1.0), //(x,y)
                          blurRadius: 20.0,
                        ),
                      ]),
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        child: Image(
                          image: AssetImage(
                              "assest/images/edit_pink.png"),
                          width: 17,
                          height: 17,
                        ),
                      ),
                    ),
                  ),
                )
                    : Container()
              ]),



              SizedBox(height: MQ_Height*0.08),

               /*Container(
                padding: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      ClipShadowPath(
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)))),
                        shadow: BoxShadow(
                          color: Color(0xffe4e9ef),
                          offset: Offset(1.0, 1.0), //(x,y)
                          blurRadius: 15.0,
                        ),
                        child: GestureDetector(
                          onTap: (){
                            print("to profile page");
                            Navigator.pushNamed(
                                context, Constant.ChatUserDetail,
                                arguments: {
                                  "user_id": user_id,
                                  "type": "1"
                                });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 8.0, color: Color(0xff1b98ea)),
                              ),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              // leading: Container(
                              //   padding: EdgeInsets.all(10),
                              //   decoration: BoxDecoration(
                              //
                              //     borderRadius:
                              //         BorderRadius.all(Radius.circular(5.0)),
                              //     color: Custom_color.BlueLightColor,
                              //   ),
                              //   child: Image.asset(
                              //     "assest/images/pin.png",
                              //     width: 18,
                              //     height: 18,
                              //     fit: BoxFit.contain,
                              //     color: Custom_color.WhiteColor,
                              //   ),
                              // ),

                              subtitle: Padding(
                                padding: const EdgeInsets.only(
                                    left: 2.0, top: 10, bottom: 10),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CustomWigdet.TextView(
                                            overflow: true,
                                            text: activty_from,
                                            color:
                                            Custom_color.BlackTextColor,
                                            fontFamily: "Kelvetica Nobis"),
                                        SizedBox(width: 4),
                                        CustomWigdet.TextView(
                                            overflow: true,
                                            text: age,
                                            color:
                                            Custom_color.BlackTextColor,
                                            fontFamily: "Kelvetica Nobis"),
                                      ],
                                    ),
                                    Padding(
                                        padding:
                                        const EdgeInsets.only(top: 5.0),
                                        child: gender == "Female"
                                            ? Image(
                                          image: AssetImage(
                                              "assest/images/female1.png"),
                                          width: 20,
                                          height: 20,
                                        )
                                            : Image(
                                          image: AssetImage(
                                              "assest/images/male.png"),
                                          width: 20,
                                          height: 20,
                                        ))
                                  ],
                                ),
                              ),

                              title: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 30.0,
                                      width: 30.0,
                                      decoration: BoxDecoration(
                                        color: Custom_color
                                            .PlacholderColor,
                                        image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              profile_image),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    CustomWigdet.TextView(
                                        overflow: true,
                                        text: AppLocalizations.of(context)
                                            .translate("Activity from"),
                                        color: Custom_color.GreyLightColor,
                                        fontFamily: "Kelvetica Nobis"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ClipShadowPath(
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)))),
                        shadow: BoxShadow(
                          color: Color(0xffe4e9ef),
                          offset: Offset(1.0, 1.0), //(x,y)
                          blurRadius: 15.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 8.0, color: Color(0xff1b98ea)),
                            ),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            // leading: Container(
                            //   padding: EdgeInsets.all(10),
                            //   decoration: BoxDecoration(
                            //
                            //     borderRadius:
                            //         BorderRadius.all(Radius.circular(5.0)),
                            //     color: Custom_color.BlueLightColor,
                            //   ),
                            //   child: Image.asset(
                            //     "assest/images/pin.png",
                            //     width: 18,
                            //     height: 18,
                            //     fit: BoxFit.contain,
                            //     color: Custom_color.WhiteColor,
                            //   ),
                            // ),

                            subtitle: Padding(
                              padding: const EdgeInsets.only(
                                  left: 2.0, top: 10, bottom: 10),
                              child: CustomWigdet.TextView(
                                  overflow: true,
                                  text: location,
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "Kelvetica Nobis"),
                            ),

                            title: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Image(
                                    image: AssetImage(
                                        "assest/images/pin.png"),
                                    color: Custom_color.GreyLightColor,
                                    width: 18,
                                    height: 18,
                                  ),
                                  SizedBox(width: 10),
                                  CustomWigdet.TextView(
                                      overflow: true,
                                      text: AppLocalizations.of(context)
                                          .translate("Location"),
                                      color: Custom_color.GreyLightColor,
                                      fontFamily: "Kelvetica Nobis"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      categroy_list != null && categroy_list.isNotEmpty
                          ? ClipShadowPath(
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)))),
                        shadow: BoxShadow(
                          color: Color(0xffe4e9ef),
                          offset: Offset(1.0, 1.0), //(x,y)
                          blurRadius: 15.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 8.0,
                                  color: Color(0xff1b98ea)),
                            ),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: Padding(
                              padding:
                              const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Image(
                                    image: AssetImage(
                                        "assest/images/gym.png"),
                                    color:
                                    Custom_color.GreyLightColor,
                                    width: 18,
                                    height: 18,
                                  ),
                                  SizedBox(width: 10),
                                  CustomWigdet.TextView(
                                      text: AppLocalizations.of(
                                          context)
                                          .translate("Category"),
                                      color: Custom_color
                                          .GreyLightColor,
                                      fontFamily:
                                      "Kelvetica Nobis"),
                                ],
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(
                                  left: 2.0, top: 10, bottom: 10),
                              child: CustomWigdet.TextView(
                                  overflow: true,
                                  text: _getListcategroyitem(
                                      categroy_list),
                                  color:
                                  Custom_color.BlackTextColor,
                                  fontFamily: "Kelvetica Nobis"),
                            ),
                          ),
                        ),
                      )
                          : Container(),

                      !UtilMethod.isStringNullOrBlank(interest)
                          ? ClipShadowPath(
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)))),
                        shadow: BoxShadow(
                          color: Color(0xffe4e9ef),
                          offset: Offset(1.0, 1.0), //(x,y)
                          blurRadius: 15.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 8.0,
                                  color: Color(0xff1b98ea)),
                            ),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: CustomWigdet.TextView(
                                text: interest_desp,
                                color: Custom_color.GreyLightColor,
                                fontFamily: "Kelvitica Nobis"),
                            subtitle: CustomWigdet.TextView(
                                overflow: true,
                                text: interest,
                                color: Custom_color.BlackTextColor,
                                fontFamily: "OpenSans Bold"),
                          ),
                        ),
                      )
                          : Container(),
                      SizedBox(height: 20),
                      ClipShadowPath(
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)))),
                        shadow: BoxShadow(
                          color: Color(0xffe4e9ef),
                          offset: Offset(1.0, 1.0), //(x,y)
                          blurRadius: 15.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 8.0, color: Color(0xff1b98ea)),
                            ),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Image(
                                  image:
                                  AssetImage("assest/images/cal.png"),
                                  color: Custom_color.GreyLightColor,
                                  width: 18,
                                  height: 18,
                                ),
                                SizedBox(width: 10),
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text: AppLocalizations.of(context)
                                        .translate("Date"),
                                    color: Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis"),
                              ],
                            ),

                            // ,CustomWigdet.TextView(
                            //     overflow: true,
                            //     text:end_time==null && t1 == null && t2==null?
                            //     "$start_time" :
                            //     "$start_time -  $end_time "
                            //         "\n $t1 - $t2 ",
                            //
                            //     color: Custom_color.BlackTextColor,
                            //     fontFamily: "OpenSans Bold"),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(
                                  left: 2.0, top: 10),
                              child: CustomWigdet.TextView(
                                text: end_time == "" || end_time == null
                                    ? "$start_time"
                                    : "$start_time " +
                                    AppLocalizations.of(context)
                                        .translate("To") +
                                    "  $end_time ",
                                color: Custom_color.BlackTextColor,
                                fontFamily:
                                "itc-avant-garde-gothic-lt-bold",
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      !UtilMethod.isStringNullOrBlank(t1)
                          ? ClipShadowPath(
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)))),
                        shadow: BoxShadow(
                          color: Color(0xffe4e9ef),
                          offset: Offset(1.0, 1.0), //(x,y)
                          blurRadius: 15.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 8.0,
                                  color: Color(0xff1b98ea)),
                            ),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Image(
                                  image: AssetImage(
                                      "assest/images/clock.png"),
                                  color:
                                  Custom_color.GreyLightColor,
                                  width: 18,
                                  height: 18,
                                ),
                                SizedBox(width: 10),
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text:
                                    AppLocalizations.of(context)
                                        .translate("Time"),
                                    color:
                                    Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis"),
                              ],
                            ),

                            // ,CustomWigdet.TextView(
                            //     overflow: true,
                            //     text:end_time==null && t1 == null && t2==null?
                            //     "$start_time" :
                            //     "$start_time -  $end_time "
                            //         "\n $t1 - $t2 ",
                            //
                            //     color: Custom_color.BlackTextColor,
                            //     fontFamily: "OpenSans Bold"),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(
                                  left: 2.0, top: 10),
                              child: CustomWigdet.TextView(
                                text: t2 == "" || t2==null
                                    ? "$t1"
                                    : "$t1  " +
                                    AppLocalizations.of(context)
                                        .translate("To") +
                                    "  $t2 ",
                                color: Custom_color.BlackTextColor,
                                fontFamily:
                                "itc-avant-garde-gothic-lt-bold",
                              ),
                            ),
                          ),
                        ),
                      )
                          : Container(),

                      SizedBox(height: 20),
                      !UtilMethod.isStringNullOrBlank(
                          suscribedcount.toString())
                          ? ClipShadowPath(
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)))),
                        shadow: BoxShadow(
                          color: Color(0xffe4e9ef),
                          offset: Offset(1.0, 1.0), //(x,y)
                          blurRadius: 15.0,
                        ),
                        child:
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 8.0,
                                  color: Color(0xff1b98ea)),
                            ),
                            color: Colors.white,
                          ),
                          child:
                          InkWell(
                              onTap: () => {
                                subscriberlist.length > 0 ?
                                showMemberList() : print('no users')
                              },
                              child : ListTile(
                                title:
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                        children : [
                                          Image(
                                            image: AssetImage(
                                                "assest/images/membar.png"),
                                            color:
                                            Custom_color.GreyLightColor,
                                            width: 18,
                                            height: 18,
                                          ),
                                          SizedBox(width: 10),
                                          CustomWigdet.TextView(
                                              text:
                                              AppLocalizations.of(context)
                                                  .translate("Members"),
                                              color:
                                              Custom_color.GreyLightColor,
                                              fontFamily: "Kelvetica Nobis"),
                                        ]

                                    ),

                                    subscriberlist.length > 0  ?
                                    Image(
                                      image: AssetImage(
                                          "assest/images/right_arrow.png"),
                                      color:
                                      Custom_color.GreyLightColor,
                                      width: 10,
                                      height: 10,
                                    ) : Container()

                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 2.0, top: 10),
                                  child: CustomWigdet.TextView(
                                      overflow: true,
                                      text: suscribedcount.toString(),
                                      color:
                                      Custom_color.BlackTextColor,
                                      fontFamily:
                                      "itc-avant-garde-gothic-lt-bold"),
                                ),
                              )),
                        ),
                      )
                          : Container(),

                      SizedBox(height: 20),

                      //   SizedBox(height: 20),

                      !UtilMethod.isStringNullOrBlank(comment)
                          ? ClipShadowPath(
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)))),
                        shadow: BoxShadow(
                          color: Color(0xffe4e9ef),
                          offset: Offset(1.0, 1.0), //(x,y)
                          blurRadius: 15.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 8.0,
                                  color: Color(0xff1b98ea)),
                            ),
                            color: Colors.white,
                          ),
                          child: ListTile(
                              title: Row(
                                children: [
                                  Image(
                                    image: AssetImage(
                                        "assest/images/info.png"),
                                    color:
                                    Custom_color.GreyLightColor,
                                    width: 18,
                                    height: 18,
                                  ),
                                  SizedBox(width: 10),
                                  CustomWigdet.TextView(
                                      text: AppLocalizations.of(
                                          context)
                                          .translate("About"),
                                      color: Custom_color
                                          .GreyLightColor,
                                      fontFamily:
                                      "Kelvetica Nobis"),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(
                                    left: 2.0, top: 10),
                                child: CustomWigdet.TextView(
                                    overflow: true,
                                    text: comment,
                                    color:
                                    Custom_color.BlackTextColor,
                                    fontFamily: "Kelvetica Nobis"),
                              )),
                        ),
                      )
                          : Container(),
                    ],
                  ),
                ),
              ),*/

              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 10,right: 10,),
                margin: EdgeInsets.only(top: 40),
                child: Text(title.toString(),
                  textAlign: TextAlign.center,

                  style: TextStyle(color:Helper.textColorBlueH1,
                      fontFamily: "Kelvetica Nobis",
                      fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH11),),
              ),
              SizedBox(height: MQ_Height*0.06),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [

                  Column(

                    children: [
                      Container(
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                        padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.08,bottom: MQ_Width*0.02) ,
                        height: 8,
                        width: MQ_Width*0.60,
                        decoration: BoxDecoration(
                          color:Colors.blue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight:  Radius.circular(20),
                          ),

                        ),),
                      Container(
                        margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                        padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                        height: MQ_Height*0.55,
                        decoration: BoxDecoration(
                          color:Colors.white,//Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),

                        ),

                        child: Column(
                          children: [
                            false?Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Text('Created by',
                                            style: TextStyle(color:Color(Helper.textColorBlackH1),
                                                fontFamily: "Kelvetica Nobis",
                                                fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),),
                                        ),
                                        CustomWigdet.TextView(
                                            overflow: true,
                                            text: activty_from,
                                            color: Helper.textColorBlueH1,
                                            fontWeight: Helper.textFontH4,
                                            fontSize: Helper.textSizeH12,
                                            fontFamily: "Kelvetica Nobis"),
                                        SizedBox(
                                          height: MQ_Height*0.01,
                                        ),
                                        Container(
                                          width: 70,
                                          height: 1,
                                          color: Color(0xfffb4592),//Colors.purpleAccent,
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: MQ_Width*0.01,),
                                      // width: _screenSize.width,
                                      padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),

                                      alignment: Alignment.topCenter,
                                      child:
                                      ClipOval(
                                        child: Material(
                                          color: Colors.white60,
                                          // Button color
                                          child: InkWell(
                                            splashColor: Helper.inIconCircleGreyColor1, // Splash color
                                            onTap: () {
                                           //   toggleAboutMeDialog();

                                            },
                                            child: SizedBox(width: 20, height: 20,
                                              child:true?Icon(Icons.edit,color:Helper.inIconGreyColor1,size: 16,):
                                              Image.asset("assest/images/edit.png",
                                                width: 16,height: 16,color: Colors.white,),
                                            ),
                                          ),
                                        ),
                                      )

                                  ),
                                ],
                              ),
                            ):Container(),
                            SizedBox(
                              height: MQ_Height*0.10,
                            ),

                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: Custom_color.GreyLightColor,
                                      child:Image(
                                        image: AssetImage(
                                            "assest/images/pin.png"),
                                        color: Custom_color.WhiteColor,
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 10),

                                  Container(
                                    child: Expanded(
                                      child: CustomWigdet.TextView(
                                          overflow: true,
                                          text: location,
                                          fontWeight: Helper.textFontH5,
                                          fontSize: Helper.textSizeH14,
                                          color: Custom_color.GreyLightColor,
                                          fontFamily: "Kelvetica Nobis"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MQ_Height*0.02,),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: Custom_color.GreyLightColor,
                                      child:false?Image(
                                        image: AssetImage(
                                            "assest/images/membar.png"),
                                        color: Custom_color.WhiteColor,
                                        width: 18,
                                        height: 18,
                                      ):Icon(Icons.people_alt_rounded,size: 18,color: Custom_color.WhiteColor,),
                                    ),
                                  ),

                                  SizedBox(width: 10),
                                  Container(
                                    child: CustomWigdet.TextView(
                                        overflow: true,
                                        text: AppLocalizations.of(context).translate("People Can Join"),
                                        fontWeight: Helper.textFontH5,
                                        fontSize: Helper.textSizeH14,
                                        color: Custom_color.GreyLightColor,
                                        fontFamily: "Kelvetica Nobis"),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                subscriberlist.length!=0
                                    ?_widgetcountPeople2():Container(child: Text('0'),),

                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: CustomWigdet.TextView(
                                        overflow: true,
                                        text: suscribedcount!=0&&suscribedcount!=null&&suscribedcount>2?'+${suscribedcount-2}':'',
                                        fontWeight: Helper.textFontH5,
                                        fontSize: Helper.textSizeH13,
                                        color: Colors.pinkAccent.shade400,
                                        fontFamily: "Kelvetica Nobis"),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    color:Colors.black,
                                    width: 1,
                                    height: 40,
                                  ),

                                  SizedBox(width: 10),
                                  InkWell(
                                    child: Container(
                                      child: CustomWigdet.TextView(
                                          overflow: true,
                                          text: suscribedcount!=null?'${suscribedcount} '+AppLocalizations.of(context).translate("people Joined"):'',
                                          fontWeight: Helper.textFontH5,
                                          fontSize: Helper.textSizeH14,
                                          color: Custom_color.BlueLightColor,
                                          fontFamily: "Kelvetica Nobis"),
                                    ),
                                    onTap: (){
                                      subscriberlist.length > 0 ?
                                      showMemberList() : print('no users');
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MQ_Height*0.02,),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: Custom_color.GreyLightColor,
                                      child:Image(
                                        image: AssetImage(
                                            "assest/images/cal.png"),
                                        color: Custom_color.WhiteColor,
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 10),
                                  Container(
                                    child: CustomWigdet.TextView(
                                        overflow: true,
                                        text: end_time == "" || end_time == null
                                            ? "$start_time"
                                            : "$start_time " +
                                            AppLocalizations.of(context)
                                                .translate("To").toLowerCase() +
                                            "  $end_time ",
                                        fontWeight: Helper.textFontH4,
                                        fontSize: Helper.textSizeH14,
                                        color: Custom_color.GreyLightColor,
                                        fontFamily: "Kelvetica Nobis"),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: MQ_Height*0.02,),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: Custom_color.GreyLightColor,
                                      child:Image(
                                        image: AssetImage(
                                            "assest/images/clock.png"),
                                        color: Custom_color.WhiteColor,
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 10),
                                  Container(
                                    child:  Expanded(
                                      child: CustomWigdet.TextView(
                                          overflow: true,
                                          text: t2 == "" || t2==null
                                              ? "Start Time "+"$t1"
                                              : "$t1  " +
                                              AppLocalizations.of(context)
                                                  .translate("To").toLowerCase() +
                                              "  $t2 ",
                                          fontWeight: Helper.textFontH5,
                                          fontSize: Helper.textSizeH14,
                                          color: Custom_color.GreyLightColor,
                                          fontFamily: "Kelvetica Nobis"),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: MQ_Height*0.02,),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: Custom_color.GreyLightColor,
                                      child:false?Image(
                                        image: AssetImage(
                                            "assest/images/membar.png"),
                                        color: Custom_color.WhiteColor,
                                        width: 18,
                                        height: 18,
                                      ):Icon(Icons.people_alt_rounded,size: 18,color: Custom_color.WhiteColor,),
                                    ),
                                  ),

                                  SizedBox(width: 10),
                                  Container(
                                    child: Expanded(
                                      child: CustomWigdet.TextView(
                                          overflow: true,
                                          text: comment!=null?'${comment}':'',
                                          fontWeight: Helper.textFontH5,
                                          fontSize: Helper.textSizeH14,
                                          color: Custom_color.GreyLightColor,
                                          fontFamily: "Kelvetica Nobis"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                        padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.08,bottom: MQ_Width*0.02) ,
                        height: 8,
                        width: MQ_Width*0.60,
                        decoration: BoxDecoration(
                          color:Colors.blue,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight:  Radius.circular(20),
                          ),

                        ),)
                    ],
                  ),

                  !UtilMethod.isStringNullOrBlank(image) ?
                  Positioned(
                    bottom:MQ_Height*0.70,

                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () {
                          print("----ds-f-ds-d-g-f-gd-fg--------");
                          if (image != null) {
                            _asyncViewImage(context);
                          }
                        },
                        child: Container(

                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,

                                colors: [
                                  // Color(0XFF8134AF),
                                  // Color(0XFFDD2A7B),
                                  // Color(0XFFFEDA77),
                                  // Color(0XFFF58529),
                                  Colors.purpleAccent.withOpacity(0.3),
                                  Colors.pinkAccent.withOpacity(0.3),

                                ],
                              ),
                              shape: BoxShape.circle
                          ),
                          child: Container(
                            margin: EdgeInsets.only(left: 10,right: 10,bottom:10,top: 10),
                            height: 190.0,
                            width: 190.0,
                            decoration: BoxDecoration(
                              color: Custom_color.PlacholderColor,
                              image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(image,scale: 1.0),
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Custom_color.WhiteColor,
                                width: 2.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      : Container(),
                  false?Positioned(
                    //bottom: 10,
                    child: Container(
                      // alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(left: 160,bottom: 60),
                      height: 110.0,
                      width: 110.0,
                      decoration: BoxDecoration(
                        color: Custom_color
                            .PlacholderColor,
                        image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                              profile_image),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ):Positioned(
                     bottom:MQ_Height*0.47,
                    child: Container(
                      //margin: EdgeInsets.only(left: 160,bottom: 60),
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            child: false?Container(
                              // alignment: Alignment.topCenter,
                              height: 70.0,
                              width: 70.0,
                              decoration: BoxDecoration(
                                color: Custom_color
                                    .PlacholderColor,
                                image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      profile_image,scale: 1.0),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ): Container(
                              // alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                 // border: Border.all(color: Custom_color.BlueLightColor,width: 0.5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomLeft,

                                    colors: [
                                      // Color(0XFF8134AF),
                                      // Color(0XFFDD2A7B),
                                      // Color(0XFFFEDA77),
                                      // Color(0XFFF58529),
                                      Colors.blue.withOpacity(0.5),
                                      Colors.blue.withOpacity(0.5),
                                     // Color(0xfffb4592).withOpacity(0.5),
                                      //Color(0xfffb4592).withOpacity(0.5),
                                      //Colors.blue.withOpacity(0.5),

                                    ],
                                  ),
                                  shape: BoxShape.circle
                              ),
                              child: Container(
                                margin: EdgeInsets.all(5),

                                child: ClipOval(
                                  child: Material(
                                    // color:Helper.inIconCircleBlueColor1, // Button color
                                    child: InkWell(
                                      splashColor: Helper.inIconCircleBlueColor1, // Splash color
                                      onTap: () {
                                        /* Navigator.pushNamed(context, Constant.ChatUserDetail,
                                                    arguments: {"user_id": chat_item.user_id, "type": "3"});*/
                                      },
                                      child: SizedBox(width: 70, height: 70,
                                          child:Image(image: profile_image!= null ||profile_image!=""?NetworkImage(profile_image,scale: 1.0):const AssetImage('assest/images/user2.png'),
                                            fit: BoxFit.cover,)
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onTap: ()async{
                              Navigator.pushNamed(context, Constant.ChatUserDetail,
                                  arguments: {"user_id":user_id, "type": "2"});
                            },
                          ),
                          Container(
                            child: Text(AppLocalizations.of(context).translate("Created by"),
                              style: TextStyle(color:Color(Helper.textColorBlackH1),
                                  fontFamily: "Kelvetica Nobis",
                                  fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),),
                          ),
                          InkWell(
                            child: CustomWigdet.TextView(
                                overflow: true,
                                text: activty_from,
                                color: Helper.textColorBlueH1,
                                fontWeight: Helper.textFontH4,
                                fontSize: Helper.textSizeH12,
                                fontFamily: "Kelvetica Nobis"),
                            onTap: ()async{
                              Navigator.pushNamed(context, Constant.ChatUserDetail,
                                  arguments: {"user_id":user_id, "type": "2"});
                            },
                          ),
                          SizedBox(
                            height: MQ_Height*0.01,
                          ),
                          Container(
                            width: 70,
                            height: 1,
                            color: Color(0xfffb4592),//Colors.purpleAccent,
                          )
                        ],
                      ),
                    ),),
                ],
              ),
              SizedBox(
                height: MQ_Height*0.05,
              ),
              active == 1 || active == 0
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        child: !UtilMethod.isStringNullOrBlank(
                            action) &&
                            action == Constant.Activity
                            ? Row(
                          children: [
                            CustomWigdet
                                .RoundRaisedButtonIcon(
                                onPress: () {
                                  _asyncConfirmDialog(
                                      context);
                                },
                                textColor: Custom_color
                                    .WhiteColor,
                                fontFamily:
                                "Kelvetica Nobis",
                                bgcolor:
                                Custom_color.RedColor,
                                icon:
                                Icons.delete_forever,
                                fontSize: 11.0,
                                fontWeight:
                                FontWeight.bold,
                                text: AppLocalizations.of(
                                    context) //delete  button in activity
                                    .translate("Delete")
                                    .toUpperCase()),
                            SizedBox(width: 15.0),
                            Container(
                              child: CustomWigdet
                                  .RoundRaisedButtonIcon(
                                text: AppLocalizations.of(
                                    context)
                                    .translate(
                                    "Broadcast a message")
                                    .toUpperCase(), //Broadcast message
                                icon: Icons.chat_bubble,
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Kelvetica Nobis",

                                bgcolor: Custom_color
                                    .BlueDarkColor,
                                textColor: Custom_color
                                    .WhiteColorLight,
                                onPress: () {
                                  if (suscribedcount > 0) {
                                    print(
                                        "------message brodcasted--------");
                                    print(
                                        "navigate to the message input page");
                                    Navigator.pushNamed(
                                        context,
                                        Constant
                                            .Broadcastmessage,
                                        arguments: routeData[
                                        "event_id"]
                                            .toString());
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => Broadcast_message(routeData["event_id"].toString())),
                                    // );

                                  } else {
                                    print(
                                        "No one has subscribed your activity yet");
                                   /* Alert(
                                      context: context,
                                      type: AlertType.info,
                                      title: AppLocalizations
                                          .of(context)
                                          .translate(
                                          'Not enough Subscriber'),
                                      desc: AppLocalizations
                                          .of(context)
                                          .translate(
                                          'No one has subscribed to your activity yet'),
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            AppLocalizations.of(
                                                context)
                                                .translate(
                                                'Fine'),
                                            style: TextStyle(
                                                color: Colors
                                                    .white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(
                                                  context),
                                          width: 120,
                                        )
                                      ],
                                    ).show();*/

                                    _showDialogBroadcast(context);
                                  }
                                },
                              ),
                            )
                          ],
                        )

                        // Color(0xfffb4592)
                            : (routeData["isSub"] != null &&
                            routeData["isSub"] == 0)
                            ? GestureDetector(
                          onTap: () {
                            _GetSubscribeSecond(context, "1");

                          },
                          child: Padding(
                            padding:
                            const EdgeInsets.only(
                                bottom: 30.0,
                                left: 150),
                            child: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(
                                      context)
                                      .translate(
                                      "I am interested"),
                                  style: TextStyle(
                                      color: Color(
                                          0xfffb4592),
                                      fontFamily:
                                      "itc-avant-garde-gothic-lt-bold",
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight
                                          .w500),
                                ),
                                SizedBox(width: 10),
                                CircleAvatar(
                                  backgroundColor:
                                  Color(0xfffb4592),
                                  child: ImageIcon(
                                    AssetImage(
                                        "assest/images/mood_happy.png"),
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            : GestureDetector(
                          onTap: () {
                            _GetSubscribeSecond(
                                context, "0");
                          },
                          child: Padding(
                            padding:
                            const EdgeInsets.only(
                                bottom: 30.0,
                                left: 150),
                            child: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(
                                      context)
                                      .translate(
                                      "I am not interested"),
                                  style: TextStyle(
                                      color: Color(
                                          0xfffb4592),
                                      fontFamily:
                                      "itc-avant-garde-gothic-lt-bold",
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight
                                          .w500),
                                ),
                                SizedBox(width: 10),
                                CircleAvatar(
                                  backgroundColor:
                                  Color(0xfffb4592),
                                  child: ImageIcon(
                                    AssetImage(
                                        "assest/images/mood_bad.png"),
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  showMemberList1() {
      print('clicked '+subscriberlist.length.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
            return false?AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
               content: Container(
                 height: 270,
                 width: 500,
                 child: Stack(
                   children: [
                     ListView.builder(
                       shrinkWrap: true,
                       itemCount: subscriberlist.length,
                       itemBuilder: (context, i) {
                           var eachItem = subscriberlist[i] as Map;
                           var item     = eachItem.values.toList();
                           print(item);
                           print(item[14]);
                           return  InkWell(
                             onTap: () {
                                 Navigator.pushNamed(context, Constant.ChatUserDetail,
                                       arguments: {"user_id": item[0].toString(), "type": "2"});
                             },
                             child : Column(
                               children : [
                               Container(
                               width:double.infinity,
                               child :Row(
                                   children : [
                                       SizedBox(
                                         child :
                                               Container(
                                                 width: 50.0,
                                                 height: 50.0,
                                                 decoration: BoxDecoration(
                                                   boxShadow: [
                                                     BoxShadow(
                                                       color: Colors.grey,
                                                       blurRadius: 3,
                                                       offset: Offset(0, 2), // Shadow position
                                                     ),
                                                   ],
                                                   image: DecorationImage(
                                                       fit: BoxFit.cover, image: NetworkImage(item[14])),
                                                   borderRadius: BorderRadius.all(Radius.circular(200.0)),
                                                   color: Colors.grey,
                                                 ),
                                               ),
                                       ),
                                       Container(
                                           margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                           child : CustomWigdet.TextView(
                                               text: item[3],
                                               textAlign: TextAlign.start,
                                               color: Custom_color.BlackTextColor,
                                               fontFamily: "OpenSans Bold"),

                                       ),




                                   ]
                               )
                             ),
                             SizedBox(
                               height:20
                             )

                           ]));
                       },
                     ),
                     Positioned(

                         child: InkWell(
                           child: Container(
                               alignment: Alignment.topRight,
                               child: Icon(Icons.cancel,color: Colors.pink,size:30,)),
                           onTap: (){
                             Navigator.pop(context,1);
                           },
                         ))
                   ],
                 ),
               ),
            ):Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 270,
                child: Stack(
                  children: [
                    Container(
                      width: 260,
                      margin: EdgeInsets.only(left: MQ_Width*0.02,right: MQ_Width*0.02,top: 10,bottom: 10),

                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: subscriberlist.length,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          var eachItem = subscriberlist[i] as Map;
                          var item     = eachItem.values.toList();
                          print(item);
                          print(item[14]);
                          return  InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, Constant.ChatUserDetail,
                                    arguments: {"user_id": item[0].toString(), "type": "2"});
                              },
                              child : Column(
                                  children : [
                                    Container(
                                        width:double.infinity,
                                        child :Row(
                                            children : [
                                              SizedBox(
                                                child :
                                                Container(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey,
                                                        blurRadius: 3,
                                                        offset: Offset(0, 2), // Shadow position
                                                      ),
                                                    ],
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover, image: NetworkImage(item[14],scale: 1.0)),
                                                    borderRadius: BorderRadius.all(Radius.circular(200.0)),
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                child : CustomWigdet.TextView(
                                                    text: item[3],
                                                    textAlign: TextAlign.start,
                                                    color: Custom_color.BlackTextColor,
                                                    fontFamily: "OpenSans Bold"),

                                              ),




                                            ]
                                        )
                                    ),
                                    SizedBox(
                                        height:20
                                    )

                                  ]));
                        },
                      ),
                    ),
                    Positioned(
                        child: InkWell(
                          child: Container(
                              alignment: Alignment.topRight,
                              child: Icon(Icons.cancel,color: Colors.pink,size:30,)),
                          onTap: (){
                            Navigator.pop(context,1);
                          },
                        ))
                  ],
                ),
              ),
            );
        }
      );
  }



  //====================== New Ui showMemberList ===============
  Future<void> showMemberList()async{


    await showDialog(context: context,
        builder: (BuildContext context){
          return Container(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Helper.avatarRadius),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Stack(
                alignment: Alignment.topRight,
                children: [

                  Container(
                    padding: EdgeInsets.only(left: Helper.padding,top: 5
                        + Helper.padding, right: Helper.padding,bottom: 5
                    ),
                    margin: EdgeInsets.only(top: Helper.avatarRadius),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      //color: Colors.white,
                      color: Color(Helper.inBackgroundColor1),
                      borderRadius: BorderRadius.circular(Helper.padding),
                      /* boxShadow: [
                        BoxShadow(color: Colors.black,offset: Offset(0,10),
                            blurRadius: 10
                        ),
                      ]*/
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                     // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Text('Location',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                        //SizedBox(height: MQ_Height*0.07,),
                        Container(
                          height: subscriberlist.length>3?MQ_Height*0.40:MQ_Height*0.20,
                         // alignment: Alignment.center,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: subscriberlist.length,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, i) {
                              var eachItem = subscriberlist[i] as Map;
                              var item     = eachItem.values.toList();
                              print(item);
                              print(item[14]);
                              return  false?InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, Constant.ChatUserDetail,
                                        arguments: {"user_id": item[0].toString(), "type": "2"});
                                  },
                                  child : Column(
                                      children : [
                                        Container(
                                            width:double.infinity,
                                            child :Row(
                                                children : [
                                                  SizedBox(
                                                    child :
                                                    Container(
                                                      width: 50.0,
                                                      height: 50.0,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey,
                                                            blurRadius: 3,
                                                            offset: Offset(0, 2), // Shadow position
                                                          ),
                                                        ],
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover, image: NetworkImage(item[14],scale: 1.0)),
                                                        borderRadius: BorderRadius.all(Radius.circular(200.0)),
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                    child : CustomWigdet.TextView(
                                                        text: item[3],
                                                        textAlign: TextAlign.start,
                                                        color: Custom_color.BlackTextColor,
                                                        fontFamily: "OpenSans Bold"),

                                                  ),




                                                ]
                                            )
                                        ),
                                        SizedBox(
                                            height:20
                                        )

                                      ])):InkWell(
                                onTap: ()async{
                                  Navigator.pop(context,1);
                                  Navigator.pushNamed(context, Constant.ChatUserDetail,
                                      arguments: {"user_id": item[0].toString(), "type": "2"});

                                },
                                child: Container(
                                margin: EdgeInsets.all(4),
                                child: Stack(
                                  //  crossAxisAlignment: CrossAxisAlignment.start,
                                  alignment: Alignment.centerLeft,
                                  children: <Widget>[
                                    Container(
                                        alignment: Alignment.centerRight,
                                        // width: 300,
                                         height: MQ_Height*0.07,
                                        margin: EdgeInsets.only(left: MQ_Width*0.05),
                                        padding: EdgeInsets.only(left: MQ_Width*0.14,top: MQ_Height*0.01,bottom: MQ_Height*0.01),
                                        decoration: BoxDecoration(
                                            border: Border.all(width: 1,color: Colors.blue.withOpacity(0.3)),
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10)
                                        ),

                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[



                                            /*Container(
                    margin: EdgeInsets.only(top: 5,bottom: 2),
                    width: 40,
                    height: 1.0,
                    color: Color(0xfffb4592),//Colors.purpleAccent,
                  ),
                  SizedBox(
                    height: MQ_Height*0.02,
                  ),*/
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              margin: EdgeInsets.only(top: 2,bottom: 2),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.centerLeft,
                                                    margin: EdgeInsets.only(top: 5,bottom: 2),
                                                    child: Text( item[3],
                                                      style: TextStyle(color:Helper.textColorBlueH1,
                                                          fontFamily: "Kelvetica Nobis",
                                                          fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH13),),
                                                  ),
                                                 false? Container(
                                                    //width: MQ_Width*0.50,
                                                    child: Text( '${item[3]??''}',
                                                      style: TextStyle(color:Color(Helper.textColorBlackH2),
                                                          fontFamily: "Kelvetica Nobis",
                                                          fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH15),),
                                                  ):Container(),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              margin: EdgeInsets.only(right: 5),
                                              child: Icon(Icons.arrow_forward_ios,size: 24,color: Helper.textColorBlueH1.withOpacity(0.5),),
                                            )


                                            /*SizedBox(
                                              height: MQ_Height*0.02,
                                            ),*/




//                    action != Action.ActivityWall
//                        ? getRowItem(
//                            nDataList.members.toString(),
//                            AppLocalizations.of(context).translate("Members"),
//                          )
//                        : Container(),
                                          ],
                                        ),
                                    ),
                                  Container(
                                       // alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomLeft,

                                          colors: [
                                            // Color(0XFF8134AF),
                                            // Color(0XFFDD2A7B),
                                            // Color(0XFFFEDA77),
                                            // Color(0XFFF58529),
                                            //Colors.blue.withOpacity(0.5),
                                            //Colors.blue.withOpacity(0.5),
                                            Color(0xfffb4592).withOpacity(0.5),
                                            Colors.blue.withOpacity(0.5),

                                          ],
                                        ),
                                        shape: BoxShape.circle
                                    ),
                                        child: Container(
                                          margin: EdgeInsets.all(3),
                                          child: ClipOval(
                                            child: Material(
                                             // color:Helper.inIconCircleBlueColor1, // Button color
                                              child: InkWell(
                                                splashColor: Helper.inIconCircleBlueColor1, // Splash color
                                                onTap: () {
                                                  /* Navigator.pushNamed(context, Constant.ChatUserDetail,
                                                    arguments: {"user_id": chat_item.user_id, "type": "3"});*/
                                                },
                                                child: SizedBox(width: 60, height: 60,
                                                    child:Image(image: item[14]!= null ||item[14]?NetworkImage(item[14],scale: 1.0):const AssetImage('assest/images/user2.png'),
                                                    fit: BoxFit.cover,)
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    )


                                  ],
                                ),
                              ),
                                      );
                            },
                          ),
                        ),
                        // SizedBox(height: 22,),

                        false?Container(
                          alignment: Alignment.bottomCenter,
                          margin:  EdgeInsets.only(left:MQ_Width *0.06,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: MQ_Height * 0.01 ),
                          padding: EdgeInsets.only(bottom: 5),
                          height: 60,
                          width: MQ_Width*0.30,
                          decoration: BoxDecoration(
                            color: Color(Helper.ButtonBorderPinkColor),
                            border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FlatButton(
                            onPressed: ()async{
                              Navigator.of(context).pop();


                            },
                            child: Text(
                              // isLocationEnabled?'CLOSE':'OPEN',
                              'Close',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH11,fontWeight:Helper.textFontH5),
                            ),
                          ),
                        ):Container(),

                      ],
                    ),
                  ),

                  true?Positioned(
                    //  left:275, //Helper.padding,
                    // right:-6,// Helper.padding,
                      top: 15,

                      child: false? Container(
                        alignment: Alignment.bottomCenter,
                        margin:  EdgeInsets.only(left:MQ_Width *0.02,right: MQ_Width * 0.02,top: MQ_Height * 0.02,bottom: MQ_Height * 0.01 ),
                        padding: EdgeInsets.only(bottom: 5),
                        height: 60,
                        width: MQ_Width*0.30,
                        decoration: BoxDecoration(
                          color: Color(Helper.ButtonBorderPinkColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FlatButton(
                          onPressed: ()async{
                            Navigator.of(context).pop();


                          },
                          child: Text(
                            // isLocationEnabled?'CLOSE':'OPEN',
                            /* AppLocalizations.of(context)
                                .translate("Confirm")
                                .toUpperCase(),*/
                            'Close'.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH11,fontWeight:Helper.textFontH5),
                          ),
                        ),
                      ):
                      InkWell(
                        child: Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(top: 10,),
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(color:Color(Helper.inBackgroundColor1),width: 3),
                              borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                   // Color(0xfff16cae).withOpacity(0.8),
                                    Color(0xff3f86c6),
                                    Color(0xff3f86c6),
                                  ],
                                )
                            ),
                            child: Icon(Icons.close,color: Colors.white,size:22,)),
                        onTap: (){
                          Navigator.pop(context,1);
                        },
                      )):Container(),

                ],),
            ),
          );
        });
  }


  Widget _widgetcountPeople2(){
     String image1;
     String image2;
      for(int i=0;i<subscriberlist.length;i++){
        if(i==0){
          var eachItem = subscriberlist[i] as Map;
          var item     = eachItem.values.toList();
          print(item);
          print('_widgetcountPeople2 item[14] imag1 =====${item[14]}');
          image1=item[14];
        }
        if(i==1){
          var eachItem = subscriberlist[i] as Map;
          var item     = eachItem.values.toList();
          print(item);
          print('_widgetcountPeople2 item[14] imag2  =====${item[14]}');
          image2=item[14];
        }
      }
    return false?ListView.builder(
      shrinkWrap: true,
      itemCount: subscriberlist.length,
      itemBuilder: (context, i) {
        var eachItem = subscriberlist[i] as Map;
        var item     = eachItem.values.toList();
        print(item);
        print('_widgetcountPeople2 item[14]  =====${item[14]}');
        return  Stack(
            alignment: Alignment.topLeft,
            children : [
              /*Container(
                  alignment: Alignment.centerLeft,

                  width: 50.0,
                  height: 50.0,
                  child:CircleAvatar(
                    radius: 17,
                    backgroundColor: Custom_color.GreyLightColor,
                    child:Image(
                      image: AssetImage(
                          "assest/images/pin.png"),
                      color: Custom_color.WhiteColor,
                      width: 18,
                      height: 18,
                    ),
                  )
              ),*/
              i==1?Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 25),
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(
                  color: Custom_color
                      .PlacholderColor,
                  image: new DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        profile_image),
                  ),
                  shape: BoxShape.circle,
                ),
              ):Container(),

            ]);
      },
    ):
    Stack(
        alignment: Alignment.topLeft,
        children : [
          Container(
            alignment: Alignment.centerLeft,
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              color: Custom_color
                  .PlacholderColor,
              image: new DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    image1,scale: 1.0),
              ),
              shape: BoxShape.circle,
            ),
          ),
          image2!=null? Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 25),
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              color: Custom_color
                  .PlacholderColor,
              image: new DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    image2,scale: 1.0),
              ),
              shape: BoxShape.circle,
            ),
          ):Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 25),
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              color: Custom_color
                  .PlacholderColor,
              image: new DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assest/images/user2.png")
              ),
              shape: BoxShape.circle,
            ),
          ),

        ]);
  }

  //===================== Broadcast Show Alert ================


  Future<void> _showDialogBroadcast(BuildContext context)async{


    await showDialog(context: context,
        builder: (BuildContext context){
          return Container(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Helper.avatarRadius),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Stack(
                children: [

                  Container(
                    padding: EdgeInsets.only(left: Helper.padding,top: Helper.avatarRadius
                        + Helper.padding, right: Helper.padding,bottom: Helper.padding
                    ),
                    margin: EdgeInsets.only(top: Helper.avatarRadius),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Helper.padding),
                      /* boxShadow: [
                        BoxShadow(color: Colors.black,offset: Offset(0,10),
                            blurRadius: 10
                        ),
                      ]*/
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Text('Location',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                        SizedBox(height: MQ_Height*0.02,),
                        Container(
                          alignment: Alignment.center,
                          child: CustomWigdet.TextView(
                            // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                              overflow: true,
                              text: AppLocalizations
                                  .of(context)
                                  .translate(
                                  'Not enough Subscriber'),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH11,
                              fontWeight: Helper.textFontH4,
                              color: Helper.textColorBlueH1
                          ),
                        ),
                        SizedBox(height: MQ_Height*0.01,),
                        Container(
                          alignment: Alignment.center,
                          child: CustomWigdet.TextView(
                            // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                              overflow: true,
                              text: AppLocalizations
                                  .of(context)
                                  .translate(
                                  'No one has subscribed to your activity yet'),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH13,
                              fontWeight: Helper.textFontH5,
                              color: Color(Helper.textColorBlackH2),
                          ),
                        ),
                        SizedBox(height: MQ_Height*0.02,),

                        false?Container(
                          alignment: Alignment.bottomCenter,
                          margin:  EdgeInsets.only(left:MQ_Width *0.06,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: MQ_Height * 0.01 ),
                          padding: EdgeInsets.only(bottom: 5),
                          height: 60,
                          width: MQ_Width*0.30,
                          decoration: BoxDecoration(
                            color: Color(Helper.ButtonBorderPinkColor),
                            border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FlatButton(
                            onPressed: ()async{

                            },
                            child: Text(
                              // isLocationEnabled?'CLOSE':'OPEN',
                              'Ok',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH11,fontWeight:Helper.textFontH5),
                            ),
                          ),
                        ):Container(),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: 0,
                                    right: 0,
                                    top: MQ_Height * 0.02,
                                    bottom: 2),
                                height: 50,
                                width: MQ_Width*0.33,
                                decoration: BoxDecoration(
                                  color: Color(Helper.ButtonBorderPinkColor),
                                  border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FlatButton(
                                  onPressed: ()async{
                                   Navigator.pop(context,1);
                                  },
                                  child: Text(
                                    // isLocationEnabled?'CLOSE':'OPEN',
                                    AppLocalizations.of(context)
                                        .translate("Fine")
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                  ),
                                ),
                              ),
                            //  SizedBox(width: MQ_Width*0.01,),
                              false?Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: 0,
                                    right: 0,
                                    top: MQ_Height * 0.02,
                                    bottom:2),
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
                              ):Container(),



                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                      left: Helper.padding,
                      right: Helper.padding,

                      child: false?Container(
                        height: 150,
                        width: 150,
                        padding: EdgeInsets.all(15),
                        // margin: EdgeInsets.only(bottom: MQ_Height*0.05),

                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,

                              colors: [
                                // Color(0XFF8134AF),
                                // Color(0XFFDD2A7B),
                                // Color(0XFFFEDA77),
                                // Color(0XFFF58529),
                                Colors.blue.withOpacity(0.4),
                                Colors.blue.withOpacity(0.3),

                              ],
                            ),
                            shape: BoxShape.circle
                        ),
                        child: Container(
                          // margin: EdgeInsets.only(bottom: 15),

                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: Helper.avatarRadius,
                            child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(Helper.avatarRadius)),
                                child: Image(image: AssetImage("assest/images/map.png"),
                                )
                            ),
                          ),
                        ),
                      ):
                      CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.3),
                        radius: 55,
                        child: false?CircleAvatar(
                          radius: 45,
                          backgroundImage: image!=null?NetworkImage(image):AssetImage("assest/images/user2.png"),

                        ):Container(
                            margin: EdgeInsets.all(2),
                            height: 85,
                            width:85,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1000),

                              //shape: BoxShape.circle
                            ),
                            child: Icon(Icons.phonelink_erase_rounded,size: 45,)),
                      )),

                ],),
            ),
          );
        });
  }


  get _appbar {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0), // here the desired height
      child: AppBar(
        title: CustomWigdet.TextView(
            text: ('Activity'),
            //AppLocalizations.of(context).translate("Activity")
            textAlign: TextAlign.center,
            color: Custom_color.WhiteColor,
            fontFamily: "OpenSans Bold"),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30))),
        leading: InkWell(
          borderRadius: BorderRadius.circular(30.0),
          child: Icon(
            Icons.arrow_back,
            color: Custom_color.WhiteColor,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<https.Response> GetEventUser(String id) async {
    try {
      Map jsondata = {"event_id": id};
      String url = WebServices.GetEventByUser +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          profile_image = data["data"]["profile_img"];
          user_id = data["data"]["user_id"];
          age = data["data"]["age"];
          gender = data["data"]["gender"];
          activty_from = data["data"]["user"] + ",";
          storedata = data["data"];
          title = data["data"]["title"];
          image = data["data"]["image"];
          location = data["data"]["location"];
          interest = data["data"]["interest"];
          active = data["data"]["active"];
          interest_desp = data["data"]["interest_desp"];
          comment = data["data"]["comment"];
          start_time = data["data"]["start_time"];
          end_time = data["data"]["end_time"];
          t1 = data["data"]["startime"];
          t2 = data["data"]["endtime"];
          suscribedcount = data["data"]["suscribedcount"];
          
          List userlist = data["data"]["category"];


          if (userlist != null && userlist.isNotEmpty) {
            categroy_list =
                userlist.map<User>((i) => User.fromJson(i)).toList();
          }
          //  GetDate(end_time);

//          Navigator.pushNamed(
//            context,
//            Constant.ActivityRoute,
//          );
          setState(() {
            loading = true;
            subscriberlist= data["data"]["subscriberlist"];
          });
        }
        if (data["is_expire"] == Constant.Token_Expire) {
          UtilMethod.showSimpleAlert(
              context: context,
              heading: AppLocalizations.of(context).translate("Alert"),
              message: AppLocalizations.of(context).translate("Token Expire"));
        }
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future _GetSubscribe(BuildContext context) async {
    try {
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      Map<String, String> headers = {
        "Accept": "application/json",
        "Cache-Control": "no-cache"
      };
      Map jsondata = {"event_id": routeData["event_id"], "is_sub": "0"};
      print("-----jsondata-----" + jsondata.toString());
      String url = WebServices.GetSubscribe +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";

      print("-----url-----" + url.toString());
      var response = await https.post(
        Uri.parse(url),
        headers: headers,
        body: jsondata,
        encoding: Encoding.getByName("utf-8"),
      );
      print("respnse----" + response.body.toString());
      _hideProgress();
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          print("----inside status---");
          Navigator.of(context).pop();
          Navigator.pop(context, Constant.ActivityWall);
        } else {
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

  Future _GetSubscribeSecond(BuildContext context, String value) async {
    try {
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      Map<String, String> headers = {
        "Accept": "application/json",
        "Cache-Control": "no-cache"
      };
      Map jsondata = {
        "event_id": routeData["event_id"].toString(),
        "is_sub": value
      };
      print("-----jsondata-----" + jsondata.toString());
      String url = WebServices.GetSubscribe +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";

      print("-----url-----" + url.toString());
      var response = await https.post(
        Uri.parse(url),
        headers: headers,
        body: jsondata,
        encoding: Encoding.getByName("utf-8"),
      );
      print("respnse----" + response.body.toString());
      _hideProgress();
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          print("----inside status---");
         // FlutterToastAlert.flutterToastMSG('${data["message"] }', context);
          /*setState(() {
            _getUserDetails();
          });*/
         /* Navigator.pushReplacementNamed(
              context, Constant.NavigationRoute).then((value) =>  _getUserDetails());*/
          String Title="Instance";
          showSuccess(Title,data["message"]);


        } else {
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
  //============ new show Alert Info =================

  Future<void> showSuccess(String Title,var MSG)async{


        await showDialog(context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: ()async{
                  return Future.value(false);
                },
                child: Center(
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Helper.avatarRadius),
                      ),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [

                          Container(
                            padding: EdgeInsets.only(
                                left: Helper.padding,
                                //top: Helper.avatarRadius,//+ Helper.padding,
                                top: Helper.padding,
                                right: Helper.padding,
                                bottom: Helper.padding
                            ),
                            margin: EdgeInsets.only(top: Helper.avatarRadius),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(Helper.padding),
                              /*  boxShadow: [
                                  BoxShadow(color: Colors.black, offset: Offset(
                                      0, 10),
                                      blurRadius: 10
                                  ),
                                ]*/
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // Text('Location',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                                // SizedBox(height: MQ_Height * 0.05,),
                                /*Container(
                                  alignment: Alignment.center,
                                  //  margin: EdgeInsets.only(bottom: 30),
                                  child: CustomWigdet.TextView(
                                      text: Title,
                                      //AppLocalizations.of(context).translate("Create Activity"),
                                      fontFamily: "Kelvetica Nobis",
                                      fontSize: Helper.textSizeH7,
                                      fontWeight: Helper.textFontH4,
                                      color: Helper.textColorBlueH1
                                  ),
                                ),*/
                                SizedBox(height: MQ_Height * 0.02,),

                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: CustomWigdet.TextView(
                                    overflow: true,
                                    text:MSG,
                                    //AppLocalizations.of(context).translate("Create Activity"),
                                    fontFamily: "Kelvetica Nobis",
                                    fontSize: Helper.textSizeH12,
                                    fontWeight: Helper.textFontH5,
                                    textAlign: TextAlign.start,
                                    color: Custom_color.GreyLightColor,

                                  ),
                                ),
                                SizedBox(height: 22,),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(left: MQ_Width * 0.06,
                                      right: MQ_Width * 0.06,
                                      top: MQ_Height * 0.02,
                                      bottom: MQ_Height * 0.01),
                                  padding: EdgeInsets.only(bottom: 5),
                                  height: 60,
                                  width: MQ_Width * 0.30,
                                  decoration: BoxDecoration(
                                    color: Color(Helper.ButtonBorderPinkColor),
                                    border: Border.all(width: 0.5,
                                        color: Color(Helper.ButtontextColor)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: FlatButton(
                                    onPressed: () async {
                                     // Navigator.of(context).pop();
                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                          Constant.NavigationRoute,
                                          ModalRoute.withName(Constant.WelcomeRoute),
                                          arguments: {"index": 0,"index_home":0});

                                    },
                                    child: Text(
                                      AppLocalizations.of(context).translate("Ok"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(Helper.ButtontextColor),
                                          fontFamily: "Kelvetica Nobis",
                                          fontSize: Helper.textSizeH11,
                                          fontWeight: Helper.textFontH5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          false? Positioned(
                              left: Helper.padding,
                              right: Helper.padding,

                              child: false ? Container(
                                height: 150,
                                width: 150,
                                padding: EdgeInsets.all(15),
                                // margin: EdgeInsets.only(bottom: MQ_Height*0.05),

                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,

                                      colors: [
                                        // Color(0XFF8134AF),
                                        // Color(0XFFDD2A7B),
                                        // Color(0XFFFEDA77),
                                        // Color(0XFFF58529),
                                        Colors.blue.withOpacity(0.4),
                                        Colors.blue.withOpacity(0.3),

                                      ],
                                    ),
                                    shape: BoxShape.circle
                                ),
                                child: Container(
                                  // margin: EdgeInsets.only(bottom: 15),

                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: Helper.avatarRadius,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(Helper.avatarRadius)),
                                        child: Image(
                                          image: AssetImage("assest/images/map.png"),
                                        )
                                    ),
                                  ),
                                ),
                              ) :
                              CircleAvatar(
                                backgroundColor: Colors.blue.withOpacity(0.3),
                                radius: 75,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: AssetImage(
                                      "assest/images/info.png"),

                                ),
                              )):Container(),

                        ],),
                    ),
                  ),
                ),
              );
            });

  }


//  GetDate(String value) {
//    List<String> parts = value.split(" ");
//
//    end_time_first = parts[0];
//    end_time_second = parts[1];
////    print("-----part11-----"+part1.toString());
////    print("-----part--22---"+part2.toString());
//  }

  Future _GetActivityDelete(BuildContext context) async {
    print("-----inside---this--");
    try {
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      Map jsondata = {"event_id": routeData["event_id"].toString()};
      print("-----jsondata-----" + jsondata.toString());
      String url = WebServices.GetActivityDelete +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      Map<String, String> headers = {
        "Accept": "application/json",
        "Cache-Control": "no-cache"
      };

      print("-----url-----" + url.toString());
      var response = await https.post(
        Uri.parse(url),
        headers: headers,
        body: jsondata,
        encoding: Encoding.getByName("utf-8"),
      );
      print("respnse----" + response.body.toString());
      _hideProgress();
      if (response.statusCode == 200) {
        var bodydata = json.decode(response.body);
        if (bodydata["status"]) {
          print("-----inside varsion---------------");
          Navigator.of(context).pop();
          Navigator.pop(context, Constant.Activity);
        } else {
          if (bodydata["is_expire"] == Constant.Token_Expire) {
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

  String _getListcategroyitem(List<User> list) {
    StringBuffer value = new StringBuffer();
    List<User>.generate(list.length, (index) {
      {
        value.write(list[index].name);
        if ((list.length) == (index + 1)) {
        } else {
          value.write(", ");
        }
      }
    });

    //value.writeln()
    return !UtilMethod.isStringNullOrBlank(value.toString())
        ? value.toString()
        : "";
  }
  //=============== Old UI Delete Broadcast Dialog =============

  Future _asyncConfirmDialog1(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Dialog(
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
                        overflow: true,
                        text: AppLocalizations.of(context)
                            .translate("Are you sure want to delete activity"),
                        fontFamily: "OpenSans Bold",
                        color: Custom_color.BlackTextColor),
                  ),
                  Spacer(),
                  Column(
                    children: <Widget>[
                      Divider(
                        color: Custom_color.ColorDivider,
                        height: 1,
                      ),
                      IntrinsicHeight(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: CustomWigdet.FlatButtonSimple(
                                    onPress: () async {
                                      if (await UtilMethod
                                          .SimpleCheckInternetConnection(
                                              context, _scaffoldKey)) {
                                        print(
                                            "----get action--------" + action);
                                        action == Constant.Activity
                                            ? _GetActivityDelete(context)
                                            : _GetSubscribe(context);
                                      }
                                    },
                                    textAlign: TextAlign.center,
                                    text: AppLocalizations.of(context)
                                        .translate("Confirm")
                                        .toUpperCase(),
                                    textColor: Custom_color.BlueLightColor,
                                    fontFamily: "OpenSans Bold"),
                              ),
                            ),
                            VerticalDivider(
                              width: 1,
                              color: Custom_color.ColorDivider,
                            ),
                            Expanded(
                              child: Padding(
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
                                    textColor: Custom_color.BlueLightColor,
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
            ));
      },
    );
  }


  //=============== New UI Delete Broadcast Dialog =============
  Future<void> _asyncConfirmDialog(BuildContext context)async{


    await showDialog(context: context,
        builder: (BuildContext context){
          return Container(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Helper.avatarRadius),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Stack(
                children: [

                  Container(
                    padding: EdgeInsets.only(left: Helper.padding,top: Helper.avatarRadius
                        + Helper.padding, right: Helper.padding,bottom: Helper.padding
                    ),
                    margin: EdgeInsets.only(top: Helper.avatarRadius),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Helper.padding),
                      /* boxShadow: [
                        BoxShadow(color: Colors.black,offset: Offset(0,10),
                            blurRadius: 10
                        ),
                      ]*/
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Text('Location',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                        SizedBox(height: MQ_Height*0.05,),
                        /*Container(
                          alignment: Alignment.center,
                          child: CustomWigdet.TextView(
                            // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                              overflow: true,
                              text: AppLocalizations
                                  .of(context)
                                  .translate(
                                  'Not enough Subscriber'),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH11,
                              fontWeight: Helper.textFontH4,
                              color: Helper.textColorBlueH1
                          ),
                        ),*/
                        Container(
                          alignment: Alignment.center,
                          child: CustomWigdet.TextView(
                            // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                            overflow: true,
                            text: AppLocalizations
                                .of(context)
                                .translate(
                                'Are you sure want to delete activity'),
                            fontFamily: "Kelvetica Nobis",
                            fontSize: Helper.textSizeH13,
                            fontWeight: Helper.textFontH5,
                            color: Helper.textColorBlueH1,
                          ),
                        ),
                        SizedBox(height: MQ_Height*0.02,),

                        false?Container(
                          alignment: Alignment.bottomCenter,
                          margin:  EdgeInsets.only(left:MQ_Width *0.06,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: MQ_Height * 0.01 ),
                          padding: EdgeInsets.only(bottom: 5),
                          height: 60,
                          width: MQ_Width*0.30,
                          decoration: BoxDecoration(
                            color: Color(Helper.ButtonBorderPinkColor),
                            border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FlatButton(
                            onPressed: ()async{

                            },
                            child: Text(
                              // isLocationEnabled?'CLOSE':'OPEN',
                              'Ok',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH11,fontWeight:Helper.textFontH5),
                            ),
                          ),
                        ):Container(),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: 0,
                                    right: 0,
                                    top: MQ_Height * 0.02,
                                    bottom: 2),
                                height: 50,
                                width: MQ_Width*0.33,
                                decoration: BoxDecoration(
                                  color: Color(Helper.ButtonBorderPinkColor),
                                  border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FlatButton(
                                  onPressed: ()async{
                                    if (await UtilMethod
                                        .SimpleCheckInternetConnection(
                                        context, _scaffoldKey)) {
                                      print(
                                          "----get action--------" + action);
                                      action == Constant.Activity
                                          ? _GetActivityDelete(context)
                                          : _GetSubscribe(context);
                                    }
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
                                SizedBox(width: MQ_Width*0.01,),
                              true?Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: 0,
                                    right: 0,
                                    top: MQ_Height * 0.02,
                                    bottom:2),
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
                              ):Container(),



                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                      left: Helper.padding,
                      right: Helper.padding,

                      child: false?Container(
                        height: 150,
                        width: 150,
                        padding: EdgeInsets.all(15),
                        // margin: EdgeInsets.only(bottom: MQ_Height*0.05),

                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,

                              colors: [
                                // Color(0XFF8134AF),
                                // Color(0XFFDD2A7B),
                                // Color(0XFFFEDA77),
                                // Color(0XFFF58529),
                                Colors.blue.withOpacity(0.4),
                                Colors.blue.withOpacity(0.3),

                              ],
                            ),
                            shape: BoxShape.circle
                        ),
                        child: Container(
                          // margin: EdgeInsets.only(bottom: 15),

                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: Helper.avatarRadius,
                            child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(Helper.avatarRadius)),
                                child: Image(image: AssetImage("assest/images/map.png"),
                                )
                            ),
                          ),
                        ),
                      ):
                      CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.3),
                        radius: 55,
                        child: false?CircleAvatar(
                          radius: 45,
                          backgroundImage: image!=null?NetworkImage(image):AssetImage("assest/images/user2.png"),

                        ):Container(
                          margin: EdgeInsets.all(2),
                            height: 85,
                            width:85,
                            decoration: BoxDecoration(
                               color: Colors.white,
                                borderRadius: BorderRadius.circular(1000),

                                //shape: BoxShape.circle
                            ),
                            child: Icon(Icons.delete_forever,size: 45)),
                      )),

                ],),
            ),
          );
        });
  }




  Future _asyncViewImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Container(
                  child: Image.network(image),
                ),
                Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.highlight_off,
                        size: 30,
                        color: Custom_color.OrangeLightColor,
                      ),
                    ))
              ],
            ));
      },
    );
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

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

@immutable
class ClipShadowPath extends StatelessWidget {
  final Shadow shadow;
  final CustomClipper<Path> clipper;
  final Widget child;

  ClipShadowPath({
    @required this.shadow,
    @required this.clipper,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClipShadowShadowPainter(
        clipper: this.clipper,
        shadow: this.shadow,
      ),
      child: ClipPath(child: child, clipper: this.clipper),
    );
  }
}

class _ClipShadowShadowPainter extends CustomPainter {
  final Shadow shadow;
  final CustomClipper<Path> clipper;

  _ClipShadowShadowPainter({@required this.shadow, @required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = shadow.toPaint();
    var clipPath = clipper.getClip(size).shift(shadow.offset);
    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
