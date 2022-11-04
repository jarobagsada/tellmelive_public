import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:image_cropper/image_cropper.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:http/http.dart' as https;
import 'package:http/http.dart' as http;
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/showtoast_widgets.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
//import 'package:multi_image_picker/multi_image_picker.dart';
//import 'package:multiple_image_picker/multiple_image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../utilmethod/helper.dart';
import 'package:numberpicker/numberpicker.dart';

import '../utilmethod/showDialog_Error.dart';

class Gallery_Screen extends StatefulWidget {
  @override
  _Gallery_ScreenState createState() => _Gallery_ScreenState();
}

class _Gallery_ScreenState extends State<Gallery_Screen> {
  Size _screenSize;
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  ProgressDialog progressDialog;
 // List<Asset> files = [];
  List<File> files = [];
  bool showLoading;

  var routeData;
  var MQ_Height;
  var MQ_Width;
  final homePageKey = GlobalKey<_Gallery_ScreenState>();

  @override
  void initState() {
    super.initState();
    showLoading = false;
  }

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    _screenSize = MediaQuery.of(context).size;
    routeData = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    print("---routedata-----" + routeData.toString());
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body:Stack(
          children: [
         //   _widgetGalleryUI()
            _widgetGalleryNewUI()
          ],
        ),
      ),
    );
  }

  //=========== Old UI ========
  Widget _widgetGalleryUI(){
    return  Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assest/images/hello.jpg"),
            fit: BoxFit.fill
        ),

      ),
      child: Stack(

        children: [
          Padding(
            padding: const EdgeInsets.only(top: 90, left: 26, right: 26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                            //     loadAssets();
                            _showModalBottomSheet(context);
                          },
                          text: AppLocalizations.of(context)
                              .translate("Add photos"),
                          textColor: Custom_color.WhiteColor,

                          fontFamily: "OpenSans Bold"),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(child: buildGridView()),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                CustomWigdet.RoundRaisedButton(
                    onPress: () async {
                      // OnSubmit(context);
                      if (await UtilMethod.SimpleCheckInternetConnection(
                          context, _scaffoldKey)) {
                        if(files.length<=10){
                          UtilMethod.isStringNullOrBlank(routeData["facbook_id"])
                              ? uploadImage()
                              : uploadImageByFacebook(routeData["facbook_id"]);
                        }
                        else{
                          UtilMethod.SnackBarMessage(
                              _scaffoldKey,
                              AppLocalizations.of(context)
                                  .translate("Not more than limit 10 images"));
                        }

                      }
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
    );
  }


  //=========== New UI ========
  Widget _widgetGalleryNewUI(){
    print('_widgetGalleryNewUI files.length=${files.length}');
    return  Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image:AssetImage("assest/images/background_img.jpg"), //AssetImage("assest/images/hello.jpg"),
            fit: BoxFit.fill
        ),

      ),
      child: Stack(

        children: [

          Container(
            padding: const EdgeInsets.only(top: 10,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
               false? InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.topRight,
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
                      padding: const EdgeInsets.only(left: 5.0,right: 10),
                      child: Text('SKIP',style: TextStyle( color: Custom_color.BlueLightColor,
                          fontSize: Helper.textSizeH11,
                          fontWeight: Helper.textFontH4,
                          fontFamily: "OpenSans Bold"),),
                    ),
                  ),
                ):Container(),
                SizedBox(
                  height: MQ_Height*0.08,
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

                Expanded(
                  child: Column(
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
                            //     loadAssets();
                            _showModalBottomSheet(context);
                          },
                          text: AppLocalizations.of(context)
                              .translate("Add photos"),
                          textColor: Custom_color.WhiteColor,

                          fontFamily: "OpenSans Bold"):
                     images.length<10 ?Container(
                       padding: EdgeInsets.only(left: 40, right: 40),
                       child: Stack(
                         children: <Widget>[
                           InkWell(
                             onTap: () {
                               _showModalBottomSheet(context);
                               //    _showDialogBox();
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
                                 width: MQ_Width*0.32,
                                 height:MQ_Height*0.15,

                               ),
                             ),

                           ),



                           Positioned.fill(
                               child: InkWell(
                                   borderRadius: BorderRadius.circular(50),
                                   onTap: () {
                                     _showModalBottomSheet(context);
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
                                                   _showModalBottomSheet(context);
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
                        height: MQ_Height*0.01,
                      ),
                      images.length!=0?Expanded(child: buildGridView()):Container(),
                      images.length!=0 ? SizedBox(
                        height: MQ_Height*0.01,
                      ):  SizedBox(
                        height: MQ_Height*0.06,
                      ),

                      CustomWigdet.RoundRaisedButton(
                          onPress: () async {
                            // OnSubmit(context);
                         print('files  files.length=${files.length}');


                            if(files.length!=0) {
                              if (await UtilMethod.SimpleCheckInternetConnection(context, _scaffoldKey)) {
                                if (files.length <= 10) {
                                  _showProgress(context);
                                  UtilMethod.isStringNullOrBlank(
                                      routeData["facbook_id"])
                                      ? uploadImage()
                                      : uploadImageByFacebook(
                                      routeData["facbook_id"]);

                                  /*for (int i=0; i< files.length; i++) {
                                    //final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.path);
                                    print('images  ##=${files[i].path}\n count=${i}');

                                    File tempFile = File(files[i].path);
                                    uploadImage_Update(tempFile,i);


                                  }*/
                                   int count=0;
                                  // images.forEach((imageAsset) async {
                                  //   final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
                                  //   print('images  ##=${filePath}');
                                  //
                                  //  File tempFile = File(filePath);
                                  //   count++;
                                  //   //uploadImage_Update(tempFile);
                                  // UploadImagesMultipart(tempFile);
                                  //
                                  // });

                                  //uploadImage_Update();

                                }
                                else {
                                  UtilMethod.SnackBarMessage(
                                      _scaffoldKey,
                                      AppLocalizations.of(context)
                                          .translate(
                                          "Not more than limit 10 images"));
                                }
                              }
                            }else{
                              UtilMethod.SnackBarMessage(
                                  _scaffoldKey,
                                  AppLocalizations.of(context)
                                      .translate(
                                      "Not more than limit 10 images"));
                            }
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

                SizedBox(
                  height: MQ_Height*0.02,
                )
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
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Container(
                      child: SvgPicture.asset('assest/images_svg/back.svg'),
                    ),
                  ),
                ),
              ),


            ),
          ): Positioned(
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

                     false? CustomWigdet.FlatButtonSimple(
                          onPress: () {
                            /*Navigator.pushNamed(
                              context,
                              Constant.ProfessionalRoute,
                            );*/

                            UtilMethod.isStringNullOrBlank(routeData["facbook_id"])
                                ? uploadImage()
                                : uploadImageByFacebook(routeData["facbook_id"]);
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
//              Flexible(
//                child: Container(
//                  width: _screenSize.width,
//                  height: 0.5,
//                  color: Custom_color.GreyLightColor,
//                ),
//              ),
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

  Widget buildGridView1() {
    print('buildGridView files.length=${files.length}');

    return GridView(
      shrinkWrap: true,
      /*crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,*/
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
        mainAxisSpacing: 10,),


      children: List.generate(

          files.length, (index) {

        return Stack(
          children: <Widget>[
            SizedBox(
              width: 300,
              height: 300,
              child:  Image.file (
                files[index],
                fit: BoxFit.cover,

              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: InkWell(
                onTap: (){
                  //   files.removeWhere((assest) => assest.name == files[index].name);

                     setState(() {
                       files.removeAt(index);
                     });

                },
                  child: Image(image:
                AssetImage("assest/images/close.png"),
                    width: 25,
                    height: 25,

              ),
              ),
            ),

          ],
        );
      }),




    );
  }

  Widget buildGridView() {
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,),
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return Stack(
          children: [
            AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            ),
            Positioned(
              top: 5,
              right: 5,
              child: InkWell(
                onTap: (){
                  //   files.removeWhere((assest) => assest.name == files[index].name);

                  setState(() {
                    images.removeAt(index);
                    files.removeAt(index);
                  });

                },
                child: Image(image:
                AssetImage("assest/images/close.png"),
                  width: 25,
                  height: 25,

                ),
              ),
            ),
          ],
        );
      }),
    );
  }



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
          showCropGrid: false),
      sourcePath: picked,
      aspectRatioPresets: [
        //   CropAspectRatioPreset.square,
        //    CropAspectRatioPreset.original,
        //    CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        //    CropAspectRatioPreset.ratio5x4,
        //   CropAspectRatioPreset.ratio16x9
      ],
      maxWidth: 900,
    );
    if (cropped != null) {
      if (mounted) {
        setState(() {
          files.add(cropped);
          //  file = cropped;
        });
      }
    }
  }

  Future<void> open_camera() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
   // var pickedFile = await ImagePicker.pickImage(source: ImageSource.camera);

    // print("-----path-------" + pickedFile.path.toString());
    if (pickedFile != null && pickedFile.path != null) {
      _cropImage(pickedFile.path);
    }
  }

  Future<void> open_gallery() async {
   // var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
   // var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
   // final ImagePicker _picker = ImagePicker();
   // final List<XFile> pickedFile = await _picker.pickMultiImage();
   // final List<XFile> images = await _picker.pickMultiImage(source: ImageSource.gallery);
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
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
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
    });

    if(files.length!=0){
      files.clear();

    }

    setState(() {
      print('images  ##=${images}');
      images.forEach((imageAsset) async {
        final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
        print('images  ##=${filePath}');

        File tempFile = File(filePath);
         if (tempFile.existsSync()) {
        print('images tempFile ##=${tempFile}');
        files.add(tempFile);
          }

      });
    });





      //files.addAll(images);
      // _error = error;




    //  var pickedFile = await ImagePicker.


    //final List<File> pickedFile = await ().pickMultiImage();
   // var image = await ImagePicker.pickImage(source: ImageSource.camera, numberOfItems: 1);


   /* if (pickedFile != null && pickedFile.path != null) {
      _cropImage(pickedFile.path);
    }*/
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


  Future<void> uploadImage() async {
    print("-------inside without facbook-----");
    try {
      _showProgress(context);
      Uri uri = Uri.parse(WebServices.UploadImages + "?language=${SessionManager.getString(Constant.Language_code)}");

      var _request = https.MultipartRequest('POST', uri);

      //============== one by one image ==========
       /* // if (images != null && images.length > 0) {
        for (File asset in files) {
        //  final filePath = await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
        //  File image = (await FlutterExifRotation.rotateImage(path: asset.path));

          if (asset.path != null) {
            print("uploadImage ------request   Galley asset.path------" + asset.path);

            _request.files.add(await https.MultipartFile.fromPath('imageFile[]', asset.path));
          }
        }
    //  }*/

      //=================== Multiple Byte type image ===========
      /*List<MultipartFile> newList = new List<MultipartFile>();
      final List<https.MultipartFile> photos = <https.MultipartFile>[];
      for (int i = 0; i < files.length; i++) {
        var path = await FlutterAbsolutePath.getAbsolutePath(files[i].path);
        File imageFile =  File(path);
        print("uploadImage ------imageFile------= $imageFile");
        var stream =new https.ByteStream(imageFile.openRead());
        print("uploadImage ------stream------= $stream");

        var length = await imageFile.length();
        print("uploadImage ------length------= $length");

        // var multipartFile = new https.MultipartFile("imageFile[]", imageFile.path, length,
        //    // filename: basename(imageFile.path)
        // );
       // newList.add(multipartFile);
        var photo = await https.MultipartFile.fromPath("imageFile[]", imageFile.path);
        photos.add(photo);
      }*/

  //===================== Multiple List Image ===========
      final List<https.MultipartFile> photos = <https.MultipartFile>[];

      for (var imageAsset in files)  {
        // final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
        //  print('images  ##=${filePath}');
        print('uploadImage filePath=${imageAsset}');

        // File tempFile = File(filePath);
        print('uploadImage tempFile=${imageAsset.path}');
        print('uploadImage getFileSizeString imageAsset Output Size=${getFileSizeString(imageAsset.lengthSync(),0)}');
        File compressedFile;
        try {
          compressedFile = await FlutterNativeImage.compressImage(
              imageAsset.path,
              quality: 20, percentage: 60);
          print('uploadImage compressedFile=${compressedFile.path}');
        }catch(error){
          print('uploadImage catch compressedFile error=${error}');
          compressedFile=File(imageAsset.path);
        }
        print('uploadImage getFileSizeString  compressedFile Output Size=${getFileSizeString( compressedFile.lengthSync(),0)}');

        var photo = await https.MultipartFile.fromPath("imageFile[]", compressedFile.path);

        photos.add(photo);

      }

      _request.files.add(await https.MultipartFile.fromPath('profile_img[]', routeData["profile_img"]));
      _request.fields["Customer[name]"] = routeData["firstname"];
      _request.fields["Customer[mobile_code]"] = routeData["countryCode"].toString();
      _request.fields["Customer[mobile_no]"] = routeData["mobile_no"];
      _request.fields["Customer[dob]"] = routeData["dob"];
      _request.fields["Customer[email]"] = routeData["email"];
      _request.fields["Customer[type]"] = routeData["gender"]; //gender
      _request.fields["Customer[access]"] = routeData["access"]; //phone facebook
      _request.fields["Customer[interest]"] = "0"; //0,1,2,3
      _request.fields["Customer[password]"] = "123456";
      _request.fields["Customer[gender]"] = routeData["gender"];
      _request.fields["Customer[device_type]"] = routeData["device_type"];
      _request.fields["Customer[device_id]"] = routeData["device_id"];
     // _request.fields["Customer[about_me]"] = routeData["about_me"];
      _request.files.addAll(photos);

      print("uploadImage ------request------" + _request.toString());
      print("uploadImage ------request   profile Img ------" + routeData["profile_img"]);

      var streamedResponse = await _request.send();
      https.Response res = await https.Response.fromStream(streamedResponse).timeout(Duration(seconds: 5));
      print('response.body ' + res.statusCode.toString());
      print("-----respnse----" + res.body.toString());
      _hideProgress();
      if (res.statusCode == 200) {
        var bodydata = json.decode(res.body);

        if (bodydata["status"]) {
          var data = bodydata["data"];
          SessionManager.setString(Constant.LogingId, data["id"].toString());
          SessionManager.setString(Constant.Token, data["token"].toString());
          SessionManager.setString(Constant.Interested, data["interest"].toString());
          SessionManager.setString(Constant.Name, data["name"].toString().toString());
          SessionManager.setString(Constant.Profile_img, data["profile_img"].toString());
          SessionManager.setString(Constant.Email, data["email"].toString());
          SessionManager.setString(Constant.Dob, data["dob"].toString());
          SessionManager.setString(Constant.Country_code, data["mobile_code"].toString());
          SessionManager.setString(Constant.Mobile_no, data["mobile_no"].toString());
       //   SessionManager.setString(Constant.ChatCount, data["chatcount"].toString());
        //    SessionManager.setString(Constant.NotificationCount, data["notification_count"].toString());

          UtilMethod.SetChatCount(context, data["chatcount"].toString());
          UtilMethod.SetNotificationCount(context, data["notification_count"].toString());


    //================== old switch page ==================
         /* SessionManager.setboolean(Constant.AlreadyRegister, false);

          Navigator.of(context).pushNamedAndRemoveUntil(
            Constant.WelcomeRoute, (Route<dynamic> route) => false,

//              arguments: {
//                "name": data["name"],
//                "profile_img": data["profile_img"],
//                "token": data["token"],
//                "mobile_no": data["mobile_no"]
//              }
          );*/

          _hideProgress();
//==================== New Switch page ========
          _showDialogSuccessRegister();

//          Navigator.pushNamed(context, Constant.WelcomeRoute, arguments: {
//            "name": data["name"],
//            "profile_img": data["profile_img"],
//            "token": data["token"],
//            "mobile_no": data["mobile_no"]
//          });
        }else{
          _hideProgress();
          try {
            var data = bodydata;
            var Status = data['status'];
            String MSG = data['message'];

            if (Status == false) {
              ShowDialogError.showDialogErrorMessage(context, "Alert Error", MSG, res.statusCode , 'Register', MQ_Width, MQ_Height);
            }else{
              ShowDialogError.showDialogErrorMessage(context, "Alert Error", MSG, res.statusCode , 'Register', MQ_Width, MQ_Height);
            }
          }catch(error){
            print('Gallery Post error==$error');
            var MSG = "Data response something went wrong.Please try again later !";
            ShowDialogError.showDialogErrorMessage(context, "Alert Error", MSG, res.statusCode , 'Register', MQ_Width, MQ_Height);
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

//      {
//        "status": true,
//    "data": {
//    "id": 8,
//    "mobile_code": "+91",
//    "mobile_no": "1232s43243",
//    "name": "shakeel",
//    "dob": "12-12-1992",
//    "email": "shakeel.saifi@leanport.info",
//    "type": "1",
//    "access": "0",
//    "interest": "1",
//    "password": "123456",
//    "facebook_id": null,
//    "gender": "0",
//    "profile_img": "5ec751443f6b8.png",
//    "token": "UwamiA6bKrtgEObgJ_dJwkzcUwCEmzEC",
//    "device_id": "sfdsgdsfdsfds",
//    "device_type": "0",
//    "user_ip": "108.167.189.23",
//    "latitude": "29.8324",
//    "longitude": "-95.4720",
//    "created_at": 1590120772,
//    "updated_at": 1590120772
//    }
//  }

//      Facebook -1
//      Mobile - 0
//
      //  default-0
//      Man-1
//      Woman-2
      //both -3
//
//      Android -0
//      Ios--1

    } on Expanded catch (e) {
      print(e.toString());
      _hideProgress();

      ShowDialogError.showDialogErrorMessage(context, "Exception Error", '$e', 'Exception' , 'Register', MQ_Width, MQ_Height);
    }
  }

  Future<void> uploadImageByFacebook(String facbook_id) async {
    try {
      _showProgress(context);
      print("-----inside facebook-----");
      Uri uri = Uri.parse(WebServices.RegisterByFacebook + "?language=${SessionManager.getString(Constant.Language_code)}");
      var _request = https.MultipartRequest('POST', uri);
      // if (images != null && images.length > 0)
      {
        for (File asset in files) {
       //   final filePath =
        //      await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
          //  print("-----filepath------" + filePath);

          if (asset.path != null) {
            _request.files
                .add(await https.MultipartFile.fromPath('imageFile[]', asset.path));
          }

        }
      }
      _request.files
          .add(await https.MultipartFile.fromPath('profile_img[]', routeData["profile_img"]));
      _request.fields["Customer[facebook_id]"] = facbook_id;
      _request.fields["Customer[name]"] = routeData["firstname"];
      _request.fields["Customer[mobile_code]"] =
          routeData["countryCode"].toString();
      _request.fields["Customer[mobile_no]"] = routeData["mobile_no"];
      _request.fields["Customer[dob]"] = routeData["dob"];
      _request.fields["Customer[email]"] = routeData["email"];
      _request.fields["Customer[type]"] = routeData["gender"]; //gender
      _request.fields["Customer[access]"] =
          routeData["access"]; //phone facebook
      _request.fields["Customer[interest]"] = "0"; //0,1,2,3
      _request.fields["Customer[password]"] = "123456";
      _request.fields["Customer[gender]"] = routeData["gender"];
      _request.fields["Customer[device_type]"] = routeData["device_type"];
      _request.fields["Customer[device_id]"] = routeData["device_id"];
    //  _request.fields["Customer[about_me]"] = routeData["about_me"];

      print("------request------" + _request.toString());
      print("------request Body------" + _request.toString());


      var streamedResponse = await _request.send();
      https.Response res = await https.Response.fromStream(streamedResponse);
      print('response.body ' + res.statusCode.toString());
      print("-----respnse----" + res.body.toString());
      _hideProgress();
      if (res.statusCode == 200) {
        var bodydata = json.decode(res.body);
        if (bodydata["status"]) {
          var data = bodydata["data"];
          print("-----token---" + data["token"]);
          SessionManager.setString(Constant.LogingId, data["id"].toString());
          SessionManager.setString(Constant.Token, data["token"].toString());
          SessionManager.setString(
              Constant.Interested, data["interest"].toString());
          SessionManager.setString(Constant.Name, data["name"].toString());
          SessionManager.setString(
              Constant.Profile_img, data["profile_img"].toString());
          SessionManager.setString(Constant.Mobile_no, data["mobile_no"].toString());
          SessionManager.setString(Constant.Country_code, data["mobile_code"].toString());
          SessionManager.setString(Constant.Email, data["email"].toString());
          SessionManager.setString(Constant.Dob, data["dob"].toString());
         // SessionManager.setString(Constant.ChatCount, data["chatcount"].toString());
         // SessionManager.setString(Constant.NotificationCount, data["notification_count"].toString());
          UtilMethod.SetChatCount(context, data["chatcount"].toString());
          UtilMethod.SetNotificationCount(context, data["notification_count"].toString());
          //============== Old Switch Page =========
         /* SessionManager.setboolean(Constant.AlreadyRegister, false);
          Navigator.of(context).pushNamedAndRemoveUntil(
            Constant.WelcomeRoute, (Route<dynamic> route) => false,
//              arguments: {
//                "name": data["name"],
//                "profile_img": data["profile_img"],
//                "token": data["token"],
//                "mobile_no": data["mobile_no"]
//              }
          );*/
//=============== New Switch Page ==============

          Navigator.pushNamed(
            context,
           // Constant.ProfessionalRoute,
            Constant.UserAboutMeScreen
          );
        }
      }
    } on Expanded catch (e) {
      print(e.toString());
      _hideProgress();
      ShowDialogError.showDialogErrorMessage(context, "Exception error", e.toString(), 0, 'error', MQ_Width, MQ_Height);
    }
  }


  Future<https.Response> _deleteImage() async {
    try {
      _showProgress(context);
      Map jsondata = {"image_id": ""};
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
          //  Navigator.pop(context,true);
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

      for (var imageAsset in files)  {
       // final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
      //  print('images  ##=${filePath}');
        print('uploadImage_Update filePath=${imageAsset}');

       // File tempFile = File(filePath);
        print('uploadImage_Update tempFile=${imageAsset.path}');
        print('Image getFileSizeString imageAsset Output Size=${getFileSizeString(imageAsset.lengthSync(),0)}');
        File compressedFile;
        try {
           compressedFile = await FlutterNativeImage.compressImage(
              imageAsset.path,
              quality: 20, percentage: 60);
          print('uploadImage_Update compressedFile=${compressedFile.path}');
        }catch(error){
          print('uploadImage_Update catch compressedFile error=${error}');
           compressedFile=File(imageAsset.path);
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

            /*Navigator.pushNamed(
                context,
                // Constant.ProfessionalRoute,
                Constant.UserAboutMeScreen
            );*/
            // setState(() {
            //   files.add(cropped);
            // });
            // _imagesSum();
         //}

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

  //================= post Multipart =======

  Future<void> UploadImagesMultipart(var FileImg)async{
    try {
      print('uploadImage_Update response.body FileImg=' + FileImg);
      Uri uri = Uri.parse(WebServices.GetUpdateImage +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}");
      var request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('imageFile[]',FileImg));
      // request.files.add(await http.MultipartFile.fromPath('imageFile[]',
      //     '/Users/kdpro/Dropbox/My Mac (KD’s iMac)/Downloads/screen02.jpg'));
      // request.files.add(await http.MultipartFile.fromPath('imageFile[]',
      //     '/Users/kdpro/Dropbox/My Mac (KD’s iMac)/Downloads/screen03.jpg'));
      // request.files.add(await http.MultipartFile.fromPath('imageFile[]',
      //     '/Users/kdpro/Dropbox/My Mac (KD’s iMac)/Downloads/screen04.jpg'));





      http.StreamedResponse res = await request.send();
      print('uploadImage_Update response.body ' + res.statusCode.toString());

      if (res.statusCode == 200) {
        print(await res.stream.bytesToString());
        print('uploadImage_Update condition match res.stream=${res.stream.bytesToString()}');
        UtilMethod.SnackBarMessage(_scaffoldKey, AppLocalizations.of(context).translate("Successful upload image"));

        /*var bodydata = json.decode(res.body);
        _hideProgress();
        if (bodydata["status"]) {
          // print('uploadImage_Update bodydata["status"] =${bodydata["status"]}\nfiles.length=${files.length}\n counbt=$count');
          // if(files.length==count) {
          print('uploadImage_Update condition match files.length=${files.length}');
          UtilMethod.SnackBarMessage(_scaffoldKey, AppLocalizations.of(context).translate("Successful upload image"));

          // Navigator.pushNamed(
          //       context,
          //       // Constant.ProfessionalRoute,
          //       Constant.UserAboutMeScreen
          //   );

          // setState(() {
          //   files.add(cropped);
          // });
          // _imagesSum();
          //}

        }
        else {
          _hideProgress();
          // UtilMethod.SnackBarMessage(_scaffoldKey, bodydata["message"]);
          ShowDialogError.showDialogErrorMessage(context, "Alert", bodydata["message"], res.statusCode, 'error', MQ_Width, MQ_Height);
        }*/
      }
      else {
        print(res.reasonPhrase);
      }
    }catch(error){

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




  Future<void> _showDialogSuccessRegister()async{

    await showDialog(context: context,
        builder: (BuildContext context){
          return WillPopScope(
            onWillPop: ()async{
              return Future.value(false);
            },
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Helper.avatarRadius),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Stack(
                  children: [

                    Container(
                      padding: EdgeInsets.only(left: Helper.padding,top: Helper.avatarRadius
                          + Helper.padding, right: Helper.padding,bottom: Helper.padding
                      ),
                      margin: EdgeInsets.only(top: Helper.avatarRadius),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Text('Location',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                          SizedBox(height: MQ_Height*0.02,),
                          Container(
                            alignment: Alignment.center,
                            child: CustomWigdet.TextView(
                              // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                                overflow: true,
                                text: AppLocalizations
                                    .of(context)
                                    .translate(
                                    'Congratulations'),
                                fontFamily: "Kelvetica Nobis",
                                fontSize: Helper.textSizeH11,
                                fontWeight: Helper.textFontH4,
                                color: Helper.textColorBlueH1
                            ),
                          ),
                          SizedBox(height: MQ_Height*0.01,),
                          Container(
                            alignment: Alignment.center,
                            child: CustomWigdet.TextView(
                              // text: isLocationEnabled?'You turn off the location':'You turn on the location',//AppLocalizations.of(context).translate("Create Activity"),
                              overflow: true,
                              text: AppLocalizations
                                  .of(context)
                                  .translate(
                                  'Your account has been successfully created'),
                              fontFamily: "Kelvetica Nobis",
                              fontSize: Helper.textSizeH12,
                              fontWeight: Helper.textFontH5,
                              color: Color(Helper.textColorBlackH2),
                            ),
                          ),
                          SizedBox(height: MQ_Height*0.02,),

                          false?Container(
                            alignment: Alignment.bottomCenter,
                            margin:  EdgeInsets.only(left:MQ_Width *0.06,right: MQ_Width * 0.06,top: MQ_Height * 0.02,bottom: MQ_Height * 0.01 ),
                            padding: EdgeInsets.only(bottom: 5),
                            height: 60,
                            width: MQ_Width*0.30,
                            decoration: BoxDecoration(
                              color: Color(Helper.ButtonBorderPinkColor),
                              border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FlatButton(
                              onPressed: ()async{

                              },
                              child: Text(
                                // isLocationEnabled?'CLOSE':'OPEN',
                                'Ok',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH11,fontWeight:Helper.textFontH5),
                              ),
                            ),
                          ):Container(),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(left: 0,
                                      right: 0,
                                      top: MQ_Height * 0.02,
                                      bottom: 2),
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
                                      Navigator.pushNamed(
                                          context,
                                          //  Constant.ProfessionalRoute,
                                          Constant.UserAboutMeScreen
                                      );

                                    },
                                    child: Text(
                                      // isLocationEnabled?'CLOSE':'OPEN',
                                      AppLocalizations.of(context)
                                          .translate("Continue")
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(Helper.ButtontextColor),fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH14,fontWeight:Helper.textFontH5),
                                    ),
                                  ),
                                ),
                                //  SizedBox(width: MQ_Width*0.01,),
                                false?Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(left: 0,
                                      right: 0,
                                      top: MQ_Height * 0.02,
                                      bottom:2),
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
                                ):Container(),



                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                        left: Helper.padding,
                        right: Helper.padding,

                        child: false?Container(
                          height: 150,
                          width: 150,
                          padding: EdgeInsets.all(15),
                          // margin: EdgeInsets.only(bottom: MQ_Height*0.05),

                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,

                                colors: [
                                  // Color(0XFF8134AF),
                                  // Color(0XFFDD2A7B),
                                  // Color(0XFFFEDA77),
                                  // Color(0XFFF58529),
                                  Colors.blue.withOpacity(0.4),
                                  Colors.blue.withOpacity(0.3),

                                ],
                              ),
                              shape: BoxShape.circle
                          ),
                          child: Container(
                            // margin: EdgeInsets.only(bottom: 15),

                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: Helper.avatarRadius,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(Helper.avatarRadius)),
                                  child: Image(image: AssetImage("assest/images/map.png"),
                                  )
                              ),
                            ),
                          ),
                        ):
                        CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.3),
                          radius: 55,
                          child: false?CircleAvatar(
                            radius: 45,
                            // backgroundImage: image!=null?NetworkImage(image):AssetImage("assest/images/user2.png"),

                          ):Container(
                              margin: EdgeInsets.all(2),
                              height: 85,
                              width:85,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1000),

                                //shape: BoxShape.circle
                              ),
                              child: Icon(Icons.task_alt_rounded,size: 60)),
                        )),

                  ],),
              ),
            ),
          );
        });
  }
}
