import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/chat/chatuser.dart';
import 'package:miumiu/screen/pages/home_pages.dart';
import 'package:miumiu/screen/pages/personal_page.dart';
import 'package:miumiu/screen/pages/provider/model.dart';
import 'package:miumiu/screen/settings/edit_profile/edit_profile_new.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../services/webservices.dart';
import '../utilmethod/helper.dart';
import '../utilmethod/network_connectivity.dart';
import '../utilmethod/preferences.dart';
import '../utilmethod/utilmethod.dart';
import 'package:http/http.dart' as https;


class Nagivation_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<Nagivation_screen> {
  int _selectedTab = 0;
  GlobalKey bottomNavigationKey = GlobalKey();
   String Tag="Nagivation_screen";
  var routeData;

  final Color _selectedItemColor = Colors.white;
  final Color _unselectedItemColor = Color(0xffd5d6d8);
 final LinearGradient _selectedBgColor = const LinearGradient(colors: [Color(0xff23b8f2), Color(0xff1b5dab)],
     begin: Alignment.topCenter,
     end: Alignment.bottomCenter);
  final LinearGradient _unselectedBgColor = const LinearGradient(colors: [Colors.white, Colors.white],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);

  List<Widget> _pageOptions   = [];
  List<Widget> _pageOptions2  = [];
  var MQ_Height;
  var MQ_Width;

  bool back = false;
  int time = 0;
  int duration = 1000;
  var countNotif=0;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Notification_Screen(),
  Timer timer;
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _connectivity = NetworkConnectivity.instance;
  bool networkEnable=true;
  bool checkRefresh = false;

  @override
  void initState() {

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() {
          _source = source;
          print('Navigate ## source =$source, \n#c _source=${_source.keys.toList()[0]}');
          if(_source.keys.toList()[0]==ConnectivityResult.wifi){
            print('Navigate ## ConnectivityResult.wifi _source=${_source.keys.toList()[0]}');
            networkEnable = true ;
          }
          else if(_source.keys.toList()[0]==ConnectivityResult.mobile){
            print('Navigate ## ConnectivityResult.mobile _source=${_source.keys.toList()[0]}');
            networkEnable = true ;
          }else{
            print('Navigate ## ConnectivityResult.none _source=${_source.keys.toList()[0]}');
            networkEnable = false ;
          }

        });
      }
    });

    Future.delayed(Duration.zero, () {

    try
    {
              routeData = ModalRoute.of(context).settings.arguments;
              print('navigator ## routeData =${routeData} \n');
                if (routeData != null) {
                  if(mounted) {
                    setState(() {
                    _selectedTab = routeData["index"];
                    Constant.currentTab = routeData["index"];
                    Constant.currentHomeTab = routeData["index_home"];

                  });
                  }

                  print('navigator ## Constant.currentTab =${Constant.currentTab} \n Constant.currentHomeTab=${Constant.currentHomeTab}');


                }else{
                  if(mounted) {
                    setState(() {
                    _selectedTab = 0;
                    Constant.currentHomeTab =1;

                  });
                  }
                }
    }catch(e){
      print('navigator ## catch  error =${e}');
      if(mounted) {
        setState(() {
        _selectedTab = 0;
        Constant.currentHomeTab =1;

      });
      }
    }

    print('navigator ## !!!! Constant.currentHomeTab=${Constant.currentHomeTab}');

    _pageOptions = [
      Home_pages(),
      // Activity_page(),
      Profile_Screen(),
      ChatUser_Screen(),
      Personal_page(),
    ];
    setState(() {
      _selectedTab =  Constant.currentTab;
      final FancyBottomNavigationState fState = bottomNavigationKey
          .currentState as FancyBottomNavigationState;
      fState.setPage(_selectedTab);

      _pageOptions2 = _pageOptions;
    });


    });




    timer = Timer.periodic(Duration(seconds: 10), (Timer t) => chatListNotify(context));

    super.initState();
  }


  Future<void> chatListNotify(BuildContext context)async{
      if(networkEnable==true) {
      if (await UtilMethod.SimpleCheckInternetConnection(context, _scaffoldKey)) {
        _chatItemList(context);
      }
    }
  }


  Future<dynamic> _chatItemList(BuildContext context) async {
    try {
      /*if (chat_list_offline != null && !chat_list_offline.isEmpty) {
        chat_list_offline.clear();
        chat_list_online.clear();
      }*/
      String url = WebServices.GetChatUser +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("$Tag ---Url----" + url.toString());
      print("$Tag chatuser _chatItemList ## url=${url}");

      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});

      print("$Tag respnse--111--" + response.body);
      // print("chatuser _chatItemList ##  response.body=${ response.body}");
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
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
        try {
          var count = data["chatcount"];
          if (count != null) {
            //  SessionManager.setString(Constant.ChatCount, count.toString());
            UtilMethod.SetChatCount(context, count.toString());
          }
          var notification_count = data["notification_count"];
          if (notification_count != null) {
            //  SessionManager.setString(Constant.NotificationCount, notification_count.toString());
            UtilMethod.SetNotificationCount(
                context, notification_count.toString());
          }
        }catch(error){
          print('navigationScreen chat counter catch error=${error.toString()}');
        }
        /*if (data["status"]) {
          List offline_data = data["offline"];
          List online_data = data["online"];

          if (offline_data != null && offline_data.isNotEmpty) {
            chat_list_offline = offline_data.map<User>((i) => User.fromJson(i)).toList();
            newDataList = List.from(chat_list_offline);
          }
          if (online_data != null && online_data.isNotEmpty) {
            chat_list_online = online_data.map<User>((i) => User.fromJson(i)).toList();
          }

          //  setState(() {
          if (mounted) {
            setState(() {
            //  _listVisible = true;
            });
          }
          //   });
        } else {
          if (mounted) {
            setState(() {
             // _listVisible = false;
            });
          }*/
        var  messages = data["message"].toString();
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
           // _visible = true;
          });
        }


    } on Exception catch (e) {
      print(e.toString());
      //_hideProgress();
    }
  }





  Gradient _getBgColor(int index) =>
      _selectedTab == index ? _selectedBgColor : _unselectedBgColor;

  Color _getItemColor(int index) =>
      _selectedTab == index ? _selectedItemColor : _unselectedItemColor;

  void _onItemTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
  }
  Widget _buildIcon(String path, String text, int index) => Container(
    decoration: BoxDecoration(

      border: Border.all(width: 0.5 ,color: Color(0xffb6e7f8)),
        gradient: _getBgColor(index)
    ),


    width: double.infinity,
    height: 70,
    child: Material(

      //color: _getBgColor(index),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: _getBgColor(index)
        ),
        child: InkWell(


          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ImageIcon(

                  AssetImage(path),

                color: _getItemColor(index),
                size: 22,

              ),
              SizedBox(height: 5.0,),
              text != null ?
              Container(
                width: 60,
                child: Text(text.toUpperCase(),textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11,color: _getItemColor(index),)),
              ) :
              Text("No data found".toUpperCase(),textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11,color: _getItemColor(index),)),
            ],
          ),
          onTap: () => _onItemTapped(index),
        ),
      ),
    ),
  );
  Widget _buildChatIcon(String path, String text, int index) => Container(
    decoration: BoxDecoration(
        border: Border.all(width: 0.5 ,color: Color(0xffb6e7f8)),
      gradient: _selectedBgColor
    ),
    width: double.infinity,
    height: 70,
    child: Material(
    //  color: _getBgColor(index),
      child: Container(


        decoration: BoxDecoration(
            gradient: _getBgColor(index)
        ),
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  ImageIcon(AssetImage(path),color: _getItemColor(index),size: 22,),

                  Consumer<CounterModel>(builder: (context, myModel, child) {
                    return Constant.DummyChatCount.isNotEmpty &&
                        Constant.DummyChatCount != null &&
                        int.parse(myModel.getCounter().toString()) > 0
                        ? Positioned(
                      right: -5,
                      top: 0,
                      child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Custom_color.RedColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child:
//                              Consumer<MyModel>( //                    <--- Consumer
//                                builder: (context, myModel, child) {
//                                  return Text(myModel.getCounter().toString(),style: TextStyle(color: Custom_color.BlackTextColor,fontSize: 10),);
//                                },
//                              ),
                          Center(
                            child: CustomWigdet.TextView(
                                text: int.parse(myModel
                                    .getCounter()
                                    .toString()) >
                                    99
                                    ? "99+"
                                    : "${myModel.getCounter().toString()}",
                                fontFamily: "OpenSans Bold",
                                fontSize: 9,
                                color: Custom_color.WhiteColor),
                          )),
                    )
                        : Container();
                  })
                ],

              ),
              const SizedBox(height: 5.0,),


              Text(text.toUpperCase(),
                  style: TextStyle(fontSize: 12, color: _getItemColor(index))),
            ],
          ),
          onTap: () => _onItemTapped(index),
        ),
      ),
    ),
  );

  Widget _buildChatIconNew(String path, String text, int index) => Material(
    //  color: _getBgColor(index),
    child: InkWell(
      child:  Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          // new ImageIcon(AssetImage(path),color: _getItemColor(index),size: 22,),

          Consumer<CounterModel>(builder: (context, myModel, child) {
            countNotif=int.parse(myModel.getCounter().toString());
            print('Navigation countNotif===$countNotif');
            return Constant.DummyChatCount.isNotEmpty &&
                Constant.DummyChatCount != null &&
                int.parse(myModel.getCounter().toString()) > 0
                ? Positioned(
              right: -5,
              top: 0,
              child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Custom_color.RedColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child:
//                              Consumer<MyModel>( //                    <--- Consumer
//                                builder: (context, myModel, child) {
//                                  return Text(myModel.getCounter().toString(),style: TextStyle(color: Custom_color.BlackTextColor,fontSize: 10),);
//                                },
//                              ),
                  Center(
                    child: CustomWigdet.TextView(
                        text: int.parse(myModel
                            .getCounter()
                            .toString()) >
                            99
                            ? "99+"
                            : "${myModel.getCounter().toString()}",
                        fontFamily: "OpenSans Bold",
                        fontSize: 9,
                        color: Custom_color.WhiteColor),
                  )),
            )
                : Container();
          })
        ],

      ),
      onTap: () => _onItemTapped(index),
    ),
  );

  Widget currentScreen;


  @override
  void dispose() {

    print("disposing navigation");
    try{
      _connectivity.disposeStream();
      _source.clear();
    }catch(error){
      print('_connectivity disponse error=$error');
    }
    try
    {
        if (Constant.socket != null) {
          Constant.socket.disconnect();
          Constant.socket.close();
          Constant.socket.clearListeners();
          Constant.socket.dispose();

        }
    }catch(e){}

    try{
      timer.cancel();
    }catch(er){
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;

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
                print('Navigation Mobile networkEnable: $networkEnable');
                networkEnable = true;
                checkRefresh = true;
              });
            } catch (error) {
              print('Navigation Mobile error: $error');
              networkEnable = true;
              checkRefresh = true;
            }
            break;
          case ConnectivityResult.wifi:
            string = 'Wifi: Online';
            //  FlutterToastAlert.flutterToastMSG('WiFi: Online', context);

            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('Navigation Wifi networkEnable: $networkEnable');

                networkEnable = true;
                checkRefresh = true;
              });
            } catch (error) {
              print('Navigation WiFi error: $error');
              networkEnable = true;
              checkRefresh = true;
            }

            break;
          case ConnectivityResult.none:
            string = 'Offline';
            // FlutterToastAlert.flutterToastMSG('Offline', context);
            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('Navigation Offline networkEnable: $networkEnable');
                networkEnable = false;
                checkRefresh = true;
              });
            } catch (error) {
              print('Navigation Offline error: $error');
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
    
    return WillPopScope(
      onWillPop:willPop,
      child: VisibilityDetector(
        key: Key('my-widget-key'),
        onVisibilityChanged: (visibilityInfo) async {
            var visiblePercentage = visibilityInfo.visibleFraction * 100;
            Constant.VISIBILITY   = visiblePercentage;
            if(visiblePercentage == 100)
            {
                _pageOptions = _pageOptions2;
                setState(() {});
              //  Navigator.pushNamedAndRemoveUntil(
              //   context, Constant.NavigationRoute, (r) => true,
              //   arguments: {"index": _selectedTab});
            }
            else
            {
                // _pageOptions = [
                //   Home_pages(),
                //   Activity_page(),
                //   Profile_Screen(),
                //   ChatUser_Screen(),
                //   Personal_page(),
                // ];
                // try{Constant.socket.disconnect();}catch(e){}
                await DefaultCacheManager().emptyCache();     
                _pageOptions = [];  
                _pageOptions = [Home_pages()];
                if(mounted==true) {
                  setState(() {});
                }
            }
            
        },
        child:AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Color(Helper.StatusBarColor),
            ),
            child: Scaffold(
          body: IndexedStack(
            index: _selectedTab,
            children: _pageOptions,
          ),
          bottomNavigationBar:
         false? BottomNavigationBar(
            selectedFontSize: 0,
           // backgroundColor: Colors.white,


              type: BottomNavigationBarType.fixed,
              //showSelectedLabels: false,
              //selectedIconTheme: IconThemeData(size: 30),
              currentIndex: _selectedTab,
              onTap: (int index) {
                setState(() {
                  _selectedTab = index;
                });
                Constant.currentTab = index;
              },
              items: [

                BottomNavigationBarItem(
                    icon: _buildIcon("assest/images/face.png",
                        AppLocalizations.of(context)
                        .translate("My Activity"), 1),

                    // backgroundColor: Colors.black,
                    // icon: Image.asset(
                    //   "assest/images/home_tellmelive.png",
                    //   width: 25,
                    //   color: _selectedTab == 0
                    //       ? Custom_color.BlueLightColor
                    //       : Custom_color.GreyLightColor,
                    //
                    //   alignment: Alignment.center,
                    // ),
                    label: ''
                  ),
           // BottomNavigationBarItem(
           //     icon: new Stack(
           //       alignment: Alignment.center,
           //       children: <Widget>[
           //         new Image.asset(
           //           "assest/images/notification_2.png",
           //           width: 25,
           //           color: _selectedTab == 1
           //               ? Custom_color.BlueLightColor
           //               : Custom_color.GreyLightColor,
           //           alignment: Alignment.center,
           //         ),
           //         Consumer<CounterModel>(builder: (context, myModel, child) {
           //           return Constant.DummyNotificationCount.isNotEmpty &&
           //                   Constant.DummyNotificationCount != null &&
           //                   int.parse(myModel.getNotificationCounter()
           //                           .toString()) >
           //                       0
           //               ? Positioned(
           //                   right: 0,
           //                   top: 0,
           //                   child: new Container(
           //                       padding: EdgeInsets.all(2),
           //                       decoration: new BoxDecoration(
           //                         color: Custom_color.RedColor,
           //                         borderRadius: BorderRadius.circular(10),
           //                       ),
           //                       constraints: BoxConstraints(
           //                         minWidth: 18,
           //                         minHeight: 18,
           //                       ),
           //                       child: Center(
           //                         child: CustomWigdet.TextView(
           //                             text: int.parse(myModel
           //                                         .getNotificationCounter()
           //                                         .toString()) >
           //                                     99
           //                                 ? "99+"
           //                                 : "${myModel.getNotificationCounter().toString()}",
           //                             fontFamily: "OpenSans Bold",
           //                             fontSize: 9,
           //                             color: Custom_color.WhiteColor),
           //                       )),
           //                 )
           //               : Container();
           //         })
           //       ],
           //     ),
           //     title: Padding(padding: EdgeInsets.all(0))),
                BottomNavigationBarItem(
                    icon: _buildIcon("assest/images/user_2.png", AppLocalizations.of(context)
                        .translate("Profile"), 2),

                    // backgroundColor: Colors.black,
                    // icon: Image.asset(
                    //   "assest/images/home_tellmelive.png",
                    //   width: 25,
                    //   color: _selectedTab == 0
                    //       ? Custom_color.BlueLightColor
                    //       : Custom_color.GreyLightColor,
                    //
                    //   alignment: Alignment.center,
                    // ),
                    label: ''
                    ),

                BottomNavigationBarItem(
                    icon: _buildIcon("assest/images/home_tellmelive.png", AppLocalizations.of(context)
                        .translate("Home"), 0),

                    // backgroundColor: Colors.black,
                    // icon: Image.asset(
                    //   "assest/images/home_tellmelive.png",
                    //   width: 25,
                    //   color: _selectedTab == 0
                    //       ? Custom_color.BlueLightColor
                    //       : Custom_color.GreyLightColor,
                    //
                    //   alignment: Alignment.center,
                    // ),
                    label: ''),
                BottomNavigationBarItem(
                    icon: _buildChatIcon("assest/images/chat.png", AppLocalizations.of(context)
                        .translate("Chats"), 3),

                    // backgroundColor: Colors.black,
                    // icon: Image.asset(
                    //   "assest/images/home_tellmelive.png",
                    //   width: 25,
                    //   color: _selectedTab == 0
                    //       ? Custom_color.BlueLightColor
                    //       : Custom_color.GreyLightColor,
                    //
                    //   alignment: Alignment.center,
                    // ),
                    label: ''

                  ),
//               BottomNavigationBarItem(
//
//                   icon:
//
//                     StreamBuilder<Object>(
//                       stream: null,
//                       builder: (context, snapshot) {
//                         return new Stack(
//                           overflow: Overflow.visible,
//                           alignment: Alignment.center,
//                           children: <Widget>[
//                             new Image.asset(
//                               "assest/images/notification_2.png",
//                               width: 25,
//                               color: _selectedTab == 4
//                                   ? Custom_color.BlueLightColor
//                                   : Custom_color.GreyLightColor,
//                               alignment: Alignment.center,
//                             ),
//                             Consumer<CounterModel>(builder: (context, myModel, child) {
//                               return Constant.DummyNotificationCount.isNotEmpty &&
//                                   Constant.DummyNotificationCount != null &&
//                                   int.parse(myModel.getNotificationCounter().toString()) > 0
//                                   ? Positioned(
//                                 right: -5,
//                                 top: 0,
//                                 child: new Container(
//                                     padding: EdgeInsets.all(2),
//                                     decoration: new BoxDecoration(
//                                       color: Custom_color.RedColor,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     constraints: BoxConstraints(
//                                       minWidth: 18,
//                                       minHeight: 18,
//                                     ),
//                                     child:
// //                              Consumer<MyModel>( //                    <--- Consumer
// //                                builder: (context, myModel, child) {
// //                                  return Text(myModel.getCounter().toString(),style: TextStyle(color: Custom_color.BlackTextColor,fontSize: 10),);
// //                                },
// //                              ),
//                                     Center(
//                                       child: CustomWigdet.TextView(
//                                           text: int.parse(myModel
//                                               .getCounter()
//                                               .toString()) >
//                                               99
//                                               ? "99+"
//                                               : "${myModel.getCounter().toString()}",
//                                           fontFamily: "OpenSans Bold",
//                                           fontSize: 9,
//                                           color: Custom_color.WhiteColor),
//                                     )),
//                               )
//                                   : Container();
//                             })
//                           ],
//
//                   );
//                       }
//                     ),
//
//
//                   title: CustomWigdet.TextView(
//                     text: AppLocalizations.of(context)
//                         .translate("Notifications"),
//                     color: _selectedTab == 4
//                         ? Custom_color.BlueLightColor
//                         : Custom_color.GreyLightColor,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w700,
//                   )),
                BottomNavigationBarItem(
                    icon: _buildIcon("assest/images/setting.png", AppLocalizations.of(context)
                        .translate("Setting"), 4),

                    // backgroundColor: Colors.black,
                    // icon: Image.asset(
                    //   "assest/images/home_tellmelive.png",
                    //   width: 25,
                    //   color: _selectedTab == 0
                    //       ? Custom_color.BlueLightColor
                    //       : Custom_color.GreyLightColor,
                    //
                    //   alignment: Alignment.center,
                    // ),
                    label: ''
                  ),
              ],
            ):Stack(
              children: [


                FancyBottomNavigation(
               key:bottomNavigationKey,
           initialSelection:_selectedTab,


           tabs: [
           //  TabData(iconData: Icons.home, title: "Home"),
                // TabData(iconData: Icons.local_activity, title: "My Activity"),
                 TabData(iconData:Icons.home, //IconData(0xe318, fontFamily: 'MaterialIcons'),

                     //SvgPicture.asset('assest/images_svg/home-grey.svg'),
                     title: "Home"),

                 TabData(iconData: Icons.person, title: "Profile"),
                 TabData(iconData:Icons.chat,
                   title: "Chat",),
                 TabData(iconData: Icons.settings, title: "Setting")

           ],

           textColor: Colors.blue,
           barBackgroundColor: Colors.white,
           inactiveIconColor: Colors.grey,
           activeIconColor: Colors.white,
           circleColor: Colors.blue,
           onTabChangedListener: (position) {
                 setState(() {
                   _selectedTab = position;
                 });
           },


         ),
                false? Positioned(
                  right: 130,
                  top: 15,
                  child: new Container(
                    padding: EdgeInsets.all(1),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8.5),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    child: Text(
                      '10',
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ):
                Positioned(
                  right: 130,
                  top: 10,
                  child: Container(
                    width:countNotif<10?15:24,
                    height: 15,
                    //color: Colors.red,
                    child:Consumer<CounterModel>(builder: (context, myModel, child) {
                      countNotif=int.parse(myModel.getCounter().toString());
                      print('Navigation countNotif===$countNotif');
                      return Constant.DummyChatCount.isNotEmpty &&
                          Constant.DummyChatCount != null &&
                          int.parse(myModel.getCounter().toString()) > 0
                          ? Container(
                              padding: EdgeInsets.all(2),
                              decoration:  BoxDecoration(
                                color: Custom_color.RedColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child:
//                              Consumer<MyModel>( //                    <--- Consumer
//                                builder: (context, myModel, child) {
//                                  return Text(myModel.getCounter().toString(),style: TextStyle(color: Custom_color.BlackTextColor,fontSize: 10),);
//                                },
//                              ),
                              Center(
                                child: CustomWigdet.TextView(
                                    text: int.parse(myModel
                                        .getCounter()
                                        .toString()) >
                                        99
                                        ? "99+"
                                        : "${myModel.getCounter().toString()}",
                                    fontFamily: "OpenSans Bold",
                                    fontSize: 9,
                                    color: Custom_color.WhiteColor),
                              ))
                          : Container();
                    })//_buildChatIconNew("assest/images/chat.png", AppLocalizations.of(context).translate("Chats"), 3),
                  ),
                )
              ],
            )
        )
          ),

      
        )
      );

  }
  Future<bool> willPop() async{
    if (_selectedTab == 0) {
      print('willPop== if _selectedTab=$_selectedTab');

      int now = DateTime.now().millisecondsSinceEpoch;
    if(back && time >= now){
      back = false;
      showExitPopup();

    }else{
      time =  DateTime.now().millisecondsSinceEpoch+ duration;
      print("again tap");
      back = true;
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(AppLocalizations.of(context).translate("Press again the button to exit"),
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: "Kelvetica Nobis",
          fontSize: Helper.textSizeH12,
          fontWeight: Helper.textFontH5,
          color: Custom_color.WhiteColor),)));
    }

    } else {
      print('willPop== else _selectedTab=$_selectedTab');
      setState(() {
        _selectedTab = 0;
        Constant.currentTab=0;
        final FancyBottomNavigationState fState = bottomNavigationKey
            .currentState as FancyBottomNavigationState;
        fState.setPage(_selectedTab);
      });
    }
    return false;
  }


  Future<bool> showExitPopup() async {
    return await showDialog( //show confirm dialogue
      //the return value will be from "Yes" or "No" options
      context: context,
      builder: (context) => Center(
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          //  backgroundColor: Colors.transparent,
            title: CustomWigdet.TextView(
                text: AppLocalizations.of(context).translate("Exit App"),
                //AppLocalizations.of(context).translate("Create Activity"),
                fontFamily: "Kelvetica Nobis",
                fontSize: Helper.textSizeH8,
                fontWeight: Helper.textFontH4,
                color: Helper.textColorBlueH1
            ),
            content:  CustomWigdet.TextView(
              overflow: true,
              text:AppLocalizations.of(context).translate("Do you want to exit an App"),
              //AppLocalizations.of(context).translate("Create Activity"),
              fontFamily: "Kelvetica Nobis",
              fontSize: Helper.textSizeH12,
              fontWeight: Helper.textFontH5,
              color: Custom_color.GreyLightColor,

            ),
            actions:[
              /*ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child:Text(AppLocalizations.of(context).translate("No")),
              ),

              ElevatedButton(
                onPressed: () {

                 },
                //return true when click on "Yes"
                child:Text(AppLocalizations.of(context).translate("Yes")),
              ),*/


              Container(
                alignment: Alignment.bottomCenter,
                margin:  EdgeInsets.only(left: 5,right: 5),
                height: 50,
                width: MQ_Width*0.28,
                decoration: BoxDecoration(
                  color: Color(Helper.ButtonBorderPinkColor),
                  border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FlatButton(
                  onPressed: ()async{
                    Navigator.of(context).pop(true);
                    exit(0);
                    //ChangeNotify();
                  },
                  child: Text(
                    // isLocationEnabled?'CLOSE':'OPEN',
                    AppLocalizations.of(context)
                        .translate("Yes")
                        .toUpperCase(),
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
                margin:  EdgeInsets.only(left: 5,right: 5),

                height: 50,
                width: MQ_Width*0.28,
                decoration: BoxDecoration(
                  color: Helper.ButtonBorderGreyColor,//Color(Helper.ButtonBorderPinkColor),
                  border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FlatButton(
                  onPressed: ()async{
                    Navigator.of(context).pop(false);
                    back = false;
                     time = 0;
                     duration = 1000;

                  },
                  child: Text(

                    AppLocalizations.of(context)
                        .translate("No")
                        .toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    )??false; //if showDialouge had returned null, then return false
  }


  ChangeNotify() {
    
    if (_selectedTab == 0) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Constant.WelcomeRoute, (Route<dynamic> route) => false,);
    } else {
      setState(() {
        _selectedTab = 0;
      });
    }
  }
}
