import 'dart:convert';

import 'package:chat_boot_app/type_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储帮助类，全部为空安全
class PrefsHelper {

  PrefsHelper._();

  static late SharedPreferences _prefs;

  static bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  static delete(String key) {
    _prefs.remove(key);
  }

  static Future<bool> init() async {
    _prefs = await SharedPreferences.getInstance();
    return true;
  }

  static int getInt(String key, [int defaultValue = 0]) {
    return TypeUtil.parseInt(_prefs.get(key), defaultValue);
  }

  static void setInt(String key, int value) {
    _prefs.setInt(key, value);
  }

  static double getDouble(String key, [double defaultValue = 0]) {
    return TypeUtil.parseDouble(_prefs.get(key), defaultValue);
  }

  static void  setDouble(String key, double value) {
    _prefs.setDouble(key, value);
  }

  static bool getBool(String key, [bool defaultValue = false]) {
    return TypeUtil.parseBool(_prefs.get(key), defaultValue);
  }

  static void setBool(String key, bool value) {
    _prefs.setBool(key, value);
  }

  static String getString(String key, [String defaultValue = '']) {
    return TypeUtil.parseString(_prefs.get(key), defaultValue);
  }

  static void setString(String key, String value) {
    _prefs.setString(key, value);
  }

  static List<String> getStringList(String key) {
    return _prefs.getStringList(key) ?? [];
  }

  static void setStringList(String key, List<String> value) {
    _prefs.setStringList(key, value);
  }

  static List<T> getList<T>(String key, T Function(String s) fn) {
    return getStringList(key).map((e) => fn(e)).toList();
  }

  static void setList<T>(String key, List<T> value, String Function(T e) fn) {
    _prefs.setStringList(key, value.map((e) => fn(e)).toList());
  }

  static Map<String, dynamic> getMap(String key) {
    return TypeUtil.parseMap(getString(key, ''));
  }

  static void setMap(String key, Map<String, dynamic> value) {
    _prefs.setString(key, jsonEncode(value));
  }
}