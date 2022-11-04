import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:intl/intl.dart';
import 'package:miumiu/utilmethod/helper.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../utilmethod/fluttertoast_alert.dart';

class User_register extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<User_register> {
  Size _screenSize;
  bool showLoading;
  String firstname = "", email = "";
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  GlobalKey<FormState> _formKey1 = new GlobalKey<FormState>();
  ProgressDialog progressDialog;
  DateTime selectedDate;
 var _selectedStartDate;
  var customFormat = DateFormat('dd-MM-yyyy');
  var routeData;
  FocusNode myFocusNode;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var MQ_Height;
  var MQ_Width;

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
    FocusScope.of(context).requestFocus(myFocusNode);
  }


  //============== New UI Show Start Date Picker ============

  Future<void> _ShowBirdyDatePick()async{

    await showDialog(context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context){
          return Container(

            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xfff16cae).withOpacity(0.8),
                    Color(0xff3f86c6).withOpacity(0.8),
                  ],
                )
            ),

            child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Helper.avatarRadius),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child:Container(
                  width: MQ_Width,
                  height: 280,
                  // padding: const EdgeInsets.only(left: 10,right: 10),
                  padding: EdgeInsets.only(left: Helper.padding,
                  ),
                  // margin: EdgeInsets.only(top: Helper.avatarRadius),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Helper.padding),
                    /* boxShadow: [
                        BoxShadow(color: Colors.black,offset: Offset(0,10),
                            blurRadius: 10
                        ),
                      ]*/
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          // height: 250,
                          child: Column(
                            children: [
                              Container(
                                //margin:  EdgeInsets.only(top: MQ_Height*0.02,bottom: 5),
                                alignment: Alignment.centerLeft,
                                child: CustomWigdet.TextView(
                                  // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                                    overflow: true,
                                    text:AppLocalizations.of(context).translate("Select Date"),
                                    fontFamily: "Kelvetica Nobis",
                                    fontSize: Helper.textSizeH11,
                                    fontWeight: Helper.textFontH6,
                                    color: Helper.textColorBlueH1
                                ),
                              ),
                              DatePickerWidget(
                                looping: false, // default is not looping
                                // firstDate: DateTime.now(), //DateTime(1960),
                                //  lastDate: DateTime(2002, 1, 1),
//              initialDate: DateTime.now(),// DateTime(1994),
                                initialDate: DateTime.now().subtract(Duration(days: ((18 * 365))+5)),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now().subtract(Duration(days: ((18 * 365))+5)),
                                dateFormat: "dd-MMMM-yyyy",
                                //     locale: DatePicker.localeFromString('he'),
                                locale: SessionManager.getString(Constant.Language_code)=="en"? DateTimePickerLocale.en_us: SessionManager.getString(Constant.Language_code)=="de"?
                                DateTimePickerLocale.de: SessionManager.getString(Constant.Language_code)=="ar"? DateTimePickerLocale.ar: DateTimePickerLocale.tr,
                                // titleText: AppLocalizations.of(context).translate("Select Date"),
                                onChange: (DateTime newDate, _) async{
                                  setState(() {
                                    _selectedStartDate = newDate;
                                    // startDate = newDate;
                                  });
                                  print(_selectedStartDate);
                                },

                                pickerTheme: DateTimePickerTheme(
                                  backgroundColor: Colors.transparent,

                                  itemTextStyle: TextStyle(color: Colors.blue,
                                    fontSize: Helper.textSizeH10,
                                    fontWeight: Helper.textFontH5,),
                                  dividerColor: Colors.blue,
                                ),

                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.bottomCenter,
                                      margin:  EdgeInsets.only(left: 5,right: 5),
                                      height: 50,
                                      width: MQ_Width*0.28,
                                      decoration: BoxDecoration(
                                        color: Color(Helper.ButtonBorderPinkColor),
                                        border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: FlatButton(
                                        onPressed: ()async{
                                          setState(() {
                                            Navigator.of(context).pop();
                                            if(_selectedStartDate==null){
                                             // selectedDate =DateTime.now();
                                              _ShowBirdyDatePick();
                                              FlutterToastAlert.flutterToastMSG('${AppLocalizations.of(context)
                                                  .translate("Please valid Date of birth")
                                                  .toUpperCase()}', context);
                                            }else{
                                              selectedDate =_selectedStartDate;
                                            }
                                          });


                                        },
                                        child: Text(
                                          // isLocationEnabled?'CLOSE':'OPEN',
                                          AppLocalizations.of(context)
                                              .translate("ok")
                                              .toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH13,fontWeight:Helper.textFontH5),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MQ_Width*0.01,
                                    ),
                                    Container(
                                      alignment: Alignment.bottomCenter,
                                      margin:  EdgeInsets.only(left: 5,right: 5),

                                      height: 50,
                                      width: MQ_Width*0.28,
                                      decoration: BoxDecoration(
                                        color: Helper.ButtonBorderGreyColor,//Color(Helper.ButtonBorderPinkColor),
                                        border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: FlatButton(
                                        onPressed: ()async{
                                          Navigator.of(context).pop();

                                        },
                                        child: Text(
                                          // isLocationEnabled?'CLOSE':'OPEN',
                                          AppLocalizations.of(context)
                                              .translate("Close")
                                              .toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                        ),
                                      ),
                                    ),



                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Text("${_selectedDate ?? ''}"),
                      ],
                    ),
                  ),
                )
            ),
          );
        });




  }

  @override
  void initState() {
    myFocusNode = FocusNode();
    showLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    routeData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    _screenSize = MediaQuery.of(context).size;
    var _pageSize = MediaQuery.of(context).size.height;
    var _notifySize = MediaQuery.of(context).padding.top;
    var _appBarSize = _getAppbar.preferredSize.height;
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
  
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,

          body: Stack(
            children: [
             // _widgetUserRegisterDetails()
              _widgetUserRegisterDetailsNewUI()
            ],
          )
         )
    
    );
  }

  //========== Old UI ======
  Widget _widgetUserRegisterDetails(){
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
                    image: AssetImage("assest/images/hello.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),

                child: Stack(

                  children: [
                    Center(
                      child: Container(
                        width: _screenSize.width,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 35, right: 35),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(top: 50),
                            //  physics: ClampingScrollPhysics(),
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
                                  height: 10,
                                ),
                                _otpTextField(),
                                SizedBox(
                                  height: 20,
                                ),
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text: AppLocalizations.of(context)
                                        .translate("Were sure you have a cute"),
                                    fontSize: 13,
                                    color: Custom_color.GreyTextColor,
                                    fontFamily: "Open Sans",
                                    textAlign: TextAlign.left),
                                SizedBox(
                                  height: 30,
                                ),
                                // CustomWigdet.TextView(
                                //     overflow: true,
                                //     text: AppLocalizations.of(context)
                                //         .translate("What is your date of birth?"),
                                //     fontSize: 14.0,
                                //     textAlign: TextAlign.center,
                                //     color: Custom_color.BlackTextColor,
                                //     fontFamily: "OpenSans Bold"),
                                SizedBox(
                                  height: 10,
                                ),
                                _otpTextFieldDOB(context),
                                SizedBox(
                                  height: 20,
                                ),
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text: AppLocalizations.of(context)
                                        .translate("We need your date of birth"),
                                    fontSize: 13,
                                    fontFamily: "Open Sans",
                                    color: Custom_color.GreyTextColor,
                                    textAlign: TextAlign.left),
                                SizedBox(
                                  height: 30,
                                ),
                                // CustomWigdet.TextView(
                                //     overflow: true,
                                //     text: AppLocalizations.of(context)
                                //         .translate("What's your email address?"),
                                //     fontSize: 14.0,
                                //     textAlign: TextAlign.center,
                                //     color: Custom_color.BlackTextColor,
                                //     fontFamily: "OpenSans Bold"),
                                SizedBox(
                                  height: 10,
                                ),
                                _otpTextFieldEMAIL(),
                                SizedBox(
                                  height: 10,
                                ),
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text: AppLocalizations.of(context)
                                        .translate("Add your email address"),
                                    fontSize: 13,
                                    color: Custom_color.GreyTextColor,
                                    fontFamily: "Open Sans",
                                    textAlign: TextAlign.left),
                                SizedBox(height: 30),

                                Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: CustomWigdet.RoundOutlineFlatButton(
                                    onPress: () {
                                      OnSubmit(context);
                                    },
                                    text: AppLocalizations.of(context)
                                        .translate("Continue")
                                        .toUpperCase(),
                                    fontFamily: "OpenSans Bold",
                                    textColor: Custom_color.WhiteColor,
                                    //    bgcolor: Custom_color.BlueLightColor
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                    ),
                  ],
                ),
              )),

        ]);
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

            child:  ListView(
              physics: AlwaysScrollableScrollPhysics(),
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
                        height: 4,
                        color:true?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
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

                  alignment: Alignment.centerLeft,
                  child: Text('Enter',
                    style: TextStyle(color:Color(Helper.textColorBlackH2),
                        fontFamily: "Kelvetica Nobis",
                        fontWeight: Helper.textFontH5,fontSize: Helper.textSizeH4),),
                ),
                Container(
                  margin: EdgeInsets.only(left: MQ_Width*0.06,top: MQ_Height*0.01),

                  alignment: Alignment.centerLeft,
                  child: Text('Your Details',
                    style: TextStyle(color:Color(0xfffb4592),
                        fontFamily: "Kelvetica Nobis",
                        fontWeight: Helper.textFontH2,fontSize: Helper.textSizeH4),),
                ),
                SizedBox(
                  height: MQ_Height*0.01,
                ),
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    width: _screenSize.width,
                    height:_screenSize.height*0.62,


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
                          SizedBox(
                            height: MQ_Height*0.01,
                          ),
                          CustomWigdet.TextView(
                              overflow: true,
                              text: AppLocalizations.of(context)
                                  .translate("Were sure you have a cute"),
                              fontSize: Helper.textSizeH14,
                              fontWeight: Helper.textFontH5,
                              color: Custom_color.GreyTextColor,
                              fontFamily: "Open Sans",
                              textAlign: TextAlign.left),
                          SizedBox(
                            height: MQ_Height*0.03,
                          ),
                          // CustomWigdet.TextView(
                          //     overflow: true,
                          //     text: AppLocalizations.of(context)
                          //         .translate("What is your date of birth?"),
                          //     fontSize: 14.0,
                          //     textAlign: TextAlign.center,
                          //     color: Custom_color.BlackTextColor,
                          //     fontFamily: "OpenSans Bold"),

                          _otpTextFieldDOB(context),
                          SizedBox(
                            height: MQ_Height*0.01,
                          ),
                          CustomWigdet.TextView(
                              overflow: true,
                              text: AppLocalizations.of(context)
                                  .translate("We need your date of birth"),
                              fontSize: Helper.textSizeH14,
                              fontWeight: Helper.textFontH5,
                              fontFamily: "Open Sans",
                              color: Custom_color.GreyTextColor,
                              textAlign: TextAlign.left),
                          SizedBox(
                            height: MQ_Height*0.03,
                          ),
                          // CustomWigdet.TextView(
                          //     overflow: true,
                          //     text: AppLocalizations.of(context)
                          //         .translate("What's your email address?"),
                          //     fontSize: 14.0,
                          //     textAlign: TextAlign.center,
                          //     color: Custom_color.BlackTextColor,

                         // _otpTextFieldEMAIL(),
                         false? SizedBox(
                            height: MQ_Height*0.01,
                          ):Container(),
                         false? CustomWigdet.TextView(
                              overflow: true,

                              text: AppLocalizations.of(context)
                                  .translate("Add your email address"),
                              fontSize:Helper.textSizeH14,
                              fontWeight: Helper.textFontH5,
                              color: Custom_color.GreyTextColor,
                              fontFamily: "Open Sans",
                              textAlign: TextAlign.left):Container(),
                          SizedBox(height: MQ_Height*0.05),

                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: CustomWigdet.RoundOutlineFlatButton(
                              onPress: () {
                                //OnSubmit(context);

                                OnSubmitWithoutMail(context);

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
          )),

    ]);
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
      height: 60,

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
              showCursor: true,
              keyboardType: TextInputType.text,
             // textCapitalization: TextCapitalization.sentences,
              inputFormatters: [UpperCaseTextFormatter()],
              style: TextStyle(
                  color: Custom_color.BlackTextColor,
                  fontFamily: "OpenSans Regular",
                  fontSize: 14),
              decoration: InputDecoration(

                prefixIcon: ImageIcon(AssetImage("assest/images/name.png"),color: Custom_color.GreyTextColor,),

                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 5.0),
                isDense: true,
                hintStyle: TextStyle(
                    color: Color(0xff9a9a9a),
                    fontFamily: "Kelvetica Nobis"
                ),
                hintText:
                    AppLocalizations.of(context).translate("What's your first name?"),
              ),

              onSaved: (value) {
                firstname = value;
              },
            ),
          ),
        ));
  }
//================ With Email =========
  Future<void> OnSubmit(BuildContext context) async {
    print('Printing the  data.');

     if (!this._formKey.currentState.validate()) {
      return;
    }
    if (!this._formKey1.currentState.validate()) {
      return;
    }

   _formKey.currentState.save(); // Save our form now.
   _formKey1.currentState.save(); // Save our form now.

    print('firstname: ${firstname}');
    print('Email: ${email}');
    if (await UtilMethod.SimpleCheckInternetConnection(context, _scaffoldKey)) {

    //   var Currentdate1 = customFormat.format(DateTime.now());
    //  var selet_date1 = customFormat.format(selectedDate);
    DateTime Currentdate = DateTime.now();
    DateTime selet_date = selectedDate;
    if (firstname.isEmpty) {
      UtilMethod.SnackBarMessage(
          _scaffoldKey,
          AppLocalizations.of(context).translate("Empty name"));
    }
    else if(selectedDate==null){
      UtilMethod.SnackBarMessage(
          _scaffoldKey,
          AppLocalizations.of(context)
              .translate("Please enter date of birth"));
    }
    else if (Currentdate.isBefore(selet_date)) {
      UtilMethod.SnackBarMessage(
          _scaffoldKey,
          AppLocalizations.of(context)
              .translate("Please valid Date of birth"));
    } else if (email.isEmpty) {
        UtilMethod.SnackBarMessage(
            _scaffoldKey,
            AppLocalizations.of(context).translate("Empty email"));
      } else if (!UtilMethod.validateEmail(email)) {
        UtilMethod.SnackBarMessage(
            _scaffoldKey,
            AppLocalizations.of(context).translate("Check your email"));
      }

    else {
      //========== Valid With email Id =========
      if(showLoading)
          return;
        _GetValidEmail(email);

    }


    }

//    Navigator.pushNamed(context, Constant.GenderRoute,
//        arguments: {
//          "access": routeData["access"],
//          "countryCode": routeData["countryCode"],
//          "mobile_no": routeData["mobile_no"],
//          "firstname":firstname,
//          "email":email,
//          "dob":customFormat.format(selectedDate),
//          "device_id":routeData["device_id"],
//          "device_type":routeData["device_type"],
//          "facbook_id":routeData["facbook_id"]
//
//        });

    // Navigator.push(context, MaterialPageRoute(builder:(context) =>HomeScreen(),settings: RouteSettings(arguments: ScreenArguments(""))));

    // Navigator.pushNamed(context, HomeScreen.home_route,arguments: {"id":"12","titke":"xyz"});

    //  Navigator.pushNamed(context, HomeScreen.home_route);
  }


  //================ Without Email ===============
  Future<void> OnSubmitWithoutMail(BuildContext context) async {
    print('Printing the  data.');


    if (!this._formKey.currentState.validate()) {
      return;
    }
   /* if (!this._formKey1.currentState.validate()) {
      return;
    }*/

    _formKey.currentState.save(); // Save our form now.
  //  _formKey1.currentState.save(); // Save our form now.



    print('firstname: ${firstname}');
    print('Email: ${email}');
    // if (await UtilMethod.SimpleCheckInternetConnection(context, _scaffoldKey)) {

    //   var Currentdate1 = customFormat.format(DateTime.now());
    //  var selet_date1 = customFormat.format(selectedDate);
    DateTime Currentdate = DateTime.now();
    DateTime selet_date = selectedDate;
    if (firstname.isEmpty) {
      UtilMethod.SnackBarMessage(
          _scaffoldKey,
          AppLocalizations.of(context).translate("Empty name"));
    }
    else if(selectedDate==null){
      UtilMethod.SnackBarMessage(
          _scaffoldKey,
          AppLocalizations.of(context)
              .translate("Please enter date of birth"));
    }
    else if (Currentdate.isBefore(selet_date)) {
      UtilMethod.SnackBarMessage(
          _scaffoldKey,
          AppLocalizations.of(context)
              .translate("Please valid Date of birth"));
    } else {
      Navigator.pushNamed(context, Constant.GenderRoute, arguments: {
        "access": routeData["access"],
        "countryCode": routeData["countryCode"],
        "mobile_no": routeData["mobile_no"],
        "firstname": firstname,
        "email": email,
        "dob": customFormat.format(selectedDate),
        "device_id": routeData["device_id"],
        "device_type": routeData["device_type"],
        "facbook_id": routeData["facbook_id"]
      });
    }


    //  }

//    Navigator.pushNamed(context, Constant.GenderRoute,
//        arguments: {
//          "access": routeData["access"],
//          "countryCode": routeData["countryCode"],
//          "mobile_no": routeData["mobile_no"],
//          "firstname":firstname,
//          "email":email,
//          "dob":customFormat.format(selectedDate),
//          "device_id":routeData["device_id"],
//          "device_type":routeData["device_type"],
//          "facbook_id":routeData["facbook_id"]
//
//        });

    // Navigator.push(context, MaterialPageRoute(builder:(context) =>HomeScreen(),settings: RouteSettings(arguments: ScreenArguments(""))));

    // Navigator.pushNamed(context, HomeScreen.home_route,arguments: {"id":"12","titke":"xyz"});

    //  Navigator.pushNamed(context, HomeScreen.home_route);
  }

  Widget _otpTextFieldDOB(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Color(Helper.editTextBorderLineColorH1),width: 1),
                boxShadow: [
                  BoxShadow(
                      color: Color(0xffd7dbe6),
                      offset: Offset(0,6),
                      blurRadius: 20

                  )
                ],

                color: Custom_color.WhiteColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () async{
                  //showPicker(context),
                  _ShowBirdyDatePick();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 17,bottom: 15,left: 15),
                  child: Row(
                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      ImageIcon(AssetImage("assest/images/calendar 2.png"),
                        color: Custom_color.GreyTextColor,),
                      SizedBox(width: 12),
                      CustomWigdet.TextView(
                          textAlign: TextAlign.start,
                          text: selectedDate == null
                              ? AppLocalizations.of(context).translate("What is your date of birth?")
                              : "${customFormat.format(selectedDate)}",
                          color: Color(0xff9a9a9a),
                      fontFamily: "Kelvetica Nobis"
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ],
    );
  }

  Widget _otpTextFieldEMAIL() {
    return Container(
      height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Color(Helper.editTextBorderLineColorH1),width: 1),
          boxShadow: [
            BoxShadow(
                color: Color(0xffd7dbe6),
                offset: Offset(0,6),
                blurRadius: 20

            )
          ],
          color: Custom_color.WhiteColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 15,bottom: 15),
          child: Form(
            key: this._formKey1,
            child: TextFormField(
              focusNode: myFocusNode,
              showCursor: true,
              style: TextStyle(
                  color: Custom_color.BlackTextColor,
                  fontFamily: "OpenSans Regular",
                  fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: ImageIcon(AssetImage("assest/images/email.png"),
                  color: Custom_color.GreyTextColor,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 10.0),
                isDense: true,
                hintStyle: TextStyle(
                    color: Color(0xff9a9a9a),
                    fontFamily: "Kelvetica Nobis"
                ),
                hintText: AppLocalizations.of(context)
                    .translate("What's your email address?"),
              ),
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) {
                email = value.trim();
              },
            ),
          ),
        ));
  }

  Future<https.Response> _GetValidEmail(String email) async {
    try {
      _showProgress(context);
      Map jsondata = {"email": email};
      var response = await https.post(Uri.parse(WebServices.ValidEmail + "?language=${SessionManager.getString(Constant.Language_code)}"),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          print("-----logging-----");
          Navigator.pushNamed(context, Constant.GenderRoute, arguments: {
            "access": routeData["access"],
            "countryCode": routeData["countryCode"],
            "mobile_no": routeData["mobile_no"],
            "firstname": firstname,
            "email": email,
            "dob": customFormat.format(selectedDate),
            "device_id": routeData["device_id"],
            "device_type": routeData["device_type"],
            "facbook_id": routeData["facbook_id"]
          });
        }
        else{
          UtilMethod.SnackBarMessage(_scaffoldKey, data["message"].toString());
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
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}
String capitalize(String value) {
  if(value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}
