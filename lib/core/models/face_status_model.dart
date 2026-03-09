/// Maps the GET /students/face/status response.
class FaceStatusModel {
  final bool hasFaceImage;
  final bool isVerified;
  final int imageCount;
  final List<String> angles;

  const FaceStatusModel({
    required this.hasFaceImage,
    required this.isVerified,
    required this.imageCount,
    required this.angles,
  });

  factory FaceStatusModel.fromJson(Map<String, dynamic> json) =>
      FaceStatusModel(
        hasFaceImage: json['has_face_image'] as bool? ?? false,
        isVerified: json['is_verified'] as bool? ?? false,
        imageCount: (json['image_count'] as num?)?.toInt() ?? 0,
        angles: (json['angles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  /// True when all 3 required angles have been uploaded.
  bool get isFullyEnrolled => imageCount >= 3;
}
