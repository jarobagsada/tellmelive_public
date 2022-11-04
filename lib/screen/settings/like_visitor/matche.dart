import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miumiu/language/app_localizations.dart';
import 'package:miumiu/screen/holder/user.dart';
import 'package:miumiu/services/webservices.dart';
import 'package:miumiu/utilmethod/constant.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:miumiu/utilmethod/custom_ui.dart';
import 'package:miumiu/utilmethod/preferences.dart';
import 'package:miumiu/utilmethod/utilmethod.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as https;

class Matched_Screen extends StatefulWidget {
  @override
  _Matched_ScreenState createState() => _Matched_ScreenState();
}

class _Matched_ScreenState extends State<Matched_Screen> {
  ProgressDialog progressDialog;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _visible, _listVisible;
  List<User> fav_list = [];
  String messages;

  @override
  void initState() {
    _visible = false;
    _listVisible = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await UtilMethod.SimpleCheckInternetConnection(
          context, _scaffoldKey)) {
        _ItemList();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar,
      body: Visibility(
        visible: _visible,
        replacement: Center(
          child: CircularProgressIndicator(),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: _listVisible
              ? Container(child: listViewWidget(context))
              : Center(
            child: Container(
              child: CustomWigdet.TextView(
                  textAlign: TextAlign.center,
                  overflow: true,
                  text: messages.toString(),
                  color: Custom_color.BlackTextColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget listViewWidget(BuildContext context) {
    return fav_list.length > 0 ? ListView.separated(
      itemBuilder: (context, i) {
        final nDataList = fav_list[i];
        print("-----chatlean----" + fav_list.length.toString());
        return
          getlistchatItem(nDataList);
      },
      itemCount: fav_list == null ? 0 : fav_list.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: Custom_color.ColorDivider,
        );
      },
    ) : Center(
      child: Container(
        child: CustomWigdet.TextView(
            text: AppLocalizations.of(context)
                .translate("There is no message"),
            color: Custom_color.BlackTextColor,
            fontSize: 14),
      ),
    );
  }

  Widget getlistchatItem(User nDataList) {
    return Container(
      color: nDataList.status==1? Custom_color.PlacholderColor:Colors.transparent,
      child: ListTile(
        onTap: (){
          Navigator.pushNamed(context, Constant.ChatUserDetail,
              arguments: {"user_id": nDataList.user_id, "type": "3"});
        },
        leading: CircleAvatar(
          backgroundColor:Custom_color.WhiteColor,
          radius: 28,
          backgroundImage:
          NetworkImage(nDataList.profile_img,scale: 1.0),
        ),
        title: CustomWigdet.TextView(
          text: nDataList.name,
          color: Custom_color.BlackTextColor,
          fontFamily: "OpenSans Bold",
        ),
        subtitle: CustomWigdet.TextView(
          overflow: true,
          text: "${nDataList.gender}${nDataList.age.isNotEmpty?", "+nDataList.age:""}",
          color: Custom_color.GreyLightColor,
        ),
      ),
    );
  }

  get _appbar {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0), // here the desired height
      child: AppBar(
        title: CustomWigdet.TextView(
            text: AppLocalizations.of(context).translate("matched").toUpperCase(),
            textAlign: TextAlign.center,
            color: Custom_color.WhiteColor,
            fontFamily: "OpenSans Bold"),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30))),
        leading: InkWell(
          borderRadius: BorderRadius.circular(30.0),
          child: Icon(
            Icons.arrow_back,
            color: Custom_color.WhiteColor,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<List<User>> _ItemList() async {
    try {
      if (fav_list != null && !fav_list.isEmpty) {
        fav_list.clear();
      }

      String url = WebServices.GetMatchProfile +
          SessionManager.getString(Constant.Token) + "&language=${SessionManager.getString(Constant.Language_code)}";
      print("---Url----" + url.toString());
      https.Response response = await https.get(Uri.parse(url),
          headers: {"Accept": "application/json", "Cache-Control": "no-cache"});
      _hideProgress();
      print("respnse--111--" + response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"]) {


          List userlist = data["user"];

          if (userlist != null && userlist.isNotEmpty) {
            fav_list = userlist.map<User>((i) => User.fromJson(i)).toList();
          }

          setState(() {
            _listVisible = true;
          });
        } else {
          setState(() {
            _listVisible = false;
          });
          messages = data["message"].toString();
          if (data["is_expire"] == Constant.Token_Expire) {
            UtilMethod.showSimpleAlert(
                context: context,
                heading: AppLocalizations.of(context).translate("Alert"),
                message:
                AppLocalizations.of(context).translate("Token Expire"));
          }
        }

        setState(() {
          _visible = true;
        });
      }

      return fav_list;
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
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
