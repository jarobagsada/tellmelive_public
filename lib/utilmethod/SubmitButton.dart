import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miumiu/colors/colors.dart';

class SubmitButton extends StatefulWidget {
  final String text;
  final AsyncCallback onPressed;

  const SubmitButton({Key key, @required this.text, @required this.onPressed})
      : super(key: key);

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  // bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width ,
        height: MediaQuery.of(context).size.width * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 51,
              width: 300,
              decoration: BoxDecoration(
                color:Color(colorsThemeBlue) ,
                borderRadius: BorderRadius.circular(10.0),
                // gradient: const LinearGradient(colors: [Color(0xff426fb6),Color(0xff426fb6)],
                //     begin: Alignment.topCenter,
                //     end: Alignment.bottomCenter)
              ),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledColor:
                Color(colorsThemeBlue).withOpacity(0.8),
                onPressed: widget.onPressed == null
                    ? null
                    : () async {
                  setState(() {
                  });
                  try {
                    await widget.onPressed();
                  } finally {
                    if (mounted)
                      setState(() {
                      });
                  }
                },
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                    color: Colors.white,fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
