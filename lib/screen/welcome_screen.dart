import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:http/http.dart' as https;
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:io' as IO;
import 'package:store_redirect/store_redirect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:upgrader/upgrader.dart';

import '../utilmethod/helper.dart';


class Welcome_Screen extends StatefulWidget {
  var lang_code;
  Welcome_Screen({Key key,@required this.lang_code}):super(key:key);

  @override
  _Welcome_ScreenState createState() => _Welcome_ScreenState();
}

class _Welcome_ScreenState extends State<Welcome_Screen> {
  Size _screenSize;
  var MQ_Height;
  var MQ_Width;
  ProgressDialog progressDialog;
  var routid;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _visiblity = false;
  //======== new Add =========
  Location _locationService = new Location();

  @override
  void initState() {
    SessionManager.setString(Constant.Language_code,widget.lang_code);
    print("-----profileimage-------" + SessionManager.getString(Constant.LogingId.toString()));
    print('SessionManager.getString(Constant.Profile_img)=${SessionManager.getString(Constant.Profile_img)}');
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(context, _scaffoldKey))
      {

        _firebaseMessaging..requestPermission( alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true, );
        if(IO.Platform.isIOS)
        {
            String text  = 'token';
            try 
            {
                final Directory directory = await getApplicationDocumentsDirectory();
                final File file = File('${directory.path}/data.txt');
                print(file.path.toString());
                text = await file.readAsString();
                print("token :: "+text);
                if(text == null)
                  text = "token";
                else if(text == "")
                  text = "token";
            } catch (e) {
                print("Couldn't read file");
            }

            _GetAppKey(text);
        }
        else
        {

          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
              RemoteNotification _notification  = message.notification;
              AndroidNotification _android      = message.notification?.android;
              try
              {
                FlutterAppBadger.updateBadgeCount(message.data["badge"]);
              }catch(E){}
              
          });

          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
              print('A new onMessageOpenedApp event was published!');
              _navigateToItemDetail(message.data);
          });

          _firebaseMessaging.getToken().then((value) => _GetAppKey(value));
        }
        

      }
    });


  }
  @override
  void dispose() {
    _hideProgress();
    super.dispose();
  }

  _navigateToItemDetail(Map<String,dynamic > message){
    String user_id ="";
    if(Platform.isAndroid) {
      final dynamic notification = message['data'];
      print("--------data noti----" + notification.toString());
       user_id = notification["user_id"];
      print("----usr_id-----" + user_id.toString());
    }else if(Platform.isIOS){
       user_id = message["user_id"];
      print("----usr_id-----" + user_id.toString());
    }

    Constant.Check_ChatNotification = true;
    Navigator.pushNamedAndRemoveUntil(
        context, Constant.NavigationRoute, (r) => false,
        arguments: {"index": 3, "user_id": user_id});

  }

  _showProgress(BuildContext context) {
    print("from :: ");
    List<Color> _kDefaultRainbowColors = const [
      Colors.blue,
      Colors.blue,
      Colors.blue,
      Colors.pinkAccent,
      Colors.pink,
      Colors.pink,
      Colors.pinkAccent,

    ];
    /* progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    progressDialog.style(
        message: AppLocalizations.of(context).translate("Loading"),
        progressWidget: false?CircularProgressIndicator():
        Center(
          child: Container(
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
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Helper.avatarRadius),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
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
        )
    );*/
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: true,
    );
    progressDialog.style(
        backgroundColor: Colors.transparent,

        elevation: 0,
        message: '',

        progressWidgetAlignment: Alignment.center,

        padding: EdgeInsets.only(left: MQ_Width*0.30,right: MQ_Width*0.20),
        child:  Center(
          child: Container(
            alignment: Alignment.center,
            width: 120,
            height: 120,
            child: LoadingIndicator(
              indicatorType: Indicator.lineScalePulseOut,
              colors: _kDefaultRainbowColors,
              strokeWidth: 2.0,
              pathBackgroundColor:Colors.black45,
              // showPathBackground ? Colors.black45 : null,
            ),
          ),
        )
    );
    /*progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: true,

      /// your body here
      customBody: false?LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        backgroundColor: Colors.white,
        minHeight: 10,
      ): Center(
        child: Container(
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
    );*/


    progressDialog.show();
    _hideProgress();
  }

  _hideProgress() {
    if (progressDialog != null) {
      progressDialog.hide();
    }
    /*if (_visible == true){
      _showSingleAnimationDialog(
          context, Indicator.values[21],
          false);
  }*/
    /* ShowProgressIntegator.showSingleAnimationDialog(
        context,Indicator.values[21],
        _visible);*/

  }



  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: false? SystemUiOverlayStyle(
        // For Android.
        // Use [light] for white status bar and [dark] for black status bar.
        statusBarIconBrightness: Brightness.light,
        // For iOS.
        // Use [dark] for white status bar and [light] for black status bar.
        statusBarBrightness: Brightness.light,
      ):SystemUiOverlayStyle(
        statusBarColor: Color(Helper.StatusBarColor),
      ),
      child: Scaffold(
        // appBar: _getAppbar(context),
        key: _scaffoldKey,
        body: UpgradeAlert(
          upgrader: Upgrader(dialogStyle: UpgradeDialogStyle.cupertino,
         // canDismissDialog: false,
         // durationUntilAlertAgain: Duration(seconds: 2),
          shouldPopScope: () {
            _hideProgress();
            return true;
          }
          ),
          child: Container(
            width: _screenSize.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Visibility(
                visible: true,//_visiblity,
                replacement: Center(child: CircularProgressIndicator()),
                child: Column(

                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.only(top:70.0),
                      child: Container(
                        width: 200,
                        height: 60,
                        child: Image(
                          image: AssetImage("assest/images/tellme.png"),
                        ),
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        // Align(
                        //   alignment: Alignment.center,
                        //   child:  Container(
                        //     width: 300,
                        //     // height: 350,
                        //     child: Image.asset(
                        //       "assest/images/star.png",
                        //       fit: BoxFit.contain,
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                _CircleImage(),
                                SizedBox(height: 25),
                                //
                                // CustomWigdet.TextView(
                                //     text: AppLocalizations.of(context)
                                //         .translate("Welcome"),
                                //     fontSize: 27.0,
                                //     fontFamily: "itc avant medium",
                                //     textAlign: TextAlign.center,
                                //     color: Custom_color.BlackTextColor),
                              CustomWigdet.TextView(
                                  text: AppLocalizations.of(context).translate("Welcome"),
                                  fontSize: 28.0,
                                  textAlign: TextAlign.center,
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "Kelvetica Nobis",
                              fontWeight: FontWeight.bold),
                                SizedBox(
                                  height: 10,
                                ),
                                CustomWigdet.TextView(
                                    text: SessionManager.getString(Constant.Name)
                                        .toString(),
                                    fontSize: 25.0,
                                    textAlign: TextAlign.center,
                                    color: Custom_color.BlackTextColor,
                                    fontFamily: "Kelvetica Nobis"),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                   false? Container(
                 //     decoration: CustomWigdet.raised,

                      child: CustomWigdet.RoundOutlineFlatButton(
                          onPress: () {
                            onSubmit(context);
                        //    ondemoSubmit();
                          },
                          text:  AppLocalizations.of(context).translate("Continue").toUpperCase(),


                          textColor: Custom_color.WhiteColor,
//                        bgcolor: Custom_color.BlueLightColor,
                          fontFamily: "Kelvetica Nobis"),

                    ): Container(
                     margin:  EdgeInsets.only(left:MQ_Width *0.06,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: 0),
                     height: 60,
                     width: MQ_Width*0.80,
                     decoration: BoxDecoration(
                       color: Color(Helper.ButtonBorderColor),
                       border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: FlatButton(
                       onPressed: ()async{
                         onSubmit(context);
                         //ondemoSubmit();

                       },
                       child: Text(
                         AppLocalizations.of(context).translate("Continue").toUpperCase(),
                         style: TextStyle(color: Color(Helper.ButtontextColor), fontSize:Helper.textSizeH12,fontWeight:Helper.textFontH5),
                       ),
                     ),
                   ),

                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  _getAppbar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Flexible(
                flex: 4,
                child: Container(
                    width: _screenSize.width,
                    height: 1,
                    color: Custom_color.BlueLightColor),
              ),
              Flexible(
                flex: 9,
                child: Container(
                  width: _screenSize.width,
                  height: 0.5,
                  color: Custom_color.GreyLightColor,
                ),
              ),
            ],
          ),
          preferredSize: Size.fromHeight(0.0)),

    );
  }

  // ignore: non_constant_identifier_names
  Widget _CircleImage() {
    return CircleAvatar(
      radius: 140,
      backgroundColor: Color(0xffe9f6fc),
      child: CircleAvatar(
        radius: 110,
        backgroundColor: Color(0xffcce9f9),
        child: Material(
          elevation: 8.0,
          shape: CircleBorder(),
          child: Container(
          height: 160.0,
          width: 160.0,
          decoration: BoxDecoration(

            color: Custom_color.PlacholderColor,
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                SessionManager.getString(Constant.Profile_img),scale: 1.0
              )
            ),
          ),
        )
        ),
      ),
    ) ;

  }


  onSubmit(BuildContext context) {
    if (SessionManager.getboolean(Constant.AlreadyRegister)) {
      //initPlatformState();
     // Navigator.pushNamed(context, Constant.NavigationRoute);
      try{showHelp();}catch(e){}
    } else {
      //============== Old Switch Page ===========
      /*Navigator.pushNamed(
        context,
        Constant.InterestedRoute,
      );*/
      //============== New Switch Page ===========
      try{showHelp();}catch(e){}

    }
  }
  //============ new show Alert Info =================

  Future<void> showHelp()async{

    if(!SessionManager.getboolean("help_shown"))
    {
      Future.delayed(Duration(milliseconds: 2000),() async {
        await SessionManager.setboolean("help_shown", true);
        await showDialog(context: context,
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
                                Container(
                                  alignment: Alignment.center,
                                  //  margin: EdgeInsets.only(bottom: 30),
                                  child: CustomWigdet.TextView(
                                      text: AppLocalizations.of(context).translate("Privacy Info"),
                                      //AppLocalizations.of(context).translate("Create Activity"),
                                      fontFamily: "Kelvetica Nobis",
                                      fontSize: Helper.textSizeH7,
                                      fontWeight: Helper.textFontH4,
                                      color: Helper.textColorBlueH1
                                  ),
                                ),
                                SizedBox(height: MQ_Height * 0.02,),

                                Container(
                                  alignment: Alignment.center,
                                  child: CustomWigdet.TextView(
                                    overflow: true,
                                    text:AppLocalizations.of(context).translate("Privacy message"),
                                    //AppLocalizations.of(context).translate("Create Activity"),
                                    fontFamily: "Kelvetica Nobis",
                                    fontSize: Helper.textSizeH14,
                                    fontWeight: Helper.textFontH5,
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
                                      Navigator.of(context).pop(true);

                                      if (SessionManager.getboolean(Constant.AlreadyRegister)) {
                                        //initPlatformState();
                                        Navigator.pushNamed(context, Constant.NavigationRoute);
                                      } else {
                                        //============== Old Switch Page ===========
                                        /*Navigator.pushNamed(
                                            context,
                                            Constant.InterestedRoute,
                                          );*/
                                        //============== New Switch Page ===========
                                        SessionManager.setboolean(Constant.AlreadyRegister, true);
                                        initPlatformState();

                                      }

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
      });
    }else{
      if (SessionManager.getboolean(Constant.AlreadyRegister)) {
        //initPlatformState();
        Navigator.pushNamed(context, Constant.NavigationRoute);
      } else {
        //============== Old Switch Page ===========
      /*Navigator.pushNamed(
                                          context,
                                          Constant.InterestedRoute,
                                        );*/
        //============== New Switch Page ===========
        SessionManager.setboolean(Constant.AlreadyRegister, true);
        initPlatformState();

      }
    }
  }

  Future<void> initPlatformState() async {
    try {
      final bool serviceStatus = await _locationService.serviceEnabled();
      print("---Service status---: $serviceStatus");
      if (serviceStatus) {
        requestPermission();
      } else {
        Navigator.pushNamed(context, Constant.LocationRoute);
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        print("--eroor--" + e.message);
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        print("--eroor2222--" + e.message);
      }
    }
  }
  Future<void> requestPermission() async {
    // final PermissionStatus permissionGrantedResult = await location.hasPermission();

    final PermissionStatus permissionRequestedResult =
    await _locationService.hasPermission();
    if (permissionRequestedResult == PermissionStatus.denied ||
        permissionRequestedResult == PermissionStatus.deniedForever) {
      Navigator.pushNamed(
        context,
        Constant.LocationRoute,
      );
    } else if (permissionRequestedResult == PermissionStatus.granted) {
      // Navigator.pushNamed(context, Constant.NavigationRoute);
     /* Navigator.of(context).pushNamedAndRemoveUntil(
          Constant.NavigationRoute,
          ModalRoute.withName(Constant.WelcomeRoute));*/
    }
  }
  

  Future<https.Response> _GetAppKey(String key) async {
    try 
    {
      _showProgress(context);
      print("------inside------ FIREBASE "+key);

      String url = WebServices.GetAppKey + SessionManager.getString(Constant.Token) + "&device_id="+ key;
      print("-----url-----" + url.toString());
      https.Response response = await https.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Cache-Control": "no-cache",
      });
      print("respnse---## -" + response.body);
      if (response.statusCode == 200) {
        _hideProgress();

        var data = json.decode(response.body);
        if (data["status"]==200) {

          try
          {
              if(data['version'] > Constant.APP_VERSION)
              {
                  StoreRedirect.redirect(
                        androidAppId: "com.tml.miumiu",
                        iOSAppId: "1587145814");
                      Future.delayed(Duration(milliseconds: 500), () {
                            print("closing "+data['close'].toString());
                            if(data['close'] == 1)
                            {
                              if(IO.Platform.isAndroid)
                                  SystemNavigator.pop();
                              else if(IO.Platform.isIOS)
                                  exit(0);
                            }
                      });
                      
                 
                  
              }
          }catch(e){

          }

          _hideProgress();

          bool isLocationEnabled = data["user"]["enabled"].toString() == "1" ? true : false ;
          print("welcome :: "+data["user"]["enabled"].toString()+" -- "+isLocationEnabled.toString());
          SessionManager.setboolean(Constant.LocationEnabled, isLocationEnabled);

          if(mounted) {
            setState(() {
              _visiblity = true;

            });
          }

        } else {

          if(mounted) {
            setState(() {
              _hideProgress();
              _visiblity = false;

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
      }else{
        _hideProgress();
      }
    } on Exception catch (e) {
      print(e.toString());
      _visiblity = true;
      _hideProgress();
    }

    try {
      Future.delayed(Duration(seconds: 3),(){
        _hideProgress();
      });
    }catch(error){
      print('Future.delayed after seconds:3 error=$error');
    }

  }

//  _logout() async {
//    await routeData["facebookLogin"].logOut();
//
//    // onLoginStatusChanged(false);
//    print("Logged out---" + routeData["id"]);
//  }
}
