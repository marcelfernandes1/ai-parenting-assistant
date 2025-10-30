/// Photo repository for handling photo upload and management API calls.
/// Provides methods for uploading photos to S3 via backend API.
library;

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/api_config.dart';
import '../domain/photo_model.dart';

/// Repository class handling photo-related API calls.
/// Uses ApiClient for network requests with multipart/form-data support.
class PhotoRepository {
  final ApiClient _apiClient;

  /// Constructor accepts ApiClient dependency for testing and flexibility
  PhotoRepository(this._apiClient);

  /// Uploads single or multiple photos (max 3) to backend/S3.
  /// Returns list of Photo objects with presigned URLs.
  ///
  /// Parameters:
  /// - filePaths: List of local file paths to upload
  /// - onProgress: Optional callback for upload progress (0.0 to 1.0)
  ///
  /// Throws DioException on network errors.
  /// Throws Exception on validation errors or server errors.
  Future<List<Photo>> uploadPhotos(
    List<String> filePaths, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Validate file count (max 3 photos per request)
      if (filePaths.isEmpty) {
        throw Exception('No files provided for upload');
      }
      if (filePaths.length > 3) {
        throw Exception('Maximum 3 photos can be uploaded at once');
      }

      // Create multipart form data
      final formData = FormData();

      // Add each file to the form data
      for (final path in filePaths) {
        final fileName = path.split('/').last;

        // Determine media type from file extension
        MediaType? contentType;
        if (fileName.toLowerCase().endsWith('.jpg') ||
            fileName.toLowerCase().endsWith('.jpeg')) {
          contentType = MediaType('image', 'jpeg');
        } else if (fileName.toLowerCase().endsWith('.png')) {
          contentType = MediaType('image', 'png');
        } else if (fileName.toLowerCase().endsWith('.heic')) {
          contentType = MediaType('image', 'heic');
        }

        // Add file to form data with field name 'photos' (matching backend)
        formData.files.add(
          MapEntry(
            'photos',
            await MultipartFile.fromFile(
              path,
              filename: fileName,
              contentType: contentType,
            ),
          ),
        );
      }

      // Upload photos with progress tracking
      final response = await _apiClient.post(
        ApiConfig.photosUploadEndpoint,
        data: formData,
        options: Options(
          // Progress callback for upload tracking
          onSendProgress: (sent, total) {
            if (onProgress != null && total > 0) {
              final progress = sent / total;
              onProgress(progress);
            }
          },
        ),
      );

      // Check response status
      if (response.statusCode == 201) {
        // Parse photos array from response
        final photosData = response.data['photos'] as List<dynamic>;
        final photos = photosData
            .map((photoJson) => Photo.fromJson(photoJson as Map<String, dynamic>))
            .toList();

        return photos;
      }

      // Handle non-success responses
      throw Exception(response.data['error'] ?? 'Failed to upload photos');
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Fetches list of user's photos with pagination.
  ///
  /// Parameters:
  /// - limit: Number of photos per page (default: 20, max: 100)
  /// - offset: Number of photos to skip (default: 0)
  /// - milestoneId: Optional filter by milestone
  /// - albumId: Optional filter by album
  ///
  /// Returns PhotoListResponse with photos and pagination info.
  Future<PhotoListResponse> listPhotos({
    int limit = 20,
    int offset = 0,
    String? milestoneId,
    String? albumId,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (milestoneId != null) {
        queryParams['milestoneId'] = milestoneId;
      }
      if (albumId != null) {
        queryParams['albumId'] = albumId;
      }

      // Fetch photos from backend
      final response = await _apiClient.get(
        ApiConfig.photosListEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PhotoListResponse.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception(response.data['error'] ?? 'Failed to fetch photos');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Deletes a specific photo from S3 and database.
  ///
  /// Parameters:
  /// - photoId: ID of the photo to delete
  ///
  /// Throws Exception if photo not found or user doesn't have permission.
  Future<void> deletePhoto(String photoId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConfig.photosEndpoint}/$photoId',
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['error'] ?? 'Failed to delete photo');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Analyzes a photo using AI Vision API.
  /// Uploads photo to S3 first, then sends to OpenAI Vision for baby-related analysis.
  ///
  /// Parameters:
  /// - filePath: Local file path of photo to analyze
  /// - concerns: Optional user concerns to include in analysis prompt
  ///
  /// Returns PhotoAnalysisResult with analysis text and photo URL.
  Future<PhotoAnalysisResult> analyzePhoto(
    String filePath, {
    String? concerns,
  }) async {
    try {
      // Create multipart form data
      final formData = FormData();

      // Add photo file
      final fileName = filePath.split('/').last;
      MediaType? contentType;
      if (fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg')) {
        contentType = MediaType('image', 'jpeg');
      } else if (fileName.toLowerCase().endsWith('.png')) {
        contentType = MediaType('image', 'png');
      } else if (fileName.toLowerCase().endsWith('.heic')) {
        contentType = MediaType('image', 'heic');
      }

      formData.files.add(
        MapEntry(
          'photo',
          await MultipartFile.fromFile(
            filePath,
            filename: fileName,
            contentType: contentType,
          ),
        ),
      );

      // Add optional concerns
      if (concerns != null && concerns.isNotEmpty) {
        formData.fields.add(MapEntry('concerns', concerns));
      }

      // Call analyze endpoint
      final response = await _apiClient.post(
        ApiConfig.photosAnalyzeEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        return PhotoAnalysisResult.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception(response.data['error'] ?? 'Failed to analyze photo');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Converts DioException to user-friendly error message
  Exception _handleDioError(DioException error) {
    // Handle specific error codes
    if (error.response?.statusCode == 429) {
      final errorData = error.response?.data as Map<String, dynamic>?;
      if (errorData?['error'] == 'photo_limit_reached') {
        return Exception(
          'Photo limit reached. Upgrade to Premium for unlimited storage.',
        );
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection. Please try again.');
    }

    // Extract error message from response
    final response = error.response;
    if (response != null && response.data is Map) {
      final errorMessage = response.data['error'] as String?;
      if (errorMessage != null) {
        return Exception(errorMessage);
      }
    }

    // Generic error message
    return Exception('An unexpected error occurred. Please try again.');
  }
}
