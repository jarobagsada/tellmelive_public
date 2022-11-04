import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'helper.dart';

class ShowProgressIntegator{
  /*List<Color> _kDefaultRainbowColors = const [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];*/

  static List<Color> _kDefaultRainbowColors = const [
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.pinkAccent,
    Colors.pink,
    Colors.pink,
    Colors.pinkAccent,

  ];
  static int checkValue=0;

  static  showSingleAnimationDialog(
      BuildContext context, Indicator indicator, bool showPathBackground) {
    if(showPathBackground==false){
      checkValue+=1;

      if(checkValue>1){
        Navigator.pop(context, 1);
        checkValue=0;

      }

    }

    print('showSingleAnimationDialog showPathBackground =$showPathBackground \ncheckValue=$checkValue');
    /* Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: false,
        builder: (ctx) {
          return Scaffold(
            */ /*appBar: AppBar(
              title: Text(indicator.toString().split('.').last),
            ),*/ /*
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                width: 80,
                height: 80,
                child: LoadingIndicator(
                  indicatorType: indicator,
                  colors: _kDefaultRainbowColors,
                  strokeWidth: 2.0,
                  pathBackgroundColor:
                  showPathBackground ? Colors.black45 : null,
                ),
              ),
            ),
          );
        },
      ),
    );*/
    if(showPathBackground==false) {
      showDialog(context: context,
          barrierDismissible: false,
          // barrierColor: Colors.transparent,
          builder: (BuildContext context) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xfff16cae).withOpacity(0.3),
                        Color(0xff3f86c6).withOpacity(0.3),
                      ],
                    )
                ),
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Helper.avatarRadius),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      child: LoadingIndicator(
                        indicatorType: indicator,
                        colors: _kDefaultRainbowColors,
                        strokeWidth: 2.0,
                        pathBackgroundColor:
                        showPathBackground ? Colors.black45 : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
    }else {
      Future.delayed(const Duration(milliseconds: 500), () {
// Here you can write your code

        if (showPathBackground == true) {
          Navigator.pop(context, 1);
        }
      });
    }
  }

}