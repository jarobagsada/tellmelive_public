import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:miumiu/utilmethod/custom_color.dart';

class WebView_Screen extends StatefulWidget {
  @override
  _WebView_ScreenState createState() => _WebView_ScreenState();
}

class _WebView_ScreenState extends State<WebView_Screen>{

  String url;
  bool isLoading=true;
  final _key = UniqueKey();
  var routeData;
  List<Color> _kDefaultRainbowColors = const [
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.pinkAccent,
    Colors.pink,
    Colors.pink,
    Colors.pinkAccent,

  ];

  @override
  Widget build(BuildContext context) {

    routeData = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    url = routeData["url"];
    print("----url-----"+url.toString());
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[

            Padding(
            padding   : EdgeInsets.fromLTRB(5, 50, 5, 5),
            child : WebView(
              key: _key,
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              onPageStarted: (finish) {
                setState(() {
                  isLoading = false;
                });
              },
            )),
            
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
                        padding: const EdgeInsets.only(left: 20.0,top: 5),
                        child:  Container(
                          child: SvgPicture.asset('assest/images_svg/back.svg',color: Custom_color.BlueLightColor,width: 20,height: 20,),
                        ),
                      ),
                    ),
                  ),
                ),

            
            isLoading ? Center( child: false?CircularProgressIndicator():
            Container(
              width: double.infinity,
              height: double.infinity,
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
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  child: LoadingIndicator(
                    indicatorType: Indicator.lineScalePulseOut,
                    colors: _kDefaultRainbowColors,
                    strokeWidth: 2.0,
                    pathBackgroundColor:Colors.black45,
                    // showPathBackground ? Colors.black45 : null,
                  ),
                ),
              ),
            ),)
                : Stack(),
          ],
        ),
      ),
    );
  }

}
