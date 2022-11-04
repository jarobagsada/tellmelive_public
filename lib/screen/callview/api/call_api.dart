import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../../utilmethod/constant.dart';
import '../../../utilmethod/constats.dart';
import '../../../utilmethod/preferences.dart';
import '../../holder/call_model.dart';
import '../network/dio_helper.dart';


class CallApi {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      listenToInComingCall() {
    return FirebaseFirestore.instance
        .collection(callsCollection)
        .where('receiverId', isEqualTo: SessionManager.getString(Constant.user_fcmUid))
        .snapshots()
        .listen((event) {});
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
  listenToCallStatus({ String callId}) {
    return FirebaseFirestore.instance
        .collection(callsCollection)
        .doc(callId)
        .snapshots()
        .listen((event) {});
  }

  Future<void> postCallToFirestore({ CallModel callModel}) {
    return FirebaseFirestore.instance
        .collection(callsCollection)
        .doc(callModel.id)
        .set(callModel.toMap());
  }

  Future<void> updateUserBusyStatusFirestore({ CallModel callModel, bool busy}) {
    Map<String, dynamic> busyMap = {'busy': busy};
    return FirebaseFirestore.instance
        .collection(userCollection)
        .doc(callModel.callerId)
        .update(busyMap)
        .then((value) {
      FirebaseFirestore.instance
          .collection(userCollection)
          .doc(callModel.receiverId)
          .update(busyMap);
    });
  }

  //Sender
  Future<dynamic> generateCallToken(
      { Map<String, dynamic> queryMap}) async {
    try {
      debugPrint('queryMap: ${queryMap}');
      debugPrint('fireCallEndpoint: ${fireCallEndpoint}');
      debugPrint('cloudFunctionBaseUrl: ${cloudFunctionBaseUrl}');
      ;


      var response = await DioHelper.getData(
          endPoint: fireCallEndpoint,
          query: queryMap,
          baseUrl: cloudFunctionBaseUrl);
      debugPrint('fireVideoCallResp: ${response.data}');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Error: ${response.data} Status Code: ${response.statusCode}');
      }
    } on DioError catch (error) {
      debugPrint("fireVideoCallError: ${error.toString()}");
    }
  }


  Future<void> updateCallStatus({ String callId, String status}){
    return FirebaseFirestore.instance
        .collection(callsCollection)
        .doc(callId)
        .update({'status': status});
  }
  Future<void> endCurrentCall({ String callId}){
    return FirebaseFirestore.instance
        .collection(callsCollection)
        .doc(callId)
        .update({'current': false});
  }
}
