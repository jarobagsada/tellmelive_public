import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/pages/provider/model.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:provider/provider.dart';

class UtilMethod {
 static CounterModel counterModel;

  static bool isStringNullOrBlank(String str) {
    if (str == null) {
      return true;
    } else if (str == ("null") || str == (""))  {
      return true;
    }
    return false;
  }

  static Future<bool> SnackBarMessage(
      GlobalKey<ScaffoldState> _scaffoldKey, String message) async {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  static bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  static String dateformate(String date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(DateTime.parse(date));
    return formatted;
  }

  static Future<bool> SimpleCheckInternetConnection(
      BuildContext context, GlobalKey<ScaffoldState> _scaffoldKey) async {
    bool connection = await DataConnectionChecker().hasConnection;
    if (connection == false) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate("Check your connection"))));
    }
    return connection;
  }

  static Future<void> showSimpleAlert(
      {@required BuildContext context,
      @required String heading,
      @required String message}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 4), () {
            SessionManager.cleanPrefrence();
            Navigator.of(context).pushNamedAndRemoveUntil(
              Constant.LoginRoute,
              (Route<dynamic> route) => false,
            );
          });
          return WillPopScope(
            onWillPop: () {},
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              ) ,
              title: Text(
                heading,
                style: TextStyle(color: Custom_color.BlackTextColor),
              ),
              content: Text(
                message.toUpperCase(),
                style: TextStyle(color: Custom_color.BlackTextColor),
              ),
            ),
          );
        });
  }
  static SetChatCount(BuildContext context,String value)
  {
    if(context!=null) {
      counterModel = Provider.of<CounterModel>(context, listen: false);
      Constant.DummyChatCount = value ?? "0";
      counterModel.doSomething();
    }
  }

  static SetNotificationCount(BuildContext context,String value)
  {
    if(context!=null) {
      counterModel = Provider.of<CounterModel>(context, listen: false);
      Constant.DummyNotificationCount = value ?? "0";
      counterModel.doSomething();
    }
  }

  static HideKeyboard(BuildContext context){
    FocusScope.of(context).requestFocus(new FocusNode());
  }
}

getPoint(isLatitude)
{
    try
    {
        if(Constant.currentLocation != null)
        {
            if(isLatitude)
              return Constant.currentLocation.latitude;
            else
              return Constant.currentLocation.longitude;
        }
    else
    {
            if(isLatitude)
              return Constant.LATITUDE;
            else
              return Constant.LONGITUDE;
    }
    }catch(e){
            if(isLatitude)
              return Constant.LATITUDE;
            else
              return Constant.LONGITUDE;
    }
    
    
}


