import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Prefs not initialized');
});

class ScanState {
  final String? lastCode;
  final DateTime? lastScannedAt;

  const ScanState({this.lastCode, this.lastScannedAt});
  factory ScanState.initial() => const ScanState();
}

class MobileCamerastate extends Notifier<ScanState> {
  late SharedPreferences _prefs;

  static const _keyLastCode = 'last_code';
  static const _keyLastTime = 'last_time';

  @override
  ScanState build() {
    try {
      _prefs = ref.watch(sharedPrefsProvider);
      _loadFromPrefs();
    } catch (e) {
      // SharedPreferences not initialized yet, will be set later
      print('Warning: SharedPreferences not available during build: $e');
    }
    return ScanState.initial();
  }

  void _loadFromPrefs() {
    final code = _prefs.getString(_keyLastCode);
    final timeString = _prefs.getString(_keyLastTime);
    final time = timeString != null ? DateTime.tryParse(timeString) : null;

    state = ScanState(lastCode: code, lastScannedAt: time);
  }

  Future<void> saveScan(String code) async {
    final now = DateTime.now();
    await _prefs.setString(_keyLastCode, code);
    await _prefs.setString(_keyLastTime, now.toIso8601String());

    state = ScanState(lastCode: code, lastScannedAt: now);
  }
}

final mobileCamerastateProvider =
    NotifierProvider<MobileCamerastate, ScanState>(() {
      return MobileCamerastate();
    });
