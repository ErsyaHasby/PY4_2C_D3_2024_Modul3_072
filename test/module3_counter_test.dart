import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app/features/logbook/counter_controller.dart';

void main() {
  group('Module 3 - Save Data to Disk (CounterController)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('TC-M3-01: save and load counter value for admin', () async {
      final controller = CounterController();
      controller.setCurrentUser('admin');
      controller.setStep(2);
      controller.increment();

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final loaded = CounterController();
      await loaded.loadLastValue('admin');

      expect(loaded.value, 2);
    });

    test('TC-M3-02: save and load history for admin', () async {
      final controller = CounterController();
      controller.setCurrentUser('admin');
      controller.increment();
      controller.decrement();

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final loaded = CounterController();
      await loaded.loadHistory('admin');

      expect(loaded.history.length, 2);
      expect(loaded.history[0].type, 'add');
      expect(loaded.history[1].type, 'subtract');
    });

    test('TC-M3-03: load default counter when no saved data', () async {
      final controller = CounterController();

      await controller.loadLastValue('guest');

      expect(controller.value, 0);
    });

    test('TC-M3-04: load empty history when no saved data', () async {
      final controller = CounterController();

      await controller.loadHistory('guest');

      expect(controller.history, isEmpty);
    });

    test('TC-M3-05: counter data is isolated per user', () async {
      final admin = CounterController();
      admin.setCurrentUser('admin');
      admin.setStep(3);
      admin.increment();

      final user = CounterController();
      user.setCurrentUser('user');
      user.increment();

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final loadedAdmin = CounterController();
      final loadedUser = CounterController();
      await loadedAdmin.loadLastValue('admin');
      await loadedUser.loadLastValue('user');

      expect(loadedAdmin.value, 3);
      expect(loadedUser.value, 1);
    });

    test(
      'TC-M3-06: clear all data removes saved counter and history',
      () async {
        final controller = CounterController();
        controller.setCurrentUser('admin');
        controller.increment();
        controller.increment();

        await Future<void>.delayed(const Duration(milliseconds: 10));
        await controller.clearAllData('admin');

        final loaded = CounterController();
        await loaded.loadAllData('admin');

        expect(loaded.value, 0);
        expect(loaded.history, isEmpty);
      },
    );
  });
}
