/// Maps the POST /analyze-frame response.
class FrameAnalysisResult {
  final bool success;
  final bool faceDetected;
  final bool readyToCapture;
  final String feedbackMessage;
  final String feedbackColor; // "green" | "yellow" | "red"
  final int overallScore; // 0–100

  const FrameAnalysisResult({
    required this.success,
    required this.faceDetected,
    required this.readyToCapture,
    required this.feedbackMessage,
    required this.feedbackColor,
    required this.overallScore,
  });

  factory FrameAnalysisResult.fromJson(Map<String, dynamic> json) =>
      FrameAnalysisResult(
        success: json['success'] as bool? ?? false,
        faceDetected: json['face_detected'] as bool? ?? false,
        readyToCapture: json['ready_to_capture'] as bool? ?? false,
        feedbackMessage: json['feedback_message'] as String? ?? '',
        feedbackColor: json['feedback_color'] as String? ?? 'red',
        overallScore: (json['overall_score'] as num?)?.toInt() ?? 0,
      );

  /// A safe "not ready" result used when the response is stale or failed.
  static const FrameAnalysisResult notReady = FrameAnalysisResult(
    success: false,
    faceDetected: false,
    readyToCapture: false,
    feedbackMessage: 'Positioning…',
    feedbackColor: 'red',
    overallScore: 0,
  );
}
