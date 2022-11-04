import 'dart:async' show Future;
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
 // static Future<SharedPreferences> _prefs  =  SharedPreferences.getInstance();
  //static Future<SharedPreferences> get _instance async => _prefsInstance ??= await _prefs;
  static Future<SharedPreferences> get _instance async => _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences _prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
     _prefsInstance = await _instance;
    return _prefsInstance;
 //   _prefsInstance = await _instance;
   // return _prefsInstance;
  }

  static String getString(String key, [String defValue]) {
    return _prefsInstance.getString(key) ?? defValue ?? "";
  }

  static Future<bool> setboolean(String key, bool value) async {
    var prefs = await _instance;
    return prefs?.setBool(key, value) ?? Future.value(false);
  }

  static bool getbooleanTrueDefault(String key, ) {
    return _prefsInstance.getBool(key)??true;
  }

  static bool getboolean(String key, ) {
    return _prefsInstance.getBool(key)??false;
  }

  static Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    return prefs?.setString(key, value) ?? Future.value(false);
  }


//  static String getListString(String key, [String defValue]) {
//    return _prefsInstance.getStringList(key) ?? defValue ?? "";
//  }
//
//  static Future<bool> setListString(String key, List<dynamic> value) async {
//    var prefs = await _instance;
//    return prefs?.setStringList(key, value) ?? Future.value(false);
//  }


   static Future cleanPrefrence() async {
     await _prefsInstance.clear();
   }
}