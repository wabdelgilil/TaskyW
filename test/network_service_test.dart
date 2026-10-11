import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/services/network_service.dart';

void main() {
  group('NetworkService.isNetworkError', () {
    test('يكتشف استثناءات مقابس الشبكة والمهلة الزمنية', () {
      expect(NetworkService.isNetworkError(const SocketException('Failed host lookup')), isTrue);
      expect(NetworkService.isNetworkError(TimeoutException('Request timed out')), isTrue);
      expect(NetworkService.isNetworkError(const HttpException('Connection reset by peer')), isTrue);
    });

    test('يكتشف أخطاء المتصفح والـ Web fetch و DNS', () {
      expect(
        NetworkService.isNetworkError(
          Exception('AuthRetryableFetchException(message: ClientException: Failed to fetch, uri=https://supabase.co)'),
        ),
        isTrue,
      );
      expect(
        NetworkService.isNetworkError(
          Exception('Failed to load resource: net::ERR_NAME_NOT_RESOLVED'),
        ),
        isTrue,
      );
      expect(
        NetworkService.isNetworkError(
          Exception('Failed to load resource: net::ERR_PROXY_CONNECTION_FAILED'),
        ),
        isTrue,
      );
      expect(
        NetworkService.isNetworkError(
          Exception('ClientException: XMLHttpRequest error'),
        ),
        isTrue,
      );
    });

    test('يتجاهل الأخطاء المنطقية أو أخطاء التحقق غير المرتبطة بالشبكة', () {
      expect(NetworkService.isNetworkError(FormatException('Invalid JSON')), isFalse);
      expect(NetworkService.isNetworkError(ArgumentError('Missing required field')), isFalse);
      expect(NetworkService.isNetworkError(Exception('Database constraint failed')), isFalse);
    });
  });
}
