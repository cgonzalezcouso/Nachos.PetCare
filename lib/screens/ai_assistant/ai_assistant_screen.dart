import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/services/ai_assistant_service.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/l10n/app_strings.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _WearablePetAvatar extends StatelessWidget {
  final Pet pet;
  final bool isSelected;
  final VoidCallback onTap;

  const _WearablePetAvatar({
    required this.pet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.4) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: pet.photoPath != null
                  ? (pet.photoPath!.startsWith('http')
                      ? NetworkImage(pet.photoPath!) as ImageProvider
                      : FileImage(File(pet.photoPath!)))
                  : null,
              child: pet.photoPath == null
                  ? Icon(
                      Icons.pets,
                      size: 28,
                      color: isSelected ? colorScheme.primary : Colors.grey,
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              pet.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiAssistantScreenState extends State<AiAssistantScreen> with SingleTickerProviderStateMixin {
  final AiAssistantService _aiService = getIt<AiAssistantService>();
  final TextEditingController _symptomController = TextEditingController();

  Pet? _selectedPet;
  bool _isLoading = false;
  AiDiagnosticReport? _report;
  
  // Lista de items del checklist interactivo de prevención
  final List<Map<String, dynamic>> _checklistItems = [];

  // Controladores de animación de carga orbital
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  void _prefillSymptom(String text) {
    setState(() {
      _symptomController.text = text;
    });
  }

  void _runSymptomAnalysis() async {
    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una mascota primero.')),
      );
      return;
    }
    if (_symptomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, describe los síntomas que presenta tu mascota.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _report = null;
      _checklistItems.clear();
    });
    _pulseController.repeat();

    // Invocar servicio
    final ageMonths = _selectedPet!.birthDate == null 
        ? 24 
        : DateTime.now().difference(_selectedPet!.birthDate!).inDays ~/ 30;

    final result = await _aiService.analyzeSymptoms(
      symptomsText: _symptomController.text,
      petName: _selectedPet!.name,
      petType: _selectedPet!.type == PetType.dog ? 'Dog' : 'Cat',
      breed: _selectedPet!.breed ?? 'Desconocida',
      ageMonths: ageMonths,
      weight: _selectedPet!.weight ?? 10.0,
    );

    if (mounted) {
      _pulseController.stop();
      setState(() {
        _isLoading = false;
        _report = result;
        // Rellenar el checklist preventivo
        for (final item in result.preventativeCare) {
          _checklistItems.add({
            'text': item,
            'checked': false,
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final petProvider = context.watch<PetProvider>();

    // Inicializar mascota por defecto si hay y no se ha seleccionado
    if (_selectedPet == null && petProvider.pets.isNotEmpty) {
      _selectedPet = petProvider.pets.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.aiAssistantTitle),
      ),
      body: petProvider.pets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.smart_toy_outlined, size: 64, color: colorScheme.primary.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay mascotas registradas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Registra una mascota para que el Asistente IA pueda cruzar datos anatómicos y de raza para ofrecer sugerencias precisas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CAROUSEL SELECTOR DE MASCOTAS
                  Text('Selecciona la mascota a consultar:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: petProvider.pets.length,
                      itemBuilder: (context, index) {
                        final pet = petProvider.pets[index];
                        return _WearablePetAvatar(
                          pet: pet,
                          isSelected: _selectedPet?.id == pet.id,
                          onTap: () {
                            setState(() {
                              _selectedPet = pet;
                              _report = null;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. FORMULARIO DE SÍNTOMAS
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, color: colorScheme.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Describe los síntomas',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _symptomController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Ej. Mi perro está decaído hoy, tiembla un poco y ha rechazado su comida habitual...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Sugerencias Rápidas
                        const Text('Sugerencias predeterminadas:', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PresetTag(
                              label: 'Cojera / Dolor Pata 🐾',
                              onTap: () => _prefillSymptom('Tiene una ligera cojera en la pata delantera derecha desde esta mañana y no quiere apoyar.'),
                            ),
                            _PresetTag(
                              label: 'Vómitos y Falta Apetito 🤮',
                              onTap: () => _prefillSymptom('Ha vomitado dos veces comida a medio digerir y está apático, no ha querido desayunar.'),
                            ),
                            _PresetTag(
                              label: 'Tos y Signos Respiratorios 🤒',
                              onTap: () => _prefillSymptom('Empezó a toser como si tuviera algo atascado en el pecho, tiene moquito transparente.'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _runSymptomAnalysis,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.smart_toy),
                          label: const Text('Analizar Síntomas con IA'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. ESTADO DE CARGA ANIMADO
                  if (_isLoading) _buildLoadingOrb(),

                  // 4. RESULTADOS DE INFORME IA
                  if (_report != null) ...[
                    _buildReportView(_report!, theme, colorScheme),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingOrb() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            RotationTransition(
              turns: _pulseController,
              child: const SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🤖 Analizando patologías...',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 6),
            Text(
              'El Asistente IA está cruzando los síntomas con la raza ${_selectedPet?.breed} y su edad de ${((_selectedPet!.birthDate == null ? 24 : DateTime.now().difference(_selectedPet!.birthDate!).inDays ~/ 30)/12).toStringAsFixed(1)} años.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportView(AiDiagnosticReport report, ThemeData theme, ColorScheme colorScheme) {
    // Definir colores según riesgo
    Color riskColor = Colors.green;
    if (report.riskLevel == 'Medio') riskColor = Colors.orange;
    if (report.riskLevel == 'Alto') riskColor = Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CABECERA DEL REPORTE
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Informe Médico Generado', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: riskColor.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RIESGO ${report.riskLevel.toUpperCase()}',
                    style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.1),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 📝 1. ANÁLISIS DE SÍNTOMAS (CON EFECTO DE MÁQUINA DE ESCRIBIR)
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
              const Row(
                children: [
                  Icon(Icons.analytics_outlined, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text('Análisis Clínico', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              _TypewriterText(text: report.symptomAnalysis),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 🩺 2. DIAGNÓSTICOS DIFERENCIALES
        Text('Diagnósticos Diferenciales Sugeridos', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'Hipótesis probables evaluadas por el algoritmo clínico IA basadas en la raza de la mascota:',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: report.differentialDiagnoses.length,
          itemBuilder: (context, idx) {
            final diff = report.differentialDiagnoses[idx];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blueAccent.withValues(alpha: 0.15)),
              ),
              child: ListTile(
                leading: const Icon(Icons.search, color: Colors.blueAccent),
                title: Text(
                  diff,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // 📋 3. CHECKLIST INTERACTIVO DE CUIDADO PREVENTIVO
        Text('Guía de Cuidado Preventivo Activo', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          'Completa estas pautas preventivas recomendadas en casa mientras vigilas su estado:',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _checklistItems.length,
            itemBuilder: (context, idx) {
              final item = _checklistItems[idx];
              return CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  item['text'],
                  style: TextStyle(
                    fontSize: 12,
                    decoration: item['checked'] ? TextDecoration.lineThrough : null,
                    color: item['checked'] ? Colors.grey : colorScheme.onSurface,
                  ),
                ),
                value: item['checked'],
                onChanged: (val) {
                  setState(() {
                    item['checked'] = val;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // ⚠️ 4. AVISO DE URGENCIA CLÍNICA
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: riskColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: riskColor.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: riskColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Recomendación del Asistente',
                    style: TextStyle(color: riskColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.recommendedUrgency,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 20),
              const Text(
                'Nota Legal: El Asistente IA no sustituye la opinión médica presencial de un veterinario titulado. Es una herramienta de cribado preliminar clínico.',
                style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Etiqueta predeterminada pulsable
class _PresetTag extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetTag({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      onPressed: onTap,
      elevation: 0,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.05),
      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.12)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      label: Text(
        label,
        style: TextStyle(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Widget para escribir el texto de forma progresiva (efecto máquina de escribir)
class _TypewriterText extends StatefulWidget {
  final String text;

  const _TypewriterText({required this.text});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayedText = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _timer?.cancel();
    _displayedText = '';

    int idx = 0;
    // Imprimir de 3 en 3 caracteres para que vaya rápido pero fluido
    _timer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (idx < widget.text.length) {
        final chunkEnd = (idx + 3 < widget.text.length) ? idx + 3 : widget.text.length;
        setState(() {
          _displayedText += widget.text.substring(idx, chunkEnd);
        });
        idx = chunkEnd;
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: const TextStyle(fontSize: 13, height: 1.5),
    );
  }
}
