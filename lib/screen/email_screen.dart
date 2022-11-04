import 'package:flutter/material.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';

class EmailScreen extends StatefulWidget {
  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  Size _screenSize;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String firstname = "";

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _getAppbar,
      body: Container(
        width: _screenSize.width,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomWigdet.TextView(
                        text: AppLocalizations.of(context)
                            .translate("What's your email address?"),
                        fontSize: 14.0,
                        textAlign: TextAlign.center,
                        color: Custom_color.BlackTextColor,
                        fontFamily: "OpenSans Bold"),
                    SizedBox(
                      height: 10,
                    ),
                    _otpTextField(),
                    SizedBox(
                      height: 10,
                    ),
                    CustomWigdet.TextView(
                        text: AppLocalizations.of(context)
                            .translate("Add your email address"),
                        fontSize: 12,
                        color: Custom_color.GreyLightColor,
                        fontFamily: "OpenSans Bold",
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              CustomWigdet.RoundOutlineFlatButton(
                  onPress: () {
                    OnSubmit(context);
                  },
                  text: AppLocalizations.of(context)
                      .translate("Continue")
                      .toUpperCase(),
                  textColor: Custom_color.BlueLightColor,
                  bordercolor: Custom_color.BlueLightColor,
                  fontFamily: "OpenSans Bold"),
            ],
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
      bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Flexible(
                flex: 4,
                child: Container(
                    width: _screenSize.width,
                    height: 1,
                    color: Custom_color.BlueLightColor),
              ),
              Flexible(
                flex: 9,
                child: Container(
                  width: _screenSize.width,
                  height: 0.5,
                  color: Custom_color.GreyLightColor,
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

  Widget _otpTextField() {
    return Container(
        decoration: BoxDecoration(
            color: Custom_color.GreyLightColor3,
            borderRadius: BorderRadius.all(Radius.circular(2.0))),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Form(
                key: this._formKey,
                child: TextFormField(
                  autofocus: true,
                  showCursor: true,
                  style: TextStyle(
                      color: Custom_color.BlackTextColor,
                      fontFamily: "OpenSans Regular",
                      fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(0.0),
                    isDense: true,
                    hintText: AppLocalizations.of(context).translate("example@mail.com"),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate("blank name");
                    }
                  },
                  onSaved: (value) {
                    firstname = value;
                  },
                ),
              ),
            ],
          ),
        ));
  }

  void OnSubmit(BuildContext context) {
    if (!this._formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save(); // Save our form now.

    print('Printing the  data.');
    print('Email: ${firstname}');

    // Navigator.push(context, MaterialPageRoute(builder:(context) =>HomeScreen(),settings: RouteSettings(arguments: ScreenArguments(""))));

    // Navigator.pushNamed(context, HomeScreen.home_route,arguments: {"id":"12","titke":"xyz"});

    //  Navigator.pushNamed(context, HomeScreen.home_route);
  }
}
