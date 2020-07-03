import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/capture.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/network/network_manager.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/common/utils/device_info.dart';
import 'package:wiredash/src/common/widgets/dismissible_page_route.dart';

import 'feedback_sheet.dart';

class FeedbackModel with ChangeNotifier {
  FeedbackModel(this._captureKey, this._navigatorKey, this._networkManager,
      this._userManager, this._buildInfoManager);

  final GlobalKey<CaptureState> _captureKey;
  final GlobalKey<NavigatorState> _navigatorKey;
  final NetworkManager _networkManager;
  final UserManager _userManager;
  final BuildInfoManager _buildInfoManager;

  FeedbackType feedbackType = FeedbackType.bug;
  String feedbackMessage;
  String feedbackTitle;
  Uint8List screenshot;

  FeedbackUiState _feedbackUiState = FeedbackUiState.hidden;
  FeedbackUiState get feedbackUiState => _feedbackUiState;
  set feedbackUiState(FeedbackUiState newValue) {
    if (_feedbackUiState == newValue) return;
    _feedbackUiState = newValue;
    _handleUiChange();
    notifyListeners();
  }

  bool _error = false;
  bool get error => _error;
  set error(bool newValue) {
    if (_error == newValue) return;
    _error = newValue;
    notifyListeners();
  }

  bool _loading = false;
  set loading(bool newValue) {
    if (_loading == newValue) return;
    _loading = newValue;
    notifyListeners();
  }

  bool get loading => _loading;

  void _handleUiChange() {
    switch (_feedbackUiState) {
      case FeedbackUiState.intro:
        _clearFeedback();
        break;
      case FeedbackUiState.capture:
        _captureKey.currentState.show().then((image) {
          screenshot = image;
          _feedbackUiState = FeedbackUiState.feedbackTitle;
          _navigatorKey.currentState.push(
            DismissiblePageRoute(
              builder: (context) => FeedbackSheet(),
              background: image,
              onPagePopped: () {
                feedbackUiState = FeedbackUiState.hidden;
              },
            ),
          );
        });
        break;
      case FeedbackUiState.success:
        _sendFeedback();
        break;
      default:
      // do nothing
    }
  }

  void _clearFeedback() {
    feedbackMessage = null;
    feedbackTitle = null;
    screenshot = null;
  }

  void _sendFeedback() {
    error = false;
    loading = true;

    _networkManager
        .sendFeedback(
            deviceInfo: DeviceInfo.generate(_buildInfoManager),
            email: _userManager.userEmail,
            message: feedbackMessage,
            title: feedbackTitle,
            picture: screenshot,
            type: feedbackType.label,
            user: _userManager.userId,
            payloadFilePath: _buildInfoManager.payloadFilePath)
        .catchError((_) {
      error = true;
    }).then((value) {
      _clearFeedback();
    }).whenComplete(() {
      loading = false;
    });
  }

  void show() {
    assert(_navigatorKey.currentState != null, '''
Wiredash couldn't access your app's root navigator.

This is likely to happen when you forget to add the navigator key to your 
Material- / Cupertino- or WidgetsApp widget. 

To fix this, simply assign the same GlobalKey you assigned to Wiredash 
to your Material- / Cupertino- or WidgetsApp widget, like so:

return Wiredash(
  projectId: "YOUR-PROJECT-ID",
  secret: "YOUR-SECRET",
  navigatorKey: _navigatorKey, // <-- should be the same
  child: MaterialApp(
    navigatorKey: _navigatorKey, // <-- should be the same
    title: 'Flutter Demo',
    home: ...
  ),
);

For more info on how to setup Wiredash, check out 
https://github.com/wiredashio/wiredash-sdk

If this did not fix the issue, please file an issue at 
https://github.com/wiredashio/wiredash-sdk/issues

Thanks!
''');

    if (_navigatorKey.currentState == null ||
        feedbackUiState == FeedbackUiState.capture) return;

    feedbackUiState = FeedbackUiState.intro;
    _navigatorKey.currentState.push(
      DismissiblePageRoute(
        builder: (context) => FeedbackSheet(),
        onPagePopped: () {
          feedbackUiState = FeedbackUiState.hidden;
        },
      ),
    );
  }
}

enum FeedbackType { bug, improvement, praise }

extension FeedbackTypeMembers on FeedbackType {
  String get label => const {
        FeedbackType.bug: "bug",
        FeedbackType.improvement: "improvement",
        FeedbackType.praise: "praise",
      }[this];
}

enum FeedbackUiState {
  hidden,
  intro,
  capture,
  feedbackTitle,
  feedback,
  email,
  success
}
