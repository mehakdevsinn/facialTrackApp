/// Maps the GET /enrollment-config response.
class EnrollmentConfig {
  final List<CaptureStep> captureSequence;
  final int recommendedFps;

  const EnrollmentConfig({
    required this.captureSequence,
    required this.recommendedFps,
  });

  factory EnrollmentConfig.fromJson(Map<String, dynamic> json) {
    final seq = (json['capture_sequence'] as List<dynamic>? ?? [])
        .map((e) => CaptureStep.fromJson(e as Map<String, dynamic>))
        .toList();
    final fps = (json['frame_analysis']
            as Map<String, dynamic>?)?['recommended_fps'] as int? ??
        10;
    return EnrollmentConfig(captureSequence: seq, recommendedFps: fps);
  }
}

/// A single capture step (one angle).
class CaptureStep {
  final String angle; // "center", "left", "right"
  final String instruction; // human-readable, displayed verbatim

  const CaptureStep({required this.angle, required this.instruction});

  factory CaptureStep.fromJson(Map<String, dynamic> json) => CaptureStep(
        angle: json['angle'] as String? ?? '',
        instruction: json['instruction'] as String? ?? '',
      );
}
