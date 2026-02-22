abstract class AppException implements Exception {
  final String message;
  
  AppException([this.message = 'An unexpected error occurred']);
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'Network connection error']) : super(message);
}

class ServerException extends AppException {
  final int? statusCode;
  
  ServerException([String message = 'Server error occurred', this.statusCode]) 
      : super(message);
}

class CacheException extends AppException {
  CacheException([String message = 'Cache error occurred']) : super(message);
}

class AuthException extends AppException {
  AuthException([String message = 'Authentication error occurred']) : super(message);
}
