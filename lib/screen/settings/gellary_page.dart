import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:http/http.dart' as https;
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
//import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../../utilmethod/helper.dart';
import '../../utilmethod/showDialog_Error.dart';

class Gallery_Pages extends StatefulWidget {
  @override
  _Gallery_ScreenState createState() => _Gallery_ScreenState();
}

class _Gallery_ScreenState extends State<Gallery_Pages> {
  Size _screenSize;
  var MQ_Width;
  var MQ_Height;
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  ProgressDialog progressDialog;
 // List<Asset> files = [];
  List<File> files = [];
  int first_value = 0;
  int Second_value = 0;
  int sum = 0;

  // List demo = [];
  List routeData = [];
  var  EvangelistRout;
  int indexTab=0;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();

    _imagesSum();
  }
  Future<void> _imagesSum()async{
    setState(() {
      if (files != null && files.isNotEmpty) {
        Second_value = files.length;
      }
      if (routeData != null && routeData.isNotEmpty) {
        first_value = routeData.length;
      }

      sum = first_value + Second_value;
    });
  }
  _showModalBottomSheet(context) {
    showModalBottomSheet(context: context,    backgroundColor: Colors.transparent,
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

  @override
  Widget build(BuildContext context) {
    EvangelistRout= ModalRoute.of(context).settings.arguments;

   if(EvangelistRout!=null) {
     routeData = EvangelistRout["imagelist"];
     indexTab = EvangelistRout["index"];

   }
    print("------routdata-------"+routeData.toString());
    _imagesSum();

    _screenSize = MediaQuery.of(context).size;
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: //_widgetGalleryUi()
        _widgetGalleryNewUi()
      ),
    );
  }

  //======================= Old Ui Gallery Page============

  Widget _widgetGalleryUi(){

    return Stack(
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(height: 70),
                Expanded(
                  child: Column(
                    //  mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomWigdet.TextView(
                          text: AppLocalizations.of(context)
                              .translate("Add your best photos"),
                          fontSize: 20.0,
                          overflow: true,
                          textAlign: TextAlign.center,
                          color: Color(0xff1e63b1),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Kelvetica Nobis"),
                      SizedBox(
                        height: 10,
                      ),
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context)
                              .translate("This will be your gallery"),
                          fontSize: 15,
                          color: Custom_color.GreyLightColor,
                          fontFamily: "Kelvetica Nobis",
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: 10,
                      ),
                      CustomWigdet.RoundRaisedButtonIcon(
                          onPress: () {
                            //    loadAssets();
                            if (files != null && files.isNotEmpty) {
                              Second_value = files.length;
                            }
                            if (routeData != null && routeData.isNotEmpty) {
                              first_value = routeData.length;
                            }

                            sum = first_value + Second_value;
                            if (sum <= 10) {
                              _showModalBottomSheet(context);
                            } else {
                              UtilMethod.SnackBarMessage(
                                  _scaffoldKey,
                                  AppLocalizations.of(context)
                                      .translate("Not more than limit 10 images"));
                            }
                          },
                          text: AppLocalizations.of(context)
                              .translate("Add photos"),
                          textColor: Custom_color.WhiteColor,

                          fontFamily: "OpenSans Bold"),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              routeData != null && routeData.isNotEmpty
                                  ? buildGridView()
                                  : Container(),
                              SizedBox(
                                height: 10,
                              ),
                              files.isNotEmpty ? buildGridView1() : Container()
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                CustomWigdet.RoundRaisedButton(
                    onPress: ()  {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Constant.NavigationRoute,
                          ModalRoute.withName(Constant.WelcomeRoute),
                          arguments: {"index": 1});
                    },
                    text: AppLocalizations.of(context)
                        .translate("Continue")
                        .toUpperCase(),
                    bgcolor: Custom_color.BlueLightColor,
                    textColor: Custom_color.WhiteColor,
                    fontFamily: "OpenSans Bold"),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,

          child: Container(
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

              ],
            ),
          ),
        ),


      ],
    );
  }

  //======================= New Ui Gallery Page============

  Widget _widgetGalleryNewUi(){

    return Stack(
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(height: 70),
               false? Expanded(
                  child: Column(
                    //  mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomWigdet.TextView(
                          text: AppLocalizations.of(context)
                              .translate("Add your best photos"),
                          fontSize: 20.0,
                          overflow: true,
                          textAlign: TextAlign.center,
                          color: Color(0xff1e63b1),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Kelvetica Nobis"),
                      SizedBox(
                        height: 10,
                      ),
                      CustomWigdet.TextView(
                          overflow: true,
                          text: AppLocalizations.of(context)
                              .translate("This will be your gallery"),
                          fontSize: 15,
                          color: Custom_color.GreyLightColor,
                          fontFamily: "Kelvetica Nobis",
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: 10,
                      ),
                      false?CustomWigdet.RoundRaisedButtonIcon(
                          onPress: () {
                            //    loadAssets();
                            if (files != null && files.isNotEmpty) {
                              Second_value = files.length;
                            }
                            if (routeData != null && routeData.isNotEmpty) {
                              first_value = routeData.length;
                            }

                            sum = first_value + Second_value;
                            if (sum <= 10) {
                              _showModalBottomSheet(context);
                            } else {
                              UtilMethod.SnackBarMessage(
                                  _scaffoldKey,
                                  AppLocalizations.of(context)
                                      .translate("Not more than limit 10 images"));
                            }
                          },
                          text: AppLocalizations.of(context)
                              .translate("Add photos"),
                          textColor: Custom_color.WhiteColor,

                          fontFamily: "OpenSans Bold"):
                      Container(),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              routeData != null && routeData.isNotEmpty
                                  ? buildGridView()
                                  : Container(),
                              SizedBox(
                                height: 10,
                              ),
                              files.isNotEmpty ? buildGridView1() : Container()
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),


                    ],
                  ),
                ):
               Expanded(
                 child: ListView(
                   //  mainAxisAlignment: MainAxisAlignment.center,
                   //crossAxisAlignment: CrossAxisAlignment.s,
                   children: <Widget>[
                     CustomWigdet.TextView(
                         text: AppLocalizations.of(context)
                             .translate("Add your best photos"),
                         overflow: true,
                         textAlign: TextAlign.center,
                         color: Color(Helper.textColorBlackH1),
                         fontWeight: Helper.textFontH4,
                         fontSize: Helper.textSizeH8,
                         fontFamily: "Kelvetica Nobis"),
                     SizedBox(
                       height: MQ_Height*0.01,
                     ),
                     CustomWigdet.TextView(
                         overflow: true,
                         text: AppLocalizations.of(context)
                             .translate("This will be your gallery"),
                         fontSize: Helper.textSizeH10,
                         fontWeight: Helper.textFontH4,
                         color: Color(0xfff84390),
                         fontFamily: "Kelvetica Nobis",
                         textAlign: TextAlign.center),
                     SizedBox(
                       height: MQ_Height*0.05,
                     ),
                     false? CustomWigdet.RoundRaisedButtonIcon(
                         onPress: () {
                           //    loadAssets();
                           if (files != null && files.isNotEmpty) {
                             Second_value = files.length;
                           }
                           if (routeData != null && routeData.isNotEmpty) {
                             first_value = routeData.length;
                           }

                           sum = first_value + Second_value;
                           if (sum <= 10) {
                             _showModalBottomSheet(context);
                           } else {
                             UtilMethod.SnackBarMessage(
                                 _scaffoldKey,
                                 AppLocalizations.of(context)
                                     .translate("Not more than limit 10 images"));
                           }
                         },
                         text: AppLocalizations.of(context)
                             .translate("Add photos"),
                         textColor: Custom_color.WhiteColor,

                         fontFamily: "OpenSans Bold"):
                     sum<4? Container(
                       alignment: Alignment.center,
                       padding: EdgeInsets.only(left: 40, right: 40),
                       child: Stack(
                         children: <Widget>[
                           InkWell(
                             onTap: () {
                               //    loadAssets();
                               if (files != null && files.isNotEmpty) {
                                 Second_value = files.length;
                               }
                               if (routeData != null && routeData.isNotEmpty) {
                                 first_value = routeData.length;
                               }

                               sum = first_value + Second_value;
                               if (sum <= 10) {
                                 _showModalBottomSheet(context);
                               } else {
                                 UtilMethod.SnackBarMessage(
                                     _scaffoldKey,
                                     AppLocalizations.of(context)
                                         .translate("Not more than limit 10 images"));
                               }
                             },
                             child: DottedBorder(
                               dashPattern: [5,3,5,3],
                               borderType: BorderType.RRect,
                               color: Custom_color.BlueLightColor,
                               strokeWidth: 1.5,


                               child: Container(
                                 decoration: BoxDecoration(
                                     color: Colors.white,
                                     boxShadow: [
                                       BoxShadow(
                                           color: Color(0xffd2d6e1),
                                           offset: Offset(1,6),
                                           blurRadius: 20

                                       )
                                     ]
                                 ),
                                 width: MQ_Width*0.50,
                                 height:MQ_Height*0.20,

                               ),
                             ),

                           ),


                           Positioned.fill(
                               child: InkWell(
                                   borderRadius: BorderRadius.circular(50),
                                   onTap: () {
                                     //    loadAssets();
                                     if (files != null && files.isNotEmpty) {
                                       Second_value = files.length;
                                     }
                                     if (routeData != null && routeData.isNotEmpty) {
                                       first_value = routeData.length;
                                     }

                                     sum = first_value + Second_value;
                                     if (sum <= 10) {
                                       _showModalBottomSheet(context);
                                     } else {
                                       UtilMethod.SnackBarMessage(
                                           _scaffoldKey,
                                           AppLocalizations.of(context)
                                               .translate("Not more than limit 10 images"));
                                     }
                                     //    _showDialogBox();
                                   },
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [

                                       Container(
                                           margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                           padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                           child: ClipOval(
                                             child: Material(
                                               //   shape: Border.all(color:Colors.grey.shade200,width: 1),
                                               color: Colors.grey.shade200,//Helper.inIconCircleBlueColor1, // Button color
                                               child: InkWell(
                                                 splashColor: Helper.inIconCircleBlueColor1, // Splash color
                                                 onTap: () {
                                                   //    loadAssets();
                                                   if (files != null && files.isNotEmpty) {
                                                     Second_value = files.length;
                                                   }
                                                   if (routeData != null && routeData.isNotEmpty) {
                                                     first_value = routeData.length;
                                                   }

                                                   sum = first_value + Second_value;
                                                   if (sum <= 10) {
                                                     _showModalBottomSheet(context);
                                                   } else {
                                                     UtilMethod.SnackBarMessage(
                                                         _scaffoldKey,
                                                         AppLocalizations.of(context)
                                                             .translate("Not more than limit 10 images"));
                                                   }
                                                 },
                                                 child: SizedBox(width: 60, height: 60,
                                                     child:Icon(Icons.add,size: 35,color: Colors.grey,)
                                                 ),
                                               ),
                                             ),
                                           )
                                       ),
                                       SizedBox(
                                         height: MQ_Height*0.01,
                                       ),
                                       Container(
                                         width: MQ_Width*0.50,
                                         child: CustomWigdet.TextView(
                                             overflow: true,
                                             text:"ADD",
                                             fontSize: Helper.textSizeH8,
                                             fontWeight: Helper.textFontH5,
                                             textAlign: TextAlign.center,

                                             color: Color(0xffadadad),
                                             fontFamily: "Kelvetica Nobis"),
                                       ),

                                     ],
                                   )
                               )),
                           /*_image_file != null
                               ? InkWell(
                             onTap: (){
                               _showModalBottomSheet(context);
                               //   _showDialogBox();
                             },
                             child: Container(
                               width: _screenSize.width,
                               height: _screenSize.height/2-100,
                               child: Image.file(
                                 _image_file,
                                 fit: BoxFit.cover,
                               ),
                             ),
                           )
                               : profile_Image!=null?  InkWell(
                             onTap: (){
                               _showModalBottomSheet(context);
                               //   _showDialogBox();
                             },
                             child: Container(
                               width: _screenSize.width,
                               height: _screenSize.height/2-100,
                               child: Image.network(
                                 profile_Image,
                                 fit: BoxFit.cover,
                               ),
                             ),
                           ):Container()*/
                         ],
                       ),
                     ):Container(),
                     SizedBox(
                       height: MQ_Height*0.03,
                     ),
                     SingleChildScrollView(
                       child: Column(
                         children: <Widget>[
                           routeData != null && routeData.isNotEmpty
                               ? buildGridView()
                               : Container(),
                           SizedBox(
                             height: 10,
                           ),
                           files.isNotEmpty ? buildGridView1() : Container()
                         ],
                       ),
                     ),



                     files.length!=0 ? SizedBox(
                       height: MQ_Height*0.01,
                     ):  SizedBox(
                       height: MQ_Height*0.06,
                     ),

                     CustomWigdet.RoundRaisedButton(
                         onPress: () async {

                           Navigator.of(context).pushNamedAndRemoveUntil(
                               Constant.NavigationRoute,
                               ModalRoute.withName(Constant.WelcomeRoute),
                               arguments: {"index": indexTab});

                         },
                         text: AppLocalizations.of(context)
                             .translate("Continue")
                             .toUpperCase(),
                         bgcolor: Custom_color.BlueLightColor,
                         textColor: Custom_color.WhiteColor,
                         fontSize: Helper.textSizeH12,
                         fontWeight: Helper.textFontH4,
                         fontFamily: "OpenSans Bold"),
                   ],
                 ),
               ),

                false?CustomWigdet.RoundRaisedButton(
                    onPress: ()  {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Constant.NavigationRoute,
                          ModalRoute.withName(Constant.WelcomeRoute),
                          arguments: {"index": 2});
                    },
                    text: AppLocalizations.of(context)
                        .translate("Continue")
                        .toUpperCase(),
                    bgcolor: Custom_color.BlueLightColor,
                    textColor: Custom_color.WhiteColor,
                    fontFamily: "OpenSans Bold"):Container(),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,

          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Custom_color.BlueLightColor,//Color(0xffc6c6c8),
                        width: 0.3
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

              ],
            ),
          ),
        ),


      ],
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
                //  fit: FlexFit.tight,
                child: Container(
                    width: _screenSize.width,
                    height: 0.5,
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
          Navigator.pop(context, true);
        },
      ),
    );
  }

  Widget buildGridView() {
    int addvalue=0;
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: List.generate(routeData.length, (index) {
        print("----lent-----" +
            routeData.length.toString() +
            "----index---" +
            index.toString()+"====addvalue*$addvalue ===============");

        //, if(index>0)
        {
          //   Asset asset = files[index];
          //  print("_-----assest--identifer--" + asset.identifier);
          //  print("------file--name-----" + routeData.toString());
         /* if(routeData.length==addvalue){
            print('buildGridView routeData.length=${routeData.length} addvalue=${addvalue}');
            return  Container(
              alignment: Alignment.centerRight,
              // padding: EdgeInsets.only(left: 40, right: 40),
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      //    loadAssets();
                      if (files != null && files.isNotEmpty) {
                        Second_value = files.length;
                      }
                      if (routeData != null && routeData.isNotEmpty) {
                        first_value = routeData.length;
                      }

                      sum = first_value + Second_value;
                      if (sum <= 10) {
                        _showModalBottomSheet(context);
                      } else {
                        UtilMethod.SnackBarMessage(
                            _scaffoldKey,
                            AppLocalizations.of(context)
                                .translate("Not more than limit 10 images"));
                      }
                    },
                    child: DottedBorder(
                      dashPattern: [5,3,5,3],
                      borderType: BorderType.RRect,
                      color: Custom_color.BlueLightColor,
                      strokeWidth: 1.5,


                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xffd2d6e1),
                                  offset: Offset(1,6),
                                  blurRadius: 20

                              )
                            ]
                        ),
                        width: MQ_Width*0.42,
                        height:MQ_Height*0.20,

                      ),
                    ),

                  ),


                  Positioned.fill(
                      child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            //    loadAssets();
                            if (files != null && files.isNotEmpty) {
                              Second_value = files.length;
                            }
                            if (routeData != null && routeData.isNotEmpty) {
                              first_value = routeData.length;
                            }

                            sum = first_value + Second_value;
                            if (sum <= 10) {
                              _showModalBottomSheet(context);
                            } else {
                              UtilMethod.SnackBarMessage(
                                  _scaffoldKey,
                                  AppLocalizations.of(context)
                                      .translate("Not more than limit 10 images"));
                            }
                            //    _showDialogBox();
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Container(
                                  margin: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                  padding: EdgeInsets.only(left: MQ_Width*0.01,right: MQ_Width*0.01),
                                  child: ClipOval(
                                    child: Material(
                                      //   shape: Border.all(color:Colors.grey.shade200,width: 1),
                                      color: Colors.grey.shade200,//Helper.inIconCircleBlueColor1, // Button color
                                      child: InkWell(
                                        splashColor: Helper.inIconCircleBlueColor1, // Splash color
                                        onTap: () {
                                          //    loadAssets();
                                          if (files != null && files.isNotEmpty) {
                                            Second_value = files.length;
                                          }
                                          if (routeData != null && routeData.isNotEmpty) {
                                            first_value = routeData.length;
                                          }

                                          sum = first_value + Second_value;
                                          if (sum <= 10) {
                                            _showModalBottomSheet(context);
                                          } else {
                                            UtilMethod.SnackBarMessage(
                                                _scaffoldKey,
                                                AppLocalizations.of(context)
                                                    .translate("Not more than limit 10 images"));
                                          }
                                        },
                                        child: SizedBox(width: 60, height: 60,
                                            child:Icon(Icons.add,size: 35,color: Colors.grey,)
                                        ),
                                      ),
                                    ),
                                  )
                              ),
                              SizedBox(
                                height: MQ_Height*0.01,
                              ),
                              Container(
                                width: MQ_Width*0.50,
                                child: CustomWigdet.TextView(
                                    overflow: true,
                                    text:"ADD",
                                    fontSize: Helper.textSizeH8,
                                    fontWeight: Helper.textFontH5,
                                    textAlign: TextAlign.center,

                                    color: Color(0xffadadad),
                                    fontFamily: "Kelvetica Nobis"),
                              ),

                            ],
                          )
                      )),

                ],
              ),
            );

          }
          addvalue=index+1;*/
          return Stack(
            children: <Widget>[
              Container(
                width: 300,
                height: 300,
                child: CustomWigdet.GetImagesNetwork(
                    imgURL: routeData[index]["name"], boxFit: BoxFit.cover),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                    onTap: () {
                      //   files.removeWhere((assest) => assest.name == files[index].name);
                      _asyncConfirmDialog(context, index, false);

                      print("------insed----" +
                          routeData[index]["id"].toString());
                    },
                    child: Image(image:
                    AssetImage("assest/images/close.png"),
                      width: 25,
                      height: 25,

                    ),),
              ),
            ],
          );

        }

        //        return Stack(
//          children: <Widget>[
//            AssetThumb(
//              asset: asset,
//              width: 300,
//              height: 300,
//            ),
//            Positioned(
//              bottom: 8,
//              right: 8,
//              child: InkWell(
//                  onTap: (){
//                    //   files.removeWhere((assest) => assest.name == files[index].name);
//
//                    setState(() {
//                      files.removeAt(index);
//                    });
//
//                  },
//                  child: Icon(
//                    Icons.cancel,
//                    size: 30,
//                    color: Custom_color.BlueLightColor,
//                  )),
//            ),
//          ],
//        );
      }),
    );
  }

  Widget buildGridView1() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: List.generate(files.length, (index) {
        print("----file-----" +
            files.length.toString() +
            "----index---" +
            index.toString());

     //   Asset asset = files[index];
        //  print("_-----assest--identifer--" + asset.identifier);
      //  print("------file--name-----" + asset.name);

        return Stack(
          children: <Widget>[
            // AssetThumb(
            //   asset: asset,
            //   width: 300,
            //   height: 300,
            // ),
            Container(
              width: 300,
              height: 300,
            child:  Image.file (files[index],fit: BoxFit.cover,),
            //  child: CustomWigdet.GetImagesNetwork(
            //      imgURL: files[index].toString(), boxFit: BoxFit.cover),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () {
                  //   files.removeWhere((assest) => assest.name == files[index].name);
                  _asyncConfirmDialog(context, index, false);

                  print("------insed----" +
                      routeData[index]["id"].toString());
                },
                child: Image(image:
                AssetImage("assest/images/close.png"),
                  width: 25,
                  height: 25,

                ),),
            ),
          ],
        );
      }),
    );
  }

  // Future<void> loadAssets() async {
  //   if (files != null && files.isNotEmpty) {
  //     images = files;
  //   }
  //   List<Asset> resultList = List<Asset>();
  //   String error = "";
  //   try {
  //     resultList = await MultiImagePicker.pickImages(
  //       maxImages: 10,
  //       enableCamera: true,
  //       selectedAssets: images,
  //       cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
  //       materialOptions: MaterialOptions(
  //         actionBarColor: Custom_color.BlueLightString,
  //         actionBarTitle: AppLocalizations.of(context).translate("MiuMiu"),
  //         allViewTitle: AppLocalizations.of(context).translate("All Photos"),
  //         useDetailsView: true,
  //         selectCircleStrokeColor: Custom_color.OrangeString,
  //       ),
  //     );
  //   } on NetworkImageLoadException catch (e) {
  //     // User pressed cancel, update ui or show alert
  //     error = e.toString();
  //   } on Exception catch (e) {
  //     error = e.toString();
  //   }
  //
  //   if (!mounted) return;
  //   setState(() {
  //     if (resultList != null && resultList.length > 0) {
  //       if (files.isEmpty) {
  //         files = resultList;
  //       } else {
  //         if (UtilMethod.isStringNullOrBlank(error)) {
  //           files.clear();
  //           files.addAll(resultList);
  //         }
  //       }
  //       List.generate(files.length, (index) {
  //         print("----filename----" + files[index].name.toString());
  //       });
  //     }
  //     images = resultList;
  //     _error = error;
  //   });
  // }

  Future _cropImage(String picked) async {
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
          initAspectRatio: CropAspectRatioPreset.ratio4x3,
          showCropGrid: false),
      sourcePath: picked,
      aspectRatioPresets: [
       // CropAspectRatioPreset.square,
       //   CropAspectRatioPreset.original,
       //   CropAspectRatioPreset.ratio3x2,
         CropAspectRatioPreset.ratio4x3,
      //   CropAspectRatioPreset.ratio5x4,
      //   CropAspectRatioPreset.ratio16x9
      ],
     // maxWidth: 900,
    );
    if (cropped != null) {
      if (mounted) {
        //  files.add(cropped);
          uploadImage(cropped);
        //  file = cropped;
      }
    }
  }

  Future open_camera() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.camera);

    // print("-----path-------" + pickedFile.path.toString());
    if (pickedFile != null && pickedFile.path != null) {
      _cropImage(pickedFile.path);
    }
  }

  Future open_gallery() async {
    //============ Select Image  ================

   /* var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null && pickedFile.path != null) {
      _cropImage(pickedFile.path);
    }*/

    //==============  Image Multiple ==========
    _SelectMultiImage();




  }
  Future<void> _SelectMultiImage()async{
    try {
      if (images.length != 0) {
        images.clear();

      }
    }catch(error){
      print('images clear error=$error');
    }

    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';


    try {
      int maxImg=0;
      if(sum!=null){
        maxImg=4-sum;
      }else{
        maxImg=4;
      }
      resultList = await MultiImagePicker.pickImages(
        maxImages:maxImg,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Gallery",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );/*.then((value)async{

      });*/

    } on Exception catch (e) {
      error = e.toString();
    }

    setState(() {
      images = resultList;
      print('images=${images.length}');
      if(images.length!=0){
        alertMultipleImage();
      }
    });

    /*if(files.length!=0){
      files.clear();

    }*/

    /*setState(() {
      print('images  ##=${images}');

      images.forEach((imageAsset) async {
        final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
        print('images  ##=${filePath}');

        File tempFile = File(filePath);
        alertMultipleImage(tempFile);


        if (tempFile.existsSync()) {
          print('images tempFile ##=${tempFile}');
          files.add(tempFile);
        }

      });
    });*/
  }
  Future<void> alertMultipleImage1()async{
    await showDialog(context: context,
        builder: (BuildContext bcontext)=>AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          title: Text('Upload Image'),
          actions: [
            Container(
              child: false?Text('Are you sure do you want to upload multiple images ?',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 16),):
              CustomWigdet.TextView(
                  textAlign: TextAlign.start,
                  overflow: true,
                  text: "Are you sure do you want to upload multiple images ?",//AppLocalizations.of(context).translate("Are you sure you want to delete image"),
                  fontFamily: "OpenSans Bold",
                  color: Custom_color.BlackTextColor,
                  fontWeight: FontWeight.w500,
                  fontSize: Helper.textSizeH12),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 5,right: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context,1);
                    },
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  margin: EdgeInsets.only(left: 5,right: 5),

                  child: ElevatedButton(
                    onPressed: ()async {
                      Navigator.pop(context,1);
                      images.forEach((imageAsset) async {
                        final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
                        print('images  ##=${filePath}');

                        File tempFile = File(filePath);
                        uploadImage(tempFile);


                                /*if (tempFile.existsSync()) {
                  print('images tempFile ##=${tempFile}');
                  files.add(tempFile);
                }*/

                      });
                    },
                    child: Text('Yes'),
                  ),
                )
              ],
            ),


          ],
        ));
  }

  Future<void> alertMultipleImage() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  Center(
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
            child: Dialog(
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Container(
                  height: MQ_Height*0.22,

                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.spaceBetween,

                    children: <Widget>[
                      false?Container(
                        padding: const EdgeInsets.all(10.0),
                       // margin:  EdgeInsets.only(top: MQ_Height*0.01,),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomWigdet.TextView(
                                textAlign: TextAlign.start,
                                fontWeight: Helper.textFontH4,
                                fontSize: Helper.textSizeH11,
                                overflow: true,
                                text:  AppLocalizations.of(context).translate("Upload Image"),
                                color: Custom_color.BlackTextColor),
                          ],
                        ),
                      ):Container(),


                      Container(
                        padding: const EdgeInsets.all(10.0),
                        margin:  EdgeInsets.only(top: MQ_Height*0.01,),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomWigdet.TextView(
                                textAlign: TextAlign.start,
                                fontWeight: Helper.textFontH5,
                                fontSize: Helper.textSizeH12,
                                overflow: true,
                                text:  AppLocalizations.of(context).translate("Are you sure do you want to upload multiple images ?"),
                                color: Custom_color.BlackTextColor),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MQ_Height*0.01,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          false?Divider(
                            color: Custom_color.GreyColor,
                            height: 1,
                          ):Container(),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[

                                Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(left: MQ_Width * 0.01,
                                      right: MQ_Width * 0.01,
                                      top: MQ_Height * 0.02,
                                      bottom: MQ_Height * 0.02),
                                  height: 50,
                                  width: MQ_Width*0.33,
                                  decoration: BoxDecoration(
                                    color: Color(Helper.ButtonBorderPinkColor),
                                    border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: FlatButton(
                                    onPressed: ()async{

                                      Navigator.pop(context,1);

                                      //========== one by one Upload image ==========
                                      images.forEach((imageAsset) async {
                                        final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
                                        print('images  ##=${filePath}');

                                        File tempFile = File(filePath);
                                        uploadImage(tempFile);

                                      });
                                      //========== Multiple image Upload =======
                                      //uploadImage_Update();

                                    },
                                    child: Text(
                                      // isLocationEnabled?'CLOSE':'OPEN',
                                      AppLocalizations.of(context)
                                          .translate("Yes")
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                    ),
                                  ),
                                ),
                                false?VerticalDivider(
                                  width: 1,
                                  color: Custom_color.GreyColor,
                                ):Container(),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(left: MQ_Width * 0.01,
                                      right: MQ_Width * 0.01,
                                      top: MQ_Height * 0.02,
                                      bottom: MQ_Height * 0.02),

                                  height: 50,
                                  width: MQ_Width*0.33,
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
                                          .translate("Cancel")
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
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }


//=============== old Delete Dialog ========
  Future _asyncConfirmDialog1(BuildContext context, int index, bool condition) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              height: 150,
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CustomWigdet.TextView(
                        textAlign: TextAlign.center,
                        overflow: true,
                        text: AppLocalizations.of(context)
                            .translate("Are you sure you want to delete image"),
                        fontFamily: "OpenSans Bold",
                        color: Custom_color.BlackTextColor),
                  ),
                  Spacer(),
                  Column(
                    children: <Widget>[
                      Divider(
                        color: Custom_color.ColorDivider,
                        height: 1,
                      ),
                      IntrinsicHeight(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: CustomWigdet.FlatButtonSimple(
                                    onPress: () async {
                                      if (condition) {
                                        Navigator.pop(context);
                                        setState(() {
                                          files.removeAt(index);
                                          _deleteImage(index, context);
                                        });
                                      } else {
                                        if (await UtilMethod
                                            .SimpleCheckInternetConnection(
                                                context, _scaffoldKey)) {
                                          _deleteImage(index, context);
                                        }
                                      }
                                    },
                                    textAlign: TextAlign.center,
                                    text: AppLocalizations.of(context)
                                        .translate("Confirm")
                                        .toUpperCase(),
                                    textColor: Custom_color.BlueLightColor,
                                    fontFamily: "OpenSans Bold"),
                              ),
                            ),
                            VerticalDivider(
                              width: 1,
                              color: Custom_color.ColorDivider,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: CustomWigdet.FlatButtonSimple(
                                    onPress: () {
                                      Navigator.of(context).pop();
                                    },
                                    textAlign: TextAlign.center,
                                    text: AppLocalizations.of(context)
                                        .translate("Cancel")
                                        .toUpperCase(),
                                    textColor: Custom_color.BlueLightColor,
                                    fontFamily: "OpenSans Bold"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }

  //============= New Ui Delete Dialog ======================

  Future _asyncConfirmDialog(BuildContext context, int index, bool condition) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  Center(
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
            child: Dialog(
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Container(
                  height: MQ_Height*0.22,

                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.spaceBetween,

                    children: <Widget>[
                      false?Container(
                        padding: const EdgeInsets.all(10.0),
                        // margin:  EdgeInsets.only(top: MQ_Height*0.01,),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomWigdet.TextView(
                                textAlign: TextAlign.start,
                                fontWeight: Helper.textFontH4,
                                fontSize: Helper.textSizeH11,
                                overflow: true,
                                text:  AppLocalizations.of(context).translate("Upload Image"),
                                color: Custom_color.BlackTextColor),
                          ],
                        ),
                      ):Container(),


                      Container(
                        padding: const EdgeInsets.all(10.0),
                        margin:  EdgeInsets.only(top: MQ_Height*0.01,),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomWigdet.TextView(
                                textAlign: TextAlign.start,
                                fontWeight: Helper.textFontH5,
                                fontSize: Helper.textSizeH12,
                                overflow: true,
                                text:  AppLocalizations.of(context).translate("Are you sure you want to delete image"),
                                color: Custom_color.BlackTextColor),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MQ_Height*0.01,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          false?Divider(
                            color: Custom_color.GreyColor,
                            height: 1,
                          ):Container(),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[

                                Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(left: MQ_Width * 0.01,
                                      right: MQ_Width * 0.01,
                                      top: MQ_Height * 0.02,
                                      bottom: MQ_Height * 0.02),
                                  height: 50,
                                  width: MQ_Width*0.33,
                                  decoration: BoxDecoration(
                                    color: Color(Helper.ButtonBorderPinkColor),
                                    border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: FlatButton(
                                    onPressed: ()async{
                                      if (routeData.length==0) {
                                        Navigator.pop(context);
                                        setState(() {
                                          files.removeAt(index);
                                          _deleteImage(index, context);
                                        });
                                      } else {
                                        if (await UtilMethod
                                            .SimpleCheckInternetConnection(
                                            context, _scaffoldKey)) {
                                          _deleteImage(index, context);
                                        }
                                      }
                                    },
                                    child: Text(
                                      // isLocationEnabled?'CLOSE':'OPEN',
                                      AppLocalizations.of(context)
                                          .translate("Confirm")
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                    ),
                                  ),
                                ),
                                false?VerticalDivider(
                                  width: 1,
                                  color: Custom_color.GreyColor,
                                ):Container(),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(left: MQ_Width * 0.01,
                                      right: MQ_Width * 0.01,
                                      top: MQ_Height * 0.02,
                                      bottom: MQ_Height * 0.02),

                                  height: 50,
                                  width: MQ_Width*0.33,
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
                                          .translate("Cancel")
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
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }

  Future<void> uploadImage(File cropped) async {
    try {
      print('uploadImage cropped.path ==${cropped.path}');
      _showProgress(context);
      Uri uri = Uri.parse(WebServices.GetUpdateImage +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}");
      var _request = https.MultipartRequest('POST', uri);
      _request.files.add(await https.MultipartFile.fromPath('imageFile[]', cropped.path));


      print("------request------" + _request.toString());
      var streamedResponse = await _request.send();
      print("-----ssssssss-----"+streamedResponse.reasonPhrase.toString());
      https.Response res = await https.Response.fromStream(streamedResponse);
      print('response.body ' + res.statusCode.toString());
      print("-----respnse----" + res.body.toString());
      _hideProgress();

      if (res.statusCode == 200) {
        var bodydata = json.decode(res.body);
        if (bodydata["status"]) {
          UtilMethod.SnackBarMessage(_scaffoldKey, AppLocalizations.of(context).translate("Successful upload image"));
          setState(() {
            files.add(cropped);
          });
          _imagesSum();

        }
        else
        {
          _hideProgress();
         //  UtilMethod.SnackBarMessage(_scaffoldKey, bodydata["message"]);
           ShowDialogError.showDialogErrorMessage(context, "Alert", bodydata["message"], res.statusCode, 'error', MQ_Width, MQ_Height);
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
      ShowDialogError.showDialogErrorMessage(context, "Exception error", e.toString(), 0, 'error', MQ_Width, MQ_Height);
    }
  }

  //================= Multiple Image Update APi ===========

  Future<void> uploadImage_Update() async {

    try {
      print('uploadImage_Update images.length=${images.length}');

      Uri uri = Uri.parse(WebServices.GetUpdateImage +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}");
      var _request = https.MultipartRequest('POST', uri);
      //===================== Multiple List Image ===========
      final List<https.MultipartFile> photos = <https.MultipartFile>[];
      /* if (files!= null && files.length > 0) {
        await Future.forEach(files, (File file) async {
          var photo = await https.MultipartFile.fromPath("imageFile[]", file.path);
          photos.add(photo);
        });
      }*/
      /*images.forEach((imageAsset) async {
        final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
        print('images  ##=${filePath}');

        File tempFile = File(filePath);
        uploadImage(tempFile);

      });*/
      for (var imageAsset in images)  {
         final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
          print('images  ##=${filePath}');
        print('uploadImage_Update filePath=${imageAsset}');

         File tempFile = File(filePath);
        print('uploadImage_Update tempFile=${tempFile.path}');
        print('Image getFileSizeString imageAsset Output Size=${getFileSizeString(tempFile.lengthSync(),0)}');
        File compressedFile;
        try {
          compressedFile = await FlutterNativeImage.compressImage(
              tempFile.path,
              quality: 20, percentage: 60);
          print('uploadImage_Update compressedFile=${compressedFile.path}');
        }catch(error){
          print('uploadImage_Update catch compressedFile error=${error}');
          compressedFile=File(tempFile.path);
        }
        print('Image getFileSizeString  compressedFile Output Size=${getFileSizeString( compressedFile.lengthSync(),0)}');


        var photo = await https.MultipartFile.fromPath("imageFile[]", compressedFile.path);

        photos.add(photo);
      }
      //_request.files.add(await https.MultipartFile.fromPath('imageFile[]', cropped.path));
      _request.files.addAll(photos);

      print("uploadImage_Update ------request------" + _request.toString());
      var streamedResponse = await _request.send();
      print("uploadImage_Update -----ssssssss-----"+streamedResponse.reasonPhrase.toString());
      https.Response res = await https.Response.fromStream(streamedResponse);
      print('uploadImage_Update response.body ' + res.statusCode.toString());
      print("uploadImage_Update -----respnse----" + res.body.toString());
      _hideProgress();

      if (res.statusCode == 200) {

        var bodydata = json.decode(res.body);
        _hideProgress();
        if (bodydata["status"]) {
          // print('uploadImage_Update bodydata["status"] =${bodydata["status"]}\nfiles.length=${files.length}\n counbt=$count');
          // if(files.length==count) {
          print('uploadImage_Update condition match files.length=${files.length}');
          UtilMethod.SnackBarMessage(_scaffoldKey, AppLocalizations.of(context).translate("Successful upload image"));

          try {
            setState(() async {
              for (var imageAsset in images) {
                final filePath = await FlutterAbsolutePath.getAbsolutePath(
                    imageAsset.identifier);
                print('images  ##=${filePath}');
                print('uploadImage_Update success Upload filePath=${imageAsset}');

                File tempFile = File(filePath);
                files.add(tempFile);
                _imagesSum();
              }
            });

          }catch(error){
            print('uploadImage_Update success Upload catch filePath error=${error}');
          }

        }
        else {
          _hideProgress();
          // UtilMethod.SnackBarMessage(_scaffoldKey, bodydata["message"]);
          ShowDialogError.showDialogErrorMessage(context, "Alert", bodydata["message"], res.statusCode, 'error', MQ_Width, MQ_Height);
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
      ShowDialogError.showDialogErrorMessage(context, "Exception error", e.toString(), 0, 'error', MQ_Width, MQ_Height);
    }
  }

  String getFileSizeString(int bytes, int decimals) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  Future<https.Response> _deleteImage(int index, BuildContext context) async {
    try {
      _showProgress(context);
      print('routeData[index]["id"].toString()=${routeData[index]["id"].toString()}');
      Map jsondata = {"image_id": routeData[index]["id"].toString()};
      String url =
          WebServices.GetDeleteImage + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      var response = await https.post(Uri.parse(url),
          body: jsondata, encoding: Encoding.getByName("utf-8"));
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          Navigator.pop(context);
          setState(() {
            routeData.removeAt(index);
          });
          _imagesSum();

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
}
