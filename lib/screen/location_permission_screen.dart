import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';

class Location_Permission_Screen extends StatefulWidget {
  @override
  _Location_Permission_ScreenState createState() => _Location_Permission_ScreenState();
}

class _Location_Permission_ScreenState extends State<Location_Permission_Screen> {
  Size _screenSize;
//  var routeData;
  Location _locationService = new Location();

  @override
  void initState() {
    // TODO: implement initState
//    print("------aaaa-----------------------");
//    if(!UtilMethod.isStringNullOrBlank(SessionManager.getString(Constant.Token)))
//      {
//        initPlatformState(context);
//      }
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
//    routeData =
//    ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return SafeArea(
        child: Scaffold(
      body: Container(
        width: _screenSize.width,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200,
                height: 200 ,
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
                          image: AssetImage("assest/images/earth.png"),
                        ),
                      ),
                    )
                )
              ),
              SizedBox(
                height: 10,
              ),
              CustomWigdet.TextView(
                  text: AppLocalizations.of(context)
                      .translate("Allow access to your location"),
                  fontSize: 14.0,
                  textAlign: TextAlign.center,
                  color: Custom_color.BlackTextColor,
                  fontFamily: "Kelvetica Nobis"),
              SizedBox(
                height: 10,
              ),
              CustomWigdet.TextView(
                  text: AppLocalizations.of(context)
                      .translate("To find the people with interests"),
                  fontSize: 12,
                  color: Custom_color.GreyLightColor,
                  fontFamily: "Kelvetica Nobis",
                  textAlign: TextAlign.center),
              SizedBox(height: 50,),
              CustomWigdet.RoundRaisedButton(
                  onPress: () {
                    initPlatformState(context);
                  },
                  text: AppLocalizations.of(context)
                      .translate("Allow")
                      .toUpperCase(),
                  fontFamily: "Kelvetica Nobis",
                  textColor: Custom_color.WhiteColor,
                  bgcolor: Custom_color.BlueLightColor),
            ],
          ),
        ),
      ),
    ));
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
    final PermissionStatus permissionRequestedResult = await _locationService.requestPermission();
    if (permissionRequestedResult == PermissionStatus.granted) {
      try 
      {
        //Constant.currentLocation = await _locationService.getLocation();
        //Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, Constant.SplashScreen);
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
}
