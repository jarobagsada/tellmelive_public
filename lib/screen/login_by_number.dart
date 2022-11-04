import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as locat;
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
import '../utilmethod/showDialog_Error.dart';

class Login_by_number extends StatefulWidget {
  @override
  _Login_by_numberState createState() => _Login_by_numberState();
}

class _Login_by_numberState extends State<Login_by_number> {
  var _screenSize;
  ProgressDialog progressDialog;
  var routeData, countryCode, mobileNumber;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  locat.LocationData _currentLocation;
  String isocountry;
  locat.Location location = new locat.Location();
  bool showLoading;
  var MQ_Height;
  var MQ_Width;

  //Country _selectedDialogCountry = CountryPickerUtils.getCountryByPhoneCode('90');
  Country _selectedFilteredDialogCountry = CountryPickerUtils.getCountryByPhoneCode('49');
  bool EnableCName=false;
  @override
  void initState() {
    super.initState();
    showLoading = false;
     _currentLocation = Constant.currentLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        GetCurentLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    routeData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    print("-----data------" + _currentLocation.toString());
    MQ_Height= MediaQuery.of(context).size.height;
    MQ_Width=MediaQuery.of(context).size.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(Helper.StatusBarColor)),
      child: Scaffold(
        backgroundColor: Image.asset('assest/images/background_img.jpg').color,
        key: _scaffoldKey,

//      body: Container(
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          children: <Widget>[
//            CustomWigdet.TextView(text: AppLocalizations.of(context).translate("What's your phone number?"),textAlign: TextAlign.center,color: Custom_color.BlackTextColor,fontFamily: "OpenSans Bold")
//          ],
//        ),
//      ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assest/images/background_img.jpg"),//AssetImage("assest/images/hello.jpg"),
                  fit: BoxFit.fill,
                ),
              ),),
            Container(
              child: Visibility(
                visible: true,
                replacement: Center(child: CircularProgressIndicator(),),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 100,left: 36.0,right: 36),
                      child:SingleChildScrollView(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Image(image: AssetImage("assest/images/tellme.png"),
                            width: 290,
                            ),
                            SizedBox(height: 80),
                            /*Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('CountryPickerDialog (filtered)'),
                                  ListTile(
                                    onTap: _openFilteredCountryPickerDialog,
                                    title: _buildDialogItem(_selectedFilteredDialogCountry),
                                  ),
                                ],
                              ),
                            ),*/
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                             // mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text: AppLocalizations.of(context)
                                        .translate("What's your phone number?"),
                                    fontSize: Helper.textSizeH11,
                                    fontWeight: Helper.textFontH4,
                                    textAlign: TextAlign.center,
                                    color: Custom_color.BlackTextColor,
                                    fontFamily: "Kelvetica Nobis"),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Custom_color.BlackTextColor.withOpacity(0.5),width: 1.0),
                                      borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Custom_color.GreyLightColor,
                                        offset: Offset(0,6),
                                        blurRadius: 20

                                      )
                                    ]
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      false?Container(
                                        height: 60,
                                        decoration: BoxDecoration(

                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.zero,
                                            bottomLeft: Radius.circular(10.0),
                                            bottomRight: Radius.zero,
                                          ),
                                          color: Custom_color.WhiteColor,
                                          //borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 2, right: 0, top: 0, bottom: 0),
                                          child: isocountry != null ?
                                          CountryCodePicker(
                                            onInit: (e) {
                                              countryCode = e;
                                              print('CountryCode ## 11000 countryCode ==$countryCode');

                                            },
                                            onChanged: (e) {
                                              countryCode = e;

                                              print('CountryCode ## 111111 countryCode ==$countryCode');
                                            },

                                            initialSelection: isocountry,
                                            //  showCountryOnly: true,
                                            // showOnlyCountryWhenClosed: true,
//                                  favorite: [
//                                    '+91',
//                                  ],
                                            flagWidth: 28,
                                            textStyle: TextStyle(
                                                color: Custom_color.GreyLightColor),
                                          ) : ((_currentLocation == null) ? CountryCodePicker(
                                            onInit: (e) {
                                              countryCode = e;
                                              print('CountryCode ## 11222 countryCode ==$countryCode');

                                            },
                                            onChanged: (e) {
                                              countryCode = e;
                                              print('CountryCode ## 11333 countryCode ==$countryCode');

                                            },

                                            initialSelection: 'de',
                                            showCountryOnly: true,
                                            showOnlyCountryWhenClosed: true,
                                            favorite: [
                                                '+49',
                                            ],
                                            flagWidth: 28,
                                            textStyle: TextStyle(
                                                color: Custom_color.GreyLightColor),
                                          ) :  SizedBox(width:30)),
                                        ),
                                      ):SizedBox(
                                        width: 120,
                                        height: 60,
                                        child: Container(
                                          decoration: BoxDecoration(

                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.zero,
                                              bottomLeft: Radius.circular(10.0),
                                              bottomRight: Radius.zero,
                                            ),
                                            color: Custom_color.WhiteColor,
                                            //borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ListTile(
                                              onTap: _openFilteredCountryPickerDialog,
                                              title: _buildDialogItem(_selectedFilteredDialogCountry),
                                              ),
                                        ),
                                      ),

                                      Expanded(
                                        child: Container(
                                          height: 60,
                                          decoration: BoxDecoration(

                                            color: Custom_color.WhiteColor,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.zero,
                                              topRight: Radius.circular(10.0),
                                              bottomLeft: Radius.zero,
                                              bottomRight: Radius.circular(10.0),
                                            ),
                                           // borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.centerLeft,
                                         // padding: EdgeInsets.only(left: 0, right: 8, top: 8, bottom: 6),
                                          child: Form(
                                            key: this._formKey,
                                            child: TextFormField(
                                              //  autofocus: true,
                                              maxLength: 11,
                                              buildCounter: (BuildContext context, {int currentLength, int maxLength, bool isFocused}) =>null,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.start,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(11),
                                                FilteringTextInputFormatter.digitsOnly,

                                              ],
                                              style: TextStyle(
                                                  color: Custom_color.BlackTextColor,
                                                  fontFamily: "itc avant medium",
                                                  fontSize: 15),
                                              decoration: InputDecoration(
                                              //  contentPadding: EdgeInsets.only(bottom: 8,top: 8),

                                                errorStyle: TextStyle(
                                                  height: 0.1,



                                                    color: Colors.red
                                                ),
                                                isDense: true,
                                                hintText: AppLocalizations.of(context)
                                                    .translate("Enter phone number"),
                                                border: InputBorder.none,
                                              ),

                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return AppLocalizations.of(context)
                                                      .translate("Enter phone number");
                                                } else if (value.length <= 5) {
                                                  return AppLocalizations.of(context)
                                                      .translate(
                                                          "Enter valid phone number");
                                                }
                                              },
                                              onSaved: (value) {
                                                mobileNumber = value;
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text: AppLocalizations.of(context)
                                        .translate("We need it to verify you account"),
                                    fontWeight: Helper.textFontH5,
                                    fontSize: Helper.textSizeH15,
                                    fontFamily: "itc avant medium",
                                    textAlign: TextAlign.left,
                                    color: Custom_color.BlackTextColor,
                                    ),
                              ],
                            ),
                            SizedBox(height: 60),
                            false?Container(
                              child: CustomWigdet.RoundOutlineFlatButton(
                                  onPress: () {
                                    UtilMethod.HideKeyboard(context);
                                    if(showLoading)
                                      return;
                                    OnSubmit(context);
                                  },
                                  text: showLoading ? AppLocalizations.of(context)
                                      .translate("Please wait")
                                      .toUpperCase(): AppLocalizations.of(context)
                                      .translate("Continue")
                                      .toUpperCase(),
                                  textColor: Custom_color.WhiteColor,
                                  // bgcolor: Custom_color.BlueLightColor,
                                  fontFamily: "Kelvetica Nobis"),
                            ):Container(
                              margin:  EdgeInsets.only(left:MQ_Width *0.02,right: MQ_Width * 0.02,top:0,bottom: 0),
                              height: 60,
                              width: MQ_Width*0.88,
                              decoration: BoxDecoration(
                                color: Color(Helper.ButtonBorderColor),
                                border: Border.all(width: 0.5,color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FlatButton(
                                onPressed: ()async{
                                  UtilMethod.HideKeyboard(context);
                                  if(showLoading)
                                    return;
                                  OnSubmit(context);

                                },
                                child: Text(
                                  showLoading ? AppLocalizations.of(context)
                                      .translate("Please wait")
                                      .toUpperCase(): AppLocalizations.of(context)
                                      .translate("Continue")
                                      .toUpperCase(),
                                  style: TextStyle(color:Custom_color.WhiteColor, fontSize:Helper.textSizeH12,fontWeight:Helper.textFontH5),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 10,
                      child: InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: false?Container(

                          child: Image.asset("assest/images/blue_arrow.png"),
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
                            padding: const EdgeInsets.only(left: 10.0,top: 5),
                            child:  Container(
                              child: SvgPicture.asset('assest/images_svg/back.svg',color: Custom_color.BlueLightColor,width: 20,height: 20,),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDialogItem(Country country) {
    print('_buildDialogItem country=$country');
    try {
      setState(() {
        countryCode = '+${country.phoneCode}';
      });
      print('CountryCode ## 11112 countryCode =$countryCode');
    }catch(error){
      print('CountryCode ## 11112 countryCode error=$error');
    }
    return  Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Text("+${country.phoneCode}",overflow: TextOverflow.ellipsis,),
          SizedBox(width: 8.0),
          EnableCName?Flexible(child: Text(country.name)):Container(height: 0,width: 0,)
        ],
      ),
    );
  }


  //========== Country List Dialog ==========


  Future<void> _openFilteredCountryPickerDialog()async{
              setState(() {
                EnableCName=true;
              });
    await showDialog(context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: ()async{
              setState(() {
                EnableCName=false;
              });
              Navigator.pop(context,1);
              return true;
            },
            child: Center(
              child: Container(
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
                child: Material(
                  type: MaterialType.transparency,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      SizedBox(
                        width: MQ_Width,
                       // height: 350,
                        child: Center(
                          child:CountryPickerDialog(
                              titlePadding: const EdgeInsets.all(8.0),
                              searchCursorColor: Colors.pinkAccent,
                              searchInputDecoration: const InputDecoration(hintText:'Search country code or name'),
                              isSearchable: true,
                              // title: const Text('Select your phone code'),
                              onValuePicked: (Country country) =>
                                  setState(() {
                                    _selectedFilteredDialogCountry = country;
                                      EnableCName=false;

                                  }),
                              // itemFilter: (c) => ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode),
                              itemBuilder: _buildDialogItem),
                        ),
                      ),
                      true?InkWell(
                          onTap: (){
                            //perform action here.

                            setState(() {
                              EnableCName=false;
                            });
                            Navigator.pop(context,1);
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 45,top: 35),
                            child: Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 28,
                            ),
                          )):Positioned(
                        //  left:275, //Helper.padding,
                         right:35,// Helper.padding,
                          top: 10,

                          child: false? Container(
                            alignment: Alignment.bottomCenter,
                            margin:  EdgeInsets.only(left:MQ_Width *0.02,right: MQ_Width * 0.02,top: MQ_Height * 0.02,bottom: MQ_Height * 0.01 ),
                            padding: EdgeInsets.only(bottom: 5),
                            height: 60,
                            width: MQ_Width*0.30,
                            decoration: BoxDecoration(
                              color: Color(Helper.ButtonBorderPinkColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FlatButton(
                              onPressed: ()async{
                                Navigator.of(context).pop();


                              },
                              child: Text(
                                // isLocationEnabled?'CLOSE':'OPEN',
                                /* AppLocalizations.of(context)
                                  .translate("Confirm")
                                  .toUpperCase(),*/
                                'Close'.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH11,fontWeight:Helper.textFontH5),
                              ),
                            ),
                          ):
                          InkWell(
                            child: Container(
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.only(top: 8,),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(color:Color(Helper.inBackgroundColor1),width: 3),
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        // Color(0xfff16cae).withOpacity(0.8),
                                        Color(0xff3f86c6),
                                        Color(0xff3f86c6),
                                      ],
                                    )
                                ),
                                child: Icon(Icons.close,color: Colors.white,size:24,)),
                            onTap: (){
                              Navigator.pop(context,1);
                            },
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
        });

  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,

      leading: InkWell(
        onTap: (){
          Navigator.pop(context);
        },
        child: CircleAvatar(
          radius: 17,
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
      leadingWidth: 25,

    );
  }



  Future<void> OnSubmit(BuildContext context) async {
    if (!this._formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save(); // Save our form now.

    print('--mobilenumber---: ${mobileNumber}');

    
    if (routeData["access"] == Constant.LoginByFacebook ||
        routeData["access"] == Constant.CreateByPhone) {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _GetPhoneNumber(mobileNumber);
      }

      print("----inside----");

//        Navigator.pushNamed(context, Constant.UserRegisterRoute,
//            arguments: {
//              "access": routeData["access"],
//              "countryCode": countryCode,
//              "mobile_no": mobileNumber,
//              "device_id":routeData["device_id"],
//              "device_type":routeData["device_type"],
//              "facbook_id":routeData["facbook_id"]
//            });

    } else if (routeData["access"] == Constant.LoginByPhone) {
      print("----inside-1111---");
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _GetLoginPhone(mobileNumber);
      }
    }
  }

  Future<https.Response> _GetPhoneNumber(String mobile) async {
    try {
      print("##mobile----" +mobile);
      _showProgress(context);
      Map jsondata = {"mobile": mobile,"countrycode":countryCode.toString(),"latitude":_currentLocation.latitude.toString(),"longitude":_currentLocation.longitude.toString()};
      String url = WebServices.ValidePhoneNumber + "?language=${SessionManager.getString(Constant.Language_code)}";
      print('request body ==$jsondata');
      print("----url----"+url.toString());
      var res = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse1----" + res.body);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data["status"]&&data["otp"]!=false) {
          if(data["oldaccount"]) {

            Navigator.pushNamed(context, Constant.OtpRoute, arguments: {
              "countryCode": countryCode,
              "mobile_no": mobileNumber,
              "oldaccount":data["oldaccount"]
            });
          }
          else {
            Navigator.pushNamed(context, Constant.OtpRoute, arguments: {
              "countryCode": countryCode,
              "mobile_no": mobileNumber,
              "oldaccount":false,
              "access": routeData["access"],
              "device_id": routeData["device_id"],
              "facbook_id": routeData["facbook_id"],
              "device_type": routeData["device_type"],
              "from_reg":"1"
            });

            // Navigator.pushNamed(
            //     context, Constant.UserRegisterRoute, arguments: {
            //   "access": routeData["access"],
            //   "countryCode": countryCode,
            //   "mobile_no": mobileNumber,
            //   "device_id": routeData["device_id"],
            //   "facbook_id": routeData["facbook_id"],
            //   "device_type": routeData["device_type"],
            // });
          }
        } else {
          if (data["otp"]==false) {
            ShowDialogError.showDialogErrorMessage(context, "Alert Error", AppLocalizations.of(context).translate("Please try after 5 minutes")+"\n\nStatusCode : ${res.statusCode}", res.statusCode, '', MQ_Width, MQ_Height);
          }else {
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
      ShowDialogError.showDialogErrorMessage(context, "Exception Error", e.toString(), 0, 'error', MQ_Width, MQ_Height);
    }
  }

  Future<https.Response> _GetLoginPhone(String mobile) async {
    try {
      _showProgress(context);


      Map jsondata = {"mobile": mobile,"latitude":getPoint(true).toString(),"longitude":getPoint(false).toString()};
      print("##jsondata==== ${jsondata}");
      try
      {
          if(_currentLocation != null)
              jsondata = {"mobile": mobile,"latitude":_currentLocation.latitude.toString(),"longitude":_currentLocation.longitude.toString()};
      }catch(e){}
      
      print(jsondata);
      print(Uri.parse(WebServices.LoginMobile + "?language=${SessionManager.getString(Constant.Language_code)}"));
      var res = await https.post (Uri.parse(WebServices.LoginMobile + "?language=${SessionManager.getString(Constant.Language_code)}"),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse ### ==" + res.body);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data["status"]==true&&data["otp"]!=false) {
          Navigator.pushNamed(context, Constant.OtpRoute, arguments: {
            "countryCode": countryCode,
            "mobile_no": mobileNumber,
            "oldaccount":data["oldaccount"]
          });
        } else {
          if (data["otp"]==false) {

            ShowDialogError.showDialogErrorMessage(context, "Alert Error", AppLocalizations.of(context).translate("Please try after 5 minutes")+"\n\nStatusCode : ${res.statusCode}", res.statusCode, '', MQ_Width, MQ_Height);
          }else {
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
      }else if (res.statusCode == 500) {
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
        print("countrycode 22 :: "+placeMark.isoCountryCode);
        try {
          print("countrycode 22 _selectedFilteredDialogCountry country=${placeMark.country}\n country=${placeMark.country}");
          _selectedFilteredDialogCountry = CountryPickerUtils.getCountryByName('${placeMark.country}');
        }catch(error){
          print("countrycode 22 _selectedFilteredDialogCountry country catch error=${error} ");
          _selectedFilteredDialogCountry = CountryPickerUtils.getCountryByPhoneCode('49');
        }
        EnableCName=false;
         setState(() {});
  }
  catch (error) {
    print("countrycode 22 catch error :: "+error);
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

  _showProgress(BuildContext context) {
    setState(() {
      showLoading = true;
    });
    // progressDialog = new ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    // progressDialog.style(
    //     message: AppLocalizations.of(context).translate("Loading"),
    //     progressWidget: CircularProgressIndicator());
    // progressDialog.show();
  }

  _hideProgress() {
    setState(() {
      showLoading = false;
    });
  }
}
