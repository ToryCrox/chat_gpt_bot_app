import 'dart:io';

import 'package:chat_boot_app/model.dart';
import 'package:chat_boot_app/prefs_helper.dart';
import 'package:chat_boot_app/type_util.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dog/dog.dart';

class HttpTool {
  static Dio? _dio;
  static const String _apiUrl = "https://api.openai.com/v1/chat/completions";

  static String get apiKey => PrefsHelper.getString('_apk_key');

  static set apiKey(String key) {
    PrefsHelper.setString('_apk_key', key);
  }

  static String get httpProxy => PrefsHelper.getString('http_proxy', '127.0.0.1:7890');
  static set httpProxy(String proxy) {
    PrefsHelper.setString('http_proxy', proxy);
  }

  static Dio get dio {
    if (_dio == null) {
      final options = BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15));
      final dio = Dio(options);
      _internalSettingProxy(dio);
      _dio = dio;
    }

    return _dio!;
  }

  static void setProxy(String proxy) {
    httpProxy = proxy;
  }

  static void _internalSettingProxy(Dio dio) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (url) {
        print('_internalSettingProxy findProxy $httpProxy, url: $url');
        if (httpProxy.isNotEmpty) {
          ///设置代理 电脑ip地址
          return "PROXY $httpProxy";
        } else {
          ///不设置代理
          return 'DIRECT';
        }
      };

      ///忽略证书
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
  }

  static Future<ChatMessage> post(String text) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final option = Options(headers: headers);
    final data = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': text}
      ]
    };
    try {
      final response = await dio.post(
        _apiUrl,
        data: data,
        options: option,
      );
      if (response.statusCode == 200) {
        final chatResponse =
            ChatResponse.fromMap(TypeUtil.parseMap(response.data));
        dog.d('chatResponse: ${chatResponse.toMap()}');
        return ChatMessage(
          author: 'Bot',
          content: chatResponse.choices.first.message.content.trim(),
          timeStamp: DateTime.now(),
        );
      } else {
        return ChatMessage(
          author: 'Bot',
          content: 'Error',
          timeStamp: DateTime.now(),
          error: TypeUtil.parseString({
            'statusCode': response.statusCode,
            'statusMessage': response.statusMessage,
            'data': response.data,
          }),
        );
      }
    } catch (e) {
      dog.e(e);
      if (e is DioError) {
        return ChatMessage(
          author: 'Bot',
          content: 'Error',
          timeStamp: DateTime.now(),
          error: TypeUtil.parseString({
            'statusCode': e.response?.statusCode,
            'statusMessage': e.response?.statusMessage,
            'data': e.response?.data,
          }),
        );
      } else {
        return ChatMessage(
          author: 'Bot',
          content:  'Error',
          timeStamp: DateTime.now(),
          error: TypeUtil.parseString({
            'error': e,
          }),
        );
      }
    }
  }
}
