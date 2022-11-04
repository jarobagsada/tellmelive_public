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

class FirstName_Screen extends StatefulWidget {
  @override
  _FirstName_ScreenState createState() => _FirstName_ScreenState();
}

class _FirstName_ScreenState extends State<FirstName_Screen> {
  Size _screenSize;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String firstname = "";
  var routeData;
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController textEditingController = new TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero,(){
      routeData = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      if(routeData!=null){
        textEditingController.text = routeData["name"];
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    routeData = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
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
          child: Stack(
            children: [
              Center(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      children: <Widget>[

                        SizedBox(height: 200),
                        CustomWigdet.TextView(
                            fontSize: 20,
                             text: AppLocalizations
                                .of(context)
                                .translate("What's your first name?"),
                            color: Color(0xff1e63b0),),

                        SizedBox(
                          height: 30,
                        ),
                        _otpTextField(),
                        SizedBox(
                          height: 10,
                        ),
                        CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("We're sure you have a cuted"),
                            fontSize: 12,
                            color: Custom_color.GreyLightColor,
                            fontFamily: "OpenSans Bold",
                            textAlign: TextAlign.center),


                        SizedBox(height: 50),


                        CustomWigdet.RoundRaisedButton(
                            onPress: () {
                              OnSubmit(context);
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
              Positioned(
                top: 10,
                left: 10,
                child: InkWell(
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
                top: 60,
                child:Container(

                  width: _screenSize.width*80,
                  height: 0.2,
                  decoration: BoxDecoration(
                      color: Custom_color.BlueLightColor,
                    borderRadius: BorderRadius.circular(30)
                  ),
                ), )
            ],
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
      bottom: PreferredSize(
          child: Container(
              width: _screenSize.width,
              height: 1,
              color: Custom_color.BlueLightColor),
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
  Widget _otpTextField() {
    return Container(
        height: 50,

        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue,width: 0.2),
          boxShadow: [
            BoxShadow(
                color:Color(0xffd7dbe6),
                offset: Offset(0,6),
                blurRadius: 20

            )
          ],
          color: Custom_color.WhiteColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 17,bottom: 15),
          child: Form(
            key: this._formKey,
            child: TextFormField(
              autofocus: true,
              showCursor: true,
              style: TextStyle(
                  color: Custom_color.BlackTextColor,
                  fontFamily: "OpenSans Regular",
                  fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: ImageIcon(
                  AssetImage("assest/images/name.png")
                  ,color: Custom_color.GreyTextColor,),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(0.0),
                isDense: true,
                hintStyle: TextStyle(
                    color: Color(0xff9a9a9a),
                    fontFamily: "Kelvetica Nobis"
                ),
                hintText:
                AppLocalizations.of(context).translate("What's your first name?").toLowerCase(),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context)
                      .translate("Empty name");
                }
              },
              onSaved: (value) {
                firstname = value;
              },
            ),
          ),
        ));
  }

  void OnSubmit(BuildContext context) {
    if (!this._formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save(); // Save our form now.

    print('Printing the  data.');
    print('Email: ${firstname}');

    _UpdateName(firstname);

    // Navigator.push(context, MaterialPageRoute(builder:(context) =>HomeScreen(),settings: RouteSettings(arguments: ScreenArguments(""))));

    // Navigator.pushNamed(context, HomeScreen.home_route,arguments: {"id":"12","titke":"xyz"});

    //  Navigator.pushNamed(context, HomeScreen.home_route);
  }

  Future<https.Response> _UpdateName(String name) async {
    try {
      _showProgress(context);
      Map jsondata = {
        "name": name
      };
      String url = WebServices.GetUpdateName +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          SessionManager.setString(Constant.Name,name);
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"]);
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
  }
}
