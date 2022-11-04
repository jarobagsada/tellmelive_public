import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../utilmethod/constats.dart';
import '../../holder/userauth_model.dart';


class AuthApi {
  Future<UserCredential> login(
      { String email,  String password}) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register(
      { String email,  String password,  String name}) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUser(
      { UserAuthModel user}) {
   return FirebaseFirestore.instance
        .collection(userCollection)
        .doc(user.id)
        .set(user.toMap());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> checkUserExistInFirebase(
      { String uId}) {
    return FirebaseFirestore.instance.collection(userCollection).doc(uId).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(
      { String uId}) {
    return FirebaseFirestore.instance.collection(userCollection).doc(uId).get();
  }

}
