import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/models/veterinary_report.dart';
import 'package:nachos_pet_care_flutter/models/vaccine_reminder.dart';
import 'package:nachos_pet_care_flutter/models/pet_weight.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';

class PdfService {
  static Future<void> exportMedicalHistoryPdf(BuildContext context, Pet pet) async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final db = getIt<DatabaseService>();

      // Recuperar los datos asíncronamente de la base de datos local
      final List<VeterinaryReport> reports = await db.getVeterinaryReportsByPet(pet.id);
      final List<VaccineReminder> vaccines = await db.getVaccineRemindersByPet(pet.id);
      final List<PetWeight> weights = await db.getPetWeights(pet.id);

      // Crear documento PDF
      final doc = pw.Document();

      // Paleta de Colores Premium
      final primaryColor = PdfColor.fromHex('#2E5A44'); // Verde Bosque Premium
      final secondaryColor = PdfColor.fromHex('#4B5563'); // Gris pizarra
      final accentColor = PdfColor.fromHex('#E6ECE8'); // Gris/verde ultra claro
      final darkText = PdfColor.fromHex('#1F2937'); // Texto oscuro
      final lightText = PdfColor.fromHex('#6B7280'); // Texto secundario
      
      final headerStyle = pw.TextStyle(
        color: primaryColor,
        fontSize: 22,
        fontWeight: pw.FontWeight.bold,
      );

      final sectionTitleStyle = pw.TextStyle(
        color: primaryColor,
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
      );

      final boldLabelStyle = pw.TextStyle(
        color: darkText,
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
      );

      final valueStyle = pw.TextStyle(
        color: secondaryColor,
        fontSize: 9,
      );

      final bodyText = pw.TextStyle(
        color: darkText,
        fontSize: 9,
      );

      final tableHeaderStyle = pw.TextStyle(
        color: PdfColors.white,
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
      );

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            // CABECERA DEL INFORME
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.5),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('INFORME VETERINARIO', style: headerStyle),
                      pw.Text('Historial Clínico Completo', style: pw.TextStyle(color: lightText, fontSize: 11)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Nachos Pet Care', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 13)),
                      pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now()), style: pw.TextStyle(color: lightText, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // TARJETA DE DATOS DE LA MASCOTA
            pw.Container(
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              padding: const pw.EdgeInsets.all(12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Ficha Informativa', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Divider(color: PdfColors.white, thickness: 1, height: 10),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Nombre: ', style: boldLabelStyle), pw.TextSpan(text: pet.name, style: valueStyle)])),
                            pw.SizedBox(height: 4),
                            pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Especie: ', style: boldLabelStyle), pw.TextSpan(text: pet.typeDisplayName, style: valueStyle)])),
                            pw.SizedBox(height: 4),
                            pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Raza: ', style: boldLabelStyle), pw.TextSpan(text: pet.breed?.isNotEmpty == true ? pet.breed! : 'Común / Mezcla', style: valueStyle)])),
                            pw.SizedBox(height: 4),
                            pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Género: ', style: boldLabelStyle), pw.TextSpan(text: pet.gender == PetGender.male ? 'Macho' : pet.gender == PetGender.female ? 'Hembra' : 'Desconocido', style: valueStyle)])),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Edad: ', style: boldLabelStyle), pw.TextSpan(text: pet.ageInYears != null ? '${pet.ageInYears} años' : 'Desconocida', style: valueStyle)])),
                            pw.SizedBox(height: 4),
                            pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Peso Actual: ', style: boldLabelStyle), pw.TextSpan(text: pet.weight != null ? '${pet.weight} kg' : 'No registrado', style: valueStyle)])),
                            pw.SizedBox(height: 4),
                            pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Microchip: ', style: boldLabelStyle), pw.TextSpan(text: pet.microchipNumber?.isNotEmpty == true ? pet.microchipNumber! : 'No registrado', style: valueStyle)])),
                            pw.SizedBox(height: 4),
                            pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Esterilizado/a: ', style: boldLabelStyle), pw.TextSpan(text: pet.isNeutered ? 'Sí' : 'No', style: valueStyle)])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // SECCIÓN: VISITAS VETERINARIAS
            pw.Text('Visitas y Consultas Clínicas', style: sectionTitleStyle),
            pw.SizedBox(height: 6),
            if (reports.isEmpty)
              pw.Text('No hay visitas veterinarias registradas para esta mascota.', style: pw.TextStyle(color: lightText, fontSize: 9, fontStyle: pw.FontStyle.italic))
            else
              pw.Column(
                children: reports.map((r) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(color: PdfColors.green700, width: 2.5),
                      ),
                    ),
                    padding: const pw.EdgeInsets.only(left: 8, top: 2, bottom: 2),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              r.vetName?.isNotEmpty == true ? 'Dr. ${r.vetName}' : 'Consulta Veterinaria',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: darkText, fontSize: 10),
                            ),
                            pw.Text(
                              DateFormat('dd/MM/yyyy · HH:mm').format(r.visitDate),
                              style: pw.TextStyle(color: lightText, fontSize: 8),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 3),
                        if (r.diagnosis?.isNotEmpty == true)
                          pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Diagnóstico: ', style: boldLabelStyle), pw.TextSpan(text: r.diagnosis!, style: bodyText)])),
                        if (r.treatment?.isNotEmpty == true)
                          pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Tratamiento: ', style: boldLabelStyle), pw.TextSpan(text: r.treatment!, style: bodyText)])),
                        if (r.notes?.isNotEmpty == true)
                          pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Notas: ', style: boldLabelStyle), pw.TextSpan(text: r.notes!, style: bodyText)])),
                      ],
                    ),
                  );
                }).toList(),
              ),
            pw.SizedBox(height: 20),

            // SECCIÓN: VACUNAS
            pw.Text('Historial de Vacunación', style: sectionTitleStyle),
            pw.SizedBox(height: 6),
            if (vaccines.isEmpty)
              pw.Text('No hay vacunas registradas para esta mascota.', style: pw.TextStyle(color: lightText, fontSize: 9, fontStyle: pw.FontStyle.italic))
            else
              pw.Table(
                border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                    ),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Vacuna / Enfermedad', style: tableHeaderStyle)),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Fecha / Límite', style: tableHeaderStyle)),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Estado', style: tableHeaderStyle)),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Notas', style: tableHeaderStyle)),
                    ],
                  ),
                  ...vaccines.map((v) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(v.vaccineName, style: bodyText)),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(DateFormat('dd/MM/yyyy').format(v.dueDate), style: bodyText)),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            v.completed ? 'Aplicada' : 'Pendiente',
                            style: pw.TextStyle(
                              color: v.completed ? PdfColors.green700 : PdfColors.amber800,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8.5,
                            ),
                          ),
                        ),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(v.notes?.isNotEmpty == true ? v.notes! : '-', style: bodyText)),
                      ],
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 20),

            // SECCIÓN: HISTORIAL DE PESO
            pw.Text('Evolución de Peso', style: sectionTitleStyle),
            pw.SizedBox(height: 6),
            if (weights.isEmpty)
              pw.Text('No hay registros de peso disponibles.', style: pw.TextStyle(color: lightText, fontSize: 9, fontStyle: pw.FontStyle.italic))
            else
              pw.Table(
                border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Fecha de Medición', style: tableHeaderStyle)),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Peso Registrado (kg)', style: tableHeaderStyle)),
                    ],
                  ),
                  ...weights.map((w) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(DateFormat('dd/MM/yyyy').format(w.date), style: bodyText)),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${w.weight} kg', style: bodyText)),
                      ],
                    );
                  }),
                ],
              ),
          ],
        ),
      );

      // Guardar PDF en directorio temporal
      final tempDir = await getTemporaryDirectory();
      final sanitizedPetName = pet.name.replaceAll(RegExp(r'[^\w]'), '_');
      final filePath = "${tempDir.path}/Historial_$sanitizedPetName.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await doc.save());

      // Cerrar indicador de carga
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Compartir PDF usando share_plus
      final xFile = XFile(filePath);
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [xFile],
        text: 'Historial médico de ${pet.name} - Generado desde Nachos Pet Care.',
        subject: 'Informe Clínico Veterinario - ${pet.name}',
      );

    } catch (e) {
      // Cerrar indicador de carga si sigue abierto
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
