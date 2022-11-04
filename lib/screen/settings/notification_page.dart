import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/user.dart';
import 'package:miumiu/screen/pages/provider/model.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../../utilmethod/helper.dart';

class Notification_Screen extends StatefulWidget {
  @override
  _Notification_ScreenState createState() => _Notification_ScreenState();
}

class _Notification_ScreenState extends State<Notification_Screen> {
  Size _screenSize;
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _visible, _listVisible;
  List<User> fav_list = [];
  var routeData;
  var messages;
  bool leading;
  // Counter counter = Counter();
  CounterModel counterModel;
  var MQ_Height;
  var MQ_Width;
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
  void initState() {
    leading = false;
    _visible = false;
    _listVisible = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _ItemList();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("------routedata--------"+routeData.toString());
     //counterModel = Provider.of<CounterModel>(context,listen: false);

    routeData = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    if(routeData!=null)
      {
        if(routeData["appbar"]!=null)
          {
            leading = routeData["appbar"];
          }
      }
    _screenSize = MediaQuery.of(context).size;
    MQ_Height= MediaQuery.of(context).size.height;
    MQ_Width=MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      body: Stack(children: [
        //_widgetNotificationScreen()
        _widgetNotificationScreenNewUI()

      ],),
    ));
  }

  //============ Old UI Notification Screen =============

  Widget _widgetNotificationScreen(){
    return Visibility(
      visible: _visible,
      replacement: Center(
        child: CircularProgressIndicator(),
      ),
      child: Stack(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [


                Padding(
                  padding: const EdgeInsets.only(bottom: 35.0),
                  child: Container(
                    height: 150.0,
                    decoration: BoxDecoration(

                        gradient: LinearGradient(colors: [Color(0xff23b8f2), Color(0xff1b5dab)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)
                    ),
                  ),
                ),
                Image(image: AssetImage("assest/images/curve.png")),
                Positioned(
                  top: 20,
                  left: 15,
                  child: InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      radius: 17,
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
                  ),
                ),
                Positioned(
                  top: 50,
                  child: Text(AppLocalizations.of(context).translate("Notifications"),
                    style: TextStyle(
                        fontFamily: "Kelvetica Nobis",
                        fontSize: 19,
                        color: Colors.white
                    ),),
                )
              ],
            ),

            Container(
              padding: EdgeInsets.only(top:150,left:15,right:15),
              child: _listVisible
                  ? Container(child: listViewWidget(context))
                  : Center(
                child: Container(
                  child: CustomWigdet.TextView(
                      textAlign: TextAlign.center,
                      overflow: true,
                      text: messages.toString(),
                      color: Custom_color.BlackTextColor),
                ),
              ),
            ),]
      ),
    );
  }


  //============ New UI Notification Screen =============

  Widget _widgetNotificationScreenNewUI(){
    return Visibility(
      visible: _visible,
      replacement: Center(
        child: false?CircularProgressIndicator():Container(
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
      child: Stack(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [


                Padding(
                  padding: const EdgeInsets.only(bottom: 35.0),
                  child: Container(
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: Colors.white

                    ),
                  ),
                ),
               // Image(image: AssetImage("assest/images/curve.png")),
                Positioned(
                  top: 20,
                  left: 15,
                  child: InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: false?CircleAvatar(
                      radius: 17,
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
                        padding: const EdgeInsets.only(left: 10.0,top: 5),
                        child:  Container(
                          child: SvgPicture.asset('assest/images_svg/back.svg',color: Custom_color.BlueLightColor,width: 20,height: 20,),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 60,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context).translate("Notifications"),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontFamily: "Kelvetica Nobis",
                          fontSize: Helper.textSizeH11,
                          fontWeight: Helper.textFontH5,
                          color:Helper.textColorBlueH1
                      ),),
                  ),
                )
              ],
            ),

            Container(

              padding: EdgeInsets.only(top:65,left:15,right:15),
              child: _listVisible
                  ? Container(
                  color: Color(Helper.inBackgroundColor1),
                  child: listViewWidget(context))
                  : Center(
                child: Container(
                  child: CustomWigdet.TextView(
                      textAlign: TextAlign.center,
                      overflow: true,
                      text: messages.toString(),
                      color: Custom_color.BlackTextColor),
                ),
              ),
            ),]
      ),
    );
  }

  Widget listViewWidget(BuildContext context) {
    return fav_list.length>0? ListView.separated(
          physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        final nDataList = fav_list[i];
        print("-----chatlean----" + fav_list.length.toString());
        return getlistchatItem(nDataList);

      },
      itemCount: fav_list == null ? 0 : fav_list.length ,
      separatorBuilder: (BuildContext context, int index) {
        return false?Divider(
          color: Custom_color.ColorDivider,
        ):Container(
          margin: EdgeInsets.all(5),
        );
      },
    ):Center(
      child: Container(
        child: CustomWigdet.TextView(
            text: AppLocalizations.of(context)
                .translate("There is no message"),
            color: Custom_color.BlackTextColor,
            fontSize: 14),
      ),
    );
  }

  //============== Old UI get list chat Item ================
  Widget getlistchatItem1(User nDataList) {
    return Container(
      color: nDataList.status==1? Custom_color.PlacholderColor:Colors.transparent,
      child: ListTile(
        onTap: () {
          if (nDataList.type == 1 || nDataList.type == 2) {
            Navigator.pushNamed(context, Constant.ChatUserDetail,
                arguments: {"user_id": nDataList.user_id.toString(), "type": "4"}).then((value) async {
              if (await UtilMethod.SimpleCheckInternetConnection(
                  context, _scaffoldKey)) {
                _showProgress(context);
                _ItemList();
              }
            });
          } else if (nDataList.type == 3) {
            Navigator.pushNamed(context, Constant.ChatRoute, arguments: {
              "active":true,
              "chat_user_id": nDataList.user_id.toString(),
              "user_id": SessionManager.getString(Constant.LogingId),
              "miu": "1",
              "name": nDataList.name,
              "image": nDataList.profile_img
            }).then((value) async {
              if (await UtilMethod.SimpleCheckInternetConnection(
                  context, _scaffoldKey)) {
                _showProgress(context);
                _ItemList();
              }
            });
          }else if (nDataList.type == 4 || nDataList.type == 5) {
            Navigator.pushNamed(context, Constant.ChatRoute, arguments: {
              "active":true,
              "chat_user_id": nDataList.user_id.toString(),
              "user_id": SessionManager.getString(Constant.LogingId),
              "miu": "0",
              "name": nDataList.name,
              "image": nDataList.profile_img
            }).then((value) async {
              if (await UtilMethod.SimpleCheckInternetConnection(
                  context, _scaffoldKey)) {
                _showProgress(context);
                _ItemList();
              }
            });
          }
        },
        leading: CircleAvatar(
          backgroundColor:nDataList.status==1?Custom_color.WhiteColor: Custom_color.PlacholderColor,
          radius: 28,
          backgroundImage:
              NetworkImage(nDataList.profile_img,scale: 1.0),
        ),
        title: CustomWigdet.TextView(
          text: nDataList.name,
          color: Custom_color.BlackTextColor,
          fontFamily: "OpenSans Bold",
        ),
        subtitle: CustomWigdet.TextView(
          overflow: true,
          text: nDataList.title,
          color: Custom_color.GreyLightColor,
        ),
//        trailing: nDataList.type==0? InkWell(
//          borderRadius: BorderRadius.circular(30),
//          onTap: () async {
//            print("-------info-------"+nDataList.user_id);
//            if (await UtilMethod.SimpleCheckInternetConnection(
//            context, _scaffoldKey)){
//              _DeletedInfo(nDataList.user_id);
//            }
//          },
//          child: Icon(
//            Icons.highlight_off,
//            color: Custom_color.RedColor,
//            size: 25,
//          ),
//        ):null,
      ),
    );
  }

  //================== New Ui getListChatItem view =============

  Widget getlistchatItem(User nDataList) {
    return InkWell(
      onTap: () {
        if (nDataList.type == 1 || nDataList.type == 2) {
          Navigator.pushNamed(context, Constant.ChatUserDetail,
              arguments: {"user_id": nDataList.user_id.toString(), "type": "4"}).then((value) async {
            if (await UtilMethod.SimpleCheckInternetConnection(
                context, _scaffoldKey)) {
              _showProgress(context);
              _ItemList();
            }
          });
        } else if (nDataList.type == 3) {
          Navigator.pushNamed(context, Constant.ChatRoute, arguments: {
            "active":true,
            "chat_user_id": nDataList.user_id.toString(),
            "user_id": SessionManager.getString(Constant.LogingId),
            "miu": "1",
            "name": nDataList.name,
            "image": nDataList.profile_img
          }).then((value) async {
            if (await UtilMethod.SimpleCheckInternetConnection(
                context, _scaffoldKey)) {
              _showProgress(context);
              _ItemList();
            }
          });
        }else if (nDataList.type == 4 || nDataList.type == 5) {
          Navigator.pushNamed(context, Constant.ChatRoute, arguments: {
            "active":true,
            "chat_user_id": nDataList.user_id.toString(),
            "user_id": SessionManager.getString(Constant.LogingId),
            "miu": "0",
            "name": nDataList.name,
            "image": nDataList.profile_img
          }).then((value) async {
            if (await UtilMethod.SimpleCheckInternetConnection(
                context, _scaffoldKey)) {
              _showProgress(context);
              _ItemList();
            }
          });
        }
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
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 2,bottom: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(top: 15,bottom: 2),
                          child: Text( nDataList.name,
                            style: TextStyle(color:Helper.textColorBlueH1,
                                fontFamily: "Kelvetica Nobis",
                                fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH13),),
                        ),
                        Container(
                          //width: MQ_Width*0.50,
                          child: Text( '${nDataList.title??''}',
                            style: TextStyle(color:Color(Helper.textColorBlackH2),
                                fontFamily: "Kelvetica Nobis",
                                fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH15),),
                        ),
                      ],
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
            Container(
              alignment: Alignment.centerLeft,
              child: ClipOval(
                child: Material(
                  color: Colors.grey.shade500,//Helper.inIconCircleBlueColor1, // Button color
                  child: InkWell(
                    splashColor: Helper.inIconCircleBlueColor1, // Splash color
                    onTap: () {
                     /* Navigator.pushNamed(context, Constant.ChatUserDetail,
                          arguments: {"user_id": chat_item.user_id, "type": "3"});*/
                    },
                    child: SizedBox(width: 65, height: 65,
                        child:Image(image: NetworkImage(
                            nDataList.profile_img!= null ?nDataList.profile_img: "",scale: 1.0))
                    ),
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      title: CustomWigdet.TextView(
          text: AppLocalizations.of(context).translate("Notification"),
          color: Custom_color.BlackTextColor,
          fontFamily: "OpenSans Bold"),
      bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: _screenSize.width,
                  height: 0.5,
                  color: Custom_color.BlueLightColor,
                ),
              ),
            ],
          ),
          preferredSize: Size.fromHeight(0.0)),
      leading: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: Icon(
          Icons.arrow_back,
          color: Custom_color.BlueLightColor,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  get _appbarNotify {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0), // here the desired height
      child: AppBar(
        automaticallyImplyLeading: false,
        title: CustomWigdet.TextView(
            text: AppLocalizations.of(context).translate("Notification"),
            textAlign: TextAlign.center,
            color: Custom_color.WhiteColor,
            fontFamily: "OpenSans Bold"),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30))),
      ),
    );
  }

  Future<List<User>> _ItemList() async {
    try {
      if (fav_list != null && !fav_list.isEmpty) {
        fav_list.clear();
      }

      String url = WebServices.GetNotification +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {

          var count = data["chatcount"];
          if (count != null) {
          //  SessionManager.setString(Constant.ChatCount, count.toString());
            UtilMethod.SetChatCount(context, count.toString());

          }

          var notification_count = data["notification_count"];
          if (notification_count != null) {
         //   SessionManager.setString(Constant.NotificationCount, notification_count.toString());
            UtilMethod.SetNotificationCount(context, notification_count.toString());
          }


          List userlist = data["notification"];

          if (userlist != null && userlist.isNotEmpty) {
            fav_list = userlist.map<User>((i) => User.fromJson(i)).toList();
          }

          setState(() {
            _listVisible = true;
          });
        } else {
          setState(() {
            _listVisible = false;
          });
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
        });
      }

      return fav_list;
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future<https.Response> _DeletedInfo(String id) async {
    try {
      print("------inside------" + id.toString());
      _showProgress(context);
      Map jsondata = {"user_id": id};
      String url =
          WebServices.GetFavorite + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          if (fav_list != null && !fav_list.isEmpty) {
            fav_list.clear();
          }
          List userlist = data["user"];

          if (userlist != null && userlist.isNotEmpty) {
            fav_list = userlist.map<User>((i) => User.fromJson(i)).toList();
          }

          setState(() {
            _listVisible = true;
          });
          messages = data["message"].toString();
          UtilMethod.SnackBarMessage(_scaffoldKey, messages.toString());
        } else {
          messages = data["message"].toString();
          setState(() {
            _listVisible = false;
          });
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

  _showProgress(BuildContext context) {
    progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    progressDialog.style(
        message: AppLocalizations.of(context).translate("Loading"),
        progressWidget: CircularProgressIndicator());
    //progressDialog.show();
  }

  _hideProgress() {
    if (progressDialog != null) {
      progressDialog.hide();
    }
  }
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
