import 'package:flutter/material.dart';
import 'package:j_cash/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get reminders => _reminders;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationService.initialize();
      await _fetchReminders();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchReminders() async {
    try {
      // TODO: Implement fetching reminders from Firestore
      // For now, we'll use an empty list
      _reminders = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching reminders: $e');
    }
  }

  Future<void> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      await _notificationService.scheduleNotification(
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        payload: payload,
      );
      await _fetchReminders();
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
      rethrow;
    }
  }

  Future<void> scheduleRecurringReminder({
    required String title,
    required String body,
    required DateTime startTime,
    required Duration interval,
    String? payload,
  }) async {
    try {
      await _notificationService.scheduleRecurringNotification(
        title: title,
        body: body,
        dateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      await _fetchReminders();
    } catch (e) {
      debugPrint('Error scheduling recurring reminder: $e');
      rethrow;
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _notificationService.cancelNotification(id);
      await _fetchReminders();
    } catch (e) {
      debugPrint('Error canceling reminder: $e');
      rethrow;
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await _notificationService.cancelAllNotifications();
      await _fetchReminders();
    } catch (e) {
      debugPrint('Error canceling all reminders: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getRemindersStream() {
    // TODO: Implement streaming reminders from Firestore
    // For now, return an empty stream
    return Stream.value([]);
  }
}
