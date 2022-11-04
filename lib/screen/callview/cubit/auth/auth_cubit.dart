import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../holder/userauth_model.dart';
import '../../api/auth_api.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  String Tag="AuthCubit";

  static AuthCubit get(context) => BlocProvider.of(context);

  UserAuthModel currentUser;

  final _authApi = AuthApi();

  void login({ String email,  String password}) async {
    emit(LoadingLoginState());
    _authApi.login(email: email, password: password).then((value){
      debugPrint(value.user.email);
      checkUserExistInFirebase(uId: value.user.uid);
    }).catchError((onError){
      print('$AuthCubit login catchError=$onError');
      emit(ErrorLoginState(onError.toString()));
    });
  }

  void register(
      { String email,
       String password,
       String name}) async {
    emit(LoadingRegisterState());
    _authApi.register(email: email, password: password, name: name).then((value){
      createUser(
        name: name,
        email: email,
        uId: value.user.uid,
      );
    }).catchError((onError){
      print('$AuthCubit register catchError=$onError');
      emit(ErrorRegisterState(onError.toString()));
    });
  }

  void checkUserExistInFirebase({ String uId}) {
    _authApi.checkUserExistInFirebase(uId: uId).then((user) {
      if (user.exists) {
        currentUser = UserAuthModel.fromJsonMap(map: user.data(), uId: uId);
        emit(SuccessLoginState(uId));
      } else {
        emit(ErrorLoginState('Account not exist'));
      }
    }).catchError((onError){
      print('$AuthCubit checkUserExistInFirebase catchError=$onError');

      emit(ErrorLoginState(onError.toString()));
    });

  }

  void getUserData({ String uId}) {
    if (uId.isNotEmpty) {
      emit(LoadingGetUserDataState());
      _authApi.getUserData(uId: uId).then((value){
        if (value.exists) {
          currentUser =
              UserAuthModel.fromJsonMap(map: value.data(), uId: value.id);
        } else {
          emit(ErrorGetUserDataState('User not found'));
        }
        emit(SuccessGetUserDataState());
      }).catchError((onError){
        print('$AuthCubit getUserData catchError=$onError');
        emit(ErrorGetUserDataState(onError.toString()));
      });
    }
  }

  void createUser(
      { String name,  String email,  String uId}) {
    UserAuthModel user = UserAuthModel.resister(
        name: name, id: uId, email: email, avatar: 'https://i.pravatar.cc/300',busy: false);
    _authApi.createUser(user: user).then((value) {
      currentUser = user;
      emit(SuccessRegisterState(uId));
    }).catchError((onError){
      print('$AuthCubit createUser catchError=$onError');

      emit(ErrorRegisterState(onError.toString()));
    });
  }
  Future<void> authSignOut(BuildContext context)async{
    await FirebaseAuth.instance.signOut().then((_){
      Navigator.of(context).pushNamedAndRemoveUntil("/login", ModalRoute.withName("/home"));
    });
  }
}
