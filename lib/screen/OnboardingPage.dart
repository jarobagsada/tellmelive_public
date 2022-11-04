import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:miumiu/language/AppLanguage.dart';

import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/preferences.dart';




import '../colors/colors.dart';
import '../utilmethod/constant.dart';
class OnBoardingPage extends StatefulWidget {
  //static const routeName = "/OnBoarding";
  final AppLanguage appLanguage;
  OnBoardingPage({this.appLanguage});

  //const OnBoardingPage({Key key}) : super(key: key);

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  List<Slide> slides = [];
  Function goToTab;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    slides.add(
      Slide(
          title: "Activities",
          styleTitle: const TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
          description: "Create Your Own Activities or Join Activities of Other Users in The App.",
          styleDescription:
          const TextStyle( fontSize: 30.0, fontWeight: FontWeight.bold),
          pathImage: "assest/images/screen1.png",
      ),
    );
    slides.add(
      Slide(
          title: "Dating",
          styleTitle: const TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
          description: "Explore our Unique TellmeLive Map & Find Singles Around You",
          styleDescription:
          const TextStyle( fontSize: 30.0, fontWeight: FontWeight.bold),
          pathImage: "assest/images/screen2.png",
      ),
    );
    slides.add(
      Slide(
          title: "Networking",
          styleTitle: const TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
          description: "Meet Like-Minded People and Grow Your Business-Network",
          styleDescription:
          const TextStyle( fontSize: 30.0, fontWeight: FontWeight.bold),
          pathImage: "assest/images/screen3.png",
      ),
    );

  }

  void onDonePress() {

    /*PreferenceProvider.of(context).onboard();
    Navigator.of(context).pushNamed(SelectLanguage.routeName);*/


    SessionManager.setboolean(Constant.Onboarded, true);

    Navigator.of(context).pushNamedAndRemoveUntil(
        Constant.LanguageScreen, (Route<dynamic> route) => false,
    );
  }

  void onTabChangeCompleted(index) {
  }

  Widget renderNextBtn() {
    return const Icon(
      Icons.navigate_next,
      color: Color(colorsThemeBlue),
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return const Icon(
      Icons.done,
      color:Color(colorsThemeBlue),
    );
  }

  Widget renderSkipBtn() {
    return const Icon(
      Icons.skip_next,
      color: Color(colorsThemeBlue),
    );
  }
  ButtonStyle myButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
      backgroundColor:
      MaterialStateProperty.all<Color>(const Color(0x33F3B4BA)),
      overlayColor: MaterialStateProperty.all<Color>(const Color(0x33FFA8B0)),
    );
  }

  ButtonStyle myDoneButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      overlayColor: MaterialStateProperty.all<Color>(Colors.white60),
    );
  }
  ButtonStyle myNextButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      overlayColor: MaterialStateProperty.all<Color>(Colors.white60),
    );
  }

  List<Widget> renderListCustomTabs() {
    List<Widget> tabs = [];
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assest/images/intro_bg.png"),
                fit: BoxFit.cover
            ),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child:
          Container(
            margin: const EdgeInsets.only(bottom: 60.0, top: 60.0),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 80,),
                Container(
                  width: 220.0,
                  height: 220.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2), // border width
                    child: Container( //
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // inner circle color
                      ),
                      child:  GestureDetector(
                          child: Image.asset(
                            slides[i].pathImage,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.contain,
                          )),// inner content
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    currentSlide.title,
                    style: Theme.of(context).textTheme.headline3.copyWith(
                        color: const Color(colorsThemeBlue),
                        fontWeight: FontWeight.bold,
                      fontSize: 40
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  margin: const EdgeInsets.only(top: 50.0),
                ),
                Container(
                  child: Text(
                    currentSlide.description,
                    style: Theme.of(context).textTheme.titleLarge.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                        fontSize: 18
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  margin: const EdgeInsets.all(10.00),
                ),
              ],
            ),
          )
      ));
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
   // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    return Scaffold(
      key: _scaffoldKey,
     // resizeToAvoidBottomInset: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
         children:<Widget>[
          IntroSlider(
            showSkipBtn: false,
            showPrevBtn: false,
            nextButtonStyle:myDoneButtonStyle() ,
            renderNextBtn:renderNextBtn(),
            renderDoneBtn: renderDoneBtn(),
            onDonePress: onDonePress,
            doneButtonStyle: myDoneButtonStyle(),
            colorDot:const Color(colorsThemePink),
            sizeDot: 12.0,
            listCustomTabs: renderListCustomTabs(),
            backgroundColorAllSlides: Colors.white,
            refFuncGoToTab: (refFunc) {
              goToTab = refFunc;
            },
            scrollPhysics: const BouncingScrollPhysics(),
            hideStatusBar: true,
           // typeDotAnimation: DotSliderAnimation.SIZE_TRANSITION,

          ),
        ],
      ),
    );
  }
}