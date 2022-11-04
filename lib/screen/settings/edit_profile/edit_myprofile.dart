import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/activity_holder.dart';
import 'package:miumiu/screen/pages/personal_page.dart';
import 'package:miumiu/screen/settings/edit_profile/edit_profile_new.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/helper.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

class Profile_Screen_n extends StatefulWidget {
 @override
 _Profile_Screen_nState createState() => _Profile_Screen_nState();
}

class _Profile_Screen_nState extends State<Profile_Screen_n> {
 Size _screenSize;
 var routeData;
 int _current = 0;
 var name,name_demo, interest, prof_interest, gender, dob,profile_image;
 String facebook="0", twitter="0", instagram="0", tiktok="0", linkedin="0" ;
 ProgressDialog progressDialog;
 List<dynamic> images = [];
 List<Activity_holder> activitylist = [];
 bool loading;
 List<dynamic> imagelist = [];
 GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


 @override
 void initState() {
   super.initState();
   loading = false;
   WidgetsBinding.instance.addPostFrameCallback((_) async {
     if (await UtilMethod.SimpleCheckInternetConnection(
         context, _scaffoldKey)) {
       _GetProfile();
     }
   });
 }
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
 Widget build(BuildContext context) {
   _screenSize = MediaQuery
       .of(context)
       .size;
   routeData = ModalRoute
       .of(context)
       .settings
       .arguments;


   return SafeArea(
     child: Scaffold(
         backgroundColor: Color(Helper.inBackgroundColor1),
       appBar: AppBar(
         backgroundColor: Colors.white,
         leading: IconButton(
           color: Colors.blue,

             onPressed: () {
              Navigator.pop(context);


                //Navigator.push( context, MaterialPageRoute( builder: (context) => Profile_Screen()  ));
             },

             icon: Icon(
             Icons.arrow_back,
                 size: 25,
           ),
         ),

         title: CustomWigdet.TextView(
             text: (AppLocalizations.of(context).translate("Edit Profile")),
             //
             textAlign: TextAlign.center,

             color: Helper.textColorBlueH1,//Custom_color.BlackTextColor,
             fontWeight: Helper.textFontH5,
             fontSize:Helper.textSizeH12,
             fontFamily: "OpenSans Bold"),
        // centerTitle: true,
         /*shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.only(
                 bottomRight: Radius.circular(30),
                 bottomLeft: Radius.circular(30))),*/
         actions: [
           //========== New UI Camera =======
           Container(
             padding: EdgeInsets.only(
                 top: 12, left: 14, right: 15),
             child: Row(
               mainAxisAlignment:
               MainAxisAlignment.spaceBetween,
               children: <Widget>[

                 InkWell(
                   // borderRadius: BorderRadius.circular(30.0),
                   child: Icon(
                     Icons.camera_alt,
                     color: Colors.blue.shade400,
                     size: 26,
                   ),
                   onTap: () {
                     Navigator.pushNamed(
                         context, Constant.ProfileImage,
                         arguments:{"gender":gender,"profile_img":profile_image,"imagelist":imagelist!=null?imagelist:[],'index':3}).then((
                         value) => _GetCallBackMethod(value));
                   },
                 ),
               ],
             ),
           ),
         ],

       ),


       key: _scaffoldKey,
       body: Visibility(
           visible: loading,
           replacement: Center(
             child: false?CircularProgressIndicator():
             Container(
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
           child: Container(
             child: Column(
               mainAxisSize: MainAxisSize.min,
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: <Widget>[
                 Expanded(
                   child: SingleChildScrollView(
                     child: Column(
                       children: <Widget>[
                         Stack(
                           children: [
                             Padding(
                               padding: const EdgeInsets.only(bottom:40),
                               child: Container(
                                   width: _screenSize.width,
                                   height: (_screenSize.height / 2.2),
                                   child: images.isNotEmpty? CarouselSlider.builder(
                                     itemCount: images==null?0: images.length,
                                     options: CarouselOptions(
                                         height: _screenSize.height,
                                         autoPlay: images.length==1?false:true,
                                         viewportFraction: 1.0,
                                         // aspectRatio: 2.0,
                                         // enlargeCenterPage: true,
                                         onPageChanged: (index, reason) {
                                           setState(() {
                                             _current = index;
                                           });
                                         }),
                                     itemBuilder: (context, index) {
                                       return Container(
                                           child: CustomWigdet.GetImagesNetwork(
                                               imgURL: images[index],
                                               boxFit: BoxFit.cover));
                                     },
                                   ):Container(
                                     color: Custom_color.PlacholderColor,
                                     child: Center(
                                       child: CustomWigdet.TextView(
                                         text: AppLocalizations.of(context).translate("Currently there is no gallery"),color: Custom_color.BlackTextColor
                                       ),
                                     ),
                                   )),
                             ),
                             Positioned(
                               bottom: 0.0,
                               //left: 0.0,
                               right: 10.0,
                               child: Container(
                                 //  padding: EdgeInsets.only(right: 14, bottom: 40),
                                 child: images.isNotEmpty? Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: images.map((url) {
                                     int index = images.indexOf(url);
                                     return Container(
                                       width: 8.0,
                                       height: 8.0,
                                       margin: EdgeInsets.symmetric(
                                           vertical: 10.0, horizontal: 2.0),
                                       decoration: BoxDecoration(
                                         shape: BoxShape.circle,
                                         color: _current == index
                                             ? Custom_color.BlueLightColor
                                             : Custom_color.WhiteColor,
                                       ),
                                     );
                                   }).toList(),
                                 ):Container(),
                               ),
                             ),
                             //======== Old new Camera =======
                             false?Container(
                               padding: EdgeInsets.only(
                                   top: 12, left: 14, right: 14),
                               child: Row(
                                 mainAxisAlignment:
                                 MainAxisAlignment.spaceBetween,
                                 children: <Widget>[

                                   InkWell(
                                     // borderRadius: BorderRadius.circular(30.0),
                                     child: Icon(
                                       Icons.camera_alt,
                                       color: Custom_color.BlueLightColor,
                                     ),
                                     onTap: () {
                                       Navigator.pushNamed(
                                           context, Constant.ProfileImage,
                                           arguments:{"gender":gender,"profile_img":profile_image,"imagelist":imagelist!=null?imagelist:[]}).then((
                                           value) => _GetCallBackMethod(value));
                                     },
                                   ),
                                 ],
                               ),
                             ):Container(),
                            !UtilMethod.isStringNullOrBlank(profile_image) ?Positioned.fill(
                               child: Align(
                                 alignment: Alignment.bottomLeft,
                                 child: Column(
                                   mainAxisAlignment:
                                   MainAxisAlignment.start,
                                   mainAxisSize: MainAxisSize.min,
                                   children: <Widget>[
                                     false?Container(
                                       child: Container(
                                         height: 80.0,
                                         width: 80.0,
                                         margin: EdgeInsets.only(left: 14),
                                         decoration: BoxDecoration(
                                           color: Custom_color.PlacholderColor,
                                           image: new DecorationImage(
                                             fit: BoxFit.cover,
                                             image: NetworkImage(profile_image,scale: 1.0),
                                           ),
                                           shape: BoxShape.circle,
                                           border: Border.all(
                                             color: Custom_color.WhiteColor,
                                             width: 2.0,
                                           ),
                                         ),
                                       ),
                                     ): Container(
                                       // alignment: Alignment.centerLeft,
                                       margin: EdgeInsets.only(left: 15),
                                       decoration: BoxDecoration(
                                           border: Border.all(color: Custom_color.BlueLightColor,width: 0.2),
                                           gradient: LinearGradient(
                                             begin: Alignment.topLeft,
                                             end: Alignment.bottomLeft,

                                             colors: [
                                               // Color(0XFF8134AF),
                                               // Color(0XFFDD2A7B),
                                               // Color(0XFFFEDA77),
                                               // Color(0XFFF58529),
                                               Colors.blue.withOpacity(0.5),
                                               Colors.blue.withOpacity(0.5),
                                              // Color(0xfffb4592).withOpacity(0.5),
                                             //  Colors.blue.withOpacity(0.5),

                                             ],
                                           ),
                                           shape: BoxShape.circle
                                       ),
                                       child: Container(
                                         margin: EdgeInsets.all(5),
                                         child: ClipOval(
                                           child: Material(
                                             // color:Helper.inIconCircleBlueColor1, // Button color
                                             child: InkWell(
                                               splashColor: Helper.inIconCircleBlueColor1, // Splash color
                                               onTap: () {
                                                 /* Navigator.pushNamed(context, Constant.ChatUserDetail,
                                                    arguments: {"user_id": chat_item.user_id, "type": "3"});*/
                                               },
                                               child: SizedBox(width: 70, height: 70,
                                                   child:Image(image: profile_image!=null?NetworkImage(profile_image,scale: 1.0):const AssetImage('assest/images/user2.png'),
                                                     fit: BoxFit.cover,)
                                               ),
                                             ),
                                           ),
                                         ),
                                       ),
                                     )
                                   ],
                                 ),
                               ),
                             ):Container(),
                           ],
                         ),

                         InkWell(
                           onTap: () {
                             Navigator.pushNamed(
                                 context, Constant.FirstNameRoute ,arguments: {"name": name_demo}).then((value) {
                               _GetCallBackMethod(value);
                             });
                           },
                           child: Container(
                             width: _screenSize.width,
                             padding: const EdgeInsets.only(
                                 top: 10, right: 16, left: 16, bottom: 10),
                             margin: EdgeInsets.only(
                                 top: 5, right: 15, left: 15, bottom: 15),
                             decoration: BoxDecoration(
                               //border: Border.all(color:Colors.blue.withOpacity(0.2),width: 5),
                                 borderRadius: BorderRadius.circular(20),
                                 color: Colors.white,
                             ),

                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: <Widget>[
                                 CustomWigdet.TextView(
                                     text: name,
                                     color: Custom_color.BlueLightColor,
                                     fontSize: 18),
                                 CustomWigdet.TextView(
                                     text: gender != null
                                         ? _getGender(gender)
                                         : gender,
                                     color: Custom_color.GreyLightColor),
                                 Divider(
                                   thickness: 1,
                                 ),

                                 InkWell(
                                   onTap: () {
                                     Navigator.pushNamed(
                                         context, Constant.DateOfBirthRoute,arguments: {"dob":dob})
                                         .then((value) {
                                       _GetCallBackMethod(value);
                                     });
                                   },
                                   child: Container(
                                     padding: EdgeInsets.only(
                                         top: 5, bottom: 5),
                                     width: _screenSize.width,
                                     child: CustomWigdet.TextView(
                                         overflow: true,
                                         text: dob ,
                                         color: Custom_color.GreyLightColor),
                                   ),
                                 ),
                                 Divider(
                                   thickness: 1,
                                 ),
                                 InkWell(
                                     onTap: () {
                                       Navigator.pushNamed(
                                           context, Constant.SocialMediaPage)
                                           .then((value) {
                                         _GetCallBackMethod(value);
                                       });
                                     },
                                     child:
                                     Column(
                                       children: [
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           children: [
                                             facebook == "1"
                                                 ? Container(
                                               margin: EdgeInsets.only(
                                                   top: 5, left: 5, right: 5),
                                               child: Image.asset(
                                                 "assest/images/fb_color.png",
                                                 width: 16,
                                                 height: 16,
                                               ),
                                             )
                                                 : Container(),
                                             twitter == "1"
                                                 ? Container(
                                               margin: EdgeInsets.only(
                                                   top: 5, left: 5, right: 5),
                                               child: Image.asset(
                                                 "assest/images/twitter_color.png",
                                                 width: 16,
                                                 height: 16,
                                               ),
                                             )
                                                 : Container(),
                                             instagram == "1"
                                                 ? Container(
                                               margin: EdgeInsets.only(
                                                   top: 5, left: 5, right: 5),
                                               child: Image.asset(
                                                 "assest/images/insta_color.png",
                                                 width: 16,
                                                 height: 16,
                                               ),
                                             )
                                                 : Container(),
                                             tiktok == "1"
                                                 ? Container(
                                               margin: EdgeInsets.only(
                                                   top: 5, left: 5, right: 5),
                                               child: Image.asset(
                                                 "assest/images/tik_tok_color.png",
                                                 width: 16,
                                                 height: 16,
                                               ),
                                             )
                                                 : Container(),
                                             linkedin == "1"
                                                 ? Container(
                                               margin: EdgeInsets.only(
                                                   top: 5, left: 5, right: 5),
                                               child: Image.asset(
                                                 "assest/images/linkedin_color.png",
                                                 width: 16,
                                                 height: 16,
                                               ),
                                             )
                                                 : Container(),
                                             (facebook == "0" && twitter == "0" && instagram == "0" && tiktok == "0" && linkedin == "0")
                                                 ? CustomWigdet.TextView(
                                                 textAlign: TextAlign.center,
                                                 overflow: true,
                                                 text: AppLocalizations.of(context)
                                                     .translate(
                                                     "No Social Media Connected"),
                                                 color: Custom_color.GreyLightColor)
                                                 : Container(),



                                           ],

                                         ),
                                       ],
                                     ),
                                 ),


                                 Divider(
                                   thickness: 1,
                                 ),
                                 InkWell(
                                   onTap: () {
                                     Navigator.pushNamed(context,
                                         Constant.Interested_profileRoute)
                                         .then((value) {
                                       _GetCallBackMethod(value);
                                     });
                                   },
                                   child: Container(
                                     width: _screenSize.width,
                                     child: Column(
                                       crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                       children: <Widget>[
                                         CustomWigdet.TextView(
                                             text: AppLocalizations.of(context)
                                                 .translate("Interest in"),
                                             color: Custom_color
                                                 .BlueLightColor),
                                         CustomWigdet.TextView(
                                             text: interest != null
                                                 ? _getInterest(interest)
                                                 : "",
                                             color: Custom_color
                                                 .GreyLightColor),
                                       ],
                                     ),
                                   ),
                                 ),
                                 Divider(
                                   thickness: 1,
                                 ),
                                 InkWell(
                                   onTap: () {
                                     Navigator.pushNamed(context,
                                         Constant.MyProfessionalPage)
                                         .then((value) {
                                       _GetCallBackMethod(value);
                                     });
                                   },
                                   child: Container(
                                     width: _screenSize.width,
                                     child: Column(
                                       crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                       children: <Widget>[
                                         CustomWigdet.TextView(
                                             text: AppLocalizations.of(context)
                                                 .translate(
                                                // "Professional interest in"
                                             "Purpose of joining"
                                             ),
                                             color: Custom_color
                                                 .BlueLightColor),
                                         CustomWigdet.TextView(
                                             text: prof_interest != null
                                                 ? _getProfessional(
                                                 prof_interest)
                                                 : "",
                                             color: Custom_color
                                                 .GreyLightColor),
                                       ],
                                     ),
                                   ),
                                 ),
                                 Divider(
                                   thickness: 1,
                                 ),
                                 InkWell(
                                   onTap: () {
                                     Navigator.pushNamed(
                                         context, Constant.MyActivityPage)
                                         .then((value) {
                                       _GetCallBackMethod(value);
                                     });
                                   },
                                   child: Container(
                                     width: _screenSize.width,
                                     child: Column(
                                       crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                       children: <Widget>[
                                         CustomWigdet.TextView(
                                             text: AppLocalizations.of(context)
                                                 .translate(
                                                 "Activity describes most"),
                                             color: Custom_color
                                                 .BlueLightColor),
                                         CustomWigdet.TextView(
                                             overflow: true,
                                             text: activitylist != null
                                                 ? _getListactiviyitem(
                                                 activitylist)
                                                 : "",
                                             color: Custom_color
                                                 .GreyLightColor),
                                       ],
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
               ],
             ),
           )),
     ),
   );
 }

 Future<https.Response> _GetProfile() async {
   try {
     if (images != null && images.isNotEmpty) {
       images.clear();
       activitylist.clear();
     }
     String url =
         WebServices.GetProfile + SessionManager.getString(Constant.Token);
     print("-----url-----" + url.toString());
     https.Response response = await https.get(Uri.parse(url), headers: {
       "Accept": "application/json",
       "Cache-Control": "no-cache",
     });
     print("respnse----" + response.body);
     if (response.statusCode == 200) {
       var data = json.decode(response.body);
       if (data["status"]) {
         interest = data["user_info"]["interest"];
         prof_interest = data["user_info"]["prof_interest"];
         name = data["name"];
         name_demo = data["user_info"]["name"];
         gender = data["user_info"]["gender"];
         dob = data["user_info"]["dob"];
         var social = data["user_info"]["social"];
         profile_image = data["user_info"]["profile_img"];
         if(social.runtimeType !=String){
           facebook = data["user_info"]["social"]["facebook"];
           twitter = data["user_info"]["social"]["twitter"];
           instagram = data["user_info"]["social"]["instagram"];
           tiktok = data["user_info"]["social"]["tiktok"];
           linkedin = data["user_info"]["social"]["linkedin"];
         }
         var count = data["user_info"]["chatcount"];
         if (count != null) {
         //  SessionManager.setString(Constant.ChatCount, count.toString());
           UtilMethod.SetChatCount(context, count.toString());

         }
         var notification_count = data["notification_count"];
         if (notification_count != null) {
          // SessionManager.setString(Constant.NotificationCount, notification_count.toString());
           UtilMethod.SetNotificationCount(context, notification_count.toString());
         }

         imagelist = data["image"] as List;
         if (imagelist != null && imagelist.length > 0) {
           for (var i = 0; i < imagelist.length; i++) {
             images.add(imagelist[i]["name"].toString());
           }
           WidgetsBinding.instance.addPostFrameCallback((_) {
             images.forEach((imageUrl) {
               precacheImage(NetworkImage(imageUrl,scale: 1.0), context);
             });
           });
         }

         var activity_list = data["activity"] as List;
         if (activity_list != null && activity_list.length > 0) {
           activitylist = activity_list
               .map<Activity_holder>(
                   (index) => Activity_holder.fromJson(index))
               .toList();
         }

         setState(() {
           loading = true;
         });
       } else {
         loading = false;
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
     loading = false;
   }
 }

 String _getListactiviyitem(List<Activity_holder> list) {
   StringBuffer value = new StringBuffer();
   List<Activity_holder>.generate(list.length, (index) {
     if(list[index].percent>0) {
       value.write(list[index].name);
       if ((list.length) == (index + 1)) {} else {
         value.write(", ");
       }
     }
   });



   //value.writeln()
   return !UtilMethod.isStringNullOrBlank(value.toString())
       ? value.toString()
       : "";

 }

 String _getGender(int name) {
   String value = "";
   if (name == 0) {
     value = AppLocalizations.of(context).translate("Male");
   } else if (name == 1) {
     value = AppLocalizations.of(context).translate("Female");
   }
   return value;
 }


 String _getInterest(int name) {
   String value = "";
   if (name == 0) {
     value = "";
   } else if (name == 1) {
     value = AppLocalizations.of(context).translate("MEN");
   } else if (name == 2) {
     value = AppLocalizations.of(context).translate("WOMEN");
   } else if (name == 3) {
     value = AppLocalizations.of(context).translate("BOTH");
   }
   return value;
 }

 String _getProfessional(int name) {
   String value = "";
   if (name == 0) {
     value = "";
   } else if (name == 1) {
     value = AppLocalizations.of(context).translate("Looking for job");
   } else if (name == 2) {
     value = AppLocalizations.of(context).translate("Providing Job");
   } else if (name == 3) {
     value = AppLocalizations.of(context).translate("BOTH");
   } else if (name == 4) {
     value = AppLocalizations.of(context).translate("Others");
   }
   return value;
 }

 _GetCallBackMethod(bool value) {
   if (value == true) {
     setState(() {
       loading = false;
     });
     WidgetsBinding.instance
         .addPostFrameCallback((_) async {
       if (await UtilMethod
           .SimpleCheckInternetConnection(
           context, _scaffoldKey)) {
         _GetProfile();
       }
     });
   }
 }



//  _showProgress(BuildContext context) {
//    progressDialog = new ProgressDialog(context,
//        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
//    progressDialog.style(
//        message: AppLocalizations.of(context).translate("Loading"),
//        progressWidget: CircularProgressIndicator());
//    progressDialog.show();
//  }
//
//  _hideProgress() {
//    if (progressDialog != null) {
//      progressDialog.hide();
//    }
//  }
}
