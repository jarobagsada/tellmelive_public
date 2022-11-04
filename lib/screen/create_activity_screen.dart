import 'dart:convert';
// import 'package:translator/translator.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/utilmethod/fluttertoast_alert.dart';
import 'package:miumiu/utilmethod/helper.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/user.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:http/http.dart' as https;
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../utilmethod/showDialog_Error.dart';
import '../utilmethod/showDialog_success.dart';
import 'ActivityFromSettings.dart';

class Create_Activity extends StatefulWidget {
  @override
  _Create_ActivityState createState() => _Create_ActivityState();
}

class _Create_ActivityState extends State<Create_Activity> {
  File _image_file;
  final picker = ImagePicker();
  Size _screenSize;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController controller = new TextEditingController();
  TextEditingController categroy_controller = new TextEditingController();
  GlobalKey<FormState> _formkey = new GlobalKey();
  int hh,mm ;
  String title = "",
      location = "",
      theme = "",
      about_activity = "",
      categroy = "",
      subAdministrativeArea = "",
      administrativeArea = "",
      country = "";
  List<User> fav_list = [];
  bool _visible;

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Constant.kGoogleApiKey);
  FocusNode focusNode_theme, focusNode_themeDiscription;
  DateTime startDate, endDate;
  String startime,endtime;
  String ed,sd ;
  int _curentvalue =1;
  String sub ;
  TimeOfDay t1,t2 ;
// include<iostream.hN



  ProgressDialog progressDialog;
  var customFormat = DateFormat("dd-MM-yyyy");
  double latitude, longitude;

  var MQ_Height;
  var MQ_Width;
  DateTime _selectedStartDate,_selectedEndDate;
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
  void initState() {
    super.initState();
    _visible = false;
    focusNode_theme = FocusNode();
    focusNode_themeDiscription = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _ItemList();
      }
    });
  }

  @override
  void dispose() {
    focusNode_theme.dispose();
    focusNode_themeDiscription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _screenSize = MediaQuery.of(context).size;
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
        key: _scaffoldKey,

         body:Stack(children: [
         //  _widgetCreateActivity()
          _widgetNewUICreateActivity(),
         ],)

    ));
  }

  //============ Old UI Create Activity =======================
  Widget _widgetCreateActivity(){

    return Visibility(
      visible: _visible,
      replacement: Center(
        child: CircularProgressIndicator(),
      ),
      child: SingleChildScrollView(
        child: Container(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              Stack(


                clipBehavior: Clip.none,


                alignment: Alignment.bottomCenter,
                children:[



                  Image(
                    fit: BoxFit.fill,
                    image: AssetImage("assest/images/create_activity.png"),
                  ),
                  Positioned(
                    top: 90.0,
                    child: InkWell(
                      onTap: () {
                        // _showDialogBox();
                        _showModalBottomSheet(context)();

                      },
                      child: Container(

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
                        width: _screenSize.width,
                        height: 155,
                        child: _image_file == null
//                            ? Image.asset(
//                                "assest/images/camera.png",
//                                color: Custom_color.GreyLightColor,
//                              )
                            ? Image(image: AssetImage("assest/images/camera.png"))
                            : CircleAvatar(
                          backgroundColor: Custom_color.WhiteColor,
                          child: CircleAvatar(
                            backgroundImage: FileImage(_image_file),
                            backgroundColor: Colors.white,
                            radius: 90,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: IconButton(icon: Icon(
                        Icons.arrow_back_ios
                    ), onPressed: (){
                      Navigator.pop(context);
                    }),
                  ),


                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left :30,right: 30),
                child: Column(

                  children: <Widget>[

                    SizedBox(height: 50),
                    CustomWigdet.TextView(
                        text: AppLocalizations.of(context).translate("Create Activity"),
                        fontFamily: "Kelvetica Nobis",
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                    ),
//

                    Form(
                      key: _formkey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0,vertical: 45),
                        child: Column(
                          children: <Widget>[
                            TextFormField(



                              style: TextStyle(

                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(

                                focusColor: Color(0xffa9dff7),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),


                                contentPadding: EdgeInsets.all(12.0),
                                labelText: AppLocalizations.of(context)
                                    .translate("Title"),
                              ),

                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .translate("Empty title");
                                }
                              },
                              onSaved: (String val) {
                                title = val;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              onTap: () async {
                                Prediction p = await PlacesAutocomplete.show(
                                    offset: 0,
                                    radius: 1000,
                                    types: [],
                                    strictbounds: false,
                                    context: context,
                                    apiKey: Constant.kGoogleApiKey,
                                    mode: Mode.overlay,
                                    onError: (value) { print(value.errorMessage); },
                                    components: [] );
                                displayPrediction(p);
                              },
                              controller: controller,
                              readOnly: true,
                              enableInteractiveSelection: false,
                              style: TextStyle(
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12.0),
                                labelText: AppLocalizations.of(context)
                                    .translate("Location"),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .translate("Empty location");
                                }
                              },
                              onSaved: (String val) {
                                location = val;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              onTap: () {
                                _asyncConfirmDistances(context);
                              },
                              controller: categroy_controller,
                              readOnly: true,
                              enableInteractiveSelection: false,
                              style: TextStyle(
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12.0),
                                labelText: AppLocalizations.of(context)
                                    .translate("Categroy"),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .translate("Empty Categroy");
                                }
                              },

                            ),
//                          SizedBox(
//                            height: 10,
//                          ),
//                          TextFormField(
//                            focusNode: focusNode_theme,
//                            style: TextStyle(
//                                color: Custom_color.BlackTextColor,
//                                fontFamily: "OpenSans Regular",
//                                fontSize: 14),
//                            decoration: InputDecoration(
//                              contentPadding: EdgeInsets.all(0.0),
//                              labelText: AppLocalizations.of(context)
//                                  .translate("Activity Category"),
//                            ),
//                            keyboardType: TextInputType.text,
//                            validator: (value) {
//                              if (value.isEmpty) {
//                                return AppLocalizations.of(context)
//                                    .translate("Empty activity category");
//                              }
//                            },
//                            onSaved: (String val) {
//                              theme = val;
//                            },
//                          ),
                            SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: CustomWigdet.TextView(
                                  text: AppLocalizations.of(context)
                                      .translate("Select date of activity"),
                                  color: Custom_color.BlackTextColor,
                                  fontSize: 12,
                                  fontFamily: "OpenSans Bold"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(

                                  borderRadius: BorderRadius.circular(20),

                                  onTap: () {
                                    showPickerStartDate(context);
                                  },
                                  child: startDate == null ? Container(
                                    width: 135,
                                    height: 50,
                                    padding: EdgeInsets.only(
                                        top: 10, bottom: 10, left: 5, right: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Color(0xffe4e9ef),
                                            width: 1)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        CustomWigdet.TextView(
                                            text: AppLocalizations.of(context)
                                                .translate("Start Date"),
                                            color: Custom_color.BlackTextColor),
                                        SizedBox(
                                          width: MQ_Width*0.01,
                                        ),
                                        ImageIcon(AssetImage("assest/images/calendar_grey.png"),
                                          color: Custom_color.GreyLightColor,
                                          size: 20,

                                        )
                                      ],
                                    ),
                                  ) :Container(
                                    width: 135,
                                    height: 50,
                                    padding: EdgeInsets.only(
                                        top: 10, bottom: 10, left: 5, right: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Color(0xffa9dff5),  //    borderSide: BorderSide(color:,width: 2 )

                                            width: 2)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        CustomWigdet.TextView(
                                            text: "${customFormat.format(startDate)}",
                                            color: Custom_color.BlackTextColor),
                                        SizedBox(
                                          width: MQ_Width*0.01,
                                        ),
                                        Image(
                                          image: AssetImage("assest/images/calendar_blue.png"),



                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context)
                                        .translate("To"),
                                    color: Custom_color.BlackTextColor,
                                    fontWeight: Helper.textFontH4,
                                    fontSize: Helper.textSizeH14,
                                    fontFamily: "OpenSans Bold"),

                                InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      showPickerendDate(context);

                                    },
                                    child:
                                    endDate == null  ?
                                    Container(
                                      width: 135,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 15, right: 15),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffe4e9ef),
                                              width: 1)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: AppLocalizations.of(context)
                                                  .translate("End Date"),
                                              color: Custom_color.BlackTextColor),
                                          SizedBox(
                                            width: MQ_Width*0.01,
                                          ),
                                          ImageIcon(AssetImage("assest/images/calendar_grey.png"),
                                            color: Custom_color.GreyLightColor,
                                            size: 20,

                                          )
                                        ],
                                      ),
                                    ):Container(
                                      width: 135,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 5, right: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffa9dff5),
                                              width: 2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: "${customFormat.format(endDate)}",
                                              color: Custom_color.BlackTextColor),
                                          SizedBox(
                                            width: MQ_Width*0.01,
                                          ),
                                          Image( image :AssetImage("assest/images/calendar_blue.png"),

                                          )
                                        ],
                                      ),
                                    )
                                ),
                              ],
                            ),
                            SizedBox(height:MQ_Height*0.05),
                            Align(
                              alignment: Alignment.center,
                              child: CustomWigdet.TextView(
                                  text: AppLocalizations.of(context)
                                      .translate("Select time of activity"),
                                  color: Custom_color.BlackTextColor,
                                  fontSize: 12,
                                  fontFamily: "OpenSans Bold"),
                            ),
                            SizedBox(height:MQ_Height*0.03),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () async {  //Start time


                                      TimeOfDay ti =
                                      await
                                      showTimePicker(
                                          helpText: "",
                                          hourLabelText: AppLocalizations.of(context).translate("Hour").toUpperCase(),
                                          minuteLabelText: AppLocalizations.of(context).translate("Minute").toUpperCase(),
                                          cancelText: AppLocalizations.of(context).translate("Cancel").toUpperCase(),
                                          confirmText: AppLocalizations.of(context).translate("Confirm").toUpperCase(),
                                          initialEntryMode:TimePickerEntryMode.input,
                                          context: context,
                                          builder: (context, child) {
                                            final Widget mediaQueryWrapper = MediaQuery(
                                              data: MediaQuery.of(context).copyWith(
                                                alwaysUse24HourFormat: true,
                                              ),
                                              child: child,
                                            );
                                            // A hack to use the es_US dateTimeFormat value.
                                            if (Localizations.localeOf(context).languageCode == 'de') {
                                              return Localizations.override(
                                                context: context,
                                                locale: Locale('en', 'US'),
                                                child: mediaQueryWrapper,
                                              );
                                            }
                                            return mediaQueryWrapper;
                                          },
                                          initialTime: TimeOfDay(
                                              hour: 00, minute: 00));
                                      setState(() {

                                        hh=ti.hour;
                                        mm=ti.minute;

                                        if(hh<10){

                                          ed="0"+hh.toString();

                                        }
                                        else{
                                          ed=hh.toString();
                                        }
                                        if (mm<10){
                                          sd ="0"+mm.toString();
                                        }
                                        else{
                                          sd=mm.toString();
                                        }
                                        startime=ed+":"+sd ;
                                        print(startime);


                                      });

                                    },
                                    child: startime == null ? Container(
                                      width: 135,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 5, right: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffe4e9ef),
                                              width: 2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,

                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: AppLocalizations.of(context)
                                                  .translate("Start Time"),
                                              color: Custom_color.BlackTextColor),
                                          SizedBox(
                                            width: MQ_Width*0.01,
                                          ),
                                          Image( image :AssetImage("assest/images/clock_grey.png"),

                                          )
                                        ],
                                      ),
                                    ):Container(
                                      width: 135,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 5, right: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffa9dff5),
                                              width: 2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: startime,
                                              color: Custom_color.BlackTextColor),
                                          SizedBox(
                                            width: MQ_Width*0.01,
                                          ),
                                          Image( image :AssetImage("assest/images/clock_blue.png"),

                                          )
                                        ],
                                      ),
                                    )
                                ),
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context)
                                        .translate("To"),
                                    color: Custom_color.BlackTextColor,
                                    fontWeight: Helper.textFontH4,
                                    fontSize: Helper.textSizeH14,
                                    fontFamily: "OpenSans Bold"),
                                InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () async {
                                      TimeOfDay ti =
                                      await
                                      showTimePicker(
                                          helpText: "",
                                          hourLabelText: AppLocalizations.of(context).translate("Hour").toUpperCase(),
                                          minuteLabelText: AppLocalizations.of(context).translate("Minute").toUpperCase(),
                                          cancelText: AppLocalizations.of(context).translate("Cancel").toUpperCase(),
                                          confirmText: AppLocalizations.of(context).translate("Confirm").toUpperCase(),
                                          initialEntryMode:TimePickerEntryMode.input,
                                          context: context,
                                          builder: (context, child) {
                                            final Widget mediaQueryWrapper = MediaQuery(
                                              data: MediaQuery.of(context).copyWith(
                                                alwaysUse24HourFormat: true,
                                              ),
                                              child: child,
                                            );
                                            // A hack to use the es_US dateTimeFormat value.
                                            if (Localizations.localeOf(context).languageCode == 'de') {
                                              return Localizations.override(
                                                context: context,
                                                locale: Locale('en', 'US'),
                                                child: mediaQueryWrapper,
                                              );
                                            }
                                            return mediaQueryWrapper;
                                          },

                                          initialTime:  TimeOfDay(
                                              hour: 00, minute: 00));

                                      setState(() {


                                        hh=ti.hour;
                                        mm=ti.minute;

                                        if(hh<10){

                                          ed="0"+hh.toString();

                                        }
                                        else{
                                          ed=hh.toString();
                                        }

                                        if (mm<10){
                                          sd ="0"+mm.toString();
                                        }
                                        else{
                                          sd=mm.toString();
                                        }
                                        endtime=ed+":"+sd ;
                                      });

                                      print(endtime);

                                    },
                                    child: endtime == null?
                                    Container(
                                      width: 135,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 5, right: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffe4e9ef),
                                              width: 2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: AppLocalizations.of(context)
                                                  .translate("End Time"),
                                              color: Custom_color.BlackTextColor),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Image( image :AssetImage("assest/images/clock_grey.png"),

                                          )
                                        ],
                                      ),
                                    ):Container(
                                      width: 135,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 5, right: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffa9dff5),
                                              width: 2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: endtime,
                                              color: Custom_color.BlackTextColor),
                                          SizedBox(
                                            width: MQ_Width*0.01,
                                          ),
                                          Image( image :AssetImage("assest/images/clock_blue.png"),

                                          )
                                        ],
                                      ),
                                    )
                                )


                              ],
                            ),
                            SizedBox(
                              height: MQ_Height*0.03,
                            ),


                            TextFormField(
                              //  focusNode: focusNode_themeDiscription,
                              style: TextStyle(
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12.0),
                                labelText: AppLocalizations.of(context)
                                    .translate("People Limit (Optional)"),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {},
                              onSaved: (String value) {
                                sub = value;
                              },
                            ),

                            //TODO: _______________add a select maximum member button

                            SizedBox(
                              height: 10.0,
                            ),




                            TextFormField(
                              focusNode: focusNode_themeDiscription,
                              style: TextStyle(
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12.0),
                                labelText: AppLocalizations.of(context)
                                    .translate("About Activity"),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {},
                              onSaved: (String val) {
                                about_activity = val;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),


                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomWigdet.RoundOutlineFlatButton(

                        onPress: () async {
                          OnSubmit(context);
                        },
                        text: AppLocalizations.of(context)
                            .translate("Create"),
                        textColor: Custom_color.WhiteColor,
                        //bgcolor: Custom_color.BlueLightColor,
                        fontFamily: "Kelvetica Nobis"),

                    SizedBox(
                      height: 30,
                    )

                  ],

                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  //============ New UI Create Activity =======================
  Widget _widgetNewUICreateActivity(){

    return Visibility(
      visible: _visible,
      replacement: false?Center(
        child: CircularProgressIndicator(),
      ):Center(
        child: Container(
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
        ),
      ),
      child: SingleChildScrollView(
        child: Container(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children:[



                  Image(
                    fit: BoxFit.fill,
                    image:AssetImage("assest/images/blueimage.png"),// AssetImage("assest/images/create_activity.png"),
                  ),
                  Positioned(
                    top: 90.0,
                    child: InkWell(
                      onTap: () {
                        // _showDialogBox();
                        _showModalBottomSheet(context)();

                      },
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,

                              colors: [
                                // Color(0XFF8134AF),
                                // Color(0XFFDD2A7B),
                                // Color(0XFFFEDA77),
                                // Color(0XFFF58529),
                                Colors.purpleAccent.withOpacity(0.4),
                                Colors.pinkAccent.withOpacity(0.5),

                              ],
                            ),
                            shape: BoxShape.circle
                        ),
                        child: Container(
                          margin: EdgeInsets.all(10),
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
                          width: _screenSize.width,
                          height: 155,
                          child: _image_file == null
//                            ? Image.asset(
//                                "assest/images/camera.png",
//                                color: Custom_color.GreyLightColor,
//                              )
                              ?
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                            Container(
                              alignment: Alignment.center,
                                child: Image(image: AssetImage("assest/images/camera.png"))),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              alignment: Alignment.center,
                              child: Text(
                                AppLocalizations.of(context).translate("Upload Image"),
                              style: TextStyle(color:Color(Helper.textHintColorH3),
                                  fontWeight: Helper.textFontH4,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: Helper.textSizeH12,
                              letterSpacing: 0.5),),
                            )
                          ],): CircleAvatar(
                            backgroundColor: Custom_color.WhiteColor,
                            child: CircleAvatar(
                              backgroundImage: FileImage(_image_file),
                              backgroundColor: Colors.white,
                              radius: 90,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: IconButton(icon: Icon(
                        //Icons.arrow_back_ios
                      Icons.arrow_back,
                      color: Colors.white,
                    ), onPressed: (){
                      Navigator.pop(context);
                    }),
                  ),


                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left :30,right: 30),
                child: Column(

                  children: <Widget>[

                   // SizedBox(height: 50),
                    SizedBox(
                      height: MQ_Height*0.12,
                    ),
                    CustomWigdet.TextView(
                        text: AppLocalizations.of(context).translate("Create Activity"),
                        fontFamily: "Kelvetica Nobis",
                        fontSize: Helper.textSizeH9,
                        fontWeight: Helper.textFontH5,
                    ),
//
                    SizedBox(
                      height: MQ_Height*0.01,
                    ),
                    Form(
                      key: _formkey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0,vertical: 30),
                        child: Column(
                          children: <Widget>[
                            TextFormField(



                              style: TextStyle(

                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(

                                focusColor: Color(0xffa9dff7),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),


                                contentPadding: EdgeInsets.all(12.0),
                                labelText:  AppLocalizations.of(context).translate("Activity Title"),
                              //  AppLocalizations.of(context).translate("Title"),
                              ),

                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .translate("Empty title");
                                }
                              },
                              onSaved: (String val) {
                                title = val;
                              },
                            ),
                            SizedBox(
                              height: MQ_Height*0.02,
                            ),
                            TextFormField(
                              onTap: () async {
                                Prediction p = await PlacesAutocomplete.show(
                                    offset: 0,
                                    radius: 1000,
                                    types: [],
                                    strictbounds: false,
                                    context: context,
                                    apiKey: Constant.kGoogleApiKey,
                                    mode: Mode.overlay,
                                    onError: (value) { print(value.errorMessage); },
                                    components: [] );
                                displayPrediction(p);
                              },
                              controller: controller,
                              readOnly: true,
                              enableInteractiveSelection: false,
                              style: TextStyle(
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12.0),
                                labelText: AppLocalizations.of(context)
                                    .translate("Location"),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .translate("Empty location");
                                }
                              },
                              onSaved: (String val) {
                                location = val;
                              },
                            ),
                            SizedBox(
                              height: MQ_Height*0.02,
                            ),
                           true? TextFormField(
                              onTap: () {
                                _asyncConfirmDistances(context);
                              },
                              controller: categroy_controller,
                              readOnly: true,
                              enableInteractiveSelection: false,
                              style: TextStyle(
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12.0),
                                labelText: AppLocalizations.of(context)
                                    .translate("Categroy"),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .translate("Empty Categroy");
                                }
                              },

                            ):Container(),
//                          SizedBox(
//                            height: 10,
//                          ),
//                          TextFormField(
//                            focusNode: focusNode_theme,
//                            style: TextStyle(
//                                color: Custom_color.BlackTextColor,
//                                fontFamily: "OpenSans Regular",
//                                fontSize: 14),
//                            decoration: InputDecoration(
//                              contentPadding: EdgeInsets.all(0.0),
//                              labelText: AppLocalizations.of(context)
//                                  .translate("Activity Category"),
//                            ),
//                            keyboardType: TextInputType.text,
//                            validator: (value) {
//                              if (value.isEmpty) {
//                                return AppLocalizations.of(context)
//                                    .translate("Empty activity category");
//                              }
//                            },
//                            onSaved: (String val) {
//                              theme = val;
//                            },
//                          ),
                            SizedBox(
                              height: MQ_Height*0.03,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: CustomWigdet.TextView(
                                  text: AppLocalizations.of(context)
                                      .translate("Select date of activity"),
                                  color: Color(Helper.textColorBlackH1),
                                  fontSize: Helper.textSizeH14,
                                  fontWeight: Helper.textFontH4,
                                  fontFamily: "OpenSans Bold"),
                            ),
                            SizedBox(
                              height: MQ_Height*0.03,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(

                                  borderRadius: BorderRadius.circular(20),

                                  onTap: () {
                                    //showPickerStartDate(context);
                                    _ShowStartDatePick();
                                  },
                                  child: startDate == null ? Container(
                                    width: 140,
                                    height: 50,
                                    padding: EdgeInsets.only(
                                        top: 10, bottom: 10, left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Color(0xffe4e9ef),
                                            width: 1)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        CustomWigdet.TextView(
                                            text: AppLocalizations.of(context)
                                                .translate("Start Date"),
                                            color: Custom_color.BlackTextColor),
                                       SizedBox(width: MQ_Width*0.02),
                                        ImageIcon(AssetImage("assest/images/calendar_grey.png"),
                                          color: Custom_color.GreyLightColor,
                                          size: 20,

                                        )
                                      ],
                                    ),
                                  ) :Container(
                                    width: 140,
                                    height: 50,
                                    padding: EdgeInsets.only(
                                        top: 10, bottom: 10, left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Color(0xffa9dff5),  //    borderSide: BorderSide(color:,width: 2 )

                                            width: 2)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        CustomWigdet.TextView(
                                            text: "${customFormat.format(startDate)}",
                                            color: Custom_color.BlackTextColor),
                                        SizedBox(
                                          width: MQ_Width*0.01,
                                        ),
                                        Image(
                                          image: AssetImage("assest/images/calendar_blue.png"),



                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context)
                                        .translate("To"),
                                    color: Custom_color.BlackTextColor,
                                    fontFamily: "OpenSans Bold"),
                                InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      //showPickerendDate(context);
                                      _ShowEndDatePick();
                                    },
                                    child:
                                    endDate == null  ?
                                    Container(
                                      width: 140,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffe4e9ef),
                                              width: 1)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: AppLocalizations.of(context)
                                                  .translate("End Date"),
                                              color: Custom_color.BlackTextColor),
                                          SizedBox(width: MQ_Width*0.02),
                                          ImageIcon(AssetImage("assest/images/calendar_grey.png"),
                                            color: Custom_color.GreyLightColor,
                                            size: 20,

                                          )
                                        ],
                                      ),
                                    ) :Container(
                                      width: 140,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffa9dff5),
                                              width: 2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: "${customFormat.format(endDate)}",
                                              color: Custom_color.BlackTextColor),
                                          SizedBox(
                                            width: MQ_Width*0.01,
                                          ),
                                          Image( image :AssetImage("assest/images/calendar_blue.png"),

                                          )
                                        ],
                                      ),
                                    )
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MQ_Height*0.03,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: CustomWigdet.TextView(
                                  text: AppLocalizations.of(context)
                                      .translate("Select time of activity"),
                                  color: Color(Helper.textColorBlackH1),
                                  fontSize: Helper.textSizeH14,
                                  fontWeight: Helper.textFontH4,
                                  fontFamily: "OpenSans Bold"),
                            ),
                            SizedBox(
                              height: MQ_Height*0.03,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () async {  //Start time

                                      final theme = ThemeData.light().copyWith(

                                          timePickerTheme: TimePickerThemeData(
                                              backgroundColor: Colors.white,
                                              // Colors.green.shade200,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              /*hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                                              states.contains(MaterialState.selected)
                                                  ? Colors.red.withOpacity(0.2)
                                                  : Colors.amber),*/

                                              hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                                              states.contains(MaterialState.selected)
                                                  ? const Color(0xfffa4491)
                                                  : Colors.blue),

                                              dayPeriodBorderSide: const BorderSide(color: Colors.red,width: 5,),
                                              dayPeriodShape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                                side: BorderSide(color: Colors.orange, width: 4),
                                              ),
                                              hourMinuteShape: RoundedRectangleBorder(side: BorderSide(color: Colors.red,width: 5),
                                                  borderRadius: BorderRadius.circular(10)),
                                              inputDecorationTheme: const InputDecorationTheme(
                                                border:OutlineInputBorder(
                                                    borderSide: BorderSide(color: Color(0xfffa4491),width: 1.0),
                                                // borderRadius: BorderRadius.circular(20.0)
                                                ),//InputBorder.none,
                                                contentPadding: EdgeInsets.all(5),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(0xfffa4491),width: 2.0),
                                                  // borderRadius: BorderRadius.circular(20.0)
                                                ),
                                                disabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(0xfffa4491),width: 2.0),
                                                  // borderRadius: BorderRadius.circular(20.0)
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(0xfffa4491),width: 2.0),
                                                  // borderRadius: BorderRadius.circular(20.0)
                                                ),
                                                hintStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 16.0),
                                              ),


                                              dialHandColor: Color(0xfffa4491).withOpacity(0.8),
                                              dialBackgroundColor: Colors.purple.withOpacity(0.5),
                                              dialTextColor: MaterialStateColor.resolveWith((states) =>
                                              states.contains(MaterialState.selected)
                                                  ? Colors.green
                                                  : Colors.black),
                                              entryModeIconColor: Color(0xfffa4491)

                                          ),
                                        textTheme: TextTheme(
                                          overline: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20
                                           ),
                                        ),
                                          textButtonTheme: TextButtonThemeData(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateColor.resolveWith((states) => Color(0xfffa4491)),
                                                foregroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
                                               // overlayColor: MaterialStateColor.resolveWith((states) => Color(0xfffa4491)),
                                                overlayColor: MaterialStateColor.resolveWith((states) => Colors.cyan),


                                                shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(10) )),
                                                padding: MaterialStateProperty.all<EdgeInsets>(
                                                    EdgeInsets.all(15)),
                                              ),

                                          ),



                                      );




                                      TimeOfDay ti =
                                      await
                                      showTimePicker(
                                          helpText: "Set Time",
                                          hourLabelText: AppLocalizations.of(context).translate("Hour").toUpperCase(),
                                          minuteLabelText: AppLocalizations.of(context).translate("Minute").toUpperCase(),
                                          cancelText: AppLocalizations.of(context).translate("Cancel").toUpperCase(),
                                          confirmText: AppLocalizations.of(context).translate("Confirm").toUpperCase(),
                                          initialEntryMode:TimePickerEntryMode.input,
                                          context: context,
                                          builder: (context, child) {
                                            final Widget mediaQueryWrapper = MediaQuery(
                                                data: MediaQuery.of(context).copyWith(
                                                  alwaysUse24HourFormat: true,
                                                  textScaleFactor: 1.2,
                                                  //size: Size(MQ_Width, 600)
                                                ),
                                                child: Theme(
                                                  data: theme,
                                                  child: Container(
                                                    //  height: 450,
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
                                                      child: child),
                                                )
                                            );
                                            // A hack to use the es_US dateTimeFormat value.
                                            if (Localizations.localeOf(context).languageCode == 'de') {
                                              return Localizations.override(
                                                context: context,
                                                locale: Locale('en', 'US'),
                                                child: true?mediaQueryWrapper:Theme(
                                                  data: theme,
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
                                                      child: child),
                                                ),
                                              );
                                            }

                                            return true?mediaQueryWrapper: Theme(
                                              data: theme,
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
                                                  child: child),
                                            );

                                          },
                                          initialTime: TimeOfDay(
                                              hour: 00, minute: 00));
                                      setState(() {

                                        hh=ti.hour;
                                        mm=ti.minute;

                                        if(hh<10){

                                          ed="0"+hh.toString();

                                        }
                                        else{
                                          ed=hh.toString();
                                        }
                                        if (mm<10){
                                          sd ="0"+mm.toString();
                                        }
                                        else{
                                          sd=mm.toString();
                                        }
                                        startime=ed+":"+sd ;
                                        print(startime);


                                      });

                                    },
                                    child: startime == null ? Container(
                                      width: 135,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffe4e9ef),
                                              width: 2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,

                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: AppLocalizations.of(context)
                                                  .translate("Start Time"),
                                              color: Custom_color.BlackTextColor),

                                          SizedBox(
                                            width: MQ_Width*0.02,
                                          ),
                                          Image( image :AssetImage("assest/images/clock_grey.png"),

                                          )
                                        ],
                                      ),
                                    ):Container(
                                      width: 135,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffa9dff5),
                                              width: 2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: startime,
                                              color: Custom_color.BlackTextColor),

                                          SizedBox(
                                            width: MQ_Width*0.02,
                                          ),
                                          Image( image :AssetImage("assest/images/clock_blue.png"),

                                          )
                                        ],
                                      ),
                                    )
                                ),
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context)
                                        .translate("To"),
                                    color: Custom_color.BlackTextColor,
                                    fontFamily: "OpenSans Bold"),
                                InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () async {

                                      final theme = ThemeData.light().copyWith(

                                        timePickerTheme: TimePickerThemeData(
                                            backgroundColor: Colors.white,
                                            // Colors.green.shade200,

                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            /*hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                                              states.contains(MaterialState.selected)
                                                  ? Colors.red.withOpacity(0.2)
                                                  : Colors.amber),*/

                                            hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                                            states.contains(MaterialState.selected)
                                                ? const Color(0xfffa4491)
                                                : Colors.blue),

                                            dayPeriodBorderSide: const BorderSide(color: Colors.red,width: 5,),
                                            dayPeriodShape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              side: BorderSide(color: Colors.orange, width: 4),
                                            ),
                                            hourMinuteShape: RoundedRectangleBorder(side: BorderSide(color: Colors.red,width: 5),
                                                borderRadius: BorderRadius.circular(10)),
                                            inputDecorationTheme: const InputDecorationTheme(
                                              border:OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xfffa4491),width: 1.0),
                                                // borderRadius: BorderRadius.circular(20.0)
                                              ),//InputBorder.none,
                                              contentPadding: EdgeInsets.all(5),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xfffa4491),width: 2.0),
                                                // borderRadius: BorderRadius.circular(20.0)
                                              ),
                                              disabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xfffa4491),width: 2.0),
                                                // borderRadius: BorderRadius.circular(20.0)
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xfffa4491),width: 2.0),
                                                // borderRadius: BorderRadius.circular(20.0)
                                              ),
                                              hintStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 16.0),
                                            ),

                                            dialHandColor: Color(0xfffa4491).withOpacity(0.8),
                                            dialBackgroundColor: Colors.purple.withOpacity(0.5),
                                            dialTextColor: MaterialStateColor.resolveWith((states) =>
                                            states.contains(MaterialState.selected)
                                                ? Colors.green
                                                : Colors.black),
                                            entryModeIconColor: Color(0xfffa4491)

                                        ),
                                        textTheme: TextTheme(
                                          overline: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20

,                                          ),
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateColor.resolveWith((states) => Color(0xfffa4491)),
                                            foregroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
                                            // overlayColor: MaterialStateColor.resolveWith((states) => Color(0xfffa4491)),
                                            overlayColor: MaterialStateColor.resolveWith((states) => Colors.cyan),

                                            shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(10) )),
                                            padding: MaterialStateProperty.all<EdgeInsets>(
                                                EdgeInsets.all(15)),
                                          ),

                                        ),

                                      );


                                      TimeOfDay ti =
                                      await
                                      showTimePicker(
                                          helpText: "Set Time",
                                          hourLabelText: AppLocalizations.of(context).translate("Hour").toUpperCase(),
                                          minuteLabelText: AppLocalizations.of(context).translate("Minute").toUpperCase(),
                                          cancelText: AppLocalizations.of(context).translate("Cancel").toUpperCase(),
                                          confirmText: AppLocalizations.of(context).translate("Confirm").toUpperCase(),
                                          initialEntryMode:TimePickerEntryMode.input,
                                          context: context,
                                          builder: (context, child) {
                                            final Widget mediaQueryWrapper = MediaQuery(
                                              data: MediaQuery.of(context).copyWith(
                                                alwaysUse24HourFormat: true,
                                                textScaleFactor: 1.2,
                                               //size: Size(MQ_Width, 600)
                                              ),
                                              child: Theme(
                                                data: theme,
                                                child: Container(
                                                //  height: 450,
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
                                                    child: child),
                                              )
                                            );
                                            // A hack to use the es_US dateTimeFormat value.
                                            if (Localizations.localeOf(context).languageCode == 'de') {
                                              return Localizations.override(
                                                context: context,
                                                locale: Locale('en', 'US'),
                                                child: true?mediaQueryWrapper:Theme(
                                                  data: theme,
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
                                                      child: child),
                                                ),
                                              );
                                            }

                                            return true?mediaQueryWrapper:Theme(
                                              data: theme,
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
                                                  child: child),
                                            );
                                          },

                                          initialTime:  TimeOfDay(
                                              hour: 00, minute: 00));

                                      setState(() {


                                        hh=ti.hour;
                                        mm=ti.minute;

                                        if(hh<10){

                                          ed="0"+hh.toString();

                                        }
                                        else{
                                          ed=hh.toString();
                                        }

                                        if (mm<10){
                                          sd ="0"+mm.toString();
                                        }
                                        else{
                                          sd=mm.toString();
                                        }
                                        endtime=ed+":"+sd ;
                                      });

                                      print(endtime);

                                    },
                                    child: endtime == null?
                                    Container(
                                      width: 135,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffe4e9ef),
                                              width: 2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: AppLocalizations.of(context)
                                                  .translate("End Time"),
                                              color: Custom_color.BlackTextColor),
                                          SizedBox(
                                            width: MQ_Width*0.02,
                                          ),
                                          Image( image :AssetImage("assest/images/clock_grey.png"),

                                          )
                                        ],
                                      ),
                                    ):Container(
                                      width: 135,
                                      height: 50,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffa9dff5),
                                              width: 2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          CustomWigdet.TextView(
                                              text: endtime,
                                              color: Custom_color.BlackTextColor),
                                          SizedBox(
                                            width: MQ_Width*0.02,
                                          ),
                                          Image( image :AssetImage("assest/images/clock_blue.png"),

                                          )
                                        ],
                                      ),
                                    )
                                )


                              ],
                            ),
                            SizedBox(
                              height: MQ_Height*0.02,
                            ),


                            true?TextFormField(
                              //  focusNode: focusNode_themeDiscription,
                              style: TextStyle(
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12.0),
                                labelText: AppLocalizations.of(context)
                                    .translate("People Limit (Optional)"),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {},
                              onSaved: (String value) {
                                sub = value;
                              },
                            ):Container(),

                            //TODO: _______________add a select maximum member button

                            false?SizedBox(
                              height: MQ_Height*0.03,
                            ):Container(),




                            false?TextFormField(
                              focusNode: focusNode_themeDiscription,
                              style: TextStyle(
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12.0),
                                labelText: AppLocalizations.of(context)
                                    .translate("About Activity"),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {},
                              onSaved: (String val) {
                                about_activity = val;
                              },
                            ):Container(),

                            SizedBox(
                              height: MQ_Height*0.03,
                            ),




                            TextFormField(
                              focusNode: focusNode_themeDiscription,
                              maxLines: 4,
                              textAlign:TextAlign.start,

                              style: TextStyle(
                                  color: Custom_color.BlackTextColor,
                                  fontFamily: "OpenSans Regular",
                                  fontSize: 14),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Color(0xffe4e9ef),
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                labelText:AppLocalizations.of(context).translate("Description"),
                                //AppLocalizations.of(context).translate("Description"),

                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {},
                              onSaved: (String val) {
                                about_activity = val;
                              },
                            ),

                          ],
                        ),
                      ),


                    ),
                    SizedBox(
                      height: MQ_Height*0.01,
                    ),
                    CustomWigdet.RoundOutlineFlatButton(

                        onPress: () async {
                        OnSubmit(context);



                        },
                        text: AppLocalizations.of(context)
                            .translate("Create").toUpperCase(),
                        textColor: Custom_color.WhiteColor,
                        fontSize: Helper.textSizeH14,
                        fontWeight: Helper.textFontH4,
                        //bgcolor: Custom_color.BlueLightColor,
                        fontFamily: "Kelvetica Nobis"),

                    SizedBox(
                      height: MQ_Height*0.03,
                    ),

                  ],

                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  get _appbar {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0), // here the desired height
      child: AppBar(
        title: CustomWigdet.TextView(
            text: AppLocalizations.of(context).translate("Create Activity"),
            textAlign: TextAlign.center,
            color: Custom_color.WhiteColor,
            fontFamily: "OpenSans Bold"),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30))),
        leading: InkWell(
          borderRadius: BorderRadius.circular(30.0),
          child: Icon(
            Icons.arrow_back,
            color: Custom_color.WhiteColor,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<List<User>> _ItemList() async {

    try {
      if (fav_list != null && !fav_list.isEmpty) {
        fav_list.clear();
      }

      String url =
          WebServices.GetCatgroy + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          List userlist = data["category"];

          if (userlist != null && userlist.isNotEmpty) {
            fav_list = userlist.map<User>((i) => User.fromJson(i)).toList();
          }
        } else {
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }
        }

        setState(() {
          _visible = true;
        });
      }

      return fav_list;
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  _showDialogBox() {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          open_camera();
                          Navigator.pop(context);
                        },
                        child: CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("Take Photo from Camera"),
                            color: Custom_color.BlackTextColor,
                            fontFamily: "OpenSans Bold",
                            fontSize: 16)),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                        onTap: () {
                          open_gallery();
                          Navigator.pop(context);
                        },
                        child: CustomWigdet.TextView(
                            text: AppLocalizations.of(context)
                                .translate("Choose from Gallery"),
                            color: Custom_color.BlackTextColor,
                            fontFamily: "OpenSans Bold",
                            fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future _asyncConfirmDistances(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(fav_list.length, (index) {
                        var data = fav_list[index];
                        return ListTile(
                            title: new Row(
                          children: <Widget>[
                            new Expanded(child: new Text(data.name)),
                            new Checkbox(
                                value: data.ischeck,
                                onChanged: (bool value) {
                                  setState(() {
                                    data.ischeck = value;
                                  });
                                })
                          ],
                        ));
                      }),
                    ),
                    Material(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                        child: InkWell(
                          onTap: () {
                            _getListactiviyitem(fav_list);
                            Navigator.of(context).pop();
                          },
                          child: Ink(
                            decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                                color: Custom_color.BlueLightColor),
                            padding: EdgeInsets.all(10),
                            width: _screenSize.width,
                            child: CustomWigdet.TextView(
                              textAlign: TextAlign.center,
                              text: AppLocalizations.of(context)
                                  .translate("Submit"),
                              color: Custom_color.WhiteColor,
                              fontFamily: "OpenSans Bold",
                            ),
                          )),
                    )
//                    CustomWigdet.RoundRaisedButton(
//                        onPress: () {},
//                        text: AppLocalizations.of(context).translate("Submit"),
//                        textColor: Custom_color.WhiteColor,
//                        fontFamily: "OpenSans Bold",
//                        bgcolor: Custom_color.BlueLightColor),
                  ],
                )));
          },
        );
      },
    );
  }

  _getListactiviyitem(List<User> list) {
    var check = false;
    StringBuffer value = new StringBuffer();
    List<User>.generate(
        list.length, (index)
     {

      if (list[index].ischeck) {
        if (check) {
          value.write(", ");
          print(list[index].name);
        } else {
          check = true;
        }
        value.write(list[index].name);
        print(list);
      }
    });

    if (!UtilMethod.isStringNullOrBlank(value.toString()))
    {
      categroy = value.toString();
      categroy_controller.text = categroy;
    } else {
      categroy_controller.text = "";
      categroy = "";
    }
   // FocusScope.of(context).requestFocus(focusNode_theme);


  }




  Future open_camera() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.camera);

    // print("-----path-------" + pickedFile.path.toString());
    if (pickedFile != null && pickedFile.path != null) {
      _cropImage(pickedFile.path);
    }
  }

  Future open_gallery() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null && pickedFile.path != null) {
      _cropImage(pickedFile.path);
    }
  }

  _cropImage(String picked) async {
    File cropped = await ImageCropper().cropImage(
      compressQuality: 60,
      iosUiSettings: IOSUiSettings(
        // rotateButtonsHidden: true,
        // rotateClockwiseButtonHidden: true,
        // resetButtonHidden: true,
        aspectRatioLockDimensionSwapEnabled: true,
        aspectRatioLockEnabled: true,
        minimumAspectRatio: 1.0,
        title: AppLocalizations.of(context).translate("Crop Image"),
      ),
      androidUiSettings: AndroidUiSettings(
          hideBottomControls: false,
          statusBarColor: Custom_color.BlueDarkColor,
          toolbarColor: Custom_color.BlueLightColor,
          toolbarTitle: AppLocalizations.of(context).translate("Crop Image"),
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          showCropGrid: false),
      sourcePath: picked,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        //  CropAspectRatioPreset.original,
        //  CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio5x4,
        // CropAspectRatioPreset.ratio16x9
      ],
      maxWidth: 900,
    );
    if (cropped != null) {
      if (mounted) {
        setState(() {
          _image_file = cropped;
        });
      }
    }
  }


  _showModalBottomSheet(context) {
    showModalBottomSheet(context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context){
          return Container(
            decoration: BoxDecoration(
                color: Custom_color.WhiteColor,
                borderRadius: BorderRadius.circular(16)
            ),
            margin: EdgeInsets.symmetric(horizontal: 3,vertical: 8),
            padding: const EdgeInsets.all(6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  dense: true,
                  onTap: (){
                    open_camera();
                    Navigator.pop(context);
                  },
                  leading: Image.asset("assest/images/ar-camera.png",width: 26,height: 26,color: Custom_color.BlackTextColor,),
                  title:  CustomWigdet.TextView(
                      text: AppLocalizations.of(context)
                          .translate("Take Photo from Camera"),
                      color: Custom_color.BlackTextColor,
                      fontFamily: "OpenSans Bold",
                      fontSize: 16),
                ),
                ListTile(
                  dense: true,
                  onTap: (){
                    open_gallery();
                    Navigator.pop(context);
                  },
                  leading: Image.asset("assest/images/photo.png",width: 26,height: 26,color: Custom_color.BlackTextColor,),
                  title:  CustomWigdet.TextView(
                      text: AppLocalizations.of(context)
                          .translate("Choose from Gallery"),
                      color: Custom_color.BlackTextColor,
                      fontFamily: "OpenSans Bold",
                      fontSize: 16),
                ),
              ],
            ),
          );
        });
  }



  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      latitude = detail.result.geometry.location.lat;
      longitude = detail.result.geometry.location.lng;
      // var address = await Geocoder.local.findAddressesFromQuery(p.description);
      List<Placemark> placemark =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark placeMark = placemark[0];
      subAdministrativeArea = placeMark.subAdministrativeArea;
      administrativeArea = placeMark.administrativeArea;
      country = placeMark.country;

      print("----11-----" + p.description.toString());
      print("----lat--" + latitude.toString());
      print("-----log------" + longitude.toString());
      // setState(() {
      location = p.description.toString();
      controller.text = location;
      //  });
    }
  }

  Future<void> OnSubmit(BuildContext context) async {


    if (!this._formkey.currentState.validate()) {
      return;
    }

    _formkey.currentState.save(); // Save our form now.

    print('Printing the  data.');
    print('title: ${title}');
    print('location: ${location}');
    print("star time:  ${startime}");
    print("endtime : ${endtime}");
//    if (_image_file != null) {
    if (await UtilMethod.SimpleCheckInternetConnection(context, _scaffoldKey)) {
      if (startDate != null && endDate != null ) {
        //&& startime!= null 
        _showProgress(context);
        uploadImageByEvent();
      }

      else {
        UtilMethod.SnackBarMessage(_scaffoldKey,
            AppLocalizations.of(context).translate("Please select date"));
      }



    }
//    } else {
//      UtilMethod.SnackBarMessage(
//          _scaffoldKey,
//          AppLocalizations.of(context)
//              .translate("Please upload profile image"));
//    }
  }

  Future<void> uploadImageByEvent() async {
    try {
      String start_time =
          "${customFormat.format(startDate)}";
      String end_time = endDate == null ? "  " : customFormat.format(endDate) ;
          // "${customFormat.format(endDate)}";

      String t1 = startime == null ? " 00:00:00 ": startime ;
       String t2 = endtime == null ? " 23:59:59" : endtime ;   //Todo : Ahmad change
      Uri uri = Uri.parse(
          WebServices.CreateEvent + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}");
      var _request = https.MultipartRequest('POST', uri);

      if (_image_file != null) {
        _request.files.add(await https.MultipartFile.fromPath(
            'imageFile[]', _image_file.path));
      }

      int i = 0;
      List<String> data = [];
      List.generate(fav_list.length, (index) {
        if (fav_list[index].ischeck) {
          // data.add(categroy_id);

          _request.fields["categroy_id[${i++}]"] =
              fav_list[index].category_id.toString();
        }
      });

      _request.fields["title"] = title;

      _request.fields["location"] = location;
      _request.fields["latitude"] = latitude.toString();
      _request.fields["longitude"] = longitude.toString();
      _request.fields["city"] = administrativeArea.toString();
      _request.fields["state"] = subAdministrativeArea.toString();
      _request.fields["country"] = country.toString();
      _request.fields["start_time"]= start_time + " " + t1 ;
      _request.fields["end_time"]= end_time + " " + t2 ;
      _request.fields["comment"] = about_activity ?? "" ;
      _request.fields["subscriber"]= sub ?? "" ;

      print("------request11------" + _request.fields.toString() );
      print("------request--22----" + _request.files.toString() );
      print("------request----33--" + _request.toString() );

      var streamedResponse = await _request.send();
      https.Response res = await https.Response.fromStream(streamedResponse);
      print('response.body ## create Activity=' + res.statusCode.toString());
      print("-----respnse----" + res.body.toString());


      if (res.statusCode == 200) {
        _hideProgress();
        var bodydata = json.decode(res.body);
        if (bodydata["status"]) {
          Future.delayed(Duration(seconds: 1),(){

            ShowDialogSuccess.showDialogSuccessMessage(context, "Success", bodydata["message"]!=null?'${bodydata["message"]}':'Successfully Activity Create', 200, "CreateActivity", MQ_Width, MQ_Height);

          });



        } else {
        // UtilMethod.SnackBarMessage(_scaffoldKey, bodydata["message"]);

          _hideProgress();
          if (bodydata["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                    AppLocalizations.of(context).translate("Token Expire"));
          }else{
            ShowDialogError.showDialogErrorMessage(context, "Alert Error", bodydata["message"], res.statusCode, '', MQ_Width, MQ_Height);
          }
        }
      }else{
        _hideProgress();

        if(res.body.isNotEmpty) {
          var bodydata = json.decode(res.body);
        // FlutterToastAlert.flutterToastMSG('${bodydata["message"]}', context);
          ShowDialogError.showDialogErrorMessage(context, "Alert Error", bodydata["message"]+"\n\nStatusCode : "+ res.statusCode, res.statusCode, '', MQ_Width, MQ_Height);
        }else{
          ShowDialogError.showDialogErrorMessage(context, "Alert Error", "Data response is empty !"+"\n\nStatusCode : ${res.statusCode}", res.statusCode, '', MQ_Width, MQ_Height);
        }
      }
    } on Expanded catch (e) {
      print(e.toString());
     // UtilMethod.SnackBarMessage(_scaffoldKey, '${e}');
      FlutterToastAlert.flutterToastMSG('$e', context);
      _hideProgress();
    }
  }

//  await DatePicker.showSimpleDatePicker(
//  context,
//  initialDate: DateTime.now(),
//  firstDate:DateTime.now().subtract(Duration(days: 366)),
//  lastDate:DateTime.now(),
//  dateFormat: "dd-MMMM-yyyy",
//  locale: DateTimePickerLocale.en_us,
//  looping: true,
//  );

  //=================== Old UI Show Start Date Picker ================

  Future<Null> showPickerStartDate(BuildContext context) async {
//    DateTime.now().subtract(Duration(days: 366)
    final DateTime picked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: (5 * 366))),
      dateFormat: "dd-MMMM-yyyy",
      locale: SessionManager.getString(Constant.Language_code)=="en"? DateTimePickerLocale.en_us: SessionManager.getString(Constant.Language_code)=="de"?
      DateTimePickerLocale.de: SessionManager.getString(Constant.Language_code)=="ar"? DateTimePickerLocale.ar: DateTimePickerLocale.tr,
      titleText: AppLocalizations.of(context).translate("Select Date"),
      cancelText: AppLocalizations.of(context).translate("Cancel"),
      confirmText: AppLocalizations.of(context).translate("Ok"),
     // textColor: Colors.pinkAccent,
      //backgroundColor: Colors.pink.withOpacity(0.3),
      pickerMode: DateTimePickerMode.datetime,
      looping: true,
    );

    // print(DateFormat.Hms().format(DateTime.now())); // print time

    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked;
       //  endDate = null;
        print("----datedage---" + picked.toString());
      });
    DateTimePickerTheme(
      backgroundColor: Colors.transparent,
      itemTextStyle:
      TextStyle(color: Colors.white, fontSize: 19),
      dividerColor: Colors.red,
    );
   // FocusScope.of(context).requestFocus(focusNode_themeDiscription);

  }
//============== New UI Show Start Date Picker ============

   Future<void> _ShowStartDatePick()async{

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
                             initialDate: DateTime.now(),
                             firstDate: DateTime.now(),
                             lastDate: DateTime.now().add(Duration(days: (5 * 366))),
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
                                         if(_selectedStartDate==null){
                                           startDate =DateTime.now();
                                         }else{
                                           startDate =_selectedStartDate;
                                         }
                                       });

                                       Navigator.of(context).pop();
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

//================= Old UI Show End Date Picker ===============

  Future<Null> showPickerendDate(BuildContext context) async {


    final DateTime picked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(Duration(days: (5 * 366))),
      dateFormat: "dd-MMMM-yyyy",
      locale: SessionManager.getString(Constant.Language_code)=="en"? DateTimePickerLocale.en_us: SessionManager.getString(Constant.Language_code)=="de"? DateTimePickerLocale.de: SessionManager.getString(Constant.Language_code)=="ar"? DateTimePickerLocale.ar: DateTimePickerLocale.tr,
      titleText: AppLocalizations.of(context).translate("Select Date"),
      cancelText: AppLocalizations.of(context).translate("Cancel"),
      confirmText: AppLocalizations.of(context).translate("Ok"),
      looping: true,
    );

    if (picked != null && picked != endDate)
      setState(() {
        endDate = picked;
        //  endDate = null;
        print("----datedage---" + picked.toString());
      });
   // FocusScope.of(context).requestFocus(focusNode_themeDiscription);
  }

  //============== New UI Show End Date Picker ============

    Future<void> _ShowEndDatePick()async{

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
                                initialDate: startDate,
                                firstDate: startDate,
                                lastDate: DateTime.now().add(Duration(days: (5 * 366))),
                                dateFormat: "dd-MMMM-yyyy",
                                locale: SessionManager.getString(Constant.Language_code)=="en"? DateTimePickerLocale.en_us: SessionManager.getString(Constant.Language_code)=="de"? DateTimePickerLocale.de: SessionManager.getString(Constant.Language_code)=="ar"? DateTimePickerLocale.ar: DateTimePickerLocale.tr,

                                // titleText: AppLocalizations.of(context).translate("Select Date"),
                                onChange: (DateTime newDate, _)async {
                                  setState(() {
                                    _selectedEndDate = newDate;
                                   // endDate = newDate;
                                  });
                                  print(_selectedEndDate);
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
                                            if(_selectedEndDate==null&&startDate==null){
                                              endDate =DateTime.now();
                                            }else if(_selectedEndDate==null&&startDate!=null){
                                              endDate =startDate;
                                            }else{
                                              endDate =_selectedEndDate;
                                            }
                                          });

                                          Navigator.of(context).pop();
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



  _showProgress1(BuildContext context) {
    progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    progressDialog.style(
        message: AppLocalizations.of(context).translate("Loading"),
        progressWidget: CircularProgressIndicator());
    //progressDialog.show();
  }
  _showProgress(BuildContext context) {
    print("from :: ");

    /* progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    progressDialog.style(
        message: AppLocalizations.of(context).translate("Loading"),
        progressWidget: false?CircularProgressIndicator():
        Center(
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
                    indicatorType: Indicator.lineScalePulseOut,
                    colors: _kDefaultRainbowColors,
                    strokeWidth: 2.0,
                    pathBackgroundColor:Colors.black45,
                    // showPathBackground ? Colors.black45 : null,
                  ),
                ),
              ),
            ),
          ),
        )
    );*/
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
        padding: EdgeInsets.only(left:
        MQ_Width*0.30,right: MQ_Width*0.20),
        child: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            /* decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xfff16cae).withOpacity(0.3),
                  Color(0xff3f86c6).withOpacity(0.3),
                ],
              )
          ),*/
            child: Center(
              child: Container(
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
            ),
          ),
        )
    );
    /*progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: true,

      /// your body here
      customBody: false?LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        backgroundColor: Colors.white,
        minHeight: 10,
      ): Center(
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
        ),
      ),
    );*/


    progressDialog.show();
  }

  _hideProgress() {
    if (progressDialog != null) {
      progressDialog.hide();
    }
  }
}
