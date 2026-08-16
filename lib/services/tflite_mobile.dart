import 'package:tflite_flutter/tflite_flutter.dart';

/// Native (Mobile/Desktop) TFLite Interpreter Facade using tflite_flutter FFI
class TFLiteInterpreterFacade {
  static Future<dynamic> fromAsset(String path) async {
    try {
      return await Interpreter.fromAsset(path);
    } catch (_) {
      return null;
    }
  }
}
