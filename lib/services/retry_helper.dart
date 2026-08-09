import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/ai_exceptions.dart';

/// Helper utility implementing Exponential Backoff for resilient AI calls.
///
/// Error Handling & Resilience
class RetryHelper {
  /// Executes an asynchronous [action] with automatic exponential backoff retries.
  ///
  /// - [maxAttempts]: Maximum number of total attempts (default 3).
  /// - [initialDelay]: Initial delay before the first retry (default 1 second).
  /// - [onRetry]: Optional callback invoked on each retry attempt with attempt count & delay.
  static Future<T> retryWithBackoff<T>({
    required Future<T> Function() action,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    void Function(int attempt, Duration delay, Exception error)? onRetry,
  }) async {
    int attempt = 0;

    while (true) {
      attempt++;
      try {
        return await action();
      } on AIException catch (e) {
        // If exception marked non-retryable (e.g., Invalid API Key or Safety refusal), fail immediately
        if (!e.canRetry || attempt >= maxAttempts) {
          rethrow;
        }

        // Compute exponential delay: initialDelay * 2^(attempt - 1)
        final backoffFactor = math.pow(2, attempt - 1);
        final delayMs = (initialDelay.inMilliseconds * backoffFactor).round();
        final delay = Duration(milliseconds: delayMs);

        debugPrint('[RetryHelper] Attempt $attempt failed (${e.runtimeType}). Retrying in ${delay.inSeconds}s...');
        onRetry?.call(attempt, delay, e);

        await Future.delayed(delay);
      } catch (e) {
        if (attempt >= maxAttempts) {
          throw UnknownAIException('Failed after $maxAttempts attempts: $e');
        }

        final delay = initialDelay * math.pow(2, attempt - 1).toInt();
        debugPrint('[RetryHelper] Attempt $attempt failed ($e). Retrying in ${delay.inSeconds}s...');
        onRetry?.call(attempt, delay, Exception(e.toString()));

        await Future.delayed(delay);
      }
    }
  }
}
