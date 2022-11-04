import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/user.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../../utilmethod/helper.dart';

class Favorites_Screen extends StatefulWidget {
  @override
  _Favorites_ScreenState createState() => _Favorites_ScreenState();
}

class _Favorites_ScreenState extends State<Favorites_Screen> {
  Size _screenSize;
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _visible, _listVisible;
  List<User> fav_list = [];

  var messages;
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
    _screenSize = MediaQuery.of(context).size;
    MQ_Height= MediaQuery.of(context).size.height;
    MQ_Width=MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      appBar: _getAppbar,
      key: _scaffoldKey,
      body: Stack(children: [
        //_widgetFavoritesScreen()
        _widgetFavoritesScreenNewUI()
      ],)
    ));
  }

  //============== Old Ui Favorites Screen===========

  Widget _widgetFavoritesScreen(){
    return Visibility(
      visible: _visible,
      replacement: Center(
        child: CircularProgressIndicator(),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: _listVisible
            ? Container(child: listViewWidget(context))
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: CustomWigdet.TextView(
                    textAlign: TextAlign.center,
                    overflow: true,
                    text: messages.toString(),
                    color: Custom_color.BlackTextColor),
              ),
              SizedBox(height: 10,),
              CustomWigdet.RoundRaisedButtonWithWrap(onPress: (){   Navigator.of(context).pushNamedAndRemoveUntil(
                  Constant.NavigationRoute,
                  ModalRoute.withName(Constant.WelcomeRoute),
                  arguments: {"index": 0});},text: AppLocalizations.of(context).translate("View Profile"),textColor: Custom_color.WhiteColor,bgcolor: Custom_color.BlueLightColor,fontFamily: "OpenSans Bold")
            ],
          ),
        ),
      ),
    );
  }

  //============== New Ui Favorites Screen ===========

  Widget _widgetFavoritesScreenNewUI(){
    return Visibility(
      visible: _visible,
      replacement:false? Center(
        child: CircularProgressIndicator(),
      ):Center(
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
      ),
      child: Container(
        color: Color(Helper.inBackgroundColor1),
        padding: EdgeInsets.all(10),
        child: _listVisible
            ? Container(

            child: listViewWidget(context))
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: CustomWigdet.TextView(
                    textAlign: TextAlign.center,
                    overflow: true,
                    text: messages.toString(),
                    color: Custom_color.BlackTextColor),
              ),
              SizedBox(height: 10,),
              CustomWigdet.RoundRaisedButtonWithWrap(onPress: (){   Navigator.of(context).pushNamedAndRemoveUntil(
                  Constant.NavigationRoute,
                  ModalRoute.withName(Constant.WelcomeRoute),
                  arguments: {"index": 0});},text: AppLocalizations.of(context).translate("View Profile"),textColor: Custom_color.WhiteColor,bgcolor: Custom_color.BlueLightColor,fontFamily: "OpenSans Bold")
            ],
          ),
        ),
      ),
    );
  }

  Widget listViewWidget(BuildContext context) {
    return ListView.separated(
        physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        final nDataList = fav_list[i];
        print("-----chatlean----" + fav_list.length.toString());
        return fav_list.length > 0
            ? getlistchatItem(nDataList)
            : Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Custom_color.BlueLightColor, width: 0.5)),
                child: CustomWigdet.TextView(
                    text: AppLocalizations.of(context)
                        .translate("User not online"),
                    color: Custom_color.GreyLightColor,
                    fontSize: 12),
              );
      },
      itemCount: fav_list == null ? 0 : fav_list.length,
      separatorBuilder: (BuildContext context, int index) {
        return false?Divider(
          color: Custom_color.ColorDivider,
        ):Container(margin: EdgeInsets.all(5),);
      },
    );
  }
//================== New Ui getListChatItem view =============
  Widget getlistchatItem1(User nDataList) {
    return Container(
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, Constant.ChatUserDetail,
              arguments: {"user_id": nDataList.user_id, "type": "4"}).then((value) async {
            if (await UtilMethod.SimpleCheckInternetConnection(
            context, _scaffoldKey)) {
              _showProgress(context);
            _ItemList();
            }
          });
        },
        leading: CircleAvatar(
          backgroundColor: Custom_color.PlacholderColor,
          radius: 28,
          backgroundImage:
              NetworkImage(Constant.ImageURL + nDataList.profile_img),
        ),
        title: CustomWigdet.TextView(
          text: nDataList.name,
          color: Custom_color.BlackTextColor,
          fontFamily: "OpenSans Bold",
        ),
        subtitle: CustomWigdet.TextView(
          text: nDataList.message,
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
        Navigator.pushNamed(context, Constant.ChatUserDetail,
            arguments: {"user_id": nDataList.user_id, "type": "4"}).then((value) async {
          if (await UtilMethod.SimpleCheckInternetConnection(
              context, _scaffoldKey)) {
            _showProgress(context);
            _ItemList();
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
                          child: Text( nDataList.message,
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
                            Constant.ImageURL + nDataList.profile_img,scale: 1.0))
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
      backgroundColor: Colors.white,//Colors.transparent,
      elevation: 0.0,
      //centerTitle: true,
      title: CustomWigdet.TextView(
          text: AppLocalizations.of(context).translate("Favorites"),
          color: Custom_color.BlueLightColor,//Custom_color.BlackTextColor,
          textAlign: TextAlign.start,
          fontWeight: Helper.textFontH5,
           fontSize: Helper.textSizeH11,
          fontFamily: "OpenSans Bold"),
      bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: _screenSize.width,
                  height: 0.5,
                  color: Custom_color.WhiteColor,//Custom_color.BlueLightColor,
                ),
              ),
            ],
          ),
          preferredSize: Size.fromHeight(0.0)),
      leading: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: false?Icon(
          Icons.arrow_back,
          color: Custom_color.BlueLightColor,
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
            padding: const EdgeInsets.only(left: 20.0,top: 5),
            child:  Container(
              child: SvgPicture.asset('assest/images_svg/back.svg',color: Custom_color.BlueLightColor,width: 20,height: 20,),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<List<User>> _ItemList() async {
    try {
      if (fav_list != null && !fav_list.isEmpty) {
        fav_list.clear();
      }

      String url =
          WebServices.GetFavorite + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]){
          List userlist = data["user"];

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
      String url = WebServices.GetFavorite +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
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
          UtilMethod.SnackBarMessage(_scaffoldKey, messages.toString());


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
}
