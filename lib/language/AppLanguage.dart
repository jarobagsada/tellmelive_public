import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en');

  Locale get appLocal => _appLocale ?? Locale("en");
  fetchLocale() async {
    String currentLocale;

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      }
      // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      //currentLocale = await Devicelocale.currentLocale;
    } on PlatformException {
      print("Error obtaining current locale");
    }

   // Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //  final SharedPreferences prefs = await _prefs;

    // if (SessionManager.getString('language_code') == null)

    {
   //   if (currentLocale != null && currentLocale == "de_DE")
      print("--------langaye code-inside-------"+SessionManager.getString(Constant.Language_code));
      if(SessionManager.getString(Constant.Language_code)=="de")
         {
        _appLocale = Locale('de');
        print("--------de------");
        return Null;
      }
      else if(SessionManager.getString(Constant.Language_code)=="ar")
      {
        _appLocale = Locale('ar');
        print("--------de------");
        return Null;
      }
      else
        {
        _appLocale = Locale('en');
        print("--------en----------");
        return Null;
      }
    }

  //  _appLocale = Locale(prefs.getString('language_code'));
  //  return Null;
  }

  void changeLanguage(Locale type) async {
  //  var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == Locale("en")) {
      _appLocale = Locale("en");
      SessionManager.setString(Constant.Language_code, "en");
    //  await prefs.setString('language_code', 'en');
     // await prefs.setString('countryCode', '');
    }
    else if (type == Locale("ar")) {
      _appLocale = Locale("ar");
      SessionManager.setString(Constant.Language_code, "ar");
      //  await prefs.setString('language_code', 'en');
      // await prefs.setString('countryCode', '');
    }
//    else {
//      _appLocale = Locale("en");
//      await prefs.setString('language_code', 'en');
//      await prefs.setString('countryCode', 'US');
//    }
    else {
      _appLocale = Locale("de");
      SessionManager.setString(Constant.Language_code, "de");
      // await prefs.setString('language_code', 'de');
      // await prefs.setString('countryCode', '');
    }
    notifyListeners();
  }
}
