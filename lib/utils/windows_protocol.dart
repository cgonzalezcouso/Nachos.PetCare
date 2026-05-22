import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

/// Registra el esquema de URI personalizado en el Registro de Windows
/// para que el sistema operativo sepa cómo redirigir los enlaces de autenticación
/// de vuelta a la aplicación.
Future<void> registerCustomSchemeWindows() async {
  if (kIsWeb || !Platform.isWindows) return;

  final logFile = File('c:\\Users\\cgonz\\Downloads\\nachos_pet_care_flutter\\protocol_register.log');
  await logFile.writeAsString('Iniciando registro de protocolo Windows...\n');

  try {
    final exePath = Platform.resolvedExecutable;
    const scheme = 'io.supabase.nachospetcare';
    
    await logFile.writeAsString('Executable path: $exePath\n', mode: FileMode.append);

    // 1. Crear la clave del protocolo
    final regKeyResult = await Process.run('reg', [
      'add',
      'HKCU\\Software\\Classes\\$scheme',
      '/v',
      'URL Protocol',
      '/t',
      'REG_SZ',
      '/d',
      '',
      '/f'
    ]);

    await logFile.writeAsString('RegKey result: exit=${regKeyResult.exitCode}, stdout=${regKeyResult.stdout}, stderr=${regKeyResult.stderr}\n', mode: FileMode.append);

    if (regKeyResult.exitCode != 0) {
      AppLogger.warn('Error al registrar URL Protocol: ${regKeyResult.stderr}');
      return;
    }

    // 2. Establecer el comando para abrir el ejecutable con el argumento URL
    final regCmdResult = await Process.run('reg', [
      'add',
      'HKCU\\Software\\Classes\\$scheme\\shell\\open\\command',
      '/ve',
      '/t',
      'REG_SZ',
      '/d',
      '"$exePath" "%1"',
      '/f'
    ]);

    await logFile.writeAsString('RegCmd result: exit=${regCmdResult.exitCode}, stdout=${regCmdResult.stdout}, stderr=${regCmdResult.stderr}\n', mode: FileMode.append);

    if (regCmdResult.exitCode != 0) {
      AppLogger.warn('Error al registrar el comando de apertura: ${regCmdResult.stderr}');
      return;
    }

    AppLogger.info('Esquema de protocolo Windows registrado correctamente en el Registro de Usuario.');
  } catch (e, stackTrace) {
    await logFile.writeAsString('Excepción: $e\n$stackTrace\n', mode: FileMode.append);
    AppLogger.error('Excepción al intentar registrar el esquema de protocolo en Windows', error: e, stackTrace: stackTrace);
  }
}
