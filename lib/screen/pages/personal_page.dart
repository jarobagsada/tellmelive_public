import 'dart:convert';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/AppLanguage.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/pages/provider/model.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';

import '../../utilmethod/fluttertoast_alert.dart';
import '../../utilmethod/helper.dart';
import '../../utilmethod/network_connectivity.dart';
import '../../utilmethod/showDialog_networkerror.dart';
import '../gallery.dart';

class Personal_page extends StatefulWidget {

  @override
  _Personal_pageState createState() => _Personal_pageState();
}

// ignore: camel_case_types
class _Personal_pageState extends State<Personal_page> {
  Size _screenSize;
  bool _visible;
  bool loading=true;

  ProgressDialog progressDialog;
  var image = "", liked, visitors, match, name;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CounterModel counterModel;
  int radioLanguage;
  AppLanguage _appLanguage;
  List<dynamic> images = [];
  List<dynamic> imagelist = [];
  int _current = 0;

  var MQ_Height;
  var MQ_Width;
  String User_imageUrl = "";
  bool isLocationEnabled = true;
  bool checkRefresh = false;
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _connectivity = NetworkConnectivity.instance;
  bool networkEnable=true;
  @override
  void initState() {
    _appLanguage = Provider.of<AppLanguage>(context, listen: false);

    _visible = false;

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() {
          _source = source;
          print('Personal ## source =$source, \n#c _source=${_source.keys.toList()[0]}');
          if(_source.keys.toList()[0]==ConnectivityResult.wifi){
            print('Personal ## ConnectivityResult.wifi _source=${_source.keys.toList()[0]}');
            networkEnable = true ;
          }
          else if(_source.keys.toList()[0]==ConnectivityResult.mobile){
            print('Personal ## ConnectivityResult.mobile _source=${_source.keys.toList()[0]}');
            networkEnable = true ;
          }else{
            print('Personal ## ConnectivityResult.none _source=${_source.keys.toList()[0]}');
            networkEnable = false ;
          }

        });
      }
    });

    getUserDetails();
    radioLanguage = SessionManager.getString(Constant.Language_code) == "en" ? Constant.English : SessionManager.getString(Constant.Language_code) == "ar"?Constant.Arabic:Constant.German;
    if(networkEnable==true) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (await UtilMethod.SimpleCheckInternetConnection(
            context, _scaffoldKey)) {
          _GetUserDetail();
          _GetProfile();
        }
      });
    }else{
      //FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
      if (mounted) {
        setState(() {
        checkRefresh=true;
      });
      }

    }
    super.initState();
  }



  getUserDetails(){
    if (mounted) {
      setState(() {
      User_imageUrl = SessionManager.getString(Constant.Profile_img);
      isLocationEnabled   = SessionManager.getbooleanTrueDefault(Constant.LocationEnabled);

      Future.delayed(const Duration(seconds: 20),(){
            checkRefresh=true;
            //   FlutterToastAlert.flutterToastMSG('checkRefresh=$checkRefresh', context);
      });
    });
    }

  }

  //============ new show Alert Location =================

  Future<void> _asyncConfirmToggle(BuildContext context)async{

    String enable   = AppLocalizations.of(context).translate("enable location sharing").toUpperCase();
    String disable  = AppLocalizations.of(context).translate("disable location sharing").toUpperCase();
    String inf      = isLocationEnabled ? disable : enable;
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
                        SizedBox(height: MQ_Height*0.07,),
                        Container(
                          alignment: Alignment.center,
                          child: CustomWigdet.TextView(
                            // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                              overflow: true,
                              text:inf,
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH11,
                              fontWeight: Helper.textFontH5,
                              color: Helper.textColorBlueH1
                          ),
                        ),
                        SizedBox(height: 22,),

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
                              toggleLocationSharing();

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
                                    Navigator.of(context).pop();
                                    toggleLocationSharing();

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
                        radius: 75,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage("assest/images/map.png"),

                        ),
                      )),

                ],),
            ),
          );
        });
  }
  //============ new show Alert Location =================



  toggleLocationSharing() async
  {

    //_showProgress(context, "12");
    String url = WebServices.ToggleLocation +
        SessionManager.getString(Constant.Token) +"&current="+(isLocationEnabled ? "1":"0")+
        "&language=${SessionManager.getString(Constant.Language_code)}";
    https.Response response = await https.post(Uri.parse(url),
        encoding: Encoding.getByName("utf-8"),
        headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
    print(response.body);



    setState(() {
      isLocationEnabled = !isLocationEnabled;
    });
    SessionManager.setboolean(Constant.LocationEnabled, isLocationEnabled);

    /*setCustomMarker();

    setState(() {
      timeStamp   = DateTime.now().millisecondsSinceEpoch;
    });*/

    //_hideProgress();
  }

 @override
  void dispose() {
    // TODO: implement dispose
   try{
     _connectivity.disposeStream();
     _source.clear();
   }catch(error){
     print('_connectivity disponse error=$error');
   }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    _screenSize = MediaQuery.of(context).size;
    counterModel = Provider.of<CounterModel>(context, listen: false);

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
                print('Personal Mobile networkEnable: $networkEnable');
                networkEnable = true;
                checkRefresh = true;
              });
            } catch (error) {
              print('Personal Mobile error: $error');
              networkEnable = true;
              checkRefresh = true;
            }
            break;
          case ConnectivityResult.wifi:
            string = 'Wifi: Online';
            //  FlutterToastAlert.flutterToastMSG('WiFi: Online', context);

            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('Personal Wifi networkEnable: $networkEnable');

                networkEnable = true;
                checkRefresh = true;
              });
            } catch (error) {
              print('Personal WiFi error: $error');
              networkEnable = true;
              checkRefresh = true;
            }

            break;
          case ConnectivityResult.none:
            string = 'Offline';
            // FlutterToastAlert.flutterToastMSG('Offline', context);
            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('Personal Offline networkEnable: $networkEnable');
                networkEnable = false;
                checkRefresh = true;
              });
            } catch (error) {
              print('Personal Offline error: $error');
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
      child:// _widgetPersonalUI()
        _widgetNewUIPersonal()
    );
  }

  //============= Olad UI ==========
  Widget _widgetPersonalUI(){
    return Visibility(
      visible: _visible,
      replacement: Center(
        child: CircularProgressIndicator(),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 185),
          //     preferredSize: Size.fromHeight(135.0), // here the desired height

          child: Column(
            children: <Widget>[
              Stack(

                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 35.0),
                    child: Container(
                      height: 150.0,
                      decoration: const BoxDecoration(

                          gradient: LinearGradient(colors: [Color(0xff22b7f1), Color(0xff1c5baa)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)
                      ),
                    ),
                  ),
                  const Image(image: AssetImage("assest/images/curve.png")),

                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CustomWigdet.TextView(
                              text: name.toString().toUpperCase(), color: Custom_color.WhiteColor),
                          const SizedBox(
                            height: 5,
                          ),
                          Stack(
                              clipBehavior: Clip.none,

                              children: [
                                Positioned(
                                  top: 70,
                                  left: 95,
                                  child: GestureDetector(

                                    onTap: (){
                                      Navigator.pushNamed(context, Constant.Edit_my_profile);
                                      print("Edit Profile");

                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xffe4e9ef),
                                              offset: Offset(1.0, 1.0), //(x,y)
                                              blurRadius: 20.0,
                                            ),

                                          ]
                                      ),
                                      child: const CircleAvatar(

                                        radius: 17,
                                        backgroundColor: Colors.white,
                                        child: Image(image: AssetImage("assest/images/edit_pink.png"),
                                          width: 17,
                                          height: 17,

                                        ),
                                      ),
                                    ),
                                  ),
                                ),


                                InkWell(
                                  onTap: (){
                                    if(image!=null){
                                      _asyncViewProfileDialog(context);
                                    }
                                  },
                                  child:  Container(
                                    height: 120.0,
                                    width: 120.0,
                                    decoration: BoxDecoration(

                                      color: Custom_color.BlueLightColor,
                                      image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(image,scale: 1.0),
                                      ),
                                      shape: BoxShape.circle,

                                    ),
//                            child: Align(
//                              alignment: Alignment.bottomRight,
//                              child: ClipOval(
//                                child: Material(
//                                  color: Custom_color.WhiteColor,
//                                  // button color
//                                  child: InkWell(
//                                    child: Container(
//                                        decoration: BoxDecoration(
//                                          shape: BoxShape.circle,
//                                          border: Border.all(
//                                            color: Custom_color.BlueLightColor,
//                                            width: 2.0,
//                                          ),
//                                        ),
//                                        width: 32,
//                                        height: 32,
//                                        child: Icon(
//                                          Icons.edit,
//                                          color: Custom_color.BlueLightColor,
//                                          size: 21,
//                                        )),
//                                    onTap: () {
//                                      Navigator.pushNamed(
//                                          context, Constant.MyProfile);
//                                    },
//                                  ),
//                                ),
//                              ),
//                            ),
                                  ),
                                ),

                                Positioned(
                                  top: 70,
                                  left: 95,
                                  child: GestureDetector(

                                    onTap: (){
                                      Navigator.pushNamed(context, Constant.Edit_my_profile);
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
                                        child: Image(image: AssetImage("assest/images/edit_pink.png"),
                                          width: 17,
                                          height: 17,

                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ]
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: _screenSize.width,
              child: Column(
                children: <Widget>[
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        Switch(
//                          value: isSwitched,
//                          onChanged: (value) {
//
//                            _showProgressCheckGPS(context);
//                            Future.delayed(Duration(seconds: 2), () {
//                              initPlatformState();
//                            });
////                          setState(() {
////
////                          //  isSwitched = value;
////                            print("----switch---" + isSwitched.toString());
////                          });
//                          },
//                          activeTrackColor: Custom_color.BlueLightColor,
//                          activeColor: Custom_color.BlueDarkColor,
//                        ),
//                        CustomWigdet.TextView(
//                            text: isSwitched
//                                ? AppLocalizations.of(context)
//                                    .translate("GPS active")
//                                : AppLocalizations.of(context)
//                                    .translate("GPS off"),
//                            color: Custom_color.BlackTextColor)
//                      ],
//                    ),
                  SizedBox(
                    height: 20,
                  ),
                  // Card(
                  //   elevation: 2,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(5),
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: <Widget>[
                  //         InkWell(
                  //           onTap: (){
                  //             Navigator.pushNamed(context, Constant.VisitorsScreen);
                  //           },
                  //           child: Column(
                  //             children: <Widget>[
                  //               CustomWigdet.TextView(
                  //                   text: AppLocalizations.of(context)
                  //                       .translate("visitors")
                  //                       .toUpperCase(),
                  //                   color: Custom_color.GreyLightColor),
                  //               CustomWigdet.TextView(
                  //                   text: visitors,
                  //                   color: Custom_color.BlackTextColor,
                  //                   fontFamily: "OpenSans Bold"),
                  //             ],
                  //           ),
                  //         ),
                  //         InkWell(
                  //           onTap: (){
                  //             Navigator.pushNamed(context, Constant.LikeScreen);
                  //           },
                  //           child: Column(
                  //             children: <Widget>[
                  //               CustomWigdet.TextView(
                  //                   text: AppLocalizations.of(context)
                  //                       .translate("liked")
                  //                       .toUpperCase(),
                  //                   color: Custom_color.GreyLightColor),
                  //               CustomWigdet.TextView(
                  //                   text: liked,
                  //                   color: Custom_color.BlackTextColor,
                  //                   fontFamily: "OpenSans Bold"),
                  //             ],
                  //           ),
                  //         ),
                  //         InkWell(
                  //           onTap: (){
                  //             Navigator.pushNamed(context, Constant.MatchScreen);
                  //           },
                  //           child: Column(
                  //             children: <Widget>[
                  //               CustomWigdet.TextView(
                  //                   text: AppLocalizations.of(context)
                  //                       .translate("matched")
                  //                       .toUpperCase(),
                  //                   color: Custom_color.GreyLightColor),
                  //               CustomWigdet.TextView(
                  //                   text: match,
                  //                   color: Custom_color.BlackTextColor,
                  //                   fontFamily: "OpenSans Bold"),
                  //             ],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  SizedBox(height: 20),
                  Container(


                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),

                        color: Colors.white,
                        boxShadow: [

                          BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 20.0,
                          ),
                        ]
                    ),
                    child: ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, Constant.MyPrefrences).then((value) async {
                            if(value) {
                              if (await UtilMethod.SimpleCheckInternetConnection(
                                  context, _scaffoldKey)) {
                                setState(() {
                                  _visible = false;
                                });
                                _GetUserDetail();
                                _GetProfile();
                              }
                            }
                          });

                        },
                        leading: Image.asset(
                          "assest/images/my_prefer.png",
                          width: 30,
                        ),
                        title: CustomWigdet.TextView(
                            overflow: true,
                            text: AppLocalizations.of(context)
                                .translate("My Preferences"),
                            color: Custom_color.BlackTextColor,
                            fontFamily: "Kelvetica Nobis"
                        ),
                        trailing:getImages()
                    ),
                  ),

                  SizedBox(height: 20),
                  // Container(
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(5),
                  //
                  //       color: Colors.white,
                  //       boxShadow: [
                  //
                  //         BoxShadow(
                  //           color:  Custom_color.GreyLightColor3,
                  //           offset: Offset(1.0, 1.0), //(x,y)
                  //           blurRadius: 20.0,
                  //         ),
                  //       ]
                  //   ),
                  //   child: ListTile(
                  //     onTap: () {
                  //       Navigator.pushNamed(context, Constant.Edit_my_profile);
                  //     },
                  //     leading:Image.asset(
                  //       "assest/images/edit.png",
                  //       width: 30,
                  //     ),
                  //
                  //
                  //
                  //
                  //     title: CustomWigdet.TextView(
                  //         text: AppLocalizations.of(context)
                  //             .translate("Edit Profile"),
                  //         color: Custom_color.BlackTextColor),
                  //     trailing: getImages(),
                  //   ),
                  // ),
                  // SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),

                        color: Colors.white,
                        boxShadow: [

                          BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 20.0,
                          ),
                        ]
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, Constant.Favorites);
                      },
                      leading: Image.asset(
                        "assest/images/favorites.png",
                        width: 25,
                        height: 25,
                      ),
                      title: CustomWigdet.TextView(
                          text: AppLocalizations.of(context)
                              .translate("Favorites"),
                          color: Custom_color.BlackTextColor,
                          fontFamily: "Kelvetica Nobis"),
                      trailing: getImages(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),

                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 20.0,
                          ),
                        ]
                    ),
                    child: ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, Constant.MatchProfile);
                        },
                        leading: Image.asset(
                          "assest/images/match_profile.png",
                          width: 25,
                          height: 25,
                        ),
                        title: CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("Match Profile"),
                            color: Custom_color.BlackTextColor,
                            fontFamily: "Kelvetica Nobis"),
                        trailing: getImages()
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),

                        color: Colors.white,
                        boxShadow: [

                          BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 20.0,
                          ),
                        ]
                    ),
                    child: ListTile(
                        onTap: () {
                          Navigator.pushNamed(
                              context, Constant.ActivitySetting,
                              arguments: {"leading": true});
                        },
                        leading: Image.asset(
                          "assest/images/activity_setting.png",
                          width: 25,
                          height: 25,
                        ),
                        title: CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("Activitys"),
                            color: Custom_color.BlackTextColor,
                            fontFamily: "Kelvetica Nobis"),
                        trailing: getImages()
                    ),
                  ),

                  SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),

                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 20.0,
                          ),
                        ]
                    ),
                    child: ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, Constant.AppSettings);
                        },
                        leading: Image.asset(
                          "assest/images/app_setting.png",
                          width: 25,
                          height: 25,
                        ),
                        title: CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("App Settings"),
                            color: Custom_color.BlackTextColor,
                            fontFamily: "Kelvetica Nobis"),
                        trailing: getImages()
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),

                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 20.0,
                          ),
                        ]
                    ),
                    child: ListTile(
                        onTap: () {
                          _asyncConfirmLanguage(context);                      },
                        leading: Image.asset(
                          "assest/images/language.png",
                          width: 25,
                          height: 25,
                        ),
                        title: CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("Language"),
                            color: Custom_color.BlackTextColor,
                            fontFamily: "Kelvetica Nobis"),
                        trailing: getImages()
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),

                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 20.0,
                          ),
                        ]
                    ),

                    child: ListTile(
                        onTap: () {
                          _asyncConfirmDialogHelp(context);
                        },
                        leading: Image.asset(
                          "assest/images/need_help.png",
                          width: 25,
                          height: 25,
                        ),
                        title: CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("Need Help"),
                            color: Custom_color.BlackTextColor,
                            fontFamily: "Kelvetica Nobis"),
                        trailing: getImages()
                    ),
                  ),
                  SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),

                        color: Color(0xfffb4592),
                        boxShadow: [

                          BoxShadow(
                            color: Color(0xffe4e9ef),
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 20.0,
                          ),
                        ]
                    ),
                    child: ListTile(
                      onTap: () {
                        _asyncConfirmDialog(context);
                      },

                      title: Center(
                        child: CustomWigdet.TextView(
                            text:
                            AppLocalizations.of(context).translate("Logout"),
                            color: Custom_color.WhiteColor,
                            fontFamily: "Kevetica Nobis"),
                      ),

                    ),
                  ),
                  SizedBox(height: 30)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _widgetLoaderRefresh(){

    return checkRefresh!=false?Center(
      child: SingleChildScrollView(
        child: Column(
          children: [

            Container(
                margin: EdgeInsets.only(top: MQ_Height*0.02),
                child:
            const Image(image: AssetImage('assest/images/activity_wall.png'))),

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
                        arguments: {"index": 3, "index_home": 0});
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
                          arguments: {"index": 3, "index_home": 0});
                    }
                  });
                }else{

                 // FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
                  ShowDialogNetworkError.showDialogNetworkErrorMessage(context, 'Network', '${AppLocalizations.of(context).translate("Please connect your internet")}', 0, 'network', MQ_Width, MQ_Height);

                }
              },
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder(),
                   // minimumSize: Size(200, 50)
                  ),

                  child: Text(AppLocalizations.of(context).translate("Try again"),
                    style:const TextStyle(fontWeight: FontWeight.w500,fontSize: 15) ,))
            ],
          ),
        ),
      ),
    );
  }

  //================= New UI ===============
  Widget _widgetNewUIPersonal(){
    List<Color> _kDefaultRainbowColors = const [
      Colors.blue,
      Colors.blue,
      Colors.blue,
      Colors.pinkAccent,
      Colors.pink,
      Colors.pink,
      Colors.pinkAccent,

    ];
    print('_widgetNewUIPersonal  networkEnable=$networkEnable\n_visible=$_visible');
    return Visibility(
      visible: networkEnable&&_visible,
      replacement:  checkRefresh!=true?Center(
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
      ):networkEnable==true?_widgetLoaderRefresh():_widgetNetworkConnectivity(),
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
       /* appBar: PreferredSize(
          preferredSize: Size(double.infinity, 185),*/
          //     preferredSize: Size.fromHeight(135.0), // here the desired height

          body: Container(
            color:Helper.inBackgroundColor,
            child: Column(
              children: [

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
                            Container(

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
                            ),
                            true?Container(
                              child: CustomWigdet.TextView(
                                  textAlign: TextAlign.center,
                                  text: "tellme",

                                  fontFamily: "Kelvetica Nobis",
                                  color: Helper.textColorBlueH1,//Custom_color.BlackTextColor,
                                  fontWeight: Helper.textFontH5,
                                  fontSize:Helper.textSizeH8),
                            ):Container(
                              margin:  EdgeInsets.only(left:MQ_Width *0.08,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: 0),

                              alignment: Alignment.centerLeft,
                              //width: 200,
                              height: 60,
                              child: Image(
                                alignment: Alignment.centerLeft,
                                image: AssetImage("assest/images/tellme.png"),
                              ),
                            ),

                            Container(
                              child: CustomWigdet.TextView(
                                  textAlign: TextAlign.center,
                                  text: "live",
                                  fontFamily: "Kelvetica Nobis",
                                  color: Color(Helper.textColorPinkH1),//Custom_color.BlackTextColor,
                                  fontWeight: Helper.textFontH5,
                                  fontSize:Helper.textSizeH8),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Row(
                          children: [
                            // InkWell(
                            //   child: Container(
                            //     child:Icon(Icons.upload)
                            //   ),
                            //   onTap: (){
                            //     Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
                            //     Gallery_Screen()));
                            //   },
                            // ),

                            Container(
                              height: 40,
                              width: 40,
                              /*decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color : Color(0xfff73c8d),
                              ),*/
                              child: RawMaterialButton(
                                onPressed: () {
                                  print("Navigate to Notification screen");
                                  if(networkEnable==true) {
                                    Navigator.pushNamed(
                                        context, Constant.NotificationScreen);
                                  }else{
                                    FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
                                  }
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      "assest/images/notification_2.png",
                                      width: 25,
                                      color: Colors.blue,//Colors.white,
                                      alignment: Alignment.center,
                                    ),
                                    Consumer<CounterModel>(
                                        builder: (context, myModel, child) {
                                          return Constant.DummyNotificationCount.isNotEmpty &&
                                              Constant.DummyNotificationCount != null &&
                                              int.parse(myModel
                                                  .getNotificationCounter()
                                                  .toString()) >
                                                  0
                                              ? Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                  BorderRadius.circular(10),
                                                ),
                                                constraints: const BoxConstraints(
                                                  minWidth: 18,
                                                  minHeight: 18,
                                                ),
                                                child: Center(
                                                  child: CustomWigdet.TextView(
                                                      text: int.parse(myModel
                                                          .getNotificationCounter()
                                                          .toString()) >
                                                          99
                                                          ? "99+"
                                                          : myModel.getNotificationCounter().toString(),
                                                      fontFamily: "OpenSans Bold",
                                                      fontSize: 9,
                                                      color: Custom_color.WhiteColor),
                                                )),
                                          )
                                              : Container();
                                        })
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: MQ_Width*0.05,),
                            Container(
                              margin: EdgeInsets.only(right: 5),

                                child:false?Image.asset('assets/images/location-pin.png'):
                                InkWell(
                                  child: false?Image(image: AssetImage("assest/images/pin_map.png"),width: 30,height: 30,
                                      color: isLocationEnabled ? Colors.green : Color.fromRGBO(255, 85, 85, 1)
                                  ):SvgPicture.asset('assest/images_svg/location.svg',width: 26,height: 26,
                                      color: isLocationEnabled ? Colors.green :Color(Helper.textColorPinkH1)),
                                  onTap: ()async{
                                    if(networkEnable ==true) {
                                      _asyncConfirmToggle(context);
                                    }else{
                                      FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
                                    }
                                  },

                                )
                            ),


                          ],
                        ),
                      ),

                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                      false?Stack(

                          alignment: Alignment.bottomCenter,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 35.0),
                              child: Container(
                                height: 250.0,
                                decoration: BoxDecoration(

                                    gradient: LinearGradient(colors: [Color(0xff22b7f1), Color(0xff1c5baa)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)
                                ),
                              ),
                            ),
                            Image(image: AssetImage("assest/images/curve.png")),

                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    CustomWigdet.TextView(
                                        text: name.toString().toUpperCase(), color: Custom_color.WhiteColor),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Stack(
                                        clipBehavior: Clip.none,

                                        children: [
                                          Positioned(
                                            top: 70,
                                            left: 95,
                                            child: GestureDetector(

                                              onTap: (){
                                                Navigator.pushNamed(context, Constant.Edit_my_profile);
                                                print("Edit Profile");

                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(0xffe4e9ef),
                                                        offset: Offset(1.0, 1.0), //(x,y)
                                                        blurRadius: 20.0,
                                                      ),

                                                    ]
                                                ),
                                                child: CircleAvatar(

                                                  radius: 17,
                                                  backgroundColor: Colors.white,
                                                  child: Image(image: AssetImage("assest/images/edit_pink.png"),
                                                    width: 17,
                                                    height: 17,

                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),


                                          InkWell(
                                            onTap: (){
                                              if(image!=null){
                                                _asyncViewProfileDialog(context);
                                              }
                                            },
                                            child:  Container(
                                              height: 120.0,
                                              width: 120.0,
                                              decoration: BoxDecoration(

                                                color: Custom_color.BlueLightColor,
                                                image: new DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(image),
                                                ),
                                                shape: BoxShape.circle,

                                              ),
//                            child: Align(
//                              alignment: Alignment.bottomRight,
//                              child: ClipOval(
//                                child: Material(
//                                  color: Custom_color.WhiteColor,
//                                  // button color
//                                  child: InkWell(
//                                    child: Container(
//                                        decoration: BoxDecoration(
//                                          shape: BoxShape.circle,
//                                          border: Border.all(
//                                            color: Custom_color.BlueLightColor,
//                                            width: 2.0,
//                                          ),
//                                        ),
//                                        width: 32,
//                                        height: 32,
//                                        child: Icon(
//                                          Icons.edit,
//                                          color: Custom_color.BlueLightColor,
//                                          size: 21,
//                                        )),
//                                    onTap: () {
//                                      Navigator.pushNamed(
//                                          context, Constant.MyProfile);
//                                    },
//                                  ),
//                                ),
//                              ),
//                            ),
                                            ),
                                          ),

                                          Positioned(
                                            top: 70,
                                            left: 95,
                                            child: GestureDetector(

                                              onTap: (){
                                                Navigator.pushNamed(context, Constant.Edit_my_profile);
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
                                                  child: Image(image: AssetImage("assest/images/edit_pink.png"),
                                                    width: 17,
                                                    height: 17,

                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ]
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ): Stack(
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
                                          .BlackTextColor),
                                ),
                              )),

                          //Image(image: AssetImage("assest/images/curve.png",),),

                          Image.asset('assest/images/curve.png',
                            color:Helper.inBackgroundColor,),
                         // !UtilMethod.isStringNullOrBlank(image ) ?
                          Positioned.fill(
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
                                              image: !UtilMethod.isStringNullOrBlank(image )?NetworkImage(
                                                  image,scale: 1.0):AssetImage('assest/images/user2.png'),
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
                                                image: !UtilMethod.isStringNullOrBlank(image )?NetworkImage(
                                                    image,scale: 1.0):AssetImage('assest/images/user2.png'),
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
                                            Navigator.pushNamed(context, Constant.Edit_my_profile);
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
                                              child: Image(image: AssetImage("assest/images/edit_pink.png",),
                                                width: 16,
                                                height: 16,
                                                color: Colors.blue.shade400,

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
                          ),

                        ],
                      ),
                        SizedBox(
                          height: MQ_Height*0.05,
                        ),

                        //========== List ==


                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              width: _screenSize.width,
                              child: Column(
                                children: <Widget>[
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        Switch(
//                          value: isSwitched,
//                          onChanged: (value) {
//
//                            _showProgressCheckGPS(context);
//                            Future.delayed(Duration(seconds: 2), () {
//                              initPlatformState();
//                            });
////                          setState(() {
////
////                          //  isSwitched = value;
////                            print("----switch---" + isSwitched.toString());
////                          });
//                          },
//                          activeTrackColor: Custom_color.BlueLightColor,
//                          activeColor: Custom_color.BlueDarkColor,
//                        ),
//                        CustomWigdet.TextView(
//                            text: isSwitched
//                                ? AppLocalizations.of(context)
//                                    .translate("GPS active")
//                                : AppLocalizations.of(context)
//                                    .translate("GPS off"),
//                            color: Custom_color.BlackTextColor)
//                      ],
//                    ),

                                  // Card(
                                  //   elevation: 2,
                                  //   shape: RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.circular(5),
                                  //   ),
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                  //     child: Row(
                                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  //       children: <Widget>[
                                  //         InkWell(
                                  //           onTap: (){
                                  //             Navigator.pushNamed(context, Constant.VisitorsScreen);
                                  //           },
                                  //           child: Column(
                                  //             children: <Widget>[
                                  //               CustomWigdet.TextView(
                                  //                   text: AppLocalizations.of(context)
                                  //                       .translate("visitors")
                                  //                       .toUpperCase(),
                                  //                   color: Custom_color.GreyLightColor),
                                  //               CustomWigdet.TextView(
                                  //                   text: visitors,
                                  //                   color: Custom_color.BlackTextColor,
                                  //                   fontFamily: "OpenSans Bold"),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //         InkWell(
                                  //           onTap: (){
                                  //             Navigator.pushNamed(context, Constant.LikeScreen);
                                  //           },
                                  //           child: Column(
                                  //             children: <Widget>[
                                  //               CustomWigdet.TextView(
                                  //                   text: AppLocalizations.of(context)
                                  //                       .translate("liked")
                                  //                       .toUpperCase(),
                                  //                   color: Custom_color.GreyLightColor),
                                  //               CustomWigdet.TextView(
                                  //                   text: liked,
                                  //                   color: Custom_color.BlackTextColor,
                                  //                   fontFamily: "OpenSans Bold"),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //         InkWell(
                                  //           onTap: (){
                                  //             Navigator.pushNamed(context, Constant.MatchScreen);
                                  //           },
                                  //           child: Column(
                                  //             children: <Widget>[
                                  //               CustomWigdet.TextView(
                                  //                   text: AppLocalizations.of(context)
                                  //                       .translate("matched")
                                  //                       .toUpperCase(),
                                  //                   color: Custom_color.GreyLightColor),
                                  //               CustomWigdet.TextView(
                                  //                   text: match,
                                  //                   color: Custom_color.BlackTextColor,
                                  //                   fontFamily: "OpenSans Bold"),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),

                                 // SizedBox(height: 20),
                                 true? Container(


                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),

                                        color: Colors.white,
                                        boxShadow: [

                                          BoxShadow(
                                            color: Color(0xffe4e9ef),
                                            offset: Offset(1.0, 1.0), //(x,y)
                                            blurRadius: 20.0,
                                          ),
                                        ]
                                    ),
                                    child: ListTile(
                                        onTap: () {
                                          Navigator.pushNamed(context, Constant.MyPrefrences).then((value) async {
                                            if(value) {
                                              if (await UtilMethod.SimpleCheckInternetConnection(
                                                  context, _scaffoldKey)) {
                                                setState(() {
                                                  _visible = false;
                                                });
                                                _GetUserDetail();
                                                _GetProfile();
                                              }
                                            }
                                          });

                                        },
                                        leading: Image.asset(
                                          "assest/images/my_prefer.png",
                                          width: 30,
                                        ),
                                        title: CustomWigdet.TextView(
                                            overflow: true,
                                            text: AppLocalizations.of(context)
                                                .translate("My Preferences"),
                                            color: Custom_color.BlackTextColor,
                                            fontFamily: "Kelvetica Nobis"
                                        ),
                                        trailing:getImages()
                                    ),
                                  ):Container(),

                                //  SizedBox(height: 20),

                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(5),
                                  //
                                  //       color: Colors.white,
                                  //       boxShadow: [
                                  //
                                  //         BoxShadow(
                                  //           color:  Custom_color.GreyLightColor3,
                                  //           offset: Offset(1.0, 1.0), //(x,y)
                                  //           blurRadius: 20.0,
                                  //         ),
                                  //       ]
                                  //   ),
                                  //   child: ListTile(
                                  //     onTap: () {
                                  //       Navigator.pushNamed(context, Constant.Edit_my_profile);
                                  //     },
                                  //     leading:Image.asset(
                                  //       "assest/images/edit.png",
                                  //       width: 30,
                                  //     ),
                                  //
                                  //
                                  //
                                  //
                                  //     title: CustomWigdet.TextView(
                                  //         text: AppLocalizations.of(context)
                                  //             .translate("Edit Profile"),
                                  //         color: Custom_color.BlackTextColor),
                                  //     trailing: getImages(),
                                  //   ),
                                  // ),
                                  SizedBox(height: MQ_Height*0.03),
                                 true? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),

                                        color: Colors.white,
                                        boxShadow: [

                                          BoxShadow(
                                            color: Color(0xffe4e9ef),
                                            offset: Offset(1.0, 1.0), //(x,y)
                                            blurRadius: 20.0,
                                          ),
                                        ]
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.pushNamed(context, Constant.Favorites);
                                      },
                                      leading: Image.asset(
                                        "assest/images/favorites.png",
                                        width: 25,
                                        height: 25,
                                      ),
                                      title: CustomWigdet.TextView(
                                          text: AppLocalizations.of(context)
                                              .translate("Favorites"),
                                          color: Custom_color.BlackTextColor,
                                          fontFamily: "Kelvetica Nobis"),
                                      trailing: getImages(),
                                    ),
                                  ):Container(),
                                  SizedBox(height: MQ_Height*0.03),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),

                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xffe4e9ef),
                                            offset: Offset(1.0, 1.0), //(x,y)
                                            blurRadius: 20.0,
                                          ),
                                        ]
                                    ),
                                    child: ListTile(
                                        onTap: () {
                                          Navigator.pushNamed(context, Constant.MatchProfile);
                                        },
                                        leading: Image.asset(
                                          "assest/images/match_profile.png",
                                          width: 25,
                                          height: 25,
                                        ),
                                        title: CustomWigdet.TextView(
                                            text: AppLocalizations.of(context)
                                                .translate("Match Profile"),
                                            color: Custom_color.BlackTextColor,
                                            fontFamily: "Kelvetica Nobis"),
                                        trailing: getImages()
                                    ),
                                  ),
                                  SizedBox(height: MQ_Height*0.03),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),

                                        color: Colors.white,
                                        boxShadow: [

                                          BoxShadow(
                                            color: Color(0xffe4e9ef),
                                            offset: Offset(1.0, 1.0), //(x,y)
                                            blurRadius: 20.0,
                                          ),
                                        ]
                                    ),
                                    child: ListTile(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, Constant.ActivitySetting,
                                              arguments: {"leading": true});
                                        },
                                        leading: Image.asset(
                                          "assest/images/activity_setting.png",
                                          width: 25,
                                          height: 25,
                                        ),
                                        title: CustomWigdet.TextView(
                                            text: AppLocalizations.of(context)
                                                .translate("Activitys"),
                                            color: Custom_color.BlackTextColor,
                                            fontFamily: "Kelvetica Nobis"),
                                        trailing: getImages()
                                    ),
                                  ),

                                  SizedBox(height: MQ_Height*0.03),

                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),

                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xffe4e9ef),
                                            offset: Offset(1.0, 1.0), //(x,y)
                                            blurRadius: 20.0,
                                          ),
                                        ]
                                    ),
                                    child: ListTile(
                                        onTap: () {
                                          Navigator.pushNamed(context, Constant.AppSettings,arguments: {'image_user':image});
                                        },
                                        leading: Image.asset(
                                          "assest/images/app_setting.png",
                                          width: 25,
                                          height: 25,
                                        ),
                                        title: CustomWigdet.TextView(
                                            text: AppLocalizations.of(context)
                                                .translate("App Settings"),
                                            color: Custom_color.BlackTextColor,
                                            fontFamily: "Kelvetica Nobis"),
                                        trailing: getImages()
                                    ),
                                  ),
                                  SizedBox(height: MQ_Height*0.03),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),

                                        color: Colors.white,
                                        boxShadow: [

                                          BoxShadow(
                                            color: Color(0xffe4e9ef),
                                            offset: Offset(1.0, 1.0), //(x,y)
                                            blurRadius: 20.0,
                                          ),
                                        ]
                                    ),
                                    child: ListTile(
                                        onTap: () {
                                          _asyncConfirmLanguage(context);                      },
                                        leading: Image.asset(
                                          "assest/images/language.png",
                                          width: 25,
                                          height: 25,
                                        ),
                                        title: CustomWigdet.TextView(
                                            text: AppLocalizations.of(context)
                                                .translate("Language"),
                                            color: Custom_color.BlackTextColor,
                                            fontFamily: "Kelvetica Nobis"),
                                        trailing: getImages()
                                    ),
                                  ),
                                  SizedBox(height: MQ_Height*0.03),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),

                                        color: Colors.white,
                                        boxShadow: [

                                          BoxShadow(
                                            color: Color(0xffe4e9ef),
                                            offset: Offset(1.0, 1.0), //(x,y)
                                            blurRadius: 20.0,
                                          ),
                                        ]
                                    ),

                                    child: ListTile(
                                        onTap: () {
                                          _asyncConfirmDialogHelp(context);
                                        },
                                        leading: Image.asset(
                                          "assest/images/need_help.png",
                                          width: 25,
                                          height: 25,
                                        ),
                                        title: CustomWigdet.TextView(
                                            text: AppLocalizations.of(context)
                                                .translate("Need Help"),
                                            color: Custom_color.BlackTextColor,
                                            fontFamily: "Kelvetica Nobis"),
                                        trailing: getImages()
                                    ),
                                  ),
                                  SizedBox(height: MQ_Height*0.03),

                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),

                                        color: Color(0xfffb4592),
                                        boxShadow: [

                                          BoxShadow(
                                            color: Color(0xffe4e9ef),
                                            offset: Offset(1.0, 1.0), //(x,y)
                                            blurRadius: 20.0,
                                          ),
                                        ]
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        _asyncConfirmDialog(context);
                                      },

                                      title: Center(
                                        child: CustomWigdet.TextView(
                                            text:
                                            AppLocalizations.of(context).translate("Logout"),
                                            color: Custom_color.WhiteColor,
                                            fontFamily: "Kevetica Nobis",
                                            fontWeight: Helper.textFontH4,
                                             fontSize: Helper.textSizeH14),
                                      ),

                                    ),
                                  ),
                                  SizedBox(height: MQ_Height*0.03),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

     // ),
    );
  }


  Widget getImages(){
    return Image.asset(
      SessionManager.getString(Constant.Language_code) == "en" || SessionManager.getString(Constant.Language_code)=="de"?"assest/images/next.png"  : "assest/images/next_ar.png",
      width: 20,
      height: 20,
        color: Colors.grey
    );
  }
//================== Old  Dialog Choose Language ===============
  Future _asyncConfirmLanguage1(BuildContext context) async {
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                 //   mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left:20.0,right: 8,top: 10),
                        child: CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("Choose language"),
                            fontSize: 18,
                            fontFamily: "OpenSans Bold",
                            color: Custom_color.BlackTextColor),
                      ),
                      RadioListTile(
                        dense: true,
                        groupValue: radioLanguage,
                        title: CustomWigdet.TextView(
                            fontSize: 16,
                            text: AppLocalizations.of(context)
                                .translate("English"),
                            color: Custom_color.BlackTextColor),
                        value: Constant.English,
                        onChanged: (val) async {
                          if (await UtilMethod.SimpleCheckInternetConnection(
                              context, _scaffoldKey)) {
                            setState(() {
                              radioLanguage = val;
                              print(' English Radio button radioLanguage=$val');

                            //  SessionManager.setString(Constant.Language_code,"en" );
                           //   _filterModel.updateLanguage(radioLanguage);
                            });
                            _appLanguage.changeLanguage(Locale("en"));

                          }
                        },
                      ),
                      RadioListTile(
                        dense: true,
                        groupValue: radioLanguage,
                        title: CustomWigdet.TextView(
                            fontSize: 16,
                            text: AppLocalizations.of(context)
                                .translate("German"),
                            color: Custom_color.BlackTextColor),
                        value: Constant.German,
                        onChanged: (val) async {

                          if (await UtilMethod.SimpleCheckInternetConnection(
                              context, _scaffoldKey)) {
                            setState(() {
                              radioLanguage = val;
                              print(' German Radio button radioLanguage=$val');

                          //    SessionManager.setString(Constant.Language_code,"de" );
                          //    _filterModel.updateLanguage(radioLanguage);
                            });
                           _appLanguage.changeLanguage(Locale("de"));


                          }
                        },
                      ),
                      // RadioListTile(
                      //   dense: true,
                      //   groupValue: radioLanguage,
                      //   title: CustomWigdet.TextView(
                      //       fontSize: 16,
                      //       text: AppLocalizations.of(context)
                      //           .translate("Arabic"),
                      //       color: Custom_color.BlackTextColor),
                      //   value: Constant.Arabic,
                      //   onChanged: (val) async {
                      //     if (await UtilMethod.SimpleCheckInternetConnection(
                      //         context, _scaffoldKey)) {
                      //       setState(() {
                      //         radioLanguage = val;
                      //         //    _filterModel.updateLanguage(radioLanguage);
                      //       });
                      //       _appLanguage.changeLanguage(Locale("ar"));
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }


  //================== New  Dialog Choose Language ===============

  Future<void> _asyncConfirmLanguage(BuildContext context)async{


        await showDialog(context: context,
            builder: (BuildContext context) {
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
                  child: Dialog(

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Helper.avatarRadius),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [

                          Container(
                            //height: MQ_Height*0.45,
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
                                  alignment: Alignment.centerLeft,
                                  //  margin: EdgeInsets.only(bottom: 30),
                                  child: CustomWigdet.TextView(
                                      text: AppLocalizations.of(context).translate("Choose"),
                                      //AppLocalizations.of(context).translate("Create Activity"),
                                      fontFamily: "Kelvetica Nobis",
                                      fontSize: Helper.textSizeH3,
                                      fontWeight: Helper.textFontH2,
                                      color:  Color(0xfff16cae)//Helper.textColorBlueH1
                                  ),
                                ),
                                SizedBox(height: MQ_Height * 0.01,),

                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: CustomWigdet.TextView(
                                    overflow: true,
                                    text: AppLocalizations.of(context)
                                        .translate("Your Language"),
                                    //AppLocalizations.of(context).translate("Create Activity"),
                                    fontFamily: "Kelvetica Nobis",
                                    fontSize: Helper.textSizeH10,
                                    fontWeight: Helper.textFontH5,
                                    color: Custom_color.GreyLightColor,

                                  ),
                                ),
                                SizedBox(height: MQ_Height * 0.02,),

                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
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
                                                  Colors.blue.withOpacity(0.4),
                                                  Colors.blue.withOpacity(0.3),

                                                ],
                                              ),
                                              shape: BoxShape.circle
                                          ),
                                          padding: EdgeInsets.all(5),
                                          child: Container(
                                            height: 120,
                                            width: 120,
                                            //padding: EdgeInsets.all(2),
                                            // margin: EdgeInsets.only(bottom: MQ_Height*0.05),

                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle
                                            ),
                                            child: Column(
                                                children: [
                                                  Container(
                                                    child: CircleAvatar(
                                                      backgroundColor: Colors.transparent,
                                                      radius: Helper.avatarRadius,
                                                      child: ClipRRect(
                                                          borderRadius: BorderRadius.all(
                                                              Radius.circular(Helper.avatarRadius)),
                                                          child: Image(
                                                            width: 60,
                                                            height: 60,
                                                            image: AssetImage("assest/images/flag.png"),
                                                          )
                                                      ),
                                                    ),
                                                  ),

                                                  Container(
                                                    margin: EdgeInsets.only(bottom: 10),
                                                    child:  CustomWigdet.TextView(

                                                      text: AppLocalizations.of(context)
                                                          .translate("German"),
                                                      color: Custom_color.BlackTextColor,
                                                      fontWeight: Helper.textFontH5,
                                                      fontSize: Helper.textSizeH14,),
                                                  )
                                                ],
                                              ),

                                          ),
                                        ),
                                        onTap: ()async{
                                          if (await UtilMethod.SimpleCheckInternetConnection(
                                          context, _scaffoldKey)) {
                                          setState(() {
                                          radioLanguage = 2;//val;
                                         // print(' German Radio button radioLanguage=$val');

                                          //    SessionManager.setString(Constant.Language_code,"de" );
                                          //    _filterModel.updateLanguage(radioLanguage);
                                          });
                                          _appLanguage.changeLanguage(Locale("de"));

                                           Navigator.pop(context,1);
                                          }
                                        },
                                      ),

                                      InkWell(
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
                                                  Colors.blue.withOpacity(0.4),
                                                  Colors.blue.withOpacity(0.3),

                                                ],
                                              ),
                                              shape: BoxShape.circle
                                          ),
                                          padding: EdgeInsets.all(5),

                                          child: Container(
                                            height: 120,
                                            width: 120,
                                            // padding: EdgeInsets.all(5),
                                            // margin: EdgeInsets.only(bottom: MQ_Height*0.05),

                                            decoration: BoxDecoration(
                                               color: Colors.white,
                                                shape: BoxShape.circle
                                            ),

                                            child: Column(
                                              children: [
                                                Container(

                                                  child: CircleAvatar(
                                                    backgroundColor: Colors.transparent,
                                                    radius: Helper.avatarRadius,
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(Helper.avatarRadius)),
                                                        child: Image(
                                                          width: 60,
                                                          height: 60,
                                                          image: AssetImage("assest/images/eng.png"),
                                                        )
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(bottom: 10),
                                                  child:  CustomWigdet.TextView(

                                                      text: AppLocalizations.of(context)
                                                          .translate("English"),
                                                      color: Custom_color.BlackTextColor,
                                                       fontWeight: Helper.textFontH5,
                                                       fontSize: Helper.textSizeH14,),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        onTap: ()async{
                                          if (await UtilMethod.SimpleCheckInternetConnection(
                                              context, _scaffoldKey)) {
                                            setState(() {
                                             radioLanguage =1; //val;

                                              //  SessionManager.setString(Constant.Language_code,"en" );
                                              //   _filterModel.updateLanguage(radioLanguage);
                                            });
                                            _appLanguage.changeLanguage(Locale("en"));
                                            Navigator.pop(context,0);

                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: MQ_Height * 0.02,),
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
                                    margin: EdgeInsets.only(top: 8,),
                                    padding: EdgeInsets.all(5),
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
                                    child: Icon(Icons.close,color: Colors.white,size:24,)),
                                onTap: (){
                                  Navigator.pop(context,1);
                                },
                              )):Container(),

                        ],),
                    ),
                  ),
                ),
              );
            });

  }


  Future<https.Response> _GetUserDetail() async {
    try {
      String url = WebServices.GetUserProfile + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        print('personal_page  _GetUserDetail response.body=${response.body}');

        var data = json.decode(response.body);
        print('personal_page  _GetUserDetail data=${data}');
        if (data["status"]) {
          image = data["image"].toString();
          name = data["name"].toString();
          visitors = data["visitors"].toString();
          liked = data["liked"].toString();
          match = data["match"].toString();

          /*imagelist = data["image"] as List;
          if (imagelist != null && imagelist.length > 0) {
            for (var i = 0; i < imagelist.length; i++) {
              images.add(imagelist[i]["name"].toString());
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              images.forEach((imageUrl) {
                precacheImage(NetworkImage(imageUrl), context);
              });
            });
          }*/
         if(mounted) {
           setState(() {
            _visible = true;

          });
         }
        } else {
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }
        }
       if(mounted) {
         setState(() {
          _visible = true;

        });
       }
      }else{
        if(mounted) {
          setState(() {
            _visible = false;

          });
        }
      }
    } on Exception catch (e) {
      if(mounted) {
        setState(() {
          _visible = false;
        });
      }
      print(e.toString());
      // _hideProgress();
    }
  }

  //=============== New Add Image =========

  Future<https.Response> _GetProfile() async {
    try {
      if (images != null && images.isNotEmpty) {
        images.clear();
       // activitylist.clear();
      }
      /*if(bylist_activitylike!=null && bylist_activitylike.isNotEmpty){
        bylist_activitylike.clear();
      }
      if(bylist_activitycreate!=null && bylist_activitycreate.isNotEmpty){
        bylist_activitycreate.clear();
      }*/
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
            // interest = data["user_info"]["interest"];
            // prof_interest = data["user_info"]["prof_interest"];
            // name = data["name"];
            // name_demo = data["user_info"]["name"];
            // gender = data["user_info"]["gender"];
            try{
              if(data["user_info"]["dob"]!=null){

                var dateOfBirth=data["user_info"]["dob"];
                var dateFormat=new DateFormat("dd-MM-yyyy").parse(dateOfBirth);
                //  var DayName=DateFormat.EEEE().format(dateFormat);
                var Date=DateFormat.d().format(dateFormat);
                var  MonthName= DateFormat.MMMM().format(dateFormat);
                var  Year= DateFormat.y().format(dateFormat);
                //dob = '${Date} ${MonthName} ${Year}';

              }
            }catch(error){

            }

            var social = data["user_info"]["social"];
            /*try{ about_me = data["user_info"]["social"];}catch(e){}
            try{about_myself = data["user_info"]["about_me"];}catch(e){}
            profile_image = data["user_info"]["profile_img"];
            if (social.runtimeType != String) {
              facebook = data["user_info"]["social"]["facebook"];
              twitter = data["user_info"]["social"]["twitter"];
              instagram = data["user_info"]["social"]["instagram"];
              tiktok = data["user_info"]["social"]["tiktok"];
              linkedin = data["user_info"]["social"]["linkedin"];
            }*/


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
            /*if (activity_listlike != null && activity_listlike.length > 0) {
              bylist_activitylike = activity_listlike
                  .map<UserEvent>((index) => UserEvent.fromJson(index))
                  .toList();
            }

            var activity_listcreate = data["user_info"]["user_events"] as List;
            if (activity_listcreate != null && activity_listcreate.length > 0) {
              bylist_activitycreate = activity_listcreate
                  .map<UserEvent>((index) => UserEvent.fromJson(index))
                  .toList();
            }*/

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

            /*var activity_list = data["activity"] as List;
            if (activity_list != null && activity_list.length > 0) {
              activitylist = activity_list
                  .map<Activity_holder>(
                      (index) => Activity_holder.fromJson(index))
                  .toList();
            }*/

            if(mounted) {
              setState(() {
                _visible = true;
                loading = true;

              });
            }


          });
        } else {
          if(mounted) {
            setState(() {
              _visible = false;
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
      }else{
        if(mounted) {
          setState(() {
            _visible = false;
            loading = false;

          });
        }
      }
    } on Exception catch (e) {
      print(e.toString());
      if(mounted) {
        setState(() {
          _visible = false;
          loading = false;
        });
      }
    }
  }


  getLogout() {
    SessionManager.setString(Constant.Token, "");
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constant.LoginRoute,
      (Route<dynamic> route) => false,
    );
  }

//  Future _asyncConfirmDialog(BuildContext context) async {
//    return showDialog(
//      context: context,
//      barrierDismissible: false, // user must tap button for close dialog!
//      builder: (BuildContext context) {
//        return AlertDialog(
//          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//          title: CustomWigdet.TextView(
//              text: AppLocalizations.of(context).translate("Alert Message"),
//              color: Custom_color.BlackTextColor,
//              fontFamily: "OpenSans Bold"),
//          content: CustomWigdet.TextView(
//              text: AppLocalizations.of(context)
//                  .translate("Are you sure want to logout"),
//              color: Custom_color.BlackTextColor),
//          actions: <Widget>[
//            CustomWigdet.FlatButtonSimple(
//                onPress: () {
//                  getLogout();
//                },
//                text: AppLocalizations.of(context).translate("Confirm"),
//                textColor: Custom_color.BlueLightColor,
//                fontFamily: "OpenSans Bold"),
//            CustomWigdet.FlatButtonSimple(
//                onPress: () {
//                  Navigator.of(context).pop();
//                },
//                text: AppLocalizations.of(context).translate("Cancel"),
//                textColor: Custom_color.BlueLightColor,
//                fontFamily: "OpenSans Bold"),
//            SizedBox(
//              width: 5,
//            ),
//          ],
//        );
//      },
//    );
//  }


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
                  child: Image.network(image),
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

//================ Logout Old UI ================
  Future _asyncConfirmDialog1(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
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
            child: Dialog(
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
                            text: AppLocalizations.of(context).translate("Are you sure want to logout").toUpperCase(),
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
                                      color: Color(0xFF23abe7),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 10.0),
                                    child: CustomWigdet.FlatButtonSimple(
                                        onPress: () {
                                          getLogout();


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
                                      color: Color(0xfffb4592),
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
                )),
          ),
        );
      },
    );
  }
  //============== Logout New UI =================

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
                              text:AppLocalizations.of(context).translate("Are you sure want to logout"),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH11,
                              fontWeight: Helper.textFontH5,
                              color: Helper.textColorBlueH1
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
                              Navigator.of(context).pop();
                              toggleLocationSharing();

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
                                    getLogout();
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

//====================== Need Help Show Dialog ============
  Future _asyncConfirmDialogHelp1(BuildContext context) async {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        child: CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: true,
                            text: AppLocalizations.of(context)
                                .translate("Need Help?"),
                            fontFamily: "OpenSans Bold",
                            fontSize: 20,
                            color: Custom_color.BlackTextColor),
                      ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // CustomWigdet.TextView(
                      //     textAlign: TextAlign.center,
                      //     overflow: true,
                      //     text: AppLocalizations.of(context)
                      //         .translate("View the explanation again"),
                      //     fontSize: 16,
                      //     color: Custom_color.BlackTextColor),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: (){
                          SessionManager.getString(Constant.Language_code)=="en"?
                          Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/en/contact/"}):
                          Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/kontakt/"});
                          },
                        child: CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: true,
                            text: AppLocalizations.of(context)
                                .translate("Contact Us"),
                            fontSize: 16,
                            color: Custom_color.BlackTextColor),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: (){
                          print("---------22222------");
                          SessionManager.getString(Constant.Language_code)=="en"?

                          Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/en/safety-tips/"})
                          :
                          Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/sicherheitstipps/"})


                          ;
                        },
                        child: CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: true,
                            text:
                                AppLocalizations.of(context).translate("See FAQ"),
                            fontSize: 16,
                            color: Custom_color.BlackTextColor),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child:  Container(
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(padding),
                        color: Custom_color.BlueLightColor,
                      ),
                      child: Image.asset(
                        "assest/images/question.png",
                        width: 40,
                        height: 40,
                      //  height: 18,
                        fit: BoxFit.contain,
                        color: Custom_color.WhiteColor,
                      )
                    ),
                  ),
                ),
              ],
            )
        );
      },
    );
  }

  //============ new show Dialog Need Help =================

  Future<void> _asyncConfirmDialogHelp(BuildContext context)async{

    String enable   = AppLocalizations.of(context).translate("enable location sharing").toUpperCase();
    String disable  = AppLocalizations.of(context).translate("disable location sharing").toUpperCase();
    String inf      = isLocationEnabled ? disable : enable;
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
                    padding: EdgeInsets.only(left: 2,top: Helper.avatarRadius
                        + Helper.padding, right: 2,bottom: Helper.padding
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
                        SizedBox(height: MQ_Height*0.07,),
                        Container(
                          alignment: Alignment.center,
                          child: CustomWigdet.TextView(
                            // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                              overflow: true,
                              text: AppLocalizations.of(context)
                                  .translate("Need Help?"),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH11,
                              fontWeight: Helper.textFontH5,
                              color: Helper.textColorBlueH1
                          ),
                        ),
                        SizedBox(height: 22,),

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
                              toggleLocationSharing();

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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: 0,
                                    right: 0,
                                    top: MQ_Height * 0.02,
                                    bottom: 2),
                                height: 50,
                                width: MQ_Width*0.30,
                                decoration: BoxDecoration(
                                  color: Color(Helper.ButtonBorderPinkColor),
                                  border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FlatButton(
                                  onPressed: ()async{
                                    Navigator.pop(context,0);

                                    SessionManager.getString(Constant.Language_code)=="en"?
                                    Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/en/contact/"}):
                                    Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/kontakt/"});

                                  },
                                  child: Text(
                                    // isLocationEnabled?'CLOSE':'OPEN',
                                    AppLocalizations.of(context)
                                        .translate("Contact Us"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH13,fontWeight:Helper.textFontH5),
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
                                width: MQ_Width*0.36,
                                decoration: BoxDecoration(
                                  color: Helper.ButtonBorderGreyColor,//Color(Helper.ButtonBorderPinkColor),
                                  border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FlatButton(
                                  onPressed: ()async{
                                    Navigator.pop(context,1);

                                    SessionManager.getString(Constant.Language_code)=="en"?

                                    Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/en/safety-tips/"})
                                        :
                                    Navigator.pushNamed(context, Constant.WebViewScreen,arguments: {"url":"https://tellmelive.com/sicherheitstipps/"});

                                  },
                                  child: Text(
                                    // isLocationEnabled?'CLOSE':'OPEN',
                                    AppLocalizations.of(context).translate("See FAQ"),
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
                        radius: 75,
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Color(0xFF21a3e1),
                          child: Image(image: AssetImage('assest/images/question.png'),),
                         // backgroundImage: AssetImage("assest/images/question.png"),

                        ),
                      )),

                ],),
            ),
          );
        });
  }
 // backgroundImage: AssetImage("assest/images/question.png"),

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
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

  Widget _CircleImage() {
    return Container(
      width: 50.0,
      height: 50.0,
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(35),
        child: Container(
            //    color: Custom_color.BlueLightColor,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Custom_color.BlueLightColor,
              border: new Border.all(
                width: 5.0,
                color: Colors.red,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage('assest/images/user.png'),
            )),
      ),
    );
  }
}

class ClippingClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 80);
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
      size.height - 80,
    );
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

//import 'package:flutter/material.dart';
//class Personal_page extends StatelessWidget {
//
//  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      key: _scaffoldKey,
//      body: Container(
//        height: 160.0,
//        child: Stack(
//          children: <Widget>[
//            Container(
//              color: Colors.red,
//              width: MediaQuery.of(context).size.width,
//              height: 100.0,
//              child: Center(
//                child: Text(
//                  "Home",
//                  style: TextStyle(color: Colors.white, fontSize: 18.0),
//                ),
//              ),
//            ),
//            Positioned(
//              top: 80.0,
//              left: 0.0,
//              right: 0.0,
//              child: Container(
//                padding: EdgeInsets.symmetric(horizontal: 20.0),
//                child: DecoratedBox(
//                  decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(1.0),
//                      border: Border.all(
//                          color: Colors.grey.withOpacity(0.5), width: 1.0),
//                      color: Colors.white),
//                  child: Row(
//                    children: [
//                      IconButton(
//                        icon: Icon(
//                          Icons.menu,
//                          color: Colors.red,
//                        ),
//                        onPressed: () {
//                          print("your menu action here");
//                          _scaffoldKey.currentState.openDrawer();
//                        },
//                      ),
//                      Expanded(
//                        child: TextField(
//                          decoration: InputDecoration(
//                            hintText: "Search",
//                          ),
//                        ),
//                      ),
//                      IconButton(
//                        icon: Icon(
//                          Icons.search,
//                          color: Colors.red,
//                        ),
//                        onPressed: () {
//                          print("your menu action here");
//                        },
//                      ),
//                      IconButton(
//                        icon: Icon(
//                          Icons.notifications,
//                          color: Colors.red,
//                        ),
//                        onPressed: () {
//                          print("your menu action here");
//                        },
//                      ),
//                    ],
//                  ),
//                ),
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//}
//
