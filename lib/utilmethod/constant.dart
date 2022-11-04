import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as locat;
import 'package:miumiu/screen/holder/activity_holder.dart';
import 'package:socket_io_client/socket_io_client.dart';

class Constant {
  static locat.LocationData currentLocation;
  static BitmapDescriptor customIcon;
  static bool networkRefresh=false;
  static double LATITUDE  =0;
  static double LONGITUDE =0;
  static final String LoginRoute = "/Login";
  static final String SplashScreen = "/SplashScreen";
  static final String LoginByNumberRoute = "/LoginBynumber";
  static final String OtpRoute = "/OtpRoute";
  static final String FirstNameRoute = "/FirstNameRoute";
  static final String DateOfBirthRoute = "/DateOfBrithRoute";
  static final String GenderRoute = "/GenderRoute";
  static final String EmailRoute = "/EmailRoute";
  static final String GalleryRoute = "/GalleryRoute";
  static final String WelcomeRoute = "/WelcomeRoute";
  static final String NavigationRoute = "/NavigationRoute";
  static final String InterestedRoute = "/IntrestedRoute";
  static final String Interested_profileRoute = "/Interested_profileRoute";
  static final String ProfessionalRoute = "/ProfessionalRoute";
  static final String ActivityRoute = "/ActivityRoute";
  static final String ActivityScreen = "/Activity_Screen";
  static final String LocationRoute = "/LocationRoute";
  static final String UserRegisterRoute = "/UserRegisterRoute";
  static final String ChatUserDetail = "/ChatUserDetailRoute";
  static final String ChatUserActivityList = "/ChatUserActivityList";
  static final String CreateActivity = "/CreateActivity";
  static final String ActivityUserDetail="/ActivityUserDetail";
  static final String MyPrefrences = "/MyPrefrences";
  static final String MyProfile = "/MyProfile";
  static final String MyProfessionalPage = "/MyProfessionalPage";
  static final String MyActivityPage = "/MyActivityPage";
  static final String AppSettings = "/AppSettings";
  static final String MyGalleryPage = "/MyGalleryPage";
  static final String ChatUser  ="/ChatUser";
  static final String ChatRoute = "/ChatRoute";
  static final String Favorites = "/Favorites";
  static final String MatchProfile = "/MatchProfile";
  static final String ProfileImage = "/ProfileImage";
  static final String ProfileScreen = "/ProfileScreen";
  static final String UserAboutMeScreen = "/UserAboutMeScreen";
  static final String NotificationScreen = "/NotificationScreen";
  static final String WebViewScreen = "/WebViewScreen";
  static final String SocialMediaScreen="/SocialMediaScreen";
  static final String SocialMediaPage = "/SocialMediaPage";
  static final String VisitorsScreen = "/VisitorsScreen";
  static final String LikeScreen = "/LikeScreen";
  static final String MatchScreen = "/MatchScreen";
  static final String LanguageScreen = "/LanguageScreen";
  static final String OnboardScreen = "/OnBoarding";
  static final String ChatMapScreen = "/ChatMapScreen";
  static final String ParticleBackgroundApp = "/ParticleBackgroundApp";
  static final String PersonalPage = "/PersonalPage";
  static final String Broadcastmessage = "/BroadcastMessage";
  static final String Broadcasthistory="/Broadcast_message_history" ;
  static final String Edit_my_profile="/Profile_Edit" ;
  static final String Edit_Activity = "Edit_Activity ";
  static final String ActivitySetting ="/ActivitySettings";
  static final String CallScreen ="/CallScreen";

  static final int APP_VERSION = 7;
  static final String progressBg = "0xFFFFFFFF";
  static final String progressVl = "0xFF03a9f4";
  static var SCREENS             = [];


//  static final String ImageURL = "http://leanports.com/muemue/uploads/customer/";
//  static final String ImageURL2 = "http://leanports.com/muemue/uploads/images/";

  static final String ImageURL2 = "http://endpoint.tellmelive.com/muemue/api/web/uploads/images/";
  static final String ImageURL = "";


  static final String Token ="token";
   static final String Interested = "interested";
  static final String Activity_list = "activity_list";
  static final String Name ="name";
  static final String LogingId ="id";
  static final String Mobile_no ="mobile_no";
  static final String Country_code ="country_code";
  static final String Email ="email";
  static final String Dob ="dob";
  static final String Profile_img ="profile_img";
  static final String AlreadyRegister = "Register_scccess";
   static final String Activity ="activity";
  static final String ActivityWall ="activityWall";
  static final int Token_Expire =1;
  static final String Max_Age = "max_age";
  static final String Min_Age = "min_age";
  static final String Miu ="miu";
  static final String Language_code = "language_code";
  static final String Distance="Distance";
  static final String FirstLangauge = "FirstLangauge";
  static final String Onboarded = "onboarded";





  static final String LocationEnabled = "locationenabled";
  static final String LoginByFacebook = "1";
  static final String LoginByPhone = "2";
  static final String CreateByPhone = "0";
  static final String Men = "0";
  static final String Women = "1";
  static final String Others = "3";
  static final String isAndroid = "0";
  static final String isIOS = "1";
  static final String UserOnline = "1";
  static final String UserOffline = "0";
  static final String Kilometers = "0";
  static final String Miles = "1";
  static final String Temporally = "1";
  static final String Permanent = "2";
  static final int English = 1;
  static final int German = 2;
  static final int Arabic = 3;
  static  bool Check_ChatNotification = true;
  static bool needsReloading = false;


  static const String View_Profile = 'View Profile';
  static const String Report_User = 'Report User';
  static const String Block_User = 'Block User';
  static const String Unblock_User = 'Unblock User';
  static const String AllchatClear_User = 'All Chat Clear';

  static const String SignOut = 'Sign out';

  static const List<String> choices = <String>[
    View_Profile,
    Block_User,
    Unblock_User,
    Report_User,
    AllchatClear_User
  //  SignOut
  ];

  static  String DummyChatCount = "0";
  static  String DummyNotificationCount = "0";
 static StreamSubscription<LocationData> locationSubscription;
 static   Socket socket;



  static String message_id = "";
  static String user_id = "";
  static String sender_id = "";
  static String receiver_id = "";
  static String chat_user_id = "";
  static String message = "";
  static String status = "";
  static String datetime = "";
  static String messagedatetime = "";
  static int location ;
  static int type ;
  static String user_fcmUid = "";
  static String user_fcmRecUid = "";
  static String terminateIncomingCallData="";








  static Map filterData        = new Map();
  static List<Activity_holder> activity_listCopy=[];

  static const kGoogleApiKey = "AIzaSyAGtFtbnppF8eAPadjGU_ZcQAL0C8RrYvg";

  static int currentTab     = 0;
  static int currentHomeTab     = 1;
  static var VISIBILITY     = 100.00;

  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {

    

    print("-----message------"+message.toString());
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      print("-----data--push notification----"+data.toString());
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      print("-----notification--push notification----"+notification.toString());
    }

    // Or do other work.
  }

  


}
