import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

import '../../../utilmethod/helper.dart';

class ProfileImage extends StatefulWidget {
  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  Size _screenSize;
  File _image_file;
  var routeData;
  int indexTab=0;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ProgressDialog progressDialog;
  String profile_Image;

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
    _screenSize = MediaQuery.of(context).size;
    routeData = ModalRoute.of(context).settings.arguments;
    if (routeData["profile_img"] != null) {
      profile_Image = routeData["profile_img"];
      indexTab=routeData["index"];
    }
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,

          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assest/images/background_img.jpg'),//AssetImage("assest/images/hello.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: <Widget>[
                          CustomWigdet.TextView(
                              fontSize: 20,
                              fontFamily: "Kelvetica Nobis",
                              text: AppLocalizations.of(context)
                                  .translate("Add your best photos"),
                              color: Color(0xff1e63b0)),
                          SizedBox(
                            height: 10,
                          ),
                          CustomWigdet.TextView(
                              text: AppLocalizations.of(context)
                                  .translate("This will be your profile photo"),
                              fontSize: 14,
                              fontFamily: "Kelvetica Nobis",
                              textAlign: TextAlign.center,
                              color: Custom_color.BlackTextColor,),
                          SizedBox(
                            height: 20,
                          ),

                          Container(
                            padding: EdgeInsets.only(left: 30,right: 30,top: 30,bottom: 0),
                            decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                   // bottomLeft: Radius.circular(30),
                                   // bottomRight: Radius.circular(30)
                                )),
                            child: Stack(
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    _showModalBottomSheet(context);                        },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Custom_color.GreyColor,
                                        borderRadius: BorderRadius.circular(8)),
                                    width: _screenSize.width,
                                    height: _screenSize.height / 2 - 100,
                                    child: Image.asset(
                                      routeData["gender"] == 0
                                          ? "assest/images/men.png"
                                          : "assest/images/women.png",
                                      alignment: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        _showModalBottomSheet(context)();
                                      },
                                      child: Center(
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                              color: Custom_color.BlueLightColor,
                                              shape: BoxShape.circle
                                          ),
                                          child: Icon(
                                            Icons.add_to_photos,
                                            size: 30,
                                            color: Custom_color.WhiteColor,
                                          ),
                                        ),
                                      ),
                                    )),
                                _image_file != null
                                    ? InkWell(
                                        onTap: () {
                                         // _showModalBottomSheet(context);
                                        },
                                        child: Container(
                                          width: _screenSize.width,
                                          height: _screenSize.height / 2 - 100,
                                          child: Image.file(
                                            _image_file,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : profile_Image != null
                                        ? InkWell(
                                            onTap: () {
                                            //  _showModalBottomSheet(context);
                                            },
                                            child: Container(
                                              width: _screenSize.width,
                                              height: _screenSize.height / 2 - 100,
                                              child: Image.network(
                                                profile_Image,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Container()
                              ],
                            ),
                          ),

                          //SizedBox(height: 20,),
                          InkWell(
                            child: Container(
                              width: _screenSize.width*0.92,
                              padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                              decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.5),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30)
                                  )
                              ),
                              child: Text(
                                AppLocalizations.of(context).translate('Change Photo').toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white,fontWeight: Helper.textFontH4,fontSize: Helper.textSizeH14),
                              ),
                            ),
                            onTap: ()async{
                              _showModalBottomSheet(context);
                            },
                          ),

                          SizedBox(
                            height: 50,
                          ),
                          CustomWigdet.RoundRaisedButton(
                              onPress: () async {
                                Navigator.pushNamed(context, Constant.MyGalleryPage,
                                    arguments:{'imagelist':routeData["imagelist"] != null
                                        ? routeData["imagelist"]
                                        : routeData["imagelist"] = [],
                                        "index":indexTab
                                       });
                              },
                              text: AppLocalizations.of(context)
                                  .translate("Continue")
                                  .toUpperCase(),
                              textColor: Custom_color.WhiteColor,
                              bgcolor: Custom_color.BlueLightColor,
                              fontSize:Helper.textSizeH12,
                              fontWeight:Helper.textFontH5,
                              fontFamily: "OpenSans Bold"),




                        ],
                      ),
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
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10,left: 10),
          child: Center(
              child: CustomWigdet.FlatButtonSimple(
                  onPress: () {
                    Navigator.pushNamed(context, Constant.MyGalleryPage,
                        arguments: routeData["imagelist"] != null
                            ? routeData["imagelist"]
                            : routeData["imagelist"] = []);
                  },
                  text: AppLocalizations.of(context)
                      .translate("skip")
                      .toUpperCase(),
                  textColor: Custom_color.BlueLightColor,
                  fontFamily: "OpenSans Bold")),
        ),
      ],
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
          Navigator.pop(context, true);
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
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(10.0)), //this right here
  //           child: Container(
  //             height: 100,
  //             child: Padding(
  //               padding: const EdgeInsets.all(16.0),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   InkWell(
  //                       onTap: () {
  //                       },
  //                       child: CustomWigdet.TextView(
  //                           text: AppLocalizations.of(context)
  //                               .translate("Take Photo from Camera"),
  //                           color: Custom_color.BlackTextColor,
  //                           fontFamily: "OpenSans Bold",
  //                           fontSize: 16)),
  //                   SizedBox(
  //                     height: 16,
  //                   ),
  //                   InkWell(
  //                       onTap: () {
  //                         open_gallery();
  //                         Navigator.pop(context);
  //                       },
  //                       child: CustomWigdet.TextView(
  //                           text: AppLocalizations.of(context)
  //                               .translate("Choose from Gallery"),
  //                           color: Custom_color.BlackTextColor,
  //                           fontFamily: "OpenSans Bold",
  //                           fontSize: 16)),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  // }

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
     //   if (_image_file != null) {
          uploadImage(cropped);
       // }
       // else {
       //   UtilMethod.SnackBarMessage(_scaffoldKey, AppLocalizations.of(context).translate("Please upload profile image"));
      //  }
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
    var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null && pickedFile.path != null) {
      _cropImage(pickedFile.path);
    }
  }

  Future<void> uploadImage(File cropped) async {
    try {
      _showProgress(context);
      Uri uri = Uri.parse(WebServices.GetUpdateImage +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}");
      var _request = https.MultipartRequest('POST', uri);
      //   if (images != null && images.length > 0)

      _request.files.add(await https.MultipartFile.fromPath(
          'profile_img[]', cropped.path));

      _request.fields["type"] = "1";

      print("------request------" + _request.toString());
      var streamedResponse = await _request.send();
      https.Response res = await https.Response.fromStream(streamedResponse);
      print('response.body ' + res.statusCode.toString());
      print("-----respnse----" + res.body.toString());
      _hideProgress();
      if (res.statusCode == 200) {
        var bodydata = json.decode(res.body);
        if (bodydata["status"]) {
          SessionManager.setString(Constant.Profile_img, bodydata["data"]["profile_img"].toString());
          UtilMethod.SetChatCount(context, bodydata["data"]["chatcount"].toString());
          UtilMethod.SetNotificationCount(context, bodydata["data"]["notification_count"].toString());
          UtilMethod.SnackBarMessage(_scaffoldKey, AppLocalizations.of(context).translate("Successful upload image"));

          setState(() {
            _image_file = cropped;
          });

        }
      }
    } on Expanded catch (e) {
      print(e.toString());
      _hideProgress();
    }
  }

  Future<https.Response> _GetProfile() async {
    try {
      String url =
          WebServices.GetProfile + SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("-----url-----" + url.toString());
      https.Response response = await https.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Cache-Control": "no-cache",
      });
      _hideProgress();
      print("respnse----" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {
          UtilMethod.SnackBarMessage(
              _scaffoldKey,
              AppLocalizations.of(context)
                  .translate("Successful upload image"));

          List image = data["image"] as List;
          if (image != null && image.length > 0) {
            routeData["imagelist"] = image;
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
      }
    } on Exception catch (e) {
      print(e.toString());
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
