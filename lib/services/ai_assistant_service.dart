import 'dart:async';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

class AiDiagnosticReport {
  final String symptomAnalysis;
  final List<String> differentialDiagnoses;
  final List<String> preventativeCare;
  final String riskLevel; // 'Bajo', 'Medio', 'Alto'
  final String recommendedUrgency;

  AiDiagnosticReport({
    required this.symptomAnalysis,
    required this.differentialDiagnoses,
    required this.preventativeCare,
    required this.riskLevel,
    required this.recommendedUrgency,
  });
}

class AiAssistantService {
  AiAssistantService() {
    AppLogger.info('Servicio AiAssistantService inicializado.');
  }

  /// Analiza los síntomas descritos por el usuario cruzándolos con la ficha clínica de la mascota
  Future<AiDiagnosticReport> analyzeSymptoms({
    required String symptomsText,
    required String petName,
    required String petType, // 'Dog', 'Cat', etc.
    required String breed,
    required int ageMonths,
    required double weight,
  }) async {
    AppLogger.info('Iniciando análisis de IA para $petName ($breed, $ageMonths meses)...');
    
    // Simula retardo de red de un LLM remoto
    await Future.delayed(const Duration(milliseconds: 1800));

    final text = symptomsText.toLowerCase();
    final ageYears = (ageMonths / 12).toStringAsFixed(1);

    // ── PATRÓN 1: COJERA / DOLOR ARTICULAR / PATA ────────────────────────────────
    if (text.contains('cojera') || text.contains('cojo') || text.contains('pata') || text.contains('articulación') || text.contains('andar') || text.contains('dolor')) {
      final isBulldog = breed.toLowerCase().contains('bulldog');
      final isLargeDog = weight > 25 && petType.toLowerCase() == 'dog';

      String breedSpecificBonus = '';
      List<String> differentials = [];

      if (isBulldog) {
        breedSpecificBonus = ' Al tratarse de un $breed (raza condrodistrófica), existe una predisposición anatómica a hernias discales o subluxación rotuliana.';
        differentials = [
          'Subluxación de Rótula (Frecuente en razas braquicéfalas y Bulldogs)',
          'Hernia Discal Grado I (Afectación de columna toracolumbar)',
          'Esguince o distensión ligamentosa menor',
        ];
      } else if (isLargeDog) {
        breedSpecificBonus = ' Dado que $petName es una mascota de raza grande ($weight kg), es primordial vigilar el desgaste del cartílago.';
        differentials = [
          'Predisposición a Displasia de Cadera o Codo',
          'Rotura parcial del ligamento cruzado anterior (LCA)',
          'Osteoartritis de aparición temprana',
        ];
      } else {
        differentials = [
          'Traumatismo articular o muscular menor',
          'Cuerpo extraño o corte menor en las almohadillas de las patas',
          'Esguince rotuliano o tendinoso',
        ];
      }

      return AiDiagnosticReport(
        symptomAnalysis: 'El análisis de síntomas reporta una alteración de la locomoción en $petName (perro de raza $breed, $ageYears años). La presencia de claudicación en la marcha sugiere una afección traumatológica o neurológica periférica.$breedSpecificBonus Es muy importante observar si apoya el miembro o si el dolor le impide conciliar el sueño.',
        differentialDiagnoses: differentials,
        preventativeCare: [
          'Restringir absolutamente el ejercicio físico pesado, saltar a sofás o subir escaleras.',
          'Revisar minuciosamente la almohadilla plantar en busca de espigas, astillas o heridas superficiales.',
          'Aplicar reposo controlado en un área acolchada y seca.',
          'Mantener un registro de si la cojera empeora en frío (al levantarse) o tras el movimiento continuo.',
        ],
        riskLevel: 'Medio',
        recommendedUrgency: 'Se recomienda concertar una visita veterinaria preventiva en las próximas 48 horas si no cede con reposo. Evita automedicar a $petName con antiinflamatorios humanos ya que son altamente tóxicos.',
      );
    }

    // ── PATRÓN 2: VÓMITOS / DIARREA / ESTÓMAGO / CACA ──────────────────────────────
    if (text.contains('vómit') || text.contains('diarrea') || text.contains('estómago') || text.contains('comer') || text.contains('vomit') || text.contains('caca') || text.contains('tripa')) {
      final isPuppy = ageMonths < 12;
      String ageSpecificText = '';
      List<String> differentials = [];
      String risk = 'Medio';

      if (isPuppy) {
        ageSpecificText = ' Debido a que $petName es un cachorro de apenas $ageMonths meses, el sistema inmune aún está madurando, aumentando el riesgo de deshidratación rápida.';
        differentials = [
          'Gastroenteritis vírica (ej. Parvovirus / Coronavirus canino)',
          'Parasitosis intestinal aguda por nematodos o giardias',
          'Indiscreción alimentaria (ingesta de cuerpos extraños o plantas tóxicas)',
        ];
        risk = 'Alto';
      } else {
        differentials = [
          'Gastroenteritis por indiscreción alimentaria (empacho o cambio de pienso brusco)',
          'Reacción alérgica alimentaria temporal',
          'Infección bacteriana oportunista gastrointestinal',
        ];
      }

      return AiDiagnosticReport(
        symptomAnalysis: 'Se ha detectado un cuadro agudo de disfunción gastrointestinal en $petName.$ageSpecificText Los episodios gastrointestinales pueden deberse a múltiples factores, desde intoxicaciones leves por ingesta en la calle hasta infecciones patógenas que requieren antibioterapia.',
        differentialDiagnoses: differentials,
        preventativeCare: [
          'Retirar la comida sólida durante un periodo de 8 a 12 horas para permitir el reposo digestivo, manteniendo acceso a agua limpia a libre disposición en pequeñas cantidades.',
          'Ofrecer una dieta blanda casera (arroz blanco cocido y pechuga de pollo hervida sin sal ni piel) en tomas muy pequeñas una vez cese el vómito.',
          'Controlar la coloración de las encías de $petName (deben lucir rosadas y húmedas, no pálidas ni secas).',
          'Suministrar probióticos específicos para mascotas bajo orientación veterinaria para restablecer la flora.',
        ],
        riskLevel: risk,
        recommendedUrgency: risk == 'Alto'
            ? '¡ATENCIÓN! Al tratarse de un cachorro en desarrollo con riesgo de deshidratación, se aconseja acudir a urgencias veterinarias si presenta más de 3 vómitos en un día o caca con sangre.'
            : 'Si el animal mantiene el apetito, no presenta fiebre ni decaimiento extremo, puedes aplicar la dieta blanda 24h. Si persiste, agenda cita regular.',
      );
    }

    // ── PATRÓN 3: TOS / RESPIRACIÓN / AHOGO / MOCO ────────────────────────────────
    if (text.contains('tos') || text.contains('respirar') || text.contains('ahogo') || text.contains('moco') || text.contains('tose') || text.contains('pecho')) {
      final isCat = petType.toLowerCase() == 'cat';
      String speciesText = '';
      List<String> differentials = [];
      String risk = 'Medio';

      if (isCat) {
        speciesText = ' En felinos, la tos no suele ser producida por indigestión, sino por reactividad bronquial extrema o asma felino, una emergencia médica.';
        differentials = [
          'Asma bronquial felino (Bronquitis crónica alérgica)',
          'Infección por el virus de la Rinotraqueitis Felina (Herpesvirus)',
          'Bolas de pelo acumuladas en tracto respiratorio superior (diagnóstico por descarte)',
        ];
        risk = 'Alto';
      } else {
        differentials = [
          'Tos de las Perreras (Traqueobronquitis infecciosa canina)',
          'Colapso traqueal leve (Común en razas pequeñas como Chihuahuas o Yorkshires)',
          'Alergia respiratoria ambiental por polvo o polen',
        ];
      }

      return AiDiagnosticReport(
        symptomAnalysis: 'El reporte indica signos de irritación de las vías respiratorias en $petName.$speciesText Es clave diferenciar una tos seca tipo "bocinazo" de una tos productiva con expectoración de moco o espuma blanca.',
        differentialDiagnoses: differentials,
        preventativeCare: [
          'Evitar ambientes con humo de tabaco, aerosoles, polución o perfumes intensos que agraven las vías respiratorias.',
          'Sustituir temporalmente el collar de paseo por un arnés de pecho para evitar presionar la tráquea.',
          'Humidificar el ambiente colocando al animal en el baño mientras se toma una ducha de agua caliente (inhalación de vapor).',
          'Vigilar la frecuencia respiratoria en reposo (no debe superar las 30 respiraciones por minuto en perros/gatos dormidos).',
        ],
        riskLevel: risk,
        recommendedUrgency: risk == 'Alto'
            ? '¡CRÍTICO! Dificultades respiratorias en felinos pueden desembocar en hipoxia. Si $petName respira con la boca abierta, saca la lengua o tiene las encías azuladas, acude a urgencias inmediatamente.'
            : 'Si se sospecha de Tos de las Perreras, es muy contagioso entre canes. Aísla a $petName de otros perros y acude al veterinario para prescribir un jarabe mucolítico.',
      );
    }

    // ── FALLBACK GENERAL ──────────────────────────────────────────────────────────
    return AiDiagnosticReport(
      symptomAnalysis: 'El Asistente IA ha recibido la descripción general de síntomas para $petName ($breed, $ageYears años). Los síntomas descritos no coinciden exactamente con patologías respiratorias, digestivas o articulares agudas comunes de urgencia extrema.',
      differentialDiagnoses: [
        'Malestar general inespecífico o estrés conductual',
        'Fiebre leve o inicio de proceso vírico menor',
        'Picadura de insecto o reacción cutánea leve en fase inicial',
      ],
      preventativeCare: [
        'Vigilar la temperatura corporal de $petName (la temperatura rectal normal de perros/gatos es de 38.0 °C a 39.2 °C).',
        'Asegurar que la mascota tiene acceso continuo a agua fresca y mantiene un rincón tranquilo y templado para descansar.',
        'Hacer un seguimiento de las comidas y comprobar si acepta premios (snacks) con normalidad.',
        'Inspeccionar el cuerpo del animal con un cepillado en busca de parásitos externos (pulgas, garrapatas) o inflamaciones.',
      ],
      riskLevel: 'Bajo',
      recommendedUrgency: 'Vigila la evolución del comportamiento de $petName durante las próximas 24 horas. Si notas pérdida de apetito persistente, desorientación o letargo severo, consulta a tu veterinario de confianza.',
    );
  }
}
