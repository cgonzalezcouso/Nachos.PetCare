import 'package:flutter/foundation.dart';
import 'package:nachos_pet_care_flutter/models/reminder.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/notification_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

class ReminderProvider with ChangeNotifier {
  final DatabaseService _db = getIt<DatabaseService>();
  final NotificationService _notificationService = getIt<NotificationService>();
  
  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReminders(String userId) async {
    _setLoading(true);
    try {
      _reminders = await _db.getRemindersByUser(userId);
      _error = null;
    } catch (e, stack) {
      AppLogger.error('Error al cargar recordatorios', error: e, stackTrace: stack);
      _error = 'No se pudieron cargar los recordatorios.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      await _db.insertReminder(reminder);
      
      await _notificationService.requestPermissions();
      
      // Test inmediato con info de debug
      final localTime = DateTime.now();
      final tzName = _notificationService.getCurrentTimeZone();
      await _notificationService.showImmediateNotification(
        'Debug Zona Horaria ($tzName)',
        'L: ${localTime.hour}:${localTime.minute} | P: ${reminder.dueDate.hour}:${reminder.dueDate.minute}'
      );

      if (!reminder.completed) {
        await _notificationService.scheduleReminder(
          id: reminder.id,
          title: reminder.title,
          body: reminder.notes ?? 'Tienes un recordatorio pendiente',
          scheduledDate: reminder.dueDate,
        );
      }

      _reminders.add(reminder);
      _reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error('Error al añadir recordatorio', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _db.updateReminder(reminder);
      
      await _notificationService.cancelReminder(reminder.id);
      if (!reminder.completed) {
        await _notificationService.scheduleReminder(
          id: reminder.id,
          title: reminder.title,
          body: reminder.notes ?? 'Tienes un recordatorio pendiente',
          scheduledDate: reminder.dueDate,
        );
      }

      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = reminder;
        _reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        notifyListeners();
      }
    } catch (e, stack) {
      AppLogger.error('Error al actualizar recordatorio', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _db.deleteReminder(id);
      await _notificationService.cancelReminder(id);
      
      _reminders.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error('Error al eliminar recordatorio', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> toggleCompleted(Reminder reminder) async {
    final updated = reminder.copyWith(completed: !reminder.completed);
    await updateReminder(updated);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
