import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
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

import '../../utilmethod/helper.dart';

class AppSetting_Screen extends StatefulWidget {
  @override
  _AppSetting_ScreenState createState() => _AppSetting_ScreenState();
}

class _AppSetting_ScreenState extends State<AppSetting_Screen> {
  Size _screenSize;
  bool isSwitched_Miu = false;
  bool isSwitched_Messages = false;
  bool isSwitched_Like = false;
  bool isSwitched_Others = false;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ProgressDialog progressDialog;
  bool _visible;
  int miu, message, like, other_notification, distance_unit;
  String radioDistance = "", distance_name = "";
  String confirmQuestion="";
  List<User> fav_list = [];
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
  var routeData;
  var image;

  @override
  void initState() {
    _visible = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _GetInfo();
      }
    });
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    routeData = ModalRoute.of(context).settings.arguments;
    if(routeData!=null){
      image=routeData['image_user'];
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: _getAppbar,
      backgroundColor:Color(Helper.inBackgroundColor1),
      body:Stack(
        children: [
          //_widgetAppSetting()
          _widgetAppSettingNewUI()
        ],
      )
    );
  }


  //=================== Old App Setting Api ============
  Widget _widgetAppSetting(){
    return Visibility(
      visible: _visible,
      replacement: Center(
        child: CircularProgressIndicator(),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // CustomWigdet.TextView(
              //     overflow: true,
              //     text:
              //         AppLocalizations.of(context).translate("Notification"),
              //     fontFamily: "OpenSans Bold",
              //     color: Custom_color.BlueLightColor),
              // CustomWigdet.TextView(
              //     overflow: true,
              //     fontSize: 12,
              //     text:
              //         "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
              //         " Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat",
              //     color: Custom_color.GreyLightColor),
              Visibility(
                  visible: false,
                  child:Row(
                    children: <Widget>[
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context).translate("Hi"),
                          color: Custom_color.BlackTextColor),
                      Spacer(),
                      Switch(
                        value: isSwitched_Miu,
                        onChanged: (value) async {
                          isSwitched_Miu = value;
                          if (await UtilMethod.SimpleCheckInternetConnection(
                              context, _scaffoldKey)) {
                            _UpdatePrefrence();
                          }
                        },
                        activeTrackColor: Custom_color.BlueLightColor,
                        activeColor: Custom_color.BlueDarkColor,
                      )
                    ],
                  )),
              Visibility(
                  visible: false,
                  child:Row(
                    children: <Widget>[
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context).translate("Messages"),
                          color: Custom_color.BlackTextColor),
                      Spacer(),
                      Switch(
                        value: isSwitched_Messages,
                        onChanged: (value) async {
                          isSwitched_Messages = value;
                          if (await UtilMethod.SimpleCheckInternetConnection(
                              context, _scaffoldKey)) {
                            _UpdatePrefrence();
                          }
                        },
                        activeTrackColor: Custom_color.BlueLightColor,
                        activeColor: Custom_color.BlueDarkColor,
                      )
                    ],
                  )),
              Visibility(
                  visible: false,
                  child:Row(
                    children: <Widget>[
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context).translate("Likes"),
                          color: Custom_color.BlackTextColor),
                      Spacer(),
                      Switch(
                        value: isSwitched_Like,
                        onChanged: (value) async {
                          isSwitched_Like = value;
                          if (await UtilMethod.SimpleCheckInternetConnection(
                              context, _scaffoldKey)) {
                            _UpdatePrefrence();
                          }
                        },
                        activeTrackColor: Custom_color.BlueLightColor,
                        activeColor: Custom_color.BlueDarkColor,
                      )
                    ],
                  )),
              Row(
                children: <Widget>[
                  CustomWigdet.TextView(
                      text: AppLocalizations.of(context).translate("Notifications"),
                      color: Custom_color.BlackTextColor),
                  Spacer(),
                  Switch(
                    value: isSwitched_Others,
                    onChanged: (value) async {
                      isSwitched_Others = value;
                      if (await UtilMethod.SimpleCheckInternetConnection(
                          context, _scaffoldKey)) {
                        _UpdatePrefrence();
                      }},
                    activeTrackColor: Custom_color.BlueLightColor,
                    activeColor: Custom_color.BlueDarkColor,
                  )
                ],
              ),
              InkWell(
                onTap: () {
                  _asyncConfirmDistances(context);
                },
                child: Container(
                  width: _screenSize.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context).translate("Distance Units"),
                          fontFamily: "OpenSans Bold",
                          color: Custom_color.BlueLightColor),
                      SizedBox(
                        height: 10,
                      ),
                      CustomWigdet.TextView(
                          overflow: true,
                          text: distance_name,
                          fontSize: 12,
                          color: Custom_color.GreyLightColor),
                    ],
                  ),
                ),
              ),
              Divider(
                thickness: 0.5,
                height: 30,
              ),
              CustomWigdet.TextView(
                  overflow: true,
                  text: AppLocalizations.of(context).translate("Legal notices"),
                  fontFamily: "OpenSans Bold",
                  color: Custom_color.BlueLightColor),
              // SizedBox(
              //   height: 10,
              // ),
              // CustomWigdet.TextView(
              //     overflow: true,
              //     text: AppLocalizations.of(context)
              //         .translate("Terms and conditions of use"),
              //     color: Custom_color.BlackTextColor),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: (){
                  SessionManager.getString(Constant.Language_code)=="en"?
                  Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/en/data-protection/"}):
                  Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/datenschutz/"});
                },
                child: CustomWigdet.TextView(
                    overflow: true,
                    text: AppLocalizations.of(context).translate("Privacy policy"),
                    color: Custom_color.BlackTextColor),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: (){
                  SessionManager.getString(Constant.Language_code)=="en"?
                  Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url": "https://tellmelive.com/en/cookies/"}):
                  Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url" :"https://tellmelive.com/cookies/"});
                },
                child: CustomWigdet.TextView(overflow: true,
                    text: AppLocalizations.of(context).translate("Cookie policy"),
                    color: Custom_color.BlackTextColor),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: (){
                  _asyncUserDetailDialog(context);
                },
                child: CustomWigdet.TextView(
                    overflow: true,
                    text: AppLocalizations.of(context).translate("My data"),
                    color: Custom_color.BlackTextColor),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  _asyncConfirmDialog(context);
                },
                child: CustomWigdet.TextView(
                    overflow: true,
                    text: AppLocalizations.of(context).translate("Delete my account"),
                    color: Custom_color.BlackTextColor),
              ),
              Container(
                padding: EdgeInsets.only(top: 40, bottom: 24),
                child: Center(
                  // child: Text(
                  //   AppLocalizations.of(context).translate("MiuMiu"),
                  //   style: TextStyle(
                  //       color: Custom_color.GreyLightColor,
                  //       fontFamily: "Diamond Dust",
                  //       fontSize: 30.0,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  child: Container(
                      padding: const EdgeInsets.only(left:30.0,right: 30),
                      child: Image.asset("assest/images/tellme.png",)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //=================== New UI App Setting Api ============

  Widget _widgetAppSettingNewUI(){
    return Visibility(
      visible: _visible,
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
      child: SingleChildScrollView(
        child: Container(
          color: Color(Helper.inBackgroundColor1),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // CustomWigdet.TextView(
              //     overflow: true,
              //     text:
              //         AppLocalizations.of(context).translate("Notification"),
              //     fontFamily: "OpenSans Bold",
              //     color: Custom_color.BlueLightColor),
              // CustomWigdet.TextView(
              //     overflow: true,
              //     fontSize: 12,
              //     text:
              //         "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
              //         " Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat",
              //     color: Custom_color.GreyLightColor),
              Visibility(
                  visible: false,
                  child:Row(
                    children: <Widget>[
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context).translate("Hi"),
                          color: Custom_color.BlackTextColor),
                      Spacer(),
                      Switch(
                        value: isSwitched_Miu,
                        onChanged: (value) async {
                          isSwitched_Miu = value;
                          if (await UtilMethod.SimpleCheckInternetConnection(
                              context, _scaffoldKey)) {
                            _UpdatePrefrence();
                          }
                        },
                        activeTrackColor: Custom_color.BlueLightColor,
                        activeColor: Custom_color.BlueDarkColor,
                      )
                    ],
                  )),
              Visibility(
                  visible: false,
                  child:Row(
                    children: <Widget>[
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context).translate("Messages"),
                          color: Custom_color.BlackTextColor),
                      Spacer(),
                      Switch(
                        value: isSwitched_Messages,
                        onChanged: (value) async {
                          isSwitched_Messages = value;
                          if (await UtilMethod.SimpleCheckInternetConnection(
                              context, _scaffoldKey)) {
                            _UpdatePrefrence();
                          }
                        },
                        activeTrackColor: Custom_color.BlueLightColor,
                        activeColor: Custom_color.BlueDarkColor,
                      )
                    ],
                  )),
              Visibility(
                  visible: false,
                  child:Row(
                    children: <Widget>[
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context).translate("Likes"),
                          color: Custom_color.BlackTextColor),
                      Spacer(),
                      Switch(
                        value: isSwitched_Like,
                        onChanged: (value) async {
                          isSwitched_Like = value;
                          if (await UtilMethod.SimpleCheckInternetConnection(
                              context, _scaffoldKey)) {
                            _UpdatePrefrence();
                          }
                        },
                        activeTrackColor: Custom_color.BlueLightColor,
                        activeColor: Custom_color.BlueDarkColor,
                      )
                    ],
                  )),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: MQ_Width*0.02),
                    child: CustomWigdet.TextView(
                        text: AppLocalizations.of(context).translate("Notifications"),
                        color: Custom_color.BlackTextColor,
                      fontWeight: Helper.textFontH5,
                      fontSize: Helper.textSizeH10,),
                  ),
                  Spacer(),
                  Switch(
                    value: isSwitched_Others,
                    onChanged: (value) async {
                      isSwitched_Others = value;
                      if (await UtilMethod.SimpleCheckInternetConnection(
                          context, _scaffoldKey)) {
                        _UpdatePrefrence();
                      }},
                    activeTrackColor: Custom_color.BlueLightColor,
                    activeColor: Custom_color.BlueDarkColor,
                  )
                ],
              ),
              SizedBox(height: MQ_Height*0.04,),
              InkWell(
                onTap: () {
                  _asyncConfirmDistances(context);
                },
                child: Container(
                  width: _screenSize.width,
                  height: MQ_Height*0.10,
                  margin: EdgeInsets.only(left: MQ_Width*0.02,right: MQ_Width*0.02),
                  padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,

                  decoration: BoxDecoration(
                    color:Colors.white,
                    borderRadius: BorderRadius.circular(20),

                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context).translate("Distance Units"),
                          fontFamily: "OpenSans Bold",
                          color: Custom_color.BlueLightColor,
                        fontWeight: Helper.textFontH5,
                        fontSize: Helper.textSizeH13,),
                      SizedBox(
                        height: 10,
                      ),
                      CustomWigdet.TextView(
                          overflow: true,
                          text: distance_name,
                          fontWeight: Helper.textFontH5,
                          fontSize: Helper.textSizeH15,
                          color: Custom_color.GreyLightColor),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MQ_Height*0.03,),
              Container(
                width: MQ_Width,
                height: MQ_Height*0.26,
                margin: EdgeInsets.only(left: MQ_Width*0.02,right: MQ_Width*0.02),
                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,

                decoration: BoxDecoration(
                  color:Colors.white,
                  borderRadius: BorderRadius.circular(20),

                ),
                child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      margin: EdgeInsets.only(top: MQ_Height*0.01,bottom: MQ_Height*0.01),

                      child: false?CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context).translate("Legal notices"),
                          fontFamily: "OpenSans Bold",
                          color: Custom_color.BlueLightColor):
                      Text(AppLocalizations.of(context).translate("Legal notices"),
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                            fontFamily: "OpenSans Bold",
                            color: Custom_color.BlueLightColor,
                            fontWeight: Helper.textFontH5,
                          fontSize: Helper.textSizeH13,
                        ),),
                    ),

              // SizedBox(
              //   height: 10,
              // ),
              // CustomWigdet.TextView(
              //     overflow: true,
              //     text: AppLocalizations.of(context)
              //         .translate("Terms and conditions of use"),
              //     color: Custom_color.BlackTextColor),

              InkWell(
                onTap: (){
                  SessionManager.getString(Constant.Language_code)=="en"?
                  Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/en/data-protection/"}):
                  Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/datenschutz/"});
                },
                child: Container(
                  margin: EdgeInsets.only(top: MQ_Height*0.01,bottom: MQ_Height*0.01),
                  child: false?CustomWigdet.TextView(
                      overflow: true,
                      text: AppLocalizations.of(context).translate("Privacy policy"),
                      color: Custom_color.BlackTextColor):
                  Text(AppLocalizations.of(context).translate("Privacy policy"),
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontFamily: "OpenSans Bold",
                      color: Custom_color.BlackTextColor,
                      fontWeight: Helper.textFontH5,
                      fontSize: Helper.textSizeH13,
                    ),),
                ),
              ),

              InkWell(
                onTap: (){
                  SessionManager.getString(Constant.Language_code)=="en"?
                  Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url": "https://tellmelive.com/en/cookies/"}):
                  Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url" :"https://tellmelive.com/cookies/"});
                },
                child: Container(
                  margin: EdgeInsets.only(top: MQ_Height*0.01,bottom: MQ_Height*0.01),

                  child: false?CustomWigdet.TextView(overflow: true,
                      text: AppLocalizations.of(context).translate("Cookie policy"),
                      color: Custom_color.BlackTextColor):
                  Text(AppLocalizations.of(context).translate("Cookie policy"),
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontFamily: "OpenSans Bold",
                      color: Custom_color.BlackTextColor,
                      fontWeight: Helper.textFontH5,
                      fontSize: Helper.textSizeH13,
                    ),),
                ),
              ),

              InkWell(
                onTap: (){
                  _asyncUserDetailDialog(context);
                },
                child: Container(
                  margin: EdgeInsets.only(top: MQ_Height*0.01,bottom: MQ_Height*0.01),

                  child: false?CustomWigdet.TextView(
                      overflow: true,
                      text: AppLocalizations.of(context).translate("My data"),
                      color: Custom_color.BlackTextColor):
                  Text(AppLocalizations.of(context).translate("My data"),
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontFamily: "OpenSans Bold",
                      color: Custom_color.BlackTextColor,
                      fontWeight: Helper.textFontH5,
                      fontSize: Helper.textSizeH13,
                    ),),
                ),
              ),

              InkWell(
                onTap: () {
                  _asyncConfirmDialog(context);
                },
                child: Container(
                  margin: EdgeInsets.only(top: MQ_Height*0.01,bottom: MQ_Height*0.01),

                  child: false?CustomWigdet.TextView(
                      overflow: true,
                      text: AppLocalizations.of(context).translate("Delete my account"),
                      color: Custom_color.BlackTextColor):
                  Text(AppLocalizations.of(context).translate("Delete my account"),
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontFamily: "OpenSans Bold",
                      color: Custom_color.BlackTextColor,
                      fontWeight: Helper.textFontH5,
                      fontSize: Helper.textSizeH13,
                    ),),
                ),
              ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 40, bottom: 24),
                child: Center(
                  // child: Text(
                  //   AppLocalizations.of(context).translate("MiuMiu"),
                  //   style: TextStyle(
                  //       color: Custom_color.GreyLightColor,
                  //       fontFamily: "Diamond Dust",
                  //       fontSize: 30.0,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  child: Container(
                      padding: const EdgeInsets.only(left:30.0,right: 30),
                      child: Image.asset("assest/images/tellme.png",)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      //centerTitle: false,
      title: CustomWigdet.TextView(
          text: AppLocalizations.of(context).translate("App Settings"),
          color: Custom_color.BlueLightColor,
          textAlign: TextAlign.start,
          fontSize: Helper.textSizeH12,
          fontWeight: Helper.textFontH5,
          fontFamily: "OpenSans Bold"),
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
        child: false?Icon(
          Icons.arrow_back,
          color: Custom_color.BlueLightColor,
        ):Container(
          alignment: Alignment.centerLeft,
          /* decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Custom_color.GreyLightColor,
                                    offset: Offset(0,4),
                                    blurRadius: 5
                                )
                              ]
                          ),*/
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0,top: 5),
            child:  Container(
              child: SvgPicture.asset('assest/images_svg/back.svg',color: Custom_color.BlueLightColor,width: 20,height: 20,),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future _asyncUserDetailDialog(BuildContext context) async {
    const double padding = 16.0;
    const double avatarRadius = 36.0;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(padding),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Container(
                  width: _screenSize.width,
                  padding: EdgeInsets.only(
                    top: avatarRadius+padding,
                    bottom: padding,
                    left: padding,
                    right: padding,
                  ),
                  margin: EdgeInsets.only(top: avatarRadius),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(padding),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top:90.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assest/images/phone1.png",width: 14,height: 14,color: Custom_color.BlueSecondLightColor,),
                            SizedBox(width: 5,),
                            CustomWigdet.TextView(text: "${SessionManager.getString(Constant.Country_code)} ${SessionManager.getString(Constant.Mobile_no)}",color: Custom_color.BlueSecondLightColor,fontSize: 14)
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assest/images/mail.png",width: 12,height: 12,color:Custom_color.BlueSecondLightColor ,),
                            SizedBox(width: 5,),
                            CustomWigdet.TextView(text: SessionManager.getString(Constant.Email),color: Custom_color.BlueSecondLightColor,fontSize: 14)
                          ],
                        ),

                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:35.0),
                  child: ClipPath(
                      clipper: ClippingClass(),
                      child: Container(
                        width: _screenSize.width,
                        height: 120.0,
                        decoration: BoxDecoration(color: Custom_color.BlueLightColor,borderRadius: BorderRadius.only(topLeft: Radius.circular(padding),topRight: Radius.circular(padding)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Custom_color.BlueSecondLightColor,
                                Custom_color.BlueLightColor,
                              ]),),
                        child: Padding(
                          padding: const EdgeInsets.only(top:34.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            CustomWigdet.TextView(text: SessionManager.getString(Constant.Name),color: Custom_color.WhiteColor,fontSize: 18,fontFamily: "OpenSans Bold"),
                            SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assest/images/birthday.png",width: 12,height: 12,color: Custom_color.WhiteColor,),
                                SizedBox(width: 5,),
                                CustomWigdet.TextView(text: SessionManager.getString(Constant.Dob),color: Custom_color.WhiteColor,fontSize: 14)
                              ],
                            ),
                          ],),
                        ),
                      )),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child:  Container(
                      width: 70,
                        height: 70,
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                         shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(SessionManager.getString(Constant.Profile_img),scale: 1.0)
                          )
                        ),

                    ),
                  ),
                ),
              ],
            )
        );
      },
    );
  }
  //
  // Future _asyncUserDetailDialog(BuildContext context) async {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //           shape:
  //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //           child: Stack(
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.only(bottom: 30),
  //                 child: CircleAvatar(backgroundImage: NetworkImage(SessionManager.getString(Constant.Profile_img))),
  //               ),
  //               Container(
  //                 padding: EdgeInsets.all(16),
  //                // height: 150,
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: <Widget>[
  //
  //
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ));
  //     },
  //   );
  // }
//=================  Delete Account Dialog Old UI ========
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
                        textAlign: TextAlign.center,
                        overflow: true,
                        text: AppLocalizations.of(context)
                            .translate("Do you want to delete account"),
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
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                                  color: Color(0xff1b98ea),
                                ),
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: CustomWigdet.FlatButtonSimple(
                                    onPress: () {
                                   //   getLogout();
                                      Navigator.pop(context);
                                      confirmQuestion = "";
                                      _asyncConfirmDeletedQuestion(context);
                                    },
                                    textAlign: TextAlign.center,
                                    text: AppLocalizations.of(context)
                                        .translate("Confirm")
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
                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
                                  color: Color(0xfffa4491),
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
            ));
      },
    );
  }

//=================  Delete Account Dialog New UI ========

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
                        Container(
                          alignment: Alignment.center,
                          child: CustomWigdet.TextView(
                            // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                              overflow: true,
                              text:AppLocalizations.of(context).translate("Do you want to delete account"),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH11,
                              fontWeight: Helper.textFontH5,
                              color: Helper.textColorBlueH1
                          ),
                        ),
                        SizedBox(height: MQ_Height*0.02,),


                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    Navigator.pop(context);
                                    confirmQuestion = "";
                                    _asyncConfirmDeletedQuestion(context);
                                  },
                                  child: Text(
                                    // isLocationEnabled?'CLOSE':'OPEN',
                                    AppLocalizations.of(context)
                                        .translate("Yes")
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MQ_Width*0.01,
                              ),
                              Container(
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
                              ),



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
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage: image!=null?NetworkImage(image):AssetImage("assest/images/user2.png"),

                        ),
                      )),

                ],),
            ),
          );
        });
  }


  Future _asyncConfirmDeleted(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(fav_list.length, (index) {
                            var data = fav_list[index];
                            return ListTile(
                                title: new Row(
                                  children: <Widget>[
                                    new Expanded(child: new Text(data.title)),
                                    new Checkbox(
                                        value: data.ischeck,
                                        onChanged: (bool value) {
                                          setState(() {
                                            data.ischeck = value;
                                          });
                                        })
                                  ],
                                ));
                          }),
                        ),
                        Material(
                          borderRadius: BorderRadius.only(bottomLeft:Radius.circular(10),bottomRight: Radius.circular(10) ),
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _GetDeletedAccount();
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(bottomLeft:Radius.circular(10),bottomRight: Radius.circular(10) ),
                                  color:  Color(0xfffb4592),
                                ),
                                padding: EdgeInsets.all(10),
                                width: _screenSize.width,
                                child: CustomWigdet.TextView(
                                  textAlign: TextAlign.center,
                                  text: AppLocalizations.of(context)
                                      .translate("Submit"),
                                  color: Custom_color.WhiteColor,
                                  fontFamily: "OpenSans Bold",
                                ),
                              )),
                        )
//                    CustomWigdet.RoundRaisedButton(
//                        onPress: () {},
//                        text: AppLocalizations.of(context).translate("Submit"),
//                        textColor: Custom_color.WhiteColor,
//                        fontFamily: "OpenSans Bold",
//                        bgcolor: Custom_color.BlueLightColor),
                      ],
                    )));
          },
        );
      },
    );
  }

  Future _asyncConfirmDistances(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                //  height: 150,
                  child: Column(mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RadioListTile(
                        dense: true,
                        groupValue: radioDistance,
                        title: CustomWigdet.TextView(
                            text:
                                AppLocalizations.of(context).translate("Miles"),
                            color: Custom_color.BlackTextColor),
                        value: Constant.Miles,
                        onChanged: (val) async {
                          if (await UtilMethod.SimpleCheckInternetConnection(
                          context, _scaffoldKey)) {
                            setState(() {
                              radioDistance = val;
                              _UpdatePrefrence();
                            });
                          }

                        },
                      ),
                      RadioListTile(
                        dense: true,
                        groupValue: radioDistance,
                        title: CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("Kilometers"),
                            color: Custom_color.BlackTextColor),
                        value: Constant.Kilometers,
                        onChanged: (val) async {
                          if (await UtilMethod.SimpleCheckInternetConnection(
                          context, _scaffoldKey)){
                            setState(() {
                              radioDistance = val;
                              _UpdatePrefrence();
                            });
                          }

                        },
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }


  Future _asyncConfirmDeletedQuestion(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  //  height: 150,
                  child: Column(mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RadioListTile(
                        dense: true,
                        groupValue: confirmQuestion,
                        title: CustomWigdet.TextView(
                            text:
                            AppLocalizations.of(context).translate("Temporally"),
                            color: Custom_color.BlackTextColor),
                        value: Constant.Temporally,
                        onChanged: (val) async {
                          if (await UtilMethod.SimpleCheckInternetConnection(
                              context, _scaffoldKey)) {
                            setState(() {
                              confirmQuestion = val;
                          //    _UpdatePrefrence();
                            });
                          }

                        },
                      ),
                      RadioListTile(
                        dense: true,
                        groupValue: confirmQuestion,
                        title: CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("Permanent"),
                            color: Custom_color.BlackTextColor),
                        value: Constant.Permanent,
                        onChanged: (val) async {
                          if (await UtilMethod.SimpleCheckInternetConnection(
                              context, _scaffoldKey)){
                            setState(() {
                              confirmQuestion = val;
                        //      _UpdatePrefrence();
                            });
                          }
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft: Radius.circular(10)),
                          color: Color(0xff1b98ea),
                        ),
                        width: _screenSize.width,
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0),
                        child: CustomWigdet.FlatButtonSimple(
                            onPress: () {
                              //   getLogout();
                              if(confirmQuestion.isNotEmpty){
                                  getUserList();
                                Navigator.pop(context);
                              _asyncConfirmDeleted(context);
                            }},
                            textAlign: TextAlign.center,
                            text: AppLocalizations.of(context)
                                .translate("Confirm")
                                .toUpperCase(),
                            textColor: Custom_color.WhiteColor,
                            fontFamily: "OpenSans Bold"),
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }



  Future _GetInfo() async {
    try {
      String url = WebServices.GetUserPrefrence +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          miu = data["data"]["miu"];
          message = data["data"]["message"];
          like = data["data"]["like"];
          other_notification = data["data"]["other_notification"];
          distance_unit = data["data"]["distance_unit"];



          isSeletedDistance(distance_unit);
          isSeletedMiu(miu);
          isSeletedOthers(other_notification);
          isSeletedLike(like);
          isSeletedOthers(other_notification);
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

        setState(() {
          _visible = true;
        });
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future<https.Response> _GetDeletedAccount() async {
    try {
      var check = false;
    StringBuffer value = new StringBuffer();
    List<User>.generate(fav_list.length, (index) {
      if (fav_list[index].ischeck) {
        if (check) {
          value.write(", ");
        } else {
          check = true;
        }
        value.write(fav_list[index].title);
      }
    });

      _showProgress(context);
      Map jsondata = {
        "reason": value.toString(),
      };
      print("------jsondata------" + jsondata.toString());
      String url;
      if(confirmQuestion=="2"){
      url =  WebServices.GetDeletedAccount + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      }else {
        url =  WebServices.GetDeactivate + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      }
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          getLogout();

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

  Future<https.Response> _UpdatePrefrence() async {
    try {
      _showProgress(context);
      Map jsondata = {
        "miu": !isSwitched_Miu ? "0" : "1",
        "message": !isSwitched_Messages ? "0" : "1",
        "other_notification": !isSwitched_Others ? "0" : "1",
        "like": !isSwitched_Like ? "0" : "1",
        "distance_unit": radioDistance
      };
      print("------jsondata------" + jsondata.toString());
      String url = WebServices.GetUpdatePrefrence +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          miu = data["data"]["miu"];
          message = data["data"]["message"];
          like = data["data"]["like"];
          other_notification = data["data"]["other_notification"];
          distance_unit = data["data"]["distance_unit"];



          isSeletedDistance(distance_unit);
          isSeletedMiu(miu);
          isSeletedOthers(other_notification);
          isSeletedLike(like);
          isSeletedOthers(other_notification);
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"]);
          setState(() {});
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

  getLogout() {
    SessionManager.setString(Constant.Token, "");
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constant.LoginRoute,
      (Route<dynamic> route) => false,
    );
  }

  isSeletedMiu(int value) {
    if (value == 0) {
      isSwitched_Miu = false;
    } else {
      isSwitched_Miu = true;
    }
  }

  isSeletedDistance(int value) {
    if (value == 0) {
      radioDistance = Constant.Kilometers;
      distance_name = AppLocalizations.of(context).translate("Kilometers");
    } else {
      radioDistance = Constant.Miles;
      distance_name = AppLocalizations.of(context).translate("Miles");
    }
  }

  isSeletedMessages(int value) {
    if (value == 0) {
      isSwitched_Messages = false;
    } else {
      isSwitched_Messages = true;
    }
  }

  isSeletedLike(int value) {
    if (value == 0) {
      isSwitched_Like = false;
    } else {
      isSwitched_Like = true;
    }
  }

  isSeletedOthers(int value) {
    if (value == 0) {
      isSwitched_Others = false;
    } else {
      isSwitched_Others = true;
    }
  }

   getUserList(){
    if (fav_list != null && !fav_list.isEmpty) {
      fav_list.clear();
    }
    fav_list.add(User(user_id: 1,title: "${AppLocalizations.of(context).translate("Too busy")}",ischeck: false));
    fav_list.add(User(user_id: 2,title: AppLocalizations.of(context).translate("Can‘t find people to follow"),ischeck: false));
    fav_list.add(User(user_id: 3,title: AppLocalizations.of(context).translate("Privacy concerns"),ischeck: false));
    fav_list.add(User(user_id: 4,title: AppLocalizations.of(context).translate("Found someone"),ischeck: false));
    fav_list.add(User(user_id: 5,title: AppLocalizations.of(context).translate("Others"),ischeck: false));
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

class ClippingClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height,
    );
    path.quadraticBezierTo(
      size.width - (size.width / 4),
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
