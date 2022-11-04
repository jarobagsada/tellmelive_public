import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miumiu/language/AppLanguage.dart';
import 'package:miumiu/screen/OnboardingPage.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as https;

class SplashScreen extends StatefulWidget {
  final AppLanguage appLanguage;
  SplashScreen({this.appLanguage});

  @override
  _SplashScreen createState() => _SplashScreen(appLanguage : this.appLanguage);


}


class _SplashScreen extends State<SplashScreen> {
  final AppLanguage appLanguage;
  final Location _locationService = new Location();
  _SplashScreen({this.appLanguage});
  bool locationLoaded;

  @override
  void initState() {
    super.initState();
    locationLoaded  = false;
  }
  


  @override
  Widget build(BuildContext context) {
    print("build");
    Future.delayed(Duration(milliseconds: 1000), () {
      initPlatformState(context);
    });
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
      children:<Widget> [
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assest/images/splash_bg.jpg"),
                fit: BoxFit.cover,

              )
          ),
        ),
        const Center(
          child: AvatarGlow(
            glowColor: Colors.white,
            endRadius: 130.0,

            duration: Duration(milliseconds: 3000),
            repeat: true,
            showTwoGlows: true,
            repeatPauseDuration: Duration(milliseconds: 100),

            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white,
              child: Image(image: AssetImage("assest/images/logo.png"),
                  width: 140,
                  height: 140),
            ),
          ),
        ),
      ],
          ),
    ) ;
  }

  Future<void> initPlatformState(context) async {
    try 
    {
      final bool serviceStatus = await _locationService.serviceEnabled();
      if (serviceStatus) 
      {
        requestPermission(context);
      } 
      else 
      {
        Navigator.pushNamed(context, Constant.LocationRoute);
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print("--eroor--" + e.message);
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        print("--eroor2222--" + e.message);
      }
    }
  }

//
  Future<void> requestPermission(context) async {
    final PermissionStatus permissionRequestedResult = await _locationService.hasPermission();
    print(permissionRequestedResult);
    //|| permissionRequestedResult == PermissionStatus.deniedForever
    if (permissionRequestedResult == PermissionStatus.denied) {
       //AppSettings.openAppSettings();
       //Navigator.pushReplacementNamed(context, Constant.LocationRoute,);
       final PermissionStatus permissionRequestedResult = await _locationService.requestPermission();
    }
    
    if (permissionRequestedResult == PermissionStatus.granted) {
        //var route = SessionManager.getboolean(Constant.FirstLangauge)==false? Langauge_Screen(appLanguage): UtilMethod.isStringNullOrBlank(SessionManager.getString(Constant.Token)) ? Login_Screen(appLanguage.appLocal.languageCode) : Welcome_Screen(appLanguage.appLocal.languageCode);
        //print(route.toString());
        //_navigate(route);
    }

    
    try
    { 
        var response            = await https.get (Uri.parse(WebServices.DefaultIP));
        print(response.body.toString());
        if (response.statusCode == 200) {
            var data            = json.decode(response.body);
            Constant.LATITUDE   = data['latitude'];
            Constant.LONGITUDE  = data['longitude'];

            print("latitude "+Constant.LATITUDE.toString()+" -- "+Constant.LONGITUDE.toString());
        }
    }catch(e){print(e.toString()+" -- ");}
    
    Future.delayed(const Duration(milliseconds : 200),(){
      if(SessionManager.getboolean(Constant.Onboarded)==true) {
        SessionManager.getboolean(Constant.FirstLangauge) == false ? _navigate(
            Constant.LanguageScreen, {"appLanguage": appLanguage}) : UtilMethod
            .isStringNullOrBlank(SessionManager.getString(Constant.Token))
            ? _navigate(Constant.LoginRoute,
            {"lang_code": appLanguage.appLocal.languageCode})
            : _navigate(Constant.WelcomeRoute,
            {"lang_code": appLanguage.appLocal.languageCode});
      }else{

        _navigate(
            Constant.OnboardScreen, {"appLanguage": appLanguage});
      }
    });
  
    loadLocation();
  }


  loadLocation() async
  {
      print("in granted");
      try
      {
          print('navigate01');
          Constant.currentLocation = await _locationService.getLocation();
          print("after granted "+Constant.currentLocation.latitude.toString());
      }catch(e){ print(e.toString());}
      print('navigate0');
  }

  _navigate(route,args)
  {
      print('navigate');
      //Navigator.of(context).popAndPushNamed(route);
      Navigator.pushNamedAndRemoveUntil(
        context, route, (r) => false,arguments: args);

  }
  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }
}


