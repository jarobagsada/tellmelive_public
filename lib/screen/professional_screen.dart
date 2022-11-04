import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/helper.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../utilmethod/fluttertoast_alert.dart';
import '../utilmethod/showDialog_Error.dart';

class Professional_Screen extends StatefulWidget {
  @override
  _Professional_ScreenState createState() => _Professional_ScreenState();
}

class _Professional_ScreenState extends State<Professional_Screen> {
  Size _screenSize;
  bool job_hunting = false;
  bool job_placement = false;
  bool look_Dating = false;

  bool both = false;
  bool others = false;
  bool _visiblity = false;
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var MQ_Height;
  var MQ_Width;
//  var routeData;
  bool showLoading;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showLoading   = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _GetProfesstion();
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
     MQ_Height=MediaQuery.of(context).size.height;
     MQ_Width=MediaQuery.of(context).size.width;

//    routeData =
//    ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
           // _widgetProfessional()
            _widgetProfessionalNewUI()
          ],
        )
      
      ),
    );
  }

  //================== Old UI professional ==========
   Widget _widgetProfessional(){
    return Column(
        children : [
          SizedBox(
            height: showLoading ? 2:0,
            child: LinearProgressIndicator(
              backgroundColor: Color(int.parse(Constant.progressBg)),
              valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse(Constant.progressVl)),),
              minHeight: 2,
            ),
          ),
          Expanded(
            child :

            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assest/images/hello.jpg"),
                  fit: BoxFit.cover,
                ),
              ),

              child: Visibility(
                visible: _visiblity,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 120),
                          Padding(
                            padding: const EdgeInsets.only(left: 20,right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CustomWigdet.TextView(
                                    fontSize: 20,

                                    text: AppLocalizations
                                        .of(context)
                                        .translate("Having professional interests in?"),
                                    color: Color(0xff1e63b0)),
                                SizedBox(
                                  height: 20,
                                ),
                                job_hunting
                                    ? CustomWigdet.OvalShapedButtonBlue(
                                  onPress: () {
                                    onChangeUser("1");
                                  },
                                  text: AppLocalizations.of(context)
                                      .translate("Looking for job")
                                      .toUpperCase(),
                                  fontFamily: "Kelvetica Nobis",
                                  textColor: Custom_color.WhiteColor ,
                                  paddingTop: 11,
                                  paddingBottom: 11,
                                  path: "assest/images/job.png",
                                  bgcolor: Custom_color.BlueLightColor,
                                )
                                    : CustomWigdet.OvalShapedButtonWhite(
                                    onPress: () {
                                      //  _UpdateInterest("1");
                                      onChangeUser("1");
                                    },
                                    path: "assest/images/job.png",

                                    text: AppLocalizations.of(context)
                                        .translate("Looking for job")
                                        .toUpperCase(),
                                    textColor: Custom_color.GreyTextColor,
                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    // bordercolor: Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis"),
                                SizedBox(
                                  height: 20,
                                ),
                                job_placement
                                    ? CustomWigdet.OvalShapedButtonBlue(
                                  onPress: () {
                                    onChangeUser("2");
                                  },
                                  text: AppLocalizations.of(context)
                                      .translate("Providing Job")
                                      .toUpperCase(),
                                  path: "assest/images/providingJob.png",

                                  fontFamily: "Kelvetica Nobis",
                                  textColor: Custom_color.WhiteColor,
                                  paddingTop: 11,
                                  paddingBottom: 11,
                                  bgcolor: Custom_color.BlueLightColor,
                                )
                                    : CustomWigdet.OvalShapedButtonWhite(
                                    onPress: () {
                                      //   _UpdateInterest("2");
                                      onChangeUser("2");
                                    },
                                    path: "assest/images/providingJob.png",

                                    text: AppLocalizations.of(context)
                                        .translate("Providing Job")
                                        .toUpperCase(),
                                    textColor: Custom_color.GreyTextColor,
                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    // bordercolor: Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis"),
                                SizedBox(
                                  height: 20,
                                ),

                                others
                                    ? CustomWigdet.OvalShapedButtonBlue(
                                    onPress: () {
                                      onChangeUser("4");
                                    },
                                    path: "assest/images/NoIntrest.png",

                                    text: AppLocalizations.of(context)
                                        .translate("No professional interest")
                                        .toUpperCase(),
                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    bgcolor: Custom_color.BlueLightColor,
                                    fontFamily: "Kelvetica Nobis",
                                    textColor: Custom_color.WhiteColor)
                                    : CustomWigdet.OvalShapedButtonWhite(
                                    onPress: () {
                                      //  _UpdateInterest("4");
                                      onChangeUser("4");
                                    },
                                    text: AppLocalizations.of(context)
                                        .translate("No professional interest")
                                        .toUpperCase(),
                                    textColor: Custom_color.GreyTextColor,
                                    paddingTop: 11,
                                    path: "assest/images/NoIntrest.png",

                                    paddingBottom: 11,
                                    //   bordercolor: Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis"),
                              ],
                            ),
                          ),
                          SizedBox(height: 50),
                          CustomWigdet.RoundRaisedButton(
                              onPress: () async {
                                if(showLoading)
                                  return;

                                if (await UtilMethod.SimpleCheckInternetConnection(
                                    context, _scaffoldKey)) {
                                  job_hunting
                                      ? await _UpdateInterest("1")
                                      : job_placement
                                      ? await _UpdateInterest("2")
                                      : both
                                      ? await _UpdateInterest("3")
                                      : others
                                      ? await _UpdateInterest("4")
                                      : Navigator.pushNamed(
                                    context,
                                    Constant.ActivityRoute,
                                  );
                                }
                              },
                              text: showLoading ?  AppLocalizations.of(context)
                                  .translate("Please wait")
                                  .toUpperCase():AppLocalizations.of(context)
                                  .translate("Continue")
                                  .toUpperCase(),
                              textColor: Custom_color.WhiteColor,
                              bgcolor: Custom_color.BlueLightColor,
                              fontFamily: "OpenSans Bold"),

                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,

                      child: Stack(
                        children: [
                          Container(
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

                                CustomWigdet.FlatButtonSimple(

                                    onPress: () {
                                      Navigator.pushNamed(context, Constant.ActivityRoute);
                                    },

                                    text: AppLocalizations.of(context)
                                        .translate("skip")
                                        .toUpperCase(),
                                    textColor: Color(0xff1e63b0),
                                    fontFamily: "Kelvetica Nobis"),

                              ],
                            ),
                          ),
                          Positioned(
                            top: 5,
                            left: MediaQuery.of(context).size.width/2.7,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.ideographic,
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Color(0xfff7428f),
                                  child: Text("2",style: TextStyle(color: Colors.white,fontSize: 13),),
                                ),
                                SizedBox(width: 5),
                                Text(AppLocalizations.of(context).translate("of"),
                                  style: TextStyle(fontFamily: "Kelvetica Nobis",
                                      fontSize: 15,
                                      color: Custom_color.GreyTextColor
                                  ),),
                                SizedBox(width: 5),

                                Text("4",
                                  style: TextStyle(fontFamily: "Kelvetica Nobis",
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Custom_color.GreyTextColor
                                  ),)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          )]);
   }

  //================== New UI professional ==========
  Widget _widgetProfessionalNewUI(){
    return Column(
        children : [
          SizedBox(
            height: showLoading ? 2:0,
            child: LinearProgressIndicator(
              backgroundColor: Color(int.parse(Constant.progressBg)),
              valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse(Constant.progressVl)),),
              minHeight: 2,
            ),
          ),
          Expanded(
            child :

            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:AssetImage('assest/images/background_img.jpg'), //AssetImage("assest/images/hello.jpg"),
                  fit: BoxFit.cover,
                ),
              ),

              child: Visibility(
                visible: _visiblity,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: MQ_Height*0.09,
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: MQ_Width*0.01),

                                  width: MQ_Width*0.12,
                                  height: 2,
                                  color:false?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                    width: MQ_Width*0.12,
                                    height: 2,
                                    color:false?Color(0xfffb4592):Helper.tabLineColorGreyH1//Colors.purpleAccent,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                  width: MQ_Width*0.12,
                                  height: 2,
                                  color:false?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                  width: MQ_Width*0.12,
                                  height: 2,
                                  color:false?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
                                ),
                                Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                width: MQ_Width*0.12,
                                height: 2,
                                color:false?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                width: MQ_Width*0.12,
                                height: 4,
                                color:true?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.01),
                                width: MQ_Width*0.12,
                                height: 2,
                                color:false?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
                              )
                              ],
                            ),
                          ),

                          SizedBox(height: MQ_Height*0.08),
                          Padding(
                            padding: const EdgeInsets.only(left: 20,right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CustomWigdet.TextView(
                                     fontWeight: Helper.textFontH5,
                                    fontSize: Helper.textSizeH9,
                                    text: 'Purpose of Joining',//AppLocalizations.of(context).translate("Having professional interests in?"),
                                    fontFamily: "Kelvetica Nobis",
                                    color: Color(Helper.textColorBlackH1)//Color(0xff1e63b0)
                                ),
                                SizedBox(
                                  height: MQ_Height*0.06,
                                ),
                                job_hunting
                                    ? CustomWigdet.OvalShapedButtonBlue(
                                  onPress: () {
                                    onChangeUser("1");
                                  },
                                  text:allWordsCapitilize(AppLocalizations.of(context)
                                      .translate("Looking for job")
                                      .toUpperCase()),
                                  fontFamily: "Kelvetica Nobis",
                                  textColor: Custom_color.WhiteColor ,
                                  paddingTop: 11,
                                  paddingBottom: 11,
                                  path: "assest/images_svg/looking for job.svg",//"assest/images/job.png",
                                  bgcolor: Custom_color.BlueLightColor,
                                    fontWeight: Helper.textFontH5,
                                    fontSize: Helper.textSizeH14 )
                                    : CustomWigdet.OvalShapedButtonWhite(
                                    onPress: () {
                                      //  _UpdateInterest("1");
                                      onChangeUser("1");
                                    },
                                    path: "assest/images_svg/looking for job.svg",//"assest/images/job.png",

                                    text: allWordsCapitilize(AppLocalizations.of(context)
                                        .translate("Looking for job")),
                                    textColor: Custom_color.GreyTextColor,
                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    // bordercolor: Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis",
                                    fontWeight: Helper.textFontH5,
                                    fontSize: Helper.textSizeH14),
                                SizedBox(
                                  height: MQ_Height*0.03,
                                ),
                                others ? CustomWigdet.OvalShapedButtonBlue(
                                  onPress: () {
                                    onChangeUser("4");
                                  },
                                  text://allWordsCapitilize('Looking For Dating'), //
                                   AppLocalizations.of(context).translate("Looking For Dating"),
                                  path: "assest/images_svg/looking for dating.svg",//"assest/images/providingJob.png",

                                  fontFamily: "Kelvetica Nobis",
                                  textColor: Custom_color.WhiteColor,
                                  paddingTop: 11,
                                  paddingBottom: 11,
                                  bgcolor: Custom_color.BlueLightColor,
                                    fontWeight: Helper.textFontH5,
                                    fontSize: Helper.textSizeH14 )
                                    : CustomWigdet.OvalShapedButtonWhite(
                                    onPress: () {
                                      //   _UpdateInterest("2");
                                      onChangeUser("4");
                                    },
                                    path: "assest/images_svg/looking for dating.svg",//"assest/images/providingJob.png",

                                    text:// allWordsCapitilize('Looking For Dating'),
                                    AppLocalizations.of(context).translate("Looking For Dating"),
                                    textColor: Custom_color.GreyTextColor,
                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    // bordercolor: Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis",
                                    fontWeight: Helper.textFontH5,
                                    fontSize: Helper.textSizeH14),

                                //============== Remove check ============
                                /*
                                SizedBox(height: MQ_Height*0.02,
                                ),
                                others
                                    ? CustomWigdet.OvalShapedButtonBlue(
                                    onPress: () {
                                      onChangeUser("4");
                                    },
                                    path: "assest/images/NoIntrest.png",

                                    text: AppLocalizations.of(context)
                                        .translate("No professional interest")
                                        .toUpperCase(),
                                    paddingTop: 11,
                                    paddingBottom: 11,
                                    bgcolor: Custom_color.BlueLightColor,
                                    fontFamily: "Kelvetica Nobis",
                                    textColor: Custom_color.WhiteColor)
                                    : CustomWigdet.OvalShapedButtonWhite(
                                    onPress: () {
                                      //  _UpdateInterest("4");
                                      onChangeUser("4");
                                    },
                                    text: AppLocalizations.of(context)
                                        .translate("No professional interest")
                                        .toUpperCase(),
                                    textColor: Custom_color.GreyTextColor,
                                    paddingTop: 11,
                                    path: "assest/images/NoIntrest.png",

                                    paddingBottom: 11,
                                    //   bordercolor: Custom_color.GreyLightColor,
                                    fontFamily: "Kelvetica Nobis"),*/
                              ],
                            ),
                          ),
                          SizedBox(height: MQ_Height*0.08),
                          CustomWigdet.RoundRaisedButton(
                              onPress: () async {
                                if(job_hunting!=false ||job_placement!=false||both!=false||others!=false|| look_Dating!= false) {
                                  if (showLoading) return;

                                  if (await UtilMethod
                                      .SimpleCheckInternetConnection(
                                      context, _scaffoldKey)) {
                                    job_hunting
                                        ? await _UpdateInterest("1")
                                        : job_placement
                                        ? await _UpdateInterest("2")
                                        : both
                                        ? await _UpdateInterest("3")
                                        : others
                                        ? await _UpdateInterest("4")
                                        :  look_Dating
                                        ? await _UpdateInterest("5")
                                        : Navigator.pushNamed(
                                      context,
                                      Constant.ActivityRoute,
                                    );
                                  }
                                }else{
                                  // FlutterToastAlert.flutterToastMSG(AppLocalizations.of(context)
                                  //     .translate("Please select type"), context);
                                  UtilMethod.SnackBarMessage(
                                      _scaffoldKey,
                                      AppLocalizations.of(context)
                                          .translate("Please select type"));
                                }
                              },
                              text: showLoading ?  AppLocalizations.of(context)
                                  .translate("Please wait")
                                  .toUpperCase():AppLocalizations.of(context)
                                  .translate("Continue")
                                  .toUpperCase(),
                              fontSize:Helper.textSizeH12,
                              fontWeight:Helper.textFontH5,
                              textColor: Custom_color.WhiteColor,
                              bgcolor: Custom_color.BlueLightColor,
                              fontFamily: "OpenSans Bold"),

                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,

                      child: Stack(
                        children: [
                          Container(
                            /*decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color(0xffc6c6c8),
                                        width: 1
                                    )
                                )
                            ),*/
                            height: 60,
                            width: MQ_Width,
                            padding: EdgeInsets.only(bottom: 5,left: 10,right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
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
                                  ):
                                  Container(
                                    child: SvgPicture.asset('assest/images_svg/back.svg'),
                                  ),
                                ),

                               false? CustomWigdet.FlatButtonSimple(

                                    onPress: () {
                                      Navigator.pushNamed(context, Constant.ActivityRoute);
                                    },

                                    text: AppLocalizations.of(context)
                                        .translate("skip")
                                        .toUpperCase(),
                                    textColor: Color(0xff1e63b0),
                                    fontFamily: "Kelvetica Nobis",
                                   fontWeight: Helper.textFontH5,
                                fontSize: Helper.textSizeH12):Container()


                              ],
                            ),
                          ),
                         false? Positioned(
                            top: 5,
                            left: MediaQuery.of(context).size.width/2.7,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.ideographic,
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Color(0xfff7428f),
                                  child: Text("2",style: TextStyle(color: Colors.white,fontSize: 13),),
                                ),
                                SizedBox(width: 5),
                                Text(AppLocalizations.of(context).translate("of"),
                                  style: TextStyle(fontFamily: "Kelvetica Nobis",
                                      fontSize: 15,
                                      color: Custom_color.GreyTextColor
                                  ),),
                                SizedBox(width: 5),

                                Text("4",
                                  style: TextStyle(fontFamily: "Kelvetica Nobis",
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Custom_color.GreyTextColor
                                  ),)
                              ],
                            ),
                          ):Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          )]);
  }
  String allWordsCapitilize (String str) {
    return str.toLowerCase().split(' ').map((word) {
      String leftText = (word.length > 1) ? word.substring(1, word.length) : '';
      return word[0].toUpperCase() + leftText;
    }).join(' ');
  }
  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Center(
              child: CustomWigdet.FlatButtonSimple(
                  onPress: () {
                    Navigator.pushNamed(context, Constant.ActivityRoute);
                  },
                  text: AppLocalizations.of(context)
                      .translate("skip")
                      .toUpperCase(),
                  textColor: Custom_color.BlueLightColor,
                  fontFamily: "OpenSans Bold")),
        ),
      ],
      title: CustomWigdet.TextView(
          text: "2 ${AppLocalizations.of(context).translate("of")} 4",
          color: Custom_color.BlackTextColor,
          fontFamily: "OpenSans Bold"),
      bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Flexible(
                flex: 5,
                child: Container(
                  width: _screenSize.width,
                  height: 0.5,
                  color: Custom_color.GreyLightColor,
                ),
              ),
              Flexible(
                flex: 4,
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

  Future<https.Response> _GetProfesstion() async {
    try {
      print("------inside------");
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      String url = WebServices.GetProfessional +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      https.Response res = await https.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Cache-Control": "no-cache",
      });
      _hideProgress();
      print("respnse----" + res.body);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data["status"]) {
          var value = data["prof_interest"].toString();
          print("-----logging-----");
          onChangeUser(value);
        } else {
          _hideProgress();
          _visiblity = false;
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }else{
            String MSG='Data response  something went wrong.Please try again later';
             try{
               MSG=data["message"];
             }catch(error){
               print(error);
             }
            ShowDialogError.showDialogErrorMessage(context, "Response Error", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
          }
        }
      }
      else if (res.statusCode == 500) {
        print(res.statusCode);
        _hideProgress();
        var MSG = "Internal server error issue.Please try again later";
        ShowDialogError.showDialogErrorMessage(context, "Internal Error", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);

      }else if (res.statusCode == 400 || res.statusCode==422) {
        _hideProgress();
        var MSG = "Data request something went wrong.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Bad Request", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==401){
        _hideProgress();
        var MSG = "Access is denied due to invalid credentials .Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Unauthorized Error?", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==403){
        _hideProgress();
        var MSG = "You don't have permission to access/on this server .Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Forbidden Error?", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==404){
        _hideProgress();
        var  MSG = "The requested URL was not found on this server.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "URL Not Found", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else{
        _hideProgress();
        var MSG = "Data response type something went wrong.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Data Response", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
      _visiblity = false;
      ShowDialogError.showDialogErrorMessage(context, "Exception error", e.toString(), 0, 'error', MQ_Width, MQ_Height);
    }
  }

  onChangeUser(String value) {
    if (!UtilMethod.isStringNullOrBlank(value)) {
      print("-----getvalue----" + value.toString());
      if (value == "0") {
        setState(() {
          job_hunting = false;
          job_placement = false;
          both = false;
          others = false;
          look_Dating = false;

          _visiblity = true;
        });
      } else if (value == "1") {
        setState(() {
          job_hunting = true;
          job_placement = false;
          both = false;
          others = false;
          look_Dating = false;

          _visiblity = true;
        });
      } else if (value == "2") {
        setState(() {
          job_hunting = false;
          job_placement = true;
          both = false;
          others = false;
          look_Dating = false;

          _visiblity = true;
        });
      } else if (value == "3") {
        setState(() {
          job_hunting = false;
          job_placement = false;
          both = true;
          others = false;
          look_Dating = false;
          _visiblity = true;
        });
      } else if (value == "4") {
        setState(() {
          job_hunting = false;
          job_placement = false;
          both = false;
          others = true;
          look_Dating = false;
          _visiblity = true;
        });
      }
      else if (value == "5") {
        setState(() {
          job_hunting = false;
          job_placement = false;
          both = false;
          others = false;
          look_Dating = true;
          _visiblity = true;
        });
      }

    }
  }

  Future<https.Response> _UpdateInterest(String name) async {
    try {
      print("------inside------" + name.toString());
      Future.delayed(Duration.zero, () {
        _showProgress(context);
      });
      Map jsondata = {"prof_interest": name};
      String url = WebServices.UpdateProfessional +
          SessionManager.getString(Constant.Token)+ "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var res= await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + res.body);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data["status"]) {
          print("-----logging-----");
          Navigator.pushNamed(context, Constant.ActivityRoute,
          );
        } else {
          _hideProgress();
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }
          else{
            String MSG='Data response  something went wrong.Please try again later';
            try{
              MSG=data["message"];
            }catch(error){
              print(error);
            }
            ShowDialogError.showDialogErrorMessage(context, "Response Error", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
          }
        }
      }
      else if (res.statusCode == 500) {
        print(res.statusCode);
        _hideProgress();
        var MSG = "Internal server error issue.Please try again later";
        ShowDialogError.showDialogErrorMessage(context, "Internal Error", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);

      }else if (res.statusCode == 400 || res.statusCode==422) {
        _hideProgress();
        var MSG = "Data request something went wrong.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Bad Request", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==401){
        _hideProgress();
        var MSG = "Access is denied due to invalid credentials .Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Unauthorized Error?", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==403){
        _hideProgress();
        var MSG = "You don't have permission to access/on this server .Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Forbidden Error?", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else if(res.statusCode==404){
        _hideProgress();
        var  MSG = "The requested URL was not found on this server.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "URL Not Found", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }else{
        _hideProgress();
        var MSG = "Data response type something went wrong.Please try again later !";
        ShowDialogError.showDialogErrorMessage(context, "Data Response", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
      ShowDialogError.showDialogErrorMessage(context, "Exception error", e.toString(), 0, 'error', MQ_Width, MQ_Height);
    }
  }

  _showProgress(BuildContext context) {
    setState(() {
      showLoading = true;
    });
    List<Color> _kDefaultRainbowColors = const [
      Colors.blue,
      Colors.blue,
      Colors.blue,
      Colors.pinkAccent,
      Colors.pink,
      Colors.pink,
      Colors.pinkAccent,

    ];

    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: true,
    );
    progressDialog.style(
        backgroundColor: Colors.transparent,

        elevation: 0,
        message: '',

        progressWidgetAlignment: Alignment.center,
        padding: EdgeInsets.only(left: MQ_Width*0.30,right: MQ_Width*0.20),
        child: Center(
          child: Container(
            alignment: Alignment.center,
            width: 120,
            height: 120,
            child: LoadingIndicator(
              indicatorType: Indicator.lineScalePulseOut,
              colors: _kDefaultRainbowColors,
              strokeWidth: 2.0,
              pathBackgroundColor:Colors.black45,
              // showPathBackground ? Colors.black45 : null,
            ),
          ),
        )
    );



    progressDialog.show();
  }

  _hideProgress() {
    setState(() {
      showLoading = false;
      if (progressDialog != null) {
        progressDialog.hide();
      }
    });
  }
}
