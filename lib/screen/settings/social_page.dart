import 'dart:convert';
import 'dart:ui';

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

class SocialMedia_Page extends StatefulWidget {
  @override
  _SocialMedia_PageState createState() => _SocialMedia_PageState();
}

class _SocialMedia_PageState extends State<SocialMedia_Page> {
  Size _screenSize;
  bool facebook = false;
  bool instagram = false;
  bool twitter = false;
  bool tiktok = false;
  bool all = false;
  bool linkedin = false;
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
        _GetMedia();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery
        .of(context)
        .size;
//    routeData =
//    ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Container(
            child: Visibility(
              visible: _visiblity,
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomWigdet.TextView(
                                        text: AppLocalizations.of(context)
                                            .translate("Which social media do use?"),
                                        fontSize: 20.0,
                                        textAlign: TextAlign.center,
                                        color: Color(0xff1e63b0),
                                        fontFamily: "Kelvetica Nobis"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GridView.extent(
                                      maxCrossAxisExtent: 150.0,
                                      shrinkWrap: true,
                                      primary: false,
                                      physics: NeverScrollableScrollPhysics(),

                                      // crossAxisSpacing: 2.0,
                                      // mainAxisSpacing: 2.0,
                                      //   crossAxisCount: 3,
                                      children: <Widget>[
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  facebook = !facebook;
                                                  all = false;
                                                });
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.all(25),
                                                  decoration: BoxDecoration(

                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      color: facebook
                                                          ? Custom_color.BlueLightColor
                                                          : Custom_color.GreyColor),
                                                  child: Image.asset(
                                                    "assest/images/facebook.png",
                                                    color: Custom_color.WhiteColor,
                                                    width: 30,
                                                    height: 30,
                                                  )),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            CustomWigdet.TextView(
                                                text: AppLocalizations.of(context)
                                                    .translate("Facebook"),
                                                fontFamily: "OpenSans Bold",
                                                fontSize: 10,
                                                color: Custom_color.BlackTextColor),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  twitter = !twitter;
                                                  all = false;
                                                });
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.all(25),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      color: twitter
                                                          ? Color(0xff00acee)
                                                          : Custom_color.GreyColor),
                                                  child: Image.asset(
                                                    "assest/images/twitter.png",
                                                    color: Custom_color.WhiteColor,
                                                    width: 30,
                                                    height: 30,
                                                  )),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            CustomWigdet.TextView(
                                                text: AppLocalizations.of(context)
                                                    .translate("Twitter"),
                                                fontFamily: "OpenSans Bold",
                                                fontSize: 10,
                                                color: Custom_color.BlackTextColor),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  instagram = !instagram;
                                                  all = false;
                                                });
                                              },
                                              child: instagram ? Container(
                                                  padding: EdgeInsets.all(25),
                                                  decoration: BoxDecoration(
                                                    gradient:LinearGradient(  colors: [Color(0xffF58529) ,Color(0xffFEDA77),Color(0xffDD2A7B),Color(0xff8134AF),Color(0xff515BD4)],


                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                  ),
                                                  child: Image.asset(
                                                    "assest/images/instagram.png",
                                                    color: Custom_color.WhiteColor,
                                                    width: 30,
                                                    height: 30,
                                                  )): Container(
                                                  padding: EdgeInsets.all(25),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      color
                                                          : Custom_color.GreyColor),
                                                  child: Image.asset(
                                                    "assest/images/instagram.png",
                                                    color: Custom_color.WhiteColor,
                                                    width: 30,
                                                    height: 30,
                                                  )),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            CustomWigdet.TextView(
                                                text: AppLocalizations.of(context)
                                                    .translate("Instagram"),
                                                fontFamily: "OpenSans Bold",
                                                fontSize: 10,
                                                color: Custom_color.BlackTextColor),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  tiktok = !tiktok;
                                                  all = false;
                                                });
                                              },
                                              child: tiktok
                                                  ? Container(
                                                  padding: EdgeInsets.all(25),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      color: tiktok
                                                          ? Color(0xFF000000)
                                                          : Custom_color.GreyColor),
                                                  child: Image.asset(


                                                    "assest/images/tiktokColor.png",
                                                    // color: Custom_color.WhiteColor,
                                                    width: 30,
                                                    height: 30,

                                                  )): Container(
                                                  padding: EdgeInsets.all(25),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      color: Custom_color.GreyColor),
                                                  child: Image.asset(
                                                    "assest/images/tik_tok.png",
                                                    color: Custom_color.WhiteColor,
                                                    width: 30,
                                                    height: 30,
                                                  )),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            CustomWigdet.TextView(
                                                text: AppLocalizations.of(context)
                                                    .translate("Tik Tok"),
                                                fontFamily: "OpenSans Bold",
                                                fontSize: 10,
                                                color: Custom_color.BlackTextColor),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  linkedin = !linkedin;
                                                  all = false;
                                                });
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.all(25),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      color: linkedin
                                                          ? Color(0xff0077b5)
                                                          : Custom_color.GreyColor),
                                                  child: Image.asset(
                                                    "assest/images/linkedin.png",
                                                    color: Custom_color.WhiteColor,
                                                    width: 30,
                                                    height: 30,
                                                  )),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            CustomWigdet.TextView(
                                                text: AppLocalizations.of(context)
                                                    .translate("Linkedin"),
                                                fontFamily: "OpenSans Bold",
                                                fontSize: 10,
                                                color: Custom_color.BlackTextColor),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  all = !all;
                                                  if (all) {
                                                    facebook = true;
                                                    twitter = true;
                                                    instagram = true;
                                                    tiktok = true;
                                                    linkedin = true;
                                                  } else {
                                                    facebook = false;
                                                    twitter = false;
                                                    instagram = false;
                                                    tiktok = false;
                                                    linkedin = false;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.all(25),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      color: all
                                                          ? Custom_color.BlueLightColor
                                                          : Custom_color.GreyColor),
                                                  child: Image.asset(
                                                    "assest/images/smartphone.png",
                                                    color: Custom_color.WhiteColor,
                                                    width: 30,
                                                    height: 30,
                                                  )),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            CustomWigdet.TextView(
                                                text: AppLocalizations.of(context)
                                                    .translate("All"),
                                                fontFamily: "OpenSans Bold",
                                                fontSize: 10,
                                                color: Custom_color.BlackTextColor),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        CustomWigdet.RoundRaisedButton(
                            onPress: () async {
                              if (await UtilMethod.SimpleCheckInternetConnection(
                                  context, _scaffoldKey)) {
                                _UpdateMedia();
                              }
                            },
                            text: AppLocalizations.of(context)
                                .translate("Continue")
                                .toUpperCase(),
                            textColor: Custom_color.WhiteColor,
                            bgcolor: Custom_color.BlueLightColor,
                            fontFamily: "OpenSans Bold"),
                        SizedBox(
                          height: 20,
                        )
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
                            child: Container(
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

  Future<https.Response> _GetMedia() async {
    try {
      print("------inside------");
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      String url = WebServices.GetProfile +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      //   print("-----url-----" + url.toString());
      https.Response response = await https.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Cache-Control": "no-cache",
      });
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          var name = data["user_info"]["social"];
          print("-----logging-----");
          onChangeUser(name);


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


  onChangeUser(value) {
    print("---------value----------"+value.runtimeType.toString());

    if (value != null) {
      _visiblity = true;
      if(value.runtimeType ==String){
        setState(() {});
        return;
      }
      print("-----getvalue----" + value.toString());
      if (value["facebook"] == "1") {
        _visiblity = true;
        setState(() {
          facebook = true;
        });
      }
      else {
        setState(() {
          facebook = false;
        });
      }
      if (value["twitter"] == "1") {
        _visiblity = true;
        setState(() {
          twitter = true;
        });
      }
      else {
        twitter = false;
      }
      if (value["instagram"] == "1") {
        _visiblity = true;
        setState(() {
          instagram = true;
        });
      }
      else {
        setState(() {
          instagram = false;
        });
      }

      if (value["tiktok"] == "1") {
        _visiblity = true;
        setState(() {
          tiktok = true;
        });
      } else {
        setState(() {
          tiktok = false;
        });
      }
      if (value["linkedin"] == "1") {
        _visiblity = true;
        setState(() {
          linkedin = true;
        });
      }
      else {
        setState(() {
          linkedin = false;
        });
      }
      if (value["all"] == "1") {
        _visiblity = true;
        setState(() {
          all = true;
        });
      }
      else {
        setState(() {
          all = false;
        });
      }
    }else{
      setState(() {
        _visiblity = true;
      });
    }
  }

  Future<https.Response> _UpdateMedia() async {
    try {
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      Map jsondata = {
        "facebook": facebook ? "1" : "0",
        "twitter": twitter ? "1" : "0",
        "instagram": instagram ? "1" : "0",
        "tiktok": tiktok ? "1" : "0",
        "linkedin": linkedin ? "1" : "0",
        "all": all ? "1" : "0"
      };

      print("----json---" + jsondata.toString());
      String url = WebServices.UpdateSocialMedia +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          Navigator.pop(context,true);
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
  }}
