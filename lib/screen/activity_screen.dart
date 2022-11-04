import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/activity_holder.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../utilmethod/fluttertoast_alert.dart';
import '../utilmethod/helper.dart';

// ignore: camel_case_types

class Activity_Screen extends StatefulWidget {
  @override
  _Activity_ScreenState createState() => _Activity_ScreenState();
}

// ignore: camel_case_types
class _Activity_ScreenState extends State<Activity_Screen> {
  Size _screenSize;
  int valueHolder = 0;
  bool showLoading;

//  var routeData;
  ProgressDialog progressDialog;
  List<Activity_holder> listArray = [];
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var MQ_Height;
  var MQ_Width;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    MQ_Height=MediaQuery.of(context).size.height;
    MQ_Width=MediaQuery.of(context).size.width;
//    routeData =
//        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,

        body: Stack(
          children: [
            //_widgetActivityScreen(),
            _widgetActivityScreenNewUI()
          ],
        )
      ),
    );
  }

  //================ Old Ui Activity Screen =========
  Widget _widgetActivityScreen(){
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
              child: Stack(
                children: [
                  Container(
                    width: _screenSize.width,
                    child: Padding(
                      padding:
                      const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 70,
                          ),
                          CustomWigdet.TextView(
                              overflow: true,
                              text: AppLocalizations.of(context)
                                  .translate("Which activity describes you most?"),
                              fontSize: 20.0,
                              textAlign: TextAlign.center,
                              color: Color(0xff1e63b0),
                              fontFamily: "Kelvetica Nobis"),
                          SizedBox(height: 20),
                          _getListItem(),
                          SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.only(left: 35, right: 35),
                            margin: EdgeInsets.only(bottom: 20),
                            child: CustomWigdet.RoundRaisedButton(
                                onPress: () async {
                                  if(showLoading)
                                    return;
                                  if (await UtilMethod.SimpleCheckInternetConnection(
                                      context, _scaffoldKey)) {
                                    _UpdateInterest(Constant.activity_listCopy);
                                  }
                                  //initPlatformState();
                                },
                                text: showLoading ?  AppLocalizations.of(context)
                                    .translate("Please wait")
                                    .toUpperCase():AppLocalizations.of(context)
                                    .translate("Continue")
                                    .toUpperCase(),
                                textColor: Custom_color.WhiteColor,
                                bgcolor: Custom_color.BlueLightColor,
                                fontFamily: "OpenSans Bold"),
                          ),
                          //  _buildCardList(),
                        ],
                      ),
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
                                    Navigator.pushNamed(context, Constant.SocialMediaScreen);
                                  },
                                  text: AppLocalizations.of(context)
                                      .translate("skip")
                                      .toUpperCase(),
                                  textColor: Color(0xff1e63b0),
                                  fontFamily: "Kelvetica Nobis"
                              ),

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
                                child: Text("3",style: TextStyle(color: Colors.white,fontSize: 13),),
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

          )]);
  }


  //================ New  Ui Activity Screen =========

  Widget _widgetActivityScreenNewUI(){
    
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
                  image:  AssetImage('assest/images/background_img.jpg'),// AssetImage("assest/images/hello.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    width: _screenSize.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                height: 2,
                                color:false?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: MQ_Width*0.01),
                                width: MQ_Width*0.12,
                                height: 4,
                                color:true?Color(0xfffb4592):Helper.tabLineColorGreyH1,//Colors.purpleAccent,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MQ_Height*0.09,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: MQ_Width*0.22,right: MQ_Width*0.22),
                          child: CustomWigdet.TextView(
                              overflow: true,
                              text: AppLocalizations.of(context)
                                  .translate("Which activity describes you most?"),
                              fontWeight: Helper.textFontH5,
                              fontSize: Helper.textSizeH9,
                              textAlign: TextAlign.center,
                              color: Color(Helper.textColorBlackH1),//Color(0xff1e63b0),
                              fontFamily: "Kelvetica Nobis"),
                        ),
                        SizedBox(height: MQ_Height*0.03),
                        _getListItem(),
                        SizedBox(height: MQ_Height*0.02),

                        Container(
                          padding: const EdgeInsets.only(left: 35, right: 35),
                          margin: EdgeInsets.only(bottom: 20),
                          child: CustomWigdet.RoundRaisedButton(
                              onPress: () async {
                                print('Constant.activity_listCopy.length=${Constant.activity_listCopy.length}');
                                int activityPercent=0;
                                if(Constant.activity_listCopy.length!=0){
                                  for(var acitvitytype in Constant.activity_listCopy){
                                    if(activityPercent==0) {
                                      activityPercent = acitvitytype.percent;
                                    }
                                    print('acitvitytype=${acitvitytype.percent}');
                                  }
                                }

                                if(activityPercent==0){
                                  print('Constant.activity_listCopy.length ***=${Constant.activity_listCopy.length}');
                                  UtilMethod.SnackBarMessage(
                                      _scaffoldKey,
                                      AppLocalizations.of(context)
                                          .translate("Please select your activity type"));
                                }else{
                                  if(showLoading)
                                    return;
                                  if (await UtilMethod.SimpleCheckInternetConnection(
                                      context, _scaffoldKey)) {
                                    _UpdateInterest(Constant.activity_listCopy);
                                  }                                }

                                //initPlatformState();
                              },
                              text: showLoading ?  AppLocalizations.of(context)
                                  .translate("Please wait")
                                  .toUpperCase():AppLocalizations.of(context)
                                  .translate("Continue")
                                  .toUpperCase(),
                              textColor: Custom_color.WhiteColor,
                              bgcolor: Custom_color.BlueLightColor,
                              fontSize:Helper.textSizeH12,
                              fontWeight:Helper.textFontH5,
                              fontFamily: "OpenSans Bold"),
                        ),
                        //  _buildCardList(),
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

                              false?CustomWigdet.FlatButtonSimple(
                                  onPress: () {
                                    Navigator.pushNamed(context, Constant.SocialMediaScreen);
                                  },
                                  text: AppLocalizations.of(context)
                                      .translate("skip")
                                      .toUpperCase(),
                                  textColor: Color(0xff1e63b0),
                                  fontFamily: "Kelvetica Nobis",
                                  fontWeight: Helper.textFontH5,
                                  fontSize: Helper.textSizeH12
                              ):Container(),

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
                                child: Text("3",style: TextStyle(color: Colors.white,fontSize: 13),),
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

          )]);
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
                    Navigator.pushNamed(context, Constant.SocialMediaScreen);
                  },
                  text: AppLocalizations.of(context)
                      .translate("skip")
                      .toUpperCase(),
                  textColor: Custom_color.BlueLightColor,
                  fontFamily: "OpenSans Bold")),
        ),
      ],
      title: CustomWigdet.TextView(
          text: "3 ${AppLocalizations.of(context).translate("of")} 4",
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
                flex: 3,
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

  Widget _getListItem() {
    return FutureBuilder<List<Activity_holder>>(
        future: _activiryItemList(),
        builder: (context, snapshot) {
          print("---data--" + snapshot.data.toString());
          print(snapshot.hasData);
          print(snapshot.connectionState);
          print(snapshot.hasError);

          return snapshot.data != null
              ? _buildCardList(snapshot.data, valueHolder)
//              ? listViewWidget(
//                  context,
//                  snapshot.data,
//                )
              : Expanded(child: Center(child: CircularProgressIndicator()));
        });
  }

//  Widget listViewWidget(
//    BuildContext context,
//    List<Activity_holder> activity_list,
//  ) {
//    if (activity_list.length > 0) {
//      return Expanded(
//        child: ListView.builder(
//            physics: NeverScrollableScrollPhysics(),
//            shrinkWrap: true,
//            itemCount: activity_list == null ? 0 : activity_list.length,
//            itemBuilder: (
//              context,
//              index,
//            ) {
//              valueHolder = activity_list[index].percent;
//              return _buildCardList(activity_list,valueHolder);
//            }),
//      );
//    }
//  }

  Future<List<Activity_holder>> _activiryItemList() async {
    List<Activity_holder> activityList = [];
    if (activityList != null && activityList.isNotEmpty) {
      activityList.clear();
    }

    String url = WebServices.GetActivity +
        SessionManager.getString(Constant.Token) +
        "&language=${SessionManager.getString(Constant.Language_code)}";
    print("---Url----" + url.toString());
    https.Response response = await https.get(Uri.parse(url),
        headers: {"Accept": "application/json", "Cache-Control": "no-cache"});

    if (response.statusCode == 200) {
      var itemlist = json.decode(response.body);
      print("---respmnse---" + response.body);
      activityList = itemlist
          .map<Activity_holder>((i) => Activity_holder.fromJson(i))
          .toList();
      print("List Size:-------> ${activityList.length}");
    }

    return activityList;
  }

  // ignore: missing_return, non_constant_identifier_names
  Future<https.Response> _UpdateInterest(
      List<Activity_holder> activityList) async {
    print("------jsondata----activityList==--" + activityList.toString());
    print("------jsondata----activityList.length ###=--${activityList.length}"  );

    try {
      if (activityList != null && activityList.length > 0) {
        Map<String, Object> jsondata = new HashMap();
        List.generate(Constant.activity_listCopy.length, (index) {
          jsondata["activity[${Constant.activity_listCopy[index].id}]"] =
              Constant.activity_listCopy[index].percent.toString();
        });

        print("------jsondata------" + jsondata.toString());
        _showProgress(context);
        String url = WebServices.UpdateActivity +
            SessionManager.getString(Constant.Token) +
            "&language=${SessionManager.getString(Constant.Language_code)}";
        print("-----url-----" + url.toString());
        var response = await https.post(Uri.parse(url),
            body: jsondata, encoding: Encoding.getByName("utf-8"));
        _hideProgress();
        print("respnse----" + response.body);
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          if (data["status"]) {
            //  Constant.activity_listCopy.clear();
            Navigator.pushNamed(context, Constant.SocialMediaScreen);
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
      }else{
        FlutterToastAlert.flutterToastMSG(AppLocalizations.of(context)
            .translate("Please select type"), context);
      }
    } on Exception catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

//  Future<void> _checkPermissions() async {
//    final PermissionStatus permissionGrantedResult =
//        await _locationService.hasPermission();
//    setState(() {
//      _permissionGranted = permissionGrantedResult;
//    });
//    print("---checkprtmsopm----" + _permissionGranted.toString());
//    if (_permissionGranted == PermissionStatus.denied) {
//      _requestPermission();
//    }
//  }

//  Future<void> _requestPermission() async {
//    if (_permissionGranted != PermissionStatus.granted) {
//      //   print("----if-------if------if------------------");
//      final PermissionStatus permissionRequestedResult =
//          await _locationService.requestPermission();
//      setState(() {
//        _permissionGranted = permissionRequestedResult;
//      });
//      print("----if-------if------if------------------" +
//          _permissionGranted.toString());
//
//      if (permissionRequestedResult != PermissionStatus.granted) {
//        return;
//      }
//    }
//    if (_permissionGranted == PermissionStatus.deniedForever) {
//      AppSettings.openLocationSettings();
//      print("---********************-dsfdsfdsf------");
//    }
//    print("---ddddd*****************----" + _permissionGranted.toString());
//  }

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

Widget _buildCardList(List<Activity_holder> activity_list, int intialvalue) {
  return Expanded(
    child: ListView.separated(
      shrinkWrap: true,
      //  physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) =>
          MyWidgetSlider(activity_list, index, intialvalue),
      itemCount: activity_list == null ? 0 : activity_list.length,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 10,
        );
      },
    ),
  );
}

class MyWidgetSlider extends StatefulWidget {
  final List<Activity_holder> activity_list;
  var index;
  int valueHolder;

  MyWidgetSlider(this.activity_list, this.index, this.valueHolder) : super();

  _MyWidgetSliderState createState() => _MyWidgetSliderState();
}

class _MyWidgetSliderState extends State<MyWidgetSlider> {
  var _currentSliderValue=10;
  @override
  Widget build(BuildContext context) {
    Constant.activity_listCopy.clear();
    Constant.activity_listCopy.addAll(widget.activity_list);
    return Padding(
      padding: widget.index == 0
          ? const EdgeInsets.only(top: 23)
          : const EdgeInsets.all(0.0),
      child: Container(
        margin: EdgeInsets.only(left: 30,right: 30),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Container(
            margin: EdgeInsets.only(left: 10,right: 10,top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: ImageIcon(
                          NetworkImage(Constant.ImageURL2 +
                              widget.activity_list[widget.index].image,scale: 1.0),
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        margin: EdgeInsets.only(left: 10,right: 10,top: 5),
                        width: 180,
                        alignment: Alignment.centerLeft,
                        child: CustomWigdet.TextView(
                            text:widget.activity_list[widget.index].name.toString(),
                            fontWeight: Helper.textFontH6,
                            fontSize: Helper.textSizeH12,
                            fontFamily: "Kelvetica Nobis",
                            color:Helper.textColorBlueH1,
                          textAlign: TextAlign.center

                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      CustomWigdet.TextView(

                          text: "${widget.activity_list[widget.index].percent.toString()}",
                          fontSize: Helper.textSizeH8,
                          color:Color(Helper.textColorPinkH1), //Color(0xff1e63b0),
                          fontWeight: Helper.textFontH4,
                          fontFamily: "Kelvetica Nobis"
                      ),
                      SizedBox(width: 5),
                      CustomWigdet.TextView(

                          text: "/10",
                          fontSize: Helper.textSizeH13,
                          fontWeight: Helper.textFontH2,
                          color:Helper.textColorBlueH1,//Custom_color.BlueDarkColor,//Color(0xff5f5f5f),

                          fontFamily: "Kelvetica Nobis"
                      ),



                    ],
                  ),
                ),
                ],
              ),
          ),
            SizedBox(height:30,),
            Container(
              margin: EdgeInsets.only(left: 10,right: 10),

              child: false?SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbColor: Custom_color.BlueLightColor,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0, disabledThumbRadius: 10.0, elevation: 10),
                  activeTrackColor: Color(Helper.SeekBarBorderPinkColor),//Custom_color.BlueLightColor,
                  inactiveTrackColor: Custom_color.GreyLightColor,
                  valueIndicatorColor:Color(Helper.SeekBarBorderPinkColor),
                 // Custom_color.BlueLightColor,
                  trackHeight: 5,

                ),
                child: Slider(
                    value: widget
                        .activity_list[widget.index].percent
                        .toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 1000,
                    thumbColor:Custom_color.BlueLightColor ,
                    inactiveColor: Custom_color.BlueLightColor,
                    mouseCursor: MouseCursor.uncontrolled,
                    label: '${widget.activity_list[widget.index].percent.round()}',
                    onChanged: (double newValue) async {
                      setState(() {
                        widget.activity_list[widget.index]
                            .percent = newValue.round();
                      });
                    })
              ):
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(Helper.SeekBarBorderPinkColor),//Custom_color.BlueLightColor,
                  inactiveTrackColor: Custom_color.GreyLightColor,
                  valueIndicatorColor:Custom_color.BlueLightColor,
                  trackShape: RoundedRectSliderTrackShape(),
                  trackHeight: 4.0,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  thumbColor: Custom_color.BlueLightColor,
                  overlayColor: Colors.red.withAlpha(32),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  tickMarkShape: RoundSliderTickMarkShape(),
                  activeTickMarkColor: Colors.red[700],
                  inactiveTickMarkColor: Colors.red[100],
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                child: Slider(
                  value: widget
                      .activity_list[widget.index].percent
                      .toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: '${widget.activity_list[widget.index].percent}',
                  onChanged: (value) {
                    setState(() {
                      widget.activity_list[widget.index]
                          .percent = value.toInt();
                    });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
