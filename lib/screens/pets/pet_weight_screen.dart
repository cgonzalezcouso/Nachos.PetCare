import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/models/pet_weight.dart';
import 'package:nachos_pet_care_flutter/l10n/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/providers/subscription_provider.dart';

class PetWeightScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const PetWeightScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetWeightScreen> createState() => _PetWeightScreenState();
}

class _PetWeightScreenState extends State<PetWeightScreen> {
  final DatabaseService _db = getIt<DatabaseService>();
  List<PetWeight> _weights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeights();
  }

  Future<void> _loadWeights() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final weights = await _db.getPetWeights(widget.petId);
      setState(() {
        _weights = weights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addWeight() async {
    final subProvider = context.read<SubscriptionProvider>();
    final canAdd = await subProvider.canAddEvent(widget.petId);
    if (!canAdd) {
      if (mounted) context.push('/premium-paywall');
      return;
    }

    DateTime selectedDate = DateTime.now();
    final weightController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final strings = AppStrings.of(context);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(strings.addWeight),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: strings.weightInKg,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: const Icon(Icons.scale),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                      title: Text(strings.selectWeightDate),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(weightController.text);
                    if (val == null || val <= 0) {
                      // Mostrar validación rápida
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: Text(strings.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      final val = double.parse(weightController.text);
      final id = const Uuid().v4();
      final weightRecord = PetWeight(
        id: id,
        petId: widget.petId,
        weight: val,
        date: selectedDate,
        createdAt: DateTime.now(),
      );

      await _db.insertPetWeight(weightRecord);
      _loadWeights();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).weightAddedSuccessfully),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteWeight(PetWeight weight) async {
    final strings = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteWeightConfirm),
        content: Text(strings.deleteWeightConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deletePetWeight(weight.id);
      _loadWeights();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calcular datos de la gráfica
    final List<FlSpot> spots = [];
    double minY = 0;
    double maxY = 10;
    double minX = 0;
    double maxX = 5;

    if (_weights.isNotEmpty) {
      double minVal = _weights[0].weight;
      double maxVal = _weights[0].weight;

      for (int i = 0; i < _weights.length; i++) {
        final w = _weights[i];
        spots.add(FlSpot(i.toDouble(), w.weight));
        if (w.weight < minVal) minVal = w.weight;
        if (w.weight > maxVal) maxVal = w.weight;
      }

      minY = (minVal - 2).clamp(0, double.infinity);
      maxY = maxVal + 2;
      minX = 0;
      maxX = (_weights.length - 1).toDouble().clamp(1, double.infinity);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${strings.weightHistory} - ${widget.petName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/pets/${widget.petId}');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWeight,
        tooltip: strings.addWeight,
        child: const Icon(Icons.scale_outlined),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                if (_weights.isNotEmpty) ...[
                  // Sección de gráfica
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.evolution,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index >= 0 && index < _weights.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  DateFormat('dd/MM').format(_weights[index].date),
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 42,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              '${value.toStringAsFixed(1)}k',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                    minX: minX,
                                    maxX: maxX,
                                    minY: minY,
                                    maxY: maxY,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            colorScheme.primary,
                                            colorScheme.secondary,
                                          ],
                                        ),
                                        barWidth: 4,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                            radius: 6,
                                            color: colorScheme.primary,
                                            strokeWidth: 2,
                                            strokeColor: colorScheme.surface,
                                          ),
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              colorScheme.primary.withValues(alpha: 0.3),
                                              colorScheme.primary.withValues(alpha: 0.0),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
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
                  ),
                ],
                if (_weights.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.scale_outlined,
                            size: 72,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${strings.emptyWeightHistory} ${widget.petName}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.emptyWeightHistorySubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Mostrar lista en orden inverso (más reciente primero)
                          final reversedIndex = _weights.length - 1 - index;
                          final record = _weights[reversedIndex];
                          final formattedDate = DateFormat('dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(record.date);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                                child: const Icon(Icons.scale),
                              ),
                              title: Text(
                                '${record.weight} kg',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(formattedDate),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteWeight(record),
                              ),
                            ),
                          );
                        },
                        childCount: _weights.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
