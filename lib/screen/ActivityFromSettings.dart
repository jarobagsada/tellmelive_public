import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/activity_list_holder.dart';
import 'package:miumiu/screen/holder/user.dart';
import 'package:miumiu/screen/pages/home_pages.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/helper.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:http/http.dart' as https;
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';

enum Action { MyActivity, ActivityWall }

class Activity_page_Settings extends StatefulWidget {
  @override
  _Activity_page_SettingsState createState() => _Activity_page_SettingsState();
}

class _Activity_page_SettingsState extends State<Activity_page_Settings> {
  Size _screenSize;
  bool _visible, _listVisible;
  var messages;
  Action action;
  List<Activity_List> activity_list = [];
  ProgressDialog progressDialog;
  var routeData;
  bool leading;
  var MQ_Height;
  var MQ_Width;
  @override
  void initState() {
    _listVisible = true;
    leading = false;
    action = Action.MyActivity;
    _activityItemList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    routeData =
    ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    if (routeData != null) {
      leading = routeData["leading"];
    }
    print("-----routdaat=======" + routeData.toString());
    return SafeArea(
      child: Scaffold(
        backgroundColor: Helper.inBackgroundColor,
        body:Stack(
          children: [
            false?_widgetActivityFormUI():_widgetActivityFormNewUI(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(
                context, Constant.CreateActivity);
          },

          label:  Text(AppLocalizations.of(context).translate('Create').toUpperCase(),
            style: TextStyle(color:Colors.white,
                fontFamily: "Kelvetica Nobis",
                fontWeight:FontWeight.w500,fontSize: 16),),
          icon: const Icon(Icons.add,color: Colors.white,size: 20,),
          backgroundColor: Color(Helper.floatButtonColor),
        ),
      ),
    );
  }

  //=================== Old UI ======
  Widget _widgetActivityFormUI(){
    return Container(
      width: _screenSize.width,
      padding: const EdgeInsets.only(
          top: 0.0, left: 0.0, right: 0.0, bottom: 10),
      child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              action == Action.MyActivity
                  ? Positioned(
                top: 150,
                child: InkWell(
                  onTap: () {
                    print("Create activity");
                    Navigator.pushNamed(
                        context, Constant.CreateActivity);
                    // result.then((value) {
                    //   if (value == Constant.Activity) {
                    //     _listVisible = true;
                    //     action = Action.MyActivity;
                    //     _activityItemList();
                    //   }
                    // });
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Custom_color.WhiteColor,
                      boxShadow: <BoxShadow>[
                        BoxShadow(

                            color: Custom_color.GreyLightColor3,
                            blurRadius: 10.0,
                            spreadRadius: 2)
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      size: 40,

                      color: Color(0xFFf72882),
                    ),
                  ),
                ),
              ) : Container(),
              Image(
                fit: BoxFit.fill,
                image: AssetImage("assest/images/activity_appbar.jpg"),
              ),
              Positioned(
                top: 100,
                child: Text(
                  action == Action.MyActivity ?
                  AppLocalizations.of(context)
                      .translate("Add you activity here") :
                  '',
                  style: TextStyle(
                      fontFamily: "Kelvetica Nobis",
                      fontSize: 20,
                      color: Colors.white
                  ),
                ),
              ),
              action == Action.MyActivity
                  ? Positioned(
                top:150,
                child: InkWell(
                  onTap: () {
                    print("Create activity");
                    Navigator.pushNamed(
                        context, Constant.CreateActivity);
                    // result.then((value) {
                    //   if (value == Constant.Activity) {
                    //     _listVisible = true;
                    //     action = Action.MyActivity;
                    //     _activityItemList();
                    //   }
                    // });
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Custom_color.WhiteColor,

                    ),
                    child: Icon(
                      Icons.add,
                      size: 40,

                      color: Color(0xFFf72882),
                    ),
                  ),
                ),
              )
                  : Container(),
              Positioned(
                top: 5,
                left: 5,
                child: InkWell(
                  onTap: () {
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

            ],
          ),
          SizedBox(height: 60.0),
          Wrap(
            spacing: 1.0,
            runSpacing: 5.0,
            children: <Widget>[
              // CustomWigdet.RoundRaisedButtonIconWithOutText(
              //     onPress: () {
              //       var result = Navigator.pushNamed(
              //           context, Constant.CreateActivity);
              //       result.then((value) {
              //         if (value == Constant.Activity) {
              //           _listVisible = true;
              //           action = Action.MyActivity;
              //           _activityItemList();
              //         }
              //       });
              //     },
              //     bgcolor: Custom_color.BlueLightColor,
              //     size: 20),
              action == Action.MyActivity
                  ? CustomWigdet.RoundRaisedButtonWithWrap(
                onPress: () {
                  action = Action.MyActivity;
                  _activityItemList();
                },
                text: AppLocalizations.of(context)
                    .translate("My Activity"),
                //    bgcolor: Custom_color.BlueLightColor
              )
                  : CustomWigdet.RoundOutlineFlatButtonWrapContant(
                  onPress: () {
                    action = Action.MyActivity;
                    _activityItemList();
                  },
                  text: AppLocalizations.of(context)
                      .translate("My Activity"),
                  textColor: Custom_color.BlueLightColor,
                  bordercolor: Custom_color.BlueLightColor),
              action == Action.ActivityWall
                  ? CustomWigdet.RoundRaisedButtonWithWrap(
                onPress: () {
                  action = Action.ActivityWall;
                  _activityItemList();
                },
                text: AppLocalizations.of(context)
                    .translate("Activity Wall"),
                //    bgcolor: Custom_color.BlueLightColor
              )
                  : CustomWigdet.RoundOutlineFlatButtonWrapContant(
                  onPress: () {
                    action = Action.ActivityWall;
                    _activityItemList();
                  },
                  text: AppLocalizations.of(context)
                      .translate("Activity Wall"),
                  textColor: Custom_color.BlueLightColor,
                  bordercolor: Custom_color.BlueLightColor)
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            color: Helper.inBackgroundColor,
            child: _listVisible
                ? listViewWidget(context, activity_list)
                : Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  action == Action.MyActivity
                      ? Image.asset(
                    "assest/images/activity_wall.png",
                    width: 160,
                  )
                      : Image.asset(
                    "assest/images/activity_wall.png",
                    width: 160,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomWigdet.TextView(
                      overflow: true,
                      text: !UtilMethod.isStringNullOrBlank(
                          messages.toString())
                          ? messages.toString()
                          : "",
                      color: Custom_color.BlackTextColor)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  //=================== New UI ======
  Widget _widgetActivityFormNewUI(){
    return Container(
      width: _screenSize.width,
      padding: const EdgeInsets.only(
          top: 0.0, left: 0.0, right: 0.0, bottom: 10),
      child: Column(
        children: <Widget>[
         false? Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              action == Action.MyActivity
                  ? Positioned(
                top: 150,
                child: InkWell(
                  onTap: () {
                    print("Create activity");
                    Navigator.pushNamed(
                        context, Constant.CreateActivity);
                    // result.then((value) {
                    //   if (value == Constant.Activity) {
                    //     _listVisible = true;
                    //     action = Action.MyActivity;
                    //     _activityItemList();
                    //   }
                    // });
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Custom_color.WhiteColor,
                      boxShadow: <BoxShadow>[
                        BoxShadow(

                            color: Custom_color.GreyLightColor3,
                            blurRadius: 10.0,
                            spreadRadius: 2)
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      size: 40,

                      color: Color(0xFFf72882),
                    ),
                  ),
                ),
              ) : Container(),
              Image(
                fit: BoxFit.fill,
                image: AssetImage("assest/images/activity_appbar.jpg"),
              ),
              Positioned(
                top: 100,
                child: Text(
                  action == Action.MyActivity ?
                  AppLocalizations.of(context)
                      .translate("Add you activity here") :
                  '',
                  style: TextStyle(
                      fontFamily: "Kelvetica Nobis",
                      fontSize: 20,
                      color: Colors.white
                  ),
                ),
              ),
              action == Action.MyActivity
                  ? Positioned(
                top:150,
                child: InkWell(
                  onTap: () {
                    print("Create activity");
                    Navigator.pushNamed(
                        context, Constant.CreateActivity);
                    // result.then((value) {
                    //   if (value == Constant.Activity) {
                    //     _listVisible = true;
                    //     action = Action.MyActivity;
                    //     _activityItemList();
                    //   }
                    // });
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Custom_color.WhiteColor,

                    ),
                    child: Icon(
                      Icons.add,
                      size: 40,

                      color: Color(0xFFf72882),
                    ),
                  ),
                ),
              )
                  : Container(),
              Positioned(
                top: 5,
                left: 5,
                child: InkWell(
                  onTap: () {
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

            ],
          ):Container(),

          Container(
            padding:  EdgeInsets.only(left: 5.0,right: 5,top: MQ_Height*0.02,bottom: MQ_Height*0.02),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1)
            ),
            child: Row(
              children: [


                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: true?Padding(
                      padding: const EdgeInsets.only(left: 5.0,right: 5),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.blue,
                        size: 22,
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
                        padding: const EdgeInsets.only(left: 10.0,right:10,top: 5),
                        child:  Container(
                          child: SvgPicture.asset('assest/images_svg/back.svg',color: Colors.blue,width: 18,height: 18,),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Text(AppLocalizations.of(context).translate('Activity Wall'),//'Activity Wall',
                    style: TextStyle(color:Helper.textColorBlueH1,
                        fontFamily: "Kelvetica Nobis",
                        fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH12),),
                ),
              ],
            ),
          ),
         // SizedBox(height: 60.0),
         false? Wrap(
            spacing: 1.0,
            runSpacing: 5.0,
            children: <Widget>[
              // CustomWigdet.RoundRaisedButtonIconWithOutText(
              //     onPress: () {
              //       var result = Navigator.pushNamed(
              //           context, Constant.CreateActivity);
              //       result.then((value) {
              //         if (value == Constant.Activity) {
              //           _listVisible = true;
              //           action = Action.MyActivity;
              //           _activityItemList();
              //         }
              //       });
              //     },
              //     bgcolor: Custom_color.BlueLightColor,
              //     size: 20),
              action == Action.MyActivity
                  ? CustomWigdet.RoundRaisedButtonWithWrap(
                onPress: () {
                  action = Action.MyActivity;
                  _activityItemList();
                },
                text: AppLocalizations.of(context)
                    .translate("My Activity"),
                //    bgcolor: Custom_color.BlueLightColor
              )
                  : CustomWigdet.RoundOutlineFlatButtonWrapContant(
                  onPress: () {
                    action = Action.MyActivity;
                    _activityItemList();
                  },
                  text: AppLocalizations.of(context)
                      .translate("My Activity"),
                  textColor: Custom_color.BlueLightColor,
                  bordercolor: Custom_color.BlueLightColor),
              action == Action.ActivityWall
                  ? CustomWigdet.RoundRaisedButtonWithWrap(
                onPress: () {
                  action = Action.ActivityWall;
                  _activityItemList();
                },
                text: AppLocalizations.of(context)
                    .translate("Activity Wall"),
                //    bgcolor: Custom_color.BlueLightColor
              )
                  : CustomWigdet.RoundOutlineFlatButtonWrapContant(
                  onPress: () {
                    action = Action.ActivityWall;
                    _activityItemList();
                  },
                  text: AppLocalizations.of(context)
                      .translate("Activity Wall"),
                  textColor: Custom_color.BlueLightColor,
                  bordercolor: Custom_color.BlueLightColor)
            ],
          ):Container(
           decoration: BoxDecoration(
             color: Colors.grey.shade200,
             borderRadius: BorderRadius.circular(1)

           ),
           padding:  EdgeInsets.only(left: 5.0,right: 5,top: MQ_Height*0.02,),

           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               InkWell(
                 onTap: ()async{
                   action = Action.MyActivity;
                   _activityItemList();
                 },
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Container(
                       alignment: Alignment.center,
                       child: Text(AppLocalizations.of(context).translate('My Activity'),//'My Activity',
                         textAlign: TextAlign.center,
                         style: TextStyle(color: action == Action.MyActivity?Color(0xfffb4592):Color(Helper.textHintColorH3),
                             fontFamily: "Kelvetica Nobis",
                             fontWeight: Helper.textFontH3,fontSize: Helper.textSizeH13),),
                     ),
                     SizedBox(
                       height: MQ_Height*0.02,
                     ),
                     Container(
                       width: MQ_Width*0.45,
                       height: 3,
                       color: action == Action.MyActivity?Color(0xfffb4592):Colors.transparent,//Colors.purpleAccent,
                     )
                   ],
                 ),
               ),
               InkWell(
                 onTap: ()async{
                   action = Action.ActivityWall;
                   _activityItemList();
                 },
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   // crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Container(
                       alignment: Alignment.center,
                       child: Text(AppLocalizations.of(context).translate('Joined Activity'),//'Joined Activity',
                         textAlign: TextAlign.center,
                         style: TextStyle(color: action == Action.ActivityWall?Color(0xfffb4592):Color(Helper.textHintColorH3),
                             fontFamily: "Kelvetica Nobis",
                             fontWeight: Helper.textFontH3,fontSize: Helper.textSizeH13),),
                     ),
                     SizedBox(
                       height: MQ_Height*0.02,
                     ),
                     Container(
                       width: MQ_Width*0.45,
                       height: 3,
                       color: action == Action.ActivityWall?Color(0xfffb4592):Colors.transparent,//Colors.purpleAccent,
                     )
                   ],
                 ),
               ),
             ],
           ),
         ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: _listVisible
                ? listViewWidget(context, activity_list)
                : Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  action == Action.MyActivity
                      ? Image.asset(
                    "assest/images/activity_wall.png",
                    width: 160,
                  )
                      : Image.asset(
                    "assest/images/activity_wall.png",
                    width: 160,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomWigdet.TextView(
                      overflow: true,
                      text: !UtilMethod.isStringNullOrBlank(
                          messages.toString())
                          ? messages.toString()
                          : "",
                      color: Custom_color.BlackTextColor)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  get _appbar {
    return PreferredSize(
      preferredSize: Size.fromHeight(186.0), // here the desired height
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 26.0),
            child: AppBar(
              automaticallyImplyLeading: leading ?? false,
              title: Text(AppLocalizations.of(context).translate("Activity")),
              centerTitle: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(180),
                      bottomLeft: Radius.circular(180))),
            ),
          ),
          action == Action.MyActivity
              ? Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: () {
                var result =
                Navigator.pushNamed(context, Constant.CreateActivity);
                result.then((value) {
                  if (value == Constant.Activity) {
                    _listVisible = true;
                    action = Action.MyActivity;
                    _activityItemList();
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Custom_color.WhiteColor,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10.0,
                        spreadRadius: 2)
                  ],
                ),
                child: Icon(
                  Icons.add,
                  size: 26,
                  color: Color(0xFFf72882),
                ),
              ),
            ),
          )
              : Container()
        ],
      ),
    );
  }

  Widget getlistitem() {
    return FutureBuilder<List<Activity_List>>(
      future: _activityItemList(),
      builder: (BuildContext context, snapshot) {
        print(snapshot.hasData);
        print(snapshot.connectionState);
        print(snapshot.hasError);
        print(snapshot.data);

        return snapshot.data != null
            ?   listViewWidget(
          context,
          snapshot.data,
        )
            : Expanded(
          flex: 5,
            child: Center(child: CircularProgressIndicator()));
      },
  );
  }

  listViewWidget(BuildContext context, List<Activity_List> activityList) {
    return Expanded(
      flex: 5,
      child: ListView.builder(
        itemBuilder: (context, i) {
          final nDataList = activityList[i];
          return false?productDisplayListView(nDataList):productDisplayListViewNewUI(nDataList);
        },
        itemCount: activityList == null ? 0 : activityList.length,
      ),
    );
  }
///===================== Old UI
  Widget productDisplayListView(Activity_List nDataList) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          var value = Navigator.pushNamed(context, Constant.ActivityUserDetail,
              arguments: action == Action.ActivityWall
                  ? {
                "event_id": nDataList.id,
                "action": Constant.ActivityWall,
                "isSub": "1"
              }
                  : {"event_id": nDataList.id, "action": Constant.Activity});
          value.then((value) {
            print("------value---activity this----------" + value.toString());
            if (value == Constant.ActivityWall) {
              _listVisible = true;
              action = Action.ActivityWall;
              _activityItemList();
            } else if (value == Constant.Activity) {
              _listVisible = true;
              action = Action.MyActivity;
              _activityItemList();
            } else if (value) {
              if (action == Action.MyActivity) {
                _listVisible = true;
                action = Action.MyActivity;
                _activityItemList();
              } else {
                _listVisible = true;
                action = Action.ActivityWall;
                _activityItemList();
              }
            }
          });
        },
        child: Container(
          padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Custom_color.PlacholderColor,
                    image: DecorationImage(
                        image: NetworkImage(
                            nDataList.image != null ? nDataList.image : "",scale: 1.0),
                        onError: (exception, stackTrace) {
                          print("---eroor-----" +
                              exception.toString() +
                              "--11111--" +
                              stackTrace.toString());
                          print("-------print0000---------" +
                              exception.hashCode.toString());
                        },
                        fit: BoxFit.cover)),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    getRowItem(
                      nDataList.title,
                      AppLocalizations.of(context).translate("Title"),
                    ),
                    getRowItem(
                      nDataList.location,
                      AppLocalizations.of(context).translate("Location"),
                    ),
                    nDataList.categroy_holder != null &&
                        nDataList.categroy_holder.isNotEmpty
                        ? getRowItem(
                      _getListcategroyitem(nDataList.categroy_holder),
                      AppLocalizations.of(context).translate("Categroy"),
                    )
                        : Container(),
                    getRowItem(
                      nDataList.start_time,
                      AppLocalizations.of(context).translate("Start"),
                    ),
                    getRowItem(
                      nDataList.end_time,
                      AppLocalizations.of(context).translate("End"),
                    ),
                    getRowItem(nDataList.members.toString(),
                        AppLocalizations.of(context).translate("Members")),
//                    action != Action.ActivityWall
//                        ? getRowItem(
//                            nDataList.members.toString(),
//                            AppLocalizations.of(context).translate("Members"),
//                          )
//                        : Container(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
//====================== New UI ==============
  Widget productDisplayListViewNewUI(Activity_List nDataList) {
    return InkWell(
      onTap: () {
        var value = Navigator.pushNamed(context, Constant.ActivityUserDetail,
            arguments: action == Action.ActivityWall
                ? {
              "event_id": nDataList.id,
              "action": Constant.ActivityWall,
              "isSub": "1"
            }
                : {"event_id": nDataList.id, "action": Constant.Activity});
        value.then((value) {
          print("------value---activity this----------" + value.toString());
          if (value == Constant.ActivityWall) {
            _listVisible = true;
            action = Action.ActivityWall;
            _activityItemList();
          } else if (value == Constant.Activity) {
            _listVisible = true;
            action = Action.MyActivity;
            _activityItemList();
          } else if (value) {
            if (action == Action.MyActivity) {
              _listVisible = true;
              action = Action.MyActivity;
              _activityItemList();
            } else {
              _listVisible = true;
              action = Action.ActivityWall;
              _activityItemList();
            }
          }
        });
      },
      child: Container(
        padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
        child: Stack(
        //  crossAxisAlignment: CrossAxisAlignment.start,
          alignment: Alignment.centerLeft,
          children: <Widget>[


            Column(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                 // width: 300,
                 // height: 150,
                  margin: EdgeInsets.only(left: MQ_Width*0.16,right: MQ_Height*0.01),
                  padding: EdgeInsets.only(left: MQ_Width*0.19,top: MQ_Height*0.01,bottom: MQ_Height*0.01),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //==old UI
                      false?getRowItem(
                        nDataList.title,
                        AppLocalizations.of(context).translate("Title"),
                      ):Container(
                        margin: EdgeInsets.only(top: 2,bottom: 2),
                        child: Text( nDataList.title,
                          style: TextStyle(color:Helper.textColorBlueH1,
                              fontFamily: "Kelvetica Nobis",
                              fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH11),),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 5,bottom: 2),
                        width: 40,
                        height: 1.0,
                        color: Color(0xfffb4592),//Colors.purpleAccent,
                      ),
                      SizedBox(
                        height: MQ_Height*0.02,
                      ),
                      false?getRowItem(
                        nDataList.location,
                        AppLocalizations.of(context).translate("Location"),
                      ):Container(
                        margin: EdgeInsets.only(top: 2,bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Container(
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
                            ),
                            Container(
                              width: MQ_Width*0.50,
                              child: Text(nDataList.location,
                                style: TextStyle(color:Color(Helper.textColorBlackH2),
                                    fontFamily: "Kelvetica Nobis",
                                    fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),),
                            ),
                          ],
                        ),
                      ),


                   //   nDataList.categroy_holder != null && nDataList.categroy_holder.isNotEmpty
                         false ? getRowItem(
                        _getListcategroyitem(nDataList.categroy_holder),
                        AppLocalizations.of(context).translate("Categroy"),
                      ) : Container(),
                     false? getRowItem(
                        nDataList.start_time,
                        AppLocalizations.of(context).translate("Start"),
                      ):Container(),
                      false?getRowItem(
                        nDataList.end_time,
                        AppLocalizations.of(context).translate("End"),
                      ):Container(),
                     SizedBox(
                       height: MQ_Height*0.01,
                     ),
                      Container(
                        margin: EdgeInsets.only(top: 2,bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Container(
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
                                          child:Icon(Icons.calendar_month,size: 14,color: Colors.white,)
                                      ),
                                    ),
                                  ),
                                )
                            ),
                            Container(
                              width: MQ_Width*0.48,
                              child: Text( nDataList.start_time +' to '+nDataList.end_time,
                                style: TextStyle(color:Color(Helper.textColorBlackH2),
                                    fontFamily: "Kelvetica Nobis",
                                    fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH14),),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MQ_Height*0.03,
                      ),
                     false? getRowItem(nDataList.members.toString(),
                          AppLocalizations.of(context).translate("Members")):Container(),
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
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(left: MQ_Width*0.20,right: MQ_Width*0.05),
                  padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.08,bottom: MQ_Width*0.02) ,
                  height: 8,
                  width: MQ_Width*0.70,
                  decoration: BoxDecoration(
                    color:Colors.blue.shade700,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight:  Radius.circular(20),
                    ),

                  ),)
              ],
            ),

            Container(
              width: 110,
              height: 110,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey,width: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  color: Custom_color.PlacholderColor,
                  image: DecorationImage(
                      image: NetworkImage(
                          nDataList.image != null ? nDataList.image : "",scale: 1.0),
                      onError: (exception, stackTrace) {
                        print("---eroor-----" +
                            exception.toString() +
                            "--11111--" +
                            stackTrace.toString());
                        print("-------print0000---------" +
                            exception.hashCode.toString());
                      },
                      fit: BoxFit.cover)),
            ),
          ],
        ),
      ),
    );
  }


  Widget getRowItem(String text, String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 30,
          child: Container(
            child: CustomWigdet.TextView(
                overflow: true,
                text: name,
                fontSize: 13,
                color: Custom_color.BlackTextColor,
                fontFamily: "OpenSans Bold"),
          ),
        ),
        // CustomWigdet.TextView(text: AppLocalizations.of(context).translate("Name"),color: Custom_color.BlackTextColor),
        Expanded(
            flex: 5,
            child: CustomWigdet.TextView(
                fontSize: 13, text: ":", color: Custom_color.BlackTextColor)),
        Expanded(
            flex: 65,
            child: CustomWigdet.TextView(
                fontSize: 13,
                overflow: true,
                text: text,
                color: Custom_color.GreyLightColor))
      ],
    );
  }

  Future<List<Activity_List>> _activityItemList() async {
    try {
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      if (activity_list != null && !activity_list.isEmpty) {
        activity_list.clear();
      }
      String url = "";
      if (action == Action.MyActivity) {
        url = WebServices.GetCreateEvent +
            SessionManager.getString(Constant.Token) +
            "&language=${SessionManager.getString(Constant.Language_code)}";
      } else {
        url = WebServices.GetActivityWall +
            SessionManager.getString(Constant.Token) +
            "&language=${SessionManager.getString(Constant.Language_code)}";
      }
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      print("respnse--111--" + response.body);
      _hideProgress();
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          var datitem = data["data"];

          activity_list = datitem
              .map<Activity_List>((i) => Activity_List.fromJson(i))
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
      }

      return activity_list;
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  String _getListcategroyitem(List<Category> list) {
    StringBuffer value = new StringBuffer();
    List<User>.generate(list.length, (index) {
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
