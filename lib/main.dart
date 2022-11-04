// @dart=2.9
import 'dart:convert';

import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miumiu/language/AppLanguage.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/ActivityFromSettings.dart';
import 'package:miumiu/screen/OnboardingPage.dart';
import 'package:miumiu/screen/activity_screen.dart';
import 'package:miumiu/screen/activity_user_detail.dart';
import 'package:miumiu/screen/call_sio_agora/agoravideocall.dart';
import 'package:miumiu/screen/callview/cubit/auth/auth_cubit.dart';
import 'package:miumiu/screen/callview/fcm/firebase_notification_handler.dart';
import 'package:miumiu/screen/callview/home/call_screen.dart';
import 'package:miumiu/screen/callview/home/home_cubit.dart';

import 'package:miumiu/screen/callview/network/dio_helper.dart';
import 'package:miumiu/screen/chat/chat.dart';
import 'package:miumiu/screen/chat/chat_map.dart';
import 'package:miumiu/screen/chat/chatuser.dart';
import 'package:miumiu/screen/chat_detail_screen.dart';
import 'package:miumiu/screen/create_activity_screen.dart';
import 'package:miumiu/screen/user_aboutme.dart';
import 'package:miumiu/utilmethod/helper.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:upgrader/upgrader.dart';
import 'dart:ui';
import 'package:vector_math/vector_math_geometry.dart';
import 'package:device_info/device_info.dart';
import 'package:miumiu/screen/langauge.dart';
import 'screen/Edit_Activity.dart';
import 'package:miumiu/screen/pages/personal_page.dart';
import 'package:miumiu/screen/pages/provider/filtermodel.dart';
import 'package:miumiu/screen/pages/provider/model.dart';
import 'package:miumiu/screen/profile.dart';
import 'package:miumiu/screen/settings/activity_page.dart';
import 'package:miumiu/screen/settings/app_setting_screen.dart';
import 'package:miumiu/screen/settings/broadcast_message.dart';
import 'package:miumiu/screen/settings/dateof_birth_page.dart';
import 'package:miumiu/screen/email_screen.dart';
import 'package:miumiu/screen/firstname_screen.dart';
import 'package:miumiu/screen/gallery.dart';
import 'package:miumiu/screen/gender_screen.dart';
import 'package:miumiu/screen/location_permission_screen.dart';
import 'package:miumiu/screen/login_by_number.dart';
import 'package:miumiu/screen/login_screen.dart';
import 'package:miumiu/screen/settings/edit_profile/edit_myprofile.dart';
import 'package:miumiu/screen/settings/edit_profile/edit_profile_new.dart';
import 'package:miumiu/screen/settings/edit_profile/profile_user.dart';
import 'package:miumiu/screen/settings/favorites_screen.dart';
import 'package:miumiu/screen/settings/gellary_page.dart';
import 'package:miumiu/screen/settings/broadcast_message_history.dart';
import 'package:miumiu/screen/settings/interest_page.dart';
import 'package:miumiu/screen/settings/like_visitor/like.dart';
import 'package:miumiu/screen/settings/like_visitor/matche.dart';
import 'package:miumiu/screen/settings/like_visitor/visitor.dart';
import 'package:miumiu/screen/settings/match_profile_page.dart';
import 'package:miumiu/screen/settings/my_preference_screen.dart';
import 'package:miumiu/screen/nagivation_screen.dart';
import 'package:miumiu/screen/otp.dart';
import 'package:miumiu/screen/interest_screen.dart';
import 'package:miumiu/screen/pages/activity_list_page.dart';
import 'package:miumiu/screen/professional_screen.dart';
import 'package:miumiu/screen/settings/notification_page.dart';
import 'package:miumiu/screen/settings/professional_page.dart';
import 'package:miumiu/screen/settings/social_page.dart';
import 'package:miumiu/screen/socialmedia_screen.dart';
import 'package:miumiu/screen/user_register.dart';
import 'package:miumiu/screen/webview.dart';
import 'package:miumiu/screen/welcome_screen.dart';
import 'package:miumiu/screen/home_welcom.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:provider/provider.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:miumiu/screen/Splash.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';  
import 'dart:io' as IO;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String id    =  IO.Platform.isAndroid ? '1:124784474027:android:f73de9c307cbe618fb04ee' : '1:124784474027:ios:b6573344920bc748fb04ee';
  DioHelper.init();
  await Firebase.initializeApp();
  await Upgrader.clearSavedSettings();
  //Handle FCM background
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  
  await SessionManager.init();
  AppLanguage appLanguage = AppLanguage();
  print("-------main---------");
  await appLanguage.fetchLocale();
  runApp(MyApp(appLanguage: appLanguage,));



}
class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics            = FirebaseAnalytics();

  final AppLanguage appLanguage;
  MyApp({this.appLanguage});

  @override
  Widget build(BuildContext context) {
    print(analytics);
   // SessionManager.cleanPreference();
    //  SessionManager.setString(Constant.Token, "pMhnG8sJvKS_j27a6KBIfDwZ9U_rwo-X");
//      poSgUPKJ9W29BDpl4-M3Ra8ASegc-Osp
    print("------token-------" + SessionManager.getString(Constant.Token));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Color(Helper.StatusBarColor),
        ),
      child: Container(
      color:  Colors.white,
      child : MultiProvider(
        providers: [
          ChangeNotifierProvider<AppLanguage>(
            create: (context) => appLanguage,
          ),
          ChangeNotifierProvider<CounterModel>(
              create: (context) => CounterModel()),
          ChangeNotifierProvider<FilterModel>(
              create: (context) => FilterModel()),
         /* ChangeNotifierProvider<AuthCubit>(
            create: (_) => AuthCubit()..getUserData(uId: SessionManager.getString(Constant.user_fcmUid)),
          ),
          ChangeNotifierProvider<HomeCubit>(
              create: (context) => HomeCubit()..listenToInComingCalls()..getUsersRealTime(context)..getCallHistoryRealTime()..initFcm(context)..updateFcmToken(uId:  SessionManager.getString(Constant.user_fcmUid)),),
*/

          BlocProvider(
            create: (_) => AuthCubit()..getUserData(uId: SessionManager.getString(Constant.user_fcmUid)),
          ),
          BlocProvider(
            create: (_) => HomeCubit()..listenToInComingCalls()..getUsersRealTime()..getCallHistoryRealTime()..initFcm(context)..updateFcmToken(uId:  SessionManager.getString(Constant.user_fcmUid)),
          ),
        ],
        child:
        Consumer<AppLanguage>(builder: (context, model, child) {
          SessionManager.setString(Constant.Language_code, model.appLocal.toString());
          print("--------langaye code--------"+SessionManager.getString(Constant.Language_code));
          //
          return MaterialApp(
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            locale: model.appLocal,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'AE'),
              Locale('de', ''),
            ],

            localizationsDelegates: const [
              AppLocalizations.delegate, // Add this line
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              //CountryLocalizations.delegate,
            ],
            title: 'Tellme Live',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Custom_color.BlueMain
            ),
            initialRoute: Constant.SplashScreen,
            //lse? Constant.LanguageScreen: UtilMethod.isStringNullOrBlank(SessionManager.getString(Constant.Token)) ? Constant.LoginRoute : Constant.WelcomeRoute,
            routes: <String, WidgetBuilder>
            {
                Constant.LoginRoute: (context) => Login_Screen(model.appLocal.toString()),
                Constant.SplashScreen :(context) => SplashScreen(appLanguage: model),
                Constant.OnboardScreen :(context) => OnBoardingPage(appLanguage: model),
                Constant.LoginByNumberRoute: (context) => Login_by_number(),
                Constant.OtpRoute: (context) => Opt_Screen(),
                Constant.FirstNameRoute: (context) => FirstName_Screen(),
                Constant.DateOfBirthRoute: (context) => DateOf_Birth_Screen(),
                Constant.GenderRoute: (context) => GenderScreen(),
                Constant.EmailRoute: (context) => EmailScreen(),
                Constant.GalleryRoute: (context) => Gallery_Screen(),
                Constant.WelcomeRoute: (context) => Welcome_Screen(lang_code:model.appLocal.toString()),
                Constant.NavigationRoute: (context) => Nagivation_screen(),
                Constant.InterestedRoute: (context) => Interested_Screen(),
                Constant.ProfessionalRoute: (context) => Professional_Screen(),
                Constant.ActivityRoute: (context) => Activity_Screen(),
                Constant.LocationRoute: (context) => Location_Permission_Screen(),
                Constant.UserRegisterRoute: (context) => User_register(),
                Constant.ChatUserDetail: (context) => ChatDetail(),
                Constant.ChatUserActivityList: (context) => Activity_page(),
                Constant.CreateActivity: (context) => Create_Activity(),
                Constant.ActivityUserDetail: (context) => Activity_User_Detail(),
                Constant.MyPrefrences: (context) => Perfrence_Screen(),
                Constant.MyProfile: (context) => Profile_Screen(),
                Constant.Interested_profileRoute: (context) => InterestedProfile_Screen(),
                Constant.MyProfessionalPage: (context) => Professional_Page(),
                Constant.MyActivityPage: (context) => Activity_PageScreen(),
                Constant.AppSettings: (context) => AppSetting_Screen(),
                Constant.MyGalleryPage: (context) => Gallery_Pages(),
                Constant.ChatUser: (context) => ChatUser_Screen(),
                Constant.ChatRoute: (context) => Chat_Screen(),
                Constant.Favorites: (context) => Favorites_Screen(),
                Constant.MatchProfile: (context) => MatchProfile_Screen(),
                Constant.ProfileImage: (context) => ProfileImage(),
                Constant.NotificationScreen: (context) => Notification_Screen(),
                Constant.ProfileScreen: (context) => ProfileImage_Screen(),
                Constant.UserAboutMeScreen: (context) => UserAboutMe(),
                Constant.WebViewScreen: (context) => WebView_Screen(),
                Constant.SocialMediaScreen:(context)=> SocialMedia_Screen(),
                Constant.SocialMediaPage: (context) => SocialMedia_Page(),
                Constant.VisitorsScreen:(context) => Visitior_Screen(),
                Constant.LikeScreen:(context) => Like_Screen(),
                Constant.MatchScreen:(context) => Matched_Screen(),
                Constant.LanguageScreen:(context)=> Langauge_Screen(appLanguage),
                Constant.ChatMapScreen:(context)=> Chat_Map(),
                Constant.ParticleBackgroundApp:(context)=> ParticleBackgroundApp(),
                Constant.PersonalPage:(context)=>Personal_page(),
                Constant.Broadcastmessage:(context)=>Broadcast_message(),
                Constant.Broadcasthistory:(context) => Broadcast_message_history(),
                Constant.Edit_my_profile:(context)=>Profile_Screen_n(),
                Constant.Edit_Activity:(context)=> Edit_Activity(),
                Constant.ActivitySetting:(context)=>Activity_page_Settings(),
                Constant.CallScreen:(context)=>
                    //AgoraVideoCall()
              CallScreen()

            },

          );
        })
        ,
      )),
    );
  }
}

Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  //await CacheHelper.init();
  if (message.data['type'] == 'call'){
    Map<String, dynamic> bodyMap = jsonDecode(message.data['body']);
    await SessionManager.setString(Constant.terminateIncomingCallData,jsonEncode(bodyMap));
  }
  //FirebaseNotifications.showNotification(title: message.data['title'],body: message.data['body'],type: message.data['type']);

}
