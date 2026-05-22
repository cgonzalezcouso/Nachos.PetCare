import 'dart:async';
import 'dart:math';
import 'package:nachos_pet_care_flutter/models/wearable_device.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

class WearableService {
  final _random = Random();
  Timer? _telemetryTimer;

  // Controllers reactivos
  final StreamController<WearableDevice?> _deviceController = StreamController<WearableDevice?>.broadcast();
  final StreamController<WearableActivity?> _activityController = StreamController<WearableActivity?>.broadcast();
  final StreamController<WearableLocation?> _locationController = StreamController<WearableLocation?>.broadcast();

  // Estados locales en caché
  WearableDevice? _currentDevice;
  WearableActivity? _currentActivity;
  WearableLocation? _currentLocation;

  // Getters de estado actual
  WearableDevice? get currentDevice => _currentDevice;
  WearableActivity? get currentActivity => _currentActivity;
  WearableLocation? get currentLocation => _currentLocation;

  // Streams públicos
  Stream<WearableDevice?> get deviceStream => _deviceController.stream;
  Stream<WearableActivity?> get activityStream => _activityController.stream;
  Stream<WearableLocation?> get locationStream => _locationController.stream;

  WearableService() {
    AppLogger.info('Servicio WearableService inicializado.');
  }

  /// Escanea dispositivos Bluetooth BLE cercanos
  Future<List<Map<String, dynamic>>> scanBleDevices() async {
    AppLogger.info('Iniciando escaneo Bluetooth BLE...');
    await Future.delayed(const Duration(seconds: 2)); // Simula tiempo de escaneo

    return [
      {
        'name': 'Tractive GPS Tracker #849',
        'type': 'Tractive GPS',
        'serial': 'TRAC-849-BLE',
        'signal': -65,
      },
      {
        'name': 'Fi Smart Collar #201',
        'type': 'Fi Smart Collar',
        'serial': 'FI-201-COLLAR',
        'signal': -72,
      },
      {
        'name': 'FitBark Activity Tag #405',
        'type': 'FitBark BLE',
        'serial': 'FITB-405-BLE',
        'signal': -88,
      },
    ];
  }

  /// Conecta a un dispositivo por Bluetooth BLE
  Future<void> connectBleDevice(String name, String petId, String type, String serial) async {
    AppLogger.info('Conectando vía BLE a $name...');
    await Future.delayed(const Duration(seconds: 1)); // Handshake inicial

    final newDevice = WearableDevice(
      id: 'ble_dev_${_random.nextInt(100000)}',
      petId: petId,
      name: name,
      type: type,
      connectionType: 'BLE',
      batteryLevel: 98,
      isConnected: true,
      serialNumber: serial,
    );

    _updateDeviceState(newDevice);
    _initializeTelemetry(petId);
  }

  /// Conecta e integra cuentas Cloud API (Tractive / Fi Collar)
  Future<bool> connectCloudAccount({
    required String provider,
    required String email,
    required String password,
    required String petId,
  }) async {
    AppLogger.info('Autenticando en nube de $provider para $email...');
    await Future.delayed(const Duration(seconds: 2)); // Simula OAuth + token exchange

    if (email.contains('@') && password.length >= 4) {
      final trackerName = provider == 'Tractive'
          ? 'Tractive GPS Cloud Link'
          : 'Fi Smart Collar Cloud API';

      final serialNumber = provider == 'Tractive' ? 'TRAC-CLOUD-771' : 'FI-CLOUD-330';

      final newDevice = WearableDevice(
        id: 'cloud_dev_${_random.nextInt(100000)}',
        petId: petId,
        name: trackerName,
        type: provider,
        connectionType: 'Cloud (HTTP REST)',
        batteryLevel: 87,
        isConnected: true,
        serialNumber: serialNumber,
      );

      _updateDeviceState(newDevice);
      _initializeTelemetry(petId);
      return true;
    }

    AppLogger.error('Credenciales incorrectas en la API de Wearables');
    return false;
  }

  /// Desconecta el dispositivo actual y limpia telemetría
  Future<void> disconnectDevice() async {
    AppLogger.info('Desconectando dispositivo wearable...');
    _telemetryTimer?.cancel();
    _telemetryTimer = null;

    _currentDevice = null;
    _currentActivity = null;
    _currentLocation = null;

    _deviceController.add(null);
    _activityController.add(null);
    _locationController.add(null);
  }

  void _updateDeviceState(WearableDevice device) {
    _currentDevice = device;
    _deviceController.add(device);
  }

  /// Inicializa la telemetría periódica simulando mediciones en tiempo real
  void _initializeTelemetry(String petId) {
    _telemetryTimer?.cancel();

    // Valores iniciales
    _currentActivity = WearableActivity(
      petId: petId,
      steps: 4210,
      stepsGoal: 10000,
      sleepMinutes: 380,
      sleepGoalMinutes: 600,
      heartRateBpm: 84,
      lastSyncAt: DateTime.now(),
    );

    // Coordenadas base (cerca de la clínica o casa)
    _currentLocation = WearableLocation(
      petId: petId,
      latitude: 41.3851, // Barcelona centro
      longitude: 2.1734,
      accuracy: 4.5,
      isSafeZone: true,
      timestamp: DateTime.now(),
    );

    _activityController.add(_currentActivity);
    _locationController.add(_currentLocation);

    int ticks = 0;
    _telemetryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentActivity == null || _currentLocation == null) return;
      ticks++;

      // 1. Simulación de pasos y sueño
      final addedSteps = _random.nextInt(3); // añade de 0 a 2 pasos cada segundo
      final newSteps = min(_currentActivity!.steps + addedSteps, _currentActivity!.stepsGoal * 2);

      // Simular variabilidad realista de pulso cardíaco
      // Ritmo sinusal normal de un perro es de 70-120 bpm, gato 120-140 bpm
      final heartDelta = _random.nextInt(7) - 3; // oscila entre -3 y +3
      final newHr = max(68, min(130, _currentActivity!.heartRateBpm + heartDelta));

      _currentActivity = _currentActivity!.copyWith(
        steps: newSteps,
        heartRateBpm: newHr,
        lastSyncAt: DateTime.now(),
      );
      _activityController.add(_currentActivity);

      // 2. Simulación de GPS y Geovallas (Geofencing)
      // Cada 12 segundos el perro sale temporalmente de la geovalla para disparar alerta en la UI, luego regresa
      final bool safe = (ticks % 15) < 10;
      final double latShift = safe ? (_random.nextDouble() - 0.5) * 0.0003 : 0.0025; // Salto grande fuera de la valla
      final double lngShift = safe ? (_random.nextDouble() - 0.5) * 0.0003 : 0.0025;

      _currentLocation = _currentLocation!.copyWith(
        latitude: 41.3851 + latShift,
        longitude: 2.1734 + lngShift,
        isSafeZone: safe,
        timestamp: DateTime.now(),
      );
      _locationController.add(_currentLocation);

      // Simular cambio ocasional de batería
      if (ticks % 60 == 0 && _currentDevice != null) {
        final currentBat = _currentDevice!.batteryLevel;
        final newBat = max(10, currentBat - 1);
        _updateDeviceState(_currentDevice!.copyWith(batteryLevel: newBat));
      }
    });
  }

  void dispose() {
    _telemetryTimer?.cancel();
    _deviceController.close();
    _activityController.close();
    _locationController.close();
  }
}
