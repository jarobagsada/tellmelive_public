import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../../utilmethod/helper.dart';

class Perfrence_Screen extends StatefulWidget {
  @override
  _Perfrence_ScreenState createState() => _Perfrence_ScreenState();
}

// ignore: camel_case_types
class _Perfrence_ScreenState extends State<Perfrence_Screen> {
  bool isSwitched_Men = false;
  bool isSwitched_Women = false;

  // bool isSwitched_Both = false;
  bool isSwitched_age = false;
  bool isSwitched_status = false;
  bool isSwitched_distance = false;
  double _starValue = 18;
  double _endValue = 65;
  Size _screenSize;
  ProgressDialog progressDialog;
  bool _visible;
  int men, woman, min_age, max_age, age_hide, online_hide, distance_hide;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool showLoading;
  var MQ_Height;
  var MQ_Width;
  @override
  void initState() {
    _visible        = true;
     showLoading    = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _GetInfo();
      }
    });
   
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: (){
        Navigator.pop(context,true);
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
            backgroundColor:Color(Helper.inBackgroundColor1),
          appBar: _getAppbar,
          body: Stack(
            children: [
              //_widgetPrefenceUI()
              _widgetPrefenceNewUI()
            ],
          )
        
        ),
      ),
    );
  }


  //===============  Preference Old Ui  ===========

  Widget _widgetPrefenceUI(){
    return Column(
        children : [
          SizedBox(
            height: showLoading ? 2:0,
            child: LinearProgressIndicator(
              backgroundColor: Color(int.parse(Constant.progressBg)),
              valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse(Constant.progressVl)),),
              minHeight: 2,
            ),
          ),
          Expanded(
            child :

            Visibility(
              visible: _visible,
              replacement: Center(
                child: CircularProgressIndicator(),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomWigdet.TextView(
                          text: AppLocalizations.of(context)
                              .translate("Having Interest in"),
                          fontFamily: "OpenSans Bold",
                          color: Custom_color.BlueLightColor),
                      Row(
                        children: <Widget>[
                          CustomWigdet.TextView(
                              text: AppLocalizations.of(context).translate("MEN"),
                              color: Custom_color.BlackTextColor),
                          Spacer(),
                          Switch(
                            value: isSwitched_Men,
                            onChanged: (value) {
                              isSwitched_Men = value;
                              _UpdatePrefrence();
                            },
                            activeTrackColor: Custom_color.BlueLightColor,
                            activeColor: Custom_color.BlueDarkColor,
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          CustomWigdet.TextView(
                              text: AppLocalizations.of(context).translate("WOMEN"),
                              color: Custom_color.BlackTextColor),
                          Spacer(),
                          Switch(
                            value: isSwitched_Women,
                            onChanged: (value) {
                              isSwitched_Women = value;
                              _UpdatePrefrence();
                            },
                            activeTrackColor: Custom_color.BlueLightColor,
                            activeColor: Custom_color.BlueDarkColor,
                          )
                        ],
                      ),
//                Row(
//                  children: <Widget>[
//                    CustomWigdet.TextView(
//                        text: AppLocalizations.of(context).translate("BOTH"),
//                        color: Custom_color.BlackTextColor),
//                    Spacer(),
//                    Switch(
//                      value: isSwitched_Both,
//                      onChanged: (value) {
//                        setState(() {
//                          isSwitched_Both = value;
//                          print("----switch---" + isSwitched_Both.toString());
//                        });
//                      },
//                      activeTrackColor: Custom_color.BlueLightColor,
//                      activeColor: Custom_color.BlueDarkColor,
//                    )
//                  ],
//                ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          CustomWigdet.TextView(
                              fontFamily: "OpenSans Bold",
                              text: _starValue.toInt().toString(),
                              color: Custom_color.BlueLightColor),
                          SizedBox(
                            width: 2,
                          ),
                          CustomWigdet.TextView(
                              text: AppLocalizations.of(context)
                                  .translate("To")
                                  .toLowerCase(),
                              color: Custom_color.BlackTextColor),
                          SizedBox(
                            width: 2,
                          ),
                          CustomWigdet.TextView(
                              fontFamily: "OpenSans Bold",
                              // text: _endValue >= 70
                              //     ? "70+"
                              //     : _endValue.toInt().toString(),
                              text:_endValue.toInt().toString(),
                              color: Custom_color.BlueLightColor),
                          SizedBox(
                            width: 2,
                          ),
                          CustomWigdet.TextView(
                              text: AppLocalizations.of(context)
                                  .translate("years old")
                                  .toLowerCase(),
                              color: Custom_color.BlackTextColor),
                        ],
                      ),
                      Container(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              thumbColor: Custom_color.BlueLightColor,
                              rangeThumbShape: RoundRangeSliderThumbShape(
                                  enabledThumbRadius: 5.0, disabledThumbRadius: 5.0),
                              activeTrackColor: Custom_color.BlueLightColor,
                              inactiveTrackColor: Custom_color.GreyLightColor,
                              valueIndicatorColor: Custom_color.BlueLightColor,
                              trackHeight: 1),
                          child: RangeSlider(
                            values: RangeValues(_starValue, _endValue),
                            min: 18,
                            max: 65,
//                    labels: RangeLabels(
//                        _starValue.toString(), _endValue.toString()),
                            onChanged: (values) {
                              setState(() {
                                _starValue = values.start.roundToDouble();
                                _endValue = values.end.roundToDouble();
                              });
                            },
                            onChangeEnd: (value) {
                              _UpdatePrefrence();
                            },
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      CustomWigdet.TextView(
                          text: AppLocalizations.of(context)
                              .translate("Choose the information you want to share"),
                          fontFamily: "OpenSans Bold",
                          overflow: true,
                          color: Custom_color.BlueLightColor),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // CustomWigdet.TextView(
                      //     text: AppLocalizations.of(context)
                      //         .translate("Choose the information you want to share"),
                      //     fontSize: 12,
                      //     color: Custom_color.GreyLightColor),
                      Row(
                        children: <Widget>[
                          CustomWigdet.TextView(
                              text: AppLocalizations.of(context)
                                  .translate("Hide my age"),
                              color: Custom_color.BlackTextColor),
                          Spacer(),
                          Switch(
                            value: isSwitched_age,
                            onChanged: (value) {
                              isSwitched_age = value;
                              _UpdatePrefrence();
                              //   _asyncConfirmDialog(context);
                            },
                            activeTrackColor: Custom_color.BlueLightColor,
                            activeColor: Custom_color.BlueDarkColor,
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          CustomWigdet.TextView(
                              text: AppLocalizations.of(context)
                                  .translate("Hide my Online status"),
                              color: Custom_color.BlackTextColor),
                          Spacer(),
                          Switch(
                            value: isSwitched_status,
                            onChanged: (value) {
                              isSwitched_status = value;
                              _UpdatePrefrence();
                              //   _asyncConfirmDialog(context);
                            },
                            activeTrackColor: Custom_color.BlueLightColor,
                            activeColor: Custom_color.BlueDarkColor,
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          CustomWigdet.TextView(
                              text: AppLocalizations.of(context)
                                  .translate("Hide my distance"),
                              color: Custom_color.BlackTextColor),
                          Spacer(),
                          Switch(
                            value: isSwitched_distance,
                            onChanged: (value) {
                              isSwitched_distance = value;
                              _UpdatePrefrence();
                              //   _asyncConfirmDialog(context);
                            },
                            activeTrackColor: Custom_color.BlueLightColor,
                            activeColor: Custom_color.BlueDarkColor,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )]);
  }


  //===============  Preference  New UI  ===========

  Widget _widgetPrefenceNewUI(){
    return Column(
        children : [
          SizedBox(
            height: showLoading ? 2:0,
            child: LinearProgressIndicator(
              backgroundColor: Color(int.parse(Constant.progressBg)),
              valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse(Constant.progressVl)),),
              minHeight: 2,
            ),
          ),
          Expanded(
            child :

            Visibility(
              visible: _visible,
              replacement: Center(
                child: CircularProgressIndicator(),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: ListView(
                   // crossAxisAlignment: CrossAxisAlignment.start,
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(

                        width: _screenSize.width,
                        height: MQ_Height*0.26,
                        margin: EdgeInsets.only(left: MQ_Width*0.02,right: MQ_Width*0.02),
                        padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,

                        decoration: BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(20),

                        ),
                        child: Column(
                          children: [
                            CustomWigdet.TextView(
                                text: AppLocalizations.of(context)
                                    .translate("Having Interest in"),
                                fontFamily: "OpenSans Bold",
                                color: Custom_color.BlueLightColor),

                            Row(
                              children: <Widget>[
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context).translate("MEN"),
                                    color: Custom_color.BlackTextColor),
                                Spacer(),
                                Switch(
                                  value: isSwitched_Men,
                                  onChanged: (value) {
                                    isSwitched_Men = value;
                                    _UpdatePrefrence();
                                  },
                                  activeTrackColor: Custom_color.BlueLightColor,
                                  activeColor: Custom_color.BlueDarkColor,
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context).translate("WOMEN"),
                                    color: Custom_color.BlackTextColor),
                                Spacer(),
                                Switch(
                                  value: isSwitched_Women,
                                  onChanged: (value) {
                                    isSwitched_Women = value;
                                    _UpdatePrefrence();
                                  },
                                  activeTrackColor: Custom_color.BlueLightColor,
                                  activeColor: Custom_color.BlueDarkColor,
                                )
                              ],
                            ),
//                Row(
//                  children: <Widget>[
//                    CustomWigdet.TextView(
//                        text: AppLocalizations.of(context).translate("BOTH"),
//                        color: Custom_color.BlackTextColor),
//                    Spacer(),
//                    Switch(
//                      value: isSwitched_Both,
//                      onChanged: (value) {
//                        setState(() {
//                          isSwitched_Both = value;
//                          print("----switch---" + isSwitched_Both.toString());
//                        });
//                      },
//                      activeTrackColor: Custom_color.BlueLightColor,
//                      activeColor: Custom_color.BlueDarkColor,
//                    )
//                  ],
//                ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: <Widget>[
                                CustomWigdet.TextView(
                                    fontFamily: "OpenSans Bold",
                                    text: _starValue.toInt().toString(),
                                    color: Custom_color.BlueLightColor),
                                SizedBox(
                                  width: 2,
                                ),
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context)
                                        .translate("To")
                                        .toLowerCase(),
                                    color: Custom_color.BlackTextColor),
                                SizedBox(
                                  width: 2,
                                ),
                                CustomWigdet.TextView(
                                    fontFamily: "OpenSans Bold",
                                    // text: _endValue >= 70
                                    //     ? "70+"
                                    //     : _endValue.toInt().toString(),
                                    text:_endValue.toInt().toString(),
                                    color: Custom_color.BlueLightColor),
                                SizedBox(
                                  width: 2,
                                ),
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context)
                                        .translate("years old")
                                        .toLowerCase(),
                                    color: Custom_color.BlackTextColor),
                              ],
                            ),
                            Container(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                    thumbColor: Custom_color.BlueLightColor,
                                    rangeThumbShape: RoundRangeSliderThumbShape(
                                        enabledThumbRadius: 5.0, disabledThumbRadius: 5.0),
                                    activeTrackColor: Custom_color.BlueLightColor,
                                    inactiveTrackColor: Custom_color.GreyLightColor,
                                    valueIndicatorColor: Custom_color.BlueLightColor,
                                    trackHeight: 1),
                                child: RangeSlider(
                                  values: RangeValues(_starValue, _endValue),
                                  min: 18,
                                  max: 65,
//                    labels: RangeLabels(
//                        _starValue.toString(), _endValue.toString()),
                                  onChanged: (values) {
                                    setState(() {
                                      _starValue = values.start.roundToDouble();
                                      _endValue = values.end.roundToDouble();
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    _UpdatePrefrence();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                     // Divider(thickness: 1,),
                      SizedBox(
                        height: MQ_Height*0.05,
                      ),


                      Container(
                        width: _screenSize.width,
                        height: MQ_Height*0.26,
                        margin: EdgeInsets.only(left: MQ_Width*0.02,right: MQ_Width*0.02),
                        padding:EdgeInsets.only(left: MQ_Width*0.05,right: MQ_Width*0.05,top: MQ_Width*0.03,bottom: MQ_Width*0.02) ,

                        decoration: BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(20),

                        ),
                        child: Column(
                          children: [
                            CustomWigdet.TextView(
                                text: AppLocalizations.of(context)
                                    .translate("Choose the information you want to share"),
                                fontFamily: "OpenSans Bold",
                                overflow: true,
                                color: Custom_color.BlueLightColor),

                            // SizedBox(
                            //   height: 5,
                            // ),
                            // CustomWigdet.TextView(
                            //     text: AppLocalizations.of(context)
                            //         .translate("Choose the information you want to share"),
                            //     fontSize: 12,
                            //     color: Custom_color.GreyLightColor),
                            Row(
                              children: <Widget>[
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context)
                                        .translate("Hide my age"),
                                    color: Custom_color.BlackTextColor),
                                Spacer(),
                                Switch(
                                  value: isSwitched_age,
                                  onChanged: (value) {
                                    isSwitched_age = value;
                                    _UpdatePrefrence();
                                    //   _asyncConfirmDialog(context);
                                  },
                                  activeTrackColor: Custom_color.BlueLightColor,
                                  activeColor: Custom_color.BlueDarkColor,
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context)
                                        .translate("Hide my Online status"),
                                    color: Custom_color.BlackTextColor),
                                Spacer(),
                                Switch(
                                  value: isSwitched_status,
                                  onChanged: (value) {
                                    isSwitched_status = value;
                                    _UpdatePrefrence();
                                    //   _asyncConfirmDialog(context);
                                  },
                                  activeTrackColor: Custom_color.BlueLightColor,
                                  activeColor: Custom_color.BlueDarkColor,
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context)
                                        .translate("Hide my distance"),
                                    color: Custom_color.BlackTextColor),
                                Spacer(),
                                Switch(
                                  value: isSwitched_distance,
                                  onChanged: (value) {
                                    isSwitched_distance = value;
                                    _UpdatePrefrence();
                                    //   _asyncConfirmDialog(context);
                                  },
                                  activeTrackColor: Custom_color.BlueLightColor,
                                  activeColor: Custom_color.BlueDarkColor,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          )]);
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
     // centerTitle: true,
      title: CustomWigdet.TextView(
          text: AppLocalizations.of(context).translate("My Preferences"),
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
          Navigator.pop(context,true);
        },
      ),
    );
  }

  Future _GetInfo() async {
    try {
      String url = WebServices.GetUserPrefrence +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
     
      print("respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          men = data["data"]["men"];
          woman = data["data"]["woman"];
          min_age = data["data"]["min_age"];
          max_age = data["data"]["max_age"];
          age_hide = data["data"]["age_hide"];
          online_hide = data["data"]["online_hide"];
          distance_hide = data["data"]["distance_hide"];

          _starValue = min_age.toDouble();
          _endValue = max_age.toDouble();

          isSeletedMen(men);
          isSeletedWomen(woman);
          isSeletedAge(age_hide);
          isSeletedStatus(online_hide);
          isSeletedDistance(distance_hide);
        } else {
          // messages = data["message"].toString();
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
        _hideProgress();
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  isSeletedMen(int value) {
    if (value == 0) {
      isSwitched_Men = false;
    } else {
      isSwitched_Men = true;
    }
  }

  isSeletedWomen(int value) {
    if (value == 0) {
      isSwitched_Women = false;
    } else {
      isSwitched_Women = true;
    }
  }

  isSeletedAge(int value) {
    if (value == 0) {
      isSwitched_age = false;
    } else {
      isSwitched_age = true;
    }
  }

  isSeletedStatus(int value) {
    if (value == 0) {
      isSwitched_status = false;
    } else {
      isSwitched_status = true;
    }
  }

  isSeletedDistance(int value) {
    if (value == 0) {
      isSwitched_distance = false;
    } else {
      isSwitched_distance = true;
    }
  }

  Future _asyncConfirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.clear,
                        color: Custom_color.BlackTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, left: 16),
                    child: CustomWigdet.TextView(
                        overflow: true,
                        textAlign: TextAlign.center,
                        text: AppLocalizations.of(context)
                            .translate("Explore our awesome features"),
                        color: Custom_color.BlackTextColor,
                        fontFamily: "OpenSans Bold"),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Image.asset(
                    "assest/images/premium.png",
                    width: 100,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  CustomWigdet.RoundRaisedButton(
                      onPress: () {},
                      text: AppLocalizations.of(context)
                          .translate("Upgrade")
                          .toUpperCase(),
                      fontSize: 12,
                      textColor: Custom_color.WhiteColor,
                      bgcolor: Custom_color.BlueLightColor,
                      fontFamily: "OpenSans Bold")
                ],
              ),
            ));
      },
    );
  }

  Future<https.Response> _UpdatePrefrence() async {
    try {
      _showProgress(context);
      Map jsondata = {
        "men": !isSwitched_Men ? "0" : "1",
        "woman": !isSwitched_Women ? "0" : "1",
        "min_age": _starValue.toString(),
        "max_age": _endValue.toString(),
        "age_hide": !isSwitched_age ? "0" : "1",
        "online_hide": !isSwitched_status ? "0" : "1",
        "distance_hide": !isSwitched_distance ? "0" : "1"
      };
      print("------jsondata------" + jsondata.toString());
      String url = WebServices.GetUpdatePrefrence +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          men = data["data"]["men"];
          woman = data["data"]["woman"];
          min_age = data["data"]["min_age"];
          max_age = data["data"]["max_age"];
          age_hide = data["data"]["age_hide"];
          online_hide = data["data"]["online_hide"];
          distance_hide = data["data"]["distance_hide"];

          _starValue = min_age.toDouble();
          _endValue = max_age.toDouble();

          isSeletedMen(men);
          isSeletedWomen(woman);
          isSeletedAge(age_hide);
          isSeletedStatus(online_hide);
          isSeletedDistance(distance_hide);
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"]);
          setState(() {});
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

  _showProgress(BuildContext context) {
    setState(() {
      showLoading = true;
    });
  }

  _hideProgress() {
    setState(() {
      showLoading = false;
    });
  }
}
