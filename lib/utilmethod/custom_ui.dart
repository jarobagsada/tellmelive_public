import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:miumiu/utilmethod/custom_color.dart';
import 'package:translator/translator.dart';
class CustomWigdet  {
 static List<Color> _kDefaultRainbowColors = const [
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.pinkAccent,
    Colors.pink,
    Colors.pink,
    Colors.pinkAccent,

  ];
  static Widget TextView(
      {String text,
      double fontSize,
      bool overflow = false,
      FontWeight fontWeight,
      TextAlign textAlign,
      Color color,
      String fontFamily}) {
    return Text(
      text ?? "",
      overflow: overflow ? null : TextOverflow.ellipsis,
      textAlign: textAlign ?? TextAlign.start,
      style: TextStyle(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.normal,
          fontFamily: fontFamily ?? "OpenSans Regular",
          color: color ?? Custom_color.BlackTextColor),
    );
  }

  static Widget OvalShapedButtonBlue(
      {@required Function() onPress,
        String text,
        String path,
        double fontSize,
        FontWeight fontWeight,
        Color textColor,
        Color bgcolor,
        double paddingTop,
        double paddingBottom,
        String fontFamily}) {
    return Container(
      height: 70,
      width: 320,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Color(0xffd5dce6),
              offset: Offset(0,6),
              blurRadius: 20

          )
        ],
        borderRadius: BorderRadius.circular(40.0),

        gradient: LinearGradient(colors: [Color(0xff23b8f2), Color(0xff1b5dab)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft),
        // boxShadow: [
        //   BoxShadow(
        //     color: Custom_color.BlueLightColor.withOpacity(0.5),
        //     spreadRadius: 3,
        //     blurRadius: 6,
        //     offset: Offset(1, 3), // changes position of shadow
        //   ),
        // ],
      ),
      child: FlatButton(
        onPressed: onPress,
        textColor: textColor ?? Colors.white,
        padding: EdgeInsets.only(top: paddingTop??14, bottom: paddingBottom?? 14),
        // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //  color: bgcolor ?? Colors.transparent,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.only(top:2.0,bottom: 2.0,left: 20),
          child: Row(

            children: [

              false?ImageIcon(AssetImage(path)
                ,color: Colors.white,size: 30,):
              SvgPicture.asset(path,width: 24,height: 24,color: Colors.white,),
              SizedBox(width: 20),

              Text(

                text ?? "",
                style: TextStyle(
                    fontSize: fontSize ?? 13.0,
                    fontFamily: fontFamily ?? "OpenSans Regular",
                    fontWeight: fontWeight ?? FontWeight.normal),

              ),
            ],
          ),
        ),
      ),
    );
  }




  static Widget OvalShapedButtonWhite(
      {@required Function() onPress,
        String text,
        double fontSize,
        FontWeight fontWeight,
        Color textColor,
        String path,
        Color bgcolor,
        double paddingTop,
        double paddingBottom,
        String fontFamily}) {
    return Container(
      height: 70,
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(70.0),
        boxShadow: [
          BoxShadow(
              color: Color(0xffd5dce6),
              offset: Offset(0,6),
              blurRadius: 20

          )
        ],

        gradient: LinearGradient(colors: [Color(0xffffffff), Color(0xffffffff)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        // boxShadow: [
        //   BoxShadow(
        //     color: Custom_color.BlueLightColor.withOpacity(0.5),
        //     spreadRadius: 3,
        //     blurRadius: 6,
        //     offset: Offset(1, 3), // changes position of shadow
        //   ),
        // ],
      ),
      child: FlatButton(
        onPressed: onPress,
        textColor: textColor ?? Colors.white,
        padding: EdgeInsets.only(top: paddingTop??14, bottom: paddingBottom?? 14),
        // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //  color: bgcolor ?? Colors.transparent,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.only(top:2.0,bottom: 2.0,left: 20),
          child: Row(
            children: [

              //Image(image:AssetImage(path),width: 30,height: 30,),
              SvgPicture.asset(path,width: 24,height: 24,color: Colors.grey.shade400,),
              SizedBox(width: 20),

              Text(
                text ?? "",
                style: TextStyle(
                    fontSize: fontSize ?? 13.0,
                    fontFamily: fontFamily ?? "OpenSans Regular",
                    fontWeight: fontWeight ?? FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }






  static Widget RoundRaisedButton(
      {@required Function() onPress,
      String text,
      double fontSize,
      FontWeight fontWeight,
      Color textColor,
      Color bgcolor,
        double paddingTop,
        double paddingBottom,
      String fontFamily}) {
    return Container(
     height: 60,
      width: 340,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),

          gradient: LinearGradient(colors: [Color(0xff23b8f2), Color(0xff1b5dab)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        // boxShadow: [
        //   BoxShadow(
        //     color: Custom_color.BlueLightColor.withOpacity(0.5),
        //     spreadRadius: 3,
        //     blurRadius: 6,
        //     offset: Offset(1, 3), // changes position of shadow
        //   ),
        // ],
      ),
      child: FlatButton(
        onPressed: onPress,
        textColor: textColor ?? Colors.white,
        padding: EdgeInsets.only(top: paddingTop??14, bottom: paddingBottom?? 14),
       // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //  color: bgcolor ?? Colors.transparent,
       // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.only(top:2.0,bottom: 2.0),
          child: Text(
            text ?? "",
            style: TextStyle(
                fontSize: fontSize ?? 14.0,
                fontFamily: fontFamily ?? "OpenSans Regular",
                fontWeight: fontWeight ?? FontWeight.normal),
          ),
        ),
      ),
    );
  }

  static Widget RoundRaisedButtonWithWrap(
      {@required Function() onPress,
        String text,
        double fontSize,
        FontWeight fontWeight,
        Color textColor,
        Color bordercolor,
        Color bgcolor,
        String fontFamily}) {
    return Container(


      child: FlatButton(

        onPressed: onPress,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: textColor ?? Colors.white,
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          //     side: BorderSide(color: bordercolor ?? Colors.white)
        ),
        child: Ink(
          decoration: BoxDecoration(

              //  border:  Border.all(color:  Colors.black, width: 1),


              borderRadius: BorderRadius.circular(5.0),


              gradient: LinearGradient(colors: [Color(0xff23b8f2), Color(0xff1b5dab)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 140.0, minHeight: 50.0),
            child: Center(
              child: Text(
                text ?? "",
                style: TextStyle(
                    fontSize: fontSize ?? 14.0,
                    fontFamily: fontFamily ?? "OpenSans Regular",
                    fontWeight: fontWeight ?? FontWeight.normal),
              ),
            ),
          ),
        ),
      ),
    );
  }
  static Widget FlatButtonSimple(
      {@required Function() onPress,
      String text,
      double fontSize,
      FontWeight fontWeight,
      Color textColor,
      TextAlign textAlign,
      String fontFamily}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          ////  customBorder: new CircleBorder(),
          // borderRadius: BorderRadius.circular(80.0),
          // focusColor: Colors.black12 ,
          //   highlightColor: Colors.orange,
          //   hoverColor: Colors.green,
          //  splashColor: Colors.redAccent,

          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Text(
              text ?? "",
              textAlign: textAlign ?? TextAlign.start,
              style: TextStyle(
                  fontSize: fontSize ?? 14.0,
                  color: textColor ?? Colors.white,
                  fontFamily: fontFamily ?? "OpenSans Regular",
                  fontWeight: fontWeight ?? FontWeight.normal),
            ),
          ),
          onTap: onPress),
    );
//    return FlatButton(
//      onPressed: onPress,
//      textColor: textColor ?? Colors.white,
//      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//      child: Text(
//        text ?? "",
//        style: TextStyle(
//            fontSize: fontSize ?? 14.0,
//            fontFamily: fontFamily ?? "OpenSans Regular",
//            fontWeight: fontWeight ?? FontWeight.normal),
//      ),
//    );
  }

  static Widget RoundRaisedButtonIcon(
      {@required Function() onPress,
      String text,
      double fontSize,
      FontWeight fontWeight,
      Color textColor,
      Color bgcolor,
      IconData icon,
      String fontFamily}) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),

          gradient: LinearGradient(colors: [Color(0xff22b7f1), Color(0xff1c5baa)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),

      // width: double.infinity,
      child: RaisedButton.icon(
        onPressed: onPress,
        textColor: textColor ?? Colors.white,
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        color: bgcolor ?? Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        icon: Icon(
          icon ?? Icons.add,
          color: Custom_color.WhiteColor,
        ),
        label: Text(
          text ?? "",
          style: TextStyle(
              fontSize: fontSize ?? 14.0,
              fontFamily: fontFamily ?? "OpenSans Regular",
              fontWeight: fontWeight ?? FontWeight.normal),
        ),
      ),
    );
  }

  static Widget RoundRaisedButtonIconWithOutText({
    @required Function() onPress,
    double size,
    Color bgcolor,
    IconData icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onPress,
      child: Ink(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 23, right: 23),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: bgcolor ?? Colors.white,
        ),
        child: Icon(
          icon ?? Icons.add,
          color: Custom_color.WhiteColor,
          size: size ?? 14,
        ),
      ),
    );
  }
  static Widget RoundOutlineFlatButtonforWhite(
      {@required Function() onPress,
        String text,
        double fontSize,
        FontWeight fontWeight,
        Color textColor,
        Color bordercolor,
        String fontFamily}) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xffe4e9ef),
            offset: Offset(1,1),
            blurRadius: 20
          )
        ]
      ),




      width: double.infinity,


      child: FlatButton(





        //padding: EdgeInsets.all(0.0),
        onPressed: onPress,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: textColor ?? Colors.white,
        padding: EdgeInsets.only(top: 5, bottom: 5),

        child:

        Ink(

          decoration: BoxDecoration(


           //  border:  Border.all(color:  Colors.black, width: 1),


              borderRadius: BorderRadius.circular(10.0),


              gradient: LinearGradient(colors: [Colors.white, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),




          child: Container(

            constraints: BoxConstraints(maxWidth: 410, minHeight: 30.0,maxHeight: 55),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom:  20),
                child: Text(
                  text ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: fontSize ?? 14.0,
                      fontFamily: fontFamily ?? "OpenSans Regular",
                      fontWeight: fontWeight ?? FontWeight.normal),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget RoundOutlineFlatButton(
      {@required Function() onPress,
        String source,

      String text,
      double fontSize,
      FontWeight fontWeight,
      Color textColor,
      Color bordercolor,
      String fontFamily}) {
    return Container(





      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        //padding: EdgeInsets.all(0.0),
        onPressed: onPress,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: textColor ?? Colors.white,
         padding: EdgeInsets.only(top: 5, bottom: 5),


        child:

        Ink(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),

              gradient: LinearGradient(colors: [Color(0xff22b7f1), Color(0xff1c5baa)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),




          child: Container(
            constraints: BoxConstraints(maxWidth: 410,maxHeight: 55),
          //  padding: const EdgeInsets.only(top:20.0, bottom:20),

            child: Center(
              child: Text(
                  text ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: fontSize ?? 14.0,
                      fontFamily: fontFamily ?? "Kelvetica Nobis",
                      fontWeight: fontWeight ?? FontWeight.normal),
                )

            ),
          ),
        ),
      ),
    );
  }

  static Widget RoundOutlineFlatButtonWrapContant(
      {@required Function() onPress,
      String text,
      double fontSize,
      FontWeight fontWeight,
      Color textColor,
      Color bordercolor,
      String fontFamily}) {
    return Container(


      child: FlatButton(

        onPressed: onPress,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: textColor ?? Colors.white,
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
        //     side: BorderSide(color: bordercolor ?? Colors.white)
        ),
        child: Ink(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
              //  border:  Border.all(color:  Colors.black, width: 1),


              borderRadius: BorderRadius.circular(10.0),


              gradient: LinearGradient(colors: [Colors.white, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 140.0, minHeight: 50.0),
            child: Center(
              child: Text(
                text ?? "",
                style: TextStyle(
                    fontSize: fontSize ?? 14.0,
                    fontFamily: fontFamily ?? "OpenSans Regular",
                    fontWeight: fontWeight ?? FontWeight.normal),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget GetImagesNetwork({String imgURL, BoxFit boxFit,double width,double height}) {
    return Image.network(
      imgURL,
      fit: boxFit,
      width:width,
      height : height,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: false?CircularProgressIndicator(
//            value: loadingProgress.expectedTotalBytes != null ?
//            loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
//                : null,
              ): Container(
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
        );
      },
    );
  }

  // convex effect
  /*
  static final BoxDecoration convex = BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
            offset: Offset(3, 3)
        ),
        BoxShadow(
            color: Colors.white.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(-4, -4)
        )
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blueGrey[200].withOpacity(0.2),
          Colors.blueGrey[200].withOpacity(0.4),
          Colors.blueGrey[200].withOpacity(0.6),
          Colors.blueGrey[200].withOpacity(0.8),
          Colors.blueGrey[200],
        ],
      )
  );

  static final BoxDecoration convexWhite =  BoxDecoration(
      color: Color(0xffd6d6d6),
      boxShadow: [
        BoxShadow(
          blurRadius: 25,
          color: Color(0xffb6b6b6),
          offset: Offset(
            5,
            5,
          ),
        ),
        BoxShadow(
          blurRadius: 25,
          color: Color(0xfff6f6f6),
          offset: Offset(
            -5,
            -5,
          ),
        ),
      ],
      gradient: LinearGradient(
        stops: [0, 1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xffc1c1c1), Color(0xffe5e5e5)],
      ),
      borderRadius: BorderRadius.all(Radius.circular(
        50,
      )));

  // raised effect
  static final BoxDecoration raised = BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: Colors.blueGrey[200],
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            spreadRadius: 0,
            offset: Offset(4, 4)
        ),
        BoxShadow(
            color: Colors.white,
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(-4, -4)
        )
      ]
  );

   */
}
