import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import '../../../utilmethod/constats.dart';
import '../../holder/call_model.dart';
import '../api/call_api.dart';
import '../home/home_cubit.dart';
import 'call_state.dart';
import 'package:quiver/async.dart';

class CallCubit extends Cubit<CallState> {
  CallCubit() : super(CallInitial());
  String Tag="CallCubit";

  static CallCubit get(context) => BlocProvider.of(context);


  //Agora video room

  int remoteUid;
  RtcEngine engine;


  Future<void> initAgoraAndJoinChannel({ String channelToken, String channelName, bool isCaller}) async {
    //create the engine
    print('$Tag ## agoraAppId=$agoraAppId');
    engine = await RtcEngine.create(agoraAppId);
   // await engine!.enableVideo();
    await engine.enableAudio();
    engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          debugPrint("local user $uid joined");
        },
        userJoined: (int uid, int elapsed) {
          debugPrint("remote user $uid joined");
          remoteUid = uid;
          emit(AgoraRemoteUserJoinedEvent());
        },
        userOffline: (int uid, UserOfflineReason reason) {
          debugPrint("remote user $uid left channel");
          remoteUid = null;
          emit(AgoraUserLeftEvent());
        },

      ),
    );

    //join channel
    await engine.joinChannel(agoraTestToken, agoraTestChannelName, null, 0);
    if(isCaller){
      emit(AgoraInitForSenderSuccessState());
      playContactingRing(isCaller: true);
    }else{
      emit(AgoraInitForReceiverSuccessState());
    }

    debugPrint('channelTokenIs $channelToken channelNameIs $channelName');
  }

  //Sender
  AudioPlayer assetsAudioPlayer = AudioPlayer();

  Future<void> playContactingRing({ bool isCaller}) async {
    String audioAsset = "assets/sounds/ringlong.mp3";
    ByteData bytes = await rootBundle.load(audioAsset);
    Uint8List  soundBytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    int result = await assetsAudioPlayer.playBytes(soundBytes);
    if(result == 1){ //play success
      debugPrint("Sound playing successful.");
    }else{
      debugPrint("Error while playing sound.");
    }
    if(isCaller){
      startCountdownCallTimer();
    }
  }

  int current = 0;
   CountdownTimer countDownTimer;
  void startCountdownCallTimer() {
    countDownTimer = CountdownTimer(
      const Duration(seconds: callDurationInSec),
      const Duration(seconds: 1),
    );
    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      current = callDurationInSec - duration.elapsed.inSeconds;
      debugPrint("DownCount: $current");
    });

    sub.onDone(() {
      debugPrint("CallTimeDone");
      sub.cancel();
      emit(DownCountCallTimerFinishState());
    });
  }

  bool muted = false;
  Widget muteIcon = const Icon(Icons.keyboard_voice_rounded,color: Colors.black,);

  Future<void> toggleMuted() async {
    muted = !muted;
    muteIcon = muted
        ? const Icon(Icons.mic_off_rounded,color: Colors.black,)
        : const Icon(Icons.keyboard_voice_rounded,color: Colors.black,);
    await engine.muteLocalAudioStream(muted);
    emit(AgoraToggleMutedState());
  }

  Future<void> switchCamera() async {
    await engine.switchCamera();
    emit(AgoraSwitchCameraState());
  }

  //Update Call Status
  final _callApi = CallApi();
  void updateCallStatusToUnAnswered({ String callId}){
    emit(LoadingUnAnsweredVideoChatState());
    _callApi.updateCallStatus(callId: callId, status: CallStatus.unAnswer.name).then((value) {
      emit(SuccessUnAnsweredVideoChatState());
    }).catchError((onError){
      emit(ErrorUnAnsweredVideoChatState(onError.toString()));
    });
  }
  Future<void> updateCallStatusToCancel({ String callId})async {
    await _callApi.updateCallStatus(callId: callId, status: CallStatus.cancel.name);
  }
  Future<void> updateCallStatusToReject({ String callId})async {
    await _callApi.updateCallStatus(callId: callId, status: CallStatus.reject.name);
  }
  Future<void> updateCallStatusToAccept({ CallModel callModel})async {
   await _callApi.updateCallStatus(callId: callModel.id, status: CallStatus.accept.name);
   initAgoraAndJoinChannel(channelToken: agoraTestChannelName, channelName: agoraTestToken, isCaller: false);
  }
  Future<void> updateCallStatusToEnd({ String callId})async {
    await _callApi.updateCallStatus(callId: callId, status: CallStatus.end.name);
  }

  Future<void> endCurrentCall({ String callId}) async {
    await _callApi.endCurrentCall(callId: callId);
  }
  Future<void> updateUserBusyStatusFirestore({ CallModel callModel}) async{
    await _callApi.updateUserBusyStatusFirestore(callModel: callModel, busy: false);
  }

  Future<void> performEndCall({ CallModel callModel}) async{
    await endCurrentCall(callId: callModel.id);
    await updateUserBusyStatusFirestore(callModel: callModel);

  }

  StreamSubscription callStatusStreamSubscription;
  void listenToCallStatus({ CallModel callModel, BuildContext context, bool isReceiver}){
   var _homeCubit = HomeCubit.get(context);
   callStatusStreamSubscription = _callApi.listenToCallStatus(callId: callModel.id);
   callStatusStreamSubscription.onData((data) {
      if(data.exists){
        String status = data.data()['status'];
        if(status == CallStatus.accept.name) {
          _homeCubit.currentCallStatus = CallStatus.accept;
          debugPrint('acceptStatus');
          emit(CallAcceptState());
        }
        if(status == CallStatus.reject.name) {
          _homeCubit.currentCallStatus = CallStatus.reject;
          debugPrint('rejectStatus');
          callStatusStreamSubscription.cancel();
          emit(CallRejectState());
        }
        if(status == CallStatus.unAnswer.name) {
          _homeCubit.currentCallStatus = CallStatus.unAnswer;
          debugPrint('unAnswerStatusHere');
          callStatusStreamSubscription.cancel();
          emit(CallNoAnswerState());
        }
        if(status == CallStatus.cancel.name) {
          _homeCubit.currentCallStatus = CallStatus.cancel;
          debugPrint('cancelStatus');
          callStatusStreamSubscription.cancel();
          emit(CallCancelState());
        }
        if(status == CallStatus.end.name){
          _homeCubit.currentCallStatus = CallStatus.end;
          debugPrint('endStatus');
          callStatusStreamSubscription.cancel();
          emit(CallEndState());
        }
      }
    });
  }
}

