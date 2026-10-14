import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/services/wearable_service.dart';
import 'package:nachos_pet_care_flutter/models/wearable_device.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
import 'package:nachos_pet_care_flutter/l10n/app_strings.dart';

class WearablesScreen extends StatefulWidget {
  const WearablesScreen({super.key});

  @override
  State<WearablesScreen> createState() => _WearablesScreenState();
}

class _WearablesScreenState extends State<WearablesScreen> with SingleTickerProviderStateMixin {
  final WearableService _wearableService = getIt<WearableService>();
  
  // Animación del radar BLE
  late AnimationController _radarController;
  bool _isScanning = false;
  List<Map<String, dynamic>> _scannedDevices = [];
  bool _scanningLoading = false;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _scanningLoading = true;
      _scannedDevices = [];
    });
    _radarController.repeat();

    final devices = await _wearableService.scanBleDevices();

    if (mounted) {
      setState(() {
        _scannedDevices = devices;
        _scanningLoading = false;
      });
    }
  }

  void _stopScan() {
    _radarController.stop();
    setState(() {
      _isScanning = false;
      _scanningLoading = false;
    });
  }

  void _connectBle(Map<String, dynamic> dev, String petId) async {
    _stopScan();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Emparejando collar vía BLE...'),
          ],
        ),
      ),
    );

    await _wearableService.connectBleDevice(
      dev['name'],
      petId,
      dev['type'],
      dev['serial'],
    );

    if (mounted) {
      Navigator.pop(context); // cerrar diálogo de emparejando
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collar ${dev['name']} emparejado con éxito 🎉')),
      );
    }
  }

  void _showCloudLogin(String provider, String petId) {
    final emailController = TextEditingController();
    final passController = TextEditingController();
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Integración $provider Cloud',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Introduce tus credenciales de tu cuenta de $provider para sincronizar los datos de actividad y GPS de forma automática.',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          setModalState(() => loading = true);
                          final success = await _wearableService.connectCloudAccount(
                            provider: provider,
                            email: emailController.text,
                            password: passController.text,
                            petId: petId,
                          );
                          if (!ctx.mounted) return;
                          setModalState(() => loading = false);

                          if (success) {
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Cuenta de $provider vinculada y sincronizada correctamente!')),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error: Credenciales no válidas. Introduce un correo y contraseña válidos.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Vincular Cuenta de $provider'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final petProvider = context.watch<PetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.wearablesTitle),
        actions: [
          StreamBuilder<WearableDevice?>(
            stream: _wearableService.deviceStream,
            initialData: _wearableService.currentDevice,
            builder: (context, snapshot) {
              final device = snapshot.data;
              if (device == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.link_off, color: Colors.red),
                tooltip: 'Desconectar collar',
                onPressed: () => _wearableService.disconnectDevice(),
              );
            },
          )
        ],
      ),
      body: petProvider.pets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 64, color: colorScheme.primary.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes mascotas registradas.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Por favor, registra al menos una mascota antes de emparejar collares GPS o sensores wearables.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : StreamBuilder<WearableDevice?>(
              stream: _wearableService.deviceStream,
              initialData: _wearableService.currentDevice,
              builder: (context, snapshot) {
                final device = snapshot.data;
                final primaryPet = petProvider.pets.first;

                if (device == null) {
                  return _buildSetupView(primaryPet.id, primaryPet.name);
                }

                return _buildDashboardView(device, primaryPet.name);
              },
            ),
    );
  }

  /// Vista de Configuración (no emparejado)
  Widget _buildSetupView(String petId, String petName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary.withValues(alpha: 0.06), colorScheme.secondary.withValues(alpha: 0.03)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.wifi_tethering, size: 36, color: colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vincular Collar para $petName',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Selecciona un método de sincronización para comenzar a monitorizar pasos, sueño y constantes vitales.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 📡 MÉTODO 1: ESCÁNER BLUETOOTH BLE
          Text('Conexión Local Bluetooth BLE', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                if (!_isScanning) ...[
                  const Icon(Icons.bluetooth, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  const Text(
                    'Emparejamiento BLE Local',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Busca collares GPS y etiquetas inteligentes activos a tu alcance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _startScan,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar Dispositivos BLE'),
                  ),
                ] else ...[
                  // Animación del radar pulsante
                  AnimatedBuilder(
                    animation: _radarController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _RadarPainter(_radarController.value, colorScheme.primary),
                        child: const SizedBox(
                          height: 120,
                          width: 120,
                          child: Center(
                            child: Icon(Icons.bluetooth_searching, size: 36, color: Colors.blue),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _scanningLoading ? 'Buscando sensores...' : 'Dispositivos detectados',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_scanningLoading)
                    const CircularProgressIndicator()
                  else if (_scannedDevices.isEmpty)
                    const Text('No se encontraron dispositivos. Asegúrate de encender tu collar.')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _scannedDevices.length,
                      itemBuilder: (context, idx) {
                        final dev = _scannedDevices[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.gps_fixed, color: Colors.green),
                            title: Text(dev['name']),
                            subtitle: Text('S/N: ${dev['serial']} | Señal: ${dev['signal']} dBm'),
                            trailing: ElevatedButton(
                              onPressed: () => _connectBle(dev, petId),
                              child: const Text('Conectar'),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _stopScan,
                    child: const Text('Cancelar Escaneo'),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ☁️ MÉTODO 2: INTEGRACIONES EN LA NUBE
          Text('Sincronización en la Nube (API)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CloudProviderCard(
                  name: 'Tractive Cloud',
                  icon: Icons.cloud_done,
                  color: Colors.green,
                  onTap: () => _showCloudLogin('Tractive', petId),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CloudProviderCard(
                  name: 'Fi Collar Cloud',
                  icon: Icons.cloud_sync,
                  color: Colors.orange,
                  onTap: () => _showCloudLogin('Fi Collar', petId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Vista de Dashboard (sensor emparejado)
  Widget _buildDashboardView(WearableDevice device, String petName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⚠️ PANELES DE ALERTA DE GEOVALLA (GEOFENCING)
          StreamBuilder<WearableLocation?>(
            stream: _wearableService.locationStream,
            initialData: _wearableService.currentLocation,
            builder: (context, snapshot) {
              final loc = snapshot.data;
              if (loc == null) return const SizedBox.shrink();

              if (!loc.isSafeZone) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.redAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildPulsingAlertIcon(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚠️ ¡ALERTA DE SEGURIDAD!',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '$petName ha salido del perímetro de la ZONA SEGURA.',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            const Text(
                              'Coordenadas de escape en tiempo real: Lat 41.3876, Lng 2.1759',
                              style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Zona Segura Activa (Casa) | $petName está a salvo.',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ℹ️ FICHA DEL COLLAR INTELIGENTE
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          device.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            device.batteryLevel > 20 ? Icons.battery_full : Icons.battery_alert,
                            color: device.batteryLevel > 20 ? Colors.greenAccent : Colors.redAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${device.batteryLevel}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MÉTODO', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1.1)),
                        Text(device.connectionType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CÓDIGO DE DISPOSITIVO', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1.1)),
                        Text(device.serialNumber, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'CONECTADO',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 💓 TELEMETRÍA EN TIEMPO REAL: CONSTANTES Y ACTIVIDAD
          StreamBuilder<WearableActivity?>(
            stream: _wearableService.activityStream,
            initialData: _wearableService.currentActivity,
            builder: (context, snapshot) {
              final act = snapshot.data;
              if (act == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final stepPercent = act.steps / act.stepsGoal;

              return Column(
                children: [
                  Row(
                    children: [
                      // 🏃 CARD 1: PASOS DIARIOS
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Pasos Hoy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Icon(Icons.directions_run, color: colorScheme.primary, size: 20),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 90,
                                      width: 90,
                                      child: CircularProgressIndicator(
                                        value: stepPercent,
                                        strokeWidth: 8,
                                        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '${act.steps}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          'meta ${act.stepsGoal}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 9),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 💓 CARD 2: RITMO CARDÍACO REAL-TIME (ANIMADO)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Ritmo Cardíaco', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Icon(Icons.favorite, color: Colors.red, size: 20),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Column(
                                  children: [
                                    // Corazón palpitante interactivo
                                    _HeartBeatWidget(bpm: act.heartRateBpm),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '${act.heartRateBpm}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.red),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text('BPM', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'ESTABLE',
                                        style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🛌 CARD 3: MONITOREO DE SUEÑO
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.hotel, color: Colors.indigo, size: 20),
                                SizedBox(width: 8),
                                Text('Análisis del Sueño', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Text(
                              '${(act.sleepMinutes / 60).toStringAsFixed(1)} hrs / ${(act.sleepGoalMinutes / 60).toStringAsFixed(0)} hrs meta',
                              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: act.sleepMinutes / act.sleepGoalMinutes,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(6),
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sueño Profundo: 2.8 hrs', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            Text('Sueño Ligero: 3.5 hrs', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // 🗺️ SIMULADOR DE MAPA GPS INTERACTIVO
          Text('Ubicación del Collar GPS', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () {
                  final petProvider = context.read<PetProvider>();
                  final activePet = petProvider.pets.isNotEmpty ? petProvider.pets.first : null;
                  context.push('/wearables/gps-tracking', extra: activePet);
                },
                child: Stack(
                  children: [
                  // Cuadrícula decorativa simulando un mapa digital minimalista
                  Positioned.fill(
                    child: StreamBuilder<WearableLocation?>(
                      stream: _wearableService.locationStream,
                      initialData: _wearableService.currentLocation,
                      builder: (context, snapshot) {
                        final loc = snapshot.data;
                        if (loc == null) return const SizedBox.shrink();

                        return CustomPaint(
                          painter: _MapSimulatorPainter(
                            latitude: loc.latitude,
                            longitude: loc.longitude,
                            safe: loc.isSafeZone,
                            accentColor: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text(
                            'Precisión GPS: +/- 4m',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildPulsingAlertIcon() {
    return const SizedBox(
      height: 36,
      width: 36,
      child: Center(
        child: Icon(Icons.error, color: Colors.red, size: 36),
      ),
    );
  }
}

/// Custom Painter para el efecto pulsante del radar BLE
class _RadarPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RadarPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * progress;

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.5, paint..color = color.withValues(alpha: (1.0 - progress) * 0.6));
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}

/// Custom Painter para simular un mapa minimalista interactivo
class _MapSimulatorPainter extends CustomPainter {
  final double latitude;
  final double longitude;
  final bool safe;
  final Color accentColor;

  _MapSimulatorPainter({
    required this.latitude,
    required this.longitude,
    required this.safe,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    // Dibujar cuadricula del mapa
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintGrid);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paintGrid);
    }

    // Dibujar geocerca circular en el centro
    final center = Offset(size.width / 2, size.height / 2);
    final safeZonePaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final safeZoneBorder = Paint()
      ..color = Colors.green.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, 70, safeZonePaint);
    canvas.drawCircle(center, 70, safeZoneBorder);

    // Dibujar el pin de localización del perro
    // Si no está a salvo, aplicamos un desfase para sacarlo de la geocerca
    final dogPosition = safe ? center : Offset(center.dx + 80, center.dy - 40);

    final dotPaint = Paint()
      ..color = safe ? Colors.blue : Colors.red
      ..style = PaintingStyle.fill;

    final pulsePaint = Paint()
      ..color = (safe ? Colors.blue : Colors.red).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // Efecto de pulso en la ubicación del perro
    canvas.drawCircle(dogPosition, 16, pulsePaint);
    canvas.drawCircle(dogPosition, 6, dotPaint);

    // Etiqueta del pin
    final textPainter = TextPainter(
      text: TextSpan(
        text: '🐾 Mascota',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: safe ? Colors.blue : Colors.red,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(dogPosition.dx - 24, dogPosition.dy - 24));
  }

  @override
  bool shouldRepaint(covariant _MapSimulatorPainter oldDelegate) => true;
}

/// Tarjeta de Proveedores en la Nube
class _CloudProviderCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CloudProviderCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sincronizar Cloud',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget del corazón palpitante real-time
class _HeartBeatWidget extends StatefulWidget {
  final int bpm;

  const _HeartBeatWidget({required this.bpm});

  @override
  State<_HeartBeatWidget> createState() => _HeartBeatWidgetState();
}

class _HeartBeatWidgetState extends State<_HeartBeatWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: _calculateDuration(widget.bpm),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _HeartBeatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bpm != widget.bpm) {
      _pulseController.duration = _calculateDuration(widget.bpm);
      _pulseController.repeat(reverse: true);
    }
  }

  Duration _calculateDuration(int bpm) {
    // A mayor BPM, latido más rápido
    final ms = (60000 / bpm) / 2; // duración de un semi-ciclo
    return Duration(milliseconds: ms.round());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double scale = 1.0 + (_pulseController.value * 0.18);
        return Transform.scale(
          scale: scale,
          child: const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 40,
          ),
        );
      },
    );
  }
}
