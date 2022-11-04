import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

class Professional_Page extends StatefulWidget {
  @override
  _Professional_ScreenState createState() => _Professional_ScreenState();
}

class _Professional_ScreenState extends State<Professional_Page> {
  Size _screenSize;
  bool job_hunting = false;
  bool job_placement = false;
  bool both = false;
  bool others = false;
  bool _visiblity = false;
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

//  var routeData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _GetProfesstion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
//    routeData =
//    ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assest/images/hello.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Visibility(
            visible: _visiblity,
            child:
            Stack(
              children: [
                Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 120),
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CustomWigdet.TextView(
                                fontSize: 20,

                                text: AppLocalizations.of(context).translate("Purpose of joining"),//AppLocalizations.of(context).translate("Having professional interests in?"),
                                color: Color(0xff1e63b0)),
                            SizedBox(
                              height: 50,
                            ),
                            job_hunting
                                ? CustomWigdet.OvalShapedButtonBlue(
                              onPress: () {
                                onChangeUser("1");
                              },
                              text: AppLocalizations.of(context).translate("Looking for job").toUpperCase(),
                              fontFamily: "Kelvetica Nobis",
                              textColor: Custom_color.WhiteColor ,
                              paddingTop: 11,
                              paddingBottom: 11,
                              path: "assest/images/job.png",
                              bgcolor: Custom_color.BlueLightColor,
                            )
                                : CustomWigdet.OvalShapedButtonWhite(
                                onPress: () {
                                  //  _UpdateInterest("1");
                                  onChangeUser("1");
                                },
                                path: "assest/images/job.png",

                                text: AppLocalizations.of(context)
                                    .translate("Looking for job")
                                    .toUpperCase(),
                                textColor: Custom_color.GreyTextColor,
                                paddingTop: 11,
                                paddingBottom: 11,
                                // bordercolor: Custom_color.GreyLightColor,
                                fontFamily: "Kelvetica Nobis"),
                            SizedBox(
                              height: 20,
                            ),
                            /*job_placement
                                ? CustomWigdet.OvalShapedButtonBlue(
                              onPress: () {
                                //onChangeUser("2");
                                onChangeUser("2");

                              },
                              text: AppLocalizations.of(context).translate("Providing Job").toUpperCase(),
                              path: "assest/images/providingJob.png",

                              fontFamily: "Kelvetica Nobis",
                              textColor: Custom_color.WhiteColor,
                              paddingTop: 11,
                              paddingBottom: 11,
                              bgcolor: Custom_color.BlueLightColor,
                            )
                                : CustomWigdet.OvalShapedButtonWhite(
                                onPress: () {
                                  //   _UpdateInterest("2");
                                  onChangeUser("2");
                                },
                                path: "assest/images/providingJob.png",

                                text: AppLocalizations.of(context)
                                    .translate("Providing Job")
                                    .toUpperCase(),
                                textColor: Custom_color.GreyTextColor,
                                paddingTop: 11,
                                paddingBottom: 11,
                                // bordercolor: Custom_color.GreyLightColor,
                                fontFamily: "Kelvetica Nobis"),
                            SizedBox(
                              height: 20,
                            ),*/

                            others
                                ? CustomWigdet.OvalShapedButtonBlue(
                                onPress: () {
                                  onChangeUser("4");
                                },
                                path: "assest/images/NoIntrest.png",

                                text: AppLocalizations.of(context).translate("Looking For Dating").toUpperCase(),//AppLocalizations.of(context).translate("No professional interest").toUpperCase(),
                                paddingTop: 11,
                                paddingBottom: 11,
                                bgcolor: Custom_color.BlueLightColor,
                                fontFamily: "Kelvetica Nobis",
                                textColor: Custom_color.WhiteColor)
                                : CustomWigdet.OvalShapedButtonWhite(
                                onPress: () {
                                  //  _UpdateInterest("4");
                                  onChangeUser("4");
                                },
                                text: AppLocalizations.of(context).translate("Looking For Dating").toUpperCase(),//AppLocalizations.of(context).translate("No professional interest").toUpperCase(),
                                textColor: Custom_color.GreyTextColor,
                                paddingTop: 11,
                                path: "assest/images/NoIntrest.png",

                                paddingBottom: 11,
                                //   bordercolor: Custom_color.GreyLightColor,
                                fontFamily: "Kelvetica Nobis"),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      CustomWigdet.RoundRaisedButton(
                          onPress: () async {
                            if (await UtilMethod.SimpleCheckInternetConnection(
                                context, _scaffoldKey)) {
                              job_hunting
                                  ? await _UpdateInterest("1")
                                  : job_placement
                                  ? await _UpdateInterest("2")
                                  : both
                                  ? await _UpdateInterest("3")
                                  : others
                                  ? await _UpdateInterest("4")
                                  : Navigator.pushNamed(
                                context,
                                Constant.ActivityRoute,
                              );
                            }
                          },
                          text: AppLocalizations.of(context)
                              .translate("Continue")
                              .toUpperCase(),
                          textColor: Custom_color.WhiteColor,
                          bgcolor: Custom_color.BlueLightColor,
                          fontFamily: "OpenSans Bold"),

                    ],
                  ),
                ),
                Positioned(
                  top: 10,

                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Color(0xffc6c6c8),
                                width: 1
                            )
                        )
                    ),
                    width: _screenSize.width,
                    height: 50,
                    padding: EdgeInsets.only(bottom: 5,left: 10,right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: false?Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Custom_color.GreyLightColor,
                                      offset: Offset(0,4),
                                      blurRadius: 5
                                  )
                                ]
                            ),
                            child: CircleAvatar(
                              radius: 15,
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
                          ): Container(
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
                              padding: const EdgeInsets.only(left: 10.0,top: 0,right: 20),
                              child:  Container(
                                child: SvgPicture.asset('assest/images_svg/back.svg',color: Custom_color.BlueLightColor,width: 18,height: 18,),
                              ),
                            ),
                          ),
                        ),



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
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: _screenSize.width,
                  height: 1,
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

  Future<https.Response> _GetProfesstion() async {
    try {
      print("------inside------");
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      String url = WebServices.GetProfessional +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      https.Response response = await https.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Cache-Control": "no-cache",
      });
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          var value = data["prof_interest"].toString();
          print("-----logging-----");
          onChangeUser(value);
        } else {
          _visiblity = false;
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
      _visiblity = false;
    }
  }

  onChangeUser(String value) {
    if (!UtilMethod.isStringNullOrBlank(value)) {
      print("-----getvalue----" + value.toString());
      if (value == "0") {
        setState(() {
          job_hunting = false;
          job_placement = false;
          both = false;
          others = false;
          _visiblity = true;
        });
      } else if (value == "1") {
        setState(() {
          job_hunting = true;
          job_placement = false;
          both = false;
          others = false;
          _visiblity = true;
        });
      } else if (value == "2") {
        setState(() {
          job_hunting = false;
          job_placement = true;
          both = false;
          others = false;
          _visiblity = true;
        });
      } else if (value == "3") {
        setState(() {
          job_hunting = false;
          job_placement = false;
          both = true;
          others = false;
          _visiblity = true;
        });
      } else if (value == "4") {
        setState(() {
          job_hunting = false;
          job_placement = false;
          both = false;
          others = true;
          _visiblity = true;
        });
      }
    }
  }

  Future<https.Response> _UpdateInterest(String name) async {
    try {
      print("------inside------" + name.toString());
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      Map jsondata = {"prof_interest": name};
      String url = WebServices.UpdateProfessional +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          print("-----logging-----");
          Navigator.pop(context, true);
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
