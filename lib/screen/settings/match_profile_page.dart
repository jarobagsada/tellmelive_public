import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/user.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/helper.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../activity_user_detail.dart';
import '../holder/activity_holder.dart';
import '../holder/user_event.dart';

class MatchProfile_Screen extends StatefulWidget {
  @override
  _MatchProfile_ScreenState createState() => _MatchProfile_ScreenState();
}

class _MatchProfile_ScreenState extends State<MatchProfile_Screen> {
  Size _screenSize;
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _visible, _listVisible;
  List<User> fav_list = [];

  var messages;

  //========= New Add Profile =====
  int _current = 0;
  var name, name_demo, interest, prof_interest, gender, dob, profile_image , about_me ,about_myself;
  List<dynamic> images = [];
  List<dynamic> imagelist = [];
  String facebook="0", twitter="0", instagram="0", tiktok="0", linkedin="0";
  String aboutChangedTxt;
  List<Activity_holder> activitylist = [];
  bool loading;
  List<UserEvent> bylist_activitylike = [];
  List<UserEvent> bylist_activitycreate = [];
  bool joined_expand;
  bool create_expand;
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
    aboutChangedTxt="";
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
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
          appBar: _getAppbar,
          key: _scaffoldKey,
          body: _widgetOldUI(),
        ));
  }

  //==========Profile UI ====================
 Widget _widgetOldUI(){
    return Visibility(
      visible: _visible,
      replacement: false?Center(
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
        padding: EdgeInsets.all(16),
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
          NetworkImage(Constant.ImageURL + nDataList.profile_img,scale: 1.0),
        ),
        title: CustomWigdet.TextView(
          text: nDataList.name,
          color: Custom_color.BlackTextColor,
          fontFamily: "OpenSans Bold",
        )
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
      backgroundColor: Colors.white,//Colors.transparent,
      elevation: 0.0,
      //centerTitle: true,
      title: CustomWigdet.TextView(
          text: AppLocalizations.of(context).translate("Match Profile"),
          color: Custom_color.BlueLightColor,//Custom_color.BlackTextColor,
          textAlign: TextAlign.start,
          fontWeight: Helper.textFontH5,
          fontSize: Helper.textSizeH11,
          fontFamily: "OpenSans Bold"),
      bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Container(
                width: _screenSize.width,
                height: 0.5,
                //color: Custom_color.BlueLightColor,
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
          WebServices.GetMatchProfile + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
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
          messages = data["message"].toString();
          UtilMethod.SnackBarMessage(_scaffoldKey, messages.toString());


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
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }



  saveAbout() async {

    aboutChangedTxt = aboutChangedTxt != "" ? aboutChangedTxt : about_myself;
    String url =WebServices.SaveAbout + SessionManager.getString(Constant.Token) + "&data="+Uri.encodeFull(aboutChangedTxt.trim())+"&language=${SessionManager.getString(Constant.Language_code)}";
    print("-----url-----" + url.toString());
    https.Response response = await https.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "Cache-Control": "no-cache",
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data["status"]) {
        setState(() {
          about_myself = aboutChangedTxt;
        });

      }
    }

    Navigator.of(context).pop();


  }

  toggleAboutMeDialog() {
    showDialog(
        barrierColor: Color(0x00ffffff),
        context: context,
        builder: (BuildContext context) {
          bool is_processing = false;
          return AlertDialog(
              backgroundColor: Color(0x00ffffff),
              content :StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        width: double.maxFinite,
                        height: 152,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                              height: 2,
                              child:  is_processing  ?  LinearProgressIndicator(
                                backgroundColor: Colors.white,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent,),
                                minHeight: 2,
                              ) : Container(),
                            ),
                            Container(
                                padding : EdgeInsets.all(5),
                                height:114,
                                child :
                                TextFormField(
                                  initialValue : aboutChangedTxt != "" ? aboutChangedTxt : about_myself,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 20,
                                  maxLength: 140,
                                  onChanged: (text) {
                                    setState(() {
                                      aboutChangedTxt = text;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey.shade300),
                                    hintText: AppLocalizations.of( context) .translate( "About me")+"...",
                                  ),
                                  style: TextStyle(color:Custom_color.GreyLightColor),
                                )),
                            IntrinsicHeight(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                                        color: Color(0xff1b98ea),
                                      ),
                                      padding: const EdgeInsets.only(
                                          top: 10.0, bottom: 10.0),
                                      child: CustomWigdet.FlatButtonSimple(
                                          onPress: () {
                                            if(is_processing)
                                              return;
                                            setState(() {
                                              is_processing = true;
                                            });
                                            Future.delayed(Duration(milliseconds: 1000), () {
                                              saveAbout();
                                            });
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
                                        color: Color(0xfffa4491),
                                      ),
                                      padding: const EdgeInsets.only(
                                          top: 10.0, bottom: 10.0),
                                      child: CustomWigdet.FlatButtonSimple(
                                          onPress: () {
                                            setState(() {
                                              is_processing = false;
                                            });
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
                        )
                    );
                  })
          );
        }
    );

  }

  String _getListactiviyitem(List<Activity_holder> list) {
    StringBuffer value = new StringBuffer();
    List<Activity_holder>.generate(list.length, (index) {
      if (list[index].percent > 0) {
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

  String _getGender(int name) {
    String value = "";
    if (name == 0) {
      value = AppLocalizations.of(context).translate("Male");
    } else if (name == 1) {
      value = AppLocalizations.of(context).translate("Female");
    }
    return value;
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

  String _getProfessional(int name) {
    String value = "";
    if (name == 0) {
      value = "";
    } else if (name == 1) {
      value = AppLocalizations.of(context).translate("Looking for job");
    } else if (name == 2) {
      value = AppLocalizations.of(context).translate("Providing Job");
    } else if (name == 3) {
      value = "${AppLocalizations.of(context).translate("Looking for job")}, ${AppLocalizations.of(context).translate("Providing Job")}";
    } else if (name == 4) {
      value = SessionManager.getString(Constant.Language_code) == "de" ? AppLocalizations.of(context).translate("No"):AppLocalizations.of(context).translate("No");
    }
    return value;
  }

  _GetCallBackMethod(bool value) {
    if (value == true) {
      setState(() {
        loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (await UtilMethod.SimpleCheckInternetConnection(
            context, _scaffoldKey)) {
          _GetProfile();
        }
      });
    }
  }


  Future<https.Response> _GetProfile() async {
    try {
      if (images != null && images.isNotEmpty) {
        images.clear();
        activitylist.clear();
      }
      if(bylist_activitylike!=null && bylist_activitylike.isNotEmpty){
        bylist_activitylike.clear();
      }
      if(bylist_activitycreate!=null && bylist_activitycreate.isNotEmpty){
        bylist_activitycreate.clear();
      }
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
            interest = data["user_info"]["interest"];
            prof_interest = data["user_info"]["prof_interest"];
            name = data["name"];
            name_demo = data["user_info"]["name"];
            gender = data["user_info"]["gender"];
            try{
              if(data["user_info"]["dob"]!=null){

                var dateOfBirth=data["user_info"]["dob"];
                var dateFormat=new DateFormat("dd-MM-yyyy").parse(dateOfBirth);
                //  var DayName=DateFormat.EEEE().format(dateFormat);
                var Date=DateFormat.d().format(dateFormat);
                var  MonthName= DateFormat.MMMM().format(dateFormat);
                var  Year= DateFormat.y().format(dateFormat);
                dob = '${Date} ${MonthName} ${Year}';

              }
            }catch(error){

            }

            var social = data["user_info"]["social"];
            try{ about_me = data["user_info"]["social"];}catch(e){}
            try{about_myself = data["user_info"]["about_me"];}catch(e){}
            profile_image = data["user_info"]["profile_img"];
            if (social.runtimeType != String) {
              facebook = data["user_info"]["social"]["facebook"];
              twitter = data["user_info"]["social"]["twitter"];
              instagram = data["user_info"]["social"]["instagram"];
              tiktok = data["user_info"]["social"]["tiktok"];
              linkedin = data["user_info"]["social"]["linkedin"];
            }


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
            if (activity_listlike != null && activity_listlike.length > 0) {
              bylist_activitylike = activity_listlike
                  .map<UserEvent>((index) => UserEvent.fromJson(index))
                  .toList();
            }

            var activity_listcreate = data["user_info"]["user_events"] as List;
            if (activity_listcreate != null && activity_listcreate.length > 0) {
              bylist_activitycreate = activity_listcreate
                  .map<UserEvent>((index) => UserEvent.fromJson(index))
                  .toList();
            }

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

            var activity_list = data["activity"] as List;
            if (activity_list != null && activity_list.length > 0) {
              activitylist = activity_list
                  .map<Activity_holder>(
                      (index) => Activity_holder.fromJson(index))
                  .toList();
            }


            loading = true;

          });
        } else {
          loading = false;
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
      loading = false;
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
