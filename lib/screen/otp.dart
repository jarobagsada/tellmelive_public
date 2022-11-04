import 'dart:async';
import 'dart:convert';

import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/fluttertoast_alert.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;
import 'package:miumiu/utilmethod/helper.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:location/location.dart' as locat;

import '../utilmethod/showDialog_Error.dart';

//import 'package:alt_sms_autofill/alt_sms_autofill.dart';

// class Opt_Screen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return NeumorphicTheme(
//       theme: NeumorphicThemeData(
//           defaultTextColor: Color(0xFF303E57),
//           accentColor: Color(0xFF7B79FC),
//           variantColor: Colors.black38,
//           baseColor: Color(0xFFF8F9FC),
//           depth: 8,
//           intensity: 0.5,
//           lightSource: LightSource.bottomRight),
//       themeMode: ThemeMode.light,
//       child: Material(
//         child: NeumorphicBackground(
//           child: OptDemo_Screen(),
//         ),
//       ),
//     );
//   }
// }

class Opt_Screen extends StatefulWidget {
  @override
  _Opt_ScreenState createState() => _Opt_ScreenState();
}

class _Opt_ScreenState extends State<Opt_Screen> {
  Size _screenSize;
  int _currentDigit;
  int _firstDigit;
  int _secondDigit;
  int _thirdDigit;
  int _fourthDigit;
  ProgressDialog progressDialog;
  var routeData;
  TextEditingController _pinController=new TextEditingController();

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Timer _timer;
  final interval = const Duration(seconds: 1);

  int timerMaxSeconds = 59;

  int currentSeconds = 0;
  bool showLoading;
  var MQ_Width;
  var MQ_Height;
  locat.LocationData _currentLocation;
  String isocountry;
  locat.Location location = new locat.Location();


  @override
  void initState() {
    startTimer();
    showLoading = false;
    _currentLocation = Constant.currentLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        GetCurentLocation();
      }
    });
   initSmsListener();
    super.initState();
  }

  GetCurentLocation() async {

    print("------1111-------");

    //await location.getLocation();

    try
    {
      print("------22222------- "+_currentLocation.latitude.toString()+" --0 "+Constant.currentLocation.latitude.toString());
      List<Placemark> placemark = await placemarkFromCoordinates(_currentLocation.latitude, _currentLocation.longitude);
      Placemark placeMark = placemark[0];
      print("countrycode :: "+placeMark.isoCountryCode.toLowerCase());
      isocountry = placeMark.isoCountryCode;
      setState(() {});
    }
    catch (error) {
    }
    // List<Placemark> newPlace = await GeocodingPlatform.instance.placemarkFromCoordinates(_currentLocation.latitude, _currentLocation.longitude,localeIdentifier: "en");
    print("------3333-------");




//    String name = placeMark.name;
//    String subLocality = placeMark.subLocality;
//    String locality = placeMark.locality;
//    String administrativeArea = placeMark.administrativeArea;
//    String postalCode = placeMark.postalCode;
//    String country = placeMark.country;


//    String address =
//        "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country},${isocountry}";
//
//    print("----placemark------" + address.toString());

  }

  String _commingSms = 'Unknown';

  Future<void> initSmsListener() async {

    String commingSms;
    try {
      commingSms = await AltSmsAutofill().listenForSms;
    } on PlatformException {
      commingSms = 'Failed to get Sms.';
    }
    if (!mounted) return;

    setState(() {
      _commingSms = commingSms;
      String aStrMSG = _commingSms.replaceAll(new RegExp(r'[^a-zA-Z]'),' ');
      String aStrOTP = _commingSms.replaceAll(new RegExp(r'[^0-9]'),'');
    //  print('initSmsListener aStrOTP=$aStrOTP');
      String otp;
      if(aStrOTP.length>3) {
       // print('initSmsListener ## == aStrOTP=$aStrOTP');
        otp = aStrOTP.substring(0, 4);

        // print('_commingSms ##=$_commingSms');
        // print('_commingSms ##  aStrMSG=$aStrMSG');
        // print("====>Message: ${_commingSms}");
        if (aStrMSG.toString().trim() == AppLocalizations.of(context)
            .translate("Your TellMeLive OTP is")
            .trim()) {
          _pinController.text = otp;
        }
        // print("${_commingSms[32]}");
        //   _pinController.text = _commingSms[32] + _commingSms[33] + _commingSms[34] + _commingSms[35]
        //
        //     + _commingSms[36] + _commingSms[37]; //used to set the code in the message to a string and setting it to a textcontroller. message length is 38. so my code is in string index 32-37.
      }
    });

  }

  @override
  void dispose() {

    AltSmsAutofill().unregisterListener();

    _timer.cancel();
    super.dispose();

  }


  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    MQ_Width= MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;

    routeData = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;


    return Scaffold(
        backgroundColor:Colors.transparent,
        key: _scaffoldKey,
        appBar: _getAppbar,
        body:Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assest/images/background_img.jpg"),//AssetImage("assest/images/hello.jpg"),
                  fit: BoxFit.fill,
                ),
              ),),

           //_widgetOTPUI()
            _widgetNewUIOTP()
          ],
        ));
  }


  //============ Old UI OTP =======

  Widget _widgetOTPUI(){
    return  Column(
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
              width: _screenSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CustomWigdet.TextView(
                              overflow: true,
                              text: AppLocalizations.of(context)
                                  .translate("Did you get your code"),
                              fontSize: 14.0,
                              textAlign: TextAlign.center,
                              color: Custom_color.BlackTextColor,
                              fontFamily: "OpenSans Bold"),
                          SizedBox(
                            height: 10,
                          ),
                          _getInputField,
                          SizedBox(
                            height: 10,
                          ),
                          CustomWigdet.TextView(
                              text:
                              "${AppLocalizations.of(context).translate("Have you still not received")} ${routeData["mobile_no"].toString()}.",
                              fontSize: 12,
                              overflow: true,
                              color: Custom_color.GreyLightColor,
                              fontFamily: "OpenSans Bold",
                              textAlign: TextAlign.center),
                          SizedBox(
                            height: 10,
                          ),
                          currentSeconds == timerMaxSeconds
                              ? CustomWigdet.RoundOutlineFlatButtonWrapContant(
                              onPress: () {},
                              text: AppLocalizations.of(context)
                                  .translate("Get OTP"),
                              fontFamily: "OpenSans Bold",
                              textColor: Custom_color.BlueLightColor,
                              bordercolor: Custom_color.BlueLightColor)
                              : CustomWigdet.TextView(
                              text:
                              "${AppLocalizations.of(context).translate("Resend OTP in")} ${timerText.toString()}",
                              color: Custom_color.BlackTextColor,
                              fontSize: 14,
                              fontFamily: "OpenSans Bold")
                        ],
                      ),
                    ),
                  ),
                  _getOtpKeyboard
                ],
              ),
            ),
          ),]);
  }

  //=========== New UI OTP ==========

  Widget _widgetNewUIOTP(){
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
          color:Colors.transparent, //Color(Helper.inBackgroundColor)
        /* gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.white, Colors.white])*/
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Stack(
          children: [

            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  /*Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                padding:
                                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                width: size.width * 0.8,
                                child: Image.asset('assets/Login.jpg')),*/
                  Container(
                    /*margin: EdgeInsets.symmetric(vertical: 10),
                  padding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 5),*/
                    child:
                   false? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       // checkVerifyOTP!=
                            true? Container(
                              alignment: Alignment.center,
                            margin: EdgeInsets.only(left: 5),
                            // margin: EdgeInsets.symmetric(vertical: 10),
                            // padding:
                            // EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            width: MQ_Width * 0.2,
                            child:false?Image.asset('assets/images/logo.png')
                            :Image(image: AssetImage("assest/images/logo.png"),
                                width: 80,
                                height: 80)):
                        InkWell(
                          child: Container(
                              margin: EdgeInsets.only(left: 5),
                              // margin: EdgeInsets.symmetric(vertical: 10),
                              // padding:
                              // EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              width: MQ_Width * 0.2,
                              child:  Image.asset('assets/imageNew/back_button.png')),
                          onTap: ()async{
                           /* setState(() {
                              print('checkVerifyOTP icon=$checkVerifyOTP');
                              print('CheckNewPassword icon=$CheckNewPassword');
                              if(checkVerifyOTP==true){
                                checkVerifyOTP=false;
                                CheckNewPassword=false;
                              }else if(CheckNewPassword==true){
                                checkVerifyOTP=true;
                                CheckNewPassword=false;
                              }else{
                                checkVerifyOTP=true;
                                CheckNewPassword=false;

                              }
                              print(_pinController.text);
                              _pinController.clear();
                            });*/
                          },
                        ),

                        Container(
                          child:  Text("tellme",
                            style: TextStyle(
                                fontWeight: Helper.textFontH4,
                                color:Custom_color.BlueLightColor,// Color(Helper.textColorBlackH1),
                                fontSize: Helper.textSizeH5),
                          ),
                        ),
                        Container(
                          child:  Text("live",
                            style: TextStyle(
                                fontWeight: Helper.textFontH4,
                                color: Custom_color.PinkColor,//Color(Helper.textColorBlackH1),
                                fontSize: Helper.textSizeH5),
                          ),
                        ),
                        false?Container(
                          // margin: EdgeInsets.symmetric(vertical: 10),
                          // padding:
                          // EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            width: MQ_Width * 0.2,
                            child: Image.asset('assets/spinlogo.png')):Container()
                      ],
                    ): Container(
                     margin:  EdgeInsets.only(left:MQ_Width *0.08,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: 0),

                     alignment: Alignment.centerLeft,
                      //width: 200,
                      height: 60,
                      child: Image(
                        alignment: Alignment.centerLeft,
                        image: AssetImage("assest/images/tellme.png"),
                      ),
                    ),


                  ),
                  SizedBox(
                    height:MQ_Height * 0.04,
                  ),

                  Container(
                 //   margin:  EdgeInsets.only(left:MQ_Width *0.06,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: 0),
                    margin:  EdgeInsets.only(left:MQ_Height * 0.05,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: 0),
                    padding:  EdgeInsets.only(left: 5,right: 5,top: 0,bottom: 0),

                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /* Icon(
                                    Icons.login,
                                    size: 50,
                                    color: kPrimaryColor,
                                  ),*/
                        Text(AppLocalizations.of(context).translate("OTP Verification"),
                          style: TextStyle(
                              fontWeight: Helper.textFontH2,
                              color: Color(Helper.textColorBlackH1),
                              fontSize: Helper.textSizeH5),
                        ),
                      ],
                    ),

                  ),
            Container(
              alignment: Alignment.centerLeft,
                    margin:  EdgeInsets.only(left:MQ_Height * 0.05,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: 0),
                    padding:  EdgeInsets.only(left: 5,right: 5,top: 0,bottom: 0),

                    child: Text(AppLocalizations.of(context).translate("Enter the OTP sent to"),
                      style: TextStyle(color: Color(Helper.textHintColorH3),
                          fontWeight:Helper.textFontH4,fontSize: Helper.textSizeH12),
                      textAlign: TextAlign.start,),
                  ),




                  //checkVerifyOTP==
                      true ? Column(children: [
                    SizedBox(
                      height: MQ_Height*0.03,
                    ),



                    Container(
                      margin: EdgeInsets.only(left: MQ_Width*0.02,
                          right: MQ_Width*0.02,
                          top: MQ_Height*0.05,bottom:MQ_Height*0.02),
                      child:Padding(
                          padding:  EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 30),

                          child:
                         true? PinCodeTextField(
                            autofocus: true,
                            controller: _pinController,
                            // hideCharacter: true,
                          // inputFormatters: [FilteringTextInputFormatter.allow(new RegExp('[1234567890]'))],
                            highlight: false,
                            highlightColor: Custom_color.BlueLightColor,//Color(Helper.textHintColorH3).withOpacity(0.5),
                            defaultBorderColor: Colors.grey,//Color(Helper.otpBgTextColor).withOpacity(0.5),
                            hasTextBorderColor:Custom_color.BlueLightColor,//Colors.grey,//Color(Helper.otpBgTextColor).withOpacity(0.5),
                            highlightPinBoxColor:Custom_color.BlueLightColor,//Color(Helper.textHintColorH3).withOpacity(0.5),
                             pinBoxWidth: MQ_Width*0.15,
                            // pinBoxHeight: 44,

                            hasUnderline: false,
                            wrapAlignment: WrapAlignment.spaceAround,
                            pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,

                           // pinBoxOuterPadding:const EdgeInsets.fromLTRB(1, 1, 1, 10) ,
                            pinTextStyle:  TextStyle(color:Color(Helper.textHintColorH3),fontWeight: Helper.textFontH6,fontSize:Helper.textSizeH2,height: 1.6),
                            pinTextAnimatedSwitcherTransition:
                            ProvidedPinBoxTextAnimation.scalingTransition,
                            pinBoxColor:Custom_color.BlueLightColor,//Colors.black12,
                            //Color(Helper.otpBgTextColor).withOpacity(0.5),
                            pinTextAnimatedSwitcherDuration:
                            Duration(milliseconds: 300),
//                    highlightAnimation: true,
                            highlightAnimationBeginColor: Color(Helper.uiTextColor),
                            highlightAnimationEndColor: Custom_color.BlueLightColor,//Color(Helper.textHintColorH3).withOpacity(0.5),
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                         ):


                          PinInputTextField(
                            pinLength: 4,
                            inputFormatters: [FilteringTextInputFormatter.allow(new RegExp('[1234567890]'))],
                              controller:_pinController,
                            decoration:  UnderlineDecoration(
                              hintTextStyle: TextStyle(color:Color(Helper.textHintColorH3),fontWeight: Helper.textFontH6,fontSize:Helper.textSizeH2),//Color(Helper.textHintColorH2) ),
                              textStyle: TextStyle(color:Color(Helper.textHintColorH3),fontWeight: Helper.textFontH6,fontSize:Helper.textSizeH2,height: 1.6),
                              //
                              lineHeight: 1.9,
                              colorBuilder: /*_counter==0?*/
                              PinListenColorBuilder(
                                 // Color(Helper.textHeaderColorH1),
                                  Custom_color.BlueLightColor,
                                  Color(Helper.textBorderLineColorH1)

                              )
                              /*:PinListenColorBuilder(Color(Helper.textHintColorH2), Color(Helper.textHintColorH2))*/,
                              // activeFillColor: Color(Helper.inBackgroundColor),
                              //     disabledColor:Color(Helper.inBackgroundColor),
                              //     inactiveColor: Color(Helper.textBorderLineColorH1),
                              //     inactiveFillColor: Color(Helper.textBorderLineColorH1),
                              //     activeColor:Color(Helper.textBorderLineColorH1),//active
                              //     selectedFillColor:Color(Helper.textColorBlackH1),
                              //     selectedColor: Color(Helper.textHeaderColorH1),

                              bgColorBuilder: null,
                              obscureStyle: ObscureStyle(
                                isTextObscure: false,
                              ),
                            ),
                          //  controller: _pinController,

                            textInputAction: TextInputAction.go,
                            enabled: true,
                            keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
                            textCapitalization: TextCapitalization.characters,
                            onSubmit: (pin) {
                              debugPrint('submit pin:$pin');
                            },
                            onChanged: (pin) {
                              debugPrint('onChanged execute. pin:$pin');
                            },
                            enableInteractiveSelection: false,
                            cursor: Cursor(
                              height: 30,
                              width: 2,
                             // color: /*_counter==0?*/Color(Helper.textHeaderColorH1)/*:Color(Helper.textHintColorH2)*/,
                              color: Custom_color.BlueLightColor,
                              radius: Radius.circular(10),
                              enabled: true,
                            ),

                          )
                      ),

                    ),

                    SizedBox(
                      height: MQ_Height*0.02,
                    ),
                    // checkVerifyOTP==true?
                   // checkVerifyOTP==
                        currentSeconds == timerMaxSeconds ?
                    Container(
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.04,right: MediaQuery.of(context).size.width*0.01),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                         // _counter==0
                            true  ?InkWell(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              margin:  EdgeInsets.only(left:MQ_Height * 0.05,right: MQ_Width * 0.06,top: 0,bottom: 0),
                              padding:  EdgeInsets.only(left: 5,right: 5,top: 0,bottom: 0),
                              //  margin: EdgeInsets.only(right:MediaQuery.of(context).size.width*0.02),
                              child: Text(AppLocalizations.of(context).translate("Resend OTP"),
                                style: TextStyle(color: Custom_color.RedColor,fontWeight:Helper.textFontH4,fontSize: Helper.textSizeH13),
                                textAlign: TextAlign.center,),
                            ),
                            onTap: ()async{
                             /* NetworkCheck.check().then((intenet) {
                                if (intenet != null && intenet) {
                                  // Internet Present Case
                                  // verifyPhone("show");
                                  DateTime now = new DateTime.now();
                                  String CurrentDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
                                  if(editText_MobileNo.text.isEmpty){
                                    FlutterToastAlert.flutterToastMSG('Please enter the register mobile number ', context);
                                  }else if (PhNumberLength!=editText_MobileNo.text.length){
                                    FlutterToastAlert.flutterToastMSG('Please enter  $PhNumberLength register mobile number', context);
                                  }else {
                                    String Url_Requestotp = Helper.Exicom_Url +'getotpNew';
                                    var requestBody = json.encode({
                                      "email":"",
                                      "id":"",
                                      "mobile":editText_MobileNo.text,
                                      "otp_purpose":"FORGOT_PASSWORD",
                                      "username":""
                                    });
                                    PostRequestOTPUser(Url_Requestotp, requestBody);
                                  }

                                } else {
                                  String Message="Please Check Internet Connection !";

                                  NetworkAlert.networkCheckAlert(Message, "0", context);

                                }
                              });*/

                              _GetLoginPhone(routeData["mobile_no"]);

                            },
                          ):Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02,right: MediaQuery.of(context).size.width*0.01),

                            child: Text("Send new code in",
                              style: TextStyle(color: Color(Helper.textHintColorH3),fontWeight:Helper.textFontH6,fontSize: Helper.textSizeH14),
                              textAlign: TextAlign.center,),
                          ),

                          // checkVerifyOTP==true?
                         // _counter!=0?

                        ],
                      ),
                    ):Container(
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.04,right: MediaQuery.of(context).size.width*0.01),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              // _counter==0
                             Container(
                               alignment: Alignment.centerLeft,
                               margin:  EdgeInsets.only(left:MQ_Height * 0.05,right: MQ_Width * 0.06,top: 0,bottom: 0),
                               padding:  EdgeInsets.only(left: 5,right: 5,top: 0,bottom: 0),
                               //  margin: EdgeInsets.only(right:MediaQuery.of(context).size.width*0.02),
                               child: Text(AppLocalizations.of(context).translate("Resend OTP in"),
                                 style: TextStyle(color: Color(Helper.textColorBlackH1),fontWeight:Helper.textFontH5,fontSize: Helper.textSizeH13),
                                 textAlign: TextAlign.center,),
                             ),

                              // checkVerifyOTP==true?
                              // _counter!=0?
                              Container(
                                //margin: EdgeInsets.all(15),
                                alignment: Alignment.center,
                                child: Text('${timerText.toString()}',
                                  style: TextStyle(color: Custom_color.RedColor,fontWeight:Helper.textFontH3,fontSize: Helper.textSizeH13),
                                ),
                              ),
                            ],
                          ),
                        ),

                  ]):Container(),





                  SizedBox(height: MQ_Height * 0.05),

                  //isLoading ==false?

                 Container(
                    margin:  EdgeInsets.only(left:MQ_Width *0.06,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: 0),
                    height: 60,
                    width: MQ_Width*0.80,
                    decoration: BoxDecoration(
                      color: Color(Helper.ButtonBorderColor),
                      border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FlatButton(
                      onPressed: ()async{
                       /* NetworkCheck.check().then((intenet) {
                          if (intenet != null && intenet) {
                            // Internet Present Case
                            // verifyPhone("show");
                            DateTime now = new DateTime.now();
                            String CurrentDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

                            if(_pinController.text.isEmpty){
                              FlutterToastAlert.flutterToastMSG('Please enter the valid code sent your register mobile number ', context);
                            }else {
                              String Url_otpVerify = Helper.Exicom_Url +'verifyOTPNew';
                              var requestBody = json.encode({
                                "email": '',
                                "mobile": '${editText_MobileNo.text}',
                                "otp_purpose":"VERIFY_FORGOT_PASSWORD",
                                "otp": '${_pinController.text}',
                                "username": '',
                              });
                              PostOTPUserVerify(Url_otpVerify, requestBody);
                            }

                          } else {
                            String Message="Please Check Internet Connection !";

                            NetworkAlert.networkCheckAlert(Message, "0", context);

                          }
                        });*/
                         if(_pinController.text.isEmpty){
                          // FlutterToastAlert.flutterToastMSG("Please enter the valid otp", context);
                           UtilMethod.SnackBarMessage(_scaffoldKey, AppLocalizations.of(context).translate("Please enter the valid otp")+" !");
                         }else {
                           print('CONTINUE buttton  _pinController.text=${ _pinController.text}');
                           _GetOtpPhone(
                               routeData["mobile_no"], _pinController.text);
                         }

                      },
                      child: Text(
                        AppLocalizations.of(context).translate("Continue").toUpperCase(),
                        style: TextStyle(color: Color(Helper.ButtontextColor), fontSize:Helper.textSizeH12,fontWeight:Helper.textFontH5),
                      ),
                    ),
                  ),

                      false ?Container(
                    height: 60,
                    width: MQ_Width*0.85,
                    margin:  EdgeInsets.only(left:MQ_Width *0.06,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: 0),

                    decoration: BoxDecoration(
                      // color: Color(Helper.designColor),
                      // border: Border.all(width: 0.5,color: Color(Helper.designColor)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FlatButton(
                      onPressed: ()async{



                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Color(Helper.textColorBlackH2), fontSize:Helper.textSizeH11,fontWeight:Helper.textFontH6),
                      ),
                    ),
                  ):Container(),


                ],
              ),
            ),

            Positioned(
                child:
               // isLoading
                 false   ?Container(
                    margin: EdgeInsets.only(top: 200),
                    alignment: Alignment.bottomCenter,
                    child:new Center(


                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.only(top: 10,bottom: 10),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(Helper.HeaderColor)),

                                // strokeWidth: 20,
                              ),),
                          ],
                        )
                    ))

                    : Container()
            ),
          ],
        ),
      ),
    );
  }

  Widget textField() {
    return Container(
      width: 100,
      color: Custom_color.GreyLightColor,
      child: TextField(
        maxLength: 1,
        //maxLengthEnforced: true,
        style: TextStyle(
            fontFamily: "OpenSans Regular", color: Custom_color.BlackTextColor),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
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
          child: Row(
            children: <Widget>[
              Flexible(
                flex: 2,
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

  // Return "OTP" input field
  get _getInputField {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: <Widget>[
        _otpTextField(_firstDigit),
        _otpTextField(_secondDigit),
        _otpTextField(_thirdDigit),
        _otpTextField(_fourthDigit),
      ],
    );
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(int digit) {
    // return Container(
    //   width: 50.0,
    //   height: 50.0,
    //   alignment: Alignment.center,
    //   child: Text(
    //     digit != null ? digit.toString() : "",
    //     style: TextStyle(
    //       fontSize: 20.0,
    //       color: Custom_color.WhiteColor,
    //     ),
    //   ),
    //   decoration: BoxDecoration(
    //       //            color: Colors.grey.withOpacity(0.4),
    //       borderRadius: BorderRadius.circular(80.0),
    //       color: Custom_color.GreyLightColor
    //       ),
    // );

    return Container(
      margin: EdgeInsets.only(left: 10.0,right: 10.0),

      //margin: EdgeInsets.all(1.0),
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Custom_color.GreyLightColor2,


      ),
      alignment: Alignment.center,
      child: Text(
        digit != null ? digit.toString() : "",
        style: TextStyle(
          fontSize: 20.0,
          color: Custom_color.BlackTextColor,
        ),
      ),
    );
  }

  // Current digit
  void _setCurrentDigit(int i) {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;
        autoSubmit();
      }



    });
  }


  void autoSubmit() async
  {
    var otp = _firstDigit.toString() +
        _secondDigit.toString() +
        _thirdDigit.toString() +
        _fourthDigit.toString();


    print("----otp-----" + otp.toString());
    if (await UtilMethod.SimpleCheckInternetConnection(
        context, _scaffoldKey)) {
      _GetOtpPhone(
          routeData["mobile_no"], otp.toString());
    }
  }

  // Returns "Otp" keyboard
  get _getOtpKeyboard {
    return Container(
        padding: EdgeInsets.only(top: 15.0),
        color: Custom_color.GreyLightColor2,

        height: _screenSize.width - 50,
        child: Column(


          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                      }),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),

//            Expanded(
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                children: <Widget>[
//                  Divider(
//                    color: Colors.red,
//                    thickness: 2.0,
//                    height: _screenSize.height,
//                  ),
//                  _otpKeyboardInputButton(
//                      label: "1",
//                      onPressed: () {
//                        _setCurrentDigit(1);
//                      }),
//                  Divider(
//                    color: Colors.red,
//                    thickness: 2.0,
//                    height: _screenSize.height,
//                  ),
//
//                  _otpKeyboardInputButton(
//                      label: "2",
//                      onPressed: () {
//                        _setCurrentDigit(2);
//                      }),
//                  Divider(
//                    color: Colors.red,
//                    thickness: 2.0,
//                    height: _screenSize.height,
//                  ),
//
//                  _otpKeyboardInputButton(
//                      label: "3",
//                      onPressed: () {
//                        _setCurrentDigit(3);
//                      }),
//                ],
//              ),
//            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "4",
                      onPressed: () {
                        _setCurrentDigit(4);
                      }),
                  _otpKeyboardInputButton(
                      label: "5",
                      onPressed: () {
                        _setCurrentDigit(5);
                      }),
                  _otpKeyboardInputButton(
                      label: "6",
                      onPressed: () {
                        _setCurrentDigit(6);
                      }),
                ],
              ),
            ),

            Expanded(

              child: Row(

                mainAxisAlignment: MainAxisAlignment.center,


                children: <Widget>[

                  _otpKeyboardInputButton(
                      label: "7",
                      onPressed: () {
                        _setCurrentDigit(7);
                      }),
                  _otpKeyboardInputButton(
                      label: "8",
                      onPressed: () {
                        _setCurrentDigit(8);
                      }),
                  _otpKeyboardInputButton(
                      label: "9",
                      onPressed: () {
                        _setCurrentDigit(9);
                      }),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _otpKeyboardActionButton(
                      label: Icon(
                        Icons.backspace,
                        size: 30,
                        color: Custom_color.OrangeLightColor,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_fourthDigit != null) {
                            _fourthDigit = null;
                          } else if (_thirdDigit != null) {
                            _thirdDigit = null;
                          } else if (_secondDigit != null) {
                            _secondDigit = null;
                          } else if (_firstDigit != null) {
                            _firstDigit = null;
                          }
                        });
                      }),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: _fourthDigit != null,
                      child: _otpKeyboardActionButton(
                          label: Icon(
                            Icons.check_circle,
                            size: 36,
                            color: Custom_color.GreenColor,
                          ),
                          onPressed: () async {
                            var otp = _firstDigit.toString() +
                                _secondDigit.toString() +
                                _thirdDigit.toString() +
                                _fourthDigit.toString();

                            // Verify your otp by here. API call

                            print("----otp-----" + otp.toString());
                            if (await UtilMethod.SimpleCheckInternetConnection(
                                context, _scaffoldKey)) {
                              _GetOtpPhone(routeData["mobile_no"], otp.toString());
                            }
                            // you can dall OTP verification API.
                          })),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ));
  }

  // Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({Widget label, VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(80.0),
      child: Container(

          height: 60,
          width: 90,
          margin: EdgeInsets.only(right: 5.0,left: 5.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,

          ),
          child: label),
    );
  }

  // Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton({String label, VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: new BorderRadius.circular(80.0),
        child: Container(
            margin: EdgeInsets.only(left:5.0,right: 5.0),
            height: 60,
            width: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,

            ),
            child: CustomWigdet.TextView(
                text: label,
                color: Custom_color.BlackTextColor,
                fontSize: 25,
                fontFamily: "OpenSans Bold")),
      ),
    );
  }

  Future<https.Response> _GetOtpPhone(String mobile, String otp) async {
    try {
      _showProgress(context);
      Map jsondata = {"mobile": mobile, "otp": otp};
      var res = await https.post(
          Uri.parse(WebServices.OtpMobile +
              "?language=${SessionManager.getString(Constant.Language_code)}"),
          body: jsondata,
          encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + res.body);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data["status"]) {
          print("----111111-----");
          SessionManager.setString(Constant.LogingId, data["data"]["id"].toString());
          print("----2222222-----");
          SessionManager.setString(
              Constant.Token, data["data"]["token"].toString());
          SessionManager.setString(
              Constant.Interested, data["data"]["interest"].toString());
          SessionManager.setString(Constant.Name, data["data"]["name"].toString());
          SessionManager.setString(Constant.Email, data["data"]["email"].toString());
          SessionManager.setString(Constant.Dob, data["data"]["dob"].toString());
          SessionManager.setString(
              Constant.Profile_img, data["data"]["profile_img"].toString());
          SessionManager.setString(
              Constant.Mobile_no, data["data"]["mobile_no"].toString());
          SessionManager.setString(Constant.Country_code, data["data"]["mobile_code"].toString());
          //  SessionManager.setString(Constant.ChatCount, data["data"]["chatcount"].toString());
          //  SessionManager.setString(Constant.NotificationCount, data["data"]["notification_count"].toString());
          UtilMethod.SetChatCount(context, data["data"]["chatcount"].toString());
          UtilMethod.SetNotificationCount(context, data["data"]["notification_count"].toString());
          SessionManager.setboolean(Constant.AlreadyRegister, true);
          print("----44444-----");
          bool routed = false;
          if(routeData['from_reg'] != null) {
            if(routeData['from_reg'] == "1") {
              routed = true;
              Navigator.pushNamed(
                  context, Constant.UserRegisterRoute, arguments: {
                "access": routeData["access"],
                "countryCode": routeData["countryCode"],
                "mobile_no": routeData["mobile_no"],
                "device_id": routeData["device_id"],
                "facbook_id": routeData["facbook_id"],
                "device_type": routeData["device_type"],
              });
            }
          }


          if(!routed)
          {
            if (routeData["oldaccount"]) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Constant.ParticleBackgroundApp, (Route<dynamic> route) => false);
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(Constant.WelcomeRoute, (Route<dynamic> route) => false);
            }
          }

        } else {
          _hideProgress();
          setState(() {
            _firstDigit   = null;
            _secondDigit  = null;
            _thirdDigit   = null;
            _fourthDigit  = null;
          });


          String MSG='Data response  something went wrong.Please try again later';
          try{
            MSG=data["message"];
          }catch(error){
            print(error);
          }
          if (MSG != null) {
            ShowDialogError.showDialogErrorMessage(context, "Data Response", MSG, res.statusCode, 'error', MQ_Width, MQ_Height);
          }else{
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
    } on Expanded catch (e) {
      print(e.toString());
      _hideProgress();
      ShowDialogError.showDialogErrorMessage(context, "Exception Error", e.toString(), 0, 'error', MQ_Width, MQ_Height);
    }
  }

  Future<https.Response> _GetLoginPhone(String mobile) async {
    try {
      _showProgress(context);


      Map jsondata = {"mobile": mobile,"latitude":getPoint(true).toString(),"longitude":getPoint(false).toString()};
      String URL;

      if (routeData["access"] == Constant.LoginByFacebook || routeData["access"] == Constant.CreateByPhone) {
        try {
          if (_currentLocation != null)
            jsondata = {
              "mobile": mobile,
              "countrycode": isocountry.toString(),
              "latitude": _currentLocation.latitude.toString(),
              "longitude": _currentLocation.longitude.toString()
            };
          URL = WebServices.ValidePhoneNumber + "?language=${SessionManager.getString(Constant.Language_code)}";
        } catch (e) {}
      }else{
        try
        {
          if(_currentLocation != null)
            jsondata = {"mobile": mobile,"latitude":_currentLocation.latitude.toString(),"longitude":_currentLocation.longitude.toString()};
          URL= WebServices.LoginMobile + "?language=${SessionManager.getString(Constant.Language_code)}";
        }catch(e){}
      }

      print(jsondata);
      print(Uri.parse(URL));

      var res= await https.post (Uri.parse(URL),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + res.body);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data["status"]) {
          /*Navigator.pushNamed(context, Constant.OtpRoute, arguments: {
            "countryCode": countryCode,
            "mobile_no": mobileNumber,
            "oldaccount":data["oldaccount"]
          });*/
          try {
            _pinController.clear();
            _timer.cancel();
            timerMaxSeconds = 59;
            currentSeconds = 0;
            startTimer();

          }catch(error){
            print('pincontroller error=$error');
          }


        } else {
          var messages = data["message"].toString();
          if (messages != null) {
            UtilMethod.SnackBarMessage(_scaffoldKey, messages);
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
    } on Expanded catch (e) {
      print(e.toString());
      _hideProgress();
      ShowDialogError.showDialogErrorMessage(context, "Exception Error", e.toString(), 0, 'error', MQ_Width, MQ_Height);
    }
  }

  void startTimer([int milliseconds]) {
    var duration = interval;
    _timer = Timer.periodic(duration, (timer) {
      setState(() {
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) timer.cancel();
      });
    });
  }

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  _showProgress(BuildContext context) {
    setState(() {
      showLoading = true;
    });
  }

  _hideProgress() {
    setState(() {
      showLoading = false;
    });
  }



//  {
//  I/flutter (25623):     "status": true,
//  I/flutter (25623):     "data": {
//  I/flutter (25623):         "id": 14,
//  I/flutter (25623):         "mobile_code": "+91",
//  I/flutter (25623):         "mobile_no": "0000000000",
//  I/flutter (25623):         "name": "Shakeel saifi",
//  I/flutter (25623):         "dob": "19-05-2020",
//  I/flutter (25623):         "email": "shakeel.saifi@leanport.info",
//  I/flutter (25623):         "type": 0,
//  I/flutter (25623):         "access": 0,
//  I/flutter (25623):         "interest": 0,
//  I/flutter (25623):         "password": "123456",
//  I/flutter (25623):         "facebook_id": null,
//  I/flutter (25623):         "gender": 0,
//  I/flutter (25623):         "profile_img": "5ecfb9a5269c8.png",
//  I/flutter (25623):         "token": "GQ914q0ErL4RHNxUe_7ma7toCWyy1nAl",
//  I/flutter (25623):         "device_id": "1913f62185294c9d",
//  I/flutter (25623):         "device_type": 0,
//  I/flutter (25623):         "user_ip": "108.167.189.23",
//  I/flutter (25623):         "latitude": "29.8324",
//  I/flutter (25623):         "longitude": "-95.4720",
//  I/flutter (25623):         "created_at": 1590671781,
//  I/flutter (25623):         "updated_at": 1590671781
//  I/flutter (25623):     }
//  I/flutter (25623): }

}