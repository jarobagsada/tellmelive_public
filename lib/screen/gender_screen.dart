import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../utilmethod/helper.dart';

class GenderScreen extends StatefulWidget {
  @override
  _GenderScreenState createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  Size _screenSize;
  bool select_gender_men = false;
  var routeData;
  bool showLoading;
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var MQ_Height;
  var MQ_Width;

  @override
  void initState() {
    showLoading = false;
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero,(){
     // routeData = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      if(routeData["gender_id"]!=null && routeData["gender_id"]==1)
      {
        setState(() {
          select_gender_men = false;
        });


      }else {
        setState(() {
          select_gender_men = true;
        });
      }
    });

  }


  @override
  Widget build(BuildContext context) {
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    _screenSize = MediaQuery.of(context).size;
    routeData = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    print("----routeData---"+routeData.toString());

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Helper.inBackgroundColor,
      body:Stack(
        children: [
         // _widgetUserGenderUI()
          _widgetUserGenderNewUI()
        ],
      )
    );
  }

  //============= Old UI =====
  Widget _widgetUserGenderUI(){
    return  Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assest/images/hello.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      width: _screenSize.width,
      child:  Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(



                children: <Widget>[
                  SizedBox(height: 25),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [

                      Positioned(
                          top:100,

                          child: _CircleImageforshadow()),
                      Image(
                        fit: BoxFit.fill,
                        image: AssetImage("assest/images/bg_img.jpg"),
                      ),


                      Positioned(
                        top: 10,
                        left: 10,
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

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
                      ),


                      Positioned(
                        top: 50,
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("You are"),
                          style: TextStyle(
                              fontFamily: "Kelvetica Nobis",
                              fontSize: 20,
                              color: Colors.white
                          ),
                        ),
                      ),
                      Positioned(
                          top:100,

                          child: _CircleImage()),
                    ],

                  ),
                  // CustomWigdet.TextView(
                  //     text: AppLocalizations.of(context).translate("You are"),
                  //     fontSize: 14.0,
                  //     textAlign: TextAlign.center,
                  //     color: Custom_color.BlackTextColor,
                  //     fontFamily: "OpenSans Bold"),
                  SizedBox(
                    height: 100,
                  ),

                  CustomeSlider(),
                  SizedBox(height: 70),
                  CustomWigdet.RoundRaisedButton(
                      onPress: () {
                        if(showLoading)
                          return;
                        OnSubmit();
                      },
                      text: showLoading ? AppLocalizations.of(context)
                          .translate("Please wait")
                          .toUpperCase() :  AppLocalizations.of(context)
                          .translate("Continue")
                          .toUpperCase(),
                      textColor: Custom_color.WhiteColor,
                      bgcolor: select_gender_men? Custom_color.BlueLightColor:Custom_color.PinkColor,
                      fontFamily: "OpenSans Bold"),

                ],
              ),
            ),

            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  //============= New UI =====
  Widget _widgetUserGenderNewUI(){
    return  Container(
      /*decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assest/images/hello.jpg"),
          fit: BoxFit.cover,
        ),
      ),*/
      width: _screenSize.width,
      child:  Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  SizedBox(height: MQ_Height*0.02),
                 false? Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [

                      Positioned(
                          top:100,
                          child: _CircleImageforshadow()),
                      Image(
                        fit: BoxFit.fill,
                        image: AssetImage("assest/images/bg_img.jpg"),
                      ),


                      Positioned(
                        top: 10,
                        left: 10,
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

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
                      ),


                      Positioned(
                        top: 50,
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("You are"),
                          style: TextStyle(
                              fontFamily: "Kelvetica Nobis",
                              fontSize: 20,
                              color: Colors.white
                          ),
                        ),
                      ),
                      Positioned(
                          top:100,

                          child: _CircleImage()),
                    ],

                  ):Container(),
                  // CustomWigdet.TextView(
                  //     text: AppLocalizations.of(context).translate("You are"),
                  //     fontSize: 14.0,
                  //     textAlign: TextAlign.center,
                  //     color: Custom_color.BlackTextColor,
                  //     fontFamily: "OpenSans Bold"),
                  SizedBox(
                    height: MQ_Height*0.04,
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.pop(context,0);
                    },
                    child:  Container(
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
                        padding: const EdgeInsets.only(left: 10.0,top: 0,right: 20),
                        child:  Container(
                          child: SvgPicture.asset('assest/images_svg/back.svg',color: Custom_color.BlueLightColor,width: 18,height: 18,),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MQ_Height*0.03,
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
                            height: 4,
                            color:true?Color(0xfffb4592):Helper.tabLineColorGreyH1//Colors.purpleAccent,
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
                          height: 2,
                          color:false?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
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
                  Container(
                    margin: EdgeInsets.only(left: MQ_Width*0.06,top: MQ_Height*0.05),

                    alignment: Alignment.center,
                    child: Text('You are',
                      style: TextStyle(color:Color(Helper.textColorBlackH2),
                          fontFamily: "Kelvetica Nobis",
                          fontWeight: Helper.textFontH3,fontSize: Helper.textSizeH2),),
                  ),
                  SizedBox(
                    height: MQ_Height*0.05,
                  ),
                 // Positioned(
                    Container(
                        //top:100,
                      margin: EdgeInsets.only(top: MQ_Height*0.05),
                      child: _CircleImageforshadow()),
                  SizedBox(
                    height: MQ_Height*0.05,
                  ),
                  CustomeSlider(),

                  SizedBox(height: MQ_Height*0.08),
                  CustomWigdet.RoundRaisedButton(
                      onPress: () {
                        if(showLoading)
                          return;
                        OnSubmit();
                      },
                      text: showLoading ? AppLocalizations.of(context)
                          .translate("Please wait")
                          .toUpperCase() :  AppLocalizations.of(context)
                          .translate("Continue")
                          .toUpperCase(),
                      fontSize: Helper.textSizeH12,
                      fontWeight: Helper.textFontH4,
                      textColor: Custom_color.WhiteColor,
                      bgcolor: select_gender_men? Custom_color.BlueLightColor:Custom_color.PinkColor,
                      fontFamily: "OpenSans Bold"),

                ],
              ),
            ),

            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      bottom: PreferredSize(
          child: routeData["gender_id"] == null
              ? Row(
                  children: <Widget>[
                    Flexible(
                      flex: 5,
                      child: Container(
                          width: _screenSize.width,
                          height: 1,
                          color: Custom_color.BlueLightColor),
                    ),
                    Flexible(
                      flex: 9,
                      child: Container(
                        width: _screenSize.width,
                        height: 0.5,
                        color: Custom_color.GreyLightColor,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Expanded(
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

  Widget _CircleImage() {
    return Container(

      width: 150.0,
      height: 150.0,
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(35),
        child: Container(
            //color: Custom_color.BlueLightColor,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: select_gender_men
                    ? Color(0xff24bbf4)
                    : Color(0xfff84390),
                border: Border.all(color: Colors.transparent, width: 5.0)),
            child: CircleAvatar(
              backgroundColor: select_gender_men
                  ? Color(0xff24bbf4)
                  : Color(0xfff84390),
              backgroundImage: select_gender_men
                  ? AssetImage('assest/images/man_thumb.png')
                  : AssetImage('assest/images/woman_thumb.png'),
            )),
      ),
    );
  }

  Widget _CircleImageforshadow() {
    return Container(
     /* decoration: BoxDecoration(
        shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Color(0xffacacac),
                offset: Offset(1,6),
                blurRadius: 30
            )
          ]
      ),*/
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,

            colors: [
              // Color(0XFF8134AF),
              // Color(0XFFDD2A7B),
              // Color(0XFFFEDA77),
              // Color(0XFFF58529),
              Colors.blue.withOpacity(0.2),
              Colors.blue.withOpacity(0.2),

            ],
          ),
          shape: BoxShape.circle
      ),
      width: 200.0,
      height: 200.0,
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(35),
        child: Container(
          //color: Custom_color.BlueLightColor,
          margin: EdgeInsets.all(15),

            /*decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: select_gender_men
                    ? Color(0xff24bbf4)
                    : Color(0xfff84390),
                border: Border.all(color: Colors.transparent, width: 5.0)),*/
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Color(0xffaeaeae),
                      offset: Offset(1,10),
                      blurRadius: 20
                  )
                ]
            ),
            child: false?CircleAvatar(
              backgroundColor: select_gender_men
                  ? Colors.blue.shade600//Color(0xff24bbf4)
                  : Color(0xfff84390),
              backgroundImage: select_gender_men
                  ? AssetImage('assest/images/men_img.png')
                  : AssetImage('assest/images/women_img.png'),
            ):
            CircleAvatar(
              backgroundImage: select_gender_men
                  ? AssetImage('assest/images/men_circle_img.png')
                  : AssetImage('assest/images/women_circle_img.png'),
            )),
      ),
    );
  }

//  Widget _CircleImage() {
//    return Container(
//      width: 150.0,
//      height: 150.0,
//      child: CircleAvatar(
//        backgroundImage: AssetImage('assest/images/user.png'),
//      )
//    );
//  }

  Widget CustomeSlider() {
    return GestureDetector(
      onTap: Selection,
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [

            /*BoxShadow(
              color: Color(0xffd1d5e0),
              offset: Offset(0,6),
              blurRadius: 30
            )*/
          ],
          borderRadius: BorderRadius.circular(30.0),

        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Container(

                decoration: BoxDecoration(
                  gradient: select_gender_men?
                  LinearGradient(colors: [Color(0xff1c61ae),Color(0xff31bdf0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight
                  ):
                  LinearGradient(colors: [Color(0xffffffff),Color(0xffffffff)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight
                  ),
                    borderRadius: BorderRadius.circular(30.0),
                    ),
                child: Center(
                    child: CustomWigdet.TextView(
                        text: AppLocalizations.of(context).translate("Man").toUpperCase(),
                        color: select_gender_men
                            ? Custom_color.WhiteColor
                            : Custom_color.GreyLightColor,
                        fontWeight: Helper.textFontH2,
                        fontSize: Helper.textSizeH12,
                        fontFamily: "Kelvetica Nobis")),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    gradient: !select_gender_men?
                    LinearGradient(colors: [Color(0xfff84390),Color(0xfffd8fbe)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight
                    ):
                    LinearGradient(colors: [Color(0xffffffff),Color(0xffffffff)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                    ),
                child: Center(
                    child: CustomWigdet.TextView(
                        text: AppLocalizations.of(context).translate("Woman").toUpperCase(),
                        color: !select_gender_men
                            ? Custom_color.WhiteColor
                            : Custom_color.GreyLightColor,
                        fontWeight: Helper.textFontH2,
                        fontSize: Helper.textSizeH12,
                        fontFamily: "OpenSans Bold")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void Selection() {
    print("------selection-----");
    setState(() {
      if (select_gender_men != null) select_gender_men = !select_gender_men;
      print("------selemant-----" + select_gender_men.toString());
    });
  }

  OnSubmit() {
    routeData["gender_id"] == null
        ?
        //===============  Old Switch page ==============
    /* Navigator.pushNamed(context, Constant.ProfileScreen, arguments: {
            "access": routeData["access"],
            "countryCode": routeData["countryCode"],
            "mobile_no": routeData["mobile_no"],
            "firstname": routeData["firstname"],
            "email": routeData["email"],
            "dob": routeData["dob"],
            "gender": select_gender_men ? Constant.Men : Constant.Women,
            "device_id": routeData["device_id"],
            "device_type": routeData["device_type"],
            "facbook_id": routeData["facbook_id"],
          }
          )*/
    //===============  New Switch page ==============

    Navigator.pushNamed(context,
      // Constant.UserAboutMeScreen
        Constant.ProfileScreen,

        arguments: {
      "access": routeData["access"],
      "countryCode": routeData["countryCode"],
      "mobile_no": routeData["mobile_no"],
      "firstname": routeData["firstname"],
      "email": routeData["email"],
      "dob": routeData["dob"],
      "gender": select_gender_men ? Constant.Men : Constant.Women,
      "device_id": routeData["device_id"],
      "device_type": routeData["device_type"],
      "facbook_id": routeData["facbook_id"],
    }
    )

        : _UpdateGender();
  }

  Future<https.Response> _UpdateGender() async {
    try {
      _showProgress(context);
      Map jsondata = {
        "gender": select_gender_men ? Constant.Men : Constant.Women
      };
      String url = WebServices.GetUpdateGender +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"]);
            Navigator.pop(context,true);
        } else {
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }
        }
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
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
