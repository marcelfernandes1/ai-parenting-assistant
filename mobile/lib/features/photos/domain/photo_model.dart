/// Photo domain models with Freezed for immutability and JSON serialization.
/// Represents photo data from backend API responses.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

// Generated file imports (will be created by build_runner)
part 'photo_model.freezed.dart';
part 'photo_model.g.dart';

/// Immutable photo data model using Freezed.
/// Represents a single photo with metadata and presigned URL.
@freezed
class Photo with _$Photo {
  const factory Photo({
    /// Unique photo identifier from database
    required String id,

    /// Presigned S3 URL for accessing the photo (24-hour expiry)
    required String url,

    /// S3 key/path for the photo (server-side reference)
    required String s3Key,

    /// Upload timestamp
    required DateTime uploadedAt,

    /// Optional metadata (original filename, mime type, size)
    Map<String, dynamic>? metadata,

    /// Optional milestone ID if photo is linked to a milestone
    String? milestoneId,

    /// Optional album ID if photo is part of an album
    String? albumId,

    /// Optional AI analysis results from Vision API
    Map<String, dynamic>? analysisResults,
  }) = _Photo;

  /// Factory constructor for creating Photo from JSON
  /// Used when deserializing API responses
  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}

/// Response model for photo list endpoint with pagination.
@freezed
class PhotoListResponse with _$PhotoListResponse {
  const factory PhotoListResponse({
    /// List of photos in current page
    required List<Photo> photos,

    /// Pagination metadata
    required PaginationInfo pagination,
  }) = _PhotoListResponse;

  /// Factory constructor for creating PhotoListResponse from JSON
  factory PhotoListResponse.fromJson(Map<String, dynamic> json) =>
      _$PhotoListResponseFromJson(json);
}

/// Pagination information for photo list responses.
@freezed
class PaginationInfo with _$PaginationInfo {
  const factory PaginationInfo({
    /// Number of items per page
    required int limit,

    /// Number of items skipped
    required int offset,

    /// Total number of items available
    required int total,

    /// Whether there are more pages available
    required bool hasMore,
  }) = _PaginationInfo;

  /// Factory constructor for creating PaginationInfo from JSON
  factory PaginationInfo.fromJson(Map<String, dynamic> json) =>
      _$PaginationInfoFromJson(json);
}

/// Result of AI Vision analysis for a photo.
@freezed
class PhotoAnalysisResult with _$PhotoAnalysisResult {
  const factory PhotoAnalysisResult({
    /// Unique photo identifier
    required String photoId,

    /// Presigned URL for the analyzed photo
    required String photoUrl,

    /// AI-generated analysis text
    required String analysis,

    /// Medical disclaimer text
    required String disclaimer,

    /// Timestamp of upload
    required DateTime uploadedAt,
  }) = _PhotoAnalysisResult;

  /// Factory constructor for creating PhotoAnalysisResult from JSON
  factory PhotoAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$PhotoAnalysisResultFromJson(json);
}
