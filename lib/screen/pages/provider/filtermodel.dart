import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:miumiu/utilmethod/constant.dart';

class FilterModel extends ChangeNotifier {
  int interestValue = 0;
  int languagevalue = Constant.English;
  bool _loading = false;
  String activityItem = "";
  bool private = false, looking_for_job = false, providing_job = false,distanceEnable = false;

  double slidercount = 30;


  getInerestValue() => interestValue;

  getlangugaValue() => languagevalue;

  getLoadingValue() => _loading;

  getActivityValue() => activityItem;

  getPrivateValue() => private;

  getLookingForJob() => looking_for_job ;

  getProvidingJob()=> providing_job;

  getSliderCount()=> slidercount;
  getDistanceEnable()=> distanceEnable;

  Future<void> updateInterest(int name) async {
    interestValue = await name;
    notifyListeners();
  }

  Future<void> updateLanguage(int name) async {
    languagevalue = await name;
    notifyListeners();
  }

  Future<void> updateLoading(bool value) async {
    _loading = await value;
    notifyListeners();
  }

  Future<void> updateActivityItem(String value) async {
    activityItem = await value;
    notifyListeners();
  }

  Future<void> updatePrivate(bool value) async {
    private = await value;
    notifyListeners();
  }

  Future<void> updateLookingForJob(bool value) async {
    looking_for_job = await value;
    notifyListeners();
  }

  Future<void> updateProvidingJob(bool value) async {
    providing_job = await value;
    notifyListeners();
  }

  Future<void> updateSliderCount(double value) async {
    slidercount = await value;
    notifyListeners();
  }
  Future<void> updateDistanceEnable(bool value) async {
    distanceEnable = await value;
    notifyListeners();
  }
}
