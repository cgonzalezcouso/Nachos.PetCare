import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nachos_pet_care_flutter/models/vet_invitation.dart';

class VetClinicService {
  static const String _saasKey = 'b2b_clinic_saas_active';
  static const String _invitationsKey = 'b2b_clinic_invitations_v1';
  static const String _apiKeysKey = 'b2b_clinic_api_keys_v1';
  static const String _apiCounterKey = 'b2b_clinic_api_counter';

  final List<VetInvitation> _invitations = [];
  final List<Map<String, dynamic>> _apiKeys = [];
  int _apiCallsCount = 0;

  final StreamController<List<VetInvitation>> _invitationsController = StreamController<List<VetInvitation>>.broadcast();
  final StreamController<bool> _saasController = StreamController<bool>.broadcast();
  final StreamController<int> _apiCounterController = StreamController<int>.broadcast();

  Stream<List<VetInvitation>> get invitationsStream => _invitationsController.stream;
  Stream<bool> get saasStream => _saasController.stream;
  Stream<int> get apiCounterStream => _apiCounterController.stream;

  VetClinicService() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Cargar estado SaaS
      final saasActive = prefs.getBool(_saasKey) ?? false;
      _saasController.add(saasActive);

      // 2. Cargar Contador API
      _apiCallsCount = prefs.getInt(_apiCounterKey) ?? 482; // Valor inicial premium para simular actividad
      _apiCounterController.add(_apiCallsCount);

      // 3. Cargar Invitaciones
      final invitationsStr = prefs.getString(_invitationsKey);
      if (invitationsStr != null) {
        final List<dynamic> decoded = json.decode(invitationsStr);
        _invitations.clear();
        _invitations.addAll(decoded.map((item) => VetInvitation.fromJson(item as Map<String, dynamic>)));
      } else {
        _initMockInvitations();
      }

      // 4. Cargar API Keys
      final apiKeysStr = prefs.getString(_apiKeysKey);
      if (apiKeysStr != null) {
        final List<dynamic> decoded = json.decode(apiKeysStr);
        _apiKeys.clear();
        _apiKeys.addAll(decoded.cast<Map<String, dynamic>>());
      } else {
        _initMockApiKeys();
      }

      _notifyInvitationsChanged();
    } catch (_) {
      _initMockInvitations();
      _initMockApiKeys();
    }
  }

  void _initMockInvitations() {
    final now = DateTime.now();
    _invitations.addAll([
      VetInvitation(
        id: 'inv_mock_1',
        petId: 'pet_nachito',
        petName: 'Nachito',
        petPhoto: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=250',
        ownerName: 'Juan Pérez',
        vetEmail: 'vet-juan@nachos.com',
        clinicName: 'Clínica Veterinaria Nachos',
        status: 'accepted',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      VetInvitation(
        id: 'inv_mock_2',
        petId: 'pet_kira',
        petName: 'Kira',
        petPhoto: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=250',
        ownerName: 'María Gómez',
        vetEmail: 'vet-juan@nachos.com',
        clinicName: 'Clínica Veterinaria Nachos',
        status: 'pending',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      VetInvitation(
        id: 'inv_mock_3',
        petId: 'pet_copito',
        petName: 'Copito',
        petPhoto: 'https://images.unsplash.com/photo-1537151608828-ea2b117b6281?w=250',
        ownerName: 'Carlos Ruiz',
        vetEmail: 'vet-juan@nachos.com',
        clinicName: 'Clínica Veterinaria Nachos',
        status: 'accepted',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);
    _saveInvitations();
  }

  void _initMockApiKeys() {
    _apiKeys.addAll([
      {
        'clientId': 'cli_nachos_a8b9c10d',
        'clientSecret': 'sec_nachos_91823719283719283712',
        'name': 'Integración ERP Clínica',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'isActive': true,
      }
    ]);
    _saveApiKeys();
  }

  Future<void> _saveInvitations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = json.encode(_invitations.map((i) => i.toJson()).toList());
      await prefs.setString(_invitationsKey, jsonStr);
    } catch (_) {}
  }

  Future<void> _saveApiKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = json.encode(_apiKeys);
      await prefs.setString(_apiKeysKey, jsonStr);
    } catch (_) {}
  }

  void _notifyInvitationsChanged() {
    _invitationsController.add(List.unmodifiable(_invitations));
  }

  // ── Gestión SaaS ──────────────────────────────────────────────────────────
  Future<bool> isSaaSActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_saasKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setSaaSActive(bool active) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_saasKey, active);
      _saasController.add(active);
    } catch (_) {}
  }

  // ── Gestión de Invitaciones (Desde Propietario) ───────────────────────────
  Future<void> sendInvitation({
    required String petId,
    required String petName,
    String? petPhoto,
    required String ownerName,
    required String vetEmail,
    required String clinicName,
  }) async {
    final newInv = VetInvitation(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      petId: petId,
      petName: petName,
      petPhoto: petPhoto,
      ownerName: ownerName,
      vetEmail: vetEmail,
      clinicName: clinicName,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    // Evitar duplicados pendientes
    _invitations.removeWhere((i) => i.petId == petId && i.vetEmail == vetEmail && i.status == 'pending');
    
    _invitations.add(newInv);
    await _saveInvitations();
    _notifyInvitationsChanged();
  }

  Future<void> revokeInvitation(String id) async {
    _invitations.removeWhere((i) => i.id == id);
    await _saveInvitations();
    _notifyInvitationsChanged();
  }

  // ── Gestión de Invitaciones (Desde Veterinario) ───────────────────────────
  Future<List<VetInvitation>> getInvitations() async {
    return List.unmodifiable(_invitations);
  }

  Future<void> updateInvitationStatus(String id, String status) async {
    final idx = _invitations.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _invitations[idx] = _invitations[idx].copyWith(status: status);
      await _saveInvitations();
      _notifyInvitationsChanged();
    }
  }

  // ── Gestión de API Keys ───────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getApiKeys() async {
    return List.unmodifiable(_apiKeys);
  }

  Future<Map<String, dynamic>> generateApiKey(String name) async {
    final clientId = 'cli_nachos_${_generateRandomString(8)}';
    final clientSecret = 'sec_nachos_${_generateRandomString(24)}';
    
    final newKey = {
      'clientId': clientId,
      'clientSecret': clientSecret,
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
    };

    _apiKeys.add(newKey);
    await _saveApiKeys();
    return newKey;
  }

  Future<void> toggleApiKey(String clientId, bool active) async {
    final idx = _apiKeys.indexWhere((k) => k['clientId'] == clientId);
    if (idx != -1) {
      _apiKeys[idx]['isActive'] = active;
      await _saveApiKeys();
    }
  }

  Future<void> deleteApiKey(String clientId) async {
    _apiKeys.removeWhere((k) => k['clientId'] == clientId);
    await _saveApiKeys();
  }

  String _generateRandomString(int len) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random();
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  // ── API REST Pública Simulación ──────────────────────────────────────────
  Future<void> _incrementApiCounter() async {
    _apiCallsCount++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_apiCounterKey, _apiCallsCount);
    } catch (_) {}
    _apiCounterController.add(_apiCallsCount);
  }

  Future<Map<String, dynamic>> simulateApiRequest({
    required String clientId,
    required String clientSecret,
    required String endpoint,
    Map<String, String>? queryParams,
  }) async {
    await _incrementApiCounter();
    
    // Simular latencia de red real de 400ms
    await Future.delayed(const Duration(milliseconds: 400));

    // 1. Validar Credenciales
    final key = _apiKeys.firstWhere(
      (k) => k['clientId'] == clientId && k['clientSecret'] == clientSecret,
      orElse: () => {},
    );

    if (key.isEmpty) {
      return {
        'status': 401,
        'body': {
          'error': 'Unauthorized',
          'message': 'Las credenciales Client ID o Client Secret suministradas son inválidas o están desactivadas.',
          'timestamp': DateTime.now().toIso8601String(),
        }
      };
    }

    if (key['isActive'] == false) {
      return {
        'status': 403,
        'body': {
          'error': 'Forbidden',
          'message': 'Esta clave de API ha sido desactivada por el administrador de la clínica.',
          'timestamp': DateTime.now().toIso8601String(),
        }
      };
    }

    // 2. Resolver Endpoints
    if (endpoint == '/api/v1/patients') {
      final acceptedPets = _invitations
          .where((i) => i.status == 'accepted')
          .map((i) => {
                'id': i.petId,
                'name': i.petName,
                'photo_url': i.petPhoto,
                'owner': i.ownerName,
                'clinic': i.clinicName,
                'linked_at': i.createdAt.toIso8601String(),
              })
          .toList();

      return {
        'status': 200,
        'body': {
          'success': true,
          'count': acceptedPets.length,
          'results': acceptedPets,
          'meta': {
            'page': 1,
            'limit': 50,
            'api_version': 'v3.0.0',
            'server_time': DateTime.now().toIso8601String(),
          }
        }
      };
    } else if (endpoint.startsWith('/api/v1/patients/') && endpoint.endsWith('/medical-records')) {
      // Extraer el petId
      final parts = endpoint.split('/');
      final petId = parts.length > 4 ? parts[4] : 'unknown';
      
      VetInvitation? matchingInv;
      try {
        matchingInv = _invitations.firstWhere((i) => i.petId == petId && i.status == 'accepted');
      } catch (_) {
        matchingInv = null;
      }

      if (matchingInv == null) {
        return {
          'status': 404,
          'body': {
            'error': 'Not Found',
            'message': 'No se encontró ningún paciente activo con el identificador suministrado ($petId) en esta clínica.',
            'timestamp': DateTime.now().toIso8601String(),
          }
        };
      }

      // Devolver historial clínico ficticio premium del paciente solicitado
      final reports = [
        {
          'id': 'rec_sim_1',
          'visit_date': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
          'vet_name': 'Dr. Alejandro Méndez',
          'diagnosis': 'Control de rutina y vacunación anual.',
          'treatment': 'Administración de vacuna trivalente felina / antirrábica canina.',
          'notes': 'El paciente se encuentra en excelente peso corporal y condición de pelaje. Temperatura corporal normal.',
        },
        {
          'id': 'rec_sim_2',
          'visit_date': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
          'vet_name': 'Dra. Sofía Rivas',
          'diagnosis': 'Leve gastroenteritis dietaria.',
          'treatment': 'Dieta blanda durante 3 días. Suplemento probiótico oral.',
          'notes': 'Recuperación favorable. Se recomienda evitar cambios abruptos en la marca de pienso.',
        }
      ];

      return {
        'status': 200,
        'body': {
          'success': true,
          'pet_id': petId,
          'pet_name': matchingInv.petName,
          'owner': matchingInv.ownerName,
          'reports': reports,
          'meta': {
            'api_version': 'v3.0.0',
            'server_time': DateTime.now().toIso8601String(),
          }
        }
      };
    }

    // Endpoint Desconocido
    return {
      'status': 404,
      'body': {
        'error': 'Not Found',
        'message': 'El endpoint solicitado no está implementado o no existe en la especificación API v3.0.',
        'timestamp': DateTime.now().toIso8601String(),
      }
    };
  }
}
