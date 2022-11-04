import 'dart:convert';
// import 'package:translator/translator.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:miumiu/screen/holder/activity_list_holder.dart';
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

class Edit_Activity extends StatefulWidget {
 //  get initialValue => null;

  @override
  _Edit_ActivityState createState() => _Edit_ActivityState();
}

class _Edit_ActivityState extends State<Edit_Activity> {
  File _image_file;
  final picker = ImagePicker();
  Size _screenSize;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  TextEditingController categroy_controller =  TextEditingController();
  TextEditingController categroy_controller2 =  TextEditingController();
  GlobalKey<FormState> _formkey = new GlobalKey();
  int hh,mm ;
  String title = "",
      location = "",
  new_location = "",
      theme = "",
      about_activity = "",
      categroy = "",
      subAdministrativeArea = "",
      administrativeArea = "",
      country = "";
  List<User> fav_list = [];
  bool _visible;
  var routeData;
  bool loading;
  var
      image = "",
  pp ,
  tt,

      interest,
      interest_desp,
      comment,
      start_time,
      end_time,
      t1,
      t2,
      end_time_first,
      end_time_second,
      suscribedcount,
      subscriber_allowed_count,
      action = "",
      storedata;
  int active ;



  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Constant.kGoogleApiKey);
  FocusNode focusNode_theme, focusNode_themeDiscription, _focusNode, _focusNodeCategory;
  DateTime startDate, endDate;
  String startime,endtime;
  String ed,sd ;
  int _curentvalue =1;
  String sub ;
 //  TimeOfDay t1,t2 ;
// include<iostream.hN


  ProgressDialog progressDialog;
  List<User> categroy_list = [];
  var customFormat = DateFormat("dd-MM-yyyy");
  double latitude, longitude;
  double lt,ln ;

  int i;


  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      routeData = ModalRoute.of(context).settings.arguments;
      action = routeData["action"];
    //  GetEventUser(routeData["event_id"].toString());
      print("------route-------" + routeData.toString());





    });
    loading = false;
  //   _visible= false ;
    super.initState();
    _visible = false;
    _focusNodeCategory = FocusNode();
    _focusNodeCategory.addListener(() {

      if(_focusNodeCategory.hasFocus) categroy_controller.clear();
    });


    // _focusNode = FocusNode();
    // _focusNode.addListener(() {
    //  if(_focusNode.hasFocus) {controller.clear();
    //  }
    // });
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
    GetEventUser(routeData);
    controller2.text = location ;
    categroy_controller2.text = _getListcategroyitem(categroy_list);



  // setState(() {
  //   controller = TextEditingController(text: location) ;
  // });

  //  categroy_controller =TextEditingController(text: _getListcategroyitem(categroy_list) );




    _screenSize = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,

          body: Visibility(
            visible: loading,
            replacement: Center(
              child: CircularProgressIndicator(),
            ),
            child: SingleChildScrollView(
              child: Container(



                child: Column(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
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
                                      border: Border.all(
                                          color: Custom_color.GreyLightColor,
                                          width: 0.5)),
                                  width: _screenSize.width,
                                  height: 150,
                                  child: _image_file == null
//                            ? Image.asset(
//                                "assest/images/camera.png",
//                                color: Custom_color.GreyLightColor,
//                              )
                                      ?
                                  CircleAvatar(
                                    backgroundColor: Custom_color.WhiteColor,
                                    child: CircleAvatar(
                                      backgroundImage: image==null||image==""?
                                      AssetImage("assest/images/camera.png"):
                                          NetworkImage(image,scale: 1.0)
                                      ,
                                      backgroundColor: Colors.white,
                                      radius: 90,
                                    ),
                                  )
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
                        SizedBox(
                          height: 40,
                        ),
                        Form(
                          key: _formkey,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16,top: 30),
                            child: Column(


                              children: <Widget>

                              [
                                TextFormField(
                                  initialValue: title,
                                  style: TextStyle(
                                      color: Custom_color.BlackTextColor,
                                      fontFamily: "OpenSans Regular",
                                      fontSize: 14),
                                  decoration: InputDecoration(
                                    focusColor: Color(0xffa9dff7),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                    ),

                                    border: OutlineInputBorder(


                                    ),
                                    contentPadding: EdgeInsets.all(12.0),
                                    labelText: AppLocalizations.of(context)
                                        .translate("Title"),
                                  ),
                                  keyboardType: TextInputType.text,

                                  onSaved: (String val) {
                                    title = val;
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(


                                  focusNode: _focusNode,



                                    // initialValue: location,




                                     // key: Key(widget.initialValue),


                                  onTap: () async {
                                      pp = 1;
                                      print(controller.text);
                                      Prediction p = await PlacesAutocomplete.show(
                                        context: context,
                                        apiKey: Constant.kGoogleApiKey);
                                    displayPrediction(p);

                                    },
                                  controller: pp == 1 ?controller:controller2,




                                  readOnly: true,
                                  enableInteractiveSelection: false,
                                  style: TextStyle(
                                      color: Custom_color.BlackTextColor,
                                      fontFamily: "OpenSans Regular",
                                      fontSize: 14),
                                  decoration: InputDecoration(

                                    focusColor: Color(0xffa9dff7),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                    ),

                                    border: OutlineInputBorder(


                                    ),
                                    contentPadding: EdgeInsets.all(12.0),
                                    labelText: AppLocalizations.of(context)
                                        .translate("Location"),
                                  ),
                                  keyboardType: TextInputType.text,


                                  onSaved: (String val) {



                                    location = val ;
                                   // controller  =TextEditingController(text: location);

                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  autofocus: true,
                                  //  initialValue: _getListcategroyitem(categroy_list) ,
                                  onTap: () async {
                                    tt=1;

                                    _asyncConfirmDistances(context);
                                  },
                                //  controller: TextEditingController(text:  _getListcategroyitem(categroy_list)),
                                  readOnly: true,
                                  controller: tt==1?categroy_controller:categroy_controller2,

                                  enableInteractiveSelection: false,
                                  style: TextStyle(
                                      color: Custom_color.BlackTextColor,
                                      fontFamily: "OpenSans Regular",
                                      fontSize: 14),

                                  decoration: InputDecoration(

                                    focusColor: Color(0xffa9dff7),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                    ),

                                    border: OutlineInputBorder(


                                    ),
                                    contentPadding: EdgeInsets.all(12.0),
                                    labelText: AppLocalizations.of(context)
                                        .translate("Category"),
                                  ),
                                  keyboardType: TextInputType.text,



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
                                        i = 1 ;


                                      },
                                      child: startDate == null?
                                      Container(
                                        width: 135,
                                        height: 50,
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10, left: 15, right: 15),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Color(0xffa9dff5),  //    borderSide: BorderSide(color:,width: 2 )

                                                width: 2)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,

                                          children: <Widget>[
                                            CustomWigdet.TextView(
                                                text:start_time==null|| start_time==""?
                                                AppLocalizations.of(context).translate("Start Date") :start_time ,
                                                //  text: "${customFormat.format(startDate)}",
                                                color: Custom_color.BlackTextColor),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Image(
                                              image: AssetImage("assest/images/calendar_blue.png"),



                                            )
                                          ],
                                        ),
                                      ) :
                                      Container(
                                        width: 135,
                                        height: 50,
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10, left: 15, right: 15),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Color(0xffa9dff5),  //    borderSide: BorderSide(color:,width: 2 )

                                                width: 2)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            CustomWigdet.TextView(
                                              text: i==1?"${customFormat.format(startDate)}":
                                                  start_time,
                                              //  text: "${customFormat.format(startDate)}",
                                                color: Custom_color.BlackTextColor),
                                            SizedBox(
                                              width: 10,
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
                                                  color: Color(0xffa9dff5),
                                                  width: 2)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,

                                            children: <Widget>[
                                              CustomWigdet.TextView(
                                                  text: end_time==null || end_time==""?
                                                  AppLocalizations.of(context).translate("End Date") :
                                                  end_time,
                                                  color: Custom_color.BlackTextColor),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Image( image :AssetImage("assest/images/calendar_blue.png"),

                                              )
                                            ],
                                          ),
                                        ):Container(
                                          width: 135,
                                          height: 50,
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 10, left: 15, right: 15),
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
                                                width: 10,
                                              ),
                                              Image( image :AssetImage("assest/images/calendar_blue.png"),

                                              )
                                            ],
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Align(
                                  alignment: Alignment.center,
                                  child: CustomWigdet.TextView(
                                      text: AppLocalizations.of(context)
                                          .translate("Select time of activity"),
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
                                        onTap: () async {  //Start time


                                          TimeOfDay ti =
                                          await
                                          showTimePicker(
                                              confirmText: "Confirm",
                                              context: context,
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
                                          height: 50,
                                          width: 135,
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 10, left: 15, right: 15),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Color(0xffa9dff5),
                                                  width: 2)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              CustomWigdet.TextView(
                                                  text: t1==null || t1 ==""?
                                                  AppLocalizations.of(context).translate("Start Date"):
                                                  t1,
                                                  color: Custom_color.BlackTextColor),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Image( image :AssetImage("assest/images/clock_blue.png"),

                                              )
                                            ],
                                          ),
                                        ):Container(
                                          height: 50,
                                          width: 135,
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 10, left: 15, right: 15),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Color(0xffa9dff5),
                                                  width: 2)),
                                          child: Row(
                                            children: <Widget>[
                                              CustomWigdet.TextView(
                                                  text: startime,
                                                  color: Custom_color.BlackTextColor),
                                              SizedBox(
                                                width: 10,
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


                                          TimeOfDay ti =
                                          await
                                          showTimePicker(
                                              confirmText: "Confirm",
                                              context: context,

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
                                          height: 50,
                                          width: 135,
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 10, left: 15, right: 15),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Color(0xffa9dff5),
                                                  width: 2)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,

                                            children: <Widget>[
                                              CustomWigdet.TextView(
                                                  text: t2 == null ||  t2 ==""?
                                                  AppLocalizations.of(context).translate("End Date"):
                                                  t2
                                                  ,
                                                  color: Custom_color.BlackTextColor),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Image( image :AssetImage("assest/images/clock_blue.png"),

                                              )
                                            ],
                                          ),
                                        ):Container(
                                          height: 50,
                                          width:135,
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 10, left: 15, right: 15),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Color(0xffa9dff5),
                                                  width: 2)),
                                          child: Row(
                                            children: <Widget>[
                                              CustomWigdet.TextView(
                                                  text: endtime,
                                                  color: Custom_color.BlackTextColor),
                                              SizedBox(
                                                width: 10,
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
                                  height: 10,
                                ),


                                TextFormField(initialValue:  subscriber_allowed_count ,
                                  //  focusNode: focusNode_themeDiscription,
                                  style: TextStyle(
                                      color: Custom_color.BlackTextColor,
                                      fontFamily: "OpenSans Regular",
                                      fontSize: 14),
                                  decoration: InputDecoration(
                                    focusColor: Color(0xffa9dff7),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                    ),

                                    border: OutlineInputBorder(


                                    ),
                                    contentPadding: EdgeInsets.all(12.0),
                                    labelText: AppLocalizations.of(context)
                                        .translate("People Limit (Optional)"),
                                  ),
                                  keyboardType: TextInputType.number,

                                  onSaved: (String value) {
                                    sub = value;
                                  },
                                ),

                                //TODO: _______________add a select maximum member button

                                SizedBox(
                                  height: 10.0,
                                ),




                                TextFormField(
                                  initialValue: comment,
                                  focusNode: focusNode_themeDiscription,
                                  style: TextStyle(
                                      color: Custom_color.BlackTextColor,
                                      fontFamily: "OpenSans Regular",
                                      fontSize: 14),
                                  decoration: InputDecoration(
                                    focusColor: Color(0xffa9dff7),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color:Color(0xffa9dff5),width: 2 )

                                    ),

                                    border: OutlineInputBorder(


                                    ),
                                    contentPadding: EdgeInsets.all(12.0),
                                    labelText: AppLocalizations.of(context)
                                        .translate("About Activity"),
                                  ),
                                  keyboardType: TextInputType.text,

                                  onSaved: (String val) {
                                    about_activity = val;
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                CustomWigdet.RoundRaisedButton(
                                    onPress: () async {
                                      OnSubmit(context);
                                    //  Navigator.pop(context);
                                    },
                                    text: AppLocalizations.of(context)
                                        .translate("Save")
                                        .toUpperCase(),
                                    textColor: Custom_color.WhiteColor,
                                    bgcolor: Custom_color.BlueLightColor,
                                    fontFamily: "OpenSans Bold"),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),


                  ],
                ),
              ),
            ),
          ),
        ));
  }

  get _appbar {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0), // here the desired height
      child: AppBar(
        title: CustomWigdet.TextView(
            text: AppLocalizations.of(context).translate("Edit Activity"),
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
    List<User>.generate(list.length, (index) {
      if (list[index].ischeck) {
        if (check) {
          value.write(", ");
        } else {
          check = true;
        }
        value.write(list[index].name);
      }
    });

    if (!UtilMethod.isStringNullOrBlank(value.toString())) {
      categroy = value.toString();
      categroy_controller.text = categroy;
    } else {
      categroy_controller.text = "";
      categroy = "";
    }
    //FocusScope.of(context).requestFocus(focusNode_theme);
    Navigator.pop(context);
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
      new_location = p.description.toString();

      controller.text = new_location;
      //  });
    }
  }

  Future<void> OnSubmit(BuildContext context) async {
//    Navigator.of(context).pushNamedAndRemoveUntil(
//        Constant.NavigationRoute, (Route<dynamic> route) => true,arguments: {"selectTab":2});

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

        _showProgress(context);
        uploadImageByEvent();






    }
//    } else {
//      UtilMethod.SnackBarMessage(
//          _scaffoldKey,
//          AppLocalizations.of(context)
//              .translate("Please upload profile image"));
//    }
  }

   Future<void> uploadImageByEvent() async
   {
    try {
      String start_time = startDate ==  null ? " " :customFormat.format(startDate);
      String end_time = endDate == null ? "  " : customFormat.format(endDate) ;
      // "${customFormat.format(endDate)}";

      String t1 = startime == null ? " 00:00 ": startime ;
      String t2 = endtime == null ? " " : endtime ;
      // title = title == null ? " ": title ;
      // location = location == null ? " " : location ;
      // categroy = categroy == null ? " " : categroy;
      // subscriber_allowed_count = subscriber_allowed_count == null ? " " : subscriber_allowed_count ;
      // comment = about_activity == null ? " " : about_activity ;
      //  Todo : Ahmad change
      String event_id = routeData ;

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
      latitude==null?
          _request.fields["latitude"] = lt.toString() :
          _request.fields["latitude"] = latitude.toString() ;
      longitude==null?
      _request.fields["longitude"] = ln.toString() :
      _request.fields["longitude"] = longitude.toString() ;

      // _request.fields["latitude"] = latitude == null ? lt : latitude.toString();
      // _request.fields["longitude"] = longitude == null ? ln : longitude.toString();
      _request.fields["city"] = administrativeArea.toString();
      _request.fields["state"] = subAdministrativeArea.toString();
      _request.fields["country"] = country.toString();
      _request.fields["start_time"]= start_time + " " + t1 ;
      _request.fields["end_time"]= end_time + " " + t2 ;
      _request.fields["event_id"]=  event_id ;

      // if(t1==null){
      //   t1= "00:00" ;
      //
      //   _request.fields["start_time"]=start_time + " " + t1 ;
      // }
      // else{
      //   _request.fields["start_time"] = start_time + " " +t1 ;
      // }
      //
      // // _request.fields["start_time"] = start_time + "  " + t1 == null ? " 00:00 " : t1 ;
      // if(end_time==null && t2 ==null){
      //   t2 = " 00:00 " ;
      //   end_time = " " ;
      //   _request.fields["end_time"] = end_time +  " " + t2 ;
      // }
      // else{
      //
      //   _request.fields["end_time"] = end_time + " " +t2;
      // }

      _request.fields["comment"] = about_activity  ;
      _request.fields["subscriber"]= sub  ;

      print("------request11------" + _request.fields.toString() );
      print("------request--22----" + _request.files.toString() );
      print("------request----33--" + _request.toString() );

      var streamedResponse = await _request.send();
      https.Response res = await https.Response.fromStream(streamedResponse);
      print('response.body ' + res.statusCode.toString());
      print("-----respnse----" + res.body.toString());
      _hideProgress();

      if (res.statusCode == 200) {
        var bodydata = json.decode(res.body);
        if (bodydata["status"]) {
//          Navigator.pushReplacementNamed(
//              context, Constant.ChatUserActivityList);
          Navigator.pop(context,Constant.Activity);
        } else {
          if (bodydata["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                AppLocalizations.of(context).translate("Token Expire"));
          }
        }
      }
    } on Expanded catch (e) {
      print(e.toString());
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

  Future<https.Response> GetEventUser(String id) async {
    try {
      Map jsondata = {"event_id": id};
      String url = WebServices.GetEventByUser +
          SessionManager.getString(Constant.Token) +
          "&language=${SessionManager.getString(Constant.Language_code)}" + "&event_id="+id;
   //   print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
     // print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          storedata = data["data"];
          title = data["data"]["title"];
          image = data["data"]["image"];
          location = data["data"]["location"];
          interest = data["data"]["interest"];
          active = data["data"]["active"];
          interest_desp = data["data"]["interest_desp"];
          comment = data["data"]["comment"];
          start_time = data["data"]["start_time"];
          end_time = data["data"]["end_time"];
          t1 = data["data"]["startime"];
          t2 = data["data"]["endtime"];
          lt = data["latitude"];
          ln = data["longitude"];
          suscribedcount = data["data"]["suscribedcount"];
          subscriber_allowed_count = data["data"]["subscriber_allowed_count"];
          List userlist = data["data"]["category"];

          if (userlist != null && userlist.isNotEmpty) {
            categroy_list =
                userlist.map<User>((i) => User.fromJson(i)).toList();
          }
          //  GetDate(end_time);

//          Navigator.pushNamed(
//            context,
//            Constant.ActivityRoute,
//          );

            setState(() {
              loading = true;
            });

        }
        if (data["is_expire"] == Constant.Token_Expire) {
          UtilMethod.showSimpleAlert(
              context: context,
              heading: AppLocalizations.of(context).translate("Alert"),
              message: AppLocalizations.of(context).translate("Token Expire"));
        }
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
  Future<Null> showPickerStartDate(BuildContext context) async {
//    DateTime.now().subtract(Duration(days: 366)
    final DateTime picked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: (5 * 366))),
      dateFormat: "dd-MMMM-yyyy",
      locale: SessionManager.getString(Constant.Language_code)=="en"? DateTimePickerLocale.en_us: SessionManager.getString(Constant.Language_code)=="de"? DateTimePickerLocale.de: SessionManager.getString(Constant.Language_code)=="ar"? DateTimePickerLocale.ar: DateTimePickerLocale.tr,
      titleText: AppLocalizations.of(context).translate("Select Date"),
      cancelText: AppLocalizations.of(context).translate("Cancel"),
      confirmText: AppLocalizations.of(context).translate("Ok"),
      looping: true,
    );

    // print(DateFormat.Hms().format(DateTime.now())); // print time

    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked;
        //  endDate = null;
        print("----datedage---" + picked.toString());
      });
    FocusScope.of(context).requestFocus(focusNode_themeDiscription);
  }

  Future<Null> showPickerendDate(BuildContext context) async {
//    final DateTime picked = await DatePicker.showSimpleDatePicker(
//      context,
//      initialDate: DateTime.now(),
//      firstDate: DateTime.now(),
//      lastDate: DateTime.now().add(Duration(days: (5 * 366))),
//      dateFormat: "dd-MMMM-yyyy",
//      locale: DateTimePickerLocale.en_us,
//      looping: true,
//    );

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
    FocusScope.of(context).requestFocus(focusNode_themeDiscription);
  }

  _showProgress(BuildContext context) {
    progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    progressDialog.style(
        message: AppLocalizations.of(context).translate("Loading"),
        progressWidget: CircularProgressIndicator());
    //progressDialog.show();
  }

  _hideProgress() {
    if (progressDialog != null) {
      progressDialog.hide();
    }
  }
  String _getListcategroyitem(List<User> list) {
    StringBuffer value = new StringBuffer();
    List<User>.generate(list.length, (index) {
      {
        value.write(list[index].name);
        if ((list.length) == (index + 1)) {
        } else {
          value.write(", ");
        }
      }
    });

    //value.writeln()
    return !UtilMethod.isStringNullOrBlank(value.toString())
        ? value.toString()
        : "";
  }
}
