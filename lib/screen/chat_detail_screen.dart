import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/activity_holder.dart';
import 'package:miumiu/screen/holder/user_event.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/helper.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

class ChatDetail extends StatefulWidget {
  @override
  _ChatDetailState createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  Size _screenSize;
  var routeData;
  int _current = 0;
  ProgressDialog progressDialog;
  List<dynamic> images = [];
  List<Activity_holder> activitylist = [];
  bool loading;
  String profileImages = "";
  String profilename = "";
  int match_percent, miu, prof_message;
  String professional_interest_id;
  String txt;
  String messageEnglish = "I have professional interest let's get in touch";
  String messageGerman = "Ich habe berufliche Interessen. Lass uns gerne sprechen" ;

  var facebook, twitter, instagram, tiktok, linkedin;
  int you_liked, liked_you , ignored;
  int gender;
  String prof_interest,about_me;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var interest;
  List<UserEvent> bylist_activitylike = [];
  List<UserEvent> bylist_activitycreate = [];
  bool joined_expand;
  bool create_expand;
  bool showLoading;
  bool fullScreen;
  var MQ_Height;
  var MQ_Width;
  String User_imageUrl=null;

  List<Color> _kDefaultRainbowColors = const [
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.pinkAccent,
    Colors.pink,
    Colors.pink,
    Colors.pinkAccent,

  ];

//  final List<String> images = [
//    'https://images.unsplash.com/photo-1586882829491-b81178aa622e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',
//    'https://images.unsplash.com/photo-1586871608370-4adee64d1794?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2862&q=80',
//    'https://images.unsplash.com/photo-1586901533048-0e856dff2c0d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
//    'https://images.unsplash.com/photo-1586902279476-3244d8d18285?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',
//    'https://images.unsplash.com/photo-1586943101559-4cdcf86a6f87?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1556&q=80',
//    'https://images.unsplash.com/photo-1586951144438-26d4e072b891?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
//    'https://images.unsplash.com/photo-1586953983027-d7508a64f4bb?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
//  ];

  @override
  void initState() {
    fullScreen = false;
    showLoading = false;
    joined_expand = false;
    create_expand = false;

    Future.delayed(Duration.zero, () {
      routeData = ModalRoute.of(context).settings.arguments;
      print("----route data----" + routeData.toString());
      _GetUserDetail(routeData["user_id"]);
    });
    loading = false;
    getUserdetails();
    super.initState();
  }
  getUserdetails(){
    setState(() {
      User_imageUrl = SessionManager.getString(Constant.Profile_img);
    });

  }

  @override
  Widget build(BuildContext context) {
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    _screenSize = MediaQuery.of(context).size;
    routeData = ModalRoute.of(context).settings.arguments;
    //gender !=null && gender==1 ? txt=  profilename.toUpperCase() + "  /  " + AppLocalizations.of(context).translate("Female") : txt= profilename.toUpperCase() + "  /  " + AppLocalizations.of(context).translate("Male");
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          Navigator.pop(context, true);
        },
        child: Scaffold(
          backgroundColor: Helper.inBackgroundColor,
          key: _scaffoldKey,
          body:Stack(
            children: [
             //_widgetPeopleDetails()
              _widgetPeopleDetailsNewUI()
            ],
          ) ,
        ),
      ),
    );
  }

  toggleFullScreen()
  {
      setState(() {
          fullScreen = !fullScreen;
      });
  }

  //============== Old Ui ======
  Widget _widgetPeopleDetails(){
    return Visibility(
        visible: loading,
        child: Container(
          padding: fullScreen ?  const EdgeInsets.only(bottom: 0) : const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: Color(int.parse(Constant.progressBg)),
                  valueColor: AlwaysStoppedAnimation<Color>(showLoading ? Color(int.parse(Constant.progressVl)) : Colors.transparent,),
                  minHeight:  2,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        alignment: fullScreen ?  Alignment.center : Alignment.bottomCenter,
                        children: [
                          Padding(
                            padding: fullScreen ?  const EdgeInsets.only(bottom: 0.0) : const EdgeInsets.only(bottom: 59.0),
                            child: InkWell(
                                onTap: () => {toggleFullScreen()},
                                child : Container(
                                    color : fullScreen ?  Colors.black : Colors.transparent,
                                    width: _screenSize.width,
                                    alignment: Alignment.center,
                                    height: fullScreen ? _screenSize.height : (_screenSize.height / 2 - 100),
                                    child: images.isNotEmpty
                                        ? CarouselSlider.builder(
                                      itemCount: images.length,
                                      options: CarouselOptions(
                                          height: _screenSize.height,
                                          autoPlay: images.length == 1
                                              ? false
                                              : true,
                                          viewportFraction: 1.0,
                                          // aspectRatio: 2.0,
                                          // enlargeCenterPage: true,
                                          onPageChanged:
                                              (index, reason) {
                                            setState(() {
                                              _current = index;
                                            });
                                          }),
                                      itemBuilder: (context, index) {
                                        return

                                          Container(
                                              alignment: Alignment.center,
                                              child: ClipRRect(
                                                  borderRadius: fullScreen ?  BorderRadius.all(Radius.circular(10.0)) : BorderRadius.all(Radius.circular(0.0)),
                                                  child : CustomWigdet
                                                      .GetImagesNetwork(
                                                    imgURL:
                                                    images[index],
                                                    boxFit:
                                                    fullScreen ? BoxFit.contain : BoxFit.cover,
                                                    width : fullScreen ? _screenSize.width : _screenSize.width,
                                                    height : fullScreen ? _screenSize.height : _screenSize.height,)));
                                      },
                                    )
                                        : Container(
                                      color:
                                      Custom_color.PlacholderColor,
                                      child: Center(
                                        child: CustomWigdet.TextView(
                                            text: AppLocalizations.of(
                                                context)
                                                .translate(
                                                "Currently there is no gallery"),
                                            color: Custom_color
                                                .BlackTextColor),
                                      ),
                                    ))),
                          ),
                          Positioned(
                              top: 10,
                              left: 10,
                              child: GestureDetector(
                                onTap: (){
                                  if(fullScreen)
                                    toggleFullScreen();
                                  else
                                    Navigator.pop(context);
                                },
                                child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Icon(Icons.arrow_back_ios,
                                        size: 15, color: Colors.blue)),
                              )),
                          Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: (){
                                  toggleFullScreen();
                                },
                                child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Image(
                                        image: AssetImage("assest/images/maximize.png"),
                                        width:15,
                                        height:15,
                                        color:Colors.blue
                                    )),
                              )),
                          fullScreen  ?
                          SizedBox.shrink() :
                          Image(
                            image: AssetImage("assest/images/curve.png"),
                          ),
                          fullScreen  ?
                          SizedBox.shrink() :
                          !UtilMethod.isStringNullOrBlank(profileImages)
                              ? Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: InkWell(
                                onTap: () {
                                  if (profileImages != null) {
                                    _asyncViewProfileDialog(
                                        context);
                                  }
                                },
                                child: CircularPercentIndicator(
                                  startAngle: 270.0,
                                  radius: 112.0,
                                  animation: true,
                                  animationDuration: 1000,
                                  lineWidth: 6.0,
                                  percent: match_percent == null
                                      ? 0.0
                                      : match_percent / 100,
                                  center: Container(
                                    height: 100.0,
                                    width: 100.0,
                                    decoration: BoxDecoration(
                                      color: Custom_color
                                          .PlacholderColor,
                                      image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            profileImages,scale: 1.0),
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  circularStrokeCap:
                                  CircularStrokeCap.butt,
                                  backgroundColor:
                                  Custom_color.WhiteColor,
                                  progressColor:
                                  match_percent == 100
                                      ? Color(0xfffb4592)
                                      : Color(0xff4974a8),
                                ),
                              ),
                            ),
                          )
                              : Container(),
                          fullScreen  ?
                          SizedBox.shrink() :
                          Positioned(
                            bottom: 110,
                            child: Container(
                              padding: EdgeInsets.only(
                                  top: 4, left: 14, right: 14, bottom: 4),
                              decoration: BoxDecoration(
                                color: match_percent == 100
                                    ? Color(0xfffb4592)
                                    : Color(0xff4974a8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CustomWigdet.TextView(
                                  text:
                                  "${match_percent}% ${AppLocalizations.of(context).translate("Match")}",
                                  fontSize: 12,
                                  color: Custom_color.WhiteColor),
                            ),
                          ),
                          Platform.isIOS
                              ? Positioned(
                              top: 0,
                              left: 0,
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: Custom_color
                                            .BlueLightColor,
                                        size: 20,
                                      ),
                                      onPressed: null)))
                              : Container()
                        ],
                      ),
                      fullScreen  ?
                      SizedBox.shrink() :
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(2),
                              width: _screenSize.width,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  CustomWigdet.TextView(
                                      textAlign: TextAlign.center,
                                      text: profilename.toUpperCase() +
                                          "  /  ",
                                      color: Custom_color.BlackTextColor,
                                      fontFamily: "Kelvetica Nobis",
                                      fontSize: 18),
                                  CustomWigdet.TextView(
                                      textAlign: TextAlign.center,
                                      text: gender != null && gender == 1
                                          ? AppLocalizations.of(context)
                                          .translate("Female")
                                          : AppLocalizations.of(context)
                                          .translate("Male"),
                                      color: Custom_color.GreyLightColor,
                                      fontFamily: "Kelvetica Nobis",
                                      fontSize: 14),
                                ],
                              )),
                          // CustomWigdet.TextView(
                          //     textAlign: TextAlign.center,
                          //     text: gender == null ? "" : gender,
                          //     color: Custom_color.GreyLightColor),
                          // Image.asset(gender!=null && gender==1? "assest/images/female1.png":"assest/images/male.png",width: 14,height: 14,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              facebook != null && facebook == "1"
                                  ? Container(
                                margin: EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Image.asset(
                                  "assest/images/fb_color.png",
                                  width: 16,
                                  height: 16,
                                ),
                              )
                                  : Container(),
                              twitter != null && twitter == "1"
                                  ? Container(
                                margin: EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Image.asset(
                                  "assest/images/twitter_color.png",
                                  width: 16,
                                  height: 16,
                                ),
                              )
                                  : Container(),
                              instagram != null && instagram == "1"
                                  ? Container(
                                margin: EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Image.asset(
                                  "assest/images/insta_color.png",
                                  width: 16,
                                  height: 16,
                                ),
                              )
                                  : Container(),
                              tiktok != null && tiktok == "1"
                                  ? Container(
                                margin: EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Image.asset(
                                  "assest/images/tik_tok_color.png",
                                  width: 16,
                                  height: 16,
                                ),
                              )
                                  : Container(),
                              linkedin != null && linkedin == "1"
                                  ? Container(
                                margin: EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Image.asset(
                                  "assest/images/linkedin_color.png",
                                  width: 16,
                                  height: 16,
                                ),
                              )
                                  : Container(),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 14, top: 10, right: 14, bottom: 40),
                            width: _screenSize.width,
                            //    padding: const EdgeInsets.only(
                            //      top: 10, bottom: 40),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Custom_color
                                              .GreyLightColor3,
                                          offset:
                                          Offset(1.0, 10.0), //(x,y)
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    constraints:BoxConstraints(minHeight: 100),
                                    child: Card(
                                        child:
                                        Stack(
                                          children: <Widget>[

                                            Positioned(
                                              top: -10,
                                              left: (SessionManager.getString(
                                                  Constant
                                                      .Language_code) ==
                                                  "en" ||
                                                  SessionManager.getString(
                                                      Constant
                                                          .Language_code) ==
                                                      "de")
                                                  ? null
                                                  : 10,
                                              right: (SessionManager.getString(
                                                  Constant
                                                      .Language_code) ==
                                                  "en" ||
                                                  SessionManager.getString(
                                                      Constant
                                                          .Language_code) ==
                                                      "de")
                                                  ? 10
                                                  : null,
                                              child:
                                              Container
                                                (
                                                width: 100,
                                                height: 90,
                                                alignment: Alignment.bottomCenter,
                                                child: Container(
                                                  margin: EdgeInsets.all(5),
                                                  height:70,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          4),
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              gender!=null && gender==1? "assest/images/woman_n.png":"assest/images/man_n.png"),

                                                          fit: BoxFit.contain)),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Padding(
                                                padding: (SessionManager.getString(
                                                    Constant
                                                        .Language_code) ==
                                                    "en" ||
                                                    SessionManager.getString(
                                                        Constant
                                                            .Language_code) ==
                                                        "de")
                                                    ? const EdgeInsets.only(
                                                    top: 5,
                                                    right: 135,
                                                    bottom: 5,
                                                    left: 15)
                                                    : const EdgeInsets.only(
                                                    top: 5,
                                                    right: 15,
                                                    bottom: 5,
                                                    left: 135),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    CustomWigdet.TextView(
                                                        text: AppLocalizations.of(
                                                            context)
                                                            .translate(
                                                            "About me"),
                                                        fontFamily:
                                                        "Kelvetica Nobis",
                                                        color: Color(0xff4974a8),
                                                        fontSize: 16),
                                                    Container(
                                                        width:double.infinity,
                                                        child :
                                                        CustomWigdet.TextView(
                                                            overflow: true,
                                                            text: about_me != null ? about_me : "",
                                                            fontSize: 14,
                                                            color: Custom_color
                                                                .GreyLightColor)),
                                                  ],
                                                ),
                                              ),
                                            )
//
                                          ],
                                        ))),
                                SizedBox(height:10),
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Custom_color.GreyLightColor3,
                                        offset: Offset(1.0, 10.0), //(x,y)
                                        blurRadius: 20.0,
                                      ),
                                    ],
                                  ),
                                  width: _screenSize.width,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: <Widget>[
                                      Container(
                                        constraints:
                                        BoxConstraints(maxHeight: 90),
                                        child: Card(
                                          elevation: 2,
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Container(),
                                              Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -5,
                                        left: (SessionManager.getString(
                                            Constant
                                                .Language_code) ==
                                            "en" ||
                                            SessionManager.getString(
                                                Constant
                                                    .Language_code) ==
                                                "de")
                                            ? 10
                                            : null,
                                        right: (SessionManager.getString(
                                            Constant
                                                .Language_code) ==
                                            "en" ||
                                            SessionManager.getString(
                                                Constant
                                                    .Language_code) ==
                                                "de")
                                            ? null
                                            : 10,
                                        child: Container(
                                          width: 90,
                                          height: 80,
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            margin: EdgeInsets.all(5),
                                            height:60,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    4),
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        "assest/images/give-love.png"),
                                                    fit: BoxFit.contain)),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Padding(
                                          padding: (SessionManager.getString(
                                              Constant
                                                  .Language_code) ==
                                              "en" ||
                                              SessionManager.getString(
                                                  Constant
                                                      .Language_code) ==
                                                  "de")
                                              ? const EdgeInsets.only(
                                              top: 5,
                                              right: 15,
                                              bottom: 5,
                                              left: 140)
                                              : const EdgeInsets.only(
                                              top: 5,
                                              right: 140,
                                              bottom: 5,
                                              left: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              CustomWigdet.TextView(
                                                  text: AppLocalizations
                                                      .of(context)
                                                      .translate(
                                                      "Interest_an"),
                                                  fontFamily:
                                                  "Kelvetica Nobis",
                                                  color:
                                                  Color(0xff4974a8),
                                                  fontSize: 16),
                                              CustomWigdet.TextView(
                                                  text: interest != null
                                                      ? _getInterest(
                                                      interest)
                                                      : "",
                                                  fontSize: 13,
                                                  color: Custom_color
                                                      .GreyLightColor),
                                            ],
                                          ),
                                        ),
                                      )
//
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Custom_color
                                              .GreyLightColor3,
                                          offset:
                                          Offset(1.0, 10.0), //(x,y)
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    constraints:BoxConstraints(minHeight: 100),
                                    child: Card(
                                        child:
                                        Stack(
                                          children: <Widget>[

                                            Positioned(
                                              top: -10,
                                              left: (SessionManager.getString(
                                                  Constant
                                                      .Language_code) ==
                                                  "en" ||
                                                  SessionManager.getString(
                                                      Constant
                                                          .Language_code) ==
                                                      "de")
                                                  ? null
                                                  : 10,
                                              right: (SessionManager.getString(
                                                  Constant
                                                      .Language_code) ==
                                                  "en" ||
                                                  SessionManager.getString(
                                                      Constant
                                                          .Language_code) ==
                                                      "de")
                                                  ? 10
                                                  : null,
                                              child:
                                              Container
                                                (
                                                width: 100,
                                                height: 90,
                                                alignment: Alignment.bottomCenter,
                                                child: Container(
                                                  margin: EdgeInsets.fromLTRB(5,10,5,5),
                                                  height:70,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          4),
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              "assest/images/lifestyle.png"),
                                                          fit: BoxFit.contain)),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Padding(
                                                padding: (SessionManager.getString(
                                                    Constant
                                                        .Language_code) ==
                                                    "en" ||
                                                    SessionManager.getString(
                                                        Constant
                                                            .Language_code) ==
                                                        "de")
                                                    ? const EdgeInsets.only(
                                                    top: 5,
                                                    right: 135,
                                                    bottom: 5,
                                                    left: 15)
                                                    : const EdgeInsets.only(
                                                    top: 5,
                                                    right: 15,
                                                    bottom: 5,
                                                    left: 135),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    CustomWigdet.TextView(
                                                        text: AppLocalizations.of(
                                                            context)
                                                            .translate(
                                                            "Activity describes most"),
                                                        fontFamily:
                                                        "Kelvetica Nobis",
                                                        color: Color(0xff4974a8),
                                                        fontSize: 16),
                                                    Container(
                                                        width:double.infinity,
                                                        child :
                                                        CustomWigdet.TextView(
                                                            overflow: true,
                                                            text: activitylist != null
                                                                ? _getListactiviyitem(
                                                                activitylist)
                                                                : "",
                                                            fontSize: 14,
                                                            color: Custom_color
                                                                .GreyLightColor)),
                                                  ],
                                                ),
                                              ),
                                            )
//
                                          ],
                                        ))),
                                SizedBox(
                                  height: 10,
                                ),
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Custom_color
                                                .GreyLightColor3,
                                            offset:
                                            Offset(1.0, 10.0), //(x,y)
                                            blurRadius: 20.0,
                                          ),
                                        ],
                                      ),
                                      constraints:
                                      BoxConstraints(maxHeight: 90),
                                      child: Card(
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Container(),
                                            Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      left: (SessionManager.getString(
                                          Constant
                                              .Language_code) ==
                                          "en" ||
                                          SessionManager.getString(
                                              Constant
                                                  .Language_code) ==
                                              "de")
                                          ? 10
                                          : null,
                                      right: (SessionManager.getString(
                                          Constant
                                              .Language_code) ==
                                          "en" ||
                                          SessionManager.getString(
                                              Constant
                                                  .Language_code) ==
                                              "de")
                                          ? null
                                          : 10,
                                      child: Container(
                                        width: 100,
                                        height: 90,
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          margin: EdgeInsets.all(5),
                                          height:70,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  4),
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "assest/images/handshake.png"),
                                                  fit: BoxFit.contain)),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Padding(
                                        padding: (SessionManager.getString(
                                            Constant
                                                .Language_code) ==
                                            "en" ||
                                            SessionManager.getString(
                                                Constant
                                                    .Language_code) ==
                                                "de")
                                            ? const EdgeInsets.only(
                                            top: 5,
                                            right: 15,
                                            bottom: 5,
                                            left: 140)
                                            : const EdgeInsets.only(
                                            top: 5,
                                            right: 140,
                                            bottom: 5,
                                            left: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            CustomWigdet.TextView(
                                                overflow: true,
                                                text: AppLocalizations.of(
                                                    context)
                                                    .translate(
                                                    "Professional interest"),
                                                fontFamily:
                                                "Kelvetica Nobis",
                                                color: Color(0xff4974a8),
                                                fontSize: 16),
                                            CustomWigdet.TextView(
                                                overflow: true,
                                                text: prof_interest != ""
                                                    ? prof_interest
                                                    : "No professional Interest",
                                                fontSize: 14,
                                                color: Custom_color
                                                    .GreyLightColor),
                                          ],
                                        ),
                                      ),
                                    )
//
                                  ],
                                ),
                              ],
                            ),
                          ),
                          bylist_activitylike != null &&
                              bylist_activitylike.isNotEmpty
                              ? Padding(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 14.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    elevation: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          alignment:
                                          Alignment.centerRight,
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets
                                                  .only(
                                                  left: 10.0,
                                                  top: 14,
                                                  right: 10,
                                                  bottom: 14),
                                              color: Custom_color
                                                  .GreyLightColor2,
                                              width:
                                              _screenSize.width,
                                              child: CustomWigdet
                                                  .TextView(
                                                text: AppLocalizations
                                                    .of(context)
                                                    .translate(
                                                    "Activity Joined"),
                                                color: Custom_color
                                                    .BlackTextColor,
                                                fontFamily:
                                                "OpenSans Bold",
                                              ),
                                            ),
                                            Positioned(
                                              right: 10,
                                              child: Image.asset(
                                                "assest/images/acting.png",
                                                width: 30,
                                                height: 30,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: List.generate(
                                              bylist_activitylike
                                                  .length, (index) {
                                            return InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context,
                                                    Constant
                                                        .ActivityUserDetail,
                                                    arguments: {
                                                      "event_id": bylist_activitylike[
                                                      index]
                                                          .id
                                                          .toString(),
                                                      "isSub": int.parse(
                                                          bylist_activitylike[
                                                          index]
                                                              .is_subs)
                                                    }).then(
                                                        (value) {
                                                      if (value !=
                                                          null &&
                                                          value) {
                                                        _GetUserDetail(
                                                            routeData[
                                                            "user_id"]);
                                                      }
                                                    });
                                              },
                                              child: Container(
                                                  width: _screenSize
                                                      .width,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color(
                                                                0xff23b8f2),
                                                            Color(
                                                                0xff1b5dab)
                                                          ],
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter)),
                                                  child: !joined_expand
                                                      ? index < 2
                                                      ? Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: CustomWigdet.TextView(text: bylist_activitylike[index].title, color: Custom_color.WhiteColor),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 16,
                                                              color: Custom_color.WhiteColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        height: 1,
                                                        thickness: 0.5,
                                                        color: Custom_color.WhiteColor,
                                                      )
                                                    ],
                                                  )
                                                      : Container()
                                                      : Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.all(10.0),
                                                        child:
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: CustomWigdet.TextView(text: bylist_activitylike[index].title, color: Custom_color.WhiteColor),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 16,
                                                              color: Custom_color.WhiteColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        height:
                                                        1,
                                                        thickness:
                                                        0.5,
                                                        color:
                                                        Custom_color.WhiteColor,
                                                      )
                                                    ],
                                                  )),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                bylist_activitylike != null &&
                                    bylist_activitylike.length >
                                        2
                                    ? Positioned(
                                    right: 10,
                                    bottom: 0,
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            joined_expand =
                                            !joined_expand;
                                          });
                                        },
                                        child: Image.asset(
                                          !joined_expand
                                              ? "assest/images/plus.png"
                                              : "assest/images/minus.png",
                                          width: 36,
                                          height: 36,
                                        )))
                                    : Container(),
                              ],
                            ),
                          )
                              : Container(),
                          bylist_activitycreate != null &&
                              bylist_activitycreate.isNotEmpty
                              ? Padding(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, top: 5),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 17.0),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          alignment:
                                          Alignment.centerRight,
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets
                                                  .only(
                                                  left: 10.0,
                                                  top: 14,
                                                  right: 10,
                                                  bottom: 14),
                                              color: Custom_color
                                                  .GreyLightColor2,
                                              width:
                                              _screenSize.width,
                                              child: CustomWigdet
                                                  .TextView(
                                                text: AppLocalizations
                                                    .of(context)
                                                    .translate(
                                                    "Activity Created"),
                                                color: Custom_color
                                                    .BlackTextColor,
                                                fontFamily:
                                                "OpenSans Bold",
                                              ),
                                            ),
                                            Positioned(
                                              right: 10,
                                              child: Image.asset(
                                                "assest/images/acting.png",
                                                width: 30,
                                                height: 30,
                                                color: Custom_color
                                                    .WhiteColor,
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: List.generate(
                                              bylist_activitycreate
                                                  .length, (index) {
                                            return InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context,
                                                    Constant
                                                        .ActivityUserDetail,
                                                    arguments: {
                                                      "event_id": bylist_activitycreate[
                                                      index]
                                                          .id
                                                          .toString(),
                                                      "isSub": int.parse(
                                                          bylist_activitycreate[
                                                          index]
                                                              .is_subs)
                                                    }).then(
                                                        (value) {
                                                      if (value !=
                                                          null &&
                                                          value) {
                                                        _GetUserDetail(
                                                            routeData[
                                                            "user_id"]);
                                                      }
                                                    });
                                              },
                                              child: Container(
                                                  width: _screenSize
                                                      .width,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color(
                                                                0xff23b8f2),
                                                            Color(
                                                                0xff1b5dab)
                                                          ],
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter)),
                                                  child: !create_expand
                                                      ? index < 2
                                                      ? Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: CustomWigdet.TextView(text: bylist_activitycreate[index].title, color: Custom_color.WhiteColor),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 16,
                                                              color: Custom_color.WhiteColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        height: 1,
                                                        thickness: 0.5,
                                                        color: Custom_color.WhiteColor,
                                                      )
                                                    ],
                                                  )
                                                      : Container()
                                                      : Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.all(10.0),
                                                        child:
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: CustomWigdet.TextView(text: bylist_activitycreate[index].title, color: Custom_color.WhiteColor),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 16,
                                                              color: Custom_color.WhiteColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        height:
                                                        1,
                                                        thickness:
                                                        0.5,
                                                        color:
                                                        Custom_color.WhiteColor,
                                                      )
                                                    ],
                                                  )),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                bylist_activitycreate != null &&
                                    bylist_activitycreate
                                        .length >
                                        2
                                    ? Positioned(
                                    right: 10,
                                    bottom: 0,
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            create_expand =
                                            !create_expand;
                                          });
                                        },
                                        child: Image.asset(
                                          !create_expand
                                              ? "assest/images/plus.png"
                                              : "assest/images/minus.png",
                                          width: 36,
                                          height: 36,
                                        )))
                                    : Container(),
                              ],
                            ),
                          )
                              : Container()
                        ],
                      )
                    ],
                  ),
                ),
              ),
              fullScreen  ?
              SizedBox.shrink():
              Stack(
                  children : [
                    SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: Color(int.parse(Constant.progressBg)),
                        valueColor: AlwaysStoppedAnimation<Color>(showLoading ? Color(int.parse(Constant.progressVl)) : Colors.transparent),
                        minHeight:  2,
                      ),
                    ),
                    Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.only(top: 10),
                      child: Stack(children: [
                        professional_interest_id == "1" ||
                            professional_interest_id == "2" ||
                            professional_interest_id == "3"
                            ? GestureDetector(
                          onTap: () {
                            miu = 1;
                            senProfessionalMessage();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (miu != null && miu == 0)
                                    ?  Color(0xffAAAAAA)
                                    : Color(0xfff84390),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xffe4e9ef),
                                    offset: Offset(1.0, 1.0), //(x,y)
                                    blurRadius: 30.0,
                                  ),
                                ]),
                            padding: const EdgeInsets.only(
                                left: 30, top: 10, right: 30, bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Image.asset(
                                "assest/images/professionals.png",
                                width: 30,
                                color: Custom_color.WhiteColor,
                              ),
                            ),
                          ),
                        )
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                print("routedata :: "+routeData["type"]);
                                // if (routeData != null &&
                                //     routeData["type"] != null &&
                                //     routeData["type"] == "3") {
                                //   Navigator.pop(context);
                                // } else
                                    {
                                  //   _GetIgnore();
                                  _asyncDialogDislike(context);
                                }
                              },
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomRight: Radius.circular(30)),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffAAAAAA) ,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xffe4e9ef),
                                        offset: Offset(1.0, 1.0), //(x,y)
                                        blurRadius: 30.0,
                                      ),
                                    ]),
                                padding: const EdgeInsets.only(
                                    left: 30, top: 10, right: 30, bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Image.asset(
                                    "assest/images/dislike.png",
                                    width: 30,
                                    color: Custom_color.WhiteColor,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {

                                if (await UtilMethod
                                    .SimpleCheckInternetConnection(
                                    context, _scaffoldKey)) {
                                  if (routeData != null &&
                                      routeData["type"] != null) {
                                    print("youliked :: "+you_liked.toString());
                                    you_liked == 0
                                        ? _GetLikeUser(routeData["user_id"])
                                        : _asyncConfirmDialog(context);
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: you_liked == 1 ? Color(0xfff84390) : Color(0xffAAAAAA),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Custom_color.GreyLightColor3,
                                        offset: Offset(1.0, 1.0), //(x,y)
                                        blurRadius: 20.0,
                                      ),
                                    ]),
                                child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    // child: Icon(
                                    //   you_liked == 0
                                    //       ? Icons.favorite_border
                                    //       : Icons.favorite,
                                    //   color: Custom_color.RedColor,
                                    //   size: 30,
                                    // ),
                                    child: you_liked == 0 && liked_you == 0
                                        ? Icon(
                                      Icons.favorite,
                                      color: Custom_color.WhiteColor,
                                      size: 30,
                                    )
                                        : you_liked == 1 && liked_you == 0
                                        ? Icon(
                                      Icons.favorite_border,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                        : you_liked == 0 && liked_you == 1
                                        ? Icon(
                                      Icons.favorite,
                                      color:
                                      Custom_color.WhiteColor,
                                      size: 30,
                                    )
                                        : you_liked == 1 &&
                                        liked_you == 1
                                        ? Icon(
                                      Icons.favorite_border,
                                      color: Custom_color
                                          .WhiteColor,
                                      size: 30,
                                    )
                                        : Container()),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                if (await UtilMethod
                                    .SimpleCheckInternetConnection(
                                    context, _scaffoldKey)) {
                                  print("----------date time--------" +
                                      (DateTime.now().millisecondsSinceEpoch *
                                          1000)
                                          .toString());
                                  //     if (miu != null && miu == 0)
                                      {
                                    _GetMiu();
                                  }
                                }
                              },
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  bottomLeft: Radius.circular(30)),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (miu != null && miu == 0)
                                        ?  Color(0xffAAAAAA) : Color(0xfff84390),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Custom_color.GreyLightColor3,
                                        offset: Offset(1.0, 1.0), //(x,y)
                                        blurRadius: 20.0,
                                      ),
                                    ]),
                                padding: const EdgeInsets.only(
                                    left: 30, top: 10, right: 30, bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Image.asset(
                                    "assest/images/hand.png",
                                    width: 30,
                                    color: Custom_color.WhiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    )
                  ]),
            ],
          ),
        ));
  }

  //============== New Ui ======
  Widget _widgetPeopleDetailsNewUI(){
    return Visibility(
        visible: loading,
      replacement:Center(
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
        child: Container(
          color: Helper.inBackgroundColor,
          padding: fullScreen ?  const EdgeInsets.only(bottom: 0) : const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:BorderRadius.circular(1)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          false?Container(

                            padding: EdgeInsets.all(2),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 0.5,color: Colors.grey),

                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Color(0xffaeaeae),
                                      offset: Offset(1,10),
                                      blurRadius: 30
                                  )
                                ]
                            ),
                            width: 50,
                            height: 50,
                            child: User_imageUrl == null||User_imageUrl==""
//                            ? Image.asset(
//                                "assest/images/camera.png",
//                                color: Custom_color.GreyLightColor,
//                              )
                                ? Image(image: AssetImage("assest/images/user2.png"))
                                : CircleAvatar(
                              backgroundColor: Custom_color.WhiteColor,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(User_imageUrl,scale: 1.0),
                                backgroundColor: Colors.white,
                                radius: 90,
                              ),
                            ),
                          ):InkWell(
            onTap: (){
              if(fullScreen)
                toggleFullScreen();
              else
                Navigator.pop(context);
      },
      child: false?Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Custom_color.GreyLightColor,
                  offset: Offset(0,4),
                  blurRadius: 5
              )
            ]
        ),
        child: CircleAvatar(
          radius: 15,
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
                      padding: const EdgeInsets.only(left: 10.0,top: 0,right: 20),
                      child:  Container(
                        child: SvgPicture.asset('assest/images_svg/back.svg',color: Custom_color.BlueLightColor,width: 18,height: 18,),
                      ),
                    ),
                  ),

                ),
                          true?Container(
                            child: CustomWigdet.TextView(
                                textAlign: TextAlign.center,
                                text: AppLocalizations.of(context).translate("Profile"),
                                fontFamily: "Kelvetica Nobis",
                                color: Helper.textColorBlueH1,//Custom_color.BlackTextColor,
                                fontWeight: Helper.textFontH5,
                                fontSize:Helper.textSizeH11),
                          ):Container()
                        ],
                      ),
                    ),


                  ],
                ),
              ),
              SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: Color(int.parse(Constant.progressBg)),
                  valueColor: AlwaysStoppedAnimation<Color>(showLoading ? Color(int.parse(Constant.progressVl)) : Colors.transparent,),
                  minHeight:  2,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        alignment: fullScreen ?  Alignment.center : Alignment.bottomCenter,
                        children: [
                          Padding(
                            padding: fullScreen ?  const EdgeInsets.only(bottom: 0.0) : const EdgeInsets.only(bottom: 59.0),
                            child: InkWell(
                                onTap: () => {toggleFullScreen()},
                                child : Container(
                                    color : fullScreen ?  Colors.black : Colors.transparent,
                                    width: _screenSize.width,
                                    alignment: Alignment.center,
                                    height: fullScreen ? _screenSize.height : (_screenSize.height / 2 - 100),
                                    child: images.isNotEmpty
                                        ? CarouselSlider.builder(
                                      itemCount: images.length,
                                      options: CarouselOptions(
                                          height: _screenSize.height,
                                          autoPlay: images.length == 1
                                              ? false
                                              : true,
                                          viewportFraction: 1.0,
                                          // aspectRatio: 2.0,
                                          // enlargeCenterPage: true,
                                          onPageChanged:
                                              (index, reason) {
                                            setState(() {
                                              _current = index;
                                            });
                                          }),
                                      itemBuilder: (context, index) {
                                        return

                                          Container(
                                              alignment: Alignment.center,
                                              child: ClipRRect(
                                                  borderRadius: fullScreen ?  BorderRadius.all(Radius.circular(10.0)) : BorderRadius.all(Radius.circular(0.0)),
                                                  child : CustomWigdet
                                                      .GetImagesNetwork(
                                                    imgURL:
                                                    images[index],
                                                    boxFit:
                                                    fullScreen ? BoxFit.contain : BoxFit.cover,
                                                    width : fullScreen ? _screenSize.width : _screenSize.width,
                                                    height : fullScreen ? _screenSize.height : _screenSize.height,)));
                                      },
                                    )
                                        : Container(
                                      color:
                                      Custom_color.PlacholderColor,
                                      child: Center(
                                        child: CustomWigdet.TextView(
                                            text: AppLocalizations.of(
                                                context)
                                                .translate(
                                                "Currently there is no gallery"),
                                            color: Custom_color
                                                .BlackTextColor),
                                      ),
                                    ))),
                          ),
                          false?Positioned(
                              top: 10,
                              left: 10,
                              child: GestureDetector(
                                onTap: (){
                                  if(fullScreen)
                                    toggleFullScreen();
                                  else
                                    Navigator.pop(context);
                                },
                                child: Icon(Icons.arrow_back,
                                    size: 20, color: Colors.blue),
                              )):Container(),
                          Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: (){
                                  toggleFullScreen();
                                },
                                child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Image(
                                        image: AssetImage("assest/images/maximize.png"),
                                        width:15,
                                        height:15,
                                        color:Colors.blue
                                    )),
                              )),
                          fullScreen  ?
                          SizedBox.shrink() :
                          Image(
                            color: Helper.inBackgroundColor,
                            image: AssetImage("assest/images/curve.png"),
                          ),
                          fullScreen  ?
                          SizedBox.shrink() :
                          !UtilMethod.isStringNullOrBlank(profileImages)
                              ? Positioned.fill(

                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: InkWell(
                                onTap: () {
                                  if (profileImages != null) {
                                    _asyncViewProfileDialog(
                                        context);
                                  }
                                },
                                child: /*CircularPercentIndicator(
                                  startAngle: 270.0,
                                  radius: 112.0,
                                  animation: true,
                                  animationDuration: 1000,
                                  lineWidth: 6.0,
                                  percent: match_percent == null
                                      ? 0.0
                                      : match_percent / 100,
                                  center:*/Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,

                                          colors: [
                                            // Color(0XFF8134AF),
                                            // Color(0XFFDD2A7B),
                                            // Color(0XFFFEDA77),
                                            // Color(0XFFF58529),
                                            gender!=null && gender==1?  Color(0xfffb4592).withOpacity(0.3):Colors.blue.withOpacity(0.3),
                                            gender!=null && gender==1?  Color(0xfffb4592).withOpacity(0.3):Colors.blue.withOpacity(0.4),

                                          ],
                                        ),
                                        shape: BoxShape.circle
                                    ),

                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      height: 130.0,
                                      width: 130.0,
                                      decoration: BoxDecoration(
                                        color: Custom_color
                                            .PlacholderColor,
                                        image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              profileImages,scale: 1.0),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  /*circularStrokeCap:
                                  CircularStrokeCap.butt,
                                  backgroundColor:
                                  Custom_color.WhiteColor,
                                  progressColor:
                                  match_percent == 100
                                      ? Color(0xfffb4592)
                                      : Color(0xff4974a8),
                                ),*/
                              ),
                            ),
                          )
                              : Container(),
                          fullScreen  ?
                          SizedBox.shrink() :
                          false?Positioned(
                            bottom: 110,
                            child: Container(
                              padding: EdgeInsets.only(
                                  top: 4, left: 14, right: 14, bottom: 4),
                              decoration: BoxDecoration(
                                color: match_percent == 100
                                    ? Color(0xfffb4592)
                                    : Color(0xff4974a8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CustomWigdet.TextView(
                                  text:
                                  "${match_percent}% ${AppLocalizations.of(context).translate("Match")}",
                                  fontSize: 12,
                                  color: Custom_color.WhiteColor),
                            ),
                          ):Container(),
                         // Platform.isIOS
                           false ? Positioned(
                              top: 0,
                              left: 0,
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: Custom_color
                                            .BlueLightColor,
                                        size: 20,
                                      ),
                                      onPressed: null)))
                              : Container()
                        ],
                      ),
                      SizedBox(
                        height: MQ_Height*0.02,
                      ),

                      fullScreen  ?
                      SizedBox.shrink() :
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            color: Helper.inBackgroundColor,
                              padding: EdgeInsets.all(2),
                              width: _screenSize.width,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  CustomWigdet.TextView(
                                      textAlign: TextAlign.center,
                                      text: profilename.toUpperCase() +
                                          "  |  ",

                                      fontFamily: "Kelvetica Nobis",
                                      color: Helper.textColorBlueH1,//Custom_color.BlackTextColor,
                                      fontWeight: Helper.textFontH5,
                                      fontSize:Helper.textSizeH11),
                                 false? CustomWigdet.TextView(
                                      textAlign: TextAlign.center,
                                      text: gender != null && gender == 1
                                          ? AppLocalizations.of(context)
                                          .translate("Female")
                                          : AppLocalizations.of(context)
                                          .translate("Male"),
                                      color: Custom_color.GreyLightColor,
                                      fontFamily: "Kelvetica Nobis",
                                      fontSize: 14):
                                 Container(

                                     margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                     // width:18,
                                     // height: 40,
                                     /*decoration: BoxDecoration(
                        //  color:Colors.blue,
                          //borderRadius: BorderRadius.circular(30)

                        ),*/
                                     padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                     // child: CustomWigdet.TextView(
                                     //     text:
                                     //         gender != null ? _getGender(gender) : gender,
                                     //     textAlign: TextAlign.center,
                                     //     overflow: true,
                                     //     color: Custom_color.GreyLightColor),
                                     child:
                                     ClipOval(
                                       child: Material(
                                         color:gender!=null && gender==1? Color(0xfffb4592):Colors.blue.shade700,
                                         //Helper.inIconCircleBlueColor1, // Button color
                                         child: InkWell(
                                           splashColor: Helper.inIconCircleBlueColor1, // Splash color
                                           onTap: () {},
                                           child: SizedBox(width: 18, height: 18,
                                             child:Image.asset(gender!=null && gender==1? "assest/images/female1.png":"assest/images/male.png",
                                               width: 10,height: 10,color: Color(Helper.inIconWhiteColorH1),),
                                           ),
                                         ),
                                       ),
                                     )
                                 )
                                ],
                              )),
                          // CustomWigdet.TextView(
                          //     textAlign: TextAlign.center,
                          //     text: gender == null ? "" : gender,
                          //     color: Custom_color.GreyLightColor),
                          // Image.asset(gender!=null && gender==1? "assest/images/female1.png":"assest/images/male.png",width: 14,height: 14,),
                      //============ fb linkedin instagram ==
                          routeData["type"]=="4"? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              facebook != null && facebook == "1"
                                  ? Container(
                                margin: EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Image.asset(
                                  "assest/images/fb_color.png",
                                  width: 16,
                                  height: 16,
                                ),
                              )
                                  : Container(),
                              twitter != null && twitter == "1"
                                  ? Container(
                                margin: EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Image.asset(
                                  "assest/images/twitter_color.png",
                                  width: 16,
                                  height: 16,
                                ),
                              )
                                  : Container(),
                              instagram != null && instagram == "1"
                                  ? Container(
                                margin: EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Image.asset(
                                  "assest/images/insta_color.png",
                                  width: 16,
                                  height: 16,
                                ),
                              )
                                  : Container(),
                              tiktok != null && tiktok == "1"
                                  ? Container(
                                margin: EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Image.asset(
                                  "assest/images/tik_tok_color.png",
                                  width: 16,
                                  height: 16,
                                ),
                              )
                                  : Container(),
                              linkedin != null && linkedin == "1"
                                  ? Container(
                                margin: EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Image.asset(
                                  "assest/images/linkedin_color.png",
                                  width: 16,
                                  height: 16,
                                ),
                              )
                                  : Container(),
                            ],
                          ):Container(),
                         /* SizedBox(
                            height: 10,
                          ),*/

                          routeData["type"]=="4"?SizedBox(
                            height: MQ_Height*0.02,
                          ):Container(),
                          //=========== New UI Match Profile=======
                          routeData["type"]=="4"? Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                                height: MQ_Height*0.20,
                                decoration: BoxDecoration(
                                  color:Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),

                                ),

                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors.blue.withOpacity(0.3),
                                                    radius: 50,
                                                    child: CircleAvatar(
                                                      radius: 40,
                                                      backgroundImage: User_imageUrl!=null ?NetworkImage(User_imageUrl,scale: 1.0): AssetImage("assest/images/user2.png"),

                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MQ_Height*0.01,
                                                ),
                                                Container(
                                                  child: Text(AppLocalizations.of(context).translate("You"),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color:Helper.textColorBlueH1,
                                                        fontFamily: "Kelvetica Nobis",
                                                        fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),),
                                                ),

                                               /* Container(
                                                  width: 40,
                                                  height: 1,
                                                  color: Color(0xfffb4592),//Colors.purpleAccent,
                                                )*/
                                              ],
                                            ),
                                          ),



                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                false?Container(
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors.blue.withOpacity(0.3),
                                                    radius: 40,
                                                    child: CircleAvatar(
                                                      radius: 30,
                                                      backgroundImage: false ?NetworkImage('chatList.profile_img'): AssetImage("assest/images/user2.png"),

                                                    ),
                                                  ),
                                                ):Container(
                                                    child:CircularPercentIndicator(
                                                      startAngle: 270.0,
                                                      radius: 80.0,
                                                      animation: true,
                                                      animationDuration: 1000,
                                                      lineWidth: 12.0,
                                                      percent: match_percent == null
                                                          ? 0.0
                                                          : match_percent / 100,
                                                      center: false?Container(
                                                        height: 100.0,
                                                        width: 100.0,
                                                        decoration: BoxDecoration(
                                                          color: Custom_color
                                                              .PlacholderColor,
                                                          image: new DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: NetworkImage(
                                                                profileImages),
                                                          ),
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ):Container(
                                                          child:CustomWigdet
                                                              .TextView(
                                                            text: match_percent!=null?'${match_percent} %':'0%',
                                                            color: Custom_color.BlackTextColor,
                                                            fontFamily: "OpenSans Bold",
                                                            fontWeight: Helper.textFontH1,
                                                            fontSize: Helper.textSizeH14
                                                          ),
                                                      ),
                                                      circularStrokeCap:
                                                      CircularStrokeCap.butt,
                                                      backgroundColor:
                                                      Custom_color.WhiteColor,
                                                      progressColor:Color(0xfffb4592)
                                                     // match_percent == 100 ? Color(0xfffb4592) : Color(0xff4974a8),
                                                    ),
                                                ),
                                                SizedBox(
                                                  height: MQ_Height*0.01,
                                                ),
                                                Container(
                                                  child: Text(AppLocalizations.of(context).translate("Matching"),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color:Color(Helper.textColorBlackH2),
                                                        fontFamily: "Kelvetica Nobis",
                                                        fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH15),),
                                                ),

                                                /* Container(
                                                  width: 40,
                                                  height: 1,
                                                  color: Color(0xfffb4592),//Colors.purpleAccent,
                                                )*/
                                              ],
                                            ),
                                          ),



                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: CircleAvatar(
                                                    backgroundColor: //Color(0xfffb4592).withOpacity(0.3),
                                                    gender!=null && gender==1?  Color(0xfffb4592).withOpacity(0.3):Colors.blue.withOpacity(0.3),
                                                    radius: 50,
                                                    child: CircleAvatar(
                                                      radius: 40,
                                                      backgroundImage: profileImages!=null ?NetworkImage(profileImages,scale: 1.0): AssetImage("assest/images/user2.png"),

                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MQ_Height*0.01,
                                                ),
                                                Container(
                                                  child: Text(profilename,//AppLocalizations.of(context).translate("You"),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color:gender!=null && gender==1?Color(Helper.textColorPinkH1):Helper.textColorBlueH1,
                                                        fontFamily: "Kelvetica Nobis",
                                                        fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),),
                                                ),

                                                /* Container(
                                                  width: 40,
                                                  height: 1,
                                                  color: Color(0xfffb4592),//Colors.purpleAccent,
                                                )*/
                                              ],
                                            ),
                                          ),
                                          false? Container(
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
                                                      // toggleAboutMeDialog();

                                                    },
                                                    child: SizedBox(width: 20, height: 20,
                                                      child:true?Icon(Icons.edit,color:Helper.inIconGreyColor1,size: 16,):
                                                      Image.asset("assest/images/edit.png",
                                                        width: 16,height: 16,color: Colors.white,),
                                                    ),
                                                  ),
                                                ),
                                              )

                                          ):Container(),
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
                                height: 6,
                                width: MQ_Width*0.60,
                                decoration: BoxDecoration(
                                  color:Colors.blue,//Color(0xfffb4592),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight:  Radius.circular(20),
                                  ),

                                ),)
                            ],
                          ):Container(),

                          SizedBox(
                            height: MQ_Height*0.03,
                          ),
                          //============= Old Ui About Me ==========
                          false?Container(

                            padding: const EdgeInsets.only(
                                left: 14, top: 10, right: 14, bottom: 40),
                            width: _screenSize.width,
                            //    padding: const EdgeInsets.only(
                            //      top: 10, bottom: 40),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Custom_color
                                              .GreyLightColor3,
                                          offset:
                                          Offset(1.0, 10.0), //(x,y)
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    constraints:BoxConstraints(minHeight: 100),
                                    child: Card(
                                        child:
                                        Stack(
                                          children: <Widget>[

                                            Positioned(
                                              top: -10,
                                              left: (SessionManager.getString(
                                                  Constant
                                                      .Language_code) ==
                                                  "en" ||
                                                  SessionManager.getString(
                                                      Constant
                                                          .Language_code) ==
                                                      "de")
                                                  ? null
                                                  : 10,
                                              right: (SessionManager.getString(
                                                  Constant
                                                      .Language_code) ==
                                                  "en" ||
                                                  SessionManager.getString(
                                                      Constant
                                                          .Language_code) ==
                                                      "de")
                                                  ? 10
                                                  : null,
                                              child:
                                              Container
                                                (
                                                width: 100,
                                                height: 90,
                                                alignment: Alignment.bottomCenter,
                                                child: Container(
                                                  margin: EdgeInsets.all(5),
                                                  height:70,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          4),
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              gender!=null && gender==1? "assest/images/woman_n.png":"assest/images/man_n.png"),

                                                          fit: BoxFit.contain)),
                                                ),
                                              ),
                                            ),

                                            Container(
                                              child: Padding(
                                                padding: (SessionManager.getString(
                                                    Constant
                                                        .Language_code) ==
                                                    "en" ||
                                                    SessionManager.getString(
                                                        Constant
                                                            .Language_code) ==
                                                        "de")
                                                    ? const EdgeInsets.only(
                                                    top: 5,
                                                    right: 135,
                                                    bottom: 5,
                                                    left: 15)
                                                    : const EdgeInsets.only(
                                                    top: 5,
                                                    right: 15,
                                                    bottom: 5,
                                                    left: 135),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    CustomWigdet.TextView(
                                                        text: AppLocalizations.of(
                                                            context)
                                                            .translate(
                                                            "About me"),
                                                        fontFamily:
                                                        "Kelvetica Nobis",
                                                        color: Color(0xff4974a8),
                                                        fontSize: 16),
                                                    Container(
                                                        width:double.infinity,
                                                        child :
                                                        CustomWigdet.TextView(
                                                            overflow: true,
                                                            text: about_me != null ? about_me : "",
                                                            fontSize: 14,
                                                            color: Custom_color
                                                                .GreyLightColor)),
                                                  ],
                                                ),
                                              ),
                                            )

//
                                          ],
                                        ))),
                                SizedBox(height:10),
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Custom_color.GreyLightColor3,
                                        offset: Offset(1.0, 10.0), //(x,y)
                                        blurRadius: 20.0,
                                      ),
                                    ],
                                  ),
                                  width: _screenSize.width,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: <Widget>[
                                      Container(
                                        constraints:
                                        BoxConstraints(maxHeight: 90),
                                        child: Card(
                                          elevation: 2,
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Container(),
                                              Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -5,
                                        left: (SessionManager.getString(
                                            Constant
                                                .Language_code) ==
                                            "en" ||
                                            SessionManager.getString(
                                                Constant
                                                    .Language_code) ==
                                                "de")
                                            ? 10
                                            : null,
                                        right: (SessionManager.getString(
                                            Constant
                                                .Language_code) ==
                                            "en" ||
                                            SessionManager.getString(
                                                Constant
                                                    .Language_code) ==
                                                "de")
                                            ? null
                                            : 10,
                                        child: Container(
                                          width: 90,
                                          height: 80,
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            margin: EdgeInsets.all(5),
                                            height:60,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    4),
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        "assest/images/give-love.png"),
                                                    fit: BoxFit.contain)),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Padding(
                                          padding: (SessionManager.getString(
                                              Constant
                                                  .Language_code) ==
                                              "en" ||
                                              SessionManager.getString(
                                                  Constant
                                                      .Language_code) ==
                                                  "de")
                                              ? const EdgeInsets.only(
                                              top: 5,
                                              right: 15,
                                              bottom: 5,
                                              left: 140)
                                              : const EdgeInsets.only(
                                              top: 5,
                                              right: 140,
                                              bottom: 5,
                                              left: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              CustomWigdet.TextView(
                                                  text: AppLocalizations
                                                      .of(context)
                                                      .translate(
                                                      "Interest_an"),
                                                  fontFamily:
                                                  "Kelvetica Nobis",
                                                  color:
                                                  Color(0xff4974a8),
                                                  fontSize: 16),
                                              CustomWigdet.TextView(
                                                  text: interest != null
                                                      ? _getInterest(
                                                      interest)
                                                      : "",
                                                  fontSize: 13,
                                                  color: Custom_color
                                                      .GreyLightColor),
                                            ],
                                          ),
                                        ),
                                      )
//
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Custom_color
                                              .GreyLightColor3,
                                          offset:
                                          Offset(1.0, 10.0), //(x,y)
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    constraints:BoxConstraints(minHeight: 100),
                                    child: Card(
                                        child:
                                        Stack(
                                          children: <Widget>[

                                            Positioned(
                                              top: -10,
                                              left: (SessionManager.getString(
                                                  Constant
                                                      .Language_code) ==
                                                  "en" ||
                                                  SessionManager.getString(
                                                      Constant
                                                          .Language_code) ==
                                                      "de")
                                                  ? null
                                                  : 10,
                                              right: (SessionManager.getString(
                                                  Constant
                                                      .Language_code) ==
                                                  "en" ||
                                                  SessionManager.getString(
                                                      Constant
                                                          .Language_code) ==
                                                      "de")
                                                  ? 10
                                                  : null,
                                              child:
                                              Container
                                                (
                                                width: 100,
                                                height: 90,
                                                alignment: Alignment.bottomCenter,
                                                child: Container(
                                                  margin: EdgeInsets.fromLTRB(5,10,5,5),
                                                  height:70,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          4),
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              "assest/images/lifestyle.png"),
                                                          fit: BoxFit.contain)),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Padding(
                                                padding: (SessionManager.getString(
                                                    Constant
                                                        .Language_code) ==
                                                    "en" ||
                                                    SessionManager.getString(
                                                        Constant
                                                            .Language_code) ==
                                                        "de")
                                                    ? const EdgeInsets.only(
                                                    top: 5,
                                                    right: 135,
                                                    bottom: 5,
                                                    left: 15)
                                                    : const EdgeInsets.only(
                                                    top: 5,
                                                    right: 15,
                                                    bottom: 5,
                                                    left: 135),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    CustomWigdet.TextView(
                                                        text: AppLocalizations.of(
                                                            context)
                                                            .translate(
                                                            "Activity describes most"),
                                                        fontFamily:
                                                        "Kelvetica Nobis",
                                                        color: Color(0xff4974a8),
                                                        fontSize: 16),
                                                    Container(
                                                        width:double.infinity,
                                                        child :
                                                        CustomWigdet.TextView(
                                                            overflow: true,
                                                            text: activitylist != null
                                                                ? _getListactiviyitem(
                                                                activitylist)
                                                                : "",
                                                            fontSize: 14,
                                                            color: Custom_color
                                                                .GreyLightColor)),
                                                  ],
                                                ),
                                              ),
                                            )
//
                                          ],
                                        ))),
                                SizedBox(
                                  height: 10,
                                ),
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Custom_color
                                                .GreyLightColor3,
                                            offset:
                                            Offset(1.0, 10.0), //(x,y)
                                            blurRadius: 20.0,
                                          ),
                                        ],
                                      ),
                                      constraints:
                                      BoxConstraints(maxHeight: 90),
                                      child: Card(
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Container(),
                                            Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      left: (SessionManager.getString(
                                          Constant
                                              .Language_code) ==
                                          "en" ||
                                          SessionManager.getString(
                                              Constant
                                                  .Language_code) ==
                                              "de")
                                          ? 10
                                          : null,
                                      right: (SessionManager.getString(
                                          Constant
                                              .Language_code) ==
                                          "en" ||
                                          SessionManager.getString(
                                              Constant
                                                  .Language_code) ==
                                              "de")
                                          ? null
                                          : 10,
                                      child: Container(
                                        width: 100,
                                        height: 90,
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          margin: EdgeInsets.all(5),
                                          height:70,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  4),
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "assest/images/handshake.png"),
                                                  fit: BoxFit.contain)),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Padding(
                                        padding: (SessionManager.getString(
                                            Constant
                                                .Language_code) ==
                                            "en" ||
                                            SessionManager.getString(
                                                Constant
                                                    .Language_code) ==
                                                "de")
                                            ? const EdgeInsets.only(
                                            top: 5,
                                            right: 15,
                                            bottom: 5,
                                            left: 140)
                                            : const EdgeInsets.only(
                                            top: 5,
                                            right: 140,
                                            bottom: 5,
                                            left: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            CustomWigdet.TextView(
                                                overflow: true,
                                                text: AppLocalizations.of(
                                                    context)
                                                    .translate(
                                                    "Professional interest"),
                                                fontFamily:
                                                "Kelvetica Nobis",
                                                color: Color(0xff4974a8),
                                                fontSize: 16),
                                            CustomWigdet.TextView(
                                                overflow: true,
                                                text: prof_interest != ""
                                                    ? prof_interest
                                                    : "No professional Interest",
                                                fontSize: 14,
                                                color: Custom_color
                                                    .GreyLightColor),
                                          ],
                                        ),
                                      ),
                                    )
//
                                  ],
                                ),
                              ],
                            ),
                          ):
                          //=========== New UI About Me=======
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                                height: MQ_Height*0.16,
                                decoration: BoxDecoration(
                                 // color:Colors.grey.shade100,
                                  color:Colors.white,
                                  borderRadius: BorderRadius.circular(20),

                                ),

                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Text(AppLocalizations.of(
                                                      context)
                                                      .translate(
                                                      "About me"),
                                                    style: TextStyle(color:Helper.textColorBlueH1,
                                                        fontFamily: "Kelvetica Nobis",
                                                        fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),),
                                                ),
                                                SizedBox(
                                                  height: MQ_Height*0.01,
                                                ),
                                                Container(
                                                  width: 40,
                                                  height: 1,
                                                  color: Color(0xfffb4592),//Colors.purpleAccent,
                                                )
                                              ],
                                            ),
                                          ),
                                          false? Container(
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
                                                      // toggleAboutMeDialog();

                                                    },
                                                    child: SizedBox(width: 20, height: 20,
                                                      child:true?Icon(Icons.edit,color:Helper.inIconGreyColor1,size: 16,):
                                                      Image.asset("assest/images/edit.png",
                                                        width: 16,height: 16,color: Colors.white,),
                                                    ),
                                                  ),
                                                ),
                                              )

                                          ):Container(),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: MQ_Height*0.02,
                                    ),

                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(about_me != null ? about_me : "",
                                        style: TextStyle(color:Color(Helper.textColorBlackH2),
                                            fontWeight: Helper.textFontH6,fontSize: Helper.textSizeH15,
                                            fontFamily: "itc avant medium"
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.08,bottom: MQ_Width*0.02) ,
                                height: 6,
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

                          SizedBox(height: MQ_Height*0.03,),


                          //============ New UI Interest =======

                         false? Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                                height: MQ_Height*0.20,
                                decoration: BoxDecoration(
                                  color:Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),

                                ),

                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Text('Interest',
                                                    style: TextStyle(color:Helper.textColorBlueH1,
                                                        fontFamily: "Kelvetica Nobis",
                                                        fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),),
                                                ),
                                                SizedBox(
                                                  height: MQ_Height*0.01,
                                                ),
                                                Container(
                                                  width: 40,
                                                  height: 0.5,
                                                  color: Color(0xfffb4592),//Colors.purpleAccent,
                                                )
                                              ],
                                            ),
                                          ),
                                          false?Container(
                                              margin: EdgeInsets.only(left: MQ_Width*0.01,),
                                              // width: _screenSize.width,
                                              padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),

                                              alignment: Alignment.topCenter,
                                              child:
                                              ClipOval(
                                                child: Material(
                                                  color: Colors.white60, // Button color
                                                  child: InkWell(
                                                    splashColor: Helper.inIconCircleGreyColor1, // Splash color
                                                    onTap: () {},
                                                    child: SizedBox(width: 20, height: 20,
                                                      child:true?Icon(Icons.edit,color:Helper.inIconGreyColor1,size: 16,):
                                                      Image.asset("assest/images/edit.png",
                                                        width: 16,height: 16,color: Colors.white,),
                                                    ),
                                                  ),
                                                ),
                                              )

                                          ):Container(),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: MQ_Height*0.02,
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Outing",
                                              style: TextStyle(color:Color(Helper.textColorBlackH2),
                                                  fontWeight: Helper.textFontH6,fontSize: Helper.textSizeH15,
                                                  fontFamily: "itc avant medium"
                                              ),),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text("5/10",
                                              style: TextStyle(color:Color(0xfffb4592),
                                                  fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH15,
                                                  fontFamily: "itc avant medium"
                                              ),),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top:5,bottom: 5),

                                      width: MQ_Width*0.80,
                                      height: 1,
                                      color: Color(Helper.textBorderLineColorH1),
                                    ),


                                    Container(

                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Sports",
                                              style: TextStyle(color:Color(Helper.textColorBlackH2),
                                                  fontWeight: Helper.textFontH6,fontSize: Helper.textSizeH15,
                                                  fontFamily: "itc avant medium"
                                              ),),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text("6/10",
                                              style: TextStyle(color:Color(0xfffb4592),
                                                  fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH15,
                                                  fontFamily: "itc avant medium"
                                              ),),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top:5,bottom: 5),

                                      width: MQ_Width*0.80,
                                      height: 1,
                                      color: Color(Helper.textBorderLineColorH1),
                                    ),


                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Entertainment",
                                              style: TextStyle(color:Color(Helper.textColorBlackH2),
                                                  fontWeight: Helper.textFontH6,fontSize: Helper.textSizeH15,
                                                  fontFamily: "itc avant medium"
                                              ),),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text("7/10",
                                              style: TextStyle(color:Color(0xfffb4592),
                                                  fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH15,
                                                  fontFamily: "itc avant medium"
                                              ),),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top:5,bottom: 5),

                                      width: MQ_Width*0.80,
                                      height: 1,
                                      color: Color(Helper.textBorderLineColorH1),
                                    ),

                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Foodle",
                                              style: TextStyle(color:Color(Helper.textColorBlackH2),
                                                  fontWeight: Helper.textFontH6,fontSize: Helper.textSizeH15,
                                                  fontFamily: "itc avant medium"
                                              ),),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text("8/10",
                                              style: TextStyle(color:Color(0xfffb4592),
                                                  fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH15,
                                                  fontFamily: "itc avant medium"
                                              ),),
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
                                height: 6,
                                width: MQ_Width*0.60,
                                decoration: BoxDecoration(
                                  color:Colors.blue,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight:  Radius.circular(20),
                                  ),

                                ),)
                            ],
                          ) :
                         Column(
                           children: [
                             Container(
                               margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                               padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                               height:activitylist.length<3?MQ_Height*0.21:MQ_Height*0.28,
                               decoration: BoxDecoration(
                                // color:Colors.grey.shade100,
                                 color:Colors.white,
                                 borderRadius: BorderRadius.circular(20),

                               ),

                               child: Column(
                                 children: [
                                   Container(
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Container(
                                           child: Column(
                                             mainAxisAlignment: MainAxisAlignment.start,
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Container(
                                                 child: Text(AppLocalizations.of(context).translate("Interest"),
                                                   style: TextStyle(color:Helper.textColorBlueH1,
                                                       fontFamily: "Kelvetica Nobis",
                                                       fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),),
                                               ),
                                               SizedBox(
                                                 height: MQ_Height*0.01,
                                               ),
                                               Container(
                                                 width: 40,
                                                 height: 0.5,
                                                 color: Color(0xfffb4592),//Colors.purpleAccent,
                                               )
                                             ],
                                           ),
                                         ),
                                         false?Container(
                                             margin: EdgeInsets.only(left: MQ_Width*0.01,),
                                             // width: _screenSize.width,
                                             padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),

                                             alignment: Alignment.topCenter,
                                             child:
                                             ClipOval(
                                               child: Material(
                                                 color: Colors.white60, // Button color
                                                 child: InkWell(
                                                   splashColor: Helper.inIconCircleGreyColor1, // Splash color
                                                   onTap: () {},
                                                   child: SizedBox(width: 20, height: 20,
                                                     child:true?Icon(Icons.edit,color:Helper.inIconGreyColor1,size: 16,):
                                                     Image.asset("assest/images/edit.png",
                                                       width: 16,height: 16,color: Colors.white,),
                                                   ),
                                                 ),
                                               ),
                                             )

                                         ):Container(),
                                       ],
                                     ),
                                   ),
                                   SizedBox(
                                     height: MQ_Height*0.02,
                                   ),

                                  /* activitylist != null
                                       ? _getListactiviyitem(
                                       activitylist)
                                       : "",*/
                                   _widgetGetListActiviyitem(activitylist)


                                 ],
                               ),
                             ),
                             Container(
                               alignment: Alignment.bottomCenter,
                               margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                               padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.08,bottom: MQ_Width*0.02) ,
                               height: 6,
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
                          SizedBox(
                            height: MQ_Height*0.03,
                          ),
                          //============ New Ui Purpose of joining =========
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                                height: MQ_Height*0.10,
                                decoration: BoxDecoration(
                                  //color:Colors.grey.shade100,
                                  color:Colors.white,
                                  borderRadius: BorderRadius.circular(20),

                                ),

                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Text(AppLocalizations.of(context).translate("Purpose of joining"),
                                                    style: TextStyle(color:Helper.textColorBlueH1,
                                                        fontFamily: "Kelvetica Nobis",
                                                        fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),),
                                                ),
                                                SizedBox(
                                                  height: MQ_Height*0.01,
                                                ),
                                                Container(
                                                  width: 40,
                                                  height: 0.5,
                                                  color: Color(0xfffb4592),//Colors.purpleAccent,
                                                )
                                              ],
                                            ),
                                          ),
                                          false? Container(
                                              margin: EdgeInsets.only(left: MQ_Width*0.01,),
                                              // width: _screenSize.width,
                                              padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),

                                              alignment: Alignment.topCenter,
                                              child:
                                              ClipOval(
                                                child: Material(
                                                  color: Colors.white60, // Button color
                                                  child: InkWell(
                                                    splashColor: Helper.inIconCircleGreyColor1, // Splash color
                                                    onTap: () {},
                                                    child: SizedBox(width: 20, height: 20,
                                                      child:true?Icon(Icons.edit,color:Helper.inIconGreyColor1,size: 16,):
                                                      Image.asset("assest/images/edit.png",
                                                        width: 16,height: 16,color: Colors.white,),
                                                    ),
                                                  ),
                                                ),
                                              )

                                          ):
                                          Container(),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: MQ_Height*0.02,
                                    ),

                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(prof_interest!=null ? prof_interest
                                          : AppLocalizations.of(context).translate("No professional Interest"),
                                        style: TextStyle(color:Color(Helper.textColorBlackH2),
                                            fontWeight: Helper.textFontH6,fontSize: Helper.textSizeH15,
                                            fontFamily: "itc avant medium"
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.08,bottom: MQ_Width*0.02) ,
                                height: 6,
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

                          SizedBox(
                            height: MQ_Height*0.03,
                          ),
                          //========== New Ui Activity Join ==========

                          bylist_activitylike != null && bylist_activitylike.isNotEmpty
                              ? Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                                height: !joined_expand?MQ_Height*0.21:MQ_Height*0.26,
                                decoration: BoxDecoration(
                                 // color:Colors.grey.shade100,
                                    color:Colors.white,
                                  borderRadius: BorderRadius.circular(20),

                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child:false? Text('Activity',
                                                    style: TextStyle(color:Helper.textColorBlueH1,
                                                        fontFamily: "Kelvetica Nobis",
                                                        fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),)
                                                      : CustomWigdet.TextView(
                                                      text: AppLocalizations
                                                          .of(context)
                                                          .translate(
                                                          "Activity Joined"),
                                                      color:Helper.textColorBlueH1,
                                                      fontFamily:
                                                      "OpenSans Bold",
                                                      fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MQ_Height*0.01,
                                                ),
                                                Container(
                                                  width: 40,
                                                  height: 0.5,
                                                  color: Color(0xfffb4592),//Colors.purpleAccent,
                                                )
                                              ],
                                            ),
                                          ),
                                          false? Container(
                                              margin: EdgeInsets.only(left: MQ_Width*0.01,),
                                              // width: _screenSize.width,
                                              padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),

                                              alignment: Alignment.topCenter,
                                              child:
                                              ClipOval(
                                                child: Material(
                                                  color: Colors.white60, // Button color
                                                  child: InkWell(
                                                    splashColor: Helper.inIconCircleGreyColor1, // Splash color
                                                    onTap: () {},
                                                    child: SizedBox(width: 20, height: 20,
                                                      child:true?Icon(Icons.edit,color:Helper.inIconGreyColor1,size: 16,):
                                                      Image.asset("assest/images/edit.png",
                                                        width: 16,height: 16,color: Colors.white,),
                                                    ),
                                                  ),
                                                ),
                                              )

                                          ):
                                          Container(),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: MQ_Height*0.02,
                                    ),

                                    /*Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Activity Name 1",
                                            style: TextStyle(color:Color(Helper.textColorBlackH1),
                                                fontWeight: Helper.textFontH3,fontSize: Helper.textSizeH15,
                                                fontFamily: "itc avant medium"
                                            ),),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Date: ",
                                            style: TextStyle(color:Color(Helper.textHintColorH3),
                                                fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH15,
                                                fontFamily: "itc avant medium"
                                            ),),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top:5,bottom: 5),

                                    width: MQ_Width*0.80,
                                    height: 1,
                                    color: Color(Helper.textBorderLineColorH1),
                                  ),
                                     Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Activity Name 2",
                                            style: TextStyle(color:Color(Helper.textColorBlackH1),
                                                fontWeight: Helper.textFontH3,fontSize: Helper.textSizeH15,
                                                fontFamily: "itc avant medium"
                                            ),),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Date: ",
                                            style: TextStyle(color:Color(Helper.textHintColorH3),
                                                fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH15,
                                                fontFamily: "itc avant medium"
                                            ),),
                                        ),
                                      ],
                                    ),
                                  ),*/
                                    Container(
                                      //color:Colors.grey.shade100,
                                      height: !joined_expand?MQ_Height*0.12:MQ_Height*0.18,
                                      child: SingleChildScrollView(
                                        physics: ClampingScrollPhysics(),
                                        child: Container(

                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(bottom: 14.0),
                                                child: Container(

                                                 // elevation: 2,
                                                  child:  Column(
                                                    children: List.generate(
                                                        bylist_activitylike
                                                            .length, (index) {
                                                      return InkWell(
                                                        onTap: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              Constant
                                                                  .ActivityUserDetail,
                                                              arguments: {
                                                                "event_id": bylist_activitylike[
                                                                index]
                                                                    .id
                                                                    .toString(),
                                                                "isSub": int.parse(
                                                                    bylist_activitylike[
                                                                    index]
                                                                        .is_subs)
                                                              }).then(
                                                                  (value) {
                                                                if (value !=
                                                                    null &&
                                                                    value) {
                                                                  _GetUserDetail(
                                                                      routeData[
                                                                      "user_id"]);
                                                                }
                                                              });
                                                        },
                                                        child: !joined_expand
                                                            ? index < 2
                                                            ? Container(
                                                            margin: EdgeInsets.all(2),
                                                            width: _screenSize
                                                                .width,
                                                            /*decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color(
                                                                          0xff23b8f2),
                                                                      Color(
                                                                          0xff1b5dab)
                                                                    ],
                                                                    begin: Alignment
                                                                        .topCenter,
                                                                    end: Alignment
                                                                        .bottomCenter)),*/
                                                            /*decoration: BoxDecoration(
                                                               color: Helper.textColorBlueH1,
                                                               border: Border.all(width: 0.5,color: Colors.blue.shade300),
                                                               borderRadius: BorderRadius.circular(20)),*/
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.all(10.0),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child: CustomWigdet.TextView(text: bylist_activitylike[index].title,  color: Color(Helper.textColorBlackH1),
                                                                            fontWeight: Helper.textFontH5,
                                                                            fontSize: Helper.textSizeH14),
                                                                      ),
                                                                      Icon(
                                                                        Icons.arrow_forward_ios,
                                                                        size: 16,
                                                                        color: Custom_color.GreyLightColor,
                                                                      )

                                                                    ],
                                                                  ),
                                                                ),
                                                               // Divider(height: 1, thickness: 0.5, color: Custom_color.WhiteColor,)
                                                                index<1?Container(
                                                                    width: MQ_Height*0.35,
                                                                    height: 1,
                                                                    decoration: BoxDecoration(
                                                                        color: Color(Helper.textBorderLineColorH1),
                                                                        border: Border.all(width: 0.5,color: Color(Helper.textBorderLineColorH1),),
                                                                        borderRadius: BorderRadius.circular(30))
                                                                ):Container()
                                                              ],
                                                            ))
                                                                : Container()
                                                                : Container(
                                                              margin: EdgeInsets.all(2),
                                                              width: _screenSize
                                                                  .width,
                                                              /* decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color(
                                                                          0xff23b8f2),
                                                                      Color(
                                                                          0xff1b5dab)
                                                                    ],
                                                                    begin: Alignment
                                                                        .topCenter,
                                                                    end: Alignment
                                                                        .bottomCenter)),*/
                                                             /* decoration: BoxDecoration(
                                                                  color: Helper.textColorBlueH1,
                                                                  border: Border.all(width: 0.5,color: Colors.blue.shade300),
                                                                  borderRadius: BorderRadius.circular(20)),*/
                                                                  child: Column(
                                                              children: [
                                                                  Padding(
                                                                    padding:
                                                                    const EdgeInsets.all(10.0),
                                                                    child:
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          child: CustomWigdet.TextView(text: bylist_activitylike[index].title,  color: Color(Helper.textColorBlackH1),
                                                                              fontWeight: Helper.textFontH5,
                                                                              fontSize: Helper.textSizeH14),
                                                                        ),
                                                                        Icon(
                                                                          Icons.arrow_forward_ios,
                                                                          size: 16,
                                                                          color: Custom_color.GreyLightColor,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                //  Divider(height: 1, thickness: 0.5, color: Custom_color.WhiteColor,)
                                                                index<bylist_activitylike.length-1?Container(
                                                                    width: MQ_Height*0.35,
                                                                    height: 1,
                                                                    decoration: BoxDecoration(
                                                                        color: Color(Helper.textBorderLineColorH1),
                                                                        border: Border.all(width: 0.5,color:Color(Helper.textBorderLineColorH1),),
                                                                        borderRadius: BorderRadius.circular(30))
                                                                ):Container()
                                                              ],
                                                            ),
                                                                ),
                                                      );
                                                    }),
                                                  ),
                                                ),
                                              ),
                                              bylist_activitylike != null &&
                                                  bylist_activitylike.length >
                                                      2
                                                  ? Positioned(
                                                  right: 10,
                                                  bottom: 0,
                                                  child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          joined_expand =
                                                          !joined_expand;
                                                        });
                                                      },
                                                      child: Image.asset(
                                                        !joined_expand
                                                            ? "assest/images/plus.png"
                                                            : "assest/images/minus.png",
                                                        width: 36,
                                                        height: 36,
                                                      )))
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.08,bottom: MQ_Width*0.02) ,
                                height: 6,
                                width: MQ_Width*0.60,
                                decoration: BoxDecoration(
                                  color:Colors.blue,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight:  Radius.circular(20),
                                  ),

                                ),)
                            ],
                          ):Container(),


                          SizedBox(
                            height: MQ_Height*0.03,
                          ),
                          //SizedBox(height: MQ_Height*0.02,),
                          //================= Old Activity Join Ui ===========
                         // bylist_activitylike != null && bylist_activitylike.isNotEmpty
                            false  ? Padding(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 14.0),
                                  child: Card(
                                    color: Helper.inBackgroundColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    elevation: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          alignment:
                                          Alignment.centerRight,
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets
                                                  .only(
                                                  left: 10.0,
                                                  top: 14,
                                                  right: 10,
                                                  bottom: 14),
                                              color: Custom_color.GreyLightColor2,
                                              width:
                                              _screenSize.width,
                                              child: CustomWigdet
                                                  .TextView(
                                                text: AppLocalizations
                                                    .of(context)
                                                    .translate(
                                                    "Activity Joined"),
                                                color: Custom_color
                                                    .BlackTextColor,
                                                fontFamily:
                                                "OpenSans Bold",
                                              ),
                                            ),
                                            Positioned(
                                              right: 10,
                                              child: Image.asset(
                                                "assest/images/acting.png",
                                                width: 30,
                                                height: 30,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: List.generate(
                                              bylist_activitylike
                                                  .length, (index) {
                                            return InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context,
                                                    Constant
                                                        .ActivityUserDetail,
                                                    arguments: {
                                                      "event_id": bylist_activitylike[
                                                      index]
                                                          .id
                                                          .toString(),
                                                      "isSub": int.parse(
                                                          bylist_activitylike[
                                                          index]
                                                              .is_subs)
                                                    }).then(
                                                        (value) {
                                                      if (value !=
                                                          null &&
                                                          value) {
                                                        _GetUserDetail(
                                                            routeData[
                                                            "user_id"]);
                                                      }
                                                    });
                                              },
                                              child: Container(
                                                  width: _screenSize
                                                      .width,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color(
                                                                0xff23b8f2),
                                                            Color(
                                                                0xff1b5dab)
                                                          ],
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter)),
                                                  child: !joined_expand
                                                      ? index < 2
                                                      ? Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: CustomWigdet.TextView(text: bylist_activitylike[index].title, color: Custom_color.WhiteColor),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 16,
                                                              color: Custom_color.WhiteColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        height: 1,
                                                        thickness: 0.5,
                                                        color: Custom_color.WhiteColor,
                                                      )
                                                    ],
                                                  )
                                                      : Container()
                                                      : Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.all(10.0),
                                                        child:
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: CustomWigdet.TextView(text: bylist_activitylike[index].title, color: Custom_color.WhiteColor),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 16,
                                                              color: Custom_color.WhiteColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        height:
                                                        1,
                                                        thickness:
                                                        0.5,
                                                        color:
                                                        Custom_color.WhiteColor,
                                                      )
                                                    ],
                                                  )),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                bylist_activitylike != null &&
                                    bylist_activitylike.length >
                                        2
                                    ? Positioned(
                                    right: 10,
                                    bottom: 0,
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            joined_expand =
                                            !joined_expand;
                                          });
                                        },
                                        child: Image.asset(
                                          !joined_expand
                                              ? "assest/images/plus.png"
                                              : "assest/images/minus.png",
                                          width: 36,
                                          height: 36,
                                        )))
                                    : Container(),
                              ],
                            ),
                          )
                              : Container(),

                          //========== New Ui Activity Create ==========
                          bylist_activitycreate != null &&
                              bylist_activitycreate.isNotEmpty
                              ? Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                                height: !create_expand?MQ_Height*0.21:MQ_Height*0.26,
                                decoration: BoxDecoration(
                                  color:Colors.white,//Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),

                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child:false? Text('Activity',
                                                    style: TextStyle(color:Helper.textColorBlueH1,
                                                        fontFamily: "Kelvetica Nobis",
                                                        fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),)
                                                      : CustomWigdet.TextView(
                                                      text:  AppLocalizations
                                                          .of(context)
                                                          .translate(
                                                          "Activity Created"),
                                                      color:Helper.textColorBlueH1,
                                                      fontFamily:
                                                      "OpenSans Bold",
                                                      fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MQ_Height*0.01,
                                                ),
                                                Container(
                                                  width: 40,
                                                  height: 0.5,
                                                  color: Color(0xfffb4592),//Colors.purpleAccent,
                                                )
                                              ],
                                            ),
                                          ),
                                          false? Container(
                                              margin: EdgeInsets.only(left: MQ_Width*0.01,),
                                              // width: _screenSize.width,
                                              padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),

                                              alignment: Alignment.topCenter,
                                              child:
                                              ClipOval(
                                                child: Material(
                                                  color: Colors.white60, // Button color
                                                  child: InkWell(
                                                    splashColor: Helper.inIconCircleGreyColor1, // Splash color
                                                    onTap: () {},
                                                    child: SizedBox(width: 20, height: 20,
                                                      child:true?Icon(Icons.edit,color:Helper.inIconGreyColor1,size: 16,):
                                                      Image.asset("assest/images/edit.png",
                                                        width: 16,height: 16,color: Colors.white,),
                                                    ),
                                                  ),
                                                ),
                                              )

                                          ):
                                          Container(),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: MQ_Height*0.02,
                                    ),

                                    /*Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Activity Name 1",
                                            style: TextStyle(color:Color(Helper.textColorBlackH1),
                                                fontWeight: Helper.textFontH3,fontSize: Helper.textSizeH15,
                                                fontFamily: "itc avant medium"
                                            ),),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Date: ",
                                            style: TextStyle(color:Color(Helper.textHintColorH3),
                                                fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH15,
                                                fontFamily: "itc avant medium"
                                            ),),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top:5,bottom: 5),

                                    width: MQ_Width*0.80,
                                    height: 1,
                                    color: Color(Helper.textBorderLineColorH1),
                                  ),
                                     Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Activity Name 2",
                                            style: TextStyle(color:Color(Helper.textColorBlackH1),
                                                fontWeight: Helper.textFontH3,fontSize: Helper.textSizeH15,
                                                fontFamily: "itc avant medium"
                                            ),),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Date: ",
                                            style: TextStyle(color:Color(Helper.textHintColorH3),
                                                fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH15,
                                                fontFamily: "itc avant medium"
                                            ),),
                                        ),
                                      ],
                                    ),
                                  ),*/
                                    Container(
                                        color:Colors.white,//Colors.grey.shade100,
                                      height: !create_expand?MQ_Height*0.12:MQ_Height*0.18,
                                      child: SingleChildScrollView(
                                        physics: ClampingScrollPhysics(),
                                        child: Container(

                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(bottom: 14.0),
                                                child: Container(
                                                 // elevation: 2,
                                                  child:  Column(
                                                    children: List.generate(
                                                        bylist_activitycreate
                                                            .length, (index) {
                                                      return InkWell(
                                                        onTap: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              Constant
                                                                  .ActivityUserDetail,
                                                              arguments: {
                                                                "event_id": bylist_activitycreate[
                                                                index]
                                                                    .id
                                                                    .toString(),
                                                                "isSub": int.parse(
                                                                    bylist_activitycreate[
                                                                    index]
                                                                        .is_subs)
                                                              }).then(
                                                                  (value) {
                                                                if (value !=
                                                                    null &&
                                                                    value) {
                                                                  _GetUserDetail(
                                                                      routeData[
                                                                      "user_id"]);
                                                                }
                                                              });
                                                        },
                                                        child: !create_expand ? index < 2 ?Container(
                                                            margin: EdgeInsets.all(2),
                                                            width: _screenSize
                                                                .width,
                                                           /* decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color(
                                                                          0xff23b8f2),
                                                                      Color(
                                                                          0xff1b5dab)
                                                                    ],
                                                                    begin: Alignment
                                                                        .topCenter,
                                                                    end: Alignment
                                                                        .bottomCenter)),*/
                                                           /* decoration: BoxDecoration(
                                                                color: Helper.textColorBlueH1,
                                                                border: Border.all(width: 0.5,color: Colors.blue.shade300),
                                                               borderRadius: BorderRadius.circular(20)
                                                              ),*/
                                                            //color: Custom_color.WhiteColor,
                                                            child:  Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.all(10.0),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child: CustomWigdet.TextView(
                                                                            text: bylist_activitycreate[index].title,
                                                                            color: Color(Helper.textColorBlackH1),
                                                                            fontWeight: Helper.textFontH5,
                                                                            fontSize: Helper.textSizeH14),
                                                                      ),
                                                                      Icon(
                                                                        Icons.arrow_forward_ios,
                                                                        size: 16,
                                                                        color: Custom_color.GreyLightColor,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                               // Divider(height: 1, thickness: 0.5, color: Custom_color.GreyLightColor,)
                                                                index<1?Container(
                                                                    width: MQ_Height*0.36,
                                                                    height: 1,
                                                                    decoration: BoxDecoration(
                                                                        color:Color(Helper.textBorderLineColorH1),
                                                                        border: Border.all(width: 0.5,color: Color(Helper.textBorderLineColorH1),),
                                                                        borderRadius: BorderRadius.circular(30))
                                                                ):Container()
                                                              ],
                                                            )) : Container()
                                                                : Container(
                                                          margin: EdgeInsets.all(2),
                                                          width: _screenSize
                                                              .width,
                                                          /* decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    colors: [
                                                                      Color(
                                                                          0xff23b8f2),
                                                                      Color(
                                                                          0xff1b5dab)
                                                                    ],
                                                                    begin: Alignment
                                                                        .topCenter,
                                                                    end: Alignment
                                                                        .bottomCenter)),*/
                                                         /* decoration: BoxDecoration(
                                                              color: Helper.textColorBlueH1,
                                                              border: Border.all(width: 0.5,color: Colors.blue.shade300),
                                                              borderRadius: BorderRadius.circular(20)),*/
                                                         // color: Custom_color.WhiteColor,
                                                                  child: Column(
                                                              children: [
                                                                  Padding(
                                                                    padding:
                                                                    const EdgeInsets.all(10.0),
                                                                    child:
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          child: CustomWigdet.TextView(text: bylist_activitycreate[index].title,
                                                                              color: Color(Helper.textColorBlackH1),
                                                                              fontWeight: Helper.textFontH5,
                                                                              fontSize: Helper.textSizeH14),
                                                                        ),
                                                                        Icon(
                                                                          Icons.arrow_forward_ios,
                                                                          size: 16,
                                                                          color: Custom_color.GreyLightColor,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                 // Divider(height: 1, thickness: 1,color: Custom_color.GreyLightColor,)
                                                                index<bylist_activitycreate.length-1?Container(
                                                                    width: MQ_Height*0.35,
                                                                    height: 1,
                                                                    decoration: BoxDecoration(
                                                                        color: Color(Helper.textBorderLineColorH1),
                                                                        border: Border.all(width: 0.5,color: Color(Helper.textBorderLineColorH1),),
                                                                        borderRadius: BorderRadius.circular(30))
                                                                ):Container()
                                                              ],
                                                            ),
                                                                ),
                                                      );
                                                    }),
                                                  ),
                                                ),
                                              ),
                                              bylist_activitycreate != null &&
                                                  bylist_activitycreate
                                                      .length >
                                                      2
                                                  ? Positioned(
                                                  right: 10,
                                                  bottom: 0,
                                                  child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          create_expand =
                                                          !create_expand;
                                                        });
                                                      },
                                                      child: Image.asset(
                                                        !create_expand
                                                            ? "assest/images/plus.png"
                                                            : "assest/images/minus.png",
                                                        width: 36,
                                                        height: 36,
                                                      )))
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                                padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.08,bottom: MQ_Width*0.02) ,
                                height: 6,
                                width: MQ_Width*0.60,
                                decoration: BoxDecoration(
                                  color:Colors.blue,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight:  Radius.circular(20),
                                  ),

                                ),)
                            ],
                          ):Container(),
//========================== Old Activity create UI =============
                         // bylist_activitycreate != null && bylist_activitycreate.isNotEmpty
                            false ? Padding(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, top: 5),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 17.0),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          alignment:
                                          Alignment.centerRight,
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets
                                                  .only(
                                                  left: 10.0,
                                                  top: 14,
                                                  right: 10,
                                                  bottom: 14),
                                              //color: Custom_color.GreyLightColor2,
                                              color:Colors.blue.shade700,

                                              width:
                                              _screenSize.width,
                                              child: CustomWigdet
                                                  .TextView(
                                                text: AppLocalizations
                                                    .of(context)
                                                    .translate(
                                                    "Activity Created"),
                                                color: Custom_color
                                                    .BlackTextColor,
                                                fontFamily:
                                                "OpenSans Bold",
                                              ),
                                            ),
                                            Positioned(
                                              right: 10,
                                              child: Image.asset(
                                                "assest/images/acting.png",
                                                width: 30,
                                                height: 30,
                                                color: Custom_color
                                                    .WhiteColor,
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: List.generate(
                                              bylist_activitycreate
                                                  .length, (index) {
                                            return InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context,
                                                    Constant
                                                        .ActivityUserDetail,
                                                    arguments: {
                                                      "event_id": bylist_activitycreate[
                                                      index]
                                                          .id
                                                          .toString(),
                                                      "isSub": int.parse(
                                                          bylist_activitycreate[
                                                          index]
                                                              .is_subs)
                                                    }).then(
                                                        (value) {
                                                      if (value !=
                                                          null &&
                                                          value) {
                                                        _GetUserDetail(
                                                            routeData[
                                                            "user_id"]);
                                                      }
                                                    });
                                              },
                                              child: Container(
                                                  width: _screenSize
                                                      .width,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color(
                                                                0xff23b8f2),
                                                            Color(
                                                                0xff1b5dab)
                                                          ],
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter)),
                                                  child: !create_expand
                                                      ? index < 2
                                                      ? Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: CustomWigdet.TextView(text: bylist_activitycreate[index].title, color: Custom_color.WhiteColor),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 16,
                                                              color: Custom_color.WhiteColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        height: 1,
                                                        thickness: 0.5,
                                                        color: Custom_color.WhiteColor,
                                                      )
                                                    ],
                                                  )
                                                      : Container()
                                                      : Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.all(10.0),
                                                        child:
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: CustomWigdet.TextView(text: bylist_activitycreate[index].title, color: Custom_color.WhiteColor),
                                                            ),
                                                            Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 16,
                                                              color: Custom_color.WhiteColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        height:
                                                        1,
                                                        thickness:
                                                        0.5,
                                                        color:
                                                        Custom_color.WhiteColor,
                                                      )
                                                    ],
                                                  )),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                bylist_activitycreate != null &&
                                    bylist_activitycreate
                                        .length >
                                        2
                                    ? Positioned(
                                    right: 10,
                                    bottom: 0,
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            create_expand =
                                            !create_expand;
                                          });
                                        },
                                        child: Image.asset(
                                          !create_expand
                                              ? "assest/images/plus.png"
                                              : "assest/images/minus.png",
                                          width: 36,
                                          height: 36,
                                        )))
                                    : Container(),
                              ],
                            ),
                          )
                              : Container()
                        ],
                      )
                    ],
                  ),
                ),
              ),
              fullScreen  ?
              SizedBox.shrink():
              Stack(
                  children : [
                    SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: Color(int.parse(Constant.progressBg)),
                        valueColor: AlwaysStoppedAnimation<Color>(showLoading ? Color(int.parse(Constant.progressVl)) : Colors.transparent),
                        minHeight:  2,
                      ),
                    ),
                    Container(
                     // color: Colors.transparent,
                      color:Helper.inBackgroundColor,
                      padding: EdgeInsets.only(top: 10),
                      child: Stack(children: [
                        professional_interest_id == "1" ||
                            professional_interest_id == "2" ||
                            professional_interest_id == "3"
                            ? GestureDetector(
                          onTap: () {
                            miu = 1;
                            senProfessionalMessage();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (miu != null && miu == 0) ?
                                Color(0xffAAAAAA) : Color(0xfff84390),
                              //  Color(0xffAAAAAA) :Colors.blue.shade700,

                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xffe4e9ef),
                                    offset: Offset(1.0, 1.0), //(x,y)
                                    blurRadius: 30.0,
                                  ),
                                ]),
                            padding: const EdgeInsets.only(
                                left: 30, top: 10, right: 30, bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: false?Image.asset(
                                "assest/images/professionals.png",
                                width: 30,
                                color: Custom_color.WhiteColor,
                              ):Icon(Icons.wechat,
                                size: 30,
                                color: Custom_color.WhiteColor,),
                            ),
                          ),
                        )
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                print("routedata :: "+routeData["type"]);
                                // if (routeData != null &&
                                //     routeData["type"] != null &&
                                //     routeData["type"] == "3") {
                                //   Navigator.pop(context);
                                // } else
                                    {
                                  //   _GetIgnore();
                                  _asyncDialogDislike(context);
                                }
                              },
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomRight: Radius.circular(30)),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:Colors.blue.shade700,
                                      //Color(0xffAAAAAA) ,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xffe4e9ef),
                                        offset: Offset(1.0, 1.0), //(x,y)
                                        blurRadius: 30.0,
                                      ),
                                    ]),
                                padding: const EdgeInsets.only(
                                    left: 30, top: 10, right: 30, bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: false?Image.asset(
                                    "assest/images/dislike.png",
                                    width: 30,
                                    color: Custom_color.WhiteColor,
                                  ):Icon(Icons.thumb_down_alt_outlined,size: 30,
                                      color: Custom_color.WhiteColor,),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {

                                if (await UtilMethod
                                    .SimpleCheckInternetConnection(
                                    context, _scaffoldKey)) {
                                  if (routeData != null &&
                                      routeData["type"] != null) {
                                    print("youliked :: "+you_liked.toString());
                                    you_liked == 0
                                        ? _GetLikeUser(routeData["user_id"])
                                        : _asyncConfirmDialog(context);
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: you_liked == 1 ?
                                    //Color(0xfff84390) : Color(0xffAAAAAA),
                                    Colors.blue.shade700:Color(0xffAAAAAA),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Custom_color.GreyLightColor3,
                                        offset: Offset(1.0, 1.0), //(x,y)
                                        blurRadius: 20.0,
                                      ),
                                    ]),
                                child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    // child: Icon(
                                    //   you_liked == 0
                                    //       ? Icons.favorite_border
                                    //       : Icons.favorite,
                                    //   color: Custom_color.RedColor,
                                    //   size: 30,
                                    // ),
                                    child: you_liked == 0 && liked_you == 0
                                        ? Icon(
                                      Icons.favorite,
                                      color: Custom_color.WhiteColor,
                                      size: 30,
                                    )
                                        : you_liked == 1 && liked_you == 0
                                        ? Icon(
                                      Icons.favorite_border,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                        : you_liked == 0 && liked_you == 1
                                        ? Icon(
                                      Icons.favorite,
                                      color:
                                      Custom_color.WhiteColor,
                                      size: 30,
                                    )
                                        : you_liked == 1 &&
                                        liked_you == 1
                                        ? Icon(
                                      Icons.favorite_border,
                                      color: Custom_color
                                          .WhiteColor,
                                      size: 30,
                                    )
                                        : Container()),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                if (await UtilMethod
                                    .SimpleCheckInternetConnection(
                                    context, _scaffoldKey)) {
                                  print("----------date time--------" +
                                      (DateTime.now().millisecondsSinceEpoch *
                                          1000)
                                          .toString());
                                  //     if (miu != null && miu == 0)
                                      {
                                    _GetMiu();
                                  }
                                }
                              },
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  bottomLeft: Radius.circular(30)),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (miu != null && miu == 0) ?
                                    //Color(0xffAAAAAA) : Color(0xfff84390),
                                   Color(0xffAAAAAA) : Colors.blue.shade700,

                                    boxShadow: [
                                      BoxShadow(
                                        color: Custom_color.GreyLightColor3,
                                        offset: Offset(1.0, 1.0), //(x,y)
                                        blurRadius: 20.0,
                                      ),
                                    ]),
                                padding: const EdgeInsets.only(
                                    left: 30, top: 10, right: 30, bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Image.asset(
                                    "assest/images/hand.png",
                                    width: 30,
                                    color: Custom_color.WhiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    )
                  ]),
            ],
          ),
        ));
  }

  Future<https.Response> _GetUserDetail(String value) async {
    try {
      //_showProgress(context);
      Map jsondata = {"user_id": value};
      print("-----jsondata-----" + jsondata.toString());
      String url = WebServices.GetChatUserDetail +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      print("_GetUserDetail ##  url ==${url}");
      Map<String, String> headers = {
        "Accept": "application/json",
        "Cache-Control": "no-cache"
      };
      var response = await https.post(Uri.parse(url),
          headers: headers,
          body: jsondata,
          encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      print("_GetUserDetail ##  respnse ==${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data["status"]) {
          profilename = data["name"].toString();
          match_percent = data["match_percent"];
          you_liked = data["you_liked"];
          liked_you = data["liked_you"];

          profileImages = data["profile_img"];
          prof_interest = data["prof_interest"];
          about_me      = data["about_me"];
          professional_interest_id = data["prof_interest_id"];
          gender = data["gender_id"];
          interest = data["gender_interest"];
          miu = data["miu"];

          var social = data["social"];
          print("------social-----" + social.runtimeType.toString());
          if (social.runtimeType != String) {
            facebook = data["social"]["facebook"];
            twitter = data["social"]["twitter"];
            instagram = data["social"]["instagram"];
            tiktok = data["social"]["tiktok"];
            linkedin = data["social"]["linkedin"];
          }
          List<dynamic> imagelist = data["image"] as List;
          if (imagelist != null && imagelist.length > 0) {
            for (var i = 0; i < imagelist.length; i++) {
              images.add(imagelist[i]["name"].toString());
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              images.forEach((imageUrl) {
                precacheImage(NetworkImage(imageUrl,scale: 1.0), context);
              });
            });
          }

          var activity_list = data["activity"] as List;
          if (activity_list != null && activity_list.length > 0) {
            activitylist = activity_list
                .map<Activity_holder>(
                    (index) => Activity_holder.fromJson(index))
                .toList();
          }

          var activity_listlike = data["user_subscribe_events"] as List;
          if (activity_listlike != null && activity_listlike.length > 0) {
            bylist_activitylike = activity_listlike
                .map<UserEvent>((index) => UserEvent.fromJson(index))
                .toList();
          }

          var activity_listcreate = data["user_events"] as List;
          if (activity_listcreate != null && activity_listcreate.length > 0) {
            bylist_activitycreate = activity_listcreate
                .map<UserEvent>((index) => UserEvent.fromJson(index))
                .toList();
          }

          setState(() {
            loading = true;
          });
        } else {
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }
          setState(() {
            loading = true;
          });
        }
      }
    } on Exception catch (e) {
      setState(() {
        loading = true;
      });
      print(e.toString());
      _hideProgress();
    }
  }

  Future _asyncViewProfileDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (BuildContext context) {
        return AlertDialog(
            shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.black,
            content:
            InkWell(
             onTap: () => Navigator.pop(context),
             child : Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    width: _screenSize.width,
                    height: _screenSize.height,
                    /*decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: profileImages != null ? BoxFit.contain : BoxFit.cover,
                          image: NetworkImage(profileImages,scale: 1.0)),
                          //shape: BoxShape.circle,
                    ),*/
                  child:  PhotoView(
                    customSize: Size(_screenSize.width, _screenSize.height),
                    imageProvider: NetworkImage(profileImages,scale: 1.0)
                  )
                  ),

                // Positioned(
                //     top: 10,
                //     right: 10,
                //     child: InkWell(
                //       onTap: () {
                //         Navigator.pop(context);
                //       },
                //       child: Icon(
                //         Icons.highlight_off,
                //         size: 30,
                //         color: Custom_color.OrangeLightColor,
                //       ),
                //     ))
              ],
            )));
      },
    );
  }
//======================== Old Dialog Like  ================
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
                            .translate("Do you want to sure unlike this user"),
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
                                      Navigator.pop(context);
                                      if (await UtilMethod
                                          .SimpleCheckInternetConnection(
                                              context, _scaffoldKey)) {
                                        _DeletedInfo(routeData["user_id"]);
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

  //============ new show Alert Dislike =================

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
                              text:AppLocalizations.of(context)
                                  .translate("Do you want to sure unlike this user"),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH11,
                              fontWeight: Helper.textFontH5,
                              color: Helper.textColorBlueH1
                          ),
                        ),
                        SizedBox(height: 22,),

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
                                    if (await UtilMethod
                                        .SimpleCheckInternetConnection(
                                        context, _scaffoldKey)) {
                                      _DeletedInfo(routeData["user_id"]);
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
                              SizedBox(
                                width: MQ_Width*0.01,
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: 0,
                                    right: 0,
                                    top: MQ_Height * 0.02,
                                    bottom: 2),
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
                        radius: 60,
                        child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(profileImages,scale: 1.0)//AssetImage("assest/images/map.png"),

                        ),
                      )),

                ],),
            ),
          );
        });
  }

  Future<void> senProfessionalMessage() async {
    try {
      _showProgress(context);
      Map jsondata = {
        "user_id": routeData["user_id"],
        "time": DateTime.now().millisecondsSinceEpoch.toString()
      };
      String url = WebServices.GetMiu +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}" +
          "&user_id=" +
          routeData["user_id"];
      print(url);

      Uri uri = Uri.parse(url);
      var _request = https.MultipartRequest('POST', uri);

      _request.fields["professional_message"] = SessionManager.getString(Constant.Language_code)=="en"?messageEnglish:messageGerman;

      var streamedResponse = await _request.send();
      https.Response res = await https.Response.fromStream(streamedResponse);
      print('response.body ' + res.statusCode.toString());
      print("-----respnse----" + res.body.toString());
      _hideProgress();

      if (res.statusCode == 200) {
        var bodydata = json.decode(res.body);
        if (bodydata["status"]) {
          print(url);
          setState(() {
            miu = 1;
          });
          _hideProgress();

//

        } else {
          UtilMethod.SnackBarMessage(
              _scaffoldKey, bodydata["message"].toString());
          if (bodydata["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }
        }
      }
    } on Expanded catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future<https.Response> _DeletedInfo(String id) async {
    try {
      _showProgress(context);
      you_liked = 0;
      Map jsondata = {"user_id": id};
      // String url = WebServices.GetFavorite + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      String url = WebServices.GetUserUnLike +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      print("respnse----" + response.body);
      _hideProgress();
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"].toString());
          Future.delayed(Duration(milliseconds: 400), () {
            Navigator.pop(context, true);
          });
          // _GetUserDetail(routeData["user_id"]);
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

  Future<https.Response> _GetLikeUser(String id) async {
    try {
      _showProgress(context);
      you_liked = 1;
      Map jsondata = {"user_id": id, "type": routeData["type"]};
      String url = WebServices.GetChatUserLike +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"].toString());
          // Future.delayed(Duration(milliseconds: 400), () {
          //   Navigator.pop(context, true);
          // });
          //  sfdf
          setState(() {
            you_liked = 1;
          });
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

  Future<https.Response> _GetMiu() async {
    try {
      _showProgress(context);
      miu = 1;
      Map jsondata = {
        "user_id": routeData["user_id"],
        "time": DateTime.now().millisecondsSinceEpoch.toString()
      };
      String url = WebServices.GetMiu +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          setState(() {
            miu = 1;
          });
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"].toString());
//          Navigator.pushReplacementNamed(
//            context,
//            Constant.NavigationRoute,

//          );
        } else {
          _hideProgress();
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"].toString());
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
  //===================== Old Dialog Dislike  ==================
  Future _asyncDialogDislike1(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              //   height: 150,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Custom_color.BlueLightColor),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(profileImages,scale: 1.0),
                            radius: 30,
                          ),
                        ),
                        CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: true,
                            fontSize: 16,
                            text:
                                "${AppLocalizations.of(context).translate("Are you sure to reject")}",
                            color: Custom_color.BlackTextColor),
                        SessionManager.getString(Constant.Language_code) == "de"
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  CustomWigdet.TextView(
                                      textAlign: TextAlign.center,
                                      overflow: true,
                                      fontSize: 16,
                                      text:
                                          "${AppLocalizations.of(context).translate("profile?")}",
                                      color: Custom_color.BlackTextColor),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  CustomWigdet.TextView(
                                      textAlign: TextAlign.center,
                                      overflow: true,
                                      text: profilename,
                                      fontSize: 16,
                                      fontFamily: "OpenSans Bold",
                                      color: Custom_color.BlackTextColor),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  CustomWigdet.TextView(
                                      textAlign: TextAlign.center,
                                      overflow: true,
                                      fontSize: 16,
                                      text:
                                          "${AppLocalizations.of(context).translate("auszublenden")}",
                                      color: Custom_color.BlackTextColor),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomWigdet.TextView(
                                      textAlign: TextAlign.center,
                                      overflow: true,
                                      text: profilename,
                                      fontSize: 16,
                                      fontFamily: "OpenSans Bold",
                                      color: Custom_color.BlackTextColor),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  CustomWigdet.TextView(
                                      textAlign: TextAlign.center,
                                      overflow: true,
                                      fontSize: 16,
                                      text:
                                          "${AppLocalizations.of(context).translate("profile?")}",
                                      color: Custom_color.BlackTextColor),
                                ],
                              ),
                        SizedBox(
                          height: 2,
                        ),
                        CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: true,
                            fontSize: 12,
                            text:
                                "${AppLocalizations.of(context).translate("Once you reject, it will never show again")}",
                            color: Custom_color.BlackTextColor),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: <Widget>[
                      Divider(
                        color: Custom_color.GreyColor,
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
                                  color: Custom_color.WhiteColor,
                                ),
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: CustomWigdet.FlatButtonSimple(
                                  onPress: () {
                                    print("dddd");
                                    Navigator.pop(context);
                                    _GetIgnore();

                                  },
                                  textAlign: TextAlign.center,
                                  text: AppLocalizations.of(context)
                                      .translate("Confirm")
                                      .toUpperCase(),
                                  textColor: Custom_color.GreyLightColor,
                                ),
                              ),
                            ),
                            VerticalDivider(
                              width: 1,
                              color: Custom_color.GreyColor,
                            ),
                            Expanded(
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
                                  textColor: Custom_color.RedColor,
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
            ));
      },
    );
  }


  //============ new show Alert Dislike =================

  Future<void> _asyncDialogDislike(BuildContext context)async{

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
                        SizedBox(height: MQ_Height*0.04,),
                        Container(
                          alignment: Alignment.center,
                          child: CustomWigdet.TextView(
                            // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                              overflow: true,
                              text:AppLocalizations.of(context).translate("Are you sure to reject"),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH11,
                              fontWeight: Helper.textFontH5,
                              color: Helper.textColorBlueH1
                          ),
                        ),
                        SessionManager.getString(Constant.Language_code) == "de"
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 2,
                            ),
                            CustomWigdet.TextView(
                                textAlign: TextAlign.center,
                                overflow: true,
                                text:
                                "${AppLocalizations.of(context).translate("profile?")}",
                                fontFamily: "Kelvetica Nobis",
                                fontSize: Helper.textSizeH11,
                                fontWeight: Helper.textFontH5,
                                color: Helper.textColorBlueH1),
                            SizedBox(
                              width: 2,
                            ),
                            CustomWigdet.TextView(
                                textAlign: TextAlign.center,
                                overflow: true,
                                text: profilename,
                                fontFamily: "OpenSans Bold",
                                fontSize: Helper.textSizeH11,
                                fontWeight: Helper.textFontH5,
                                color: Helper.textColorBlueH1),
                            SizedBox(
                              width: 2,
                            ),
                            CustomWigdet.TextView(
                                textAlign: TextAlign.center,
                                overflow: true,
                                text:
                                "${AppLocalizations.of(context).translate("auszublenden")}",
                                fontFamily: "Kelvetica Nobis",
                                fontSize: Helper.textSizeH11,
                                fontWeight: Helper.textFontH5,
                                color: Helper.textColorBlueH1),
                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomWigdet.TextView(
                                textAlign: TextAlign.center,
                                overflow: true,
                                text: profilename,
                                fontFamily: "OpenSans Bold",
                                fontSize: Helper.textSizeH12,
                                fontWeight: Helper.textFontH5,
                                color: Helper.textColorBlueH1),
                            SizedBox(
                              width: 2,
                            ),
                            CustomWigdet.TextView(
                                textAlign: TextAlign.center,
                                overflow: true,
                                text:
                                "${AppLocalizations.of(context).translate("profile?")}",
                                fontFamily: "Kelvetica Nobis",
                                fontSize: Helper.textSizeH11,
                                fontWeight: Helper.textFontH5,
                                color: Helper.textColorBlueH1),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: true,
                            text:
                            "${AppLocalizations.of(context).translate("Once you reject, it will never show again")}",
                            fontFamily: "Kelvetica Nobis",
                            fontSize: Helper.textSizeH14,
                            fontWeight: Helper.textFontH5,
                            color: Helper.textColorBlueH1),
                        SizedBox(height: 22,),

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
                                    print("dddd");
                                    Navigator.pop(context);
                                    _GetIgnore();


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
                              SizedBox(
                                width: MQ_Width*0.01,
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: 0,
                                    right: 0,
                                    top: MQ_Height * 0.02,
                                    bottom: 2),
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
                        radius: 60,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(profileImages,scale: 1.0)//AssetImage("assest/images/map.png"),

                        ),
                      )),

                ],),
            ),
          );
        });
  }

  Future<https.Response> _GetIgnore() async {
    try {
      print("eee");
      _showProgress(context);
      Map jsondata = {
        "ignore_user_id": routeData["user_id"],
        "type": routeData["type"]
      };
      String url = WebServices.GetIgnore +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("con1 :: "+data['status'].toString());
        if (data["status"]) {
          print("con2 :: "+data['status'].toString());
           //Navigator.pushNamed(context, Constant.NavigationRoute);
           Navigator.pop(context);
         // UtilMethod.SnackBarMessage(_scaffoldKey, data["message"].toString());
        } else {
          //UtilMethod.SnackBarMessage(_scaffoldKey, data["message"].toString());
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

  String _getListactiviyitem(List<Activity_holder> list) {
    StringBuffer value = new StringBuffer();
    List<Activity_holder>.generate(list.length, (index) {
      if (list[index].percent > 0) {
        String s = list[index].name+" ("+list[index].percent.toString()+"/10)";
        value.write(s);
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

  //=================== child Ui Interest Report ==========
  Widget  _widgetGetListActiviyitem(List<Activity_holder> list) {
    /*StringBuffer value = new StringBuffer();
    List<Activity_holder>.generate(list.length, (index) {
      if (list[index].percent > 0) {
        String s = list[index].name+" ("+list[index].percent.toString()+"/10)";
        value.write(s);
        if ((list.length) == (index + 1)) {
        } else {
          value.write(", ");
        }
      }
    });*/

    //value.writeln()
    return list.length!=0?Container(
      //height: MQ_Height*0.27,

      child: ListView.builder(
           shrinkWrap: true,
          itemCount: list.length,
          physics:  NeverScrollableScrollPhysics(),
          controller: ScrollController(keepScrollOffset: false),
          itemBuilder: (BuildContext context, index){
           return  Column(
             children: [
               Container(
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Container(
                       alignment: Alignment.centerLeft,
                       child: Text('${list[index].name}',
                         style: TextStyle(color:Color(Helper.textColorBlackH2),
                             fontWeight: Helper.textFontH6,fontSize: Helper.textSizeH15,
                             fontFamily: "itc avant medium"
                         ),),
                     ),
                     Container(
                       alignment: Alignment.centerLeft,
                       child: Text('${list[index].percent.toString()}/10',
                         style: TextStyle(color:Color(0xfffb4592),
                             fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH15,
                             fontFamily: "itc avant medium"
                         ),),
                     ),
                   ],
                 ),
               ),
               index<list.length-1?Container(
                 margin: EdgeInsets.only(top:5,bottom: 5),

                 width: MQ_Width*0.80,
                 height: 1,
                 color: Color(Helper.textBorderLineColorH1),
               ):Container(),
             ],
           );
          }),
    ):
    Container(
        child: Text(''),
    );
  }

  String _getInterest(int name) {
    String value = "";
    if (name == 0) {
      value = "";
    } else if (name == 1) {
      value = AppLocalizations.of(context).translate("MEN");
    } else if (name == 2) {
      value = AppLocalizations.of(context).translate("WOMEN");
    } else if (name == 3) {
      value =
          "${AppLocalizations.of(context).translate("MEN")}, ${AppLocalizations.of(context).translate("WOMEN")}";
    }
    return value;
  }

  String _getProfessional(int name) {
    String value = "";
    if (name == 0) {
      value = "";
    } else if (name == 1) {
      value = AppLocalizations.of(context).translate("Looking for job");
    } else if (name == 2) {
      value = AppLocalizations.of(context).translate("Providing Job");
    } else if (name == 3) {
      value =
          "${AppLocalizations.of(context).translate("Looking for job")}, ${AppLocalizations.of(context).translate("Providing Job")}";
    } else if (name == 4) {
      value = AppLocalizations.of(context).translate("No");
    }
    return value;
  }

 _showProgress(BuildContext context) {
    setState(() {
      showLoading = true;
    });
    Constant.needsReloading = true;
    // progressDialog = new ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    // progressDialog.style(
    //     message: AppLocalizations.of(context).translate("Loading"),
    //     progressWidget: CircularProgressIndicator());
    // progressDialog.show();
  }

  _hideProgress() {
    setState(() {
      showLoading = false;
    });
  }
}
