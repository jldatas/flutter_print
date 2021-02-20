import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPrinter {
  static const MethodChannel _channel = const MethodChannel('flutter_printer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static connectWifi(String ip, int port) async {
    final info = await _channel
        .invokeMethod('connectWifi', <String, dynamic>{'ip': ip, 'port': port});
    return info;
  }

  static disconnect() async {
    final info = await _channel.invokeMethod('disconnect');
    return info;
  }

  static codeQR(int labelWidth, int labelLength, int row, int col, int size,
      String label, String text) async {
    final info = await _channel.invokeMethod('codeQR', <dynamic, dynamic>{
      'labelWidth': labelWidth,
      'labelLength': labelLength,
      'row': row,
      'col': col,
      'size': size,
      'label': label,
      'text': text
    });
    return info;
  }

  static code128(int labelWidth, int labelLength, int row, int col, bool bottom,
      bool top, String text) async {
    final info = await _channel.invokeMethod('code128', <dynamic, dynamic>{
      'labelWidth': labelWidth,
      'labelLength': labelLength,
      'row': row,
      'col': col,
      'bottom': bottom,
      'top': top,
      'text': text
    });
    return info;
  }

  static text(int labelWidth, int labelLength, int row, int col, int textWidth,
      int textHeight, String text) async {
    final info = await _channel.invokeMethod('text', <dynamic, dynamic>{
      'labelWidth': labelWidth,
      'labelLength': labelLength,
      'row': row,
      'col': col,
      'textWidth': textWidth,
      'textHeight': textHeight,
      'text': text
    });
    return info;
  }

  static runCmd(String text) async {
    final info =
        await _channel.invokeMethod('runCmd', <dynamic, dynamic>{'text': text});
    return info;
  }
}
