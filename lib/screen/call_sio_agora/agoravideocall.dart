import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miumiu/screen/call_sio_agora/utils/color_utils.dart';
import 'package:miumiu/screen/call_sio_agora/utils/common_methods.dart';
import 'package:miumiu/screen/call_sio_agora/utils/localization/localization.dart';
import 'package:miumiu/screen/call_sio_agora/utils/navigation.dart';

class AgoraVideoCall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: ColorUtils.transparentColor,
      statusBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agora VideoCall',
      theme: ThemeData(
        bottomSheetTheme: BottomSheetThemeData(
          modalBackgroundColor: ColorUtils.transparentColor,
        ),
        primaryColor: ColorUtils.primaryColor,
        accentColor: Colors.white,
        fontFamily: 'Asap',
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        scaffoldBackgroundColor: ColorUtils.whiteColor,
      ),
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      home: navigationToNextScreen(),
      onGenerateRoute: NavigationUtils.generateRoute,
      localizationsDelegates: [
        const MyLocalizationsDelegate(),
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
      ],
    );
  }
}