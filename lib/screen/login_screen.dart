import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/professional_screen.dart';
import 'package:miumiu/screen/profile.dart';
import 'package:miumiu/screen/socialmedia_screen.dart';
import 'package:miumiu/screen/user_aboutme.dart';
import 'package:miumiu/screen/user_register.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as https;
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../utilmethod/helper.dart';
import 'activity_screen.dart';
import 'gallery.dart';
import 'gender_screen.dart';
import 'interest_screen.dart';

enum Action { Create_account, login_facbook, login_phone }

class Login_Screen extends StatefulWidget {
  String lang_code;

  Login_Screen(this.lang_code);

  @override
  _Login_ScreenState createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  Action action;
  bool checked =false;
  var url ;


  static final FacebookLogin facebookLogin = new FacebookLogin();
  bool isLoggedIn = false;
  var profileData, device_id = "", device_type = "";
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Location _locationService = new Location();
  bool showLoading;
  var Size;
  var MQ_Height;
  var MQ_Width;

  String privacy_policy;
  String and ;
  String terms ;
  String By_creating;
  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  @override
  void initState() {
    super.initState();
    showLoading = false;
    SessionManager.setString(Constant.Language_code,widget.lang_code);
    getDeviceDetails();
  }



  @override
  Widget build(BuildContext context) {
    privacy_policy = AppLocalizations.of(context).translate("Privacy policy");
     and = AppLocalizations.of(context).translate("And");
    terms = AppLocalizations.of(context).translate("Terms and conditions of use");
     By_creating = AppLocalizations.of(context).translate("By creating an account");
    Size = MediaQuery.of(context).size;
    print("---dfsf11---" + device_id.toString());
    MQ_Height= MediaQuery.of(context).size.height;
    MQ_Width=MediaQuery.of(context).size.width;




    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(Helper.StatusBarColor),
      ),
      child: SafeArea(
        child: Scaffold(

          body:Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assest/images/background_img.jpg"),//AssetImage("assest/images/hello.jpg"),
                    fit: BoxFit.fill,
                  ),
                ),),
              _widgetLoginDetails()
            ],
          )
        ),
      ),
    );
  }

  Widget _widgetLoginDetails(){
    return Container(
      child: ListView(
       // mainAxisAlignment: MainAxisAlignment.center,
       // crossAxisAlignment: CrossAxisAlignment.center,
        shrinkWrap: true,

          children : [
            SizedBox(
              height: showLoading ? 2:0,
              child: LinearProgressIndicator(
                backgroundColor: Color(int.parse(Constant.progressBg)),
                valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse(Constant.progressVl)),),
                minHeight: 2,
              ),
            ),
            Container(

             /* decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assest/images/background_img.jpg"),//AssetImage("assest/images/hello.jpg"),
                    fit: BoxFit.fill
                ),

              ),*/

              //  height: 300,
              width: Size.width,
              child: Container(
                margin: EdgeInsets.only(left:30,right: 30),

                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top:60,right: 60),


                      //height: 40,
                      //    padding: const EdgeInsets.only(left:30.0,right: 30),
                      child: Image.asset("assest/images/tellme.png")
                      ,),

                    Container(
                      margin:  EdgeInsets.only(left:MQ_Width *0.02,right: MQ_Width * 0.02,top: MQ_Height * 0.02,bottom: 0),
                      child: Column(

                        crossAxisAlignment:  CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            AppLocalizations.of(context).translate("Hello"),
                            style: TextStyle(
                                color: Color(0xFFf64492),
                                fontFamily: "itc avant medium",
                                fontSize: SessionManager.getString(Constant.Language_code)=="en"?70:60,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).translate("And"),
                            style: TextStyle(
                                color: Custom_color.BlackTextColor,
                                fontFamily: "itc avant medium",
                                fontSize: SessionManager.getString(Constant.Language_code)=="en"?60:50,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).translate("Welcome"),
                            style: TextStyle(
                                color: Custom_color.BlackTextColor,
                                fontFamily: "itc avant medium",
                                fontSize:SessionManager.getString(Constant.Language_code)=="en"?60:50,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: Size.width,
                      child: Padding(
                        padding:  EdgeInsets.only(top: MQ_Height*0.02),
                        child: Column(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Material(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"http://leanports.com/46/miu-miu/"});
                                },
                                child: CustomWigdet.TextView(
                                  overflow: true,

                                  color: Custom_color.BlueLightColor,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              color: Colors.transparent,
                            ),
                            false? CustomWigdet.RoundOutlineFlatButton(

                                onPress: () {
                                  if(!this.checked)
                                  {

                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(AppLocalizations.of(context).translate("Accept Privacy Policy")),
                                    ));
                                    return;
                                  }

                                  action = Action.Create_account;
                                  navigateToNext(context);
                                },
                                text: AppLocalizations.of(context)
                                    .translate("Create a New Account")
                                    .toUpperCase(),
                                textColor: Custom_color.WhiteColor,
                                bordercolor: Custom_color.BlueLightColor,
                                fontFamily: "Kelvetica Nobis",
                                fontWeight: FontWeight.w500
                            ):Container(
                              margin:  EdgeInsets.only(left:MQ_Width *0.02,right: MQ_Width * 0.02,top: MQ_Height * 0.02,bottom: 0),
                              height: 60,
                              width: MQ_Width*0.88,
                              decoration: BoxDecoration(
                                color: Color(Helper.ButtonBorderColor),
                                border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FlatButton(
                                onPressed: ()async{
                                  if(!this.checked)
                                  {

                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(AppLocalizations.of(context).translate("Accept Privacy Policy")),
                                    ));
                                    return;
                                  }

                                  action = Action.Create_account;
                                  navigateToNext(context);

                                },
                                child: Text(
                                  AppLocalizations.of(context).translate("Create a New Account").toUpperCase(),
                                  style: TextStyle(color: Color(Helper.ButtontextColor), fontSize:Helper.textSizeH12,fontWeight:Helper.textFontH5),
                                ),
                              ),
                            ),
//                      CustomWigdet.FlatButtonSimple(
//                          onPress: () {
//                            Navigator.pushNamed(
//                                context, Constant.LoginByNumberRoute,
//                                arguments: {
//                                  "facbook_id": "",
//                                  "access": Constant.CreateByPhone,
//                                  "device_id": device_id,
//                                  "device_type": device_type
//                                });
//                          },
//                          text: AppLocalizations.of(context)
//                              .translate("Create a New Account"),
//                          textColor: Custom_color.WhiteColor,
//                          textAlign: TextAlign.center,
//                          fontFamily: "OpenSans Bold"),

                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(left:MQ_Width*0.02,right: MQ_Width*0.02,top: MQ_Height*0.03,bottom: MQ_Height*0.01),
                              child: Text(
                                AppLocalizations.of(context).translate("Already have an account").toUpperCase(),
                                style: TextStyle(
                                    color: Custom_color.BlackTextColor,
                                    fontFamily: "itc avant medium",
                                    fontSize: Helper.textSizeH14,
                                    fontWeight: Helper.textFontH5
                                ),
                              ),
                            ),

                            false?CustomWigdet.RoundOutlineFlatButtonforWhite(

                                onPress: () {
                                  if(!this.checked)
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(AppLocalizations.of(context).translate("Accept Privacy Policy")),
                                    ));
                                    return;
                                  }
                                  action = Action.login_phone;
                                  //   PreferenceUtils.setString(Constant.Token, "safsdfdsfdsf");
//                            Navigator.pushNamed(
//                                context, Constant.LoginByNumberRoute,
//                                arguments: {
//                                  "facbook_id": "",
//                                  "access": Constant.LoginByPhone,
//                                  "device_id": device_id,
//                                  "device_type": device_typeß
//                                });
                                  navigateToNext(context);
                                },
                                text: AppLocalizations.of(context).translate("Login").toUpperCase(),
                                textColor: Helper.textColorBlueH1,//Custom_color.BlueLightColor,

                                bordercolor: Custom_color.BlueLightColor,
                                fontFamily: "Kelvetica Nobis",
                                fontWeight: Helper.textFontH5,
                                fontSize:Helper.textSizeH13):
                            Container(
                              margin:  EdgeInsets.only(left:MQ_Width *0.02,right: MQ_Width * 0.02,top:0,bottom: 0),
                              height: 60,
                              width: MQ_Width*0.88,
                              decoration: BoxDecoration(
                                color: Colors.white,//Color(Helper.ButtonBorderColor),
                                border: Border.all(width: 0.5,color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FlatButton(
                                onPressed: ()async{
                                  if(!this.checked)
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(AppLocalizations.of(context).translate("Accept Privacy Policy")),
                                    ));
                                    return;
                                  }
                                  action = Action.login_phone;
                                  //   PreferenceUtils.setString(Constant.Token, "safsdfdsfdsf");
//                            Navigator.pushNamed(
//                                context, Constant.LoginByNumberRoute,
//                                arguments: {
//                                  "facbook_id": "",
//                                  "access": Constant.LoginByPhone,
//                                  "device_id": device_id,
//                                  "device_type": device_typeß
//                                });
                                  navigateToNext(context);

                                },
                                child: Text(
                                  AppLocalizations.of(context).translate("Login").toUpperCase(),
                                  style: TextStyle(color: Helper.textColorBlueH1, fontSize:Helper.textSizeH12,fontWeight:Helper.textFontH5),
                                ),
                              ),
                            ),



                            Container(

                              margin:  EdgeInsets.only(left:MQ_Width*0.02,right:MQ_Width*0.02,top:MQ_Height*0.02,bottom: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(

                                    alignment: Alignment.centerLeft,
                                    width: 20,
                                    height: 20,
                                    color: Colors.white,
                                    child: Transform.scale(
                                     scale: 1.2,
                                      child: Checkbox(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.white,width: 1.0),
                                            borderRadius: BorderRadius.circular(2),
                                        ),
                                        side: BorderSide(color: Custom_color.BlackTextColor.withOpacity(0.5),width: 1.3),

                                        activeColor: Colors.blue,
                                          focusColor: Colors.white,
                                          checkColor: Colors.white,
                                          value: this.checked,
                                          onChanged:(bool checked) {
                                        setState(() {
                                          this.checked=checked;
                                        });
                                      }),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                      width: MQ_Width*0.70,
                                      margin:  EdgeInsets.only(left:MQ_Width*0.02,top:0,bottom: 0),
                                      child: RichText(
                                          textAlign: TextAlign.left,
                                          text: TextSpan(

                                              children: [
                                                TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight: Helper.textFontH5,
                                                      fontSize: Helper.textSizeH14
                                                  ),
                                                  text: By_creating,
                                                  recognizer: TapGestureRecognizer()..onTap= (){
                                                  },
                                                ),


                                                TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight: Helper.textFontH5,
                                                      fontSize: Helper.textSizeH14
                                                  ),
                                                  text:" "+ terms+" ",
                                                  recognizer: TapGestureRecognizer()..onTap= (){
                                                    Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"http://endpoint.tellmelive.com/terms.php"});
                                                  },
                                                ),


                                                TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight: Helper.textFontH5,
                                                      fontSize: Helper.textSizeH14
                                                  ),
                                                  text: AppLocalizations.of(context).translate("And"),
                                                  recognizer: TapGestureRecognizer()..onTap= (){
                                                  },
                                                ),

                                                TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight: Helper.textFontH5,
                                                      fontSize: Helper.textSizeH14
                                                  ),
                                                  text:" "+ privacy_policy,
                                                  recognizer: TapGestureRecognizer()..onTap= (){
                                                    SessionManager.getString(Constant.Language_code)=="en"?
                                                    Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/en/data-protection/"}):
                                                    Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/datenschutz/"});

                                                  },
                                                ),
                                                TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10
                                                  ),
                                                  text: " "+AppLocalizations.of(context).translate("Zu"),
                                                  recognizer: TapGestureRecognizer()..onTap= (){
                                                  },
                                                ),

                                              ]
                                          ))

                                  ),



                                ],
                              ),
                            ),



                            // CustomWigdet.RoundOutlineFlatButton(
                            //     onPress: () async {
                            //       if (await UtilMethod.SimpleCheckInternetConnection(
                            //           context, _scaffoldKey)) {
                            //         action = Action.login_facbook;
                            //         initPlatformState(context);
                            //       }
                            //     },
                            //     text: AppLocalizations.of(context)
                            //         .translate("log in with facebook")
                            //         .toUpperCase(),
                            //     textColor: Custom_color.WhiteColor,
                            //     bordercolor: Custom_color.WhiteColor,
                            //     fontFamily: "OpenSans Bold"),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            // CustomWigdet.TextView(
                            //     text: AppLocalizations.of(context)
                            //         .translate("Trouble Logging In"),
                            //     color: Custom_color.WhiteColor,
                            //     textAlign: TextAlign.center,
                            //     fontFamily: "OpenSans Bold"),
                            SizedBox(
                              height: 30,
                            ),

                           false? Container(
                              height: 60,
                              width: 360,
                              //  margin:  EdgeInsets.only(left:MQ_Width *0.06,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: 0),

                              decoration: BoxDecoration(
                                // color: Color(Helper.designColor),
                                // border: Border.all(width: 0.5,color: Color(Helper.designColor)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FlatButton(
                                onPressed: ()async{


                                   Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context)=>
                               //  User_register()
                                 // GenderScreen(),
                               //  ProfileImage_Screen()
                                 //Gallery_Screen(),
                                 // UserAboutMe()
                               //  Interested_Screen()
                               // Professional_Screen ()
                                  Activity_Screen()
                                 // SocialMedia_Screen()
                                  ));

                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(color: Color(Helper.textColorBlackH2), fontSize:Helper.textSizeH11,fontWeight:Helper.textFontH6),
                                ),
                              ),
                            ):Container()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

            ),]),
    );
  }






  Future<Null> initiateFacebookLogin() async {
    final FacebookLoginResult result = await facebookLogin.logIn(['email']);

    // print("------facbooking sataus-----"+result.status.toString());

    switch (result.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
//        print('''
//         Logged in!
//         ----Token:- ${accessToken.token}
//         ----User id:- ${accessToken.userId}
//        ---- Expires:- ${accessToken.expires}
//        ---- Permissions:- ${accessToken.permissions}
//        ---- Declined permissions:- ${accessToken.declinedPermissions}
//         ''');

        var graphResponse = await https.get(
            Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(400)&access_token=${result.accessToken.token}'));

        if (graphResponse.statusCode == 200) {
          var profile = json.decode(graphResponse.body);
          //  demo.putIfAbsent("access", () => Constant.LoginByFacebook);
          //    profile["access"] = Constant.LoginByFacebook;

          profile["facebookLogin"] = facebookLogin;

          //onLoginStatusChanged(true, profileData: profile);

          _showProgress(context);
          _GetCheckFackbook(profile["id"], profile);
          break;
        }
    }
  }


  navigateToNext(context) {
      try 
      {
        if (action == Action.login_phone) {
          Navigator.pushNamed(context, Constant.LoginByNumberRoute, arguments: {
            "facbook_id": "",
            "access": Constant.LoginByPhone,
            "device_id": device_id,
            "device_type": device_type
          });
        } else if (action == Action.login_facbook) {
          initiateFacebookLogin();
        } else if (action == Action.Create_account) {
          Navigator.pushNamed(context, Constant.LoginByNumberRoute, arguments: {
            "facbook_id": "",
            "access": Constant.CreateByPhone,
            "device_id": device_id,
            "device_type": device_type
          });
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

  Future<void> initPlatformState(BuildContext context) async {
    try {
      final bool serviceStatus = await _locationService.requestService();
      print("---Service status---: $serviceStatus");
      if (serviceStatus) {
        requestPermission(context);
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

  Future<void> requestPermission(BuildContext context) async {
    final PermissionStatus permissionRequestedResult =
        await _locationService.requestPermission();
    if (permissionRequestedResult == PermissionStatus.granted) {
      try {
        if (action == Action.login_phone) {
          Navigator.pushNamed(context, Constant.LoginByNumberRoute, arguments: {
            "facbook_id": "",
            "access": Constant.LoginByPhone,
            "device_id": device_id,
            "device_type": device_type
          });
        } else if (action == Action.login_facbook) {
          initiateFacebookLogin();
        } else if (action == Action.Create_account) {
          Navigator.pushNamed(context, Constant.LoginByNumberRoute, arguments: {
            "facbook_id": "",
            "access": Constant.CreateByPhone,
            "device_id": device_id,
            "device_type": device_type
          });
        }
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

  Future<String> getDeviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    String deviceName;
    String deviceVersion;
    //  String identifier;
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        device_id = build.androidId; //UUID for Android
        device_type = Constant.isAndroid;
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        device_id = data.identifierForVendor; //UUID for iOS
        device_type = Constant.isIOS;
      }
    } on PlatformException {
      print('Failed to get platform version');
    }

    //if (!mounted){ return;}
    return device_id;
  }

  Future<https.Response> _GetCheckFackbook(String id, profile) async {
    try {
      Map jsondata = {"facebook_id": id};
      var response = await https.post(Uri.parse(WebServices.LoginFacebook + "?language=${SessionManager.getString(Constant.Language_code)}"),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          print("-----logging-----");
//          Navigator.pushNamed(context, Constant.GenderRoute,
//              arguments: {
//                "access": routeData["access"],
//                "countryCode": routeData["countryCode"],
//                "mobile_no": routeData["mobile_no"],
//                "firstname":firstname,
//                "email":email,
//                "dob":customFormat.format(selectedDate),
//                "device_id":routeData["device_id"],
//                "device_type":routeData["device_type"]
//              });
          if (data["is_registration"] == 1) {
            Navigator.pushNamed(context, Constant.LoginByNumberRoute,
                arguments: {
                  "facbook_id": id,
                  "access": Constant.LoginByFacebook,
                  "device_id": device_id,
                  "device_type": device_type
                });
          } else {
            SessionManager.setString(Constant.Token, data["data"]["token"]);
            SessionManager.setString(
                Constant.Interested, data["data"]["interest"].toString());
            SessionManager.setString(
                Constant.LogingId, data["data"]["id"].toString());
            SessionManager.setString(
                Constant.Interested, data["data"]["interest"].toString());
            SessionManager.setString(Constant.Name, data["data"]["name"].toString());
            SessionManager.setString(Constant.Email, data["data"]["email"].toString());
            SessionManager.setString(Constant.Dob, data["data"]["dob"].toString());
            SessionManager.setString(
                Constant.Profile_img, data["data"]["profile_img"].toString());
            SessionManager.setString(
                Constant.Mobile_no, data["data"]["mobile_no"].toString());
            SessionManager.setString(Constant.Country_code, data["data"]["mobile_code"].toString());
            SessionManager.setboolean(Constant.AlreadyRegister, true);
            Navigator.pushReplacementNamed(context, Constant.WelcomeRoute);
          }
        }
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }


  _showProgress(BuildContext context) {
    setState(() {
      showLoading = true;
    });
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
    // if (progressDialog != null) {
    //   progressDialog.hide();
    // }
  }
}
