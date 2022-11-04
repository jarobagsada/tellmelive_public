
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../socket/model/res_call_accept_model.dart';
import '../../socket/model/res_call_request_model.dart';
import '../../socket/socket_constants.dart';
import '../../socket/socket_manager.dart';
import '../../utils/color_utils.dart';
import '../../utils/constants/api_constants.dart';
import '../../utils/constants/arg_constants.dart';
import '../../utils/constants/route_constants.dart';
import '../../utils/dimens.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../utils/permission_utils.dart';

class CommonScreen extends StatefulWidget {
  @override
  _CommonScreenState createState() => _CommonScreenState();
}

class _CommonScreenState extends State<CommonScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      initSocketManager(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.of(context).appBarLabel),
        centerTitle: true,
        backgroundColor: ColorUtils.accentColor,
      ),
      body: Center(
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius:BorderRadius.circular(20)
          ),
          color: Colors.green,//ColorUtils.accentColor,

          child: Text("Call Now",//Localization.of(context).primaryBtnLabel,

              style: TextStyle(
                  color: ColorUtils.whiteColor, fontSize: buttonLabelFontSize)),
          onPressed: () {
            print('CommonScreen  ApiConstants.chatUserId=${ ApiConstants.chatUserId}');
            PermissionUtils.requestPermission(
                [PermissionGroup.camera, PermissionGroup.microphone], context,
                isOpenSettings: true, permissionGrant: () async {
              emit(
                  SocketConstants.connectCall,
                  ({
                    ArgParams.connectId: ApiConstants.chatUserId, //Receiver Id
                  }));
              NavigationUtils.push(context, RouteConstants.routePickUpScreen,
                  arguments: {
                    ArgParams.resCallAcceptModel:
                        ResCallAcceptModel(otherUserId: ApiConstants.chatUserId), //Receiver Id
                    ArgParams.resCallRequestModel: ResCallRequestModel(),
                    ArgParams.isForOutGoing: true,
                  });
            });
          },
        ),
      ),
    );
  }
}
