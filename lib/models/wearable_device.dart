class WearableDevice {
  final String id;
  final String petId;
  final String name;
  final String type; // 'Tractive GPS', 'Fi Smart Collar', 'FitBark BLE'
  final String connectionType; // 'BLE', 'Cloud'
  final int batteryLevel;
  final bool isConnected;
  final String serialNumber;

  WearableDevice({
    required this.id,
    required this.petId,
    required this.name,
    required this.type,
    required this.connectionType,
    required this.batteryLevel,
    required this.isConnected,
    required this.serialNumber,
  });

  factory WearableDevice.fromJson(Map<String, dynamic> json) {
    return WearableDevice(
      id: json['id'] as String,
      petId: json['petId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      connectionType: json['connectionType'] as String,
      batteryLevel: json['batteryLevel'] as int,
      isConnected: json['isConnected'] as bool,
      serialNumber: json['serialNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'type': type,
      'connectionType': connectionType,
      'batteryLevel': batteryLevel,
      'isConnected': isConnected,
      'serialNumber': serialNumber,
    };
  }

  WearableDevice copyWith({
    String? id,
    String? petId,
    String? name,
    String? type,
    String? connectionType,
    int? batteryLevel,
    bool? isConnected,
    String? serialNumber,
  }) {
    return WearableDevice(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      type: type ?? this.type,
      connectionType: connectionType ?? this.connectionType,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isConnected: isConnected ?? this.isConnected,
      serialNumber: serialNumber ?? this.serialNumber,
    );
  }
}

class WearableActivity {
  final String petId;
  final int steps;
  final int stepsGoal;
  final int sleepMinutes;
  final int sleepGoalMinutes;
  final int heartRateBpm;
  final DateTime lastSyncAt;

  WearableActivity({
    required this.petId,
    required this.steps,
    required this.stepsGoal,
    required this.sleepMinutes,
    required this.sleepGoalMinutes,
    required this.heartRateBpm,
    required this.lastSyncAt,
  });

  factory WearableActivity.fromJson(Map<String, dynamic> json) {
    return WearableActivity(
      petId: json['petId'] as String,
      steps: json['steps'] as int,
      stepsGoal: json['stepsGoal'] as int,
      sleepMinutes: json['sleepMinutes'] as int,
      sleepGoalMinutes: json['sleepGoalMinutes'] as int,
      heartRateBpm: json['heartRateBpm'] as int,
      lastSyncAt: DateTime.parse(json['lastSyncAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'steps': steps,
      'stepsGoal': stepsGoal,
      'sleepMinutes': sleepMinutes,
      'sleepGoalMinutes': sleepGoalMinutes,
      'heartRateBpm': heartRateBpm,
      'lastSyncAt': lastSyncAt.toIso8601String(),
    };
  }

  WearableActivity copyWith({
    String? petId,
    int? steps,
    int? stepsGoal,
    int? sleepMinutes,
    int? sleepGoalMinutes,
    int? heartRateBpm,
    DateTime? lastSyncAt,
  }) {
    return WearableActivity(
      petId: petId ?? this.petId,
      steps: steps ?? this.steps,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      sleepGoalMinutes: sleepGoalMinutes ?? this.sleepGoalMinutes,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}

class WearableLocation {
  final String petId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isSafeZone;
  final DateTime timestamp;

  WearableLocation({
    required this.petId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isSafeZone,
    required this.timestamp,
  });

  factory WearableLocation.fromJson(Map<String, dynamic> json) {
    return WearableLocation(
      petId: json['petId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      isSafeZone: json['isSafeZone'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'isSafeZone': isSafeZone,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  WearableLocation copyWith({
    String? petId,
    double? latitude,
    double? longitude,
    double? accuracy,
    bool? isSafeZone,
    DateTime? timestamp,
  }) {
    return WearableLocation(
      petId: petId ?? this.petId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      isSafeZone: isSafeZone ?? this.isSafeZone,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
