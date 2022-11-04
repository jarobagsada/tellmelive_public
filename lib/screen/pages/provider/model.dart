import 'package:flutter/foundation.dart';
import 'package:miumiu/utilmethod/constant.dart';

class CounterModel with ChangeNotifier { //    <<--MyModel



  int ChatValue = 0;
  int NotifyValue =0;

  getCounter() => ChatValue;

  getNotificationCounter() => NotifyValue;



  void doSomething() {
    ChatValue = int.parse(Constant.DummyChatCount);
    NotifyValue = int.parse(Constant.DummyNotificationCount);

    print("------chatvalue--------&&&&&&&&&&&&&&&&&&&&&&&&---"+ChatValue.toString());
    notifyListeners();
  }


}