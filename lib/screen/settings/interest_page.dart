import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/fluttertoast_alert.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../../utilmethod/showDialog_Error.dart';

class InterestedProfile_Screen extends StatefulWidget {
  @override
  _Interest_ScreenState createState() => _Interest_ScreenState();
}

class _Interest_ScreenState extends State<InterestedProfile_Screen> {
  Size _screenSize;
  bool selected_men = false;
  bool selected_women = false;
  bool selected_both = false;
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _visiblity = false;
  var MQ_Width, MQ_Height;
  @override
  void initState() {
    super.initState();
    SessionManager.getString(Constant.Interested).toString();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _GetInterest();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    MQ_Width=MediaQuery.of(context).size.width;
    MQ_Height=MediaQuery.of(context).size.height;
//    routeData =
//        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
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
          child: Align(
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    child: Visibility(
                      visible: _visiblity,
                      child: Container(
                        child: Column(


                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,

                              children: <Widget>[
                                SizedBox(height: 90),
                                CustomWigdet.TextView(
                                    fontSize: 20,
                                    fontFamily: "Kelvetica Nobis",
                                    text: AppLocalizations.of(context)
                                        .translate("Having Interest in?"),
                                    color: Color(0xff1e63b0)),
                                SizedBox(
                                  height: 20,
                                ),
                                selected_men?
                                CustomWigdet.OvalShapedButtonBlue(
                                  onPress: () {
                                    onChangeUser("1");
                                  },
                                  text: AppLocalizations.of(context)
                                      .translate("MEN")
                                      .toUpperCase(),

                                  paddingTop: 11,
                                  paddingBottom: 11,
                                  bgcolor: Custom_color.BlueLightColor,
                                  fontSize: 17,
                                  path: "assest/images/man.png",
                                  fontFamily: "Kelvetica Nobis",
                                  textColor: Custom_color.WhiteColor,)
                                    :CustomWigdet.OvalShapedButtonWhite(
                                    onPress: () {
                                      onChangeUser("1");
                                    },
                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    fontSize: 17,
                                    text: AppLocalizations.of(context)
                                        .translate("MEN")
                                        .toUpperCase(),
                                    path: "assest/images/man.png",
                                    textColor: Custom_color.GreyTextColor,
                                    //  bordercolor: Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis"),
                                SizedBox(
                                  height: 10,
                                ),
                                selected_women? CustomWigdet.OvalShapedButtonBlue(
                                    onPress: () {
                                      onChangeUser("2");
                                    },
                                    text: AppLocalizations.of(context)
                                        .translate("WOMEN")
                                        .toUpperCase(),
                                    textColor: Custom_color.WhiteColor,
                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    fontSize: 17,
                                    path: "assest/images/woman.png",
                                    bgcolor: Custom_color.BlueLightColor,
                                    fontFamily: "Kelvetica Nobis"): CustomWigdet.OvalShapedButtonWhite(
                                    onPress: () {
//                            await _UpdateInterest("2");

                                      onChangeUser("2");
                                      //  SessionManager.setString(Constant.Interested, "2");
                                    },
                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    fontSize: 17,
                                    path: "assest/images/woman.png",

                                    text: AppLocalizations.of(context)
                                        .translate("WOMEN")
                                        .toUpperCase(),
                                    textColor: Custom_color.GreyTextColor,
                                    //   bordercolor: Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis"),
                                SizedBox(
                                  height: 10,
                                ),
                                selected_both? CustomWigdet.OvalShapedButtonBlue(
                                    onPress: () {
                                      onChangeUser("3");
                                    },
                                    text: AppLocalizations.of(context)
                                        .translate("BOTH")
                                        .toUpperCase(),
                                    textColor: Custom_color.WhiteColor,
                                    path: "assest/images/both.png",

                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    fontSize: 17,
                                    bgcolor: Custom_color.BlueLightColor,
                                    fontFamily: "Kelvetica Nobis"): CustomWigdet.OvalShapedButtonWhite(
                                    onPress: () {
                                      //     await _UpdateInterest("3");
                                      onChangeUser("3");

                                      //  print("---get interested-----"+SessionManager.getString(Constant.Interested).toString());
                                    },
                                    text: AppLocalizations.of(context)
                                        .translate("BOTH")
                                        .toUpperCase(),

                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    textColor: Custom_color.GreyTextColor,
                                    path: "assest/images/both.png",
                                    fontSize: 17,

                                    //   bordercolor:  Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis"),
                              ],
                            ),
                            SizedBox(height: 70),
                            CustomWigdet.RoundRaisedButton(
                                onPress: () async {
                                  if(selected_men!=false ||selected_women!=false||selected_both!=false) {
                                    if (await UtilMethod
                                        .SimpleCheckInternetConnection(
                                        context, _scaffoldKey)) {
                                      selected_men
                                          ? await _UpdateInterest("1")
                                          : selected_women
                                          ? await _UpdateInterest("2")
                                          : selected_both
                                          ? await _UpdateInterest("3")
                                          : Navigator.pushNamed(
                                        context,
                                        Constant.ProfessionalRoute,
                                      );
                                    }
                                  }else{

                                    FlutterToastAlert.flutterToastMSG(AppLocalizations.of(context)
                                        .translate("Please select type"), context);
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
                    ),
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
                    color: Custom_color.BlueLightColor),
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

  onChangeUser(String value) {
    if (!UtilMethod.isStringNullOrBlank(value)) {
      print("-----getvalue----" + value.toString());
      if (value == "0") {
        setState(() {
          selected_men = false;
          selected_women = false;
          selected_both = false;
          _visiblity = true;
        });
      } else if (value == "1") {
        setState(() {
          selected_men = true;
          selected_women = false;
          selected_both = false;
          _visiblity = true;
        });
      } else if (value == "2") {
        setState(() {
          selected_men = false;
          selected_women = true;
          selected_both = false;
          _visiblity = true;
        });
      } else if (value == "3") {
        setState(() {
          selected_men = false;
          selected_women = false;
          selected_both = true;
          _visiblity = true;
        });
      }
    }
  }

  Future<https.Response> _GetInterest() async {
    try {
      print("------inside------");
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      String url = WebServices.GetInerest +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      https.Response res = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse----" + res.body);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data["status"]) {
          var value = data["interest"].toString();
          print("-----logging-----");
          onChangeUser(value);

//          Navigator.pushNamed(context, Constant.ProfessionalRoute,
//              arguments: routeData);
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
      } else if (res.statusCode == 500) {
        print(res.statusCode);
        _hideProgress();
        var MSG = "Internal server error issue.Please try again later";
        ShowDialogError.showDialogErrorMessage(context, "Internal Error", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);

      }else if (res.statusCode == 400 || res.statusCode==422) {
        _hideProgress();
        var MSG = "Data request something went wrong.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Bad Request", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==401){
        _hideProgress();
        var MSG = "Access is denied due to invalid credentials .Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Unauthorized Error?", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==403){
        _hideProgress();
        var MSG = "You don't have permission to access/on this server .Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Forbidden Error?", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==404){
        _hideProgress();
        var  MSG = "The requested URL was not found on this server.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "URL Not Found", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else{
        _hideProgress();
        var MSG = "Data response type something went wrong.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Data Response", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
      _visiblity = false;
    }
  }

  Future<https.Response> _UpdateInterest(String name) async {
    try {
      print("------inside------" + name.toString());
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      Map jsondata = {"interest": name};
      String url = WebServices.UpdateInterest +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var res = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + res.body);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data["status"]) {
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
      else if (res.statusCode == 500) {
        print(res.statusCode);
        _hideProgress();
        var MSG = "Internal server error issue.Please try again later";
        ShowDialogError.showDialogErrorMessage(context, "Internal Error", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);

      }else if (res.statusCode == 400 || res.statusCode==422) {
        _hideProgress();
        var MSG = "Data request something went wrong.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Bad Request", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==401){
        _hideProgress();
        var MSG = "Access is denied due to invalid credentials .Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Unauthorized Error?", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==403){
        _hideProgress();
        var MSG = "You don't have permission to access/on this server .Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Forbidden Error?", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==404){
        _hideProgress();
        var  MSG = "The requested URL was not found on this server.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "URL Not Found", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else{
        _hideProgress();
        var MSG = "Data response type something went wrong.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Data Response", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
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
