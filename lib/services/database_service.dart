import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:nachos_pet_care_flutter/models/user.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/models/vaccine_reminder.dart';
import 'package:nachos_pet_care_flutter/models/veterinary_report.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';


class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError('SQLite no está disponible en web');
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    if (kIsWeb) {
      AppLogger.info('Web: DatabaseService.initialize() omitido');
      return;
    }
    try {
      AppLogger.db('Inicializando base de datos SQLite...');
      _database = await _initDatabase();
      AppLogger.db('Base de datos inicializada correctamente');
    } catch (e, stackTrace) {
      AppLogger.error('Error al inicializar base de datos', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final dbPath = await getDatabasesPath();
      AppLogger.db('Ruta de base de datos: $dbPath');
      final path = join(dbPath, 'nachos_pet_care.db');

      return await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      AppLogger.error('Error en _initDatabase', error: e);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      AppLogger.db('Creando tabla users...');
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          email TEXT NOT NULL,
          name TEXT NOT NULL,
          surname TEXT NOT NULL,
          profilePhotoPath TEXT,
          address TEXT,
          postalCode TEXT,
          city TEXT,
          phone TEXT,
          createdAt INTEGER NOT NULL
        )
      ''');

      AppLogger.db('Creando tabla pets...');
      await db.execute('''
        CREATE TABLE pets (
          id TEXT PRIMARY KEY,
          ownerId TEXT NOT NULL,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          breed TEXT,
          birthDate INTEGER,
          gender TEXT NOT NULL,
          weight REAL,
          photoPath TEXT,
          notes TEXT,
          microchipNumber TEXT,
          isNeutered INTEGER NOT NULL DEFAULT 0,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (ownerId) REFERENCES users (id)
        )
      ''');

      AppLogger.db('Creando tabla vaccine_reminders...');
      await db.execute('''
        CREATE TABLE vaccine_reminders (
          id TEXT PRIMARY KEY,
          petId TEXT NOT NULL,
          vaccineName TEXT NOT NULL,
          dueDate INTEGER NOT NULL,
          notes TEXT,
          completed INTEGER DEFAULT 0,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (petId) REFERENCES pets (id)
        )
      ''');

      AppLogger.db('Creando tabla veterinary_reports...');
      await db.execute('''
        CREATE TABLE veterinary_reports (
          id TEXT PRIMARY KEY,
          petId TEXT NOT NULL,
          visitDate INTEGER NOT NULL,
          vetName TEXT,
          diagnosis TEXT,
          treatment TEXT,
          notes TEXT,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (petId) REFERENCES pets (id)
        )
      ''');
      
      AppLogger.db('Todas las tablas creadas exitosamente');
    } catch (e, stackTrace) {
      AppLogger.error('Error al crear tablas', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.db('Migrando BD de v$oldVersion a v$newVersion...');
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE pets ADD COLUMN microchipNumber TEXT');
      AppLogger.db('Columna microchipNumber añadida a pets');
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE pets ADD COLUMN isNeutered INTEGER NOT NULL DEFAULT 0',
      );
      AppLogger.db('Columna isNeutered añadida a pets');
    }
  }

  // --- Operaciones de Usuario ---

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return User.fromJson(maps.first);
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // --- Operaciones de Mascota ---

  Future<void> insertPet(Pet pet) async {
    final db = await database;
    await db.insert(
      'pets',
      pet.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Pet>> getPetsByOwner(String ownerId) async {
    final db = await database;
    final maps = await db.query(
      'pets',
      where: 'ownerId = ?',
      whereArgs: [ownerId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Pet.fromJson(map)).toList();
  }

  Future<Pet?> getPet(String id) async {
    final db = await database;
    final maps = await db.query(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Pet.fromJson(maps.first);
  }

  Future<void> updatePet(Pet pet) async {
    final db = await database;
    await db.update(
      'pets',
      pet.toJson(),
      where: 'id = ?',
      whereArgs: [pet.id],
    );
  }

  Future<void> deletePet(String id) async {
    final db = await database;
    await db.delete(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Operaciones de Vacunas ---

  Future<void> insertVaccineReminder(VaccineReminder reminder) async {
    final db = await database;
    await db.insert(
      'vaccine_reminders',
      reminder.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VaccineReminder>> getVaccineRemindersByPet(String petId) async {
    final db = await database;
    final maps = await db.query(
      'vaccine_reminders',
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => VaccineReminder.fromJson(map)).toList();
  }

  Future<void> updateVaccineReminder(VaccineReminder reminder) async {
    final db = await database;
    await db.update(
      'vaccine_reminders',
      reminder.toJson(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteVaccineReminder(String id) async {
    final db = await database;
    await db.delete(
      'vaccine_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Operaciones de Historial Veterinario ---

  Future<void> insertVeterinaryReport(VeterinaryReport report) async {
    final db = await database;
    await db.insert(
      'veterinary_reports',
      report.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VeterinaryReport>> getVeterinaryReportsByPet(String petId) async {
    final db = await database;
    final maps = await db.query(
      'veterinary_reports',
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'visitDate DESC',
    );
    return maps.map((map) => VeterinaryReport.fromJson(map)).toList();
  }

  Future<void> updateVeterinaryReport(VeterinaryReport report) async {
    final db = await database;
    await db.update(
      'veterinary_reports',
      report.toJson(),
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  Future<void> deleteVeterinaryReport(String id) async {
    final db = await database;
    await db.delete(
      'veterinary_reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

