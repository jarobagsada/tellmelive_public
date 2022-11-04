import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utilmethod/constant.dart';
import '../../../utilmethod/constats.dart';
import '../../../utilmethod/preferences.dart';


class HomeApi{

 //Not Used
 Future<QuerySnapshot<Map<String,dynamic>>> getUsers() async{
   return FirebaseFirestore.instance.collection(userCollection).where('uId',isNotEqualTo: SessionManager.getString(Constant.user_fcmUid)).get();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getUsersRealTime() {
   return FirebaseFirestore.instance.collection(userCollection).where('uId',isNotEqualTo: SessionManager.getString(Constant.user_fcmUid)).snapshots().listen((event) {});
 }

 StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getCallHistoryRealTime() {
  return FirebaseFirestore.instance.collection(callsCollection).orderBy('createAt',descending: true).snapshots().listen((event) {});
 }
 
 
}