import 'package:flutter/foundation.dart';

class LogEntry {
  const LogEntry(this.time, this.message);

  final String time;
  final String message;
}

class LogService {
  static const _maxEntries = 100;

  /// Kept in memory only, so each launch starts empty.
  static final ValueNotifier<List<LogEntry>> entries = ValueNotifier(const []);

  /// Write to the on-screen log view and the console.
  static void log(String message) {
    debugPrint('[OneSignal] $message');
    final next = [
      ...entries.value,
      LogEntry(_formatTime(DateTime.now()), message),
    ];
    entries.value =
        next.length > _maxEntries
            ? next.sublist(next.length - _maxEntries)
            : next;
  }

  static void clear() => entries.value = const [];

  static String _formatTime(DateTime date) => [
    date.hour,
    date.minute,
    date.second,
  ].map((part) => part.toString().padLeft(2, '0')).join(':');

  LogService._();
}
