import 'package:flutter/material.dart';

import '../language/app_localizations.dart';
import 'custom_color.dart';
import 'custom_ui.dart';
import 'helper.dart';

class ShowDialogNetworkError{

  static   Future<bool> showDialogNetworkErrorMessage(BuildContext context,var Title,var MSG,var status,var Type_Action,var MQ_Width,var MQ_Height) async {
    return await showDialog( //show confirm dialogue
      //the return value will be from "Yes" or "No" options
      context: context,
      builder: (context) => Center(
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
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            //  backgroundColor: Colors.transparent,
            title: CustomWigdet.TextView(
                text: AppLocalizations.of(context).translate("No internet connection"),
                //AppLocalizations.of(context).translate("Create Activity"),
                fontFamily: "Kelvetica Nobis",
                fontSize: Helper.textSizeH10,
                fontWeight: Helper.textFontH4,
                color: Helper.textColorBlueH1
            ),
            content:  CustomWigdet.TextView(
              overflow: true,
              text:AppLocalizations.of(context).translate("Make sure that WiFi or mobile data is turned on,then try again"),
              //AppLocalizations.of(context).translate("Create Activity"),
              fontFamily: "Kelvetica Nobis",
              fontSize: Helper.textSizeH12,
              fontWeight: Helper.textFontH5,
              color: Color(Helper.textColorBlackH2),

            ),
            actions:[
              /*ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child:Text(AppLocalizations.of(context).translate("No")),
              ),

              ElevatedButton(
                onPressed: () {

                 },
                //return true when click on "Yes"
                child:Text(AppLocalizations.of(context).translate("Yes")),
              ),*/


              Container(
                alignment: Alignment.bottomCenter,
                margin:  const EdgeInsets.only(left: 5,right: 5),
                height: 50,
                width: MQ_Width*0.25,
                decoration: BoxDecoration(
                  color: Color(Helper.ButtonBorderPinkColor),
                  border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FlatButton(
                  onPressed: ()async{
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    // isLocationEnabled?'CLOSE':'OPEN',
                    AppLocalizations.of(context)
                        .translate("Ok")
                        .toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(Helper.ButtontextColor),
                        fontFamily: "Kelvetica Nobis", fontSize:Helper.textSizeH13,fontWeight:Helper.textFontH4),
                  ),
                ),
              ),
             // SizedBox(width: MQ_Width*0.01,),
              false? Container(
                alignment: Alignment.bottomCenter,
                margin:  EdgeInsets.only(left: 5,right: 5),

                height: 50,
                width: MQ_Width*0.28,
                decoration: BoxDecoration(
                  color: Helper.ButtonBorderGreyColor,//Color(Helper.ButtonBorderPinkColor),
                  border: Border.all(width: 0.5,color: Color(Helper.ButtontextColor)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FlatButton(
                  onPressed: ()async{
                    Navigator.of(context).pop(false);

                  },
                  child: Text(
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
      ),
    )??false; //if showDialouge had returned null, then return false
  }

}