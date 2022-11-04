import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/user.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/fluttertoast_alert.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:http/http.dart' as https;
import 'package:progress_dialog/progress_dialog.dart';

import '../../utilmethod/helper.dart';
import '../../utilmethod/network_connectivity.dart';
import '../../utilmethod/showDialog_networkerror.dart';

class ChatUser_Screen extends StatefulWidget {
  @override
  _ChatUser_ScreenState createState() => _ChatUser_ScreenState();
}

class _ChatUser_ScreenState extends State<ChatUser_Screen> {
  Size _screenSize;
  var MQ_Height;
  var MQ_Width;
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _visible, _listVisible;
  List<User> chat_list_online = [];
  List<User> chat_list_offline = [];
  var messages;
  double sizeheight = 0;
  TextEditingController _textController = TextEditingController();
  List<User> newDataList = [];
  bool checkRefresh=false;
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _connectivity = NetworkConnectivity.instance;
  bool networkEnable=true;
  var routeData;
  List<Color> _kDefaultRainbowColors = const [
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.pinkAccent,
    Colors.pink,
    Colors.pink,
    Colors.pinkAccent,

  ];

  onItemChanged(String value) {
    if(this.mounted)
    setState(() {
      newDataList = chat_list_offline
          .where((string) =>
              string.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();

    if (Constant.locationSubscription != null) {
      print("------@@@@@@@@@----1111111--------" +
          Constant.locationSubscription.isPaused.toString());
    } else {
      print("-------@@@@@@@@-----null nulll------");
    }

    _visible = false;
    _listVisible = true;
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() {
          _source = source;
          print('Chatuser ## source =$source, \n#c _source=${_source.keys.toList()[0]}');
          if(_source.keys.toList()[0]==ConnectivityResult.wifi){
            print('Chatuser ## ConnectivityResult.wifi _source=${_source.keys.toList()[0]}');
            networkEnable = true ;
          }
          else if(_source.keys.toList()[0]==ConnectivityResult.mobile){
            print('Chatuser ## ConnectivityResult.mobile _source=${_source.keys.toList()[0]}');
            networkEnable = true ;
          }else{
            print('Chatuser ## ConnectivityResult.none _source=${_source.keys.toList()[0]}');
            networkEnable = false ;
          }

        });
      }
    });


    if(networkEnable==true) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (await UtilMethod.SimpleCheckInternetConnection(
            context, _scaffoldKey)) {
          _showProgress(context);
          _chatItemList();
        }
      });
    }else{
      if (mounted) {
        setState(() {
        checkRefresh=true;
      });
      }
    }

    Future.delayed(const Duration(seconds: 30),(){
      if (mounted) {
        setState(() {
        checkRefresh=true;
      });
      }
      //   FlutterToastAlert.flutterToastMSG('checkRefresh=$checkRefresh', context);
    });
  }



  @override
  Widget build(BuildContext context) {
    routeData = ModalRoute.of(context).settings.arguments;
    _screenSize = MediaQuery.of(context).size;
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
                print('ChatUser Mobile networkEnable: $networkEnable');
                networkEnable = true;
                checkRefresh = true;
              });
            } catch (error) {
              print('ChatUser Mobile error: $error');
              networkEnable = true;
              checkRefresh = true;
            }
            break;
          case ConnectivityResult.wifi:
            string = 'Wifi: Online';
            //  FlutterToastAlert.flutterToastMSG('WiFi: Online', context);

            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('ChatUser Wifi networkEnable: $networkEnable');

                networkEnable = true;
                checkRefresh = true;
              });
            } catch (error) {
              print('ChatUser WiFi error: $error');
              networkEnable = true;
              checkRefresh = true;
            }

            break;
          case ConnectivityResult.none:
            string = 'Offline';
            // FlutterToastAlert.flutterToastMSG('Offline', context);
            try {
              Future.delayed(const Duration(seconds: 2), () {
                print('ChatUser Offline networkEnable: $networkEnable');
                networkEnable = false;
                checkRefresh = true;
              });
            } catch (error) {
              print('ChatUser Offline error: $error');
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
      onWillPop: ()async{
        Navigator.of(context).pushNamedAndRemoveUntil(
            Constant.NavigationRoute,
            ModalRoute.withName(Constant.WelcomeRoute),
            arguments: {"index": 0});

        return true;
      },
      child: SafeArea(
          child: Scaffold(

      //  key: _scaffoldKey,
        body: Visibility(
          visible:networkEnable&&_visible,
          replacement: checkRefresh!=true?Center(
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
          child: Container(
            padding: EdgeInsets.all(16),
            color: Color(Helper.inBackgroundColor1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CustomWigdet.TextView(
                    text: AppLocalizations.of(context).translate("Chats"),
                    fontSize: 20,
                    color: Custom_color.BlueDarkColor,
                    fontFamily: "OpenSans Bold"),
                chat_list_offline != null && chat_list_offline.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(top: 6, bottom: 6),
                        padding: EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(

                            boxShadow: [

                              BoxShadow(
                                color: Custom_color.GreyColor,
                                offset: Offset(1.0, 1.0), //(x,y)
                                blurRadius: 20.0,
                              ),
                            ],
                            color: Custom_color.WhiteColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: TextField(
                          style: TextStyle(
                              color: Custom_color.BlackTextColor,
                              fontFamily: "OpenSans Regular"),
                          controller: _textController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            //   contentPadding:
                            //  EdgeInsets.only(left: 15, right: 15),
                            prefixIcon: getImages(),
                            hintText:
                            AppLocalizations.of(context).translate("Search"),
                          ),
                          onChanged: onItemChanged,
                        ),
                      )
                    : Container(),

                CustomWigdet.TextView(
                    text:"",
                    fontFamily: "Kelvetica Nobis",
                    color: Custom_color.BlackTextColor),
                _listVisible
                    ? Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            chat_list_online != null &&
                                    chat_list_online.isNotEmpty
                                ? Container(





                                padding: EdgeInsets.only(left: 10,top: 20),
                    constraints: BoxConstraints(minHeight: 120,maxHeight: double.infinity),
                    decoration: BoxDecoration(
                        color:Colors.white,

                        boxShadow: [
                                  BoxShadow(
                                      color: Custom_color.GreyLightColor3,
                                      offset: Offset(1.0,1.0),
                                      blurRadius: 20
                                  )
                                ],

                                borderRadius: BorderRadius.circular(7)
                    ),
                    // constraints: BoxConstraints(maxWidth: _screenSize.width-35,minHeight: 120),


                    child: Stack(
                                children:[
                                  Padding(
                                    padding: const EdgeInsets.only(left:8.0),
                                    child: CustomWigdet.TextView(
                                        text: AppLocalizations.of(context)
                                            .translate("Online Users"),
                                        color:  Color(0xff05a820),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Kelvetica Nobis"),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: listViewWidget(context),
                                  )]))
                                : Container(

                                    margin: EdgeInsets.all(8.0),
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    width: _screenSize.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Custom_color.BlackTextColor,
                                            width: 1)),
                                    child: Center(
                                        child: CustomWigdet.TextView(
                                            fontFamily: "OpenSans Bold",
                                            text: AppLocalizations.of(context)
                                                .translate("User not online"),
                                            color: Custom_color.BlackTextColor,
                                            fontSize: 15)),
                                  ),
                            SizedBox(
                              height: 6,
                            ),


                            Expanded(
                              child: Container(


                                //height: 300,
                                padding: EdgeInsets.only(left: 10,top: 15),
                                  color: Color(Helper.inBackgroundColor1),
                                 /* decoration: BoxDecoration(

                                      boxShadow: [
                                        BoxShadow(
                                            color: Custom_color.GreyLightColor3,
                                            offset: Offset(1.0,1.0),
                                            blurRadius: 20
                                        )
                                      ],
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(7)
                                  ),*/
                               // constraints: BoxConstraints(maxWidth: _screenSize.width-35,minHeight: 120),


                                  child: Stack(
                                      children:[
                                        Padding(
                                          padding: const EdgeInsets.only(left:8.0),
                                          child: CustomWigdet.TextView(
                                              text: AppLocalizations.of(context)
                                                  .translate("User not online"),
                                              color:  Custom_color.GreyLightColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Kelvetica Nobis"),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(top: 30.0),
                                          child: listViewWidgetAll(context),
                                        )])),
                            ),
                          ],
                        ),
                      )
                    : Center(
                      child: Container(


                        child: CustomWigdet.TextView(
                            textAlign: TextAlign.center,
                            overflow: true,
                            text: messages.toString(),
                            color: Custom_color.BlackTextColor),
                      ),
                    ),


              ],

            ),
          ),
        ),
      )),
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
                          arguments: {"index": 2, "index_home": 0});
                    }
                  });
                }else{
                 // FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
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
                          arguments: {"index": 2, "index_home": 0});
                    }
                  });
                }else{
                  //FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context).translate("Please connect your internet")} ', context);
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


  Widget getImages() {
    return SessionManager.getString(Constant.Language_code) == "en" ||
            SessionManager.getString(Constant.Language_code) == "de"
        ? Icon(Icons.search)
        : RotatedBox(quarterTurns: 1, child: Icon(Icons.search));
  }

  Widget listViewWidget(
      BuildContext context,
      ) {
    return ListView.separated(
      //  physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, i) {
          final nDataList = newDataList[i];

          Future.delayed(Duration.zero, () {
            if (Constant.Check_ChatNotification) {
              if (routeData != null &&
                  routeData["user_id"] == nDataList.user_id) {
                Constant.Check_ChatNotification = false;
                nDataList.nomessage == 1
                    ? _asyncConfirmDialog(context)
                    : Navigator.pushNamed(context, Constant.ChatRoute,
                    arguments: {
                      "active": nDataList.active,
                      "chat_user_id": nDataList.user_id,
                      "user_id":
                      SessionManager.getString(Constant.LogingId),
                      "miu": nDataList.miu.toString(),
                      "name": nDataList.name,
                      "image": nDataList.profile_img,
                      "app_id": nDataList.app_id,
                      "login_user":
                      SessionManager.getString(Constant.Name)
                    });
              }
            }
          });

          return newDataList.length > 0
              ? getlistchatItem(nDataList, newDataList[i].count)
              : Container();
        },
        itemCount: newDataList == null ? 0 : newDataList.length,
        separatorBuilder:(context, index){
          return
            SizedBox(height: 4);

        }
    );
  }
  Widget listViewWidgetAll(
    BuildContext context,
  ) {
    return ListView.separated(
      //  physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) {
        final nDataList = newDataList[i];

        Future.delayed(Duration.zero, () {
          if (Constant.Check_ChatNotification) {
            if (routeData != null &&
                routeData["user_id"] == nDataList.user_id) {
              Constant.Check_ChatNotification = false;
              nDataList.nomessage == 1
                  ? _asyncConfirmDialog(context)
                  : Navigator.pushNamed(context, Constant.ChatRoute,
                      arguments: {
                          "active": nDataList.active,
                          "chat_user_id": nDataList.user_id,
                          "user_id":
                              SessionManager.getString(Constant.LogingId),
                          "miu": nDataList.miu.toString(),
                          "name": nDataList.name,
                          "image": nDataList.profile_img,
                          "app_id": nDataList.app_id,
                          "login_user":
                              SessionManager.getString(Constant.Name)
                        });
            }
          }
        });

        return newDataList.length > 0
            ? getlistchatItemAll(nDataList)
            : Container();
      },
      itemCount: newDataList == null ? 0 : newDataList.length,
      separatorBuilder:(context, index){
        return
        SizedBox(height: 4);

      }
    );
  }

  Widget getlistchatItem(User chat_item,var checkCounter) {

  print('getlistchatItem ## checkCounter=$checkCounter');

    return chat_item.online == Constant.UserOnline
        ? InkWell(
        onTap: () {
          chat_item.nomessage == 1
              ? _asyncConfirmDialog(context)
              : Navigator.pushNamed(context, Constant.ChatRoute,
              arguments: {
                "history":chat_item.historyList,
                "active": chat_item.active,
                "chat_user_id": chat_item.user_id,
                "user_id":
                SessionManager.getString(Constant.LogingId),
                "miu": chat_item.miu.toString(),
                "name": chat_item.name,
                "image": chat_item.profile_img,
                "blocked": chat_item.blocked,
                "youblocked": chat_item.youblocked,
                "app_id": chat_item.app_id,
                "login_user": SessionManager.getString(Constant.Name)

              }).then((value) async {
            if (Constant.locationSubscription != null) {
              print("------@@@@@@@@@----1111111--------" +
                  Constant.locationSubscription.isPaused.toString());
            } else {
              print("-------@@@@@@@@-----null nulll------");
            }
            if (await UtilMethod.SimpleCheckInternetConnection(
                context, _scaffoldKey)) {
              _showProgress(context);
              _chatItemList();
            }
          });
        },
        child:

        Container(


          //padding: EdgeInsets.only(top:20),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      //  _asyncViewProfileDialog(context,chat_item.profile_img);
                      Navigator.pushNamed(context, Constant.ChatUserDetail,
                          arguments: {"user_id": chat_item.user_id, "type": "3"});
                      chat_item.count=0 ;
                    },
                    child: CircleAvatar(
                      backgroundColor: Custom_color.PlacholderColor,
                      radius: 30,
                      backgroundImage: NetworkImage(chat_item.profile_img,scale: 1.0),
                    ),
                  ),
                  chat_item.count > 0
                      ? Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Custom_color.WhiteColor, width: 1)),
                      child: Container(
                        height: 20.0,
                        width: 20.0,
                        // padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Custom_color.BlueLightColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                            child: CustomWigdet.TextView(
                                fontSize: 10,
                                overflow: true,
                                textAlign: TextAlign.center,
                                fontFamily: "Kelvetica Nobis",
                                text: chat_item.count.toString(),
                                color: Custom_color.WhiteColor)),
                      ),
                    ),
                  )
                      : Container(child: Positioned(
                    top: 5,
                    right: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Color(0xff52d167),
                              width: 1)),
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Color(0xff52d167)
                      ),
                    ),
                  ),

                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {

                  chat_item.nomessage == 1
                      ? _asyncConfirmDialog(context)
                      : Navigator.pushNamed(context, Constant.ChatRoute,
                      arguments: {
                        "history":chat_item.historyList,
                        "active": chat_item.active,
                        "chat_user_id": chat_item.user_id,
                        "user_id":
                        SessionManager.getString(Constant.LogingId),
                        "miu": chat_item.miu.toString(),
                        "name": chat_item.name,
                        "image": chat_item.profile_img,
                        "app_id": chat_item.app_id,
                        "blocked": chat_item.blocked,
                        "youblocked": chat_item.youblocked,
                        "login_user":
                        SessionManager.getString(Constant.Name)
                      }).then((value) async {
                    if (await UtilMethod.SimpleCheckInternetConnection(
                        context, _scaffoldKey)) {
                      _showProgress(context);
                      _chatItemList();
                    }
                  });
                },
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomWigdet.TextView(
                        text: chat_item.name,
                        color: Custom_color.BlackTextColor,
                        fontFamily: "Kelvetica Nobis",
                        fontSize: 14),
                    SizedBox(
                      height: 2,
                    ),
                    Container(
                      width: 240,
                      padding: EdgeInsets.only(bottom:8),
                      child: CustomWigdet.TextView(
                          overflow: true,
                          text: chat_item.message ,

                          color: Custom_color.GreyLightColor,
                          fontSize: 14),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
    ):Container();
  }



//================== Old Ui getListChatItem view =============

  Widget getlistchatItemAll1(User chat_item) {



    return chat_item.online == Constant.UserOffline
        ? InkWell(
        onTap: () {
      chat_item.nomessage == 1
          ? _asyncConfirmDialog(context)
          : Navigator.pushNamed(context, Constant.ChatRoute,
          arguments: {
            "history":chat_item.historyList,
            "active": chat_item.active,
            "chat_user_id": chat_item.user_id,
            "user_id":
            SessionManager.getString(Constant.LogingId),
            "miu": chat_item.miu.toString(),
            "name": chat_item.name,
            "image": chat_item.profile_img,
            "blocked": chat_item.blocked,
            "youblocked": chat_item.youblocked,
            "app_id": chat_item.app_id,
            "login_user": SessionManager.getString(Constant.Name)
          }).then((value) async {
        if (Constant.locationSubscription != null) {
          print("------@@@@@@@@@----1111111--------" +
              Constant.locationSubscription.isPaused.toString());
        } else {
          print("-------@@@@@@@@-----null nulll------");
        }
        if (await UtilMethod.SimpleCheckInternetConnection(
            context, _scaffoldKey)) {
          _showProgress(context);
          _chatItemList();
        }
      });
    },
    child:

      Container(


        //padding: EdgeInsets.only(top:20),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                InkWell(
                  onTap: () {
                    //  _asyncViewProfileDialog(context,chat_item.profile_img);
                    Navigator.pushNamed(context, Constant.ChatUserDetail,
                        arguments: {"user_id": chat_item.user_id, "type": "3"});
                  },
                  child: CircleAvatar(
                    backgroundColor: Custom_color.PlacholderColor,
                    radius: 30,
                    backgroundImage: NetworkImage(chat_item.profile_img,scale: 1.0),
                  ),
                ),
                chat_item.count > 0
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Custom_color.WhiteColor, width: 1)),
                          child: Container(
                            height: 20.0,
                            width: 20.0,
                            // padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Custom_color.BlueLightColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                                child: CustomWigdet.TextView(
                                    fontSize: 10,
                                    overflow: true,
                                    textAlign: TextAlign.center,
                                    fontFamily: "Kelvetica Nobis",
                                    text: chat_item.count.toString(),
                                    color: Custom_color.WhiteColor)),
                          ),
                        ),
                      )
                    : Container(child: Positioned(
                  top: 5,
                  right: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Custom_color.GreyLightColor,
                            width: 1)),
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: Custom_color.GreyColor,
                    ),
                  ),
                ),

                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                chat_item.nomessage == 1
                    ? _asyncConfirmDialog(context)
                    : Navigator.pushNamed(context, Constant.ChatRoute,
                        arguments: {
                            "history":chat_item.historyList,
                            "active": chat_item.active,
                            "chat_user_id": chat_item.user_id,
                            "user_id":
                                SessionManager.getString(Constant.LogingId),
                            "miu": chat_item.miu.toString(),
                            "name": chat_item.name,
                            "image": chat_item.profile_img,
                            "app_id": chat_item.app_id,
                            "blocked": chat_item.blocked,
                            "youblocked": chat_item.youblocked,
                            "login_user":
                                SessionManager.getString(Constant.Name)
                          }).then((value) async {
                        if (await UtilMethod.SimpleCheckInternetConnection(
                            context, _scaffoldKey)) {
                          _showProgress(context);
                          _chatItemList();
                        }
                      });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomWigdet.TextView(
                      text: chat_item.name,
                      color: Custom_color.BlackTextColor,
                      fontFamily: "Kelvetica Nobis",
                      fontSize: 14),
                  SizedBox(
                    height: 2,
                  ),
                  Container(
                    width: 240,
                    padding: EdgeInsets.only(bottom :8),
                    child: CustomWigdet.TextView(
                        overflow: true,
                        text: chat_item.message,
                        color: Custom_color.GreyLightColor,
                        fontSize: 14),
                  )
                ],
              ),
            ),
          ],
        ),
      )
    ):Container();

  }


//================== New Ui getListChatItem view =============

  Widget getlistchatItemAll(User chat_item) {
    return chat_item.online == Constant.UserOffline
        ?InkWell(
      onTap: () {
        chat_item.nomessage == 1
            ? _asyncConfirmDialog(context)
            : Navigator.pushNamed(context, Constant.ChatRoute,
            arguments: {
              "history":chat_item.historyList,
              "active": chat_item.active,
              "chat_user_id": chat_item.user_id,
              "user_id":
              SessionManager.getString(Constant.LogingId),
              "miu": chat_item.miu.toString(),
              "name": chat_item.name,
              "image": chat_item.profile_img,
              "blocked": chat_item.blocked,
              "youblocked": chat_item.youblocked,
              "app_id": chat_item.app_id,
              "login_user": SessionManager.getString(Constant.Name)
            }).then((value) async {
          if (Constant.locationSubscription != null) {
            print("------@@@@@@@@@----1111111--------" +
                Constant.locationSubscription.isPaused.toString());
          } else {
            print("-------@@@@@@@@-----null nulll------");
          }
          if (await UtilMethod.SimpleCheckInternetConnection(
              context, _scaffoldKey)) {
            _showProgress(context);
            _chatItemList();
          }
        });
      },
      child: Container(
        //padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
        child: Stack(
          //  crossAxisAlignment: CrossAxisAlignment.start,
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              // width: 300,
              // height: 150,
              margin: EdgeInsets.only(left: MQ_Width*0.08,right: MQ_Height*0.01),
              padding: EdgeInsets.only(left: MQ_Width*0.14,top: MQ_Height*0.01,bottom: MQ_Height*0.01),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[



                  /*Container(
                    margin: EdgeInsets.only(top: 5,bottom: 2),
                    width: 40,
                    height: 1.0,
                    color: Color(0xfffb4592),//Colors.purpleAccent,
                  ),
                  SizedBox(
                    height: MQ_Height*0.02,
                  ),*/
                  InkWell(
                    onTap: () async{
                      chat_item.nomessage == 1
                          ? _asyncConfirmDialog(context)
                          : Navigator.pushNamed(context, Constant.ChatRoute,
                          arguments: {
                            "history":chat_item.historyList,
                            "active": chat_item.active,
                            "chat_user_id": chat_item.user_id,
                            "user_id":
                            SessionManager.getString(Constant.LogingId),
                            "miu": chat_item.miu.toString(),
                            "name": chat_item.name,
                            "image": chat_item.profile_img,
                            "app_id": chat_item.app_id,
                            "blocked": chat_item.blocked,
                            "youblocked": chat_item.youblocked,
                            "login_user":
                            SessionManager.getString(Constant.Name)
                          }).then((value) async {
                        if (await UtilMethod.SimpleCheckInternetConnection(
                            context, _scaffoldKey)) {
                          _showProgress(context);
                          _chatItemList();
                        }
                      });
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 2,bottom: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(top: 15,bottom: 2),
                            child: Text( chat_item.name,
                              style: TextStyle(color:Helper.textColorBlueH1,
                                  fontFamily: "Kelvetica Nobis",
                                  fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH13),),
                          ),
                          false?Container(
                              margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                              padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                              child:
                              ClipOval(
                                child: Material(
                                  color: Colors.grey.shade500,//Helper.inIconCircleBlueColor1, // Button color
                                  child: InkWell(
                                    splashColor: Helper.inIconCircleBlueColor1, // Splash color
                                    onTap: () {},
                                    child: SizedBox(width: 20, height: 20,
                                        child:Icon(Icons.location_on,size: 14,color: Colors.white,)
                                    ),
                                  ),
                                ),
                              )
                          ):Container(),
                          Container(
                            //width: MQ_Width*0.50,
                            child: Text(chat_item.message,
                              style: TextStyle(color:Color(Helper.textColorBlackH2),
                                  fontFamily: "Kelvetica Nobis",
                                  fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH15),),
                          ),
                        ],
                      ),
                    ),
                  ),


                  SizedBox(
                    height: MQ_Height*0.02,
                  ),




//                    action != Action.ActivityWall
//                        ? getRowItem(
//                            nDataList.members.toString(),
//                            AppLocalizations.of(context).translate("Members"),
//                          )
//                        : Container(),
                ],
              ),
            ),
            
            false?Container(
              width: 60,
              height: 60,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Custom_color.PlacholderColor,
                  image: DecorationImage(
                      image: NetworkImage(
                          chat_item.profile_img != null ? chat_item.profile_img : ""),
                      onError: (exception, stackTrace) {
                        print("---eroor-----" +
                            exception.toString() +
                            "--11111--" +
                            stackTrace.toString());
                        print("-------print0000---------" +
                            exception.hashCode.toString());
                      },
                      fit: BoxFit.cover)),
            ):Container(
              alignment: Alignment.centerLeft,
              child: ClipOval(
                child: Material(
                  color: Colors.grey.shade500,//Helper.inIconCircleBlueColor1, // Button color
                  child: InkWell(
                    splashColor: Helper.inIconCircleBlueColor1, // Splash color
                    onTap: () {
                      Navigator.pushNamed(context, Constant.ChatUserDetail,
                          arguments: {"user_id": chat_item.user_id, "type": "3"});
                    },
                    child: SizedBox(width: 65, height: 65,
                        child:Image(image: NetworkImage(
                            chat_item.profile_img != null ? chat_item.profile_img : "",scale: 1.0))
                    ),
                  ),
                ),
              ),
            ),

            chat_item.count > 0
                ? Positioned(
              bottom: 18,
              left:50 ,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Custom_color.WhiteColor, width: 1)),
                child: Container(
                  height: 20.0,
                  width: 20.0,
                  // padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Custom_color.BlueLightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: CustomWigdet.TextView(
                          fontSize: 10,
                          overflow: true,
                          textAlign: TextAlign.center,
                          fontFamily: "Kelvetica Nobis",
                          text: chat_item.count.toString(),
                          color: Custom_color.WhiteColor)),
                ),
              ),
            )
                : Container(child: Positioned(
              //top: 5,
             // right: 1,
              child: false?Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Custom_color.GreyLightColor,
                        width: 1)),
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Custom_color.GreyColor,
                ),
              ):Container(),
            ),

            ),
          ],
        ),
      ),
    ):Container();
  }


  Future _asyncViewProfileDialog(
      BuildContext context, String profile_img) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Container(
                  child: Image.network(profile_img),
                ),
                Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () {
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

  Future<List<User>> _chatItemList() async {
    try {
      if (chat_list_offline != null && !chat_list_offline.isEmpty) {
        chat_list_offline.clear();
        chat_list_online.clear();
      }
      String url = WebServices.GetChatUser +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("---Url----" + url.toString());
      print("chatuser _chatItemList ## url=${url}");

      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse--111--" + response.body);
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
        if (data["status"]) {
          List offline_data = data["offline"];
          List online_data = data["online"];

          if (offline_data != null && offline_data.isNotEmpty) {
            chat_list_offline =
                offline_data.map<User>((i) => User.fromJson(i)).toList();
            newDataList = List.from(chat_list_offline);
          }
          if (online_data != null && online_data.isNotEmpty) {
            chat_list_online =
                online_data.map<User>((i) => User.fromJson(i)).toList();
          }

          //  setState(() {
          if (mounted) {
            setState(() {
              _listVisible = true;
              _visible = true;
            });
          }
          //   });
        } else {
          if (mounted) {
            setState(() {
              _listVisible = false;
            });
          }
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
          });
        }
      }

      return newDataList;
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future _asyncConfirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
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
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              title: Text(
                AppLocalizations.of(context).translate("Alert"),
                style: TextStyle(color: Custom_color.BlackTextColor),
              ),
              content: Text(
                AppLocalizations.of(context)
                    .translate("Your chat will be start once user reply"),
                style: TextStyle(color: Custom_color.BlackTextColor,fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH12),
              ),
              actions: [
                Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(left: MQ_Width * 0.06,
                      right: MQ_Width * 0.06,
                      top: MQ_Height * 0.02,
                      bottom: MQ_Height * 0.01),
                  padding: EdgeInsets.only(bottom: 5),
                  height: 50,
                  width: MQ_Width * 0.25,
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
        );
      },
    );
  }
  _showProgress(BuildContext context) {
    // progressDialog = new ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    // progressDialog.style(
    //     message: AppLocalizations.of(context).translate("Loading"),
    //     progressWidget: CircularProgressIndicator());
    //progressDialog.show();
  }


  _showProgress1(BuildContext context) {
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
        padding: EdgeInsets.only(left:
        MQ_Width*0.30,right: MQ_Width*0.30),
        child: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            /* decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xfff16cae).withOpacity(0.3),
                  Color(0xff3f86c6).withOpacity(0.3),
                ],
              )
          ),*/
            child: Center(
              child: Container(
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
    try
    {
    if (progressDialog != null) {
      progressDialog.hide();
    }
    }catch(e){}
  }

  @override
  void cc(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  /*
  @override
  void dispose() {
    // print("-----------------disponse-------111111111111111---");
    if (Constant.locationSubscription == null) {
      if (Constant.socket != null) {
        Constant.socket.disconnect();
        Constant.socket.close();
        Constant.socket.clearListeners();
        Constant.socket.dispose();
      }
    }
    super.dispose();
  }
  */


  @override
  void dispose() {
    // TODO: implement dispose
    _hideProgress();
    try{
      _connectivity.disposeStream();
      _source.clear();
    }catch(error){
      print('_connectivity disponse error=$error');
    }
    super.dispose();
  }
}
