import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:location/location.dart' as locat;
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/activity_user_holder.dart';
import 'package:miumiu/screen/holder/chat.dart';
import 'package:miumiu/screen/pages/provider/model.dart';
import 'package:miumiu/screen/holder/user.dart';
import 'package:miumiu/screen/pages/provider/filtermodel.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/fluttertoast_alert.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/showDialog_networkerror.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';
import 'dart:ui' as ue;
import 'dart:typed_data';
import 'package:image/image.dart' as Images;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as IMG;
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:widget_slider/widget_slider.dart';

import '../../utilmethod/helper.dart';
import '../../utilmethod/network_connectivity.dart';
import '../../utilmethod/show_progressintegator.dart';
import 'dart:ui' as ui;

import '../settings/edit_profile/edit_profile_new.dart';






enum Action {
  People,
  Professional,
  Activity,
}

class Home_pages extends StatefulWidget {
  //var indexHomeTab=0;
  Home_pages({Key key}):super(key:key);

  @override
  _Home_pagesState createState() => _Home_pagesState();
}

class _Home_pagesState extends State<Home_pages> with TickerProviderStateMixin {
  BitmapDescriptor customIcon;
  bool intialCalled;

  Size _screenSize;
  final locat.Location _locationService = new locat.Location();
  locat.LocationData _currentLocation;
  bool _loading, _listVisible, _visible;
  CameraPosition _currentCameraPosition;
  ProgressDialog progressDialog;
  List<bool> isSelected;
  int radioInterest;
  int radioLanguage;
  int selection;
  FilterModel _filterModel;
  bool distanceEnable=false;
  List<User> fav_list = [];
  double _slidevalue = 0;
  bool toolkit_visible = false;
  int toggle = 1;
  var routeData;

  // final allUserMarker = [];
  Set<Marker> _markers = Set();
  Set<Marker> _markers1 = Set();

  List<Chat> chat_list_match = [];
  List<Chat> chat_list_Nomatch = [];
  List<Activity_User_Holder> activity_list = [];
  Action action;
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _controllergoogleZoom;
  LatLng _currentLatLng;
  Set<Circle> circles;

  var messages;
  double minExtent      = 0.3;
  double maxExtent      = 1.0;
  double initialExtent  = 0.3;
  bool isExpanded       = false;
  int timeStamp        = DateTime.now().millisecondsSinceEpoch;
  var myMarker;
  double maxActivityWidth  = 150;
  BitmapDescriptor mapIcon;
  GlobalKey _fabKey = GlobalObjectKey("fab");
  GlobalKey _tileKey = GlobalObjectKey("tile_2");


  String tool_image = "", tool_name = "", tool_country = "", tool_user_id = "";
  static const CameraPosition _initialposition = CameraPosition(
    zoom: 15,
    bearing: 30,
    target: LatLng(51.1657, 10.4515),
    tilt: 0,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController tabBarController;

  bool isLocationEnabled = true;



  String prevChatResponse;
  String prevActResponse;
  String prevChatResponseFilter;
  String prevActResponseFilter;
  String prevProfResponse;
  String prevProfResponseFilter;
  var personalData;
  var sha  = ['','',''];
  var calledIndex = [0,0,0];
  var MQ_Height;
  var MQ_Width;
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _connectivity = NetworkConnectivity.instance;
  bool networkEnable=true;
  bool checkRefresh = false;

  var _image_file=null;
  String User_imageUrl = "";


  final controller = SliderController(
    duration: const Duration(milliseconds: 600),
  );


  _showModalBottomSheet(context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return Consumer<FilterModel>(builder: (context, myModel, child) {
          return Visibility(
            visible: myModel.getLoadingValue(),
            replacement: const Center(
              child: CircularProgressIndicator(),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 20, left: 16, right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Image(
                          image: AssetImage("assest/images/icon_filter.png"),
                          color: Color(0xFF23abe7),
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 15.0),
                        CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("FILTERS"),
                            color: const Color(0xFF23abe7),
                            fontFamily: "Kelvetica Nobis",
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.only(
                          left: 130, right: 130, top: 10),
                      child: Divider(
                        thickness: 2,
                        color: Color(0xfffa4491),
                      ),
                    ),
                    action == Action.Activity || action == Action.Professional
                        ? ListTile(
                            onTap: () {
                              _asyncConfirmInterest(context);
                            },
                            contentPadding:
                                const EdgeInsets.only(left: 0.0, right: 0.0),
                            dense: true,
                            leading: CustomWigdet.TextView(
                                text: AppLocalizations.of(context)
                                    .translate("Interest_an"),
                                fontFamily: "OpenSans Bold",
                                color: Custom_color.BlackTextColor),
                            title: CustomWigdet.TextView(
                                textAlign: TextAlign.end,
                                text: _getInterest(myModel.getInerestValue()),
                                fontFamily: "OpenSans Bold",
                                color: Custom_color.GreyLightColor),
                            trailing: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              elevation: 2,
                              child: CircleAvatar(
                                radius: 15.0,
                                backgroundColor: Colors.white60,
                                child: Icon(
                                  Icons.navigate_next,
                                  size: 20,
                                  color: Custom_color.GreyLightColor,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    action == Action.Activity || action == Action.Professional
                        ? const SizedBox(height: 6)
                        : Container(),
                    ListTile(
                      onTap: () {
                        _asyncConfirmActivity(context);
                      },
                      contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
                      dense: true,
                      leading: CustomWigdet.TextView(
                          text: AppLocalizations.of(context).translate(
                              action == Action.Activity ||
                                      action == Action.Professional
                                  ? "Activitys"
                                  : "Categroy"),
                          fontFamily: "OpenSans Bold",
                          color: Custom_color.BlackTextColor),
                      title: CustomWigdet.TextView(
                          overflow: true,
                          textAlign: TextAlign.end,
                          text: myModel.getActivityValue(),
                          fontFamily: "OpenSans Bold",
                          color: Custom_color.GreyLightColor),
                      trailing: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: CircleAvatar(
                          backgroundColor: Colors.white60,
                          radius: 15,
                          child: Icon(
                            Icons.navigate_next,
                            size: 20,
                            color: Custom_color.GreyLightColor,
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(height: 6),
                    // action == Action.Activity || action == Action.Professional
                    //     ? ListTile(
                    //         onTap: () {
                    //          _asyncConfirmLanguage(context);
                    //         },
                    //         contentPadding:
                    //             EdgeInsets.only(left: 0.0, right: 0.0),
                    //         dense: true,
                    //         leading: CustomWigdet.TextView(
                    //             text: AppLocalizations.of(context)
                    //                 .translate("Language"),
                    //             fontFamily: "OpenSans Bold",
                    //             color: Custom_color.BlackTextColor),
                    //         title: CustomWigdet.TextView(
                    //             textAlign: TextAlign.end,
                    //             text: _getLanguage(myModel.getlangugaValue()),
                    //             fontFamily: "OpenSans Bold",
                    //             color: Custom_color.GreyLightColor),
                    //         trailing: Icon(
                    //           Icons.navigate_next,
                    //           size: 20,
                    //           color: Custom_color.GreyLightColor,
                    //         ),
                    //       )
                    //     : Container(),
                    action == Action.Activity || action == Action.Professional
                        ? const SizedBox(height: 6)
                        : Container(),
//                      Row(
//                        children: <Widget>[
//                          CustomWigdet.TextView(
//                              overflow: true,
//                              fontFamily: "OpenSans Bold",
//                              text: AppLocalizations.of(context)
//                                  .translate("Private"),
//                              color: Custom_color.BlackTextColor),
//                          Spacer(),
//                          Switch(
//                            value: myModel.getPrivateValue(),
//                            onChanged: (value) async {
//                              _filterModel.updatePrivate(value);
//
////                            if (await UtilMethod.SimpleCheckInternetConnection(
////                                context, _scaffoldKey)) {
////                              _UpdatePrefrence();
////                            }
//                            },
//                            activeTrackColor: Custom_color.BlueLightColor,
//                            activeColor: Custom_color.BlueDarkColor,
//                          ),
//                        ],
//                      ),
//                      Divider(color: Custom_color.ColorDivider, height: 1),
                    action == Action.Activity || action == Action.Professional
                        ? Row(
                            children: <Widget>[
                              CustomWigdet.TextView(
                                  overflow: true,
                                  fontFamily: "OpenSans Bold",
                                  text: AppLocalizations.of(context)
                                      .translate("Looking for job"),
                                  color: Custom_color.BlackTextColor),
                              const Spacer(),
                              Switch(
                                value: myModel.getLookingForJob(),
                                onChanged: (value) async {
                                  _filterModel.updateLookingForJob(value);
//                            if (await UtilMethod.SimpleCheckInternetConnection(
//                                context, _scaffoldKey)) {
//                              _UpdatePrefrence();
//                            }
                                },
                                activeTrackColor: Color(0xfffa4491),
                                activeColor: Custom_color.WhiteColor,
                              ),
                            ],
                          )
                        : Container(),
                    action == Action.Activity || action == Action.Professional
                        ? const SizedBox(height: 6)
                        : Container(),
                    action == Action.Activity || action == Action.Professional
                        ? Row(
                            children: <Widget>[
                              CustomWigdet.TextView(
                                  overflow: true,
                                  fontFamily: "OpenSans Bold",
                                  text: AppLocalizations.of(context)
                                      .translate("Providing Job"),
                                  color: Custom_color.BlackTextColor),
                              Spacer(),
                              Switch(
                                value: myModel.getProvidingJob(),
                                onChanged: (value) async {
                                  _filterModel.updateProvidingJob(value);
//                            if (await UtilMethod.SimpleCheckInternetConnection(
//                                context, _scaffoldKey)) {
//                              _UpdatePrefrence();
//                            }
                                },
                                activeTrackColor: Color(0xfffa4491),
                                activeColor: Custom_color.WhiteColor,
                              )
                            ],
                          )
                        : Container(),
                    action == Action.Activity || action == Action.Professional
                        ? SizedBox(height: 6)
                        : Container(),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: CustomWigdet.TextView(
                              overflow: true,
                              fontFamily: "OpenSans Bold",
                              text: "${AppLocalizations.of(context).translate("Distance")} (${SessionManager.getString(Constant.Distance)})",
                              color: Custom_color.BlackTextColor),
                        ),
                        const Spacer(),

                        Switch(
                          value:myModel.getDistanceEnable(),
                          onChanged: (value) async {
                            _filterModel.updateDistanceEnable(value);


//
                          },
                          activeTrackColor: Color(0xfffa4491),
                          activeColor: Custom_color.WhiteColor,
                        )
                      ],
                    ),
                    myModel.getDistanceEnable()==true?Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              thumbColor: Custom_color.WhiteColor,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8.0,
                                  disabledThumbRadius: 8.0),
                              activeTrackColor: const Color(0xfffa4491),
                              inactiveTrackColor: Custom_color.GreyLightColor,
                              valueIndicatorColor:
                                  Custom_color.BlueLightColor,
                              trackHeight: 3),
                          child: Slider(
                            // key: ValueKey(index),
                            value: myModel.getSliderCount(),

                            min: 1,
                            max: 100,
                            divisions: 100,
                            //   activeColor: Custom_color.BlueLightColor,
                            //    inactiveColor: Custom_color.GreyLightColor,
                            label: "${myModel.getSliderCount().toInt()}",
                            onChanged: (double newValue) async {
                              _slidevalue = newValue;
                              _filterModel.updateSliderCount(_slidevalue);
                            },
                          ),
                        ),
                        Positioned(
                          bottom: -5,
                          right: 0,
                          child: Container(
                              width: _screenSize.width,
                              child: CustomWigdet.TextView(
                                  text:"${myModel.getSliderCount().toInt()} km",
                                  color: Custom_color.GreyLightColor,
                                  textAlign: TextAlign.end)),
                        ),
                      ],
                    ):Container(),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomWigdet.RoundRaisedButtonWithWrap(
                              onPress: () {
                                // OnSubmit(context);
                                final Map<String, String> jsondata =
                                    Map<String, String>();
                                int i = 0;
                                List.generate(fav_list.length, (index) {
                                  if (fav_list[index].ischeck) {
                                    // data.add(categroy_id);
                                    jsondata["categroy_id[${i++}]"] =
                                        fav_list[index]
                                            .category_id
                                            .toString();
                                  }
                                });
                                //  jsondata["language"] = radioLanguage.toString();
                                if(myModel.getDistanceEnable()==true) {
                                  jsondata["distance"] =
                                  "${(myModel.getSliderCount().toInt())}";
                                }else{
                                  jsondata["distance"] = "";
                                }

                                Navigator.pop(context, () { setState(() {}); });
                                _showProgress(context,"12");
                                if (action == Action.Activity) {
                                  jsondata["looking_for_job"] =
                                      myModel.getLookingForJob().toString();
                                  jsondata["providing_job"] =
                                      myModel.getProvidingJob().toString();
                                  jsondata["interest"] =
                                      radioInterest.toString();
                                  print("----json data-----" +
                                      jsondata.toString());
                                  _chatItemListApllyFilter(jsondata);
                                } else if (action == Action.People) {
                                  print("----json data-----" +
                                      jsondata.toString());

                                  _activityItemApplyFilterList(jsondata);
                                } else if (action == Action.Professional) {
                                  jsondata["looking_for_job"] =
                                      myModel.getLookingForJob().toString();
                                  jsondata["providing_job"] =
                                      myModel.getProvidingJob().toString();
                                  jsondata["interest"] =
                                      radioInterest.toString();
                                  print("----json data-----" +
                                      jsondata.toString());
                                  _professionItemListFilter(jsondata);
                                }
                              },
                              text: AppLocalizations.of(context)
                                  .translate("Apply")
                                  .toUpperCase(),
                              textColor: Custom_color.WhiteColor,
                              bgcolor: Custom_color.BlueLightColor,
                              fontFamily: "Kelvetica Nobis"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child:
                              CustomWigdet.RoundOutlineFlatButtonWrapContant(
                                  onPress: () {
                                    resetFilterButton();
                                  },
                                  text: AppLocalizations.of(context)
                                      .translate("Reset")
                                      .toUpperCase(),
                                  textColor: Custom_color.BlueLightColor,
                                  bordercolor: Custom_color.BlueLightColor,
                                  fontFamily: "Kelvetica Nobis"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }


  Future<List<int>> setCustomMarker() async {

    try
    {
          if(customIcon == null)
          {
              try
              {
                User_imageUrl            = SessionManager.getString(Constant.Profile_img);
                  ByteData imageData  = await NetworkAssetBundle(Uri.parse(User_imageUrl)).load(User_imageUrl);
                  List<int> bytes     = Uint8List.view(imageData.buffer);
                  var avatarImage     = Images.decodeImage(bytes);
                  if(myGender == "1")
                    imageData = await rootBundle.load('assest/images/location-pin.png');
                  else
                    imageData = await rootBundle.load('assest/images/location-pin-male.png');
                  bytes               = Uint8List.view(imageData.buffer);
                  var markerImage     = Images.decodeImage(bytes);
                  avatarImage         = Images.copyResize(avatarImage,width: markerImage.width ~/ 1.1, height: markerImage.height ~/ 1.4);
                  var radius          = 90;
                  int originX         = avatarImage.width ~/ 2, originY = avatarImage.height ~/ 2;
                  
                  for (int y = -radius; y <= radius; y++)
                    for (int x = -radius; x <= radius; x++)
                      if (x * x + y * y <= radius * radius)
                        markerImage.setPixelSafe(originX + x+8, originY + y+10,
                            avatarImage.getPixelSafe(originX + x, originY + y));
                  markerImage = Images.copyResize(markerImage,
                      width: markerImage.width ~/ 2, height: markerImage.height ~/ 2);
                  
                  var v                 = Images.encodePng(markerImage);    
                  Constant.customIcon   = BitmapDescriptor.fromBytes(v);
                
              }catch(e){
                   await getBytesFromAsset('assest/images/placeholder128.png',80).then((onValue) {
                      customIcon            = BitmapDescriptor.fromBytes(onValue);
                      Constant.customIcon   = customIcon;
                  });
              }
          }
          customIcon= Constant.customIcon;

          try
          {
              //Marker marker = _markers.firstWhere((marker) => marker.markerId.value == "-112",orElse: () => null);
            Marker marker = _markers1.firstWhere((marker) => marker.markerId.value == "-112",orElse: () => null);

              setState(() {
               // _markers.remove(marker);
                _markers1.remove(marker);
              });
          }catch(e){}
      

          myMarker = Marker(
                            infoWindow: InfoWindow(
                                title: AppLocalizations.of(context).translate('You are here')),
                            markerId: MarkerId("-112"),
                            position:  
                                LatLng(getPoint(true), getPoint(false)),
                            icon: Constant.customIcon,
                          );

          circles = Set.from([Circle(
            circleId: CircleId("-112"),
            center:LatLng(getPoint(true), getPoint(false)),
            radius: 200,
            fillColor: Colors.blue.shade100.withOpacity(0.5),
            strokeColor:  Colors.blue.shade100.withOpacity(0.1),
          )]);
    }catch(e){
      print("e...."+e.toString());
    }
    



  }



  

  Timer timer;
  String myGender;
  bool refreshListState;
  // AnimationController _controller;
  // Animation<Offset> _animation;
  Timer _timer;
   double _progress;

  @override
  void initState()  {
    // _controller = AnimationController(
    //   duration: const Duration(seconds: 3),
    //   vsync: this,)
    //   ..forward();
    // _animation = Tween<Offset>(
    //   begin: const Offset(-0.5, 0.0),
    //   end: const Offset(0.5, 0.0),
    // ).animate(CurvedAnimation(
    //   parent: _controller,
    //   curve: Curves.easeInCubic,
    // ));

    // TODO: implement initState
    super.initState();


    if (Platform.isAndroid) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }
    refreshListState = true;
    checkRefresh=false;
    timeStamp = DateTime.now().millisecondsSinceEpoch;
    _loading = false;
     _visible = false;
    action = Action.Activity;
    _listVisible = true;
    isSelected = [true, false, false];
    Future.delayed(Duration.zero,(){



    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() {
        _source = source;
        print('Home ## source =$source, \n#c _source=${_source.keys.toList()[0]}');
        if(_source.keys.toList()[0]==ConnectivityResult.wifi){
          print('Home ## ConnectivityResult.wifi _source=${_source.keys.toList()[0]}');
          networkEnable = true ;
        }
       else if(_source.keys.toList()[0]==ConnectivityResult.mobile){
          print('Home ## ConnectivityResult.mobile _source=${_source.keys.toList()[0]}');
          networkEnable = true ;
        }else{
          print('Home ## ConnectivityResult.none _source=${_source.keys.toList()[0]}');

          networkEnable = false ;
        }

      });
      }
    });

    /*Future.delayed(Duration.zero, () {
      try {
        print('Home index ## widget.indexHomeTab=${widget.indexHomeTab}');
        if (widget.indexHomeTab == 0) {
          setState(() {
            toggle = widget.indexHomeTab;
            action = Action.People;
            _listVisible = true;
            isSelected = [false, true, false];
          });
        } else {
          setState(() {
            toggle = 1;
            action = Action.Activity;
            _listVisible = true;
            isSelected = [true, false, false];
          });
        }
      } catch (e) {
        print('Home index ## catch error=${e}');
        setState(() {
          toggle = 1;
          action = Action.Activity;
          _listVisible = true;
          isSelected = [true, false, false];
        });
      }
    });*/



    //radioInterest = int.parse(SessionManager.getString(Constant.Interested));
    radioLanguage = SessionManager.getString(Constant.Language_code) == "en"
        ? Constant.English
        : SessionManager.getString(Constant.Language_code) == "ar"
            ? Constant.Arabic
            : Constant.German;
    _filterModel = Provider.of<FilterModel>(context, listen: false);
    // _filterModel.updateInterest(radioInterest);
   // getLocation();
    _currentLocation = Constant.currentLocation;
    // _updateIntialMaps();
   if(networkEnable==true) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (await UtilMethod.SimpleCheckInternetConnection(
            context, _scaffoldKey)) {
          /*ShowProgressIntegator.showSingleAnimationDialog(
            context,Indicator.values[21],
            _visible);*/
          _showProgress(context, "1");
          _updateGPSLocation(true);
        }
      });
   }
//====================== Old Timer Refresh ============
  //  timer = Timer.periodic(Duration(seconds: 15), (Timer t) => refreshList());
    //====================== New Timer Refresh ============
    isLocationEnabled   = SessionManager.getbooleanTrueDefault(Constant.LocationEnabled);

     if(networkEnable==true) {
       timer = Timer.periodic(const Duration(minutes: 10), (Timer t) => refreshList());

      //=========== Get all Data ==========
      getMyDetails();
      refreshList();
    } else{
     // FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
       setState(() {
         checkRefresh=true;

       });
       _hideProgress();
    }
    });

  // Timer(Duration(seconds: 1), () => showCoachMarkFAB());
   /* EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });*/
    //EasyLoading.showSuccess('Use in initState');

    /*Future.delayed(Duration(seconds: 20),(){

    });*/


    Future.delayed(const Duration(seconds: 40),(){
      if (mounted) {
        setState(() {
        checkRefresh=true;});
      }
      _hideProgress();
   //   FlutterToastAlert.flutterToastMSG('checkRefresh=$checkRefresh', context);
    });



  }



  //Here is example of CoachMark usage
  void showCoachMarkFAB() {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = _fabKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
        targetContext: _fabKey.currentContext,
        markRect: markRect,
        children: [
          const Center(
              child: Text("Tap on button\nto add a friend",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  )))
        ],
        duration: null,
        onClose: () {
          Timer(const Duration(seconds: 3), () => showCoachMarkTile());
        });
  }

  void showCoachMarkTile() {
    CoachMark coachMarkTile = CoachMark();
    RenderBox target = _tileKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = markRect.inflate(5.0);

    coachMarkTile.show(
        targetContext: _fabKey.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Positioned(
              top: markRect.bottom + 15.0,
              right: 5.0,
              child: const Text("Tap on friend to see details",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  )))
        ],
        duration: const Duration(seconds: 3));
  }



  @override
  void dispose() {
    customDispose();
    _hideProgress();
    try{
      _connectivity.disposeStream();
      _source.clear();
    }catch(error){
      print('_connectivity disponse error=$error');
    }

    super.dispose();
    
  }

  customDispose()
  {
      try{timer.cancel();} catch(ee){}
      refreshListState     = false;
      print("Disposing first route");
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ue.Codec codec = await ue.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ue.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ue.ImageByteFormat.png)).buffer.asUint8List();
  }

  getMyDetails() async {
      String url = WebServices.GetMyDetails +SessionManager.getString(Constant.Token);
      print('My Home Screen getMyDetails url=$url');
      https.Response response = await https.post(Uri.parse(url),
          encoding: Encoding.getByName("utf-8"),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      if(response.statusCode == 200)
      {
          print(response.body);
          var json      = jsonDecode(response.body);
          myGender      = json['gender'].toString();
      }
      else
          myGender      = "0";

      setCustomMarker();
  }

  refreshList()
  {
        // if(Constant.VISIBILITY == 0)
        // {
        //     customDispose();
        //     return;
        // }

        _currentLocation        = Constant.currentLocation;
        print("caling refresh "+refreshListState.toString());
        print(" "+refreshListState.toString());

        if(!refreshListState) {
          return;
        }
        
        
        _updateGPSLocation(false);
        if(toggle == 0) {
          _activityItemList();
        } else {
          _chatItemList();
        }

        setMyIcon();
        setState(() { });
  }


  //============ Old show Alert Location =================


  Future _asyncConfirmToggle1(BuildContext context) async {
    String enable   = AppLocalizations.of(context).translate("enable location sharing").toUpperCase();
    String disable  = AppLocalizations.of(context).translate("disable location sharing").toUpperCase();
    String inf      = isLocationEnabled ? disable : enable;
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              height: 150,

              child: Column(
                children: <Widget>[
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CustomWigdet.TextView(
                        textAlign: TextAlign.center,
                        overflow: true,
                        text: inf,
                        fontFamily: "OpenSans Bold",
                        color: Custom_color.BlackTextColor),
                  ),
                  const Spacer(),
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
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                                  color: Color(0xFF23abe7),
                                ),
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: CustomWigdet.FlatButtonSimple(
                                    onPress: () {
                                      Navigator.of(context).pop();
                                      toggleLocationSharing();


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
                                decoration: const BoxDecoration(
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
            ));
      },
    );
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
                    padding: const EdgeInsets.only(left: Helper.padding,top: Helper.avatarRadius
                        + Helper.padding, right: Helper.padding,bottom: Helper.padding
                    ),
                    margin: const EdgeInsets.only(top: Helper.avatarRadius),
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
                        const SizedBox(height: 22,),

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
                        Row(
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
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage("assest/images/map.png"),

                        ),
                      )),

                ],),
            ),
          );
        });
  }




  Future<void> _asyncRefreshDialog(BuildContext context)async{


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
                    padding: const EdgeInsets.only(left: Helper.padding,top: Helper.avatarRadius
                        + Helper.padding, right: Helper.padding,bottom: Helper.padding
                    ),
                    margin: const EdgeInsets.only(top: Helper.avatarRadius),
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
                                'Are you sure you want to refresh'),
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
                        Row(
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
                                 // Navigator.pop(context,1);
                                  Navigator.of(context,rootNavigator: true).pop();
                                  _navigRefresh();


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
                      ],
                    ),
                  ),

                  Positioned(
                      left: Helper.padding,
                      right: Helper.padding,

                      child: false?Container(
                        height: 150,
                        width: 150,
                        padding: const EdgeInsets.all(15),
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
                        child:  Container(
                          // margin: EdgeInsets.only(bottom: 15),

                          child:const CircleAvatar(
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
                        child: Container(
                            margin: const EdgeInsets.all(2),
                            height: 85,
                            width:85,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1000),

                              //shape: BoxShape.circle
                            ),
                            child: const Icon(Icons.refresh_sharp,size: 45)),
                      )),

                ],),
            ),
          );
        });
  }



  Future<void> _navigRefresh() async{
    _hideProgress();

    Navigator.of(context).pushNamedAndRemoveUntil(
        Constant.NavigationRoute,
        ModalRoute.withName(Constant.WelcomeRoute),
        arguments: {"index": 0, "index_home": 0});
  }

  //============ new show Alert Location =================



  toggleLocationSharing() async {
      
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
      
      setCustomMarker();

      setState(() {
        timeStamp   = DateTime.now().millisecondsSinceEpoch;
      });
   
      //_hideProgress();
  }


  //=========== old tab triggerReload1==========
  triggerReload1() {

    if(toggle == 0)
    {

        prevChatResponse = null;
        prevProfResponse = null;
        prevChatResponseFilter = null;
        prevProfResponseFilter = null;
        //_showProgress(context,"7");
        resetFilter();
        _activityItemList();
        _hideProgress();

    }
    else if(toggle == 1)
    {
      prevActResponse = null;
      prevProfResponse = null;
      prevActResponseFilter = null;
      prevProfResponseFilter = null;
      //_showProgress(context,"6");
      resetFilter();
      _chatItemList();
      _hideProgress();
    }
    else if(toggle == 2)
    {
      prevChatResponse = null;
      prevActResponse = null;
      prevChatResponseFilter = null;
      prevActResponseFilter = null;
      // _showProgress(context,"5");
      resetFilter();
      _chatItemList();
      _hideProgress();
    }
  }
  
//==================== New tab triggerReload==
   triggerReload() {
    //FlutterToastAlert.flutterToastMSG('triggerReload=$toggle \nactivity_list.length=${activity_list.length} \nchat_list_match.length=${chat_list_match.length}', context);
    /*EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );*/
    /*EasyLoadingIndicatorType.wave: Padding(
  padding: EdgeInsets.all(5.0),
  child: Text('wave'),
    );*/
    /*EasyLoading.show(
      status: 'Please Wait !',
      maskType: EasyLoadingMaskType.none,


    );*/


    if(networkEnable==true) {
      if (toggle == 0) {
        if (activity_list.isNotEmpty) {
          if (mounted) {
            setState(() {
              _listVisible = true;
              action = Action.People;
              for (int i = 0; i < isSelected.length; i++) {
                isSelected[i] = i == 0;
              }
              prevChatResponse = null;
              prevProfResponse = null;
              prevChatResponseFilter = null;
              prevProfResponseFilter = null;
              //_showProgress(context,"7");
              resetFilter();
              _activityItemList();
              _hideProgress();
            });
          }
        } else {
          prevChatResponse = null;
          prevProfResponse = null;
          prevChatResponseFilter = null;
          prevProfResponseFilter = null;
          //_showProgress(context,"7");
          resetFilter();
          _activityItemList();
          _hideProgress();
        }
      }
      else if (toggle == 1) {
        if (chat_list_match.isNotEmpty) {
          if (mounted) {
            setState(() {
              _listVisible = true;
              action = Action.Activity;
              for (int i = 0; i < isSelected.length; i++) {
                isSelected[i] = i == 1;
              }

              prevActResponse = null;
              prevProfResponse = null;
              prevActResponseFilter = null;
              prevProfResponseFilter = null;
              //_showProgress(context,"6");
              resetFilter();
              _chatItemList();
              _hideProgress();
            });
          }
        } else {
          prevActResponse = null;
          prevProfResponse = null;
          prevActResponseFilter = null;
          prevProfResponseFilter = null;
          //_showProgress(context,"6");
          resetFilter();
          _chatItemList();
          _hideProgress();
        }
      }
      else if (toggle == 2) {
        if (chat_list_match.isNotEmpty) {
          if (mounted) {
            setState(() {
              _listVisible = true;
              action = Action.Activity;
              for (int i = 0; i < isSelected.length; i++) {
                isSelected[i] = i == 2;
              }
              prevChatResponse = null;
              prevActResponse = null;
              prevChatResponseFilter = null;
              prevActResponseFilter = null;
              // _showProgress(context,"5");
              resetFilter();
              _chatItemList();
              _hideProgress();
            });
          }
        } else {
          prevChatResponse = null;
          prevActResponse = null;
          prevChatResponseFilter = null;
          prevActResponseFilter = null;
          // _showProgress(context,"5");
          resetFilter();
          _chatItemList();
          _hideProgress();
        }
      }
    }else{
      _hideProgress();
     // FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
      ShowDialogNetworkError.showDialogNetworkErrorMessage(context, 'NetworkError', '${AppLocalizations.of(context).translate("Please connect your internet")}', 0, "NetworkError", MQ_Width, MQ_Height);
    }
  }
//================infoAlert=====================

  showHelp1() async  {
        if(!SessionManager.getboolean("help_shown"))
        {
              Future.delayed(Duration(milliseconds: 2000),() async{
                  await SessionManager.setboolean("help_shown",true);
                  Widget okButton = TextButton(
                    child: Text(AppLocalizations.of(context).translate("Ok")),
                    onPressed: () { Navigator.pop(context); },
                  );

                  AlertDialog alert = AlertDialog(
                    title: Text(AppLocalizations.of(context).translate("Privacy Info")),
                    content: Text(AppLocalizations.of(context).translate("Privacy message")),
                    actions: [
                      okButton,
                    ],
                  );

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
            });
        }
          
  }

  //============ new show Alert Info =================

  Future<void> showHelp()async{

    if(!SessionManager.getboolean("help_shown")) {
      Future.delayed(const Duration(milliseconds: 2000),() async {
        await SessionManager.setboolean("help_shown", true);
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [

                        Container(
                          padding: const EdgeInsets.only(
                              left: Helper.padding,
                              //top: Helper.avatarRadius,//+ Helper.padding,
                              top: Helper.padding,
                              right: Helper.padding,
                              bottom: Helper.padding
                          ),
                          margin: const EdgeInsets.only(top: Helper.avatarRadius),
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
                                margin: EdgeInsets.only(left: 0,
                                    right: 0,
                                    top: MQ_Height * 0.02,
                                    bottom: 2),
                                height: 50,
                                width: MQ_Width * 0.30,
                                decoration: BoxDecoration(
                                  color: Color(Helper.ButtonBorderPinkColor),
                                  border: Border.all(width: 0.5,
                                      color: Color(Helper.ButtontextColor)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FlatButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();

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
                              child:  Container(
                                // margin: EdgeInsets.only(bottom: 15),

                                child: const CircleAvatar(
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
                              child:const CircleAvatar(
                                radius: 60,
                                backgroundImage: AssetImage("assest/images/info.png"),

                              ),
                            )):Container(),

                      ],),
                  ),
                ),
              );
            });
      });
      }
  }
  
  
  @override
  Widget build(BuildContext context) {

    try{
      FlutterAppBadger.removeBadge();
    }catch(e){
      print('Home build ** e: $e');
    }

    try{
      String string;
      print('_source : ${_source.keys.toList()[0]}');
      Future.delayed (const Duration(seconds: 2),() {
        switch (_source.keys.toList()[0]) {
          case ConnectivityResult.mobile:
            string = 'Mobile: Online';
            // FlutterToastAlert.flutterToastMSG('Mobile: Online', context);
            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('Home Mobile networkEnable: $networkEnable');
                networkEnable = true;
                checkRefresh = true;
                Constant.networkRefresh=true;


              });
            } catch (error) {
              print('Home Mobile error: $error');
              networkEnable = true;
              checkRefresh = true;
              Constant.networkRefresh=true;
            }
            /*if(Constant.networkRefresh==true) {
              try {
                Future.delayed(const Duration(seconds: 30), () {
                  print('Home Mobile networkRefresh: ${Constant.networkRefresh}');
                  Constant.networkRefresh=false;
                  _navigRefresh();
                });
              } catch (error) {
                print('Home Mobile error: $error');
              }
            }*/
            break;
          case ConnectivityResult.wifi:
            string = 'Wifi: Online';
            //  FlutterToastAlert.flutterToastMSG('WiFi: Online', context);

            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('Home Wifi networkEnable: $networkEnable');

                networkEnable = true;
                checkRefresh = true;
                Constant.networkRefresh=true;
              });
            } catch (error) {
              print('Home WiFi error: $error');
              networkEnable = true;
              checkRefresh = true;
              Constant.networkRefresh=true;
            }

           /* if(Constant.networkRefresh==true) {
              try {
                Future.delayed(const Duration(seconds: 30), () {
                  print('Home WiFi networkRefresh: ${Constant.networkRefresh}');
                  Constant.networkRefresh=false;
                  _navigRefresh();
                });
              } catch (error) {
                print('Home WiFi error: $error');
              }
            }*/

            break;
          case ConnectivityResult.none:
            string = 'Offline';
            // FlutterToastAlert.flutterToastMSG('Offline', context);
            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('Home Offline networkEnable: $networkEnable');
                networkEnable = false;
                checkRefresh = true;
                Constant.networkRefresh=false;
              });
            } catch (error) {
              print('Home Offline error: $error');
              networkEnable = false;
              checkRefresh = true;
              Constant.networkRefresh=false;
            }
            break;
          default:
        }
      });

    }catch(error){
     print('***** error=$error');
    }


    tabBarController  = TabController(length: 3, vsync: this , initialIndex: toggle);
    personalData = ModalRoute.of(context).settings.arguments;
    if(personalData!=null) {
      int _selectedTab = personalData["index"];
      print('Home ##= _selectedTab=$_selectedTab');
      if (_selectedTab != null && _selectedTab > 0) {
        _hideProgress();
      }
    }

    tabBarController.addListener(() {

        toggle    = tabBarController.index;
        if(toggle == 0)
        {
          try
          { 
            sha[1] = '';
            sha[2] = '';
          }catch(e){}
        }
        else if(toggle == 1)
        {
          try
          { 
            sha[0] = '';
            sha[2] = '';
          }catch(e){}
        }
        else if(toggle == 2)
        {
          try
          { 
            sha[0] = '';
            sha[1] = '';
          }catch(e){}
        }
        triggerReload();
    });



    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    _screenSize = MediaQuery.of(context).size;
    maxActivityWidth = MediaQuery.of(context).size.width - 120;
    print("maxActivity :: "+maxActivityWidth.toString());
    print('home build ##action ::action =$action \ntogle=$toggle' );

    //  print("--------------langauecode----------"+SessionManager.getString(Constant.Language_code));
    print(' Home ==  networkEnable=$networkEnable\n _visible=$_visible');

    return action!=Action.Activity?Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
      body:SafeArea(
          child:Stack(
            fit: StackFit.expand,
          clipBehavior: Clip.none,
        children: <Widget>[
          //_widgetHomeUi()

          true?_widgetHomeNewUi():Container(),

          networkEnable&&_visible? _widgetZoomPulseMinus():Container(),

        ],
      )) ,


      floatingActionButton:  networkEnable&&_visible?FloatingActionButton.extended(

        onPressed: () {
          Navigator.pushNamed(
              context, Constant.CreateActivity);
        },

        label:  Text(AppLocalizations.of(context).translate('Create').toUpperCase(),
          style: const TextStyle(color:Colors.white,
              fontFamily: "Kelvetica Nobis",
              fontWeight:FontWeight.w500,fontSize: 13),),
        icon: const Icon(Icons.add,color: Colors.white,size: 20,),
        backgroundColor: Color(Helper.floatButtonColor),
      ):Container(),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
     bottomSheet: Padding(padding: EdgeInsets.only(bottom: MQ_Height/1.45))

    ):Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body:SafeArea(
    child:Stack(
        children: [
          //_widgetHomeUi()

          true?_widgetHomeNewUi():Container(),
          networkEnable&&_visible? _widgetZoomPulseMinus():Container(),



          ],
      )) ,
    );
  }

  //=============== Home old UI =========
  Widget   _widgetHomeUi(){

    return Visibility(
      visible: _visible,
      replacement: Center(
        child: CircularProgressIndicator(),
      ),
      child: Container(
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
                width: _screenSize.width,
                height: _screenSize.height,
                child: GoogleMap(
                  padding: EdgeInsets.only(bottom: 200.0),

                  myLocationEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  tiltGesturesEnabled: false,
                  markers: (_markers != null) ? _markers : Set(),
                  initialCameraPosition: _initialposition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                )),
            Visibility(
              visible: toolkit_visible,
              child: Container(
                width: _screenSize.width,
                color: Custom_color.BlackTextColor.withOpacity(0.4),
              ),
            ),
            Visibility(
              visible: toolkit_visible,
              child: Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Container(
                  width: _screenSize.width,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: ListTile(
                        onTap: () {
                          if (action == Action.Activity) {
                            Navigator.pushNamed(
                                context, Constant.ChatUserDetail,
                                arguments: {
                                  "user_id": tool_user_id,
                                  "type": "1"
                                }).then((value) {
                              _showProgress(context,"11");
                              _chatItemList();
                            });
                          } else if (action == Action.Professional) {
                            Navigator.pushNamed(
                                context, Constant.ChatUserDetail,
                                arguments: {
                                  "user_id": tool_user_id,
                                  "type": "2"
                                }).then((value) {
                              _showProgress(context,"10");
                              _professionItemList();
                            });
                          }
                        },
                        contentPadding:
                        EdgeInsets.only(left: 0.0, right: 0.0),
                        dense: true,
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(tool_image,scale: 1.0),
                        ),
                        title: CustomWigdet.TextView(
                            text: tool_name,
                            color: Custom_color.BlackTextColor),
                        subtitle: CustomWigdet.TextView(
                            text: tool_country,
                            color: Custom_color.GreyLightColor),
                        trailing: InkWell(
                          onTap: () {
                            setState(() {
                              toolkit_visible = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Custom_color.BlueDarkColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
                left: 10,
                top: 10,
                child: Column(
                    children : [
                      Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color:isLocationEnabled ? Colors.green : Color.fromRGBO(255, 85, 85, 1),
                              boxShadow: [BoxShadow(
                                offset: Offset(2, 2),
                                blurRadius: 16,
                                color: Color.fromRGBO(128, 128, 128, 0.8),
                              )]
                          ),
                          child: Tooltip(message: AppLocalizations.of(context).translate('toggle location privacy'),
                              child:
                              InkWell(
                                onTap: () {
                                  _asyncConfirmToggle(context);
                                },
                                child:Padding(child:Image.asset("assest/images/pin_map.png", color: Colors.white),padding:EdgeInsets.all(6)),
                              ))
                      ),
                      Container(
                          width : 40,
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          padding : EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color:isLocationEnabled ? Color.fromRGBO(255, 255, 255, 0.5) : Color.fromRGBO(255, 255, 255, 0.3),

                          ),
                          child : Text(
                              isLocationEnabled ? AppLocalizations.of(context).translate('on').toUpperCase() : AppLocalizations.of(context).translate('off').toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isLocationEnabled ? Colors.green : Color.fromRGBO(255, 85, 85, 1),
                                fontSize: 10,
                                fontFamily: "Kelvetica Nobis",
                              )
                          ))

                    ])
            ),
            Positioned(
                left: 55,
                top: 20,
                child:Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color:Colors.black.withOpacity(0.3),
                    ),
                    padding:EdgeInsets.all(5),
                    child : Text(
                        AppLocalizations.of(context).translate('toggle location privacy'),

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: "Kelvetica Nobis",
                        )
                    )
                )
            ),

            Positioned(
              right: 10,
              top: 10,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color : Color(0xfff73c8d),
                ),
                child: RawMaterialButton(
                  onPressed: () {
                    print("Navigate to Notification screen");
                    Navigator.pushNamed(
                        context, Constant.NotificationScreen);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      new Image.asset(
                        "assest/images/notification_2.png",
                        width: 20,
                        color: Colors.white,
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
                              child: new Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: new BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  constraints: BoxConstraints(
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
                                            : "${myModel.getNotificationCounter().toString()}",
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
            ),


            NotificationListener<DraggableScrollableNotification>(
                onNotification: (DraggableScrollableNotification DSNotification){

                  if(DSNotification.extent>=minExtent){
                    setState(() {
                      isExpanded=true;
                    });
                  }
                  if(DSNotification.extent <= minExtent){
                    print("collapsed");
                    setState(() {
                      isExpanded=false;
                    });
                  }

                  print("typ :: "+DSNotification.extent.toString()+" -- "+(DSNotification.extent <= minExtent).toString()+" -- "+isExpanded.toString());
                },
                child:
                DraggableScrollableSheet(
                  minChildSize: minExtent,
                  maxChildSize: maxExtent,
                  initialChildSize: initialExtent,

                  builder: (BuildContext context,
                      ScrollController scrollController) {
//                    return Card(
//                      shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.only(
//                          topLeft: Radius.circular(50),
//                          topRight: Radius.circular(50),
//                      ),),

                    var buildContext  = context;
                    return Stack(
                        clipBehavior: Clip.none,
                        children : [




                          Container(
                            padding: EdgeInsets.only(
                                top: 0, bottom: 2, right: 0, left: 0),
                            width: _screenSize.width,

                            // height: _screenSize.height,
                            decoration: BoxDecoration(
                              color: Custom_color.WhiteColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                _getToggleActivity(),
                                true? Expanded(
                                  child: SingleChildScrollView(
                                    controller: scrollController,
                                    physics:const ClampingScrollPhysics(), //NeverScrollableScrollPhysics(),
                                    child: Container(
                                      child: action == Action.Activity
                                          ? _listVisible
                                          ?
                                      /*listViewWidget(context, chat_list_match,
                                    scrollController, action)*///============ People Tab ====
                                      _widgetListCarouselSliderNewUI(context, chat_list_match,
                                          scrollController, action)
                                          : Container(
                                        padding: EdgeInsets.only(top: 60),
                                        width: _screenSize.width,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              "assest/images/multiuser.png",
                                              width: 160,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            CustomWigdet.TextView(
                                                overflow: true,
                                                text: !UtilMethod
                                                    .isStringNullOrBlank(
                                                    messages
                                                        .toString())
                                                    ? messages.toString()
                                                    : "",
                                                color: Custom_color
                                                    .BlackTextColor)
                                          ],
                                        ),
                                      )
                                          : action == Action.People
                                          ? _listVisible
                                          ? listViewWidget2(context,
                                          activity_list, scrollController)//===== Activity tab
                                          : Container(
                                        padding:
                                        EdgeInsets.only(top: 60),
                                        width: _screenSize.width,
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              "assest/images/activity_wall.png",
                                              width: 160,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            CustomWigdet.TextView(
                                                overflow: true,
                                                text: !UtilMethod
                                                    .isStringNullOrBlank(
                                                    messages
                                                        .toString())
                                                    ? messages
                                                    .toString()
                                                    : "",
                                                color: Custom_color
                                                    .BlackTextColor)
                                          ],
                                        ),
                                      )
                                          : action == Action.Professional
                                          ? _listVisible
                                          ? listViewWidget(
                                          context,
                                          chat_list_match,
                                          scrollController,
                                          Action.Professional)
                                          : Container(
                                        padding: EdgeInsets.only(
                                            top: 60),
                                        width: _screenSize.width,
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          children: <Widget>[
                                            Image.asset(
                                              "assest/images/activity_wall.png",
                                              width: 160,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            CustomWigdet.TextView(
                                                overflow: true,
                                                text: !UtilMethod
                                                    .isStringNullOrBlank(
                                                    messages
                                                        .toString())
                                                    ? messages
                                                    .toString()
                                                    : "",
                                                color: Custom_color
                                                    .BlackTextColor)
                                          ],
                                        ),
                                      )
                                          : Center(
                                        child:
                                        CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                ):Container(
                                  child: Text('Narendra'),
                                ),
                              ],
                            ),
                          )
                          ,
                          Positioned(
                              top : -15,
                              left: 0,
                              right: 0,
                              child : Center(
                                  child:
                                  InkWell(
                                      onTap: () {
                                        print(isExpanded);
                                      },
                                      child : Container(
                                          child : Icon(Icons.arrow_upward_outlined,color:Colors.grey.shade400,size: isExpanded ? 0 : 20,),
                                          height:isExpanded ? 0 : 40,
                                          width:isExpanded ? 0 : 40,
                                          decoration : BoxDecoration(
                                            borderRadius:BorderRadius.circular(50),
                                            color:Colors.white,
                                          )
                                      )
                                  )
                              )

                          ),

                        ]
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }



  //============================= Home New UI =======

  Widget _widgetHomeNewUi(){

    return Visibility(

      visible:true, //_visible,
      replacement: const Center(
        child: CircularProgressIndicator(),

      ),
      child: Column(
        children: [
          Container(
            height: MQ_Height/13.8,
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
                        InkWell(
                          onTap: (){
                            // Navigator.of(context).pushNamed(
                            //     Constant.NavigationRoute,
                            //     arguments: {"index": 1,"index_home":0});
                            Navigator.push(context, new MaterialPageRoute(builder: (context)=>Profile_Screen()));
                          },
                          child: Container(

                            padding: EdgeInsets.all(2),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 0.5,color: Colors.grey),

                                shape: BoxShape.circle,
                                boxShadow: const [
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
                        Container(

                            child:false?Image.asset('assets/images/location-pin.png'):
                            InkWell(
                              child: false?Image(image: const AssetImage("assest/images/pin_map.png"),width: 30,height: 30,
                                  color: isLocationEnabled ? Colors.green : Color.fromRGBO(255, 85, 85, 1)
                              ):Icon(Icons.refresh_sharp,size: 26,),
                              onTap: ()async{
                                _asyncRefreshDialog(context);
                              },

                            )
                        ),
                        SizedBox(width: MQ_Width*0.03,),
                        Container(

                          child:false?Image.asset('assets/images/location-pin.png'):
                          InkWell(
                            child: false?Image(image:const AssetImage("assest/images/pin_map.png"),width: 30,height: 30,
                                color: isLocationEnabled ? Colors.green : Color.fromRGBO(255, 85, 85, 1)
                            ):SvgPicture.asset('assest/images_svg/location.svg',width: 26,height: 26,
                                color: isLocationEnabled ? Colors.green :Color(Helper.textColorPinkH1)),
                            onTap: ()async{
                              if(networkEnable==true) {
                                _asyncConfirmToggle(context);
                              }else{

                               // FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
                                ShowDialogNetworkError.showDialogNetworkErrorMessage(context, 'Network', '${AppLocalizations.of(context).translate("Please connect your internet")}', 0, 'network', MQ_Width, MQ_Height);
                              }
                            },

                          )
                        ),
                        SizedBox(width: MQ_Width*0.03,),
                        false?Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color :const Color(0xfff73c8d),
                            ),
                            child: RawMaterialButton(
                              onPressed: () {
                                print("Navigate to Notification screen");
                                Navigator.pushNamed(
                                    context, Constant.NotificationScreen);
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                   Image.asset("assest/images/notification_2.png",
                                    width: 20,
                                    color: Colors.white,
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
                                          child:  Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration:  BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                              constraints:const BoxConstraints(
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
                                                        : "${myModel.getNotificationCounter().toString()}",
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
                        ): Container(
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
                               // FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
                                ShowDialogNetworkError.showDialogNetworkErrorMessage(context, 'Network', '${AppLocalizations.of(context).translate("Please connect your internet")}', 0, 'network', MQ_Width, MQ_Height);

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
                                        child:  Container(
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
                                                      : "${myModel.getNotificationCounter().toString()}",
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
                        SizedBox(width: MQ_Width*0.03,),
                        Container(
                          child: InkWell(child: false?Image(image: AssetImage("assest/images/icon_filter.png"),width: 30,height: 30,):
                          SvgPicture.asset('assest/images_svg/filter.svg',width: 26,height: 26),
                            onTap: ()async{
                              print("------actin-------" + action.toString());
                              if(networkEnable==true) {
                                if (await UtilMethod
                                    .SimpleCheckInternetConnection(
                                    context, _scaffoldKey)) {
                                  //  if (action == Action.Activity)
                                  {
                                    if (fav_list != null && fav_list.isEmpty) {
                                      _filterModel.updateLoading(false);
                                      _showModalBottomSheet(context);
                                      _ItemList();
                                    } else {
                                      _filterModel.updateLoading(true);
                                      _showModalBottomSheet(context);
                                    }
                                  }
                                  //  else if(action == Action.People)
//                            {
//                              print("----inside1111-----------");
//                              _filterModel.updateLoading(true);
//                              _showModalBottomSheet(context);
//                            }
                                }
                              }else{
                                //FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
                                ShowDialogNetworkError.showDialogNetworkErrorMessage(context, 'Network', '${AppLocalizations.of(context).translate("Please connect your internet")}', 0, 'network', MQ_Width, MQ_Height);

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


          //========================= New  Top TabView ====================

          false?NotificationListener<DraggableScrollableNotification>(
              onNotification: (DraggableScrollableNotification DSNotification){

                if(DSNotification.extent>=minExtent){
                  setState(() {
                    isExpanded=true;
                  });
                }
                if(DSNotification.extent <= minExtent){
                  print("collapsed");
                  setState(() {
                    isExpanded=false;
                  });
                }

                print("typ :: "+DSNotification.extent.toString()+" -- "+(DSNotification.extent <= minExtent).toString()+" -- "+isExpanded.toString());
              },
              child:
              DraggableScrollableSheet(
                minChildSize: minExtent,
                maxChildSize: maxExtent,
                initialChildSize: initialExtent,

                builder: (BuildContext context,
                    ScrollController scrollController) {
//                    return Card(
//                      shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.only(
//                          topLeft: Radius.circular(50),
//                          topRight: Radius.circular(50),
//                      ),),

                  var buildContext  = context;
                  return Stack(
                      clipBehavior: Clip.none,
                      children : [




                        true?Container(
                          padding: EdgeInsets.only(
                              top: 0, bottom: 2, right: 0, left: 0),
                          width: _screenSize.width,

                          // height: _screenSize.height,
                          decoration: BoxDecoration(
                            color: Custom_color.WhiteColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              _getToggleActivity(),
                              false? Expanded(
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  physics:const ClampingScrollPhysics(), //NeverScrollableScrollPhysics(),
                                  child: Container(
                                    child: action == Action.Activity
                                        ? _listVisible
                                        ?
                                    /*listViewWidget(context, chat_list_match,
                                        scrollController, action)*///============ People Tab ====
                                    _widgetListCarouselSliderNewUI(context, chat_list_match,
                                        scrollController, action)
                                        : Container(
                                      padding: EdgeInsets.only(top: 60),
                                      width: _screenSize.width,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            "assest/images/multiuser.png",
                                            width: 160,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          CustomWigdet.TextView(
                                              overflow: true,
                                              text: !UtilMethod
                                                  .isStringNullOrBlank(
                                                  messages
                                                      .toString())
                                                  ? messages.toString()
                                                  : "",
                                              color: Custom_color
                                                  .BlackTextColor)
                                        ],
                                      ),
                                    )
                                        : action == Action.People
                                        ? _listVisible
                                        ? listViewWidget2(context,
                                        activity_list, scrollController)//===== Activity tab
                                        : Container(
                                      padding:
                                      EdgeInsets.only(top: 60),
                                      width: _screenSize.width,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            "assest/images/activity_wall.png",
                                            width: 160,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          CustomWigdet.TextView(
                                              overflow: true,
                                              text: !UtilMethod
                                                  .isStringNullOrBlank(
                                                  messages
                                                      .toString())
                                                  ? messages
                                                  .toString()
                                                  : "",
                                              color: Custom_color
                                                  .BlackTextColor)
                                        ],
                                      ),
                                    )
                                        : action == Action.Professional
                                        ? _listVisible
                                        ? listViewWidget(
                                        context,
                                        chat_list_match,
                                        scrollController,
                                        Action.Professional)
                                        : Container(
                                      padding: EdgeInsets.only(
                                          top: 60),
                                      width: _screenSize.width,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          Image.asset(
                                            "assest/images/activity_wall.png",
                                            width: 160,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          CustomWigdet.TextView(
                                              overflow: true,
                                              text: !UtilMethod
                                                  .isStringNullOrBlank(
                                                  messages
                                                      .toString())
                                                  ? messages
                                                  .toString()
                                                  : "",
                                              color: Custom_color
                                                  .BlackTextColor)
                                        ],
                                      ),
                                    )
                                        : Center(
                                      child:
                                      CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                              ):Container(
                                child: Text('Narendra'),
                              ),
                            ],
                          ),
                        ):Container()
                        ,
                       false? Positioned(
                            top : -15,
                            left: 0,
                            right: 0,
                            child : Center(
                                child:
                                InkWell(
                                    onTap: () {
                                      print(isExpanded);
                                    },
                                    child : Container(
                                        child : Icon(Icons.arrow_upward_outlined,color:Colors.grey.shade400,size: isExpanded ? 0 : 20,),
                                        height:isExpanded ? 0 : 40,
                                        width:isExpanded ? 0 : 40,
                                        decoration : BoxDecoration(
                                          borderRadius:BorderRadius.circular(50),
                                          color:Colors.white,
                                        )
                                    )
                                )
                            )

                        ):Container(),

                      ]
                  );
                },
              )):Container(),
          _widgetTabBarToggleActivity(),

          networkEnable&&_visible?Stack(
            //clipBehavior: Clip.none,
            children: <Widget>[
             true? SizedBox(
               // margin: EdgeInsets.only(top: 5),
                  width: _screenSize.width,

                  height:(MQ_Height/100)*76,//_screenSize.height,
                  child: GoogleMap(
                    //padding: EdgeInsets.only(bottom: 200.0),

                    myLocationEnabled: false,
                    compassEnabled: false,
                     mapToolbarEnabled: false,
                    tiltGesturesEnabled: false,
                    //minMaxZoomPreference: MinMaxZoomPreference(6, 19),
                    initialCameraPosition: _initialposition,
                    /*onMapCreated: (GoogleMapController controller) {
                   _controller.complete(controller);
                   _controllergoogleZoom=controller;

                     },*/
                    onMapCreated: (GoogleMapController controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                        //_controller = controller;
                        _controllergoogleZoom=controller;
                        var zoom=controller.getZoomLevel();

                      }
                    },
                    markers: (_markers1 != null) ? _markers1 : Set(),

                  //  scrollGesturesEnabled: false,
                    padding: EdgeInsets.only(bottom: MQ_Height*0.50),

                    zoomControlsEnabled: false,
                    circles: (circles != null) ? circles : Set(),
                  )):Container(),
              Visibility(
                visible: toolkit_visible,
                child: Container(
                  width: _screenSize.width,
                  color: Custom_color.BlackTextColor.withOpacity(0.4),
                ),
              ),
              Visibility(
                visible: toolkit_visible,
                child: Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    width: _screenSize.width,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: ListTile(
                          onTap: () {
                            if (action == Action.Activity) {
                              Navigator.pushNamed(
                                  context, Constant.ChatUserDetail,
                                  arguments: {
                                    "user_id": tool_user_id,
                                    "type": "1"
                                  }).then((value) {
                                _showProgress(context,"11");
                                _chatItemList();
                              });
                            } else if (action == Action.Professional) {

                              Navigator.pushNamed(
                                  context, Constant.ChatUserDetail,
                                  arguments: {
                                    "user_id": tool_user_id,
                                    "type": "2"
                                  }).then((value) {
                                _showProgress(context,"10");
                                _professionItemList();
                              });
                            }
                          },
                          contentPadding:
                          EdgeInsets.only(left: 0.0, right: 0.0),
                          dense: true,
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(tool_image,
                                scale: 1.0),
                          ),
                          title: CustomWigdet.TextView(
                              text: tool_name,
                              color: Custom_color.BlackTextColor),
                          subtitle: CustomWigdet.TextView(
                              text: tool_country,
                              color: Custom_color.GreyLightColor),
                          trailing: InkWell(
                            onTap: () {
                              setState(() {
                                toolkit_visible = false;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: Custom_color.BlueDarkColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),



              false?Positioned(
                  left: 10,
                  top: 10,
                  child: Column(
                      children : [
                        Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color:isLocationEnabled ? Colors.green : Color.fromRGBO(255, 85, 85, 1),
                                boxShadow: [BoxShadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 16,
                                  color: Color.fromRGBO(128, 128, 128, 0.8),
                                )]
                            ),
                            child: Tooltip(message: AppLocalizations.of(context).translate('toggle location privacy'),
                                child:
                                InkWell(
                                  onTap: () {
                                    _asyncConfirmToggle(context);
                                  },
                                  child:Padding(child:Image.asset("assest/images/pin_map.png", color: Colors.white),padding:EdgeInsets.all(6)),
                                ))
                        ),
                        Container(
                            width : 40,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            padding : EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color:isLocationEnabled ? Color.fromRGBO(255, 255, 255, 0.5) : Color.fromRGBO(255, 255, 255, 0.3),

                            ),
                            child : Text(
                                isLocationEnabled ? AppLocalizations.of(context).translate('on').toUpperCase() : AppLocalizations.of(context).translate('off').toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isLocationEnabled ? Colors.green : Color.fromRGBO(255, 85, 85, 1),
                                  fontSize: 10,
                                  fontFamily: "Kelvetica Nobis",
                                )
                            ))

                      ])
              ):Container(),
              Container(
                alignment: Alignment.bottomCenter,
                margin: chat_list_match.length==0&&action==Action.Activity?EdgeInsets.only(top:MQ_Height*0.40):EdgeInsets.only(top: action!=Action.Activity?MQ_Height*0.40:MQ_Height*0.46),
                padding: EdgeInsets.only(
                    top: 0, bottom: 2, right: 0, left: 0),
                width: _screenSize.width,

                 height:action!=Action.Activity?MQ_Height/3:MQ_Height/4,   //290:200,//_screenSize.height,
                decoration: BoxDecoration(
                  color:Colors.transparent, //Custom_color.WhiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                  //  _getToggleActivity(),
                    true? Expanded(
                      child: SingleChildScrollView(
                        controller: ScrollController(keepScrollOffset: false),//scrollController,
                        physics:const ClampingScrollPhysics(), //NeverScrollableScrollPhysics(),
                        child: Container(
                          child:action == Action.Activity
                              ? _listVisible
                              ?
                          /*listViewWidget(context, chat_list_match,
                                      scrollController, action)*///============ People Tab ====
                          _widgetListCarouselSliderNewUI(context, chat_list_match,
                              ScrollController(keepScrollOffset: false), action)
                              : Container(
                            padding: EdgeInsets.only(top: 20,bottom:20),
                            margin: EdgeInsets.only(left: 20,right: 20,top:0),
                            width: _screenSize.width,
                            //height: MQ_Height*0.30,
                            alignment: Alignment.topCenter ,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:BorderRadius.circular(10)
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assest/images/multiuser.png",
                                  width: MQ_Width/3.0,
                                 // height: 110,

                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text: !UtilMethod
                                        .isStringNullOrBlank(
                                        messages
                                            .toString())
                                        ? messages.toString()
                                        : "",
                                    color: Custom_color
                                        .BlackTextColor)
                              ],
                            ),
                          )
                              : action == Action.People
                              ? _listVisible
                              ? /*listViewWidget2(context,
                              activity_list, ScrollController(keepScrollOffset: false))  */  //===== Activity tab
                          _widgetListCarouselSliderNewUI2(context,
                              activity_list, ScrollController(keepScrollOffset: false))
                              : Container(
                            padding: EdgeInsets.only(top: 20,bottom:20),
                            margin: EdgeInsets.only(left: 20,right: 20,top:0),
                            width: _screenSize.width,
                            alignment: Alignment.topCenter ,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:BorderRadius.circular(10)
                            ),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assest/images/activity_wall.png",
                                  width: MQ_Width/3.0,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text: !UtilMethod
                                        .isStringNullOrBlank(
                                        messages
                                            .toString())
                                        ? messages
                                        .toString()
                                        : "",
                                    color: Custom_color
                                        .BlackTextColor)
                              ],
                            ),
                          )
                              : action == Action.Professional
                              ? _listVisible
                              ? listViewWidget(
                              context,
                              chat_list_match,
                              ScrollController(keepScrollOffset: false),
                              Action.Professional)
                              : Container(
                            padding: EdgeInsets.only(top: 20),
                            width: _screenSize.width,
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              children: <Widget>[
                                Image.asset(
                                  "assest/images/activity_wall.png",
                                  width: 160,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text: !UtilMethod
                                        .isStringNullOrBlank(
                                        messages
                                            .toString())
                                        ? messages
                                        .toString()
                                        : "",
                                    color: Custom_color
                                        .BlackTextColor)
                              ],
                            ),
                          )
                              : Center(
                            child:Container()
                           // CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ):Container(
                      child: Text('Narendra'),
                    ),
                  ],
                ),
              ),
              //========== location Privacy =====
              false?Positioned(
                  left: 55,
                  top: 20,
                  child:Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color:Colors.black.withOpacity(0.3),
                      ),
                      padding:EdgeInsets.all(5),
                      child : Text(
                          AppLocalizations.of(context).translate('toggle location privacy'),

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: "Kelvetica Nobis",
                          )
                      )
                  )
              ):Container(),
//===================  Notification Show Icon =========
             false? Positioned(
                right: 10,
                top: 10,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color : Color(0xfff73c8d),
                  ),
                  child: RawMaterialButton(
                    onPressed: () {
                      print("Navigate to Notification screen");
                      Navigator.pushNamed(
                          context, Constant.NotificationScreen);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        new Image.asset(
                          "assest/images/notification_2.png",
                          width: 20,
                          color: Colors.white,
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
                                child: new Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: new BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    constraints: BoxConstraints(
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
                                              : "${myModel.getNotificationCounter().toString()}",
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
              ):Container(),

              //========================= Old Bottom to Top TabView ====================
              false?NotificationListener<DraggableScrollableNotification>(
                  onNotification: (DraggableScrollableNotification DSNotification){

                    if(DSNotification.extent>=minExtent){
                      setState(() {
                        isExpanded=true;
                      });
                    }
                    if(DSNotification.extent <= minExtent){
                      print("collapsed");
                      setState(() {
                        isExpanded=false;
                      });
                    }

                    print("typ :: "+DSNotification.extent.toString()+" -- "+(DSNotification.extent <= minExtent).toString()+" -- "+isExpanded.toString());
                  },
                  child:
                  DraggableScrollableSheet(
                    minChildSize: minExtent,
                    maxChildSize: maxExtent,
                    initialChildSize: initialExtent,

                    builder: (BuildContext context,
                        ScrollController scrollController) {
//                    return Card(
//                      shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.only(
//                          topLeft: Radius.circular(50),
//                          topRight: Radius.circular(50),
//                      ),),

                      var buildContext  = context;
                      return Stack(
                          clipBehavior: Clip.none,
                          children : [




                            true?Container(
                              padding: EdgeInsets.only(
                                  top: 0, bottom: 2, right: 0, left: 0),
                              width: _screenSize.width,

                              // height: _screenSize.height,
                              decoration: BoxDecoration(
                                color: Custom_color.WhiteColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  _getToggleActivity(),
                                  true? Expanded(
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      physics:const ClampingScrollPhysics(), //NeverScrollableScrollPhysics(),
                                      child: Container(
                                        child: action == Action.Activity
                                            ? _listVisible
                                            ?
                                        /*listViewWidget(context, chat_list_match,
                                      scrollController, action)*///============ People Tab ====
                                        _widgetListCarouselSliderNewUI(context, chat_list_match,
                                            scrollController, action)
                                            : Container(
                                          padding: EdgeInsets.only(top: 60),
                                          width: _screenSize.width,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: <Widget>[
                                              Image.asset(
                                                "assest/images/multiuser.png",
                                                width: 160,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              CustomWigdet.TextView(
                                                  overflow: true,
                                                  text: !UtilMethod
                                                      .isStringNullOrBlank(
                                                      messages
                                                          .toString())
                                                      ? messages.toString()
                                                      : "",
                                                  color: Custom_color
                                                      .BlackTextColor)
                                            ],
                                          ),
                                        )
                                            : action == Action.People
                                            ? _listVisible
                                            ? listViewWidget2(context,
                                            activity_list, scrollController)//===== Activity tab
                                            : Container(
                                          padding:
                                          EdgeInsets.only(top: 60),
                                          width: _screenSize.width,
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: <Widget>[
                                              Image.asset(
                                                "assest/images/activity_wall.png",
                                                width: 160,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              CustomWigdet.TextView(
                                                  overflow: true,
                                                  text: !UtilMethod
                                                      .isStringNullOrBlank(
                                                      messages
                                                          .toString())
                                                      ? messages
                                                      .toString()
                                                      : "",
                                                  color: Custom_color
                                                      .BlackTextColor)
                                            ],
                                          ),
                                        )
                                            : action == Action.Professional
                                            ? _listVisible
                                            ? listViewWidget(
                                            context,
                                            chat_list_match,
                                            scrollController,
                                            Action.Professional)
                                            : Container(
                                          padding: EdgeInsets.only(
                                              top: 60),
                                          width: _screenSize.width,
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              Image.asset(
                                                "assest/images/activity_wall.png",
                                                width: 160,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              CustomWigdet.TextView(
                                                  overflow: true,
                                                  text: !UtilMethod
                                                      .isStringNullOrBlank(
                                                      messages
                                                          .toString())
                                                      ? messages
                                                      .toString()
                                                      : "",
                                                  color: Custom_color
                                                      .BlackTextColor)
                                            ],
                                          ),
                                        )
                                            : Center(
                                          child:
                                          CircularProgressIndicator(),
                                        ),
                                      ),
                                    ),
                                  ):Container(
                                    child: Text('Narendra'),
                                  ),
                                ],
                              ),
                            ):Container()
                            ,
                            Positioned(
                                top : -15,
                                left: 0,
                                right: 0,
                                child : Center(
                                    child:
                                    InkWell(
                                        onTap: () {
                                          print(isExpanded);
                                        },
                                        child : Container(
                                            child : Icon(Icons.arrow_upward_outlined,color:Colors.grey.shade400,size: isExpanded ? 0 : 20,),
                                            height:isExpanded ? 0 : 40,
                                            width:isExpanded ? 0 : 40,
                                            decoration : BoxDecoration(
                                              borderRadius:BorderRadius.circular(50),
                                              color:Colors.white,
                                            )
                                        )
                                    )
                                )

                            ),

                          ]
                      );
                    },
                  )):Container(),
            ],
          ):networkEnable==true?_widgetLoaderRefresh():_widgetNetworkConnectivity(),
        ],
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
                        arguments: {"index": 0, "index_home": 0});
                  }
                });
              }else{
               // FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
                ShowDialogNetworkError.showDialogNetworkErrorMessage(context, 'Network', '${AppLocalizations.of(context).translate("Please connect your internet")}', 0, 'network', MQ_Width, MQ_Height);
              }
            },
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),

                child: Text(AppLocalizations.of(context)
                    .translate("Try again"),style:const TextStyle(fontWeight: FontWeight.w500,fontSize: 15) ,))
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
                          arguments: {"index": 0, "index_home": 0});
                    }
                  });
                }else{
                //  FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
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


  Widget  _widgetZoomPulseMinus(){
    return  Positioned(
      top: MQ_Height/6,
      left:MQ_Width/1.2,
      child: Card(
        elevation: 2,
        key: _fabKey,
        child: Container(
          alignment: Alignment.topRight,
          color: Color(0xFFFAFAFA),
         // width: 40,
          height: MQ_Height/8.0,//100,
          child: Column(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    var currentZoomLevel = await  _controllergoogleZoom.getZoomLevel();

                    currentZoomLevel = currentZoomLevel + 2;
                    _controllergoogleZoom.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _currentLatLng,//locationCoords,
                          zoom: currentZoomLevel,
                        ),
                      ),
                    );
                  }),
              SizedBox(height: 2),
              IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () async {
                    var currentZoomLevel = await _controllergoogleZoom.getZoomLevel();
                    currentZoomLevel = currentZoomLevel - 2;
                    if (currentZoomLevel < 0) currentZoomLevel = 0;
                    _controllergoogleZoom.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target:_currentLatLng, //locationCoords,
                          zoom: currentZoomLevel,
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );

  }
/*
  Widget getlistitem() {
    return FutureBuilder<List<Chat>>(
      future: _chatItemList(),
      builder: (BuildContext context, snapshot) {
        print(snapshot.hasData);
        print(snapshot.connectionState);
        print(snapshot.hasError);
        print(snapshot.data);

        return snapshot.hasData != null
            ? listViewWidget(
                context,



                snapshot.data,
              )
            : Expanded(child: Center(child: CircularProgressIndicator()));
      },
    );
  }



  Widget getlistitem2() {
    return FutureBuilder<List<Activity_User_Holder>>(
      future: _activityItemList(),
      builder: (BuildContext context, snapshot) {
        print(snapshot.hasData);
        print(snapshot.connectionState);
        print(snapshot.hasError);
        print(snapshot.data);

        return snapshot.hasData != null
            ? listViewWidget2(
                context,
                snapshot.data,
              )
            : Expanded(child: Center(child: CircularProgressIndicator()));
      },
    );
  }

 */
//   =================== People List  Item user Old UI ==========
  listViewWidget(BuildContext context, List<Chat> chatList,
      ScrollController scrollController, Action action) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.separated(
        controller: scrollController,
       // physics: NeverScrollableScrollPhysics(),
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          final nDataList = chatList[i];
          return getlistchatItem(i, nDataList);
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 8,
          );
        },
        itemCount: chatList == null ? 0 : chatList.length,
      ),
    );
  }


  //=============== Slider People List Item User New UI ========

  Widget _widgetListCarouselSliderNewUI(BuildContext context, List<Chat> chatList,
      ScrollController scrollController, Action action){

    return Center(
      child: WidgetSlider(
        //fixedSize: 300,
        controller: controller,
        itemCount: chatList.length,
        onMove: onMovePeople,
        itemBuilder: (context, index, activeIndex) {



          return CupertinoButton(
            onPressed: () async {

              await controller.moveTo?.call(index);
           /* if (action == Action.Activity) {
              Navigator.pushNamed(context, Constant.ChatUserDetail,
                  arguments: {"user_id": chatList[index].user_id, "type": "1"});
              //     .then((value) {
              //   _showProgress(context);
              //   _chatItemList();
              // });
            } else if (action == Action.Professional) {
              Navigator.pushNamed(context, Constant.ChatUserDetail,
                  arguments: {"user_id": chatList[index].user_id, "type": "2"});
              //     .then((value) {
              //   _showProgress(context);
              //   _professionItemList();
              // });
            }*/
              print('_widgetListCarouselSliderNewUI chatList[index].profile_img=${chatList[index].profile_img}'
                  '\nchatList[index].allownavigation=${chatList[index].allownavigation}');
             //if(chatList[index].allownavigation==1){
               showAlartPeopleDetails(chatList[index]);
             // }
            },


            child:Container(
              height:MQ_Height*0.70,
              width: MQ_Width*0.70,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,

                    colors: [
                      // Color(0XFF8134AF),
                      // Color(0XFFDD2A7B),
                      // Color(0XFFFEDA77),
                      // Color(0XFFF58529),
                      //Colors.blue.withOpacity(0.5),
                      //Colors.blue.withOpacity(0.5),
                      chatList[index].gender.toLowerCase()=="female"? Color(0xfffb4592).withOpacity(0.5):Colors.blue.withOpacity(0.5),
                      chatList[index].gender.toLowerCase()=="female"? Color(0xfffb4592).withOpacity(0.5):Colors.blue.withOpacity(0.5),
                    ],
                  ),
                  shape: BoxShape.circle
              ),
              child: Container(
               // padding: EdgeInsets.all(5),
               // height: 150,
                //width: 150,
                margin: const EdgeInsets.all(10),
                /*decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(chatList[index].profile_img,scale: 1.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade50,
                      offset: const Offset(0, 8),
                      spreadRadius: 30,
                      blurRadius: 30,
                    ),
                    BoxShadow(
                      color: Colors.grey.shade100,
                      offset: const Offset(0, 8),
                      spreadRadius: 30,
                      blurRadius: 30,
                    ),
                  ],
                ),*/
                child:
                Container(
                  height: 200,
                  width: 200,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(

                          child: Hero(
                            tag: index,
                            child: ClipOval(
                                child:chatList[index].profile_img!=null?Image.network(chatList[index].profile_img, fit: BoxFit.cover, width: 1000):Image.asset('assets/images/user2.png', fit: BoxFit.cover, width: 1000)
                            ),
                          )
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child:   Container(
                         // margin: EdgeInsets.all(2),
                         // color: Colors.purple,
                          height: 45,
                          width: 135,
                          //margin: EdgeInsets.only(left: 5,right: 5,bottom: 1),
                          decoration: BoxDecoration(
                             // border: Border.all(color: Colors.transparent,width: 2),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(100),
                                bottomRight: Radius.circular(100)),
                            color:chatList[index].gender.toLowerCase()=="female"? Color(0xfffb4592).withOpacity(0.4):Colors.blue.withOpacity(0.3),
                            //shape: BoxShape.rectangle,
                           // color: Colors.purple,

                          ),
                          child: Column(
                            children: [
                              Container(
                                //  width: MQ_Width,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(2),
                                child: CustomWigdet.TextView(
                                    textAlign: TextAlign.center,
                                    text: '${chatList[index].name}',
                                    color:Custom_color.WhiteColor,
                                    fontFamily: "OpenSans",
                                    fontWeight: Helper.textFontH5,
                                    fontSize: Helper.textSizeH15),
                              ),
                          chatList[index].hide_age.toString().trim()!='1'? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    //width: MQ_Width,
                                    padding: EdgeInsets.all(2),
                                    child: _widgetDOB(chatList[index]),
                                  ),
                                  Container(
                                    // margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                     width:18,
                                     height: 18,
                                    /*decoration: BoxDecoration(
                //  color:Colors.blue,
                //borderRadius: BorderRadius.circular(30)

              ),*/
                                    // padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                    // child: CustomWigdet.TextView(
                                    //     text:
                                    //         gender != null ? _getGender(gender) : gender,
                                    //     textAlign: TextAlign.center,
                                    //     overflow: true,
                                    //     color: Custom_color.GreyLightColor),
                                      child:
                                     false? ClipOval(
                                        child: Material(
                                          color://gender!=null && gender==1?
                                          chatList[index].gender!=null&&chatList[index].gender==1?Color(0xfffb4592):Colors.blue.shade700,//Helper.inIconCircleBlueColor1, // Button color
                                          child: InkWell(
                                            splashColor: Helper.inIconCircleBlueColor1, // Splash color
                                            onTap: () {},
                                            child: SizedBox(width: 18, height: 18,
                                              child:Image.asset(
                                                chatList[index].gender!=null &&chatList[index].gender==1?
                                                "assest/images/female1.png":"assest/images/male.png",
                                                width: 10,height: 10,color: Color(Helper.inIconWhiteColorH1),),
                                            ),
                                          ),
                                        ),
                                      ):
                                     CircleAvatar(
                                       // backgroundColor: Colors.transparent,
                                       backgroundColor:chatList[index].gender!=null &&chatList[index].gender.toLowerCase()=="female"? Color(0xfffb4592):Colors.blue.shade700,
                                       radius: Helper.avatarRadius,
                                       child: ClipRRect(
                                         borderRadius: BorderRadius.all(Radius.circular(Helper.avatarRadius)),
                                         child: Image.asset(chatList[index].gender!=null && chatList[index].gender.toLowerCase()=="female"? "assest/images/female1.png":"assest/images/male.png",
                                           width: 14,height: 14,color: Color(Helper.inIconWhiteColorH1),),

                                       ),
                                     ),
                                  ),
                                ],
                              ):Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      )
    );
  }

  Widget _widgetDOB(Chat chatList){

        var DOB=chatList.dob;
        print('_widgetDOB DOB=$DOB');
        int DOBAge=0;
        if(DOB!=null) {
          try {
            var dateFormat = new DateFormat("dd-MM-yyyy").parse(DOB);
            var currentDate = DateTime.now();
            DOBAge = dateFormat.year - currentDate.year;
            print('_widgetDOB DOB_age$DOBAge');
          }catch(error){
            print('DOB_age erro$error');
            DOBAge=0;
          }

        }

    return DOBAge!=0?CustomWigdet.TextView(
        textAlign: TextAlign.center,
        text: '${DOBAge.toString().substring(1,DOBAge.toString().length)}',
        color: Custom_color.WhiteColor,
        fontFamily: "OpenSans",
        fontWeight: Helper.textFontH5,
        fontSize: Helper.textSizeH15):
    CustomWigdet.TextView(
        textAlign: TextAlign.center,
        text: '0',
        color: Custom_color.WhiteColor,
        fontFamily: "OpenSans",
        fontWeight: Helper.textFontH5,
        fontSize: Helper.textSizeH15);
  }

  Future<void> onMovePeople(int i)async{
   // FlutterToastAlert.flutterToastMSG('MSG onMove=$i', context);


   if(chat_list_match.length!=0) {
     if(_markers.length!=0){
       _markers.clear();
       //_markers1.clear();
     }
     print('onMove ## postion=${i}');
     print('onMove ## chat_list_match[i].profile_img=${chat_list_match[i].profile_img}');
     print('onMove ## chat_list_match[i].profile_imgmap=${chat_list_match[i].profile_imgmap}');
     print('onMove ## chat_list_match[i].user_id=${chat_list_match[i].user_id}');
     print('onMove ## chat_list_match[i].latitude=${chat_list_match[i].latitude}');
     print('onMove ## chat_list_match[i].longitude=${chat_list_match[i].longitude}');

     await getBytesFromAsset('assest/images/user2.png', 100).then((onValue) {
       mapIcon =BitmapDescriptor.fromBytes(onValue);
     });


     /*Uint8List markerIcon = await getMarkerIconActivity(
         chat_list_match[i].profile_imgmap, Size(150, 150));
     _markers.add(Marker(
         markerId: MarkerId(chat_list_match[i].user_id.toString() +
             Random().nextInt(1000).toString()),
         position: LatLng(double.parse(chat_list_match[i].latitude),
             double.parse(chat_list_match[i].longitude)),
         icon: BitmapDescriptor.fromBytes(markerIcon)));*/
     print('onMove ## chat_list_match[i].latitude=${chat_list_match[i].latitude}\n chat_list_match[i].latitude=${chat_list_match[i].longitude}\n chat_list_match[i]=${chat_list_match[i].user_id}\n i=$i');
     if(chat_list_match[i].allownavigation==1) {
       if (action == Action.Activity) {
         print('onMove ## people action=$action');
        // _updateIntialMaps(0, i);
         setMyIcon();
         _moveCamera(chat_list_match[i].latitude,chat_list_match[i].longitude,16);

       /* try {
          if (i > 0 && i != 0) {
            print('onMove ## people abc i =$i');
            String pImage = chat_list_match[i - 1].profile_imgmap != null
                ? chat_list_match[i - 1].profile_imgmap
                : chat_list_match[i - 1].profile_img;
            var a = await getMarkerIconToMove(
                pImage, Size(150, 150), resize[toggle]);
            var icon = BitmapDescriptor.fromBytes(a);
            var UserMarker = Marker(
              markerId: MarkerId(chat_list_match[i - 1].user_id +
                  Random().nextInt(1000).toString()),
              position: LatLng(double.parse(chat_list_match[i - 1].latitude),
                  double.parse(chat_list_match[i - 1].longitude)),
              anchor: const Offset(0.5, 0.5),

              icon: icon,
            );

            _markers1.remove(UserMarker);
            //_markers1.add(UserMarker);
          }
        }catch(error){
          print('error ###0000 =$error');
        }



         String pImage =chat_list_match[i].profile_imgmap != null ? chat_list_match[i].profile_imgmap : chat_list_match[i].profile_img;
         var a   = await getMarkerIconToMove(pImage, Size(300, 300),resize[toggle]);
        var icon =null;   //= BitmapDescriptor.fromBytes(a);

         try
         {
          String  User_MapMakr            = chat_list_match[i].profile_img;
           ByteData imageData  = await NetworkAssetBundle(Uri.parse(User_MapMakr)).load(User_MapMakr);
           List<int> bytes     = Uint8List.view(imageData.buffer);
           var avatarImage     = Images.decodeImage(bytes);
           if(chat_list_match[i].gender.toLowerCase()=="female")
             imageData = await rootBundle.load('assest/images/location-pin.png');
           else
             imageData = await rootBundle.load('assest/images/location-pin-male.png');
           bytes               = Uint8List.view(imageData.buffer);
           var markerImage     = Images.decodeImage(bytes);
           avatarImage         = Images.copyResize(avatarImage,width: markerImage.width ~/ 1.1, height: markerImage.height ~/ 1.4);
           var radius          = 90;
           int originX         = avatarImage.width ~/ 2, originY = avatarImage.height ~/ 2;

           for (int y = -radius; y <= radius; y++)
             for (int x = -radius; x <= radius; x++)
               if (x * x + y * y <= radius * radius)
                 markerImage.setPixelSafe(originX + x+8, originY + y+10,
                     avatarImage.getPixelSafe(originX + x, originY + y));
           markerImage = Images.copyResize(markerImage,
               width: markerImage.width ~/ 2, height: markerImage.height ~/ 2);

           var v                 = Images.encodePng(markerImage);
           icon   = BitmapDescriptor.fromBytes(v);

         }catch(e){
           // await getBytesFromAsset('assest/images/placeholder128.png',80).then((onValue) {
           //   customIcon            = BitmapDescriptor.fromBytes(onValue);
           //   Constant.customIcon   = customIcon;
           // });
         }
       var UserMarker =  Marker(
           markerId: MarkerId(chat_list_match[i].user_id+Random().nextInt(1000).toString()),
           position: LatLng(double.parse(chat_list_match[i].latitude), double.parse(chat_list_match[i].longitude)),
            anchor: const Offset(0.5, 0.5),
         infoWindow: InfoWindow(
             title: AppLocalizations.of(context).translate('You are here')),

           icon: icon ,


         );


         _markers1.remove(UserMarker);
         _markers1.add(UserMarker);*/

         // var currentZoomLevel =await _controllergoogleZoom.getZoomLevel();
         // print('onMove ## Professional currentZoomLevel=$currentZoomLevel');
         // double equatorLength = 40075004; // in meters
         // double widthInPixels = MQ_Width;
         // double metersPerPixel = equatorLength / 256;
         // int zoomLevel = 1;
         // while ((metersPerPixel * widthInPixels) > 2000) {
         //   metersPerPixel /= 2;
         //   ++zoomLevel;
         // }
       //  print( "zoom level = $zoomLevel");

           circles = Set.from([Circle(
            circleId: CircleId(chat_list_match[i].user_id+Random().nextInt(1000).toString()),
            center: LatLng(double.parse(chat_list_match[i].latitude), double.parse(chat_list_match[i].longitude)),
             radius:70,//double.parse('${70}'),//currentZoomLevel.toInt()<=16?double.parse('${90-currentZoomLevel.toInt()/100}'):double.parse('${80+currentZoomLevel.toInt()}'),
             strokeWidth: 1,
             zIndex: 1,
             fillColor: chat_list_match[i].gender!=null &&chat_list_match[i].gender.toLowerCase()=="female"? Color(0xfffb4592).withOpacity(0.5):Colors.blue.shade400.withOpacity(0.5),
             strokeColor: chat_list_match[i].gender!=null &&chat_list_match[i].gender.toLowerCase()=="female"? Color(0xfffb4592).withOpacity(0.2):Colors.blue.shade400.withOpacity(0.2),
            )]);


       } else if (action == Action.Professional) {
         print('onMove ## Professional action=$action');

        // _updateIntialMaps(2, i);
         var currentZoomLevel = await  _controllergoogleZoom.getZoomLevel();
         setMyIcon();
         _moveCamera(chat_list_match[i].latitude,chat_list_match[i].longitude,16);
         circles = Set.from([Circle(
           circleId: CircleId(chat_list_match[i].user_id+Random().nextInt(1000).toString()),
           center: LatLng(double.parse(chat_list_match[i].latitude), double.parse(chat_list_match[i].longitude)),
           radius: 70,//MQ_Width/5,
           strokeWidth: 1,

           fillColor: chat_list_match[i].gender!=null &&chat_list_match[i].gender.toLowerCase()=="female"? Color(0xfffb4592).withOpacity(0.5):Colors.blue.shade400.withOpacity(0.5),
           strokeColor: chat_list_match[i].gender!=null &&chat_list_match[i].gender.toLowerCase()=="female"? Color(0xfffb4592).withOpacity(0.2):Colors.blue.shade400.withOpacity(0.2),
         )]);

       }
     }else{

      /* Fluttertoast.showToast(
           msg: 'User Live Location Hidden !',
           toastLength: Toast.LENGTH_LONG,
           gravity: ToastGravity.CENTER,
           fontSize: Helper.textSizeH10,
           textColor: Colors.white,
           backgroundColor:Colors.blueAccent.withOpacity(0.9) ,
           timeInSecForIosWeb: 1);*/
       showDialog(
           context: context,
           barrierColor: Colors.transparent,
           builder: (context) {
             Future.delayed(Duration(seconds: 1), () {
               Navigator.of(context).pop(true);
             });

             return AlertDialog(
               title: Text(AppLocalizations.of(context).translate("User Live Location Hidden"),style: TextStyle(color: Colors.white,fontSize:Helper.textSizeH10)),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(Helper.avatarRadius),
               ),
               backgroundColor:Colors.blueAccent.withOpacity(0.7),
             );
           });

     }


     setState(() {});
   }
  }

  //===================== Show Alart People Details ==============

  void showAlartPeopleDetails(Chat chatList) async {
    double totalDistance = 0;
    setState(() {
     // "latitude": getPoint(true).toString(),
     // "longitude": getPoint(false).toString()
      print('showAlartPeopleDetails current latitude=${getPoint(true)}\n latitude=${getPoint(false)}'
          '\nchatList.gender=${chatList.gender}');
      try {
        totalDistance = calculateDistance(double.parse('${getPoint(true)}'),
            double.parse('${getPoint(false)}'),
            double.parse('${chatList.latitude}'),
            double.parse('${chatList.longitude}'));
      }catch(error){
        print('showAlartPeopleDetails totalDistance error=$error');
      }
    });
    var DOB=chatList.dob;
    print('showAlartPeopleDetails DOB=$DOB');
    int DOBAge=0;
    if(DOB!=null) {
      try {
        var dateFormat = new DateFormat("dd-MM-yyyy").parse(DOB);
        var currentDate = DateTime.now();
        DOBAge = dateFormat.year - currentDate.year;
        print('showAlartPeopleDetails DOB_age$DOBAge');
      }catch(error){
        print('DOB_age erro$error');
        DOBAge=0;
      }

    }

    await showDialog(context: context,
       // barrierColor: //Color(0xfffb4592).withOpacity(0.4),

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
              backgroundColor://Color(0xfffb4592).withOpacity(0.4),
               Colors.transparent,
              child: Container(

                child: Stack(
                  children: [

                    Container(
                      padding: EdgeInsets.only(left: 5,top: Helper.avatarRadius
                          + Helper.padding, right: 5,bottom: Helper.padding
                      ),
                      margin: EdgeInsets.only(top: Helper.avatarRadius),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(Helper.padding),
                          boxShadow: [
                            BoxShadow(color: Colors.black,offset: Offset(0,10),
                                blurRadius: 10
                            ),
                          ]
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Text('Location',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                          SizedBox(height: MQ_Height*0.07,),
                          Container(
                            alignment: Alignment.center,
                            child: CustomWigdet.TextView(
                                text: '${chatList.name}',//AppLocalizations.of(context).translate("Create Activity"),
                                fontFamily: "Kelvetica Nobis",
                                fontSize: Helper.textSizeH8,
                                fontWeight: Helper.textFontH5,
                                color: Helper.textColorBlueH1
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: MQ_Height*0.01,bottom: MQ_Height*0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                               chatList.hide_age.toString().trim()!='1'?Container(
                                  margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),

                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: CustomWigdet.TextView(
                                            text: '${DOBAge.toString().substring(1,DOBAge.toString().length)}',//AppLocalizations.of(context).translate("Create Activity"),
                                            fontFamily: "Kelvetica Nobis",
                                            fontSize: Helper.textSizeH10,
                                            fontWeight: Helper.textFontH5,
                                            color: Helper.textColorBlueH1
                                        ),
                                      ),
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
                                            backgroundColor:chatList.gender!=null &&chatList.gender.toLowerCase()=="female"? Color(0xfffb4592):Colors.blue.shade700,
                                            radius: Helper.avatarRadius,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(Helper.avatarRadius)),
                                              child: Image.asset(chatList.gender!=null && chatList.gender.toLowerCase()=="female"? "assest/images/female1.png":"assest/images/male.png",
                                                width: 15,height: 15,color: Color(Helper.inIconWhiteColorH1),),

                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ):Container(),

                                chatList.distance_hide.toString().trim()!='1'&& chatList.hide_age.toString().trim()!='1'? Container(
                                  width: 1,
                                  height: 30,
                                  color: Color(Helper.linePinkColor),
                                ):Container(),

                                /*Container(
                                  margin: EdgeInsets.only(left: MQ_Width*0.01,),
                                  // width: _screenSize.width,
                                  padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01,top: MQ_Height*0.02,bottom: MQ_Height*0.02),
                                  child: false?Icon(Icons.cake,color: Colors.blue,size: 16,):
                                  Image.asset("assest/images/birthday.png",
                                    width: 18,height: 18,color: Colors.blue,),
                                ),*/

                                chatList.distance_hide.toString().trim()!='1'?Container(
                                  margin: EdgeInsets.only(left: MQ_Width*0.02,right: MQ_Width*0.02),
                                  child: Row(
                                    children: [
                                      Container(

                                        alignment: Alignment.center,
                                        child: CustomWigdet.TextView(
                                            text: totalDistance!=0?'${totalDistance.toStringAsFixed(2)}':'$totalDistance',//AppLocalizations.of(context).translate("Create Activity"),
                                            fontFamily: "Kelvetica Nobis",
                                            fontSize: Helper.textSizeH10,
                                            fontWeight: Helper.textFontH5,
                                            color: Helper.textColorBlueH1
                                        ),
                                      ),
                                      Container(margin: EdgeInsets.only(top: MQ_Height*0.01),
                                        alignment: Alignment.bottomCenter,
                                        child: CustomWigdet.TextView(
                                            text: 'KM',//AppLocalizations.of(context).translate("Create Activity"),
                                            fontFamily: "Kelvetica Nobis",
                                            fontSize: Helper.textSizeH12,
                                            fontWeight: Helper.textFontH5,
                                            color: Helper.textColorBlueH1
                                        ),
                                      ),
                                    ],
                                  ),
                                ):Container(),
                              ],
                            ),
                          ),
                          SizedBox(height: 22,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: 0,
                                    right: 0,
                                    top: MQ_Height * 0.02,
                                    bottom: 2),
                                height: 50,
                                width: MQ_Width*0.40,
                                decoration: BoxDecoration(
                                  color: Color(Helper.ButtonBorderPinkColor),
                                  border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FlatButton(
                                  onPressed: ()async{
                                    Navigator.of(context).pop();
                                    if (action == Action.Activity) {
                                      Navigator.pushNamed(context, Constant.ChatUserDetail,
                                          arguments: {"user_id": chatList.user_id, "type": "1"});
                                      //     .then((value) {
                                      //   _showProgress(context);
                                      //   _chatItemList();
                                      // });
                                    } else if (action == Action.Professional) {
                                      Navigator.pushNamed(context, Constant.ChatUserDetail,
                                          arguments: {"user_id": chatList.user_id, "type": "2"});
                                      //     .then((value) {
                                      //   _showProgress(context);
                                      //   _professionItemList();
                                      // });
                                    }

                                  },
                                  child: Text(
                                    AppLocalizations.of(context).translate("MORE DETAILS").toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(left: 0,
                                    right: 0,
                                    top: MQ_Height * 0.02,
                                    bottom: 2),
                                height: 50,
                                width: MQ_Width*0.30,
                                decoration: BoxDecoration(
                                  color: Helper.ButtonBorderGreyColor,
                                  border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FlatButton(
                                  onPressed: ()async{
                                    Navigator.of(context).pop();


                                  },
                                  child: Text(
                                      AppLocalizations.of(context).translate("Cancel").toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                  ),
                                ),
                              ),
                            ],
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
                                  child:chatList.profile_img!=null ?Image.network(chatList.profile_img,width: 150,height: 150,):Image(image: AssetImage("assest/images/user2.png"),
                                  )
                              ),
                            ),
                          ),
                        ):
                        CircleAvatar(
                          backgroundColor:chatList.gender!=null &&chatList.gender.toLowerCase()=="female"? Color(0xfffb4592).withOpacity(0.4):Colors.blue.withOpacity(0.3),
                          radius: 75,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: chatList.profile_img!=null ?NetworkImage(chatList.profile_img,scale: 1.0): AssetImage("assest/images/user2.png"),

                          ),
                        )),

                  ],),
              ),
            ),
          );
        });
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }


  listViewWidget2(BuildContext context, List<Activity_User_Holder> chatList,
      ScrollController scrollController) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
       // scrollDirection: Axis.horizontal,

       // physics: NeverScrollableScrollPhysics(),
        physics: const AlwaysScrollableScrollPhysics(),

        itemBuilder: (context, i) {
          final nDataList = chatList[i];
          return getlistchatItem2(i, nDataList);
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 8,
          );
        },
        itemCount: chatList == null ? 0 : chatList.length,
      ),
    );
  }

 Widget  _widgetListCarouselSliderNewUI2(BuildContext context, List<Activity_User_Holder> chatList,
     ScrollController scrollController){

   return true?Center(
      child: WidgetSlider(
        fixedSize: 300,
        //aspectRatio: 30.0,
        sizeDistinction: 0.01,
        proximity: 0.7,
        controller: controller,
        itemCount: chatList.length,
        onMove:onMoveActivity,
        itemBuilder: (context, index, activeIndex) {
          return CupertinoButton(
            onPressed: () async {
              await controller.moveTo?.call(index);
              Navigator.pushNamed(context, Constant.ActivityUserDetail,
                  arguments: {
                    "event_id": chatList[index].event_id,
                    "isSub":chatList[index].is_subs
                  });

             // showAlartActivityDetails(chatList[index]);
              },
            child:false?Container(
              height:MQ_Height*0.70,
              width: MQ_Width*0.70,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,

                    colors: [
                      // Color(0XFF8134AF),
                      // Color(0XFFDD2A7B),
                      // Color(0XFFFEDA77),
                      // Color(0XFFF58529),
                      Colors.blue.withOpacity(0.5),
                      Colors.blue.withOpacity(0.5),

                    ],
                  ),
                  shape: BoxShape.circle
              ),
              child: Container(
                // padding: EdgeInsets.all(5),
                // height: 150,
                //width: 150,
                margin: const EdgeInsets.all(10),
                /*decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(chatList[index].profile_img,scale: 1.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade50,
                      offset: const Offset(0, 8),
                      spreadRadius: 30,
                      blurRadius: 30,
                    ),
                    BoxShadow(
                      color: Colors.grey.shade100,
                      offset: const Offset(0, 8),
                      spreadRadius: 30,
                      blurRadius: 30,
                    ),
                  ],
                ),*/
                child:
                Container(
                  height: 200,
                  width: 200,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(

                          child: ClipOval(
                              child:chatList[index].image!=null?Image.network(chatList[index].image, fit: BoxFit.cover, width: 1000):Image.asset('assets/images/user2.png', fit: BoxFit.cover, width: 1000)),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child:   Container(
                          // margin: EdgeInsets.all(2),
                          // color: Colors.purple,
                          height: 45,
                          width: 135,
                          //margin: EdgeInsets.only(left: 5,right: 5,bottom: 1),
                          decoration: BoxDecoration(
                            // border: Border.all(color: Colors.transparent,width: 2),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(100),
                                bottomRight: Radius.circular(100)),
                            color: Colors.blue.withOpacity(0.3),
                            //shape: BoxShape.rectangle,
                            // color: Colors.purple,

                          ),
                          child: Column(
                            children: [
                              Container(
                                //  width: MQ_Width,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(2),
                                child: CustomWigdet.TextView(
                                    textAlign: TextAlign.center,
                                    text: '${chatList[index].title}',
                                    color:Custom_color.WhiteColor,
                                    fontFamily: "OpenSans",
                                    fontWeight: Helper.textFontH5,
                                    fontSize: Helper.textSizeH15),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  false?Container(
                                    //width: MQ_Width,
                                    padding: EdgeInsets.all(2),
                                    child: CustomWigdet.TextView(
                                        textAlign: TextAlign.center,
                                        text: '24',
                                        color: Custom_color.WhiteColor,
                                        fontFamily: "OpenSans",
                                        fontWeight: Helper.textFontH5,
                                        fontSize: Helper.textSizeH15),
                                  ):Container(),
                                  Container(
                                    // margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                    // width:18,
                                    // height: 40,
                                    /*decoration: BoxDecoration(
                //  color:Colors.blue,
                //borderRadius: BorderRadius.circular(30)

              ),*/
                                    // padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                    // child: CustomWigdet.TextView(
                                    //     text:
                                    //         gender != null ? _getGender(gender) : gender,
                                    //     textAlign: TextAlign.center,
                                    //     overflow: true,
                                    //     color: Custom_color.GreyLightColor),
                                      /*child:
                                      ClipOval(
                                        child: Material(
                                          color://gender!=null && gender==1?
                                          chatList[index].gender!=null&&chatList[index].gender==1?Color(0xfffb4592):Colors.blue.shade700,//Helper.inIconCircleBlueColor1, // Button color
                                          child: InkWell(
                                            splashColor: Helper.inIconCircleBlueColor1, // Splash color
                                            onTap: () {},
                                            child: SizedBox(width: 18, height: 18,
                                              child:Image.asset(
                                                chatList[index].gender!=null &&chatList[index].gender==1?
                                                "assest/images/female1.png":"assest/images/male.png",
                                                width: 10,height: 10,color: Color(Helper.inIconWhiteColorH1),),
                                            ),
                                          ),
                                        ),
                                      )*/
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ):Container(
              width: MQ_Width*0.70,
              height: 300,

              // padding: EdgeInsets.only(top: 3),
              child: Stack(
               // alignment: Alignment.center,
               // clipBehavior: Clip.none,
                children: <Widget>[
                 true? Column(children: [
                   Container(
                   padding: EdgeInsets.only(left: Helper.padding,top: Helper.avatarRadius
                       + Helper.padding, right: Helper.padding,bottom: Helper.padding
                   ),
                   margin: EdgeInsets.only(top: Helper.avatarRadius),
                   decoration: BoxDecoration(
                       color: Colors.white,
                      borderRadius:BorderRadius.circular(10)
                   ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                         false? Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child:Container(
                                child: CustomWigdet.TextView(
                                    text: chatList[index].title,
                                    overflow: false,
                                    color: Color(0xff217fc5),
                                    fontSize: Helper.textSizeH12,
                                    fontFamily: "Kelvetica Nobis"),
                              )),
                              Icon(
                                chatList[index].is_subs == 0
                                    ? Icons.check
                                    : Icons.done_all,
                                size: 20,
                                color: chatList[index].is_subs == 0
                                    ? Custom_color.GreyLightColor
                                    : Color(0xfff73d90),
                              )
                            ],
                          ):Container(
                          // margin: EdgeInsets.only(top:5),
                           child: CustomWigdet.TextView(
                               text: chatList[index].title,
                               overflow: false,
                               textAlign: TextAlign.center,
                               color: Color(0xff217fc5),
                               fontSize: Helper.textSizeH12,
                               fontFamily: "Kelvetica Nobis"),
                         ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left:80.0,
                                right: 80.0, top: 3, bottom: 3),
                            child: Divider(
                                thickness: 1, color: Color(0xfff73d90)),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 11,
                                backgroundColor: Color(0xffacacac),
                                child: Image.asset(
                                  "assest/images/pin2.png",
                                  color: Custom_color.WhiteColor,
                                  width: 14,
                                  height: 14,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: CustomWigdet.TextView(
                                    overflow: true,
                                    fontSize: 11,
                                    text: chatList[index].location,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
//                                CustomWigdet.TextView(
//                                    text: nDataList.interest,
//                                    color: Custom_color.GreyLightColor,
//                                    fontFamily: "OpenSans Bold"),
                          !UtilMethod.isStringNullOrBlank(
                              chatList[index].start_time)
                              ? Row(
                            children: [
                              CircleAvatar(
                                radius: 11,
                                backgroundColor: Color(0xffacacac),
                                child: Image.asset(
                                  "assest/images/calendar.png",
                                  color: Custom_color.WhiteColor,
                                  width: 14,
                                  height: 14,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              CustomWigdet.TextView(
                                  fontSize: 11,
                                  text: chatList[index].start_time,
                                  color: Colors.black),
                            ],
                          )
                              : Container(),
                          chatList[index].categroy_holder != null &&
                              chatList[index].categroy_holder.isNotEmpty
                              ? Padding(
                            padding:
                            const EdgeInsets.only(top: 5.0),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 1.0),
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor:
                                    Color(0xffacacac),
                                    child: Image.asset(
                                      "assest/images/interest.png",
                                      color:
                                      Custom_color.WhiteColor,
                                      width: 14,
                                      height: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: CustomWigdet.TextView(
                                    fontSize: 11,
                                    overflow: true,
                                    text: _getListcategroyitem(
                                        chatList[index].categroy_holder),
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Container(),
                         /* Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 8.0),
                              child: InkWell(
                                  onTap: () async {
                                    if (await UtilMethod
                                        .SimpleCheckInternetConnection(
                                        context, _scaffoldKey)) {
                                      print("----isSubs-----" +
                                          chatList[index].is_subs.toString());
                                      String value = "";
                                      if (chatList[index].is_subs == 1) {
                                        value = "0";
                                        print("----0000000000--------");
                                      } else {
                                        value = "1";
                                        print(
                                            "----------11111111--------");
                                      }
                                      _GetSubscribe(
                                          chatList[index].event_id, value);
                                    }
                                  },
                                  child: Icon(
                                    chatList[index].is_subs == 0
                                        ? Icons.check
                                        : Icons.done_all,
                                    size: 20,
                                    color: chatList[index].is_subs == 0
                                        ? Custom_color.WhiteColor
                                        : Color(0xffffffff),
                                  )),
                            ),
                          ),*/
                        ],
                      ),
                    ),
                 ),
                   Container(
                     margin: EdgeInsets.only(left: 20,right:20),
                     height: 8.0,
                     decoration: BoxDecoration(
                       color:  Color(0xff1b98ea),
                       borderRadius: BorderRadius.only(
                         bottomLeft: Radius.circular(20),
                         bottomRight: Radius.circular(20),

                       )
                     )
                   )
                 ],): Container(
                   padding: EdgeInsets.only(left: Helper.padding,top: Helper.avatarRadius
                       + Helper.padding, right: Helper.padding,bottom: Helper.padding
                   ),
                   margin: EdgeInsets.only(top: Helper.avatarRadius),
                   decoration: BoxDecoration(
                       shape: BoxShape.rectangle,
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(Helper.padding),
                       boxShadow: [
                         BoxShadow(color: Colors.black,offset: Offset(0,10),
                             blurRadius: 10
                         ),
                       ]
                   ),
                   child: ClipShadowPath(
                     clipper: ShapeBorderClipper(
                         shape: RoundedRectangleBorder(
                             borderRadius:
                             BorderRadius.all(Radius.circular(10)))),
                     shadow: BoxShadow(
                       color: Color(0xffe4e9ef),
                       offset: Offset(1.0, 1.0), //(x,y)
                       blurRadius: 15.0,
                     ),
                     child: Container(
                       decoration: BoxDecoration(
                           color: Colors.white,
                           border: Border(
                             bottom: BorderSide(
                                 width: 8.0, color: Color(0xff1b98ea)),
                           )),
                       child: ConstrainedBox(
                         constraints:
                         BoxConstraints(maxWidth: 310, maxHeight: 175),
                         child: Padding(
                           padding: const EdgeInsets.only(
                               left: 5, top: 20, right: 15),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: <Widget>[
                               Row(
                                 mainAxisAlignment:
                                 MainAxisAlignment.spaceBetween,
                                 children: [
                                   Expanded(child:Container(
                                     child: CustomWigdet.TextView(
                                         text: chatList[index].title,
                                         overflow: false,
                                         color: Color(0xff217fc5),
                                         fontSize: Helper.textSizeH12,
                                         fontFamily: "Kelvetica Nobis"),
                                   )),
                                   Icon(
                                     chatList[index].is_subs == 0
                                         ? Icons.check
                                         : Icons.done_all,
                                     size: 20,
                                     color: chatList[index].is_subs == 0
                                         ? Custom_color.GreyLightColor
                                         : Color(0xfff73d90),
                                   )
                                 ],
                               ),
                               Padding(
                                 padding: const EdgeInsets.only(
                                     right: 140.0, top: 3, bottom: 3),
                                 child: Divider(
                                     thickness: 1, color: Color(0xfff73d90)),
                               ),
                               Row(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   CircleAvatar(
                                     radius: 11,
                                     backgroundColor: Color(0xffacacac),
                                     child: Image.asset(
                                       "assest/images/pin2.png",
                                       color: Custom_color.WhiteColor,
                                       width: 14,
                                       height: 14,
                                     ),
                                   ),
                                   SizedBox(
                                     width: 5,
                                   ),
                                   Expanded(
                                     child: CustomWigdet.TextView(
                                         overflow: true,
                                         fontSize: 11,
                                         text: chatList[index].location,
                                         color: Colors.black),
                                   ),
                                 ],
                               ),
                               SizedBox(
                                 height: 5,
                               ),
//                                CustomWigdet.TextView(
//                                    text: nDataList.interest,
//                                    color: Custom_color.GreyLightColor,
//                                    fontFamily: "OpenSans Bold"),
                               !UtilMethod.isStringNullOrBlank(
                                   chatList[index].start_time)
                                   ? Row(
                                 children: [
                                   CircleAvatar(
                                     radius: 11,
                                     backgroundColor: Color(0xffacacac),
                                     child: Image.asset(
                                       "assest/images/calendar.png",
                                       color: Custom_color.WhiteColor,
                                       width: 14,
                                       height: 14,
                                     ),
                                   ),
                                   SizedBox(
                                     width: 5,
                                   ),
                                   CustomWigdet.TextView(
                                       fontSize: 11,
                                       text: chatList[index].start_time,
                                       color: Colors.black),
                                 ],
                               )
                                   : Container(),
                               chatList[index].categroy_holder != null &&
                                   chatList[index].categroy_holder.isNotEmpty
                                   ? Padding(
                                 padding:
                                 const EdgeInsets.only(top: 5.0),
                                 child: Row(
                                   crossAxisAlignment:
                                   CrossAxisAlignment.start,
                                   mainAxisSize: MainAxisSize.min,
                                   children: <Widget>[
                                     Padding(
                                       padding: const EdgeInsets.only(
                                           top: 1.0),
                                       child: CircleAvatar(
                                         radius: 11,
                                         backgroundColor:
                                         Color(0xffacacac),
                                         child: Image.asset(
                                           "assest/images/interest.png",
                                           color:
                                           Custom_color.WhiteColor,
                                           width: 14,
                                           height: 14,
                                         ),
                                       ),
                                     ),
                                     SizedBox(
                                       width: 5,
                                     ),
                                     Expanded(
                                       child: CustomWigdet.TextView(
                                         fontSize: 11,
                                         overflow: true,
                                         text: _getListcategroyitem(
                                             chatList[index].categroy_holder),
                                         color: Colors.black,
                                       ),
                                     ),
                                   ],
                                 ),
                               )
                                   : Container(),
                               Align(
                                 alignment: Alignment.centerRight,
                                 child: Padding(
                                   padding: const EdgeInsets.only(
                                       right: 8.0, top: 4),
                                   child: InkWell(
                                       onTap: () async {
                                         if (await UtilMethod
                                             .SimpleCheckInternetConnection(
                                             context, _scaffoldKey)) {
                                           print("----isSubs-----" +
                                               chatList[index].is_subs.toString());
                                           String value = "";
                                           if (chatList[index].is_subs == 1) {
                                             value = "0";
                                             print("----0000000000--------");
                                           } else {
                                             value = "1";
                                             print(
                                                 "----------11111111--------");
                                           }
                                           _GetSubscribe(
                                               chatList[index].event_id, value);
                                         }
                                       },
                                       child: Icon(
                                         chatList[index].is_subs == 0
                                             ? Icons.check
                                             : Icons.done_all,
                                         size: 20,
                                         color: chatList[index].is_subs == 0
                                             ? Custom_color.WhiteColor
                                             : Color(0xffffffff),
                                       )),
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                   )
                 ),

                    Positioned(
                     // left: Helper.padding,
                      right: Helper.padding,
                      top: 60,
                      child:  Container(
                      alignment: Alignment.topRight,
                      child: chatList[index].is_subs == 0?Icon(
                        chatList[index].is_subs == 0
                            ? Icons.check
                            : Icons.done_all,
                        size: 20,
                        color: chatList[index].is_subs == 0
                            ? Custom_color.GreyLightColor
                            : Color(0xfff73d90),
                      ):SvgPicture.asset('assest/images_svg/complete.svg',width: 20,height: 20,),
                    )
                      ,),
                  false?Positioned.fill(
                    left: 10,
                    top: -30,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          chatList[index].image != null
                              ? Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0, 7),
                                    blurRadius: 15)
                              ],
                            ),
                            width: 70,
                            height: 10,
                          )
                              : Container(),
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: 90, maxHeight: 100,minWidth: 50, minHeight: 60),
                              child : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    child: chatList[index].image != null
                                        ? Image.network(
                                      chatList[index].image,
                                      fit: BoxFit.cover,
                                    )
                                        : Container()),
                              )),
                        ],
                      ),
                    ),
                  ): Positioned(
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
                            child: ClipOval(
                              //borderRadius: BorderRadius.all(Radius.circular(Helper.avatarRadius)),
                                child:chatList[index].image!=null?Image.network(chatList[index].image, fit: BoxFit.cover,):Image(image: AssetImage("assest/images/user2.png"),
                                )
                            ),
                          ),
                        ),
                      ):
                      Hero(
                        tag: index,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.3),
                          radius: 55,
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: chatList[index].image!=null ?NetworkImage(chatList[index].image,scale: 1.0): AssetImage("assest/images/user2.png"),

                          ),
                        ),
                      )),


                ],
              ),
            )
          );
        },
      ),
    ):

    Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      height: MediaQuery.of(context).size.height * 0.25,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
           // key: onMoveActivity,
            itemCount: chatList.length, itemBuilder: (context, index) {

           return Container(
           width: MQ_Width*0.80,
           child:InkWell(
             onFocusChange: (v){
               FlutterToastAlert.flutterToastMSG('MSG', context);
               onMoveActivity(index);
             },
            onTap: () {
             /* Navigator.pushNamed(context, Constant.ActivityUserDetail,
                  arguments: {
                    "event_id": chatList[index].event_id,
                    "isSub": chatList[index].is_subs
                  });*/
              showAlartActivityDetails(chatList[index]);
            },
            child: Container(
              //width: MQ_Width*0.90,
              padding: EdgeInsets.only(top: 3),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: ClipShadowPath(
                      clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10)))),
                      shadow: BoxShadow(
                        color: Color(0xffe4e9ef),
                        offset: Offset(1.0, 1.0), //(x,y)
                        blurRadius: 15.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                  width: 8.0, color: Color(0xff1b98ea)),
                            )),
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(maxWidth: 310, maxHeight: 175),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 95, top: 20, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child:Container(
                                      child: CustomWigdet.TextView(
                                             text: chatList[index].title,
                                           overflow: false,
                                          color: Color(0xff217fc5),
                                          fontSize: Helper.textSizeH12,
                                          fontFamily: "Kelvetica Nobis"),
                                    )),
                                    Icon(
                                      chatList[index].is_subs == 0
                                          ? Icons.check
                                          : Icons.done_all,
                                      size: 20,
                                      color: chatList[index].is_subs == 0
                                          ? Custom_color.GreyLightColor
                                          : Color(0xfff73d90),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 140.0, top: 3, bottom: 3),
                                  child: Divider(
                                      thickness: 1, color: Color(0xfff73d90)),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 11,
                                      backgroundColor: Color(0xffacacac),
                                      child: Image.asset(
                                        "assest/images/pin2.png",
                                        color: Custom_color.WhiteColor,
                                        width: 14,
                                        height: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: CustomWigdet.TextView(
                                          overflow: true,
                                          fontSize: 11,
                                          text: chatList[index].location,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
//                                CustomWigdet.TextView(
//                                    text: nDataList.interest,
//                                    color: Custom_color.GreyLightColor,
//                                    fontFamily: "OpenSans Bold"),
                                !UtilMethod.isStringNullOrBlank(
                                    chatList[index].start_time)
                                    ? Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 11,
                                      backgroundColor: Color(0xffacacac),
                                      child: Image.asset(
                                        "assest/images/calendar.png",
                                        color: Custom_color.WhiteColor,
                                        width: 14,
                                        height: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    CustomWigdet.TextView(
                                        fontSize: 11,
                                        text: chatList[index].start_time,
                                        color: Colors.black),
                                  ],
                                )
                                    : Container(),
                                chatList[index].categroy_holder != null &&
                                    chatList[index].categroy_holder.isNotEmpty
                                    ? Padding(
                                  padding:
                                  const EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 1.0),
                                        child: CircleAvatar(
                                          radius: 11,
                                          backgroundColor:
                                          Color(0xffacacac),
                                          child: Image.asset(
                                            "assest/images/interest.png",
                                            color:
                                            Custom_color.WhiteColor,
                                            width: 14,
                                            height: 14,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: CustomWigdet.TextView(
                                          fontSize: 11,
                                          overflow: true,
                                          text: _getListcategroyitem(
                                              chatList[index].categroy_holder),
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    : Container(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, top: 4),
                                    child: InkWell(
                                        onTap: () async {
                                          if (await UtilMethod
                                              .SimpleCheckInternetConnection(
                                              context, _scaffoldKey)) {
                                            print("----isSubs-----" +
                                                chatList[index].is_subs.toString());
                                            String value = "";
                                            if (chatList[index].is_subs == 1) {
                                              value = "0";
                                              print("----0000000000--------");
                                            } else {
                                              value = "1";
                                              print(
                                                  "----------11111111--------");
                                            }
                                            _GetSubscribe(
                                                chatList[index].event_id, value);
                                          }
                                        },
                                        child: Icon(
                                          chatList[index].is_subs == 0
                                              ? Icons.check
                                              : Icons.done_all,
                                          size: 20,
                                          color: chatList[index].is_subs == 0
                                              ? Custom_color.WhiteColor
                                              : Color(0xffffffff),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    left: 10,
                    top: -30,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          chatList[index].image != null
                              ? Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0, 7),
                                    blurRadius: 15)
                              ],
                            ),
                            width: 70,
                            height: 10,
                          )
                              : Container(),
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: 90, maxHeight: 100,minWidth: 50, minHeight: 60),
                              child : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    child: chatList[index].image != null
                                        ? Image.network(
                                      chatList[index].image,
                                      fit: BoxFit.cover,
                                    )
                                        : Container()),
                              )),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
  Future<void> onMoveActivity(int i)async{
    // FlutterToastAlert.flutterToastMSG('MSG onMove=$i', context);

    if(activity_list.length!=0) {
      if(_markers.length!=0){
        _markers.clear();
      }
      print('onMoveActivity ## postion=${i}');
      print('onMoveActivity ## chat_list_match[i].profile_img=${activity_list[i].image}');
      print('onMoveActivity ## activity_list[i].event_id=${activity_list[i].event_id}');
      print('onMoveActivity ## activity_list[i].latitude=${activity_list[i].latitude}');
      print('onMoveActivity ## activity_list[i].longitude=${activity_list[i].longitude}');

      /*Uint8List markerIcon = await getMarkerIconActivity(
         activity_list[i].profile_imgmap, Size(150, 150));
     _markers.add(Marker(
         markerId: MarkerId(activity_list[i].event_id.toString() +
             Random().nextInt(1000).toString()),
         position: LatLng(double.parse(chat_list_match[i].latitude),
             double.parse(activity_list[i].longitude)),
         icon: BitmapDescriptor.fromBytes(markerIcon)));*/

        _updateIntialMaps(1,i);


      setState(() {});
    }
  }



  Future<String> _getCountry(Chat nDataList) async {
    List<Placemark> placemark = await placemarkFromCoordinates(
        double.tryParse(nDataList.latitude.toString()),
        double.tryParse(nDataList.longitude.toLowerCase()));

    return placemark[0].country;
  }

//====================== Show Alart Activity Details =============
  void showAlartActivityDetails(Activity_User_Holder activityUserHolder) async {
    var gender=null;
    await showDialog(context: context,
        builder: (BuildContext context){
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Helper.avatarRadius),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(

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
                        boxShadow: [
                          BoxShadow(color: Colors.black,offset: Offset(0,10),
                              blurRadius: 10
                          ),
                        ]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Text('Location',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                        SizedBox(height: MQ_Height*0.05,),
                        Container(
                          alignment: Alignment.center,
                          child: CustomWigdet.TextView(
                              text: '${activityUserHolder.title??''}',//AppLocalizations.of(context).translate("Create Activity"),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH8,
                              fontWeight: Helper.textFontH5,
                              color: Helper.textColorBlueH1
                          ),
                        ),
                        false?Container(
                          margin: EdgeInsets.only(top: MQ_Height*0.01,bottom: MQ_Height*0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),

                                child: Row(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: CustomWigdet.TextView(
                                          text: '24',//AppLocalizations.of(context).translate("Create Activity"),
                                          fontFamily: "Kelvetica Nobis",
                                          fontSize: Helper.textSizeH10,
                                          fontWeight: Helper.textFontH5,
                                          color: Helper.textColorBlueH1
                                      ),
                                    ),
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
                                  ],
                                ),
                              ),

                              Container(
                                width: 1,
                                height: 30,
                                color: Color(Helper.linePinkColor),
                              ),

                              /*Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.01,),
                                // width: _screenSize.width,
                                padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01,top: MQ_Height*0.02,bottom: MQ_Height*0.02),
                                child: false?Icon(Icons.cake,color: Colors.blue,size: 16,):
                                Image.asset("assest/images/birthday.png",
                                  width: 18,height: 18,color: Colors.blue,),
                              ),*/

                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.02,right: MQ_Width*0.02),
                                child: Row(
                                  children: [
                                    Container(

                                      alignment: Alignment.center,
                                      child: CustomWigdet.TextView(
                                          text: '23',//AppLocalizations.of(context).translate("Create Activity"),
                                          fontFamily: "Kelvetica Nobis",
                                          fontSize: Helper.textSizeH10,
                                          fontWeight: Helper.textFontH5,
                                          color: Helper.textColorBlueH1
                                      ),
                                    ),
                                    Container(margin: EdgeInsets.only(top: MQ_Height*0.01),
                                      alignment: Alignment.bottomCenter,
                                      child: CustomWigdet.TextView(
                                          text: 'KM',//AppLocalizations.of(context).translate("Create Activity"),
                                          fontFamily: "Kelvetica Nobis",
                                          fontSize: Helper.textSizeH12,
                                          fontWeight: Helper.textFontH5,
                                          color: Helper.textColorBlueH1
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ):Container(),
                        SizedBox(height: 22,),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.bottomCenter,
                              margin:  EdgeInsets.only(right: MQ_Width*0.01,top: MQ_Height * 0.02,bottom: MQ_Height * 0.01 ),
                              padding: EdgeInsets.only(bottom: 5),
                              height: 60,
                              width: MQ_Width*0.40,
                              decoration: BoxDecoration(
                                color: Color(Helper.ButtonBorderPinkColor),
                                border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FlatButton(
                                onPressed: ()async{
                                  Navigator.of(context).pop();
                                  Navigator.pushNamed(context, Constant.ActivityUserDetail,
                                      arguments: {
                                        "event_id": activityUserHolder.event_id,
                                        "isSub": activityUserHolder.is_subs
                                      });

                                },
                                child: Text(
                                  'More Details'.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH12,fontWeight:Helper.textFontH5),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              margin:  EdgeInsets.only(left: MQ_Width*0.01,top: MQ_Height * 0.02,bottom: MQ_Height * 0.01 ),
                              padding: EdgeInsets.only(bottom: 5),
                              height: 60,
                              width: MQ_Width*0.27,
                              decoration: BoxDecoration(
                                color: Helper.ButtonBorderGreyColor,
                                border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FlatButton(
                                onPressed: ()async{
                                  Navigator.of(context).pop();


                                },
                                child: Text(
                                  'Cancel'.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH12,fontWeight:Helper.textFontH5),
                                ),
                              ),
                            ),
                          ],
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
                            child: ClipOval(
                                //borderRadius: BorderRadius.all(Radius.circular(Helper.avatarRadius)),
                                child: activityUserHolder.image!=null?Image.network(activityUserHolder.image, fit: BoxFit.cover,):Image(image: AssetImage("assest/images/user2.png"),
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
                          backgroundImage: activityUserHolder.image!=null ?NetworkImage(activityUserHolder.image,scale: 1.0): AssetImage("assest/images/user2.png"),

                        ),
                      )),

                ],),
            ),
          );
        });
  }








  bool isProcessing = false;
  var resize        = [true,true,true];
  var useAssetImg   = [false,false,false];

  _updateIntialMaps(int index,int position) async {
    isProcessing = true;
    _markers.clear();
    if(_markers1.length!=0){
      _markers1.clear();
    }
	  setCustomMarker();
    //============= Old moveCamera function =======
   // _moveCamera();
    //============= new moveCamera function =======
    _moveCamera(getPoint(true),getPoint(false),14);
    //try{showHelp();}catch(e){}
    if (!_listVisible) {
      _markers.clear();
    } else if (_listVisible) {
      await getBytesFromAsset('assest/images/user2.png', 100).then((onValue) {
          mapIcon =BitmapDescriptor.fromBytes(onValue);
      });
      if (index == 0 || index == 2) {
        if (chat_list_match.length != 0 && chat_list_match.length > 0) {
           if(_markers.length!=0) {
             _markers.clear();
           }

           //============== old for loop  all user view map =======================
          for (var data in chat_list_match) {
            String pImage = data.profile_img;//data.profile_imgmap != null ? data.profile_imgmap : data.profile_img;
            if (action != Action.People) {
              Marker m=null;
              try
              {
                  print("useasset :: "+useAssetImg[toggle].toString());
                  var icon  = null;


                  if(useAssetImg[toggle])
                  {
                      icon  = mapIcon;
                  }
                  else
                  {
                      var a   = await getMarkerIcon(pImage, const Size(80, 80),resize[toggle]);
                      print('img getMarkerIcon a ::= $a');
                      icon    = await getMarkerIconNew(data.profile_img,data.name);
                     // BitmapDescriptor.fromBytes(a);
                  }

                  print("Marker Check data.user_id :: "+data.user_id+"\n data.latitude=${data.latitude}"+"\n data.longitude=${data.longitude}");
                  if(data.allownavigation==1) {
                    _markers1.add(Marker(
                      markerId: MarkerId(
                          data.user_id + Random().nextInt(1000).toString()),
                      position: LatLng(double.parse(data.latitude),
                          double.parse(data.longitude)),
                      anchor: const Offset(0.5, 0.5),
                      icon: icon,

                      onTap: () {
                        int allow = 1;
                        try {
                          allow = data.allownavigation;
                        } catch (eew) {}
                        if (allow == 1) {
                          if (action == Action.Activity) {
                            Navigator.pushNamed(context,
                                Constant.ChatUserDetail,
                                arguments: {
                                  "user_id": data.user_id,
                                  "type": "1"
                                })
                                .then((value) {
                              // _showProgress(context,"9");
                              _chatItemList();
                            });
                          } else if (action == Action.Professional) {
                            Navigator.pushNamed(
                                context, Constant.ChatUserDetail,
                                arguments: {
                                  "user_id": data.user_id,
                                  "type": "2"
                                })
                                .then((value) {
                              // _showProgress(context,"8");
                              _professionItemList();
                            });
                          }
                        }
                      },
                    ));
                  }


                 /* circles = Set.from([Circle(
                    circleId: CircleId(chat_list_match[0].user_id+Random().nextInt(1000).toString()),
                    center: LatLng(double.parse(chat_list_match[0].latitude), double.parse(chat_list_match[0].longitude)),
                    radius: 80,

                    fillColor: chat_list_match[0].gender!=null &&chat_list_match[0].gender.toLowerCase()=="female"? Color(0xfffb4592).withOpacity(0.5):Colors.blue.shade400.withOpacity(0.5),
                    strokeColor: chat_list_match[0].gender!=null &&chat_list_match[0].gender.toLowerCase()=="female"? Color(0xfffb4592).withOpacity(0.2):Colors.blue.shade400.withOpacity(0.2),
                  )]);*/


                    m   = Marker(
                    markerId: MarkerId(data.user_id+Random().nextInt(1000).toString()),
                    position: LatLng(double.parse(data.latitude), double.parse(data.longitude)),
                    anchor: const Offset(0.5, 0.5),
                    icon: icon ,
                      zIndex:300.0,
                    onTap: () {
                      int allow = 1;
                      try{allow = data.allownavigation;}catch(eew){}
                      if(allow == 1)
                      {
                          if (action == Action.Activity) {
                            Navigator.pushNamed(context, Constant.ChatUserDetail,
                                    arguments: {"user_id": data.user_id, "type": "1"})
                                .then((value) {
                             // _showProgress(context,"9");
                              _chatItemList();
                            });
                          } else if (action == Action.Professional) {
                            Navigator.pushNamed(context, Constant.ChatUserDetail,
                                    arguments: {"user_id": data.user_id, "type": "2"})
                                .then((value) {
                             // _showProgress(context,"8");
                              _professionItemList();
                            });
                          }
                      }
                      
                    },
                  );

              }
              catch(ee){
                print(e.toString());
              }
              
              if(m != null)
                print('_updateIntialMaps #### _makers =$m');
                _markers.add(m);
            }
            setState(() {});
          }

           //============  New  one user view map ===========

         /*//  for (var data in chat_list_match) {
          // =================== old pImage =======================
             String pImage  = chat_list_match[position].profile_imgmap != null ? chat_list_match[position].profile_imgmap : chat_list_match[position].profile_img;
           //=================== New pImage =======================
             // String pImage  =  chat_list_match[position].profile_img;
             if (action != Action.People) {
               Marker m = null;
               try
               {
                 print("useasset :: "+useAssetImg[toggle].toString());
                 var icon  = null;


                 if( useAssetImg[toggle])
                 {
                   icon  = mapIcon;
                 }
                 else
                 {
                   var a   = await getMarkerIcon(pImage, Size(150, 150),resize[toggle]);
                   icon    = BitmapDescriptor.fromBytes(a);
                 }


                 m   = await Marker(

                   markerId:
                   MarkerId(chat_list_match[position].user_id + Random().nextInt(1000).toString()),
                   position: LatLng(
                       double.parse(chat_list_match[position].latitude), double.parse(chat_list_match[position].longitude)),
                   anchor: Offset(0.5, 0.5),
                   icon: icon ,
                   onTap: () {
                     int allow = 1;
                     try{allow = chat_list_match[position].allownavigation;}catch(eew){}
                     if(allow == 1)
                     {
                       if (action == Action.Activity) {
                         Navigator.pushNamed(context, Constant.ChatUserDetail,
                             arguments: {"user_id": chat_list_match[position].user_id, "type": "1"})
                             .then((value) {
                           _showProgress(context,"9");
                           _chatItemList();
                         });
                       } else if (action == Action.Professional) {
                         Navigator.pushNamed(context, Constant.ChatUserDetail,
                             arguments: {"user_id": chat_list_match[position].user_id, "type": "2"})
                             .then((value) {
                           _showProgress(context,"8");
                           _professionItemList();
                         });
                       }
                     }

                   },
                 );

               }
               catch(ee){print(e.toString());}

               if(m != null)
                 print('_updateIntialMaps #### _makers =$m');


               _markers.add(m);
               //============= new moveCamera function =======
               setMyIcon();
               _moveCamera(chat_list_match[position].latitude,chat_list_match[position].longitude);
             }
            // setState(() {});
         //  }
          setState(() {});*/
        } else {
           setState(() {});
          //_moveCamera();
        }
      } else if (index == 1) {
        if(_markers1.length!=0) {
          _markers1.clear();
        }
        if (activity_list != null && activity_list.length > 0) {

          //================= old for loop all user view map ===========
          for (var i = 0; i < activity_list.length; i++) {
            Uint8List markerIcon = await getMarkerIconActivity(
                activity_list[i].image, Size(150, 150));
            _markers1.add(Marker(
                markerId: MarkerId(activity_list[i].event_id.toString() +
                    Random().nextInt(1000).toString()),
                position: LatLng(double.parse(activity_list[i].latitude),
                    double.parse(activity_list[i].longitude)),
                icon: BitmapDescriptor.fromBytes(markerIcon)));
                setState(() {});
          }

          //================== New one user view map ============

          /*Uint8List markerIcon = await getMarkerIconActivity(
              activity_list[position].image, Size(150, 150));
          _markers.add(Marker(
              markerId: MarkerId(activity_list[position].event_id.toString() +
                  Random().nextInt(1000).toString()),
              position: LatLng(double.parse(activity_list[position].latitude),
                  double.parse(activity_list[position].longitude)),
              icon: BitmapDescriptor.fromBytes(markerIcon)));

          //============= new moveCamera function =======
          setMyIcon();
          _moveCamera(activity_list[position].latitude,activity_list[position].longitude);
          setState(() {});*/
           
        }
        //_moveCamera();
      }
    }

   // setMyIcon();
   // _moveCamera();
    isProcessing = false; 
  }
  
  setMyIcon() async
  {
    try
    {
        _markers.remove(myMarker);
        _markers.remove(myMarker);
        if(myMarker != null && isLocationEnabled)
           // _markers.add(myMarker);

        _markers1.add(myMarker);
        setState(() { });
    }catch(e){}
      
  }
//================ old method move Location ========
  _moveCamera1() async {
        setState(() {});
        _currentCameraPosition = await CameraPosition(
            target: LatLng(getPoint(true), getPoint(false)),
            zoom: 15);
        final GoogleMapController controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(_currentCameraPosition));


       // mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(currentLocation.latitude, currentLocation.longitude), 14));

  }
//================ new  method move Location ========
  _moveCamera(var latitude,var longitude ,var zoomPos) async {
    zoomPos ??= 14;
    setState(() {});
    _currentLatLng=LatLng(double.parse('$latitude'),double.parse('$longitude'));
    _currentCameraPosition = await CameraPosition(
        target:_currentLatLng,
        zoom: double.parse('${zoomPos}'),
      bearing: 12.0,
      tilt: 12.0);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(_currentCameraPosition));




    // mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(currentLocation.latitude, currentLocation.longitude), 14));

  }

  Future<Uint8List> getMarkerIconActivity(String imagePath, Size size) async {
    final ue.PictureRecorder pictureRecorder = ue.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Colors.blue;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(shadowWidth, shadowWidth,
              size.width - (shadowWidth * 2), size.height - (shadowWidth * 2)),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    /*
    // Add tag circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(size.width - tagWidth, 0.0, tagWidth, tagWidth),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        tagPaint);


    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: count,
      style: TextStyle(fontSize: 20.0, color: Colors.white),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size.width - tagWidth / 2 - textPainter.width / 2,
            tagWidth / 2 - textPainter.height / 2));

     */

    // Oval for the image
    Rect oval = Rect.fromLTWH(imageOffset, imageOffset,
        size.width - (imageOffset * 2), size.height - (imageOffset * 2));

    // Add path for oval image
    canvas.clipPath(Path()..addOval(oval));

    // Add image
    ue.Image images = await loadUiImage(
        imagePath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: images, rect: oval, fit: BoxFit.cover);
    // paintImage()    ;

    // Convert canvas to image
    final ue.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());

    // Convert image to bytes
    final ByteData byteData =
        await markerAsImage.toByteData(format: ue.ImageByteFormat.png);

    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> getMarkerIcon(String imageUrl, Size size,bool resizeImg) async {
    print('img imageUrl ::= $imageUrl');
    
    final File markerImageFile        = await DefaultCacheManager().getSingleFile(imageUrl).catchError((error) async {
      print('img markerImageFile error ::= $error');

      await getBytesFromAsset('assest/images/user2.png', 100).then((onValue) {
        mapIcon =BitmapDescriptor.fromBytes(onValue);

      });
    });
    print('img markerImageFile ::= $markerImageFile');

    final Uint8List data              = await markerImageFile.readAsBytes();

    if(!resizeImg)
        return data;

    IMG.Image img  = IMG.decodeImage(data);
    print("img :: "+markerImageFile.path);
  
    
    final ue.PictureRecorder pictureRecorder = ue.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    //final Radius radius = Radius.circular(size.width / 2);
    final Radius radius = Radius.circular(30);


    final Paint tagPaint = Paint()..color = Colors.blue;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(50.0, 50.0, size.width, size.height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(shadowWidth, shadowWidth,
              size.width - (shadowWidth * 2), size.height - (shadowWidth * 2)),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Oval for the image
    Rect oval = Rect.fromLTWH(imageOffset, imageOffset,
        size.width - (imageOffset * 2), size.height - (imageOffset * 2));

    // Add path for oval image
    canvas.clipPath(Path()..addOval(oval));

    // Add image
    ue.Image images = await loadUiImageCached(img); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: images, rect: oval, fit: BoxFit.cover);
    // paintImage()    ;

    // Convert canvas to image
    final ue.Image markerAsImage = await pictureRecorder
        .endRecording()
       // .toImage(size.width.toInt(), size.height.toInt());
     .toImage(80, 80);


    // Convert image to bytes
    final ByteData byteData =
        await markerAsImage.toByteData(format: ue.ImageByteFormat.png);

    return byteData.buffer.asUint8List();
  }

  //======new  get MakerIcon New  =========
  Future<BitmapDescriptor> createCustomMarkerBitmapWithNameAndImage(
      String imagePath, Size size, String name) async {


   /* TextSpan span = new TextSpan(
        style: new TextStyle(
          height: 1.2,
          color: Colors.black,
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
        text: name);*/

   /* TextPainter tp = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();*/
    final ui.PictureRecorder recorder = ui.PictureRecorder();


    Canvas canvas = new Canvas(recorder);




    final Radius radius = Radius.circular(size.width / 2);

   // final Paint shadowCirclePaint = Paint()..color =Color(Helper.textColorPinkH1).withAlpha(180);//MyTheme.primaryColor.withAlpha(180);

    final Paint shadowPaint = Paint()..color = Colors.white;//Colors.blue.withAlpha(100);
    final double shadowWidth = 2.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 2.0;
    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
   /* canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              size.width / 8, size.width / 2, size.width, size.height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        //shadowCirclePaint
        shadowPaint
    );*/

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(shadowWidth, shadowWidth,
              size.width - (shadowWidth * 2), size.height - (shadowWidth * 2)),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);


    // TEXT BOX BACKGROUND
  //  Paint textBgBoxPaint = Paint()..color = Color(Helper.textColorPinkH1);

    Rect rect = Rect.fromLTWH(
      0,
      0,
      //tp.width + 35,
      50,
      50,
    );

    /*canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(10.0)),
     // textBgBoxPaint,
    );*/

    //ADD TEXT WITH ALIGN TO CANVAS
   // tp.paint(canvas, new Offset(20.0, 5.0));

    /* Do your painting of the custom icon here, including drawing text, shapes, etc. */

   /* Rect oval = Rect.fromLTWH(35, 78, size.width - (imageOffset * 2),
        size.height - (imageOffset * 2));


    // ADD  PATH TO OVAL IMAGE
    canvas.clipPath(Path()..addOval(oval));
*/
    Rect oval = Rect.fromLTWH(imageOffset, imageOffset,
        size.width - (imageOffset * 2), size.height - (imageOffset * 2));

    // Add path for oval image
    canvas.clipPath(Path()..addOval(oval));
    ui.Image image = await getImageFromPath(
        imagePath);
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.cover);

    ui.Picture p = recorder.endRecording();
    ByteData pngBytes = await (await p.toImage(size.width.toInt(), size.height.toInt()))
        .toByteData(format: ui.ImageByteFormat.png);

    Uint8List data = Uint8List.view(pngBytes.buffer);

    return BitmapDescriptor.fromBytes(data);
  }

  Future<ui.Image> getImageFromPath(String imagePath) async {
    File imageFile = File(imagePath);

    Uint8List imageBytes = imageFile.readAsBytesSync();

    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }



  Future<BitmapDescriptor> getMarkerIconNew(String image, String name) async {
    if (image != null) {
      final File markerImageFile =
      await DefaultCacheManager().getSingleFile(image);
      Size s = Size(150, 150);

      var icon = await createCustomMarkerBitmapWithNameAndImage(markerImageFile.path, s, name);

      return icon;
    } else {
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<Uint8List> getMarkerIconToMove(String imageUrl, Size size,bool resizeImg) async {

    final File markerImageFile  = await DefaultCacheManager().getSingleFile(imageUrl);
    final Uint8List data              = await markerImageFile.readAsBytes();

    if(!resizeImg)
      return data;

    IMG.Image img   = IMG.decodeImage(data);
    print("img :: "+markerImageFile.path);


    final ue.PictureRecorder pictureRecorder = ue.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(5);

    final Paint tagPaint = Paint()..color = Colors.blue;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
    final double shadowWidth = 25.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 15.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(shadowWidth, shadowWidth,
              size.width - (shadowWidth * 6), size.height - (shadowWidth * 6)),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Oval for the image
    Rect oval = Rect.fromLTWH(imageOffset, imageOffset,
        size.width - (imageOffset * 2), size.height - (imageOffset * 2));

    // Add path for oval image
    canvas.clipPath(Path()..addOval(oval));

    // Add image
    ue.Image images = await loadUiImageCached(img); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: images, rect: oval, fit: BoxFit.cover,scale: 1.0);
    // paintImage()    ;

    // Convert canvas to image
    final ue.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(400,400);

    // Convert image to bytes
    final ByteData byteData =
    await markerAsImage.toByteData(format: ue.ImageByteFormat.png);

    return byteData.buffer.asUint8List();
  }


  Future<ue.Image> loadUiImageCached(IMG.Image resized) async {
    final Completer<ue.Image> completer = Completer();

    ue.decodeImageFromList(IMG.encodeJpg(resized), (ue.Image img) {
        return completer.complete(img);
    });
    // ue.decodeImageFromList(response.bodyBytes, (ue.Image img) {
    //   return completer.complete(img);
    // });
    return completer.future;
    
  }

  Future<ue.Image> loadUiImage(String imageAssetPath) async {
    //  NetworkAssetBundle networkAssetBundle = NetworkAssetBundle(Uri.parse(imageAssetPath));
    var response = await https.get(Uri.parse(imageAssetPath));

    // final ByteData data = await networkAssetBundle.load(imageAssetPath);
    //  final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ue.Image> completer = Completer();
    ue.decodeImageFromList(response.bodyBytes, (ue.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget getlistchatItem(int index, Chat nDataList) {
    return index % 2 == 0
        ? InkWell(
            onTap: () {
              if (action == Action.Activity) {
                Navigator.pushNamed(context, Constant.ChatUserDetail,
                    arguments: {"user_id": nDataList.user_id, "type": "1"});
                //     .then((value) {
                //   _showProgress(context);
                //   _chatItemList();
                // });
              } else if (action == Action.Professional) {
                Navigator.pushNamed(context, Constant.ChatUserDetail,
                    arguments: {"user_id": nDataList.user_id, "type": "2"});
                //     .then((value) {
                //   _showProgress(context);
                //   _professionItemList();
                // });
              }
            },
            child: Container(
                 width: double.infinity,
                margin : EdgeInsets.only(left:5, right:5,top:10,bottom:10),
                child : ClipShadowPath(
                clipper: ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(10)))),
                shadow: BoxShadow(
                  color: Color(0xffacacac),
                  offset: Offset(1.0, 1.0), //(x,y)
                  blurRadius: 15.0,
                ),
                child:Stack (
              children : [
              Container(
              decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffe4e9ef),
                        offset: Offset(1.0, 1.0), //(x,y)
                        blurRadius: 100.0,
                      ),
                    ],
                    border: Border(
                      bottom: BorderSide(
                          width: 8.0, color: Color(0xff1b98ea)),
                    )),
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child:                           
                          Container(
                                width: 80,
                                height : 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    child: nDataList.profile_img != null
                                        ? Image.network(
                                            nDataList.profile_img,
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height:80,
                                          )
                                        : Container()),
                          ),
                    ),
                  )
                  ,
                
                  IntrinsicWidth(child : Container(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxHeight: 180,minWidth: 140, minHeight: 135),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 5, top: 0, right: 0, bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomWigdet.TextView(
                                      text: nDataList.name,
                                      overflow: false,
                                      color: Color(0xff217fc5),
                                      fontSize: Helper.textSizeH11,
                                      fontFamily: "Kelvetica Nobis",
                                    ),
                                  ),
                                ],
                              ),
                              !UtilMethod.isStringNullOrBlank(nDataList.city)
                                  ? CustomWigdet.TextView(
                                      text: nDataList.city,
                                      color: Custom_color.BlackTextColor)
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.only(right: 140.0),
                                child: Divider(
                                  thickness: 1.5,
                                  color: Color(0xfffa4491),
                                ),
                              ),
                              !UtilMethod.isStringNullOrBlank(
                                      nDataList.prof_interest)
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Color(0xffacacac),
                                          radius: 11.0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Image.asset(
                                              "assest/images/proffesional.png",
                                              color: Colors.white,
                                              width: 12,
                                              height: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 9),
                                        Expanded(
                                          child: CustomWigdet.TextView(
                                            overflow: true,
                                            fontSize: 13,
                                            text: nDataList.prof_interest ==
                                                    "Other"
                                                ? "No professional interest"
                                                : nDataList.prof_interest,
                                            color: Custom_color.BlackTextColor,
                                          ),
                                        )
                                      ],
                                    )
                                  : Container(),
                              SizedBox(height: 5.0),
                              !UtilMethod.isStringNullOrBlank(
                                      nDataList.gender_interest.toString())
                                  ? Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 11.0,
                                          backgroundColor: Color(0xffacacac),
                                          child: Image.asset(
                                            "assest/images/gender.png",
                                            color: Custom_color.WhiteColor,
                                            width: 12,
                                            height: 12,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 9,
                                        ),
                                        CustomWigdet.TextView(
                                          overflow: true,
                                          fontSize: 12,
                                          text: _getInterestSecond(
                                              nDataList.gender_interest),
                                          color: Custom_color.BlackTextColor,
                                        )
                                      ],
                                    )
                                  : Container(),
                              SizedBox(height: 5.0),
                              nDataList.activity_holder != null &&
                                      nDataList.activity_holder.isNotEmpty
                                  ? Column (
                                    children : [
                                      Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 11.0,
                                          backgroundColor: Color(0xffacacac),
                                          child: Image.asset(
                                            "assest/images/interest.png",
                                            color: Custom_color.WhiteColor,
                                            width: 12,
                                            height: 12,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 9,
                                        ),
                                        Container(
                                           constraints: BoxConstraints(maxWidth: 150),
                                              child : Text(
                                                _getListactiviyitem(
                                                nDataList.activity_holder),
                                                overflow: TextOverflow.clip,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.normal,
                                                    fontFamily: "OpenSans Regular",
                                                    color: Custom_color.BlackTextColor),
                                              )
                                            ),
                                      ],
                                    ),Container(width:maxActivityWidth)])
                                  : Container(width:maxActivityWidth),
                              SizedBox(height: 5.0)
                            ],
                          ),
                        ),
                      ),
                    )),
                ],
              ),
            ),
            Positioned(
                      top: 10,
                      right: 5,
                      child :
                    InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          if (await UtilMethod
                              .SimpleCheckInternetConnection(
                                  context, _scaffoldKey)) {
                            _GetLikeUser(nDataList);
                          }
                        },
                        child: nDataList.you_liked == 0 &&
                                nDataList.liked_you == 0
                            ? Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xffa6a6a6),
                                        Color(0xffe0e0e0)
                                      ],
                                      end: Alignment.topCenter,
                                      begin:
                                          Alignment.bottomCenter,
                                      tileMode: TileMode.clamp,
                                    )),
                                child: CircleAvatar(
                                  backgroundColor:
                                      Colors.transparent,
                                  radius: 13,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        Custom_color.WhiteColor,
                                    child: RadiantGradientMask(
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : nDataList.you_liked == 1 &&
                                    nDataList.liked_you == 0
                                ? Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xfffa2985),
                                            Color(0xfffe98bf)
                                          ],
                                          end:
                                              Alignment.topCenter,
                                          begin: Alignment
                                              .bottomCenter,
                                          tileMode:
                                              TileMode.clamp,
                                        )),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Colors.transparent,
                                      radius: 13.5,
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor:
                                            Colors.transparent,
                                        child: Icon(
                                          Icons.favorite,
                                          color: Custom_color
                                              .WhiteColor,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  )
                                : nDataList.you_liked == 0 &&
                                        nDataList.liked_you == 1
                                    ? Container(
                                        decoration: BoxDecoration(
                                            shape:
                                                BoxShape.circle,
                                            gradient:
                                                LinearGradient(
                                              colors: [
                                                Color(0xffa6a6a6),
                                                Color(0xffe0e0e0)
                                              ],
                                              end: Alignment
                                                  .topCenter,
                                              begin: Alignment
                                                  .bottomCenter,
                                              tileMode:
                                                  TileMode.clamp,
                                            )),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Colors.transparent,
                                          radius: 13,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor:
                                                Custom_color
                                                    .WhiteColor,
                                            child:
                                                RadiantGradientMask(
                                              child: Icon(
                                                Icons.favorite,
                                                color:
                                                    Colors.white,
                                                size: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : nDataList.you_liked == 1 &&
                                            nDataList.liked_you ==
                                                1
                                        ? Container(
                                            decoration:
                                                BoxDecoration(
                                                    shape: BoxShape
                                                        .circle,
                                                    gradient:
                                                        LinearGradient(
                                                      colors: [
                                                        Color(
                                                            0xfffa2985),
                                                        Color(
                                                            0xfffe98bf)
                                                      ],
                                                      end: Alignment
                                                          .topCenter,
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      tileMode:
                                                          TileMode
                                                              .clamp,
                                                    )),
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Colors
                                                      .transparent,
                                              radius: 13.5,
                                              child: CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    Colors
                                                        .transparent,
                                                child: Icon(
                                                  Icons.favorite,
                                                  color: Custom_color
                                                      .WhiteColor,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          )
                          : Container()))
                                
                   
          ])
        ), //TODO : idhar home page wala  container khatam hai
                )
          )
        : InkWell(
            onTap: () {
              if (action == Action.Activity) {
                Navigator.pushNamed(context, Constant.ChatUserDetail,
                    arguments: {"user_id": nDataList.user_id, "type": "1"});
                //     .then((value) {
                //   _showProgress(context);
                //   _chatItemList();
                // }
                // );
              } else if (action == Action.Professional) {
                Navigator.pushNamed(context, Constant.ChatUserDetail,
                    arguments: {"user_id": nDataList.user_id, "type": "2"});
                //     .then((value) {
                //   _showProgress(context);
                //   _professionItemList();
                // });
              }
            },
            child: false?Container(
                margin : EdgeInsets.fromLTRB(15, 10, 15, 10),
                child : ClipShadowPath(
                clipper: ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(10)))),
                shadow: BoxShadow(
                  color: Color(0xffacacac),
                  offset: Offset(1.0, 1.0), //(x,y)
                  blurRadius: 15.0,
                ),
                child: Stack(
                  children : [
                  Container(
                    decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffe4e9ef),
                        offset: Offset(1.0, 1.0), //(x,y)
                        blurRadius: 100.0,
                      ),
                    ],
                    border: Border(
                      bottom: BorderSide(
                          width: 8.0, color: Color(0xff1b98ea)),
                    )),
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child:                           
                          Container(
                                width: 85,
                                height : 95,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    child: nDataList.profile_img != null
                                        ? Image.network(
                                            nDataList.profile_img,
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height:90,
                                          )
                                        : Container()),
                          ),
                    ),
                  )
                  ,
                  Stack(
                  
                  alignment: Alignment.center,
                      clipBehavior: Clip.none,
                  children : [
                    IntrinsicWidth(child: Container(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: 200, maxWidth: 310, minHeight: 155),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 0, right: 0, bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomWigdet.TextView(
                                      text: nDataList.name,
                                      overflow: false,
                                      color: Color(0xff217fc5),
                                      fontSize: 18,
                                      fontFamily: "Kelvetica Nobis",
                                    ),
                                  ),
                                ],
                              ),
                              !UtilMethod.isStringNullOrBlank(nDataList.city)
                                  ? CustomWigdet.TextView(
                                      text: nDataList.city,
                                      color: Custom_color.BlackTextColor)
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.only(right: 140.0),
                                child: Divider(
                                  thickness: 1.5,
                                  color: Color(0xfffa4491),
                                ),
                              ),
                              !UtilMethod.isStringNullOrBlank(
                                      nDataList.prof_interest)
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Color(0xffacacac),
                                          radius: 11.0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Image.asset(
                                              "assest/images/proffesional.png",
                                              color: Colors.white,
                                              width: 12,
                                              height: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 9),
                                        Expanded(
                                          child: CustomWigdet.TextView(
                                            overflow: true,
                                            fontSize: 13,
                                            text: nDataList.prof_interest ==
                                                    "Other"
                                                ? "No professional interest"
                                                : nDataList.prof_interest,
                                            color: Custom_color.BlackTextColor,
                                          ),
                                        )
                                      ],
                                    )
                                  : Container(),
                              SizedBox(height: 5.0),
                              !UtilMethod.isStringNullOrBlank(
                                      nDataList.gender_interest.toString())
                                  ? Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 11.0,
                                          backgroundColor: Color(0xffacacac),
                                          child: Image.asset(
                                            "assest/images/gender.png",
                                            color: Custom_color.WhiteColor,
                                            width: 12,
                                            height: 12,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 9,
                                        ),
                                        CustomWigdet.TextView(
                                          overflow: true,
                                          fontSize: 12,
                                          text: _getInterestSecond(
                                              nDataList.gender_interest),
                                          color: Custom_color.BlackTextColor,
                                        )
                                      ],
                                    )
                                  : Container(),
                              SizedBox(height: 5.0),
                              nDataList.activity_holder != null &&
                                      nDataList.activity_holder.isNotEmpty
                                  ? Column (
                                    children : [
                                      Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 11.0,
                                          backgroundColor: Color(0xffacacac),
                                          child: Image.asset(
                                            "assest/images/interest.png",
                                            color: Custom_color.WhiteColor,
                                            width: 12,
                                            height: 12,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 9,
                                        ),
                                        Container(
                                            constraints: BoxConstraints(maxWidth: 150),
                                              child : Text(
                                                _getListactiviyitem(
                                                nDataList.activity_holder),
                                                overflow: TextOverflow.clip,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.normal,
                                                    fontFamily: "OpenSans Regular",
                                                    color: Custom_color.BlackTextColor),
                                              )
                                              ),
                                      ],
                                    ),Container(width:maxActivityWidth) ])
                                  : Container(width:maxActivityWidth),
                              SizedBox(height: 5.0)
                            ],
                          ),
                        ),
                      ),
                    ),
                    ),
                              
                ]),
                ],
              ),
            )
            ,
            Positioned(
                      top: 10,
                      right : 5,
                      child :InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () async {
                                        if (await UtilMethod
                                            .SimpleCheckInternetConnection(
                                                context, _scaffoldKey)) {
                                          _GetLikeUser(nDataList);
                                        }
                                      },
                                      child: nDataList.you_liked == 0 &&
                                              nDataList.liked_you == 0
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xffa6a6a6),
                                                      Color(0xffe0e0e0)
                                                    ],
                                                    end: Alignment.topCenter,
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    tileMode: TileMode.clamp,
                                                  )),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                radius: 13,
                                                child: CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      Custom_color.WhiteColor,
                                                  child: RadiantGradientMask(
                                                    child: Icon(
                                                      Icons.favorite,
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : nDataList.you_liked == 1 &&
                                                  nDataList.liked_you == 0
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xfffa2985),
                                                          Color(0xfffe98bf)
                                                        ],
                                                        end:
                                                            Alignment.topCenter,
                                                        begin: Alignment
                                                            .bottomCenter,
                                                        tileMode:
                                                            TileMode.clamp,
                                                      )),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    radius: 13.5,
                                                    child: CircleAvatar(
                                                      radius: 12,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      child: Icon(
                                                        Icons.favorite,
                                                        color: Custom_color
                                                            .WhiteColor,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : nDataList.you_liked == 0 &&
                                                      nDataList.liked_you == 1
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xffa6a6a6),
                                                              Color(0xffe0e0e0)
                                                            ],
                                                            end: Alignment
                                                                .topCenter,
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            tileMode:
                                                                TileMode.clamp,
                                                          )),
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        radius: 13,
                                                        child: CircleAvatar(
                                                          radius: 12,
                                                          backgroundColor:
                                                              Custom_color
                                                                  .WhiteColor,
                                                          child:
                                                              RadiantGradientMask(
                                                            child: Icon(
                                                              Icons.favorite,
                                                              color:
                                                                  Colors.white,
                                                              size: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : nDataList.you_liked == 1 &&
                                                          nDataList.liked_you ==
                                                              1
                                                      ? Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      Color(
                                                                          0xfffa2985),
                                                                      Color(
                                                                          0xfffe98bf)
                                                                    ],
                                                                    end: Alignment
                                                                        .topCenter,
                                                                    begin: Alignment
                                                                        .bottomCenter,
                                                                    tileMode:
                                                                        TileMode
                                                                            .clamp,
                                                                  )),
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            radius: 13.5,
                                                            child: CircleAvatar(
                                                              radius: 12,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              child: Icon(
                                                                Icons.favorite,
                                                                color: Custom_color
                                                                    .WhiteColor,
                                                                size: 15,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                    : Container()))
                
            ]),
            
            )
          ):Container()
            
          );
  }

  Widget getlistchatItem2(int index, Activity_User_Holder nDataList) {
    print("-------list-------" + nDataList.categroy_holder.toList().toString());
    return index % 2 == 0
        ? InkWell(
            onTap: () {
              Navigator.pushNamed(context, Constant.ActivityUserDetail,
                  arguments: {
                    "event_id": nDataList.event_id,
                    "isSub": nDataList.is_subs
                  });
            },
            child: Container(
              padding: EdgeInsets.only(top: 3),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: ClipShadowPath(
                      clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      shadow: BoxShadow(
                        color: Color(0xffe4e9ef),
                        offset: Offset(1.0, 1.0), //(x,y)
                        blurRadius: 15.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                  width: 8.0, color: Color(0xff1b98ea)),
                            )),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: 310, maxHeight: 175),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 110, top: 20, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: CustomWigdet.TextView(
                                          text: nDataList.title,
                                          overflow: false,
                                          color: Color(0xff217fc5),
                                          fontSize: 20,
                                          fontFamily: "Kelvetica Nobis"),
                                    ),
                                    Icon(
                                      nDataList.is_subs == 0
                                          ? Icons.check
                                          : Icons.done_all,
                                      size: 20,
                                      color: nDataList.is_subs == 0
                                          ? Custom_color.GreyLightColor
                                          : Color(0xfff73d90),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 140.0, top: 3, bottom: 3),
                                  child: Divider(
                                      thickness: 1, color: Color(0xfff73d90)),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 11,
                                      backgroundColor: Color(0xffacacac),
                                      child: Image.asset(
                                        "assest/images/pin2.png",
                                        color: Custom_color.WhiteColor,
                                        width: 14,
                                        height: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: CustomWigdet.TextView(
                                          overflow: true,
                                          fontSize: 11,
                                          text: nDataList.location,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
//                                CustomWigdet.TextView(
//                                    text: nDataList.interest,
//                                    color: Custom_color.GreyLightColor,
//                                    fontFamily: "OpenSans Bold"),
                                !UtilMethod.isStringNullOrBlank(
                                        nDataList.start_time)
                                    ? Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 11,
                                            backgroundColor: Color(0xffacacac),
                                            child: Image.asset(
                                              "assest/images/calendar.png",
                                              color: Custom_color.WhiteColor,
                                              width: 14,
                                              height: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          CustomWigdet.TextView(
                                              fontSize: 11,
                                              text: nDataList.start_time,
                                              color: Colors.black),
                                        ],
                                      )
                                    : Container(),
                                nDataList.categroy_holder != null &&
                                        nDataList.categroy_holder.isNotEmpty
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 1.0),
                                              child: CircleAvatar(
                                                radius: 11,
                                                backgroundColor:
                                                    Color(0xffacacac),
                                                child: Image.asset(
                                                  "assest/images/interest.png",
                                                  color:
                                                      Custom_color.WhiteColor,
                                                  width: 14,
                                                  height: 14,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: CustomWigdet.TextView(
                                                fontSize: 11,
                                                overflow: true,
                                                text: _getListcategroyitem(
                                                    nDataList.categroy_holder),
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, top: 4),
                                    child: InkWell(
                                        onTap: () async {
                                          if (await UtilMethod
                                              .SimpleCheckInternetConnection(
                                                  context, _scaffoldKey)) {
                                            print("----isSubs-----" +
                                                nDataList.is_subs.toString());
                                            String value = "";
                                            if (nDataList.is_subs == 1) {
                                              value = "0";
                                              print("----0000000000--------");
                                            } else {
                                              value = "1";
                                              print(
                                                  "----------11111111--------");
                                            }
                                            _GetSubscribe(
                                                nDataList.event_id, value);
                                          }
                                        },
                                        child: Icon(
                                          nDataList.is_subs == 0
                                              ? Icons.check
                                              : Icons.done_all,
                                          size: 20,
                                          color: nDataList.is_subs == 0
                                              ? Custom_color.WhiteColor
                                              : Color(0xffffffff),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    left: 35,
                    top: -30,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          nDataList.image != null
                              ? Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0, 7),
                                          blurRadius: 15)
                                    ],
                                  ),
                                  width: 70,
                                  height: 10,
                                )
                              : Container(),
                          ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 90, maxHeight: 100,minWidth: 50, minHeight: 60),
                            child : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    child: nDataList.image != null
                                        ? Image.network(
                                            nDataList.image,
                                            fit: BoxFit.cover,
                                          )
                                        : Container()),
                          )),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : InkWell(
            onTap: () {
              Navigator.pushNamed(context, Constant.ActivityUserDetail,
                  arguments: {
                    "event_id": nDataList.event_id,
                    "isSub": nDataList.is_subs
                  });
            },
            child: Container(
              padding: EdgeInsets.only(top: 3),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: ClipShadowPath(
                      clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      shadow: BoxShadow(
                        color: Color(0xffe4e9ef),
                        offset: Offset(1.0, 1.0), //(x,y)
                        blurRadius: 15.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                  width: 8.0, color: Color(0xff1b98ea)),
                            )),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: 310, maxHeight: 175),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 110, top: 20, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomWigdet.TextView(
                                        text: nDataList.title,
                                        overflow: false,
                                        color: Color(0xff217fc5),
                                        fontSize: 20,
                                        fontFamily: "Kelvetica Nobis"),
                                    Icon(
                                      nDataList.is_subs == 0
                                          ? Icons.check
                                          : Icons.done_all,
                                      size: 20,
                                      color: nDataList.is_subs == 0
                                          ? Custom_color.GreyLightColor
                                          : Color(0xfff73d90),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 140.0, top: 3, bottom: 3),
                                  child: Divider(
                                      thickness: 1, color: Color(0xfff73d90)),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 11,
                                      backgroundColor: Color(0xffacacac),
                                      child: Image.asset(
                                        "assest/images/pin2.png",
                                        color: Custom_color.WhiteColor,
                                        width: 14,
                                        height: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: CustomWigdet.TextView(
                                          overflow: true,
                                          fontSize: 11,
                                          text: nDataList.location,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
//                                CustomWigdet.TextView(
//                                    text: nDataList.interest,
//                                    color: Custom_color.GreyLightColor,
//                                    fontFamily: "OpenSans Bold"),
                                !UtilMethod.isStringNullOrBlank(
                                        nDataList.start_time)
                                    ? Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 11,
                                            backgroundColor: Color(0xffacacac),
                                            child: Image.asset(
                                              "assest/images/calendar.png",
                                              color: Custom_color.WhiteColor,
                                              width: 14,
                                              height: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          CustomWigdet.TextView(
                                              fontSize: 11,
                                              text: nDataList.start_time,
                                              color: Colors.black),
                                        ],
                                      )
                                    : Container(),
                                nDataList.categroy_holder != null &&
                                        nDataList.categroy_holder.isNotEmpty
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 1.0),
                                              child: CircleAvatar(
                                                radius: 11,
                                                backgroundColor:
                                                    Color(0xffacacac),
                                                child: Image.asset(
                                                  "assest/images/interest.png",
                                                  color:
                                                      Custom_color.WhiteColor,
                                                  width: 14,
                                                  height: 14,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: CustomWigdet.TextView(
                                                fontSize: 11,
                                                overflow: true,
                                                text: _getListcategroyitem(
                                                    nDataList.categroy_holder),
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, top: 4),
                                    child: InkWell(
                                        onTap: () async {
                                          if (await UtilMethod
                                              .SimpleCheckInternetConnection(
                                                  context, _scaffoldKey)) {
                                            print("----isSubs-----" +
                                                nDataList.is_subs.toString());
                                            String value = "";
                                            if (nDataList.is_subs == 1) {
                                              value = "0";
                                              print("----0000000000--------");
                                            } else {
                                              value = "1";
                                              print(
                                                  "----------11111111--------");
                                            }
                                            _GetSubscribe(
                                                nDataList.event_id, value);
                                          }
                                        },
                                        child: Icon(
                                          nDataList.is_subs == 0
                                              ? Icons.check
                                              : Icons.done_all,
                                          size: 20,
                                          color: nDataList.is_subs == 0
                                              ? Custom_color.WhiteColor
                                              : Color(0xffffffff),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: -30,
                    left: 35,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          nDataList.image != null
                              ? Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0, 7),
                                          blurRadius: 15)
                                    ],
                                  ),
                                  width: 70,
                                  height: 10,
                                )
                              : Container(),
                          Container(
                            // color: Colors.white,
                            width: 90,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                child: nDataList.image != null
                                    ? Image.network(
                                        nDataList.image,
                                        fit: BoxFit.cover,
                                      )
                                    : Container()),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  _updateGPSLocation(reloadList) async {
    try {
      print("-----homepage---11111-----");
      _currentLocation = await _locationService.getLocation();

      print("-----homepage---2222-----");

      List<Placemark> placemark = await placemarkFromCoordinates(
          getPoint(true), getPoint(false));
      print("-----homepage---33333-----");

      Placemark placeMark = placemark[0];
//    String subLocality = placeMark.subLocality;
      String subAdministrativeArea = placeMark.subAdministrativeArea;
      String administrativeArea = placeMark.administrativeArea;
      String country = placeMark.country;
//      isocountry = placeMark.isoCountryCode;
      //    print("-------loction addresss-------" + placemark[0].toJson().toString());

      Map jsondata = {
        "city": administrativeArea,
        "state": subAdministrativeArea,
        "country": country,
        "latitude": getPoint(true).toString(),
        "longitude": getPoint(false).toString()
      };
      print("-----jsondata-------" + jsondata.toString());

      String url = WebServices.UpdateUserLocation + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("Home page _updateGPSLocation url=" +url);

      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      // _hideProgress();
       print("respnse----" + response.body);
      if (response.statusCode == 200 && reloadList) {
        // var data = json.decode(response.body);
        _chatItemList();
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  String _getListactiviyitem(List<Activity> list) {
    
    StringBuffer value = new StringBuffer();
    List<Activity>.generate(list.length, (index) {
      //  if (list[index].percent > 0)
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

  String _getListcategroyitem(List<Category> list) {
    StringBuffer value = new StringBuffer();
    List<Category>.generate(list.length, (index) {
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

//  Set<Marker> _currentMarker() {
//    _markers.clear();
//    if (allUserMarker != null && allUserMarker.length > 0) {
//      for (var i = 0; i < allUserMarker.length; i++) {
//        //setCustomMapPin(i);
//        var now = new DateTime.now().millisecondsSinceEpoch;
////        _markers.add(Marker(
////            markerId:
////            MarkerId(allUserMarker[i].toString() + now.toString()),
////            position: allUserMarker[i],
//////            infoWindow: InfoWindow(
//////              title: 'This is a Title  $i',
//////              snippet: 'This is a snippet $i',
//////            ),
////            icon: BitmapDescriptor.defaultMarker));
//
//
//        return <Marker>[
//          Marker(
//              markerId: MarkerId(allUserMarker[i].toString() + now.toString()),
//              position: allUserMarker[i],
//              icon: BitmapDescriptor.defaultMarker),
//        ].toSet();
//      }
//    }
//  }

  Future<List<Chat>> _chatItemListApllyFilter(Map jsondata) {
          Constant.filterData   = jsondata;
          return _chatItemList();
  }


  Future<List<Chat>> _chatItemList() async {
  
    try {

      // if(isProcessing)
      //      return chat_list_match;
           
      action = Action.Activity;
      String latitude = "";
      String longitude = "";
      try{

        latitude = getPoint(true).toString();

      }catch(e){
        print('latitude error=$e');
      }
      try{
        longitude = getPoint(false).toString();
      }catch(e){}
      print('_chatItemList ####  latitude=$latitude\t\t # longitude=$longitude');
      String index = '';
      String shavalue = '';
      try{ index = calledIndex[toggle].toString();
      }catch(e){
        print('latitude error=$e');
      }
      try{ shavalue = sha[toggle].toString();}catch(e){}
      String url = WebServices.GetPeople + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}&latitude="+latitude+"&longitude="+longitude+"&tab="+toggle.toString()+"&currindex="+index+"&sha="+shavalue;
      print("---Url----" + url.toString());
      print("_chatItemList ####  Url=$url");

      https.Response response = await https.post(Uri.parse(url),
          body: Constant.filterData,
          encoding: Encoding.getByName("utf-8"),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      if (response.statusCode == 200) {
        print("_chatItemList ####  response.body=${response.body}");
        try{ calledIndex[toggle] = calledIndex[toggle] < 500 ? calledIndex[toggle]+1 : calledIndex[toggle];}
        catch(e){
          print('** e=$e');
        }
        bool reload = false;
        
        prevChatResponse= response.body;
        print("SHA :: "+prevChatResponse);
        var data = json.decode(response.body);
        try
        {
            if(sha[toggle] != data['sha'].toString()) {
              reload = true;
            }
        }
        catch(e){reload       = true;}
            
        sha[toggle]  = data['sha'].toString();
        print('_chatItemList #### data["sha"].toString()=${data['sha'].toString()}');
        
        

        if(!reload)
          return chat_list_match;


        
        try{resize[toggle]   = data['resize'].toString().toLowerCase() == "true";}catch(e3){}
        try{useAssetImg[toggle] = data['useasset'].toString().toLowerCase() == "true";}catch(e3){}

        print("SHA22 :: "+data['useasset'].toString()+" -- "+useAssetImg[toggle].toString());
        if (chat_list_match != null && chat_list_match.isNotEmpty) {
          chat_list_match.clear();
        }
        var count = data["chatcount"];
        if (count != null) {
          //  SessionManager.setString(Constant.ChatCount, count.toString());
          UtilMethod.SetChatCount(context, count.toString());
        }
        var distance = data["distance_unit"];
        if (distance != null) {
          SessionManager.setString(Constant.Distance, distance.toString());
        }
        var notificationCount = data["notification_count"];
        if (notificationCount != null) {
          //  SessionManager.setString(Constant.NotificationCount, notification_count.toString());
          UtilMethod.SetNotificationCount(
              context, notificationCount.toString());
        }
        if (data["status"]) {
          List datitemmatch = data["data"];

          print(data["data"].toString());
          print('_chatItemList ### data["data"].toString()=${data["data"].toString()}');
          print('_chatItemList ### response.body.length=${response.body.length}');
          print('_chatItemList ### response.body.length=$response');

         // FlutterToastAlert.flutterToastMSG('_chatItemList ==>Success[${data["data"]}]', context);

          if (datitemmatch != null && datitemmatch.isNotEmpty) {
            chat_list_match = datitemmatch.map<Chat>((i) => Chat.fromJson(i)).toList();
          }


           if(mounted) {
             setState(() {
          _listVisible = true;
          _visible = true;
            });
           }

        } else {
          //  setState(() {
          _listVisible = false;
          //  });
          messages = data["message"].toString();
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }
        }


           if (mounted) {
             setState(() {
            _visible = true;
            _hideProgress();

            for (int i = 0; i < isSelected.length; i++) {
              isSelected[i] = i == 1;
            }
          });
           }

         //=========== old method _updateIntialMaps =============
        //_updateIntialMaps(0);
        //=========== new method _updateIntialMaps =============
        _updateIntialMaps(0,0);

      }

      return chat_list_match;
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future<List<Chat>> _professionItemList() async {
    try {
      action = Action.Professional;
     

      String url = WebServices.GetProfessionalUser +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("---Url----" + url.toString());
      https.Response response = await https.post(Uri.parse(url),
          body: Constant.filterData,
          encoding: Encoding.getByName("utf-8"),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      if (response.statusCode == 200) {
        bool reload = false;
        if(prevProfResponse != null)
        {
            if(prevProfResponse != response.body) {
              reload = true;
            }
        }
        else {
          reload= true;
        }
        prevProfResponse      = response.body;
        var data              = json.decode(response.body);

        print("reloadNeeded 3 :: "+reload.toString());
        if(!reload) {
          return chat_list_match;
        }

        if (chat_list_match != null && chat_list_match.isNotEmpty) {
          chat_list_match.clear();
        }
        var count = data["chatcount"];
        if (count != null) {
          //   SessionManager.setString(Constant.ChatCount, count.toString());
          UtilMethod.SetChatCount(context, count.toString());
        }
        var distance = data["distance_unit"];
        if (distance != null) {
          SessionManager.setString(Constant.Distance, distance.toString());
        }

        var notificationCount = data["notification_count"];
        if (notificationCount != null) {
          //    SessionManager.setString(Constant.NotificationCount, notification_count.toString());
          UtilMethod.SetNotificationCount(
              context, notificationCount.toString());
        }
        if (data["status"]) {
          List datitemmatch = data["data"];

          if (datitemmatch != null && datitemmatch.isNotEmpty) {
            chat_list_match = datitemmatch.map<Chat>((i) => Chat.fromJson(i)).toList();
          }
          //  setState(() {

          if(mounted) {
            setState(() {
            _listVisible = true;
            _visible=true;
          });
          }

          //   });
        } else {
          setState(() {
            _listVisible = false;
          });
          messages = data["message"].toString();
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
          _hideProgress();
          //================ Tab change Selected ==
          /*for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = i == 2;
          }*/
        });
        }
        //=========== old method _updateIntialMaps =============
       // _updateIntialMaps(2);

        //=========== new method _updateIntialMaps =============
        _updateIntialMaps(2,0);
      }

      return chat_list_match;
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future<List<Chat>> _professionItemListFilter(Map jsondata) async {
          Constant.filterData      = jsondata;
          return _professionItemList();
  }

  
  Future<List<Activity_User_Holder>> _activityItemList() async {
    try {
      action = Action.People;
      String latitude = "";
      String longitude = "";
      try{ latitude = getPoint(true).toString();}catch(e){}
      try{ longitude = getPoint(false).toString();}catch(e){}

      String url = WebServices.GetUserActivity +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}&latitude="+latitude+"&longitude="+longitude;
      print("---Url----" + url.toString());
      https.Response response = await https.post(Uri.parse(url),
          body: Constant.filterData,
          encoding: Encoding.getByName("utf-8"),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      if (response.statusCode == 200) {
        bool reload         = false;
        if(prevActResponse != null)
        {
            if(prevActResponse != response.body)
                reload = true;
        }
        else
            reload            = true;
        print(prevActResponse);
        print("reloadNeeded 5 :: "+response.body);
        prevActResponse       = response.body;
        var data              = json.decode(response.body);
        print("reloadNeeded 5 :: "+reload.toString());
        if(!reload)
          return activity_list;


        if (activity_list != null && activity_list.isNotEmpty) {
          activity_list.clear();
        }
        if (data["status"]) {
          var datitem = data["data"];
          var distance = data["distance_unit"];
            try {
              if (distance != null) {
                SessionManager.setString(
                    Constant.Distance, distance.toString());
              }
            }catch(error){
              print('_activityItemList ### distance error=${error}');
            }
          print('_activityItemList ### data["data"].toString()=${data["data"].toString()}');
          print('_activityItemList ### response.body.length=${response.body.length}');

          activity_list = datitem
              .map<Activity_User_Holder>(
                  (i) => Activity_User_Holder.fromJson(i))
              .toList();
         // FlutterToastAlert.flutterToastMSG('_activityItemList ==>Success[${data["data"]}]', context);

          if(mounted) {
            setState(() {
            _listVisible = true;
            _visible=true;
          });
          }
        } else {
          setState(() {
            _listVisible = false;
          });
          messages = data["message"].toString();
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message: AppLocalizations.of(context).translate("Token Expire"));
          }
        }
        if(mounted) {
          setState(() {
          _visible = true;
          _hideProgress();

          for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = i == 0;
          }
        });
        }
        //=========== old method _updateIntialMaps =============
        // _updateIntialMaps(1);
        //=========== new method _updateIntialMaps =============
        _updateIntialMaps(1,0);
      }

      return activity_list;
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();

    }
  }

  Future<List<Activity_User_Holder>> _activityItemApplyFilterList(Map jsondata) async {
            Constant.filterData      = jsondata;
            return _activityItemList();
  }


  Future<List<Activity_User_Holder>> _activityItemApplyFilterListOld(Map jsondata) async {
    try {
      action = Action.People;
      

      String url = WebServices.GetUserActivity +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      https.Response response = await https.post(Uri.parse(url),
          body: jsondata,
          encoding: Encoding.getByName("utf-8"),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});

      _hideProgress();
      if (response.statusCode == 200) {

        bool reload         = false;
        if(prevActResponseFilter != null)
        {
            if(prevActResponseFilter != response.body)
                reload = true;
        }
        else
            reload            = true;
        prevActResponseFilter      = response.body;
        var data = json.decode(response.body);
        print("reloadNeeded 6 :: "+reload.toString());
        if(!reload)
          return activity_list;

        if (activity_list != null && activity_list.isNotEmpty) {
          activity_list.clear();
        }
        
        if (data["status"]) {
          var datitem = data["data"];
          var distance = data["distance_unit"];
          if (distance != null) {
            SessionManager.setString(Constant.Distance, distance.toString());
          }
          activity_list = datitem
              .map<Activity_User_Holder>(
                  (i) => Activity_User_Holder.fromJson(i))
              .toList();
          setState(() {
            _listVisible = true;
          });
        } else {
          setState(() {
            _listVisible = false;
          });
          messages = data["message"].toString();
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
          for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = i == 0;
          }
        });
        //=========== new method _updateIntialMaps =============
        // _updateIntialMaps(0);
        //=========== new method _updateIntialMaps =============
        _updateIntialMaps(0,0);
      }

      return activity_list;
    } on Exception catch (e) {
      print(e.toString());
    }
  }


  Future<List<Chat>> _chatItemListApllyFilterOld(Map jsondata) async {
    try {
      action = Action.Activity;
      
      String url = WebServices.GetPeople +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}"+"&tab="+toggle.toString();
      print("---Url-11---" + url.toString());
      print("String = " + jsondata.toString());
      //  var response = await https.post(url,
      //   body: jsondata, encoding: Encoding.getByName("utf-8"));
      https.Response response = await https.post(Uri.parse(url),
          body: jsondata,
          encoding: Encoding.getByName("utf-8"),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      if (response.statusCode == 200) {

        bool reload         = false;
        if(prevChatResponseFilter != null)
        {
            if(prevChatResponseFilter != response.body)
                reload = true;
        }
        else
            reload            = true;
        prevChatResponseFilter      = response.body;
        var data = json.decode(response.body);
        print("reloadNeeded 1 :: "+reload.toString());
        if(!reload)
          return chat_list_match;

        if (chat_list_match != null && chat_list_match.isNotEmpty) {
          chat_list_match.clear();
        }


        var count = data["chatcount"];
        if (count != null) {
          UtilMethod.SetChatCount(context, count.toString());
        }
        var distance = data["distance_unit"];
        if (distance != null) {
          SessionManager.setString(Constant.Distance, distance.toString());
        }
        var notificationCount = data["notification_count"];
        if (notificationCount != null) {
          UtilMethod.SetNotificationCount(
              context, notificationCount.toString());
        }
        if (data["status"]) {
          List datitemmatch = data["data"];

          if (datitemmatch != null && datitemmatch.isNotEmpty) {
            chat_list_match =
                datitemmatch.map<Chat>((i) => Chat.fromJson(i)).toList();
          }
          //  setState(() {

          _listVisible = true;

          //   });
        } else {
          _listVisible = true;

          messages = data["message"].toString();
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
          for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = i == 0;
          }
        });
        //=========== old method _updateIntialMaps =============
        //_updateIntialMaps(0);
        //=========== new method _updateIntialMaps =============
        _updateIntialMaps(0,0);
      }

      return chat_list_match;
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future<List<Chat>> _professionItemListFilterOld(Map jsondata) async {
    try {
      action = Action.Professional;
      

      String url;

      url = WebServices.GetProfessionalUser +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";

      print("---Url----" + url.toString());
      https.Response response = await https.post(Uri.parse(url),
          body: jsondata,
          encoding: Encoding.getByName("utf-8"),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      if (response.statusCode == 200) {
        bool reload         = false;
        if(prevProfResponseFilter != null)
        {
            if(prevProfResponseFilter != response.body)
                reload = true;
        }
        else
            reload            = true;
        prevProfResponseFilter      = response.body;
        var data = json.decode(response.body);
        print("reloadNeeded 4 :: "+reload.toString());
        if(!reload)
          return chat_list_match;
//        Future.delayed(Duration(seconds: 2)).then((_) {
//          setState(() {
//            print("1 second closer to NYE!");
//            // Anything else you want
//          });
//        });
//        setState(() {
//          _listVisible = true;
//
//        });

        if (chat_list_match != null && chat_list_match.isNotEmpty) {
          chat_list_match.clear();
        }
        var count = data["chatcount"];
        if (count != null) {
          //   SessionManager.setString(Constant.ChatCount, count.toString());
          UtilMethod.SetChatCount(context, count.toString());
        }
        var distance = data["distance_unit"];
        if (distance != null) {
          SessionManager.setString(Constant.Distance, distance.toString());
        }

        var notificationCount = data["notification_count"];
        if (notificationCount != null) {
          //    SessionManager.setString(Constant.NotificationCount, notification_count.toString());
          UtilMethod.SetNotificationCount(
              context, notificationCount.toString());
        }
        if (data["status"]) {
          List datitemmatch = data["data"];

          if (datitemmatch != null && datitemmatch.isNotEmpty) {
            chat_list_match =
                datitemmatch.map<Chat>((i) => Chat.fromJson(i)).toList();
          }
          //  setState(() {

          setState(() {
            _listVisible = true;
          });

          //   });
        } else {
          setState(() {
            _listVisible = false;
          });
          messages = data["message"].toString();
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
          for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = i == 2;
          }
        });
        //=========== old method _updateIntialMaps =============
       // _updateIntialMaps(2);
        //=========== new method _updateIntialMaps =============
        _updateIntialMaps(2,0);
      }

      return chat_list_match;
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }


 //============= Old TabView Bar ================
  Widget _getToggleActivity() {

    return 
    Theme(
    data: ThemeData(
      indicatorColor: Color(0xfff73d90) ,
    ),
    child : DefaultTabController(
      length : 3,
      child : Stack(children: [
      Container(
       // margin: EdgeInsets.only(right: 90.0),
        height: 80,
        child: TabBar(
          controller: tabBarController,
          tabs: [
              Tab(
                   child : 
                   Container(
                   height : 80,
                   child : Column(
                        children: [
                          ImageIcon(AssetImage("assest/images/activity.png"),
                              size: 25, color: (toggle == 0 ?  Color(0xfff73d90) : Colors.grey[500])),
                          SizedBox(height:10),
                          Text(
                            AppLocalizations.of(context)
                                .translate("Activitys")
                                .toUpperCase(),
                            style: TextStyle(
                              color: (toggle == 0 ?  Color(0xfff73d90) : Colors.grey[500]),
                              fontWeight: FontWeight.bold,
                              fontSize: 7.5,
                              fontFamily: "OpenSans Regular",
                            ),
                          ),
                        ],
                      ),
                )),
                Tab(
                  child : 
                   Container(
                   height : 80,
                   child : Column(
                        children: [
                          ImageIcon(AssetImage("assest/images/peoples.png"),
                              size: 25, color: (toggle == 1 ?  Color(0xfff73d90) : Colors.grey[500])),
                          SizedBox(height:10),
                          Text(AppLocalizations.of(context).translate("People").toUpperCase(),
                            style: TextStyle(
                              color: (toggle == 1 ?  Color(0xfff73d90) : Colors.grey[500]),
                              fontWeight: FontWeight.bold,
                              fontSize: 7.5,
                              fontFamily: "OpenSans Regular",
                            ),
                          ),
                        ],
                      ),
                )),
                Tab(
                  child : 
                   Container(
                   height : 80,
                    child :  Column(
                        children: [
                          ImageIcon(
                            AssetImage("assest/images/professionals.png"),
                            size: 25,
                            color: (toggle == 2 ?  Color(0xfff73d90) : Colors.grey[500]),
                          ),
                          SizedBox(height:10),
                          Text(
                            AppLocalizations.of(context)
                                .translate("Professional_new")
                                .toUpperCase(),
                            style: TextStyle(
                              color: (toggle == 2 ?  Color(0xfff73d90) : Colors.grey[500]),
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                              fontFamily: "OpenSans Regular",
                            ),
                          ),
                        ],
                      ),  

                ))
            
          ],
        ),
      ),

      //========= Filter =================
     Positioned(
        top: 10,
        right: 20,
        child: Material(
          elevation: 2.0,
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // button color
          child: InkWell(
            child: ClipRRect(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  "assest/images/icon_filter.png",
                  width: 18,
                  height: 18,
                  fit: BoxFit.cover,
                  color: Color(0xFF23abe7),
                ),
              ),
            ),
            onTap: () async {
              print("------actin-------" + action.toString());
              if (await UtilMethod.SimpleCheckInternetConnection(
                  context, _scaffoldKey)) {
                //  if (action == Action.Activity)
                {
                  if (fav_list != null && fav_list.isEmpty) {
                    _filterModel.updateLoading(false);
                    _showModalBottomSheet(context);
                    _ItemList();
                  } else {
                    _filterModel.updateLoading(true);
                    _showModalBottomSheet(context);
                  }
                }
                //  else if(action == Action.People)
//                            {
//                              print("----inside1111-----------");
//                              _filterModel.updateLoading(true);
//                              _showModalBottomSheet(context);
//                            }
              }
            },
          ),
        ),
      ),
    ])));
  }

  //============= New TabView Bar ================
  Widget _widgetTabBarToggleActivity() {
    return
      Theme(
          data: ThemeData(
            indicatorColor: Color(0xfff73d90) ,
          ),
          child : DefaultTabController(
              length : 3,
              child :Stack(children: [
                Container(
                  color: Helper.inBackgroundColor.withOpacity(0.4),
                  // margin: EdgeInsets.only(right: 90.0),
                  height: 50,
                  child: TabBar(
                    controller: tabBarController,
                    tabs: [
                      Tab(
                          child :
                          Container(
                            height : 50,
                            child : Row(
                              children: [
                                false?ImageIcon(AssetImage("assest/images/activity.png"),
                                    size: 25, color: (toggle == 0 ?  Color(0xfff73d90) : Colors.grey[500])):
                                SvgPicture.asset('assest/images_svg/activity.svg',width: 25,height: 25,
                                    color: (toggle == 0 ?  Color(0xfff73d90) : Colors.grey[800])),
                                SizedBox(width:5),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate("Activitys")
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: (toggle == 0 ?  Color(0xfff73d90) : Colors.grey[800]),
                                    fontWeight: Helper.textFontH2,
                                    fontSize: Helper.textSizeH18,
                                    fontFamily: "OpenSans Regular",
                                  ),
                                ),
                              ],
                            ),
                          )),
                      Tab(
                          child :
                          Container(
                            height : 50,
                            child : Row(
                              children: [
                                false?ImageIcon(AssetImage("assest/images/peoples.png"),
                                    size: 25, color: (toggle == 1 ?  Color(0xfff73d90) : Colors.grey[500])):
                          SvgPicture.asset('assest/images_svg/Peoples.svg',width: 25,height: 25,
                          color: (toggle == 1 ?  Color(0xfff73d90) : Colors.grey[800])),
                                SizedBox(width:5),
                                Text(AppLocalizations.of(context).translate("People").toUpperCase(),
                                  style: TextStyle(
                                    color: (toggle == 1 ?  Color(0xfff73d90) : Colors.grey[800]),
                                    fontWeight: Helper.textFontH2,
                                    fontSize: Helper.textSizeH18,
                                    fontFamily: "OpenSans Regular",
                                  ),
                                ),
                              ],
                            ),
                          )),
                      Tab(
                          child :
                          Container(
                            height : 50,
                            child :  Row(
                              children: [
                                ImageIcon(
                                  AssetImage("assest/images/professionals.png"),
                                  size: 25,
                                  color: (toggle == 2 ?  Color(0xfff73d90) : Colors.grey[800]),
                                ),
                                SizedBox(width:5),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate("Professional_new")
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: (toggle == 2 ?  Color(0xfff73d90) : Colors.grey[800]),
                                    fontWeight: Helper.textFontH2,
                                    fontSize: Helper.textSizeH18,
                                    fontFamily: "OpenSans Regular",
                                  ),
                                ),
                              ],
                            ),

                          ))

                    ],
                  ),
                ),
              ])));
  }


  Future<https.Response> _GetLikeUser(Chat nDataList) async {
    try {
      Future.delayed(Duration.zero, () {
        _showProgress(context,"4");
      });
      Map jsondata = {"user_id": nDataList.user_id};
      print("----jsondata-----" + jsondata.toString());
      String url;
      if (nDataList.you_liked == 0) {
        url = WebServices.GetChatUserLike +
            SessionManager.getString(Constant.Token) +
            "&language=${SessionManager.getString(Constant.Language_code)}";
      } else {
        url = WebServices.GetUserUnLike +
            SessionManager.getString(Constant.Token) +
            "&language=${SessionManager.getString(Constant.Language_code)}";
      }
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          // Scaffold.of(context).showSnackBar(SnackBar(content: Text(data["message"])));

          if (action == Action.Activity) {
            _chatItemList();
          } else if (action == Action.Professional) {
            _professionItemList();
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
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future _GetSubscribe(String id, String value) async {
    try {
      Future.delayed(Duration.zero, () {
        _showProgress(context,"3");
      });
//      Response response;
//      Dio dio = new Dio();
//      FormData formData = new FormData.fromMap({
//        "event_id": id,
//        "is_sub": value,
//      });
      Map jsondata = {"event_id": id, "is_sub": value};
      print("-----jsondata-----" + jsondata.toString());
      String url = WebServices.GetSubscribe +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
//      response = await dio.post(url, data: {
//        "event_id": id,
//        "is_sub": value,
//      });

      //  var response = await dio.post(url, data: formData);

      print("-----url-----" + url.toString());
      var response = await https.post(
        Uri.parse(url),
        body: jsondata,
        encoding: Encoding.getByName("utf-8"),
      );
      print("respnse----" + response.body.toString());
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          // Scaffold.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"]);

          _activityItemList();
        } else {
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message: AppLocalizations.of(context).translate("Token Expire"));
          }
        }
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future<List<User>> _ItemList() async {
    try {
      if (fav_list != null && fav_list.isNotEmpty) {
        fav_list.clear();
      }

      String url = WebServices.GetCatgroy +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          List userlist = data["category"];

          if (userlist != null && userlist.isNotEmpty) {
            fav_list = userlist.map<User>((i) => User.fromJson(i)).toList();
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

        _filterModel.updateLoading(true);
      }

      return fav_list;
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future _asyncConfirmInterest(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            print("----------instast-----" + radioInterest.toString());
            return Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      const Color(0xfff16cae).withOpacity(0.8),
                      const Color(0xff3f86c6).withOpacity(0.8),
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
                        //  height: 150,
                        padding: const EdgeInsets.only(
                            left: Helper.padding,
                            //top: Helper.avatarRadius,//+ Helper.padding,
                            top: Helper.padding,
                            right: Helper.padding,
                            bottom: Helper.padding
                        ),
                        margin: const EdgeInsets.only(top: Helper.avatarRadius),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RadioListTile(
                              dense: true,
                              groupValue: radioInterest,
                              title: CustomWigdet.TextView(
                                  fontSize: 16,
                                  text: AppLocalizations.of(context).translate("MEN"),
                                  color: Custom_color.BlackTextColor),
                              value: 1,
                              onChanged: (val) async {
                                if (await UtilMethod.SimpleCheckInternetConnection(
                                    context, _scaffoldKey)) {
                                  setState(() {
                                    radioInterest = val;
                                    _filterModel.updateInterest(radioInterest);
                                  });
                                }
                                Navigator.pop(context,1);

                              },
                            ),
                            RadioListTile(
                              dense: true,
                              groupValue: radioInterest,
                              title: CustomWigdet.TextView(
                                  fontSize: 16,
                                  text:
                                      AppLocalizations.of(context).translate("WOMEN"),
                                  color: Custom_color.BlackTextColor),
                              value: 2,
                              onChanged: (val) async {
                                if (await UtilMethod.SimpleCheckInternetConnection(
                                    context, _scaffoldKey)) {
                                  setState(() {
                                    radioInterest = val;
                                    _filterModel.updateInterest(radioInterest);
                                  });
                                }
                                Navigator.pop(context,1);
                              },
                            ),
                            RadioListTile(
                              dense: true,
                              groupValue: radioInterest,
                              title: CustomWigdet.TextView(
                                  fontSize: 16,
                                  text:
                                      AppLocalizations.of(context).translate("BOTH"),
                                  color: Custom_color.BlackTextColor),
                              value: 3,
                              onChanged: (val) async {
                                if (await UtilMethod.SimpleCheckInternetConnection(
                                    context, _scaffoldKey)) {
                                  setState(() {
                                    radioInterest = val;
                                    _filterModel.updateInterest(radioInterest);
                                  });
                                }
                                Navigator.pop(context,1);

                              },
                            ),
                          ],
                        ),
                      ),
                      true?Positioned(
                        //  left:275, //Helper.padding,
                        // right:-6,// Helper.padding,
                          top:15,

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
                                margin: const EdgeInsets.only(top: 10,),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    border: Border.all(color:Color(Helper.inBackgroundColor1),width: 3),
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        // Color(0xfff16cae).withOpacity(0.8),
                                        Color(0xff3f86c6),
                                        Color(0xff3f86c6),
                                      ],
                                    )
                                ),
                                child: const Icon(Icons.close,color: Colors.white,size:22,)),
                            onTap: (){
                              Navigator.pop(context,1);
                            },
                          )):Container(),
                    ],
                  )),
            );
          },
        );
      },
    );
  }

  Future _asyncConfirmLanguage(BuildContext context) async {
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
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
                              _filterModel.updateLanguage(radioLanguage);
                            });
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
                              _filterModel.updateLanguage(radioLanguage);
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

  Future _asyncConfirmActivity(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      const Color(0xfff16cae).withOpacity(0.8),
                      const Color(0xff3f86c6).withOpacity(0.8),
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
                        //height: MQ_Height*0.45,
                          padding: const EdgeInsets.only(
                              left: Helper.padding,
                              //top: Helper.avatarRadius,//+ Helper.padding,
                              top: Helper.padding,
                              right: Helper.padding,
                              bottom: Helper.padding
                          ),
                          margin: const EdgeInsets.only(top: Helper.avatarRadius),
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(fav_list.length, (index) {
                              var data = fav_list[index];
                              return ListTile(
                                  title:  Row(
                                children: <Widget>[
                                   Expanded(child:
                                   Text(data.name,style: TextStyle(color: Custom_color.BlueDarkColor),)),
                                   Checkbox(
                                      value: data.ischeck,
                                      onChanged: (bool value) {
                                        setState(() {
                                          data.ischeck = value;
                                          _filterModel.updateActivityItem(
                                              _getListUseritem(fav_list));
                                        });
                                      },

                                    side:BorderSide(color: Custom_color.BlueDarkColor),
                                  )
                                ],
                              ));
                            }),
                          ),
                         false?Material(
                           child: InkWell(
                               onTap: () {
//                            _filterModel
//                                .updateActivityItem(_getListUseritem(fav_list));
                                 Navigator.pop(context);
                               },
                               child: Ink(
                                 padding: EdgeInsets.all(10),
                                 width: _screenSize.width,
                                 color: Custom_color.BlueLightColor,
                                 child: CustomWigdet.TextView(
                                   textAlign: TextAlign.center,
                                   text: AppLocalizations.of(context)
                                       .translate("Submit"),
                                   color: Custom_color.WhiteColor,
                                   fontFamily: "OpenSans Bold",
                                 ),
                               )),
                         ): Container(
                           alignment: Alignment.center,
                           margin: EdgeInsets.only(left: MQ_Width * 0.06,
                               right: MQ_Width * 0.06,
                               top: MQ_Height * 0.02,
                               bottom: MQ_Height * 0.01),
                           padding: const EdgeInsets.only(bottom: 5),
                           height: 50,
                           width: MQ_Width * 0.32,
                           decoration: BoxDecoration(
                             color:  Color(Helper.ButtonBorderPinkColor),
                             border: Border.all(width: 0.5,
                                 color: Color(Helper.ButtontextColor)),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: FlatButton(
                             onPressed: () async {
                               Navigator.of(context).pop();

                             },
                             child: Text(
                               AppLocalizations.of(context)
                                   .translate("Submit"),
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                   color: Color(Helper.ButtontextColor),
                                   fontFamily: "Kelvetica Nobis",
                                   fontSize: Helper.textSizeH13,
                                   fontWeight: Helper.textFontH5),
                             ),
                           ),
                         ),
                        ],
                      )),
                      true?Positioned(
                        //  left:275, //Helper.padding,
                        // right:-6,// Helper.padding,
                          top:15,

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
                                margin: const EdgeInsets.only(top: 10,),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    border: Border.all(color:Color(Helper.inBackgroundColor1),width: 3),
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        // Color(0xfff16cae).withOpacity(0.8),
                                        Color(0xff3f86c6),
                                        Color(0xff3f86c6),
                                      ],
                                    )
                                ),
                                child: const Icon(Icons.close,color: Colors.white,size:22,)),
                            onTap: (){
                              Navigator.pop(context,1);
                            },
                          )):Container(),
                    ],
                  )),
            );
          },
        );
      },
    );
  }

  String _getInterestSecond(int name) {
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

   _getListUseritem(List<User> list) async {
    var check = false;
    StringBuffer value = new StringBuffer();
    List<User>.generate(list.length, (index) {
      if (list[index].ischeck) {
        if (check) {
          value.write(", ");
        } else {
          check = true;
        }
        value.write(list[index].name);
      }
    });

    return !UtilMethod.isStringNullOrBlank(value.toString())
        ? value.toString()
        : "";
    //FocusScope.of(context).requestFocus(focusNode_theme);
  }

  void resetFilterButton() {
    _filterModel.updateSliderCount(30.0);
    _filterModel.updateProvidingJob(false);
    _filterModel.updateLookingForJob(false);
    _filterModel.updateInterest(0);
    _filterModel.updateActivityItem("");
    fav_list.clear();
    Navigator.pop(context);
    if (action == Action.Activity) {
      _showProgress(context,"2");
      _chatItemList();
    } else if (action == Action.People) {
      _showProgress(context,"1");
      _activityItemList();
    } else if (action == Action.Professional) {
      _showProgress(context,"0");
      _professionItemList();
    }
  }

  void resetFilter() {
    _filterModel.updateSliderCount(30.0);
    _filterModel.updateProvidingJob(false);
    _filterModel.updateLookingForJob(false);
    _filterModel.updateInterest(0);
    _filterModel.updateActivityItem("");
    fav_list.clear();
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

  String _getLanguage(int name) {
    String value = "";
    if (name == 0) {
      value = "";
    } else if (name == Constant.English) {
      value = AppLocalizations.of(context).translate("English");
    } else if (name == Constant.German) {
      value = AppLocalizations.of(context).translate("German");
    }
    return value;
  }

  _showProgress(BuildContext context,String from) {
    print("from :: ");
    print(from);
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
      child: Center(
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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class MapWidget {}

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

class RadiantGradientMask extends StatelessWidget {
  RadiantGradientMask({this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [Color(0xffaeaeae), Color(0xffb5b5b5)],
        end: Alignment.topRight,
        begin: Alignment.bottomLeft,
        tileMode: TileMode.clamp,
      ).createShader(bounds),
      child: child,
    );
  }
}

class RadiantGradientMask2 extends StatelessWidget {
  RadiantGradientMask2({this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [Color(0xfffa2985), Color(0xfffe98bf)],
        end: Alignment.topRight,
        begin: Alignment.bottomLeft,
        tileMode: TileMode.clamp,
      ).createShader(bounds),
      child: child,
    );
  }
}
