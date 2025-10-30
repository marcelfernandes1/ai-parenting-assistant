/// Custom exception thrown when user reaches FREE tier daily limits.
/// Contains reset time information for displaying countdown to user.
library;

/// Exception thrown when daily usage limit is reached
/// Includes reset time to show user when limits will reset
class LimitReachedException implements Exception {
  final String message;
  final DateTime? resetTime;
  final int remaining;

  LimitReachedException({
    required this.message,
    this.resetTime,
    this.remaining = 0,
  });

  @override
  String toString() => message;

  /// Creates LimitReachedException from API response data
  factory LimitReachedException.fromResponse(Map<String, dynamic> data) {
    DateTime? resetTime;
    if (data['resetTime'] != null) {
      try {
        resetTime = DateTime.parse(data['resetTime'] as String);
      } catch (e) {
        // If parsing fails, leave resetTime as null
      }
    }

    return LimitReachedException(
      message: data['message'] as String? ?? 'Daily limit reached',
      resetTime: resetTime,
      remaining: data['remaining'] as int? ?? 0,
    );
  }

  /// Gets a formatted time remaining until reset
  String get timeUntilReset {
    if (resetTime == null) return 'midnight UTC';

    final now = DateTime.now();
    final duration = resetTime!.difference(now);

    if (duration.isNegative) return 'soon';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return 'less than a minute';
    }
  }
}
