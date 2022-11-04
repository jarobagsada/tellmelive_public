import 'package:flutter/material.dart';
import 'package:miumiu/colors/colors.dart';
import 'package:miumiu/language/AppLanguage.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/LanguageModel.dart';
import 'package:miumiu/utilmethod/SubmitButton.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';

class Langauge_Screen extends StatefulWidget {
  AppLanguage appLanguage;

  Langauge_Screen(this.appLanguage);

  @override
  _Langauge_ScreenState createState() => _Langauge_ScreenState();
}

class _Langauge_ScreenState extends State<Langauge_Screen> {
  bool flag_eng;
  bool flag_german;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<LanguageModel> languageList = List<LanguageModel>();
  LanguageModel _languageModel = LanguageModel();

  @override
  void initState() {
    flag_eng = false;
    flag_german = false;
    _languageModel = null;
    languageList.add(LanguageModel(
        languageCode: 'en',
        languageName: "English",
        flagURL: 'assest/images/eng.png',
        isSelected: false));
    languageList.add(LanguageModel(
        languageCode: 'de',
        languageName: "German",
        flagURL: 'assest/images/flag.png',
        isSelected: false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var Size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assest/images/newbg.png"),
              fit: BoxFit.cover),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 70),
                padding: const EdgeInsets.only(left: 40.0, right: 80),
                child: Image.asset(
                  "assest/images/tellme.png",
                )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate("Choose"),
                    style: Theme.of(context).textTheme.headline2.copyWith(
                        color: const Color(colorsThemePink),
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    AppLocalizations.of(context).translate("Your Language"),
                    style: Theme.of(context).textTheme.headline4.copyWith(
                        color: Colors.black87, fontWeight: FontWeight.bold,fontSize: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 10,
                  ),
                  scrollDirection: Axis.vertical,
                  itemCount: languageList.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return Container(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            languageList.forEach((element) {
                              element.isSelected = false;
                            });
                            languageList[index].isSelected = true;
                            flag_eng=true;
                            _languageModel = languageList[index];
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: Image(
                                image:
                                AssetImage(languageList[index].flagURL),
                                fit: BoxFit.contain, // use this
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(languageList[index].languageName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                    fontStyle: FontStyle.normal,
                                    // fontSize: 16,
                                    color:
                                    languageList[index].isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.normal)),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: languageList[index].isSelected
                              ? const Color(colorsThemeBlue)
                              : Colors.white,
                          border: Border.all(
                            color: Colors.lightBlue[100],
                            width: 6,
                          ),
                          borderRadius: BorderRadius.circular(80)),
                    );
                  }),
            ),
            const Spacer(),
            _languageModel == null
                ? Container()
                : Padding(
              padding: const EdgeInsets.only(left: 30, right: 30,bottom:60),
              child: SubmitButton(
                onPressed: () async {
                  setState(() {
                    onTapNext();
                    /*PreferenceProvider.of(context).updateLanguageCode(
                        _languageModel.languageCode ?? "en");
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        LoginLandingScreen.routeName,
                            (Route<dynamic> route) => false);*/

                    // CustomMethods.SnackBarMessage(_scaffoldKey, _languageModel.languageName);
                  });
                },
                text: AppLocalizations.of(context).translate("Continue"),
              ),
            ),

          ],
        ),
      ),
    );
  }

  onTapflagEng() {
    setState(() {
      flag_eng = true;
      flag_german = false;
      widget.appLanguage.changeLanguage(Locale("en"));
      SessionManager.setString(Constant.Language_code,"en" );
    });
  }

  onTapflagGerman() {
    setState(() {
      flag_eng = false;
      flag_german = true;
      widget.appLanguage.changeLanguage(Locale("de"));
      SessionManager.setString(Constant.Language_code,"de" );
    });
  }

  onTapNext() {
    if (flag_eng || flag_german) {
      print("---------fla---true------");
      SessionManager.setboolean(Constant.FirstLangauge, true);
      widget.appLanguage.changeLanguage(Locale(_languageModel.languageCode));
      SessionManager.setString(Constant.Language_code,_languageModel.languageCode );
      Navigator.pushReplacementNamed(context, Constant.LoginRoute);
    }
    else {
      print("---------fla---fasle------");
      UtilMethod.SnackBarMessage(this._scaffoldKey, AppLocalizations.of(context).translate("Please select langauge"));
    }
  }
}
