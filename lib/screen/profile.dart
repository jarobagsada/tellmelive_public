import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../services/webservices.dart';
import '../utilmethod/helper.dart';
import '../utilmethod/preferences.dart';
import 'package:http/http.dart' as https;

import '../utilmethod/showDialog_Error.dart';

class ProfileImage_Screen extends StatefulWidget {
  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage_Screen> {
  Size _screenSize;
  File _image_file;
  var routeData ;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String profile_Image;
  var MQ_Height;
  var MQ_Width;
  ProgressDialog progressDialog;
  bool showLoading;
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


  @override
  Widget build(BuildContext context) {
    MQ_Width =MediaQuery.of(context).size.width;
    MQ_Height= MediaQuery.of(context).size.height;
    _screenSize = MediaQuery.of(context).size;
    routeData = ModalRoute.of(context).settings.arguments;
    print("-----route--------"+routeData.toString());
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body:Stack(
          children: [
            //_widgetProfileImage()
            _widgetProfileImageNewUI()
          ],
        ),
      ),
    );
  }
  //=============== Old UI ==================
  Widget _widgetProfileImage(){
    return  Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assest/images/hello.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [

          Container(

            padding: EdgeInsets.only(left: 40, right: 40),
            child: Column(

              children: <Widget>[

                SizedBox(
                  height: 140,
                ),
                Stack(
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
                          width: _screenSize.width,
                          height: _screenSize.height/2-100,

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

                                Image(image: AssetImage("assest/images/image.png"),width: 70,height: 70,),
                                CustomWigdet.TextView(
                                    overflow: true,
                                    text: AppLocalizations.of(context)
                                        .translate("Add your best photo"),
                                    fontSize: 25.0,
                                    textAlign: TextAlign.center,
                                    color: Color(0xffadadad),
                                    fontFamily: "Kelvetica Nobis"),
                                SizedBox(
                                  height: 10,
                                ),
                                CustomWigdet.TextView(
                                    text: AppLocalizations.of(context)
                                        .translate("This will be your profile photo"),
                                    fontSize: 14,
                                    textAlign: TextAlign.center,
                                    fontFamily: "Kelvetica Nobis",
                                    color: Color(0xff9a9a9a)),
                              ],
                            )
                        )),
                    _image_file != null
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
                    ):Container()
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                CustomWigdet.RoundRaisedButton(
                    onPress: () {

                      if(_image_file!=null) {
                        Navigator.pushNamed(context, Constant.GalleryRoute, arguments: {

                          "access": routeData["access"],
                          "countryCode": routeData["countryCode"],
                          "mobile_no": routeData["mobile_no"],
                          "firstname": routeData["firstname"],
                          "email": routeData["email"],
                          "dob": routeData["dob"],
                          "gender": routeData["gender"],
                          "device_id": routeData["device_id"],
                          "device_type": routeData["device_type"],
                          "facbook_id": routeData["facbook_id"],
                          "profile_img": _image_file.path.toString()
                        });
                      }
                      else
                      {
                        UtilMethod.SnackBarMessage(_scaffoldKey, AppLocalizations.of(context).translate("Please upload profile image"));
                      }
                    },
                    text: AppLocalizations.of(context)
                        .translate("Continue")
                        .toUpperCase(),
                    textColor: Custom_color.WhiteColor,
                    bgcolor: Custom_color.BlueLightColor,
                    fontFamily: "OpenSans Bold"),
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


  //================ New UI ============

  Widget _widgetProfileImageNewUI(){
    return  Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assest/images/background_img.jpg"),//AssetImage("assest/images/hello.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [

          Container(

          //  padding: EdgeInsets.only(left: 40, right: 40),
            child: Column(

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
                  height: MQ_Height*0.01,
                ),
                Container(
                  margin: EdgeInsets.only(left: MQ_Width*0.06,top: MQ_Height*0.05),

                  alignment: Alignment.center,
                  child: Text('Profile Image',
                    style: TextStyle(color:Color(Helper.textColorBlackH2),
                        fontFamily: "Kelvetica Nobis",
                        fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH2),),
                ),
                SizedBox(
                  height: MQ_Height*0.05,
                ),
                Container(
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
                          color: Color(0xfffb4592),//Custom_color.BlueLightColor,
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
                            width: _screenSize.width,
                            height: _screenSize.height/2-100,

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

                                  Image(image: AssetImage("assest/images/image.png"),width: 70,height: 70,),
                                  Container(
                                    width: MQ_Width*0.50,
                                    child: CustomWigdet.TextView(
                                        overflow: true,
                                        text: AppLocalizations.of(context)
                                            .translate("Add your best photo").toUpperCase(),
                                        fontSize: Helper.textSizeH8,
                                        fontWeight: Helper.textFontH4,
                                        textAlign: TextAlign.center,

                                        color: Color(0xffadadad),
                                        fontFamily: "Kelvetica Nobis"),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CustomWigdet.TextView(
                                      text: AppLocalizations.of(context)
                                          .translate("This will be your profile photo"),
                                      fontSize: Helper.textSizeH14,
                                      fontWeight: Helper.textFontH4,
                                      textAlign: TextAlign.center,
                                      fontFamily: "Kelvetica Nobis",
                                      color: Color(0xff9a9a9a)),
                                ],
                              )
                          )),
                      _image_file != null
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
                      ):Container()
                    ],
                  ),
                ),
                SizedBox(
                  height: MQ_Height*0.10,
                ),
                CustomWigdet.RoundRaisedButton(
                    onPress: () {

                      if(_image_file!=null) {
                        Navigator.pushNamed(context, Constant.GalleryRoute, arguments: {
                          "access": routeData["access"],
                          "countryCode": routeData["countryCode"],
                          "mobile_no": routeData["mobile_no"],
                          "firstname": routeData["firstname"],
                          "email": routeData["email"],
                          "dob": routeData["dob"],
                          "gender": routeData["gender"],
                          "device_id": routeData["device_id"],
                          "device_type": routeData["device_type"],
                          "facbook_id": routeData["facbook_id"],
                          "profile_img": _image_file.path.toString(),
                         // "about_me":routeData['about_me']
                        });
                       /* UtilMethod.isStringNullOrBlank(routeData["facbook_id"])
                            ? uploadImage()
                            : uploadImageByFacebook(routeData["facbook_id"]);*/
                      }
                      else
                      {
                        UtilMethod.SnackBarMessage(_scaffoldKey, AppLocalizations.of(context).translate("Please upload profile image"));
                      }
                    },
                    text: AppLocalizations.of(context)
                        .translate("Continue")
                        .toUpperCase(),
                    fontSize: Helper.textSizeH12,
                    fontWeight: Helper.textFontH4,
                    textColor: Custom_color.WhiteColor,
                    bgcolor: Custom_color.BlueLightColor,
                    fontFamily: "OpenSans Bold"),
              ],
            ),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
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
        ],
      ),
    );
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
//      actions: <Widget>[
//        Padding(
//          padding: const EdgeInsets.only(right: 10),
//          child: Center(
//              child: CustomWigdet.FlatButtonSimple(
//                  onPress: () {
//                    Navigator.pushNamed(
//                        context, Constant.MyGalleryPage,
//                        arguments: routeData["imagelist"]!=null? routeData["imagelist"]:routeData["imagelist"]=[]);
//                  },
//                  text: AppLocalizations.of(context)
//                      .translate("skip")
//                      .toUpperCase(),
//                  textColor: Custom_color.BlueLightColor,
//                  fontFamily: "OpenSans Bold")),
//        ),
//      ],
      bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: _screenSize.width,
                  height: 1,
                  color: Custom_color.BlueLightColor,
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



  // _showDialogBox() {
  //   return showDialog(
  //       barrierDismissible: true,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Dialog(
  //             backgroundColor: Colors.transparent,
  //             insetPadding: EdgeInsets.all(10),
  //             child: Stack(
  //               children: <Widget>[
  //                 Container(
  //                  // width: double.infinity,
  //                   height: 160,
  //                   decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(8),
  //                       color: Custom_color.WhiteColor
  //                   ),
  //               child: Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           ListTile(
  //                             dense: true,
  //                             onTap: (){
  //                               open_camera();
  //                               Navigator.pop(context);
  //                             },
  //                             leading: Image.asset("assest/images/ar-camera.png",width: 26,height: 26,color: Custom_color.BlackTextColor,),
  //                             title:  CustomWigdet.TextView(
  //                                 text: AppLocalizations.of(context)
  //                                     .translate("Take Photo from Camera"),
  //                                 color: Custom_color.BlackTextColor,
  //                                 fontFamily: "OpenSans Bold",
  //                                 fontSize: 16),
  //                           ),
  //                           ListTile(
  //                             dense: true,
  //                             onTap: (){
  //                               open_gallery();
  //                               Navigator.pop(context);
  //                             },
  //                             leading: Image.asset("assest/images/photo.png",width: 26,height: 26,color: Custom_color.BlackTextColor,),
  //                             title:  CustomWigdet.TextView(
  //                                 text: AppLocalizations.of(context)
  //                                     .translate("Choose from Gallery"),
  //                                 color: Custom_color.BlackTextColor,
  //                                 fontFamily: "OpenSans Bold",
  //                                 fontSize: 16),
  //                           ),
  //                         ],
  //                       ),
  //                 ),
  //               ],
  //             )
  //         );
  //       }
  //       );
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

  Future open_camera() async {
    var  pickedFile = await ImagePicker().getImage(source: ImageSource.camera);

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

//  Future open_camera() async {
//    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
//
//    // print("-----path-------" + pickedFile.path.toString());
//
//    if (pickedFile != null && pickedFile.path != null) {
//      File image = (await FlutterExifRotation.rotateImage(
//          path: pickedFile.path));
//
//      if (image.path != null) {
//        setState(() {
//          _image_file = File(image.path);
//        });
//      }
//    }
//  }
//
//  Future open_gallery() async {
//    final pickedFile =
//    await ImagePicker().getImage(source: ImageSource.gallery);
//    print("-----path-------" + pickedFile.path.toString());
//    if (pickedFile != null && pickedFile.path != null) {
//      File image = (await FlutterExifRotation.rotateImage(
//          path: pickedFile.path));
//
//      if (image.path != null) {
//        setState(() {
//          _image_file = File(image.path);
//        });
//      }
//    }
//  }



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
      // final List<https.MultipartFile> photos = <https.MultipartFile>[];
      // if (files!= null && files.length > 0) {
      //   await Future.forEach(files, (File file) async {
      //     var photo = await https.MultipartFile.fromPath("imageFile[]", file.path);
      //     photos.add(photo);
      //   });
      // }


      _request.files.add(await https.MultipartFile.fromPath('profile_img[]', _image_file.path.toString()));
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
    //  _request.files.addAll(photos);

      print("uploadImage ------request------" + _request.toString());
      //print("uploadImage ------request   profile Img ------" + routeData["profile_img"]);

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
//==================== New Switch page ========
          Navigator.pushNamed(
              context,
              //  Constant.ProfessionalRoute,
            Constant.GalleryRoute,
          );
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
      /*// if (images != null && images.length > 0){
        for (File asset in files) {
          //   final filePath =
          //      await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
          //  print("-----filepath------" + filePath);

          if (asset.path != null) {
            _request.files
                .add(await https.MultipartFile.fromPath('imageFile[]', asset.path));
          }

        }
     // }*/
     // _request.files.add(await https.MultipartFile.fromPath('profile_img[]', routeData["profile_img"]));
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
            Constant.GalleryRoute
          );
        }
      }
    } on Expanded catch (e) {
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
