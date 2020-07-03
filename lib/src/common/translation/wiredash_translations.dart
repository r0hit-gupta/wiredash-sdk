/// This is a default list of translatable terms in the
/// Wiredash package.
///
/// If you want to override default translations you need to
/// provide your custom implementation of this class
abstract class WiredashTranslations {
  const WiredashTranslations();
  String get captureSkip;
  String get captureTakeScreenshot;
  String get captureSaveScreenshot;
  String get captureSpotlightNavigateTitle;
  String get captureSpotlightNavigateMsg;
  String get captureSpotlightScreenCapturedTitle;
  String get captureSpotlightScreenCapturedMsg;
  String get feedbackModeBugTitle;
  String get feedbackModeBugMsg;
  String get feedbackModeImprovementTitle;
  String get feedbackModeImprovementMsg;
  String get feedbackModePraiseTitle;
  String get feedbackModePraiseMsg;
  String get feedbackBack;
  String get feedbackCancel;
  String get feedbackSave;
  String get feedbackSend;
  String get feedbackStateFeedbackTitle;
  String get feedbackStateIntroTitle;
  String get feedbackStateIntroMsg;
  String get feedbackStateFeedbackMsg;
  String get feedbackStateEmailTitle;
  String get feedbackStateEmailMsg;
  String get feedbackStateSuccessTitle;
  String get feedbackStateSuccessMsg;
  String get feedbackStateSuccessCloseTitle;
  String get feedbackStateSuccessCloseMsg;
  String get inputHintFeedbackTitle;
  String get inputHintFeedback;
  String get inputHintEmail;
  String get validationHintFeedbackTitleEmpty;
  String get validationHintFeedbackTitleLength;
  String get validationHintFeedbackEmpty;
  String get validationHintFeedbackLength;
  String get validationHintEmail;
}
