import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

/// 一些数据转换工具，主要确保安全
class TypeUtil {
  TypeUtil._();

  /// 转换成int
  /// 如果value是bool，则true转换成1， false为0
  static int parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value == 'null') return defaultValue;

    if (value is String) {
      try {
        return double.parse(value).toInt();
      } catch (e) {
        return defaultValue;
      }
    }
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    return defaultValue;
  }

  /// 解析bool类型
  /// - 如果为bool类型，则直接返回
  /// - 如果为num类型，则为0表示false，否则为true
  /// - 如果为String类型，则'true'表示true，否则转换Int类型， 判断是否为0
  static bool parseBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      return parseInt(value) != 0;
    }
    return defaultValue;
  }

  /// 转换成String
  /// 如果value是bool，则true转换成'1'， false为'0'
  /// 如果value是Map或List, Set，则转换成json字符串
  static String parseString(dynamic value, [String defaultValue = '']) {
    if (value == null) return '';
    if (value == 'null') return '';
    if (value is Map || value is List) return jsonEncode(value);
    if (value is Set) return jsonEncode(value.toList());
    return '$value';
  }

  /// 转换成double
  /// 如果value是bool，则true转换成1.0， false为0.0
  /// 如果value是String，则转换成double
  /// 如果value是int，则转换成double
  /// 如果value是double，则直接返回
  /// 如果value是其他类型，则返回0.0
  static double parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  /// 解析list， value可以为字符串数组
  /// 如果value是字符串，则尝试解析成json数组
  /// 如果value是数组，则直接返回
  /// 如果value是null，则返回空数组
  /// 如果value是其他类型，则返回空数组
  /// 如果value是空字符串，则返回空数组
  static List<T> parseList<T>(dynamic value, T Function(dynamic e) f) {
    if (value == null) return [];
    List list = [];
    if (value is String && value.isNotEmpty) {
      try {
        list = jsonDecode(value);
      } catch (e) {
        list = [];
      }
    } else if (value is List) {
      list = value;
    }

    if (list.isNotEmpty) {
      return list.map((e) => f(e)).toList();
    } else {
      return [];
    }
  }

  static List<String> parseStringList(dynamic value) {
    if (value is List<String>) return value;
    return parseList(value, (e) => parseString(e));
  }

  static List<int> parseIntList(dynamic value) {
    if (value is List<int>) return value;
    return parseList(value, (e) => parseInt(e));
  }

  /// value解析，确保不会报错
  static Map<String, dynamic> parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return jsonDecode(value);
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  /// 解析Color, 支持#ffffff, #ffffffff, 0xffffffff, 0xffffff, 0xff, 0xffffffff, 0xffffff, 0xff
  /// 如果解析失败，则返回透明色
  static Color parseColor(dynamic value, [Color defaultValue = Colors.transparent]) {
    if (value == null) return defaultValue;
    if (value is Color) return value;
    if (value is String) {
      if (!value.startsWith('#') && !value.startsWith('0x')) {
        return defaultValue;
      }
      try {
        return Color(int.parse(value.replaceAll('#', '0xff')));
      } catch (e) {
        return defaultValue;
      }
    }
    if (value is int) return Color(value);
    return defaultValue;
  }
}
