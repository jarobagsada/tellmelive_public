import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FlutterToastAlert{
  static void flutterToastMSG(String MSG,BuildContext mcontext,){
    Fluttertoast.showToast(
        msg: '$MSG!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }
}