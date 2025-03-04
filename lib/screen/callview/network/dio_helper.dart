import 'package:dio/dio.dart';

import 'constats.dart';


class DioHelper{

  static  Dio dio;

  static init()
  {
    dio = Dio(
      BaseOptions(
          receiveDataWhenStatusError: true,
          connectTimeout: 30*1000, // 30 seconds
          receiveTimeout: 30*1000 // 30 seconds
      ),
    );
  }

  static Future<Response> getData({ String endPoint,Map<String, dynamic> query,
     String baseUrl}) async
  {
      dio.options.baseUrl = baseUrl;
      dio.options.headers =
      {
        'Content-Type':'application/json',
        'Accept': 'application/json',
      };

      try {
        return await dio.get(endPoint,queryParameters: query,);
      }on DioError catch (ex) {
        if(ex.type == DioErrorType.connectTimeout){
          throw Exception("Connection Timeout Exception");
        }
        if (ex.type == DioErrorType.receiveTimeout) {
          throw Exception("Receive Timeout Exception");
        }
        throw Exception(ex.message);
      }

  }

  static Future<Response> postData({
     String endPoint,
    Map<String, dynamic> query,
     Map<String, dynamic> data,
    bool isRow = true,
    bool isPut = false,
    String lang = 'en',
    String token,
     String baseUrl,
  }) async
  {
    dio.options.followRedirects = true;
    dio.options.validateStatus = (status)  => true;

    dio.options.baseUrl = baseUrl;
    dio.options.headers = {
      'Content-Type':'application/json',
      'Accept': 'application/json',
      'Authorization':'key= $fcmKey',
    };

    return !isPut ? await dio.post(
      endPoint,
      queryParameters: query,
      data: isRow ? data : FormData.fromMap(data),
    ) : await dio.put(
      endPoint,
      queryParameters: query,
      data: isRow ? data : FormData.fromMap(data),
    );
  }


}