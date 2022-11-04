import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:intl/intl.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

class DateOf_Birth_Screen extends StatefulWidget {
  @override
  _FirstName_ScreenState createState() => _FirstName_ScreenState();
}

class _FirstName_ScreenState extends State<DateOf_Birth_Screen> {
  Size _screenSize;
  DateTime selectedDate;
  var routeData;
  var customFormat = DateFormat('dd-MM-yyyy');
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ProgressDialog progressDialog;
  bool checkrunFirsttime = true;

  Future<Null> showPicker(BuildContext context) async {
    final DateTime picked = await DatePicker.showSimpleDatePicker(context,
        initialDate: DateTime.now().subtract(Duration(days: ((18 * 365))+5)),
        firstDate: DateTime(1900),
        lastDate: DateTime.now().subtract(Duration(days: ((18 * 365))+5)),
//        initialDate: DateTime.now(),
//        firstDate: DateTime(1900),
//        lastDate: DateTime.now().add(Duration(days: 31)),
        dateFormat: "dd-MMMM-yyyy",
        locale: SessionManager.getString(Constant.Language_code)=="en"? DateTimePickerLocale.en_us: SessionManager.getString(Constant.Language_code)=="de"? DateTimePickerLocale.de: SessionManager.getString(Constant.Language_code)=="ar"? DateTimePickerLocale.ar: DateTimePickerLocale.tr,
        //  dateFormat: "MMMM-dd-yyyy",
        titleText: AppLocalizations.of(context).translate("Select Date"),
        cancelText: AppLocalizations.of(context).translate("Cancel"),
        confirmText: AppLocalizations.of(context).translate("Ok"),
        looping: true);

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }


  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    routeData = ModalRoute.of(context).settings.arguments;
    print("---roure---"+routeData.toString());
    if(checkrunFirsttime && routeData!=null)
    {
      DateTime tempDate =  DateFormat('dd-MM-yyyy').parse(routeData["dob"]);
      selectedDate = tempDate;
      print("-----selet----"+tempDate.toString()+"----"+selectedDate.toString());
      checkrunFirsttime = false;
    }

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
              Container(
                width: _screenSize.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomWigdet.TextView(
                          fontSize: 20,

                          text: AppLocalizations
                              .of(context)
                              .translate("What is your date of birth?"),
                          color: Color(0xff1e63b0)),
                      SizedBox(
                        height: 10,
                      ),
                      _otpTextField(context),
                      SizedBox(
                        height: 10,
                      ),
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context)
                              .translate("We need your date of birth"),
                          fontSize: 15,
                          color: Custom_color.GreyLightColor,
                          fontFamily: "Kelvetica Nobis",
                          textAlign: TextAlign.center),
                      SizedBox(height: 50),


                      CustomWigdet.RoundRaisedButton(
                          onPress: () {
                            OnSubmit(context);
                          },
                          text: AppLocalizations.of(context)
                              .translate("Confirm")
                              .toUpperCase(),
                          textColor: Custom_color.WhiteColor,
                          bgcolor: Custom_color.BlueLightColor,
                          fontFamily: "OpenSans Bold"),
                    ],
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
    );
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
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

  Widget _otpTextField(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              height: 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Color(0xffd7dbe6),
                      offset: Offset(0,6),
                      blurRadius: 20

                  )
                ],

                color: Custom_color.WhiteColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => showPicker(context),
                child: Padding(
                  padding: const EdgeInsets.only(top: 17,bottom: 15,left: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      // Icon(Icons.calendar_today,color: Colors.black,size: 20,),
                      // SizedBox(width: 22),
                      CustomWigdet.TextView(
                          textAlign: TextAlign.start,
                          text: selectedDate == null
                              ? AppLocalizations.of(context).translate("What is your date of birth?")
                              : "${customFormat.format(selectedDate)}",
                          color: Color(0xff9a9a9a),
                          fontFamily: "Kelvetica Nobis"
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ],
    );
  }

  Future<void> OnSubmit(BuildContext context) async {
    print("-----date---" + selectedDate.toIso8601String());

    if (await UtilMethod.SimpleCheckInternetConnection(context, _scaffoldKey)) {
      DateTime Currentdate = DateTime.now();
      DateTime selet_date = selectedDate;

      if (Currentdate.isBefore(selet_date)) {
        UtilMethod.SnackBarMessage(
            _scaffoldKey,
            AppLocalizations.of(context)
                .translate("Please valid Date of birth"));
      } else {
        _UpdateDOB(customFormat.format(selectedDate));
      }
    }
  }

  Future<https.Response> _UpdateDOB(String dob) async {
    try {
      print("------inside------" + dob.toString());
      _showProgress(context);
      Map jsondata = {"dob": dob};
      String url =
          WebServices.GetUpdateDOB + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          SessionManager.setString(Constant.Dob,dob);
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"]);
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
