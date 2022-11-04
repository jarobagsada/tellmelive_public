import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/screen/nagivation_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/activity_holder.dart';
import 'package:miumiu/screen/holder/user_event.dart';
import 'package:miumiu/screen/settings/edit_profile/edit_myprofile.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/helper.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../../../utilmethod/fluttertoast_alert.dart';
import '../../../utilmethod/network_connectivity.dart';
import '../../../utilmethod/showDialog_networkerror.dart';

class Profile_Screen extends StatefulWidget {
  @override
  _Profile_ScreenState createState() => _Profile_ScreenState();
}

class _Profile_ScreenState extends State<Profile_Screen> {
  Size _screenSize;
  var routeData;
  int _current = 0;
  var name, name_demo, interest, prof_interest, gender, dob, profile_image , about_me ,about_myself;
  ProgressDialog progressDialog;
  List<dynamic> images = [];
  List<Activity_holder> activitylist = [];
  bool loading;
  List<dynamic> imagelist = [];
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<UserEvent> bylist_activitylike = [];
  List<UserEvent> bylist_activitycreate = [];
  bool joined_expand;
  bool create_expand;
  String facebook="0", twitter="0", instagram="0", tiktok="0", linkedin="0";
  String aboutChangedTxt;
  var MQ_Height;
  var MQ_Width;
  bool checkRefresh = false;
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _connectivity = NetworkConnectivity.instance;
  bool networkEnable=true;
  @override
  void initState() {
    super.initState();
    loading = true;
    joined_expand = false;
    create_expand = false;
    aboutChangedTxt  = "";

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() {
          _source = source;
          print('Profile ## source =$source, \n#c _source=${_source.keys.toList()[0]}');
          if(_source.keys.toList()[0]==ConnectivityResult.wifi){
            print('Profile ## ConnectivityResult.wifi _source=${_source.keys.toList()[0]}');
            networkEnable = true ;
          }
          else if(_source.keys.toList()[0]==ConnectivityResult.mobile){
            print('Profile ## ConnectivityResult.mobile _source=${_source.keys.toList()[0]}');
            networkEnable = true ;
          }else{
            print('Profile ## ConnectivityResult.none _source=${_source.keys.toList()[0]}');
            networkEnable = false ;
          }

        });
      }
    });

   if(networkEnable==true) {
     WidgetsBinding.instance.addPostFrameCallback((_) async {
       if (await UtilMethod.SimpleCheckInternetConnection(
           context, _scaffoldKey)) {
         if (mounted) {
           setState(() {
           _GetProfile();
         });
         }
       }
     });
   }else{
     if(mounted) {
       setState(() {
       checkRefresh=true;
       loading=false;
     });
     }
   }

    Future.delayed(const Duration(seconds: 20),(){
      if(mounted) {
        setState(() {
        checkRefresh=true;
      });
      }
      //   FlutterToastAlert.flutterToastMSG('checkRefresh=$checkRefresh', context);
    });

  }



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    try{
      _connectivity.disposeStream();
      _source.clear();
    }catch(error){
      print('_connectivity disponse error=$error');
    }

  }


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
  Widget build(BuildContext context) {


    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    _screenSize = MediaQuery.of(context).size;
    routeData = ModalRoute.of(context).settings.arguments;
    try{
      String string;
      print('_source : ${_source.keys.toList()[0]}');
      Future.delayed(const Duration(seconds: 2),() {
        switch (_source.keys.toList()[0]) {
          case ConnectivityResult.mobile:
            string = 'Mobile: Online';
            // FlutterToastAlert.flutterToastMSG('Mobile: Online', context);
            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('Profile Mobile networkEnable: $networkEnable');
                networkEnable = true;
                checkRefresh = true;
              });
            } catch (error) {
              print('Profile Mobile error: $error');
              networkEnable = true;
              checkRefresh = true;
            }
            break;
          case ConnectivityResult.wifi:
            string = 'Wifi: Online';
            //  FlutterToastAlert.flutterToastMSG('WiFi: Online', context);

            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('Profile Wifi networkEnable: $networkEnable');

                networkEnable = true;
                checkRefresh = true;
              });
            } catch (error) {
              print('Profile WiFi error: $error');
              networkEnable = true;
              checkRefresh = true;
            }

            break;
          case ConnectivityResult.none:
            string = 'Offline';
            // FlutterToastAlert.flutterToastMSG('Offline', context);
            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('Profile Offline networkEnable: $networkEnable');
                networkEnable = false;
                checkRefresh = true;
              });
            } catch (error) {
              print('Profile Offline error: $error');
              networkEnable = false;
              checkRefresh = true;
            }
            break;
          default:
        }
      });

    }catch(error){
      print('***** error=$error');
    }

    return SafeArea(

      child: Scaffold(
       // backgroundColor: Helper.inBackgroundColor,
        key: _scaffoldKey,
        body: Visibility(

            visible: networkEnable&&loading,
            replacement: checkRefresh!=true?Center(
              child: false? CircularProgressIndicator():
              Container(
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
            ):networkEnable==true?_widgetLoaderRefresh():_widgetNetworkConnectivity(),
            child:
           // _widgetProfile()
           _widgetNewUIProfile()
        ),
      ),
    );
  }



  //=========== Old UI ===
   Widget _widgetProfile(){
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(

                        width: _screenSize.width,
                        height: ((_screenSize.height / 2) - 50),

                        color: Custom_color.BlackTextColor.withOpacity(
                            0.3),
                      ),
                      Container(
                          width: _screenSize.width,
                          height: ((_screenSize.height / 2) - 50),
                          child: images.isNotEmpty
                              ? CarouselSlider.builder(
                            itemCount: images == null
                                ? 0
                                : images.length,
                            options: CarouselOptions(
                                height: _screenSize.height,
                                autoPlay: images.length == 1
                                    ? false
                                    : true,
                                viewportFraction: 1.5,
                                // aspectRatio: 2.0,
                                // enlargeCenterPage: true,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                }),
                            itemBuilder: (context, index) {
                              return Container(
                                  child: CustomWigdet
                                      .GetImagesNetwork(
                                      imgURL: images[index],
                                      width:_screenSize.width,
                                      height: _screenSize.height,
                                      boxFit:
                                      BoxFit.cover));
                            },
                          )
                              : Container(
                            color: Custom_color.PlacholderColor,
                            child: Center(
                              child: CustomWigdet.TextView(
                                  text: AppLocalizations.of(
                                      context)
                                      .translate(
                                      "Currently there is no gallery"),
                                  color: Custom_color
                                      .BlackTextColor),
                            ),
                          )),

                      Image(image: AssetImage("assest/images/curve.png"),),
                      !UtilMethod.isStringNullOrBlank( profile_image )
                          ? Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            onTap: (){
                              print("----ds-f-ds-d-g-f-gd-fg--------");
                              if(profile_image!=null){
                                Navigator.pushNamed(
                                    context, Constant.ProfileImage,
                                    arguments:{"gender":gender,"profile_img":profile_image,"imagelist":imagelist!=null?imagelist:[]}).then((
                                    value) => _GetCallBackMethod(value));
                                //_asyncViewProfileDialog(context);
                              }
                            },
                            child: Container(
                              height: 160.0,
                              width: 160.0,
                              decoration: BoxDecoration(
                                boxShadow: [

                                  BoxShadow(
                                    color: Color(0xffe4e9ef),
                                    offset: Offset(1.0, 1.0), //(x,y)
                                    blurRadius: 15.0,
                                  ),


                                ],
                                color: Custom_color
                                    .PlacholderColor,
                                image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      profile_image,scale: 1.0),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                  Custom_color.WhiteColor,
                                  width: 5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                          : Container(),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: _screenSize.width,
                        padding: EdgeInsets.all(2),
                        child: CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            text: name,
                            color: Custom_color.BlackTextColor,
                            fontFamily: "OpenSans",
                            fontSize: 18),
                      ),

                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: _screenSize.width,
                        padding: EdgeInsets.all(2),
                        // child: CustomWigdet.TextView(
                        //     text:
                        //         gender != null ? _getGender(gender) : gender,
                        //     textAlign: TextAlign.center,
                        //     overflow: true,
                        //     color: Custom_color.GreyLightColor),
                        child: Image.asset(gender!=null && gender==1? "assest/images/female1.png":"assest/images/male.png",width: 16,height: 16,),
                      ),

                    ],
                  ),
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2),
                        width: _screenSize.width,
                        child: CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: true,
                            text: dob,
                            color: Custom_color.GreyLightColor,
                            fontFamily: "itc avant medium"),
                      ),

                    ],
                  ),
                  // Column(
                  //   children: [
                  //     Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //          facebook == "1"
                  //             ? Container(
                  //                 margin: EdgeInsets.only(
                  //                     top: 5, left: 5, right: 5),
                  //                 child: Image.asset(
                  //                   "assest/images/fb_color.png",
                  //                   width: 16,
                  //                   height: 16,
                  //                 ),
                  //               )
                  //             : Container(),
                  //          twitter == "1"
                  //             ? Container(
                  //                 margin: EdgeInsets.only(
                  //                     top: 5, left: 5, right: 5),
                  //                 child: Image.asset(
                  //                   "assest/images/twitter_color.png",
                  //                   width: 16,
                  //                   height: 16,
                  //                 ),
                  //               )
                  //             : Container(),
                  //          instagram == "1"
                  //             ? Container(
                  //                 margin: EdgeInsets.only(
                  //                     top: 5, left: 5, right: 5),
                  //                 child: Image.asset(
                  //                   "assest/images/insta_color.png",
                  //                   width: 16,
                  //                   height: 16,
                  //                 ),
                  //               )
                  //             : Container(),
                  //         tiktok == "1"
                  //             ? Container(
                  //                 margin: EdgeInsets.only(
                  //                     top: 5, left: 5, right: 5),
                  //                 child: Image.asset(
                  //                   "assest/images/tik_tok_color.png",
                  //                   width: 16,
                  //                   height: 16,
                  //                 ),
                  //               )
                  //             : Container(),
                  //         linkedin == "1"
                  //             ? Container(
                  //                 margin: EdgeInsets.only(
                  //                     top: 5, left: 5, right: 5),
                  //                 child: Image.asset(
                  //                   "assest/images/linkedin_color.png",
                  //                   width: 16,
                  //                   height: 16,
                  //                 ),
                  //               )
                  //             : Container(),
                  //         (facebook == "0" && twitter == "0" && instagram == "0" && tiktok == "0" && linkedin == "0")
                  //             ? CustomWigdet.TextView(
                  //                 textAlign: TextAlign.center,
                  //                 overflow: true,
                  //                 text: AppLocalizations.of(context)
                  //                     .translate(
                  //                         "No Social Media Connected"),
                  //                 color: Custom_color.GreyLightColor)
                  //             : Container()
                  //       ],
                  //     ),
                  //   ],
                  // ),





                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: _screenSize.width,
                    padding: const EdgeInsets.only(
                        top: 10, right: 14, left: 14, bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(


                          width: _screenSize.width,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              ClipShadowPath(
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),

                                shadow:   BoxShadow(
                                  color: Color(0xffe4e9ef),
                                  offset: Offset(1.0, 1.0), //(x,y)
                                  blurRadius: 15.0,
                                ),
                                child: Container(

                                  constraints:
                                  BoxConstraints(maxHeight: about_myself == null ? 110 : (about_myself.toString().length < 85 ? 110 : 150), maxWidth: 320),
                                  decoration: BoxDecoration(

                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(width: 8.0, color: Color(0xff1b98ea)),
                                      )
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),

                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top:20,

                                left: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?30:null,
                                right: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?null:10,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: Card(
                                    elevation: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(4),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                ( gender!=null && gender==1) ? "assest/images/woman_n.png":"assest/images/man_n.png",
                                              ),
                                              fit: BoxFit.contain)),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child:
                                InkWell(
                                    onTap: () =>{
                                      toggleAboutMeDialog()
                                    },
                                    child : Padding(
                                      padding: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?const EdgeInsets.only(
                                          top: 5,
                                          right: 15,
                                          bottom: 5,
                                          left: 140):const EdgeInsets.only(
                                          top: 5,
                                          right: 140,
                                          bottom: 5,
                                          left: 15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children:[
                                                CustomWigdet.TextView(
                                                    overflow: true,
                                                    text: AppLocalizations.of(
                                                        context)
                                                        .translate(
                                                        "About me"),
                                                    fontFamily: "Kelvetica Nobis",
                                                    color: Color(0xff1e7fc4),
                                                    fontSize: 16),
                                                Image.asset("assest/images/edit.png",width:12,color:Colors.grey.shade600)
                                              ]
                                          ),


                                          Padding(
                                            padding: const EdgeInsets.only(right: 150.0),
                                            child: Divider(thickness: 2,
                                              color: Color(0xfffb4592),
                                            ),
                                          ),
                                          Text(
                                            about_myself != null ? about_myself : "",
                                            style: TextStyle(color:Custom_color.GreyLightColor),
                                          ),

                                        ],
                                      ),
                                    )),
                              )
//
                            ],
                          ),
                        ),



                        SizedBox(height: 10,),

                        Container(


                          width: _screenSize.width,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              ClipShadowPath(
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),

                                shadow:   BoxShadow(
                                  color: Color(0xffe4e9ef),
                                  offset: Offset(1.0, 1.0), //(x,y)
                                  blurRadius: 15.0,
                                ),
                                child: Container(

                                  constraints:
                                  BoxConstraints(maxHeight: 110, maxWidth: 320),
                                  decoration: BoxDecoration(


                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(width: 8.0, color: Color(0xff1b98ea)),
                                      )
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),

                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top:20,

                                left: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?30:null,
                                right: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?null:10,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: Card(
                                    elevation: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(4),
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "assest/images/give-love.png"),
                                            fit: BoxFit.contain
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?const EdgeInsets.only(
                                      top: 5,
                                      right: 15,
                                      bottom: 5,
                                      left: 140):const EdgeInsets.only(
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
                                          text: AppLocalizations.of(
                                              context)
                                              .translate("Interest_an"),
                                          fontFamily: "Kelvetica Nobis",
                                          color: Color(0xff1e7fc4),
                                          fontSize: 16),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 150.0),
                                        child: Divider(thickness: 2,
                                          color: Color(0xfffb4592),
                                        ),
                                      ),

                                      CustomWigdet.TextView(
                                          text: interest != null
                                              ? _getInterest(interest)
                                              : "",
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
                          width: _screenSize.width,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              ClipShadowPath(
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),

                                shadow:   BoxShadow(
                                  color: Color(0xffe4e9ef),
                                  offset: Offset(1.0, 1.0), //(x,y)
                                  blurRadius: 15.0,
                                ),
                                child: Container(

                                  constraints:
                                  BoxConstraints(maxHeight: 110, maxWidth: 320),
                                  decoration: BoxDecoration(

                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.grey,
                                    //     offset: Offset(1.0, 1.0), //(x,y)
                                    //     blurRadius: 20.0,
                                    //   ),
                                    //
                                    // ],
                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(width: 8.0, color: Color(0xff1b98ea)),
                                      )
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),

                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top:20,

                                left: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?30:null,
                                right: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?null:10,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: Card(
                                    elevation: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(4),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assest/images/lifestyle.png"),
                                              fit: BoxFit.contain)),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?const EdgeInsets.only(
                                      top: 5,
                                      right: 15,
                                      bottom: 5,
                                      left: 140):const EdgeInsets.only(
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
                                          text: AppLocalizations.of(
                                              context)
                                              .translate(
                                              "Activity describes most"),
                                          fontFamily: "Kelvetica Nobis",
                                          color: Color(0xff1e7fc4),
                                          fontSize: 16),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 150.0),
                                        child: Divider(thickness: 2,
                                          color: Color(0xfffb4592),
                                        ),
                                      ),
                                      CustomWigdet.TextView(
                                          overflow: true,
                                          text: activitylist != null
                                              ? _getListactiviyitem(
                                              activitylist)
                                              : "",
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


                          width: _screenSize.width,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              ClipShadowPath(
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),

                                shadow:   BoxShadow(
                                  color: Color(0xffe4e9ef),
                                  offset: Offset(1.0, 1.0), //(x,y)
                                  blurRadius: 15.0,
                                ),
                                child: Container(

                                  constraints:
                                  BoxConstraints(maxHeight: 110, maxWidth: 320),
                                  decoration: BoxDecoration(

                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(width: 8.0, color: Color(0xff1b98ea)),
                                      )
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),

                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top:20,

                                left: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?30:null,
                                right: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?null:10,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: Card(
                                    elevation: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(4),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                "assest/images/handshake.png",
                                              ),
                                              fit: BoxFit.contain)),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?const EdgeInsets.only(
                                      top: 5,
                                      right: 15,
                                      bottom: 5,
                                      left: 140):const EdgeInsets.only(
                                      top: 5,
                                      right: 140,
                                      bottom: 5,
                                      left: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomWigdet.TextView(
                                          overflow: true,
                                          text: AppLocalizations.of(
                                              context)
                                              .translate(
                                              "Professional interest"),
                                          fontFamily: "Kelvetica Nobis",
                                          color: Color(0xff1e7fc4),
                                          fontSize: 16),

                                      Padding(
                                        padding: const EdgeInsets.only(right: 150.0),
                                        child: Divider(thickness: 2,
                                          color: Color(0xfffb4592),
                                        ),
                                      ),
                                      CustomWigdet.TextView(
                                          overflow: true,
                                          text: prof_interest != null
                                              ? _getProfessional(
                                              prof_interest)
                                              : "",
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
                          padding:
                          const EdgeInsets.only(bottom: 14.0),
                          child: Card(
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment:Alignment.centerRight,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left:10.0,top: 14,bottom: 14,right: 10),
                                      color: Custom_color.GreyLightColor2,
                                      width: _screenSize.width,
                                      child:
                                      CustomWigdet.TextView(
                                        text: AppLocalizations.of(
                                            context)
                                            .translate(
                                            "Activity Enrolled"),
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
                                      bylist_activitylike.length,
                                          (index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context,
                                                Constant
                                                    .ActivityUserDetail,
                                                arguments: {
                                                  "event_id":
                                                  bylist_activitylike[
                                                  index]
                                                      .id,
                                                  "action": Constant
                                                      .ActivityWall,
                                                  "isSub":
                                                  bylist_activitylike[
                                                  index]
                                                      .is_subs
                                                }).then((value) {
                                              if (value) {
                                                setState(() {
                                                  loading= false;
                                                  _GetProfile();
                                                });
                                              }
                                            } );
                                          },
                                          child: Container(
                                              width:
                                              _screenSize.width,
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(colors: [Color(0xff23b8f2), Color(0xff1b5dab)],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter)
                                              ),
                                              child: !joined_expand
                                                  ? index < 2
                                                  ? Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .all(
                                                        10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: CustomWigdet.TextView(
                                                              text: bylist_activitylike[index]
                                                                  .title,
                                                              color: Custom_color
                                                                  .WhiteColor),
                                                        ),
                                                        Icon(Icons.arrow_forward_ios,size: 16,color: Custom_color.WhiteColor,)
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(height: 1,thickness: 0.5,color: Custom_color.WhiteColor,)
                                                ],
                                              )
                                                  : Container()
                                                  : Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(
                                                        10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: CustomWigdet.TextView(
                                                              text: bylist_activitylike[
                                                              index]
                                                                  .title,
                                                              color: Custom_color
                                                                  .WhiteColor),
                                                        ),
                                                        Icon(Icons.arrow_forward_ios,size: 16,color: Custom_color.WhiteColor,)
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(height: 1,thickness: 0.5,color: Custom_color.WhiteColor,)
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
                            bylist_activitylike.length > 2
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
                          padding:
                          const EdgeInsets.only(bottom: 14.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ) ,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment:Alignment.centerRight ,
                                  children: [
                                    Container(
                                      padding:
                                      const EdgeInsets.only(left:10.0,top:14,bottom:14,right: 10),
                                      color: Custom_color.GreyLightColor2,
                                      width: _screenSize.width,
                                      child:
                                      CustomWigdet.TextView(
                                        text: AppLocalizations.of(
                                            context)
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
                                        color: Custom_color.WhiteColor,
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
                                              "event_id":
                                              bylist_activitycreate[
                                              index]
                                                  .id,
                                              "action": Constant
                                                  .Activity
                                            }).then((value){
                                          if (value == Constant.Activity) {
                                            print("-------value edit profile----"+value);
                                            setState(() {
                                              loading= false;
                                              _GetProfile();
                                            });

                                          }
                                        });
                                      },
                                      child: Container(
                                          width:
                                          _screenSize.width,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [Color(0xff23b8f2), Color(0xff1b5dab)],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter)
                                          ),
                                          child: !create_expand
                                              ? index < 2
                                              ? Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets
                                                    .all(
                                                    10.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: CustomWigdet.TextView(
                                                          text: bylist_activitycreate[index]
                                                              .title,
                                                          color: Custom_color
                                                              .WhiteColor),
                                                    ),
                                                    Icon(Icons.arrow_forward_ios,size: 16,color: Custom_color.WhiteColor,)
                                                  ],
                                                ),
                                              ),
                                              Divider(height: 1,thickness: 0.5,color: Custom_color.WhiteColor,)
                                            ],
                                          )
                                              : Container()
                                              : Column(
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(
                                                    10.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: CustomWigdet.TextView(
                                                          text: bylist_activitycreate[
                                                          index]
                                                              .title,
                                                          color: Custom_color
                                                              .WhiteColor),
                                                    ),
                                                    Icon(Icons.arrow_forward_ios,size: 16,color: Custom_color.WhiteColor,)
                                                  ],
                                                ),
                                              ),
                                              Divider(height: 1,thickness: 0.5,color: Custom_color.WhiteColor,)
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
                            bylist_activitycreate.length > 2
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
              ),
            ),
          ),
        ],
      ),
    );
   }

  Widget _widgetLoaderRefresh(){

    return checkRefresh!=false?Center(
      child: Container(
        //height: MQ_Height,
        //color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [

              Container(
                  margin: EdgeInsets.only(top: MQ_Height*0.02),
                  child:
                  Image(image: AssetImage('assest/images/activity_wall.png'))),

              Container(
                margin: EdgeInsets.only(top: MQ_Height*0.05),
                alignment: Alignment.center,
                child:CustomWigdet.TextView(
                  overflow: true,
                  textAlign: TextAlign.center,
                  text:AppLocalizations.of(context)
                      .translate("Oops"),
                  color: Helper.textColorBlueH1,
                  fontWeight: Helper.textFontH4,
                  fontSize: Helper.textSizeH8,
                  fontFamily: "Kelvetica Nobis",
                ),

              ),

              Container(
                margin: EdgeInsets.only(top: MQ_Height*0.02),
                padding: EdgeInsets.only(left: MQ_Width*0.15,right: MQ_Width*0.15),
                alignment: Alignment.center,
                child:CustomWigdet.TextView(
                  overflow: true,
                  textAlign: TextAlign.center,
                  text:AppLocalizations.of(context)
                      .translate("Something went wrong.Let's give this another try"),
                  color: Color(Helper.textColorBlackH2).withOpacity(0.7),
                  fontWeight: Helper.textFontH4,
                  fontSize: Helper.textSizeH14,
                  fontFamily: "Kelvetica Nobis",
                ),

              ),

              SizedBox(height: MQ_Height*0.03,),

              ElevatedButton(onPressed: ()async{
                if(networkEnable==true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (await UtilMethod.SimpleCheckInternetConnection(
                        context, _scaffoldKey)) {
                      setState(() {
                        checkRefresh = false;
                      });
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Constant.NavigationRoute,
                          ModalRoute.withName(Constant.WelcomeRoute),
                          arguments: {"index": 1, "index_home": 0});
                    }
                  });
                }else{
                  //FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
                  ShowDialogNetworkError.showDialogNetworkErrorMessage(context, 'Network', '${AppLocalizations.of(context).translate("Please connect your internet")}', 0, 'network', MQ_Width, MQ_Height);

                }
              },
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),

                  child: Text(AppLocalizations.of(context)
                      .translate("Try again"),style:TextStyle(fontWeight: FontWeight.w500,fontSize: 15) ,))
            ],
          ),
        ),
      ),
    ):Center(
      child: Container(
        margin: EdgeInsets.only(top: MQ_Height*0.25),
        alignment: Alignment.center,
        child:CustomWigdet.TextView(
          overflow: true,
          textAlign: TextAlign.center,
          text: AppLocalizations.of(context)
              .translate("Please Wait Loading"),
          color: Custom_color.GreyColor,
          fontWeight: Helper.textFontH4,
          fontSize: Helper.textSizeH8,
          fontFamily: "Kelvetica Nobis",
        ),

      ),
    );
  }

  Widget _widgetNetworkConnectivity(){
    return Center(
      child: Container(
        //height: MQ_Height,
        //color: Colors.white,

        child: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Container(
                  margin: EdgeInsets.only(top: MQ_Height*0.05),
                  child: false?Image(image: AssetImage('assest/images/no_internet.png')):Icon(Icons.network_check,size: 250,color: Colors.grey.shade500,)),

              Container(
                margin: EdgeInsets.only(top: MQ_Height*0.05),
                alignment: Alignment.center,
                child:CustomWigdet.TextView(
                  overflow: true,
                  textAlign: TextAlign.center,
                  text:AppLocalizations.of(context).translate("No internet connection"),
                  color: Helper.textColorBlueH1,
                  fontWeight: Helper.textFontH4,
                  fontSize: Helper.textSizeH8,
                  fontFamily: "Kelvetica Nobis",
                ),

              ),

              Container(
                margin: EdgeInsets.only(top: MQ_Height*0.02),
                padding: EdgeInsets.only(left: MQ_Width*0.15,right: MQ_Width*0.15),
                alignment: Alignment.center,
                child:CustomWigdet.TextView(
                  overflow: true,
                  textAlign: TextAlign.center,
                  text:AppLocalizations.of(context)
                      .translate("Make sure that WiFi or mobile data is turned on,then try again"),
                  color: Color(Helper.textColorBlackH2).withOpacity(0.7),
                  fontWeight: Helper.textFontH4,
                  fontSize: Helper.textSizeH14,
                  fontFamily: "Kelvetica Nobis",
                ),

              ),

              SizedBox(height: MQ_Height*0.03,),


              ElevatedButton(onPressed: ()async{
                if(networkEnable==true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (await UtilMethod.SimpleCheckInternetConnection(
                        context, _scaffoldKey)) {
                      setState(() {
                        checkRefresh = false;
                      });
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Constant.NavigationRoute,
                          ModalRoute.withName(Constant.WelcomeRoute),
                          arguments: {"index": 1, "index_home": 0});
                    }
                  });
                }else{
                 // FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
                  ShowDialogNetworkError.showDialogNetworkErrorMessage(context, 'Network', '${AppLocalizations.of(context).translate("Please connect your internet")}', 0, 'network', MQ_Width, MQ_Height);

                }
              },
                  style: ElevatedButton.styleFrom(shape: StadiumBorder(),
                    // minimumSize: Size(200, 50)
                  ),

                  child: Text(AppLocalizations.of(context).translate("Try again"),
                    style:TextStyle(fontWeight: FontWeight.w500,fontSize: 15) ,))
            ],
          ),
        ),
      ),
    );
  }


  //=========== Profile New UI ===
  Widget _widgetNewUIProfile(){
    return Container(
      color:Color(Helper.inBackgroundColor1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(

                        width: _screenSize.width,
                        height: ((_screenSize.height / 2) - 50),

                      //  color: Custom_color.BlackTextColor.withOpacity(0.3),

                      ),
                      Container(
                          width: _screenSize.width,
                          height: ((_screenSize.height / 2) - 50),
                          child: images.isNotEmpty
                              ? CarouselSlider.builder(
                            itemCount: images == null
                                ? 0
                                : images.length,
                            options: CarouselOptions(
                                height: _screenSize.height,
                                autoPlay: images.length == 1
                                    ? false
                                    : true,
                                viewportFraction: 1.5,
                                // aspectRatio: 2.0,
                                // enlargeCenterPage: true,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                }),
                            itemBuilder: (context, index) {
                              return Container(
                                  child: CustomWigdet
                                      .GetImagesNetwork(
                                      imgURL: images[index],
                                      width:_screenSize.width,
                                      height: _screenSize.height,
                                      boxFit:
                                      BoxFit.cover));
                            },
                          )
                              : Container(
                            color: Custom_color.PlacholderColor,

                            child: Center(
                              child: CustomWigdet.TextView(
                                  text: AppLocalizations.of(
                                      context)
                                      .translate(
                                      "Currently there is no gallery"),
                                  color: Custom_color
                                      .GreyLightColor,
                                fontSize: Helper.textSizeH12,
                                fontWeight: Helper.textFontH4
                              ),

                            ),
                          )),

                      //Image(image: AssetImage("assest/images/curve.png",),),

                      Image.asset('assest/images/curve.png',
                        color:Color(Helper.inBackgroundColor1),),
                    //  !UtilMethod.isStringNullOrBlank( profile_image )
                        false ? Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            onTap: (){
                              print("----ds-f-ds-d-g-f-gd-fg--------");
                              if(profile_image!=null){
                                Navigator.pushNamed(
                                    context, Constant.ProfileImage,
                                    arguments:{"gender":gender,"profile_img":profile_image,"imagelist":imagelist!=null?imagelist:[]}).then((
                                    value) => _GetCallBackMethod(value));
                                //_asyncViewProfileDialog(context);
                              }
                            },
                            child: Container(
                              height: 160.0,
                              width: 160.0,
                              decoration: BoxDecoration(
                                boxShadow: [

                                  BoxShadow(
                                    color: Color(0xffe4e9ef),
                                    offset: Offset(1.0, 1.0), //(x,y)
                                    blurRadius: 15.0,
                                  ),


                                ],
                                color: Custom_color
                                    .PlacholderColor,
                                image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      profile_image),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                  Custom_color.WhiteColor,
                                  width: 5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ):Container(),
                          true?Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          print("----ds-f-ds-d-g-f-gd-fg--------");
                                          /* if(image!=null){
                                            Navigator.pushNamed(
                                                context, Constant.ProfileImage,
                                                arguments:{"gender":gender,"profile_img":profile_image,"imagelist":imagelist!=null?imagelist:[]}).then((
                                                value) => _GetCallBackMethod(value));
                                            //_asyncViewProfileDialog(context);
                                          }*/
                                        },
                                        child: false?Container(
                                          height: 160.0,
                                          width: 160.0,
                                          decoration: BoxDecoration(
                                            boxShadow: [

                                              BoxShadow(
                                                color: Color(0xffe4e9ef),
                                                offset: Offset(1.0, 1.0), //(x,y)
                                                blurRadius: 15.0,
                                              ),


                                            ],
                                            color: Custom_color
                                                .PlacholderColor,
                                            image: new DecorationImage(
                                              fit: BoxFit.fill,
                                              image:!UtilMethod.isStringNullOrBlank( profile_image )? NetworkImage(
                                                  profile_image,scale: 1.0):AssetImage('assest/images/user2.png'),
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                              Custom_color.WhiteColor,
                                              width: 5,
                                            ),
                                          ),
                                        ):
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Custom_color.BlueLightColor,width: 0.2),
                                              gradient: LinearGradient(
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,

                                                colors: [
                                                  // Color(0XFF8134AF),
                                                  // Color(0XFFDD2A7B),
                                                  // Color(0XFFFEDA77),
                                                  // Color(0XFFF58529),
                                                  // gender!=null && gender==1?  Color(0xfffb4592).withOpacity(0.3):
                                                  Colors.blue.withOpacity(0.3),
                                                  // gender!=null && gender==1?  Color(0xfffb4592).withOpacity(0.3):
                                                  Colors.blue.withOpacity(0.4),

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
                                                image: !UtilMethod.isStringNullOrBlank(profile_image )?NetworkImage(
                                                    profile_image,scale: 1.0):AssetImage('assest/images/user2.png'),
                                              ),
                                              border: Border.all(color: Custom_color.BlueLightColor,width: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 95,
                                        right: -1,
                                        child: GestureDetector(

                                          onTap: (){
                                            Navigator.pushNamed(
                                                context, Constant.ProfileImage,
                                                arguments:{"gender":gender,"profile_img":profile_image,"imagelist":imagelist!=null?imagelist:[],
                                                  "index":1}).then((
                                                value) => _GetCallBackMethod(value));
                                            //_asyncViewProfileDialog(context);
                                            print("Edit Profile");

                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: Color(0xffe4e9ef),
                                              //     offset: Offset(1.0, 1.0), //(x,y)
                                              //     blurRadius: 20.0,
                                              //   ),
                                              //
                                              // ]
                                            ),
                                            child: CircleAvatar(

                                              radius: 17,
                                              backgroundColor: Colors.white,
                                              child: Image(image: AssetImage("assest/images/camera.png"),
                                                color:Colors.blue,//Color(Helper.inIconColorPinkH1),
                                                width: 18,
                                                height: 18,

                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ):Container(),

                    ],
                  ),
                  SizedBox(
                    height: MQ_Height*0.02,
                  ),


                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                          child: CustomWigdet.TextView(
                              textAlign: TextAlign.center,
                              text: name,
                              color: Helper.textColorBlueH1,//Custom_color.BlackTextColor,
                             fontFamily: "OpenSans",
                              fontWeight: Helper.textFontH5,
                              fontSize:Helper.textSizeH11),
                        ),

                        Container(
                          margin: EdgeInsets.only(left: MQ_Width*0.01,),
                          // width: _screenSize.width,
                          padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),

                          alignment: Alignment.topCenter,
                          child:
                          ClipOval(
                            child: Material(
                              color: Helper.inIconCircleGreyColor1, // Button color
                              child: InkWell(
                                splashColor: Helper.inIconCircleGreyColor1, // Splash color
                                onTap: () {},
                                child: false?SizedBox(width: 20, height: 20,
                                    child:true?Icon(Icons.edit,color:Helper.inIconGreyColor1,size: 16,):
                                    Image.asset("assest/images/edit.png",
                                      width: 16,height: 16,color: Colors.white,),
                                ):Container(),
                              ),
                            ),
                          )

                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width:30,
                        height: 30,
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
                        child: InkWell(
                          child: CircleAvatar(
                            // backgroundColor: Colors.transparent,
                            backgroundColor:gender!=null && gender==1? Color(0xfffb4592):Colors.blue.shade700,
                            radius: Helper.avatarRadius,
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(Helper.avatarRadius)),
                              child: Image.asset(gender!=null && gender==1? "assest/images/female1.png":"assest/images/male.png",
                                width: 15,height: 15,color: Color(Helper.inIconWhiteColorH1),),

                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 18,
                        color: Colors.blue,
                      ),

                      Container(
                        margin: EdgeInsets.only(left: MQ_Width*0.01,),
                        // width: _screenSize.width,
                        padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01,top: MQ_Height*0.02,bottom: MQ_Height*0.02),
                        child: //false?Icon(Icons.cake,color: Colors.blue,size: 16,):
                        false?Image.asset("assest/images/birthday.png",
                          width: 18,height: 18,color: Colors.blue,):
                        SvgPicture.asset('assest/images_svg/birthday.svg',width: 20,height: 20,),
                      ),

                      Container(
                      //  margin: EdgeInsets.only(left: MQ_Width*0.02,right: MQ_Width*0.02),
                        // width: _screenSize.width,
                       // padding: EdgeInsets.only(left: MQ_Width*0.02,right: MQ_Width*0.02,top: MQ_Height*0.02,bottom: MQ_Height*0.02),
                       // width: _screenSize.width,
                        child: CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: true,
                            text: dob,
                            color: Color(Helper.textColorBlackH1),
                            fontSize: Helper.textSizeH15,
                            fontWeight: Helper.textFontH4,
                            fontFamily: "itc avant medium"),
                      ),
                    ],
                    ),
                  ),

                  // Column(
                  //   children: [
                  //     Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //          facebook == "1"
                  //             ? Container(
                  //                 margin: EdgeInsets.only(
                  //                     top: 5, left: 5, right: 5),
                  //                 child: Image.asset(
                  //                   "assest/images/fb_color.png",
                  //                   width: 16,
                  //                   height: 16,
                  //                 ),
                  //               )
                  //             : Container(),
                  //          twitter == "1"
                  //             ? Container(
                  //                 margin: EdgeInsets.only(
                  //                     top: 5, left: 5, right: 5),
                  //                 child: Image.asset(
                  //                   "assest/images/twitter_color.png",
                  //                   width: 16,
                  //                   height: 16,
                  //                 ),
                  //               )
                  //             : Container(),
                  //          instagram == "1"
                  //             ? Container(
                  //                 margin: EdgeInsets.only(
                  //                     top: 5, left: 5, right: 5),
                  //                 child: Image.asset(
                  //                   "assest/images/insta_color.png",
                  //                   width: 16,
                  //                   height: 16,
                  //                 ),
                  //               )
                  //             : Container(),
                  //         tiktok == "1"
                  //             ? Container(
                  //                 margin: EdgeInsets.only(
                  //                     top: 5, left: 5, right: 5),
                  //                 child: Image.asset(
                  //                   "assest/images/tik_tok_color.png",
                  //                   width: 16,
                  //                   height: 16,
                  //                 ),
                  //               )
                  //             : Container(),
                  //         linkedin == "1"
                  //             ? Container(
                  //                 margin: EdgeInsets.only(
                  //                     top: 5, left: 5, right: 5),
                  //                 child: Image.asset(
                  //                   "assest/images/linkedin_color.png",
                  //                   width: 16,
                  //                   height: 16,
                  //                 ),
                  //               )
                  //             : Container(),
                  //         (facebook == "0" && twitter == "0" && instagram == "0" && tiktok == "0" && linkedin == "0")
                  //             ? CustomWigdet.TextView(
                  //                 textAlign: TextAlign.center,
                  //                 overflow: true,
                  //                 text: AppLocalizations.of(context)
                  //                     .translate(
                  //                         "No Social Media Connected"),
                  //                 color: Custom_color.GreyLightColor)
                  //             : Container()
                  //       ],
                  //     ),
                  //   ],
                  // ),

                  SizedBox(height: MQ_Height*0.02,),
                  true?Container(
                    width: _screenSize.width,
                    padding: const EdgeInsets.only(top: 10, right: 14, left: 14, bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        //=========Old UI About Me ====
                       false? Container(


                          width: _screenSize.width,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              ClipShadowPath(
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),

                                shadow:   BoxShadow(
                                  color: Color(0xffe4e9ef),
                                  offset: Offset(1.0, 1.0), //(x,y)
                                  blurRadius: 15.0,
                                ),
                                child: Container(

                                  constraints:
                                  BoxConstraints(maxHeight: about_myself == null ? 110 : (about_myself.toString().length < 85 ? 110 : 150), maxWidth: 320),
                                  decoration: BoxDecoration(

                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(width: 8.0, color: Color(0xff1b98ea)),
                                      )
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),

                                    ],
                                  ),
                                ),
                              ),
                            false?  Positioned(
                                top:20,

                                left: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?30:null,
                                right: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?null:10,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: Card(
                                    elevation: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(4),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                ( gender!=null && gender==1) ? "assest/images/woman_n.png":"assest/images/man_n.png",
                                              ),
                                              fit: BoxFit.contain)),
                                    ),
                                  ),
                                ),
                              ):Container(),
                              Positioned.fill(
                                child:
                                InkWell(
                                    onTap: () =>{
                                      toggleAboutMeDialog()
                                    },
                                    child : Padding(
                                      padding: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?const EdgeInsets.only(
                                          top: 5,
                                          right: 15,
                                          bottom: 5,
                                          left: 140):const EdgeInsets.only(
                                          top: 5,
                                          right: 140,
                                          bottom: 5,
                                          left: 15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children:[
                                                CustomWigdet.TextView(
                                                    overflow: true,
                                                    text: AppLocalizations.of(
                                                        context)
                                                        .translate(
                                                        "About me"),
                                                    fontFamily: "Kelvetica Nobis",
                                                    color: Color(0xff1e7fc4),
                                                    fontSize: 16),
                                                Image.asset("assest/images/edit.png",width:12,color:Colors.grey.shade600)
                                              ]
                                          ),


                                          Padding(
                                            padding: const EdgeInsets.only(right: 150.0),
                                            child: Divider(thickness: 2,
                                              color: Color(0xfffb4592),
                                            ),
                                          ),
                                          Text(
                                            about_myself != null ? about_myself : "",
                                            style: TextStyle(color:Custom_color.GreyLightColor),
                                          ),

                                        ],
                                      ),
                                    )),
                              )
//
                            ],
                          ),
                        ):
                           //=====New UI About Me ======
                       Column(
                         children: [
                           Container(
                             margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                             padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                             height: MQ_Height*0.16,
                             decoration: BoxDecoration(
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
                                               child: false?Text('About me',
                                               style: TextStyle(color:Helper.textColorBlueH1,
                                                   fontFamily: "Kelvetica Nobis",
                                                   fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),)
                                               : CustomWigdet.TextView(
                                                   overflow: true,
                                                   text: AppLocalizations.of(
                                                       context)
                                                       .translate(
                                                       "About me"),
                                                   fontFamily: "Kelvetica Nobis",
                                                   color:Helper.textColorBlueH1,
                                                   fontWeight: Helper.textFontH5,
                                                   fontSize: Helper.textSizeH14),
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
                                       Container(
                                           margin: EdgeInsets.only(left: MQ_Width*0.01,),
                                           // width: _screenSize.width,
                                           padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),

                                           alignment: Alignment.topCenter,
                                           child:
                                           ClipOval(
                                             child: Material(

                                               color:Colors.white70,
                                               shape: RoundedRectangleBorder(
                                                   side: BorderSide(width: 1,color: Colors.grey.shade400),
                                                 borderRadius: BorderRadius.circular(30.0),
                                               ),

                                               // Button color
                                               child: InkWell(
                                                 splashColor: Helper.inIconCircleGreyColor1, // Splash color
                                                 onTap: () {
                                                   toggleAboutMeDialog();

                                                 },
                                                 child: SizedBox(width: 24, height: 24,
                                                   child:true?Icon(Icons.edit,
                                                     color:Helper.inIconGreyColor1,
                                                     size: 15,):
                                                   Image.asset("assest/images/edit.png",
                                                     width: 16,height: 16,color: Colors.white,),
                                                 ),
                                               ),
                                             ),
                                           )

                                       ),
                                     ],
                                   ),
                                 ),
                                 SizedBox(
                                   height: MQ_Height*0.02,
                                 ),

                                 Container(
                                   alignment: Alignment.centerLeft,
                                   child: Text(about_myself != null ? about_myself : "",
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

                       //================Old Ui Interest ======
                       false? Container(


                          width: _screenSize.width,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              ClipShadowPath(
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),

                                shadow:   BoxShadow(
                                  color: Color(0xffe4e9ef),
                                  offset: Offset(1.0, 1.0), //(x,y)
                                  blurRadius: 15.0,
                                ),
                                child: Container(

                                  constraints:
                                  BoxConstraints(maxHeight: 110, maxWidth: 320),
                                  decoration: BoxDecoration(


                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(width: 8.0, color: Color(0xff1b98ea)),
                                      )
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),

                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top:20,

                                left: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?30:null,
                                right: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?null:10,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: Card(
                                    elevation: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(4),
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "assest/images/give-love.png"),
                                            fit: BoxFit.contain
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?const EdgeInsets.only(
                                      top: 5,
                                      right: 15,
                                      bottom: 5,
                                      left: 140):const EdgeInsets.only(
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
                                          text: AppLocalizations.of(
                                              context)
                                              .translate("Interest_an"),
                                          fontFamily: "Kelvetica Nobis",
                                          color: Color(0xff1e7fc4),
                                          fontSize: 16),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 150.0),
                                        child: Divider(thickness: 2,
                                          color: Color(0xfffb4592),
                                        ),
                                      ),

                                      CustomWigdet.TextView(
                                          text: interest != null
                                              ? _getInterest(interest)
                                              : "",
                                          color: Custom_color
                                              .GreyLightColor),
                                    ],
                                  ),
                                ),
                              )
//
                            ],
                          ),
                        ):
                           //============ New UI Interest =======
                       Column(
                         children: [
                           Container(
                             margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                             padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                             height: activitylist.length<3?MQ_Height*0.21: MQ_Height*0.28,
                             decoration: BoxDecoration(
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
                                               child: false?Text('Interest',
                                                 style: TextStyle(color:Helper.textColorBlueH1,
                                                     fontFamily: "Kelvetica Nobis",
                                                     fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),):
                                               CustomWigdet.TextView(
                                                   text: AppLocalizations.of(
                                                       context)
                                                       .translate("Interest_an"),
                                                   fontFamily: "Kelvetica Nobis",
                                                   color: //Color(0xff1e7fc4),
                                                   Helper.textColorBlueH1,
                                                   fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),
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
                                 /*Container(
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
                                 ),*/
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
                       ) ,

                        SizedBox(
                          height: MQ_Height*0.03,
                        ),

                       //======================= Old UI Purpose of joining =====

                       false? Container(


                          width: _screenSize.width,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              ClipShadowPath(
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),

                                shadow:   BoxShadow(
                                  color: Color(0xffe4e9ef),
                                  offset: Offset(1.0, 1.0), //(x,y)
                                  blurRadius: 15.0,
                                ),
                                child: Container(

                                  constraints:
                                  BoxConstraints(maxHeight: 110, maxWidth: 320),
                                  decoration: BoxDecoration(

                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(width: 8.0, color: Color(0xff1b98ea)),
                                      )
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),

                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top:20,

                                left: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?30:null,
                                right: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?null:10,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: Card(
                                    elevation: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(4),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                "assest/images/handshake.png",
                                              ),
                                              fit: BoxFit.contain)),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?const EdgeInsets.only(
                                      top: 5,
                                      right: 15,
                                      bottom: 5,
                                      left: 140):const EdgeInsets.only(
                                      top: 5,
                                      right: 140,
                                      bottom: 5,
                                      left: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomWigdet.TextView(
                                          overflow: true,
                                          text: AppLocalizations.of(
                                              context)
                                              .translate(
                                              "Professional interest"),
                                          fontFamily: "Kelvetica Nobis",
                                          color: Color(0xff1e7fc4),
                                          fontSize: 16),

                                      Padding(
                                        padding: const EdgeInsets.only(right: 150.0),
                                        child: Divider(thickness: 2,
                                          color: Color(0xfffb4592),
                                        ),
                                      ),
                                      CustomWigdet.TextView(
                                          overflow: true,
                                          text: prof_interest != null
                                              ? _getProfessional(
                                              prof_interest)
                                              : "",
                                          color: Custom_color
                                              .GreyLightColor),
                                    ],
                                  ),
                                ),
                              )
//
                            ],
                          ),
                        ):
                           //============ New Ui Purpose of joining =========
                       Column(
                         children: [
                           Container(
                             margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                             padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                             height: MQ_Height*0.10,
                             decoration: BoxDecoration(
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
                                               child: false?Text('Purpose of joining',
                                                 style: TextStyle(color:Helper.textColorBlueH1,
                                                     fontFamily: "Kelvetica Nobis",
                                                     fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),):
                                               CustomWigdet.TextView(
                                                   text: AppLocalizations.of(
                                                       context)
                                                       .translate("Purpose of joining"),
                                                   fontFamily: "Kelvetica Nobis",
                                                   color: //Color(0xff1e7fc4),
                                                   Helper.textColorBlueH1,
                                                   fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),
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
                                   child: Text(prof_interest != null
                                       ? _getProfessional(
                                       prof_interest)
                                       : "",
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
                        //======== Old UI Activity
                        false?Container(
                          width: _screenSize.width,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              ClipShadowPath(
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),

                                shadow:   BoxShadow(
                                  color: Color(0xffe4e9ef),
                                  offset: Offset(1.0, 1.0), //(x,y)
                                  blurRadius: 15.0,
                                ),
                                child: Container(

                                  constraints:
                                  BoxConstraints(maxHeight: 110, maxWidth: 320),
                                  decoration: BoxDecoration(

                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.grey,
                                    //     offset: Offset(1.0, 1.0), //(x,y)
                                    //     blurRadius: 20.0,
                                    //   ),
                                    //
                                    // ],
                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(width: 8.0, color: Color(0xff1b98ea)),
                                      )
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),

                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top:20,

                                left: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?30:null,
                                right: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?null:10,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: Card(
                                    elevation: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(4),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assest/images/lifestyle.png"),
                                              fit: BoxFit.contain)),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: (SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code) == "de")?const EdgeInsets.only(
                                      top: 5,
                                      right: 15,
                                      bottom: 5,
                                      left: 140):const EdgeInsets.only(
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
                                          text: AppLocalizations.of(
                                              context)
                                              .translate(
                                              "Activity describes most"),
                                          fontFamily: "Kelvetica Nobis",
                                          color: Color(0xff1e7fc4),
                                          fontSize: 16),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 150.0),
                                        child: Divider(thickness: 2,
                                          color: Color(0xfffb4592),
                                        ),
                                      ),
                                      CustomWigdet.TextView(
                                          overflow: true,
                                          text: activitylist != null
                                              ? _getListactiviyitem(
                                              activitylist)
                                              : "",
                                          color: Custom_color
                                              .GreyLightColor),
                                    ],
                                  ),
                                ),
                              )
//
                            ],
                          ),
                        ):Container(),
                          //========== New Ui Activity Enrolled ==========
                          bylist_activitylike != null && bylist_activitylike.isNotEmpty
                       ? Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05),
                              padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,
                              height: !joined_expand?MQ_Height*0.21:MQ_Height*0.26,
                              decoration: BoxDecoration(
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
                                                  text: AppLocalizations.of(
                                                      context)
                                                      .translate(
                                                      "Activity Enrolled"),
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
                                     color:Colors.white,
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
                                                //elevation: 2,
                                                child: Column(
                                                  children: List.generate(
                                                      bylist_activitylike.length,
                                                          (index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            Navigator.pushNamed(
                                                                context,
                                                                Constant
                                                                    .ActivityUserDetail,
                                                                arguments: {
                                                                  "event_id":
                                                                  bylist_activitylike[
                                                                  index]
                                                                      .id,
                                                                  "action": Constant
                                                                      .ActivityWall,
                                                                  "isSub":
                                                                  bylist_activitylike[
                                                                  index]
                                                                      .is_subs
                                                                }).then((value) {
                                                              if (value) {
                                                                setState(() {
                                                                  loading= false;
                                                                  _GetProfile();
                                                                });
                                                              }
                                                            } );
                                                          },
                                                          child: !joined_expand
                                                              ? index < 2?Container(
                                                              width:
                                                              _screenSize.width,
                                                              /*decoration: BoxDecoration(
                                                                  gradient: LinearGradient(colors: [Color(0xff23b8f2), Color(0xff1b5dab)],
                                                                      begin: Alignment.topCenter,
                                                                      end: Alignment.bottomCenter)
                                                              ),*/
                                                              margin: EdgeInsets.all(2),
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
                                                                          child: CustomWigdet.TextView(
                                                                              text: bylist_activitylike[index].title,
                                                                              color: Color(Helper.textColorBlackH1),
                                                                              fontWeight: Helper.textFontH5,
                                                                              fontSize: Helper.textSizeH14),
                                                                        ),
                                                                        Icon(Icons.arrow_forward_ios,size: 16,
                                                                          color: Custom_color.GreyLightColor,)
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  //Divider(height: 1,thickness: 0.5,color: Custom_color.WhiteColor,)
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
                                                            decoration: BoxDecoration(
                                                                color: Helper.textColorBlueH1,
                                                                border: Border.all(width: 0.5,color: Colors.blue.shade300),
                                                                borderRadius: BorderRadius.circular(20)),
                                                                    child: Column(
                                                                children: [
                                                                    Padding(
                                                                      padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10.0),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            child: CustomWigdet.TextView(
                                                                                text: bylist_activitylike[
                                                                                index]
                                                                                    .title,
                                                                                color: Color(Helper.textColorBlackH1),
                                                                                fontWeight: Helper.textFontH5,
                                                                                fontSize: Helper.textSizeH14),
                                                                          ),
                                                                          Icon(Icons.arrow_forward_ios,size: 16,color: Custom_color.GreyLightColor,)
                                                                        ],
                                                                      ),
                                                                    ),
                                                                   // Divider(height: 1,thickness: 0.5,color: Custom_color.WhiteColor,)
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
                                                bylist_activitylike.length > 2
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

                                        /*bylist_activitycreate != null &&
                                            bylist_activitycreate
                                                .length >
                                                2*/false? Container(
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
                                                  onTap: () {
                                                    setState(() {
                                                      create_expand =
                                                      !create_expand;
                                                    });
                                                  },
                                                  child: SizedBox(width: 30, height: 30,
                                                    child:false?Icon(Icons.edit,color:Helper.inIconGreyColor1,size: 16,):
                                                    Image.asset(
                                                      !create_expand
                                                          ? "assest/images/plus.png"
                                                          : "assest/images/minus.png",
                                                      width: 30,
                                                      height: 30,
                                                    ),
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
                                      color:Colors.white,
                                    height:!create_expand?MQ_Height*0.12:MQ_Height*0.18,
                                    child: SingleChildScrollView(
                                      physics: const ClampingScrollPhysics(),
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
                                                      bylist_activitycreate.length, (index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            Constant
                                                                .ActivityUserDetail,
                                                            arguments: {
                                                              "event_id":
                                                              bylist_activitycreate[
                                                              index]
                                                                  .id,
                                                              "action": Constant
                                                                  .Activity
                                                            }).then((value){
                                                          if (value == Constant.Activity) {
                                                            print("-------value edit profile----"+value);
                                                            setState(() {
                                                              loading= false;
                                                              _GetProfile();
                                                            });

                                                          }
                                                        });
                                                      },
                                                      child: !create_expand
                                                          ? index < 2
                                                          ? Container(
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
                                                          margin: EdgeInsets.all(2),
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
                                                                      child: CustomWigdet.TextView(text: bylist_activitycreate[index].title, color: Color(Helper.textColorBlackH1),
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
                                                              // Divider(
                                                              //   height: 1,
                                                              //   thickness: 0.5,
                                                              //   color: Custom_color.WhiteColor,
                                                              // )
                                                              index<1?Container(
                                                                  width: MQ_Height*0.35,
                                                                  height: 1,
                                                                  decoration: BoxDecoration(
                                                                      color: Color(Helper.textBorderLineColorH1),
                                                                      border: Border.all(width: 0.5,color:Color(Helper.textBorderLineColorH1),),
                                                                      borderRadius: BorderRadius.circular(30))
                                                              ):Container()
                                                            ],
                                                          ))
                                                              : Container()
                                                              : Container(
                                                            margin: EdgeInsets.all(2),
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
                                                                // Divider(
                                                                //   height:
                                                                //   1,
                                                                //   thickness:
                                                                //   0.5,
                                                                //   color:
                                                                //   Custom_color.WhiteColor,
                                                                // )
                                                              index<bylist_activitycreate.length-1?Container(
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



                      ],
                    ),
                  ):Container(),
                 // bylist_activitylike != null && bylist_activitylike.isNotEmpty
                    false  ? Padding(
                    padding: const EdgeInsets.only(
                        left: 14, right: 14),
                    child: Stack(
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(bottom: 14.0),
                          child: Card(
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment:Alignment.centerRight,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left:10.0,top: 14,bottom: 14,right: 10),
                                      color: Custom_color.GreyLightColor2,
                                      width: _screenSize.width,
                                      child:
                                      CustomWigdet.TextView(
                                        text: AppLocalizations.of(
                                            context)
                                            .translate(
                                            "Activity Enrolled"),
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
                                      bylist_activitylike.length,
                                          (index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context,
                                                Constant
                                                    .ActivityUserDetail,
                                                arguments: {
                                                  "event_id":
                                                  bylist_activitylike[
                                                  index]
                                                      .id,
                                                  "action": Constant
                                                      .ActivityWall,
                                                  "isSub":
                                                  bylist_activitylike[
                                                  index]
                                                      .is_subs
                                                }).then((value) {
                                              if (value) {
                                                setState(() {
                                                  loading= false;
                                                  _GetProfile();
                                                });
                                              }
                                            } );
                                          },
                                          child: Container(
                                              width:
                                              _screenSize.width,
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(colors: [Color(0xff23b8f2), Color(0xff1b5dab)],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter)
                                              ),
                                              child: !joined_expand
                                                  ? index < 2
                                                  ? Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .all(
                                                        10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: CustomWigdet.TextView(
                                                              text: bylist_activitylike[index]
                                                                  .title,
                                                              color: Custom_color
                                                                  .WhiteColor),
                                                        ),
                                                        Icon(Icons.arrow_forward_ios,size: 16,color: Custom_color.WhiteColor,)
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(height: 1,thickness: 0.5,color: Custom_color.WhiteColor,)
                                                ],
                                              )
                                                  : Container()
                                                  : Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(
                                                        10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: CustomWigdet.TextView(
                                                              text: bylist_activitylike[
                                                              index]
                                                                  .title,
                                                              color: Custom_color
                                                                  .WhiteColor),
                                                        ),
                                                        Icon(Icons.arrow_forward_ios,size: 16,color: Custom_color.WhiteColor,)
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(height: 1,thickness: 0.5,color: Custom_color.WhiteColor,)
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
                            bylist_activitylike.length > 2
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
                 // bylist_activitycreate != null && bylist_activitycreate.isNotEmpty
                    false  ? Padding(
                    padding: const EdgeInsets.only(
                        left: 14, right: 14, top: 5),
                    child: Stack(
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(bottom: 14.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ) ,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment:Alignment.centerRight ,
                                  children: [
                                    Container(
                                      padding:
                                      const EdgeInsets.only(left:10.0,top:14,bottom:14,right: 10),
                                      color: Custom_color.GreyLightColor2,
                                      width: _screenSize.width,
                                      child:
                                      CustomWigdet.TextView(
                                        text: AppLocalizations.of(
                                            context)
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
                                        color: Custom_color.WhiteColor,
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
                                              "event_id":
                                              bylist_activitycreate[
                                              index]
                                                  .id,
                                              "action": Constant
                                                  .Activity
                                            }).then((value){
                                          if (value == Constant.Activity) {
                                            print("-------value edit profile----"+value);
                                            setState(() {
                                              loading= false;
                                              _GetProfile();
                                            });

                                          }
                                        });
                                      },
                                      child: Container(
                                          width:
                                          _screenSize.width,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [Color(0xff23b8f2), Color(0xff1b5dab)],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter)
                                          ),
                                          child: !create_expand
                                              ? index < 2
                                              ? Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets
                                                    .all(
                                                    10.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: CustomWigdet.TextView(
                                                          text: bylist_activitycreate[index]
                                                              .title,
                                                          color: Custom_color
                                                              .WhiteColor),
                                                    ),
                                                    Icon(Icons.arrow_forward_ios,size: 16,color: Custom_color.WhiteColor,)
                                                  ],
                                                ),
                                              ),
                                              Divider(height: 1,thickness: 0.5,color: Custom_color.WhiteColor,)
                                            ],
                                          )
                                              : Container()
                                              : Column(
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(
                                                    10.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: CustomWigdet.TextView(
                                                          text: bylist_activitycreate[
                                                          index]
                                                              .title,
                                                          color: Custom_color
                                                              .WhiteColor),
                                                    ),
                                                    Icon(Icons.arrow_forward_ios,size: 16,color: Custom_color.WhiteColor,)
                                                  ],
                                                ),
                                              ),
                                              Divider(height: 1,thickness: 0.5,color: Custom_color.WhiteColor,)
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
                            bylist_activitycreate.length > 2
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
              ),
            ),
          ),
        ],
      ),
    );
  }


  saveAbout() async {
      
      aboutChangedTxt = aboutChangedTxt != "" ? aboutChangedTxt : about_myself;
      String url =WebServices.SaveAbout + SessionManager.getString(Constant.Token) + "&data="+Uri.encodeFull(aboutChangedTxt.trim())+"&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      https.Response response = await https.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Cache-Control": "no-cache",
      });
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
            setState(() {
                about_myself = aboutChangedTxt;
            });
            
        }
      }
      
      Navigator.of(context).pop();


  }
 //================== old Ui Show Dialog About Me =============
  toggleAboutMeDialog1() {
      showDialog(
        barrierColor: Color(0x00ffffff),
        context: context,
        builder: (BuildContext context) {
            bool is_processing = false;
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
                child: AlertDialog(
                  backgroundColor: Color(0x00ffffff),
                  content :StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                  return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      width: double.maxFinite,
                      height: MQ_Height*0.20,
                      child: Column(
                            children: [
                                    Container(
                                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      height: 2,
                                      child:  is_processing  ?  LinearProgressIndicator(
                                        backgroundColor: Colors.white,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent,),
                                        minHeight: 2,
                                      ) : Container(),
                                    ),
                                    Container(
                                    padding : EdgeInsets.all(2),
                                        height: MQ_Height*0.15,
                                    child :
                                    TextFormField(
                                          initialValue : aboutChangedTxt != "" ? aboutChangedTxt : about_myself,
                                          keyboardType: TextInputType.multiline,
                                          minLines: 1,
                                          maxLines: 20,
                                          maxLength: 140,
                                          onChanged: (text) {
                                            setState(() {
                                                aboutChangedTxt = text;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(color: Colors.grey.shade300),
                                            hintText: AppLocalizations.of( context) .translate( "About me")+"...",
                                          ),
                                          style: TextStyle(color:Custom_color.GreyLightColor),
                                    )),
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
                                                top: 10.0, bottom: 12.0),
                                            child: CustomWigdet.FlatButtonSimple(
                                                onPress: () {
                                                    if(is_processing)
                                                          return;
                                                    setState(() {
                                                        is_processing = true;
                                                    });
                                                    Future.delayed(Duration(milliseconds: 1000), () {
                                                      saveAbout();
                                                    });
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
                                                top: 10.0, bottom: 12.0),
                                            child: CustomWigdet.FlatButtonSimple(
                                                onPress: () {
                                                  setState(() {
                                                    is_processing = false;
                                                  });
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
                      )
                  );
                })
          ),
              ),
            );
        }
      );

  }

  //================== New Ui Show Dialog About Me =============

  Future<void> toggleAboutMeDialog()async{


    await showDialog(context: context,
        builder: (BuildContext context){
          bool is_processing = false;
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
                        false?Container(
                          alignment: Alignment.center,
                          child: CustomWigdet.TextView(
                            // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                              overflow: true,
                              text:AppLocalizations.of(context).translate("Are you sure want to logout"),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH11,
                              fontWeight: Helper.textFontH5,
                              color: Helper.textColorBlueH1
                          ),
                        ):Container(),
                        Container(
                            padding : EdgeInsets.all(2),
                            height: MQ_Height*0.15,
                            child :
                            TextFormField(
                              initialValue : aboutChangedTxt != "" ? aboutChangedTxt : about_myself,
                              keyboardType: TextInputType.multiline,
                             // minLines: 7,
                              maxLines: 7,
                              maxLength: 150,
                              onChanged: (text) {
                                setState(() {
                                  aboutChangedTxt = text;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                counterText: '',
                                labelText: AppLocalizations.of( context) .translate( "About me"),
                                labelStyle: TextStyle(color: Helper.textColorBlueH1,fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH12),
                                hintStyle: TextStyle(color: Colors.grey.shade300),
                                hintText: AppLocalizations.of( context) .translate( "About me")+"...",
                              ),
                              style: TextStyle(color:Custom_color.GreyLightColor),
                            )),
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
                                    if(is_processing) {
                                      return;
                                    }
                                    setState(() {
                                      is_processing = true;
                                    });
                                    Future.delayed(Duration(milliseconds: 1000), () {
                                      saveAbout();
                                    });
                                  },
                                  child: Text(
                                    // isLocationEnabled?'CLOSE':'OPEN',
                                    AppLocalizations.of(context)
                                        .translate("Update")
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
                          backgroundImage: profile_image !=null?NetworkImage(profile_image):AssetImage("assest/images/user2.png"),

                        ),
                      )),

                ],),
            ),
          );
        });
  }


  Future<https.Response> _GetProfile() async {
    try {
      if (images != null && images.isNotEmpty) {
        images.clear();
        activitylist.clear();
      }
      if(bylist_activitylike!=null && bylist_activitylike.isNotEmpty){
        bylist_activitylike.clear();
      }
      if(bylist_activitycreate!=null && bylist_activitycreate.isNotEmpty){
        bylist_activitycreate.clear();
      }
      String url =
          WebServices.GetProfile + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      https.Response response = await https.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Cache-Control": "no-cache",
      });
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {

          setState(() {
          interest = data["user_info"]["interest"];
          if(data["user_info"]["prof_interest"].toString().trim().toUpperCase()=="NO"){
            prof_interest = AppLocalizations.of(context).translate("Looking For Dating");
          }else{
            prof_interest = data["user_info"]["prof_interest"];
          }

          name = data["name"];
          name_demo = data["user_info"]["name"];
          gender = data["user_info"]["gender"];
          try{
            if(data["user_info"]["dob"]!=null){

              var dateOfBirth=data["user_info"]["dob"];
              var dateFormat=new DateFormat("dd-MM-yyyy").parse(dateOfBirth);
           //  var DayName=DateFormat.EEEE().format(dateFormat);
              var Date=DateFormat.d().format(dateFormat);
              var  MonthName= DateFormat.MMMM().format(dateFormat);
              var  Year= DateFormat.y().format(dateFormat);
              dob = '${Date} ${MonthName} ${Year}';

            }
          }catch(error){

          }

          var social = data["user_info"]["social"];
          try{ about_me = data["user_info"]["social"];}catch(e){}
          try{about_myself = data["user_info"]["about_me"];}catch(e){}
          profile_image = data["user_info"]["profile_img"];
          if (social.runtimeType != String) {
            facebook = data["user_info"]["social"]["facebook"];
            twitter = data["user_info"]["social"]["twitter"];
            instagram = data["user_info"]["social"]["instagram"];
            tiktok = data["user_info"]["social"]["tiktok"];
            linkedin = data["user_info"]["social"]["linkedin"];
          }


          var count = data["user_info"]["chatcount"];
          if (count != null) {
            //  SessionManager.setString(Constant.ChatCount, count.toString());
            UtilMethod.SetChatCount(context, count.toString());
          }
          var notification_count = data["notification_count"];
          if (notification_count != null) {
            // SessionManager.setString(Constant.NotificationCount, notification_count.toString());
            UtilMethod.SetNotificationCount(
                context, notification_count.toString());
          }

          var activity_listlike =
          data["user_info"]["user_subscribe_events"] as List;
          if (activity_listlike != null && activity_listlike.length > 0) {
            bylist_activitylike = activity_listlike
                .map<UserEvent>((index) => UserEvent.fromJson(index))
                .toList();
          }

          var activity_listcreate = data["user_info"]["user_events"] as List;
          if (activity_listcreate != null && activity_listcreate.length > 0) {
            bylist_activitycreate = activity_listcreate
                .map<UserEvent>((index) => UserEvent.fromJson(index))
                .toList();
          }

          imagelist = data["image"] as List;
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
         if(mounted) {
           setState(() {
            loading = true;
          });
         }

        });
        } else {
          if(mounted) {
            setState(() {
              loading = false;
            });
          }
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
      if(mounted) {
        setState(() {
          loading = false ;
        });
      }

    }
  }

  Future _asyncViewProfileDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Container(
                  child: Image.network(profile_image),
                ),
                Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: (){
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

  String _getListactiviyitem(List<Activity_holder> list) {
    StringBuffer value = new StringBuffer();
    List<Activity_holder>.generate(list.length, (index) {
      if (list[index].percent > 0) {
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
          physics: NeverScrollableScrollPhysics(),
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

  String _getGender(int name) {
    String value = "";
    if (name == 0) {
      value = AppLocalizations.of(context).translate("Male");
    } else if (name == 1) {
      value = AppLocalizations.of(context).translate("Female");
    }
    return value;
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
      value = "${AppLocalizations.of(context).translate("Looking for job")}, ${AppLocalizations.of(context).translate("Providing Job")}";
    } else if (name == 4) {

      //value = SessionManager.getString(Constant.Language_code) == "de" ? AppLocalizations.of(context).translate("No"):AppLocalizations.of(context).translate("No");
      value = SessionManager.getString(Constant.Language_code) == "de" ? AppLocalizations.of(context).translate("Looking For Dating"):AppLocalizations.of(context).translate("Looking For Dating");
    }

    return value;
  }

  _GetCallBackMethod(bool value) {
    if (value == true) {
      setState(() {
        loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (await UtilMethod.SimpleCheckInternetConnection(
            context, _scaffoldKey)) {
          _GetProfile();
        }
      });
    }
  }



//  _showProgress(BuildContext context) {
//    progressDialog = new ProgressDialog(context,
//        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
//    progressDialog.style(
//        message: AppLocalizations.of(context).translate("Loading"),
//        progressWidget: CircularProgressIndicator());
//    progressDialog.show();
//  }
//
//  _hideProgress() {
//    if (progressDialog != null) {
//      progressDialog.hide();
//    }
//  }
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
