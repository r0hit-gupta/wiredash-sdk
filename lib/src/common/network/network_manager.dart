import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/common/network/api_client.dart';

class NetworkManager {
  NetworkManager(this._apiClient);

  final ApiClient _apiClient;

  static const String _feedbackPath = 'feedback';

  static const String _parameterDeviceInfo = 'deviceInfo';
  static const String _parameterEmail = 'email';
  static const String _parameterPayload = 'payload';
  static const String _parameterUser = 'user';

  static const String _parameterFeedbackMessage = 'message';
  static const String _parameterFeedbackTitle = 'title';
  static const String _parameterFeedbackScreenshot = 'file';
  static const String _parameterFeedbackType = 'type';

  Future<void> sendFeedback({
    @required Map<String, dynamic> deviceInfo,
    String email,
    String message,
    @required String title,
    String payloadFilePath,
    Uint8List picture,
    @required String type,
    String user,
  }) async {
    MultipartFile screenshotFile;
    MultipartFile payloadFile;

    if (picture != null) {
      screenshotFile = MultipartFile.fromBytes(
        _parameterFeedbackScreenshot,
        picture,
        filename: 'file',
        contentType: MediaType('image', 'png'),
      );
    }
    if (payloadFilePath != null) {
      payloadFile = await MultipartFile.fromPath(
        _parameterPayload,
        payloadFilePath,
      );
    }

    await _apiClient.post(
      urlPath: _feedbackPath,
      arguments: {
        _parameterDeviceInfo: json.encode(deviceInfo),
        if (email != null)
          _parameterEmail: email,
        if (_parameterFeedbackMessage != null)
          _parameterFeedbackMessage: message,
        // if (payload != null) _parameterPayload: json.encode(payload),
        _parameterFeedbackType: type,
        _parameterFeedbackTitle: title,
        if (user != null)
          _parameterUser: user
      },
      files: [screenshotFile, payloadFile],
    );
  }
}
