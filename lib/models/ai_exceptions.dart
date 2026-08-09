/// Base Exception class for AI Engineering in Flutter.
abstract class AIException implements Exception {
  final String message;
  final int? statusCode;
  final bool canRetry;

  const AIException({
    required this.message,
    this.statusCode,
    this.canRetry = true,
  });

  @override
  String toString() =>
      '$runtimeType: $message${statusCode != null ? ' (Code $statusCode)' : ''}';
}

/// Thrown when there is no network connection or a socket/timeout error occurs.
class NetworkAIException extends AIException {
  const NetworkAIException(String message)
    : super(message: message, canRetry: true);
}

/// Thrown when Gemini API rate limits are reached (HTTP 429).
class RateLimitAIException extends AIException {
  final Duration? retryAfter;

  const RateLimitAIException(String message, {this.retryAfter})
    : super(message: message, statusCode: 429, canRetry: true);
}

/// Thrown when Structured Output fails to deserialize into the Dart model.
class SchemaParsingAIException extends AIException {
  final String rawOutput;

  const SchemaParsingAIException(String message, {required this.rawOutput})
    : super(message: message, canRetry: true);
}

/// Thrown when the model refuses a prompt due to safety/policy filters.
class SafetyRefusalAIException extends AIException {
  const SafetyRefusalAIException(String message)
    : super(message: message, canRetry: false);
}

/// Thrown when the API key is missing or invalid.
class InvalidApiKeyAIException extends AIException {
  const InvalidApiKeyAIException(String message)
    : super(message: message, statusCode: 401, canRetry: false);
}

/// Unknown fallback exception.
class UnknownAIException extends AIException {
  const UnknownAIException(String message)
    : super(message: message, canRetry: true);
}
