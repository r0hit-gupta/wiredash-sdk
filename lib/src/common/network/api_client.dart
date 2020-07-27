import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class ApiClient {
  ApiClient({
    @required this.httpClient,
    @required this.projectId,
    @required this.secret,
  });

  // static const String _host = 'http://localhost:5001/wiredash-75f17/us-central1/app';
  static const String _host = 'https://us-central1-wiredash-75f17.cloudfunctions.net/app/';

  final Client httpClient;
  final String projectId;
  final String secret;

  Future<Map<String, dynamic>> get(String urlPath) async {
    final url = '$_host$urlPath';
    final BaseResponse response = await httpClient.get(url, headers: {
      'project': projectId,
      'authorization': secret
    });
    final responseString = utf8.decode((response as Response).bodyBytes);
    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}:\n$responseString');
    }
    try {
      return json.decode(responseString) as Map<String, dynamic>;
    } catch (exception) {
      throw Exception('${exception.toString()}\n$responseString');
    }
  }

  Future<Map<String, dynamic>> post({
    @required String urlPath,
    @required Map<String, String> arguments,
    List<MultipartFile> files,
  }) async {
    final url = '$_host$urlPath';
    BaseResponse response;
    String responseString;
    arguments.removeWhere((key, value) => value == null || value.isEmpty);
    files.removeWhere((element) => element == null);

    if (files != null && files.isNotEmpty) {
      final multipartRequest = MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(arguments)
        ..files.addAll(files);
      multipartRequest.headers['project'] = projectId;
      multipartRequest.headers['authorization'] = secret;

      response = await multipartRequest.send();
      responseString =
          utf8.decode(await (response as StreamedResponse).stream.toBytes());
    } else {
      response = await httpClient.post(
        url,
        headers: {
          'project': projectId,
          'authorization': secret
        },
        body: arguments,
      );
      responseString = utf8.decode((response as Response).bodyBytes);
    }

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}:\n$responseString');
    }
    try {
      return json.decode(responseString) as Map<String, dynamic>;
    } catch (exception) {
      throw Exception('${exception.toString()}\n$responseString');
    }
  }
}
