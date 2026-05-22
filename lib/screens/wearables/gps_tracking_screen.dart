import 'dart:async';
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/services/wearable_service.dart';
import 'package:nachos_pet_care_flutter/models/wearable_device.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';

class GpsTrackingScreen extends StatefulWidget {
  final Pet? initialPet;

  const GpsTrackingScreen({super.key, this.initialPet});

  @override
  State<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends State<GpsTrackingScreen> with TickerProviderStateMixin {
  final WearableService _wearableService = getIt<WearableService>();
  StreamSubscription? _locationSubscription;

  Pet? _selectedPet;
  double _geofenceRadius = 150.0; // Dynamic Geofence radius in meters (50m to 500m)
  bool _mockEscapeActive = false;

  // Path history trail of canvas offsets to draw a motion trail
  final List<Offset> _trailHistory = [];
  Offset? _lastCalculatedOffset;

  // Animation controller for flashing hazard warnings during an escape
  late AnimationController _alertPulseController;
  late AnimationController _mapAnimationController;

  @override
  void initState() {
    super.initState();
    _alertPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Listen to real-time location stream to populate our breadcrumb trail
    _locationSubscription = _wearableService.locationStream.listen((loc) {
      if (loc == null || !mounted) return;

      // Base coordinates (Barcelona Center)
      const double baseLat = 41.3851;
      const double baseLng = 2.1734;

      // Dynamic Y and X shifts
      double dx = (loc.longitude - baseLng) * 120000;
      double dy = -(loc.latitude - baseLat) * 120000;

      setState(() {
        final newOffset = Offset(dx, dy);
        _lastCalculatedOffset = newOffset;

        // Prevent duplicating identical locations consecutively
        if (_trailHistory.isEmpty || (_trailHistory.last - newOffset).distance > 5) {
          _trailHistory.add(newOffset);
          if (_trailHistory.length > 8) {
            _trailHistory.removeAt(0); // Cap historical trail length
          }
        }
      });

      // Handle safety status changes dynamically
      if (!loc.isSafeZone && !_mockEscapeActive) {
        _triggerVisualEscapeAlert();
      } else if (loc.isSafeZone && _mockEscapeActive) {
        _cancelVisualEscapeAlert();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedPet == null) {
      final petProvider = context.watch<PetProvider>();
      if (petProvider.pets.isNotEmpty) {
        // Use initialPet if passed, otherwise default to first active pet
        _selectedPet = widget.initialPet ?? petProvider.pets.first;
      }
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _alertPulseController.dispose();
    _mapAnimationController.dispose();
    super.dispose();
  }

  void _triggerVisualEscapeAlert() {
    setState(() {
      _mockEscapeActive = true;
    });
    _alertPulseController.repeat(reverse: true);

    // Show emergency dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 36),
          ),
          title: Text(
            '¡ALERTA DE SEGURIDAD!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
          ),
          content: Text(
            '${_selectedPet?.name ?? "Tu mascota"} ha superado el perímetro de seguridad establecido de ${_geofenceRadius.toInt()} metros.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Generando ruta de recuperación rápida por GPS... 📍'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Iniciar Ruta de Búsqueda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ignorar Alerta', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    });
  }

  void _cancelVisualEscapeAlert() {
    setState(() {
      _mockEscapeActive = false;
    });
    _alertPulseController.stop();
  }

  void _triggerMockManualEscape() {
    if (_mockEscapeActive) {
      _cancelVisualEscapeAlert();
    } else {
      _triggerVisualEscapeAlert();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final petProvider = context.watch<PetProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Seguimiento GPS Satelital'),
        centerTitle: true,
        actions: [
          StreamBuilder<WearableDevice?>(
            stream: _wearableService.deviceStream,
            initialData: _wearableService.currentDevice,
            builder: (context, devSnap) {
              final device = devSnap.data;
              if (device == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.battery_5_bar_rounded, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${device.batteryLevel}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: petProvider.pets.isEmpty
          ? _buildNoPetsView()
          : Column(
              children: [
                // 1. Horizontal Pet Picker Chips
                _buildPetPickerSection(petProvider.pets),

                // 2. Main Live Map Visualizer (Expands)
                Expanded(
                  child: Stack(
                    children: [
                      // Simulated digital street-map custom painter canvas
                      Positioned.fill(
                        child: StreamBuilder<WearableLocation?>(
                          stream: _wearableService.locationStream,
                          initialData: _wearableService.currentLocation,
                          builder: (context, locSnap) {
                            final loc = locSnap.data;
                            if (loc == null) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 12),
                                    Text('Esperando señal GPS del collar...', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              );
                            }

                            // Dynamic calculations based on coordinates
                            return AnimatedBuilder(
                              animation: Listenable.merge([_mapAnimationController, _alertPulseController]),
                              builder: (context, _) {
                                return ClipRect(
                                  child: CustomPaint(
                                    painter: _InteractiveGpsMapPainter(
                                      geofenceRadius: _geofenceRadius,
                                      trail: _trailHistory,
                                      currentOffset: _lastCalculatedOffset ?? Offset.zero,
                                      isSafeZone: loc.isSafeZone && !_mockEscapeActive,
                                      mockEscapeActive: _mockEscapeActive,
                                      alertProgress: _alertPulseController.value,
                                      animationValue: _mapAnimationController.value,
                                      accentColor: colorScheme.primary,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Flashing Hazard Red Border during mock escape
                      if (_mockEscapeActive)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _alertPulseController,
                              builder: (context, _) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.red.withValues(alpha: 0.3 * _alertPulseController.value),
                                      width: 8.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // Top-right Compass & Overlay actions
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'compass_fab',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Centrando mapa satelital en la mascota...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: const Icon(Icons.explore_outlined),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'emergency_fab',
                              backgroundColor: _mockEscapeActive ? Colors.red : colorScheme.surface,
                              foregroundColor: _mockEscapeActive ? Colors.white : colorScheme.onSurface,
                              onPressed: _triggerMockManualEscape,
                              tooltip: 'Simular Fuga',
                              child: Icon(_mockEscapeActive ? Icons.warning : Icons.crisis_alert_outlined),
                            ),
                          ],
                        ),
                      ),

                      // Live Glowing Perimetro status bar overlay
                      Positioned(
                        top: 16,
                        left: 16,
                        child: StreamBuilder<WearableLocation?>(
                          stream: _wearableService.locationStream,
                          initialData: _wearableService.currentLocation,
                          builder: (context, locSnap) {
                            final loc = locSnap.data;
                            final isSafe = (loc?.isSafeZone ?? true) && !_mockEscapeActive;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: (isSafe ? Colors.green : Colors.red).withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isSafe ? Colors.green : Colors.red).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSafe ? Icons.gpp_good : Icons.gpp_maybe,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isSafe ? 'DENTRO DEL PERÍMETRO' : '¡FUERA DE LÍMITES!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Sliding Geofence Controls & Live Telemetry
                _buildGeofencePanel(colorScheme, theme),
              ],
            ),
    );
  }

  Widget _buildNoPetsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'No hay mascotas disponibles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              'Por favor, registra al menos una mascota en tu perfil para habilitar el rastreo GPS.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetPickerSection(List<Pet> pets) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          final isSelected = _selectedPet?.id == pet.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              avatar: CircleAvatar(
                radius: 12,
                backgroundImage: pet.photoPath != null && pet.photoPath!.isNotEmpty
                    ? FileImage(File(pet.photoPath!)) as ImageProvider
                    : null,
                child: pet.photoPath == null || pet.photoPath!.isEmpty
                    ? const Icon(Icons.pets, size: 12)
                    : null,
              ),
              label: Text(pet.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPet = pet;
                    _trailHistory.clear(); // Clear old trail for new pet
                    _lastCalculatedOffset = null;
                  });
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeofencePanel(ColorScheme colorScheme, ThemeData theme) {
    return StreamBuilder<WearableLocation?>(
      stream: _wearableService.locationStream,
      initialData: _wearableService.currentLocation,
      builder: (context, locSnap) {
        final loc = locSnap.data;
        final latText = loc != null ? loc.latitude.toStringAsFixed(5) : '0.00000';
        final lngText = loc != null ? loc.longitude.toStringAsFixed(5) : '0.00000';

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel Drag Handle Indicator
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajustar Geovalla de Seguridad',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Radio actual de cobertura: ${_geofenceRadius.toInt()}m',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_geofenceRadius.toInt()} m',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              // Radius Slider
              Slider(
                value: _geofenceRadius,
                min: 50.0,
                max: 500.0,
                divisions: 9,
                label: '${_geofenceRadius.toInt()}m',
                onChanged: (newVal) {
                  setState(() {
                    _geofenceRadius = newVal;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Live GPS metrics grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.radar,
                      label: 'Precisión',
                      value: '+/- 4.2m',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.speed,
                      label: 'Velocidad',
                      value: _mockEscapeActive ? '12.4 km/h' : '2.1 km/h',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.satellite_alt,
                      label: 'Señal GPS',
                      value: '-68 dBm',
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Lat Long Coordinate Readout
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Coordenadas satelitales actuales: ',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      'Lat $latText, Lng $lngText',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveGpsMapPainter extends CustomPainter {
  final double geofenceRadius;
  final List<Offset> trail;
  final Offset currentOffset;
  final bool isSafeZone;
  final bool mockEscapeActive;
  final double alertProgress;
  final double animationValue;
  final Color accentColor;

  _InteractiveGpsMapPainter({
    required this.geofenceRadius,
    required this.trail,
    required this.currentOffset,
    required this.isSafeZone,
    required this.mockEscapeActive,
    required this.alertProgress,
    required this.animationValue,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw Digital Map Street Grids
    final paintGrid = Paint()
      ..color = Colors.grey.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 24) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintGrid);
    }
    for (double i = 0; i < size.height; i += 24) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paintGrid);
    }

    // 2. Draw Simulated Streets and Parks (Custom geometry for beauty)
    final paintGreenZone = Paint()
      ..color = Colors.green.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw custom Park zones
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 40, 100, 90),
        const Radius.circular(16),
      ),
      paintGreenZone,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 130, size.height - 180, 110, 140),
        const Radius.circular(16),
      ),
      paintGreenZone,
    );

    // Draw main boulevard/street outlines
    final paintStreet = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paintStreet);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paintStreet);

    // Draw labels for streets
    const textStyle = TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: const TextSpan(text: 'Av. Diagonal PetCare', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(20, center.dy - 12));

    final textPainter2 = TextPainter(
      text: const TextSpan(text: 'Parque Canino Barcelona', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter2.paint(canvas, Offset(25, 45));

    // 3. Draw Safety Geofence (Visual Circle)
    // geofenceRadius goes from 50m to 500m. Map to screen pixels (e.g. 50m = 30px, 500m = 180px)
    final double screenRadius = 30.0 + ((geofenceRadius - 50.0) / 450.0) * 130.0;

    final geofenceFillPaint = Paint()
      ..color = (isSafeZone ? Colors.green : Colors.red).withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final geofenceBorderPaint = Paint()
      ..color = (isSafeZone ? Colors.green : Colors.red).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, screenRadius, geofenceFillPaint);
    canvas.drawCircle(center, screenRadius, geofenceBorderPaint);

    // Draw safety fence dash pattern details
    final dashPaint = Paint()
      ..color = (isSafeZone ? Colors.green : Colors.red).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, screenRadius + 4, dashPaint);

    // 4. Draw Pet Breadcrumb Path History Trail
    if (trail.isNotEmpty && trail.length > 1) {
      final trailPaint = Paint()
        ..color = (isSafeZone ? Colors.blue : Colors.red).withValues(alpha: 0.3)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(center.dx + trail[0].dx, center.dy + trail[0].dy);
      for (int i = 1; i < trail.length; i++) {
        path.lineTo(center.dx + trail[i].dx, center.dy + trail[i].dy);
      }
      canvas.drawPath(path, trailPaint);

      // Draw little dot trails
      final dotPaint = Paint()
        ..color = (isSafeZone ? Colors.blue : Colors.red).withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      for (var pt in trail) {
        canvas.drawCircle(center + pt, 3.0, dotPaint);
      }
    }

    // 5. Draw Pet Real-Time Marker
    final petPosition = center + currentOffset;

    // Pulse effect behind pet marker
    final pulsePaint = Paint()
      ..color = (isSafeZone ? Colors.blue : Colors.red).withValues(
        alpha: 0.15 * (1.0 - (animationValue % 1.0)),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(petPosition, 24 * (1.0 + (animationValue % 1.0)), pulsePaint);

    // Hazard alarm warning flashing halo
    if (mockEscapeActive) {
      final hazardPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.3 * alertProgress)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(petPosition, 18.0, hazardPaint);
    }

    // Core Solid Pointer Ring
    final markerBgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final markerBorderPaint = Paint()
      ..color = isSafeZone ? Colors.blue : Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(petPosition, 9.0, markerBgPaint);
    canvas.drawCircle(petPosition, 9.0, markerBorderPaint);

    // Inner pin dot
    final pinDotPaint = Paint()
      ..color = isSafeZone ? Colors.blue : Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(petPosition, 4.0, pinDotPaint);

    // 6. Styled Callout Label above pet pin
    final labelBgPaint = Paint()
      ..color = isSafeZone ? Colors.blue : Colors.red
      ..style = PaintingStyle.fill;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(petPosition.dx - 28, petPosition.dy - 32, 56, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, labelBgPaint);

    final labelText = TextPainter(
      text: const TextSpan(
        text: '🐾 RASTREO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelText.paint(canvas, Offset(petPosition.dx - 22, petPosition.dy - 28));
  }

  @override
  bool shouldRepaint(covariant _InteractiveGpsMapPainter oldDelegate) {
    return oldDelegate.geofenceRadius != geofenceRadius ||
        oldDelegate.trail.length != trail.length ||
        oldDelegate.currentOffset != currentOffset ||
        oldDelegate.isSafeZone != isSafeZone ||
        oldDelegate.mockEscapeActive != mockEscapeActive ||
        oldDelegate.alertProgress != alertProgress ||
        oldDelegate.animationValue != animationValue;
  }
}
