import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:intl/intl.dart';
import 'package:miumiu/utilmethod/fluttertoast_alert.dart';
import 'package:miumiu/utilmethod/helper.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../utilmethod/showDialog_Error.dart';

class UserAboutMe extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<UserAboutMe> {
  Size _screenSize;
  bool showLoading;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  GlobalKey<FormState> _formKey1 = new GlobalKey<FormState>();
  ProgressDialog progressDialog;
  DateTime selectedDate;
  var customFormat = DateFormat('dd-MM-yyyy');
  var routeData;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var MQ_Height;
  var MQ_Width;

  String aboutChangedTxt;
  TextEditingController _textEditAboutMe=new TextEditingController();


  Future<Null> showPicker(BuildContext context) async {
//    final DateTime picked = await DatePicker.showSimpleDatePicker(
//        context,
////        initialDate: DateTime.now(),
////        firstDate: DateTime(1900),
////        lastDate: DateTime.now(),
//      initialDate: DateTime.now(),
//      firstDate:DateTime.now(),
//      lastDate:DateTime.now().add(Duration(days: (5*366))),
//        dateFormat: "dd-MMMM-yyyy",
//      locale: DateTimePickerLocale.en_us,
//      looping: true,
//    );

    final DateTime picked = await DatePicker.showSimpleDatePicker(context,
        initialDate: DateTime.now().subtract(Duration(days: ((18 * 365))+5)),
        firstDate: DateTime(1900),
        lastDate: DateTime.now().subtract(Duration(days: ((18 * 365))+5)),
        dateFormat: "dd-MMMM-yyyy",
        locale: SessionManager.getString(Constant.Language_code)=="en"? DateTimePickerLocale.en_us: SessionManager.getString(Constant.Language_code)=="de"? DateTimePickerLocale.de: SessionManager.getString(Constant.Language_code)=="ar"? DateTimePickerLocale.ar: DateTimePickerLocale.tr,
        titleText: AppLocalizations.of(context).translate("Select Date"),
        cancelText: AppLocalizations.of(context).translate("Cancel"),
        confirmText: AppLocalizations.of(context).translate("Ok"),
        looping: true
        );

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });

  }

  @override
  void initState() {

    showLoading = false;
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    routeData = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    _screenSize = MediaQuery.of(context).size;
    var _pageSize = MediaQuery.of(context).size.height;
    var _notifySize = MediaQuery.of(context).padding.top;
    var _appBarSize = _getAppbar.preferredSize.height;
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    //routeData = ModalRoute.of(context).settings.arguments;
    print("-----route--------"+routeData.toString());
  
    return SafeArea(
      child: WillPopScope(
        onWillPop: ()async{
          UtilMethod.SnackBarMessage(
              _scaffoldKey,
              AppLocalizations.of(context)
                  .translate("Please enter about me"));
          return Future.value(false);
        },
        child: Scaffold(
            key: _scaffoldKey,

            body: Stack(
              children: [
               // _widgetUserRegisterDetails()
                _widgetUserRegisterDetailsNewUI()
              ],
            )
           ),
      )
    
    );
  }




  //========== New UI ======
  Widget _widgetUserRegisterDetailsNewUI(){
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
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assest/images/background_img.jpg"),//AssetImage("assest/images/hello.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),

                child: Stack(
                  children: [

                    SingleChildScrollView(
                      child: Column(
                        children: [
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
                                  height: 4,
                                  color:true?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
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

                          SizedBox(
                            height: MQ_Height*0.05,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text('About me',
                              style: TextStyle(color:Color(Helper.textColorBlackH1),
                                  fontFamily: "Kelvetica Nobis",
                                  fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH5),),
                          ),
                          SizedBox(
                            height: MQ_Height*0.01,
                          ),
                          Center(
                            child: Container(
                              width: _screenSize.width,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 35, right: 35),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[

                                    // CustomWigdet.TextView(
                                    //     overflow: true,
                                    //     text: AppLocalizations.of(context)
                                    //         .translate("What's your first name?"),
                                    //     fontSize: 14.0,
                                    //     textAlign: TextAlign.center,
                                    //     color: Custom_color.BlackTextColor,
                                    //     fontFamily: "OpenSans Bold"),
                                    SizedBox(
                                      height: MQ_Height*0.03,
                                    ),
                                    _otpTextField(),

                                    SizedBox(height: MQ_Height*0.09),

                                    Container(
                                      margin: EdgeInsets.only(bottom: 20),
                                      alignment: Alignment.center,
                                      child: CustomWigdet.RoundOutlineFlatButton(
                                        onPress: () {


                                            saveAbout();

                                        },
                                        text: AppLocalizations.of(context)
                                            .translate("Continue")
                                            .toUpperCase(),
                                        fontFamily: "OpenSans Bold",
                                        fontSize: Helper.textSizeH12,
                                        fontWeight: Helper.textFontH4,
                                        textColor: Custom_color.WhiteColor,
                                        //    bgcolor: Custom_color.BlueLightColor
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    false?Positioned(
                      top: 30,
                      left: 10,
                      child: InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
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
                          child: Container(
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
                      ),
                    ):Container(),
                  ],
                ),
              )),

        ]);
  }

  saveAbout() async {
    if(aboutChangedTxt != null&&aboutChangedTxt!=""&&aboutChangedTxt!=" "&&aboutChangedTxt!="  ") {
   // aboutChangedTxt = aboutChangedTxt != "" ? aboutChangedTxt : about_myself;
      try {
    _showProgress(context);

    String url =WebServices.SaveAbout + SessionManager.getString(Constant.Token) + "&data="+Uri.encodeFull(aboutChangedTxt.trim())+"&language=${SessionManager.getString(Constant.Language_code)}";
    print("-----url-----" + url.toString());
    https.Response res = await https.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "Cache-Control": "no-cache",
    });
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      if (data["status"]) {
        setState(() {
        // about_myself = aboutChangedTxt;
        });
        _hideProgress();
       //==================== New Switch page ========
        Navigator.pushNamed(
          context,
          Constant.ProfessionalRoute,
        );


      }else{
        _hideProgress();
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

    } else if (res.statusCode == 500) {
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

    }else{
      //FlutterToastAlert.flutterToastMSG(AppLocalizations.of(context).translate("Please enter about me"), context);
      UtilMethod.SnackBarMessage(
          _scaffoldKey,
          AppLocalizations.of(context)
              .translate("Please enter about me"));
    }
   /* if(aboutChangedTxt != null) {
      Navigator.pushNamed(context, Constant.ProfileScreen, arguments: {
        "access": routeData["access"],
        "countryCode": routeData["countryCode"],
        "mobile_no": routeData["mobile_no"],
        "firstname": routeData["firstname"],
        "email": routeData["email"],
        "dob": routeData["dob"],
        "gender": routeData["gender"],
        //select_gender_men ? Constant.Men : Constant.Women,
        "device_id": routeData["device_id"],
        "device_type": routeData["device_type"],
        "facbook_id": routeData["facbook_id"],
        "about_me": '${aboutChangedTxt}',

      }
      );
    }else{
      FlutterToastAlert.flutterToastMSG(AppLocalizations.of(context).translate("Please enter about me"), context);
    }*/



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
                flex: 4,
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

  Widget _otpTextField() {
    return Container(
      height: 200,

        decoration: BoxDecoration(
          border: Border.all(color: Color(Helper.editTextBorderLineColorH1),width: 1),
          boxShadow: [
            BoxShadow(
                color:Color(0xffd7dbe6),
                offset: Offset(0,6),
                blurRadius: 20

            )
          ],
          color: Custom_color.WhiteColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 17,bottom: 15),
          child: Form(
            key: this._formKey,
            child: TextFormField(
             // controller: _textEditAboutMe,
              showCursor: true,
              initialValue : aboutChangedTxt,
              maxLines: 6,
              style: TextStyle(
                  color: Custom_color.BlackTextColor,
                  fontFamily: "OpenSans Regular",
                fontWeight: Helper.textFontH5,
                fontSize: Helper.textSizeH14),
              decoration: InputDecoration(

               // prefixIcon: ImageIcon(AssetImage("assest/images/name.png"),color: Custom_color.GreyTextColor,),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 20,top: 5.0),
                isDense: true,
                hintStyle: TextStyle(
                    color: Color(0xff9a9a9a),
                    fontWeight: Helper.textFontH4,
                    fontSize: Helper.textSizeH14,
                    fontFamily: "Kelvetica Nobis"
                ),
                hintText:'Descriptions'
                   // AppLocalizations.of(context).translate("What's your first name?"),
              ),

              keyboardType: TextInputType.text,
              onChanged: (text) {
                setState(() {
                  aboutChangedTxt = text;
                });
              },
              onSaved: (value) {
                setState(() {
                  aboutChangedTxt = value;
                });
              },
            ),
          ),
        ));
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
