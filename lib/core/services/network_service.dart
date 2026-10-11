import 'dart:async';
import 'dart:io' show HttpException, InternetAddress, SocketException, TlsException, HandshakeException;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// خدمة فحص ومراقبة الاتصال بالإنترنت بشكل لحظي ومتوافق عبر كافة المنصات
class NetworkService {
  static final NetworkService instance = NetworkService._internal();
  NetworkService._internal();

  Timer? _monitorTimer;

  /// التحقق من توفر اتصال فعلي بالإنترنت
  Future<bool> hasInternetConnection() async {
    if (kIsWeb) {
      try {
        // في بيئة الويب نستخدم استعلام DNS عام يدعم CORS لتفادي حظر المتصفح
        final response = await http
            .get(Uri.parse('https://dns.google/resolve?name=example.com'))
            .timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) return true;
      } catch (_) {}

      try {
        // محاولة عنوان احتياطي بديل يدعم CORS أيضاً (Cloudflare DoH)
        final fallback = await http
            .get(
              Uri.parse('https://cloudflare-dns.com/dns-query?name=example.com&type=A'),
              headers: {'accept': 'application/dns-json'},
            )
            .timeout(const Duration(seconds: 3));
        if (fallback.statusCode == 200) return true;
      } catch (_) {}

      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      // محاولة عنوان بديل احتياطي (Cloudflare DNS)
      try {
        final fallback = await InternetAddress.lookup('1.1.1.1')
            .timeout(const Duration(seconds: 2));
        if (fallback.isNotEmpty && fallback[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// التحقق مما إذا كان الخطأ البرمجي ناتجاً عن فقدان الاتصال بالإنترنت أو تعذر الوصول للخادم
  static bool isNetworkError(Object error) {
    if (!kIsWeb) {
      if (error is SocketException ||
          error is HttpException ||
          error is HandshakeException ||
          error is TlsException ||
          error is TimeoutException) {
        return true;
      }
    }
    final msg = error.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('failed host lookup') ||
        msg.contains('network is unreachable') ||
        msg.contains('connection closed') ||
        msg.contains('connection refused') ||
        msg.contains('connection timed out') ||
        msg.contains('connection reset') ||
        msg.contains('handshakeexception') ||
        msg.contains('timeoutexception') ||
        msg.contains('clientexception') ||
        msg.contains('software caused connection abort') ||
        msg.contains('no route to host') ||
        msg.contains('offline') ||
        msg.contains('failed to connect') ||
        msg.contains('failed to fetch') ||
        msg.contains('authretryablefetchexception') ||
        msg.contains('err_name_not_resolved') ||
        msg.contains('err_proxy_connection_failed') ||
        msg.contains('err_internet_disconnected') ||
        msg.contains('err_network_changed') ||
        msg.contains('err_connection_timed_out') ||
        msg.contains('err_connection_refused') ||
        msg.contains('xmlhttprequest') ||
        msg.contains('networkerror') ||
        msg.contains('load failed');
  }

  /// بدء مراقبة الاتصال عند فقدانه لاستئناف المزامنة فور عودته تلقائياً
  void startMonitoring({required VoidCallback onRestored}) {
    stopMonitoring();
    _monitorTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final isOnline = await hasInternetConnection();
      if (isOnline) {
        stopMonitoring();
        onRestored();
      }
    });
  }

  /// إيقاف المراقبة الدورية
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }
}
