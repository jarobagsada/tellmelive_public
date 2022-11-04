import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkConnectivity {
  NetworkConnectivity._();

  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _connectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;

  void initialise() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    /*try {
      final result = await InternetAddress.lookup('endpoint.tellmelive.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }*/
    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      // this is the different
      if (await InternetConnectionChecker().hasConnection) {
        isOnline = true;
      } else {
        isOnline = false;
      }
    } else {
      isOnline = false;
    }
   // if(_controller.isClosed) {
      _controller.sink.add({result: isOnline});
    /*}else{
      _controller.onResume();
      _controller.sink.add({result: isOnline});
    }*/
  }


  void disposeStream() => _controller.onCancel();
}