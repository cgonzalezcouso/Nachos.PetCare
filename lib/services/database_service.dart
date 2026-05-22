import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:nachos_pet_care_flutter/models/user.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/models/vaccine_reminder.dart';
import 'package:nachos_pet_care_flutter/models/veterinary_report.dart';
import 'package:nachos_pet_care_flutter/models/reminder.dart';
import 'package:nachos_pet_care_flutter/models/pet_photo.dart';
import 'package:nachos_pet_care_flutter/models/pet_weight.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

class DatabaseService {
  static Database? _database;
  static const int _version = 6;

  // In-memory simulated storage for Web
  final Map<String, User> _webUsers = {};
  final Map<String, Pet> _webPets = {};
  final Map<String, VaccineReminder> _webVaccines = {};
  final Map<String, VeterinaryReport> _webReports = {};
  final Map<String, Reminder> _webReminders = {};
  final Map<String, PetPhoto> _webPhotos = {};
  final Map<String, PetWeight> _webWeights = {};

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
        version: _version,
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
      AppLogger.db('Creando tablas iniciales...');
      
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
      
      await db.execute('''
        CREATE TABLE reminders (
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          title TEXT NOT NULL,
          dueDate INTEGER NOT NULL,
          notes TEXT,
          completed INTEGER NOT NULL DEFAULT 0,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE pet_photos (
          id TEXT PRIMARY KEY,
          petId TEXT NOT NULL,
          photoPath TEXT NOT NULL,
          date INTEGER NOT NULL,
          notes TEXT,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE pet_weights (
          id TEXT PRIMARY KEY,
          petId TEXT NOT NULL,
          weight REAL NOT NULL,
          date INTEGER NOT NULL,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
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
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE pets ADD COLUMN isNeutered INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reminders (
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          title TEXT NOT NULL,
          dueDate INTEGER NOT NULL,
          notes TEXT,
          completed INTEGER NOT NULL DEFAULT 0,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id)
        )
      ''');
      AppLogger.db('Tabla reminders creada');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pet_photos (
          id TEXT PRIMARY KEY,
          petId TEXT NOT NULL,
          photoPath TEXT NOT NULL,
          date INTEGER NOT NULL,
          notes TEXT,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
        )
      ''');
      AppLogger.db('Tabla pet_photos creada en migración v5');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pet_weights (
          id TEXT PRIMARY KEY,
          petId TEXT NOT NULL,
          weight REAL NOT NULL,
          date INTEGER NOT NULL,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
        )
      ''');
      AppLogger.db('Tabla pet_weights creada en migración v6');
    }
  }


  // --- Operaciones de Usuario ---

  Future<void> insertUser(User user) async {
    if (kIsWeb) {
      _webUsers[user.id] = user;
      return;
    }
    final db = await database;
    await db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUser(String id) async {
    if (kIsWeb) {
      return _webUsers[id];
    }
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return User.fromJson(maps.first);
  }

  Future<void> updateUser(User user) async {
    if (kIsWeb) {
      _webUsers[user.id] = user;
      return;
    }
    final db = await database;
    await db.update('users', user.toJson(), where: 'id = ?', whereArgs: [user.id]);
  }

  // --- Operaciones de Mascota ---

  Future<void> insertPet(Pet pet) async {
    if (kIsWeb) {
      _webPets[pet.id] = pet;
      return;
    }
    final db = await database;
    await db.insert('pets', pet.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Pet>> getPetsByOwner(String ownerId) async {
    if (kIsWeb) {
      final petsList = _webPets.values.where((p) => p.ownerId == ownerId).toList();
      petsList.sort((a, b) => a.name.compareTo(b.name));
      return petsList;
    }
    final db = await database;
    final maps = await db.query('pets', where: 'ownerId = ?', whereArgs: [ownerId], orderBy: 'name ASC');
    return maps.map((map) => Pet.fromJson(map)).toList();
  }

  Future<Pet?> getPet(String id) async {
    if (kIsWeb) {
      return _webPets[id];
    }
    final db = await database;
    final maps = await db.query('pets', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Pet.fromJson(maps.first);
  }

  Future<void> updatePet(Pet pet) async {
    if (kIsWeb) {
      _webPets[pet.id] = pet;
      return;
    }
    final db = await database;
    await db.update('pets', pet.toJson(), where: 'id = ?', whereArgs: [pet.id]);
  }

  Future<void> deletePet(String id) async {
    if (kIsWeb) {
      _webPets.remove(id);
      _webVaccines.removeWhere((_, v) => v.petId == id);
      _webReports.removeWhere((_, r) => r.petId == id);
      _webPhotos.removeWhere((_, p) => p.petId == id);
      _webWeights.removeWhere((_, w) => w.petId == id);
      return;
    }
    final db = await database;
    await db.delete('pets', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operaciones de Vacunas ---

  Future<void> insertVaccineReminder(VaccineReminder reminder) async {
    if (kIsWeb) {
      _webVaccines[reminder.id] = reminder;
      return;
    }
    final db = await database;
    await db.insert('vaccine_reminders', reminder.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<VaccineReminder>> getVaccineRemindersByPet(String petId) async {
    if (kIsWeb) {
      final list = _webVaccines.values.where((v) => v.petId == petId).toList();
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return list;
    }
    final db = await database;
    final maps = await db.query('vaccine_reminders', where: 'petId = ?', whereArgs: [petId], orderBy: 'dueDate ASC');
    return maps.map((map) => VaccineReminder.fromJson(map)).toList();
  }

  Future<void> updateVaccineReminder(VaccineReminder reminder) async {
    if (kIsWeb) {
      _webVaccines[reminder.id] = reminder;
      return;
    }
    final db = await database;
    await db.update('vaccine_reminders', reminder.toJson(), where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<void> deleteVaccineReminder(String id) async {
    if (kIsWeb) {
      _webVaccines.remove(id);
      return;
    }
    final db = await database;
    await db.delete('vaccine_reminders', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operaciones de Historial Veterinario ---

  Future<void> insertVeterinaryReport(VeterinaryReport report) async {
    if (kIsWeb) {
      _webReports[report.id] = report;
      return;
    }
    final db = await database;
    await db.insert('veterinary_reports', report.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<VeterinaryReport>> getVeterinaryReportsByPet(String petId) async {
    if (kIsWeb) {
      final list = _webReports.values.where((r) => r.petId == petId).toList();
      list.sort((a, b) => b.visitDate.compareTo(a.visitDate));
      return list;
    }
    final db = await database;
    final maps = await db.query('veterinary_reports', where: 'petId = ?', whereArgs: [petId], orderBy: 'visitDate DESC');
    return maps.map((map) => VeterinaryReport.fromJson(map)).toList();
  }

  Future<void> updateVeterinaryReport(VeterinaryReport report) async {
    if (kIsWeb) {
      _webReports[report.id] = report;
      return;
    }
    final db = await database;
    await db.update('veterinary_reports', report.toJson(), where: 'id = ?', whereArgs: [report.id]);
  }

  Future<void> deleteVeterinaryReport(String id) async {
    if (kIsWeb) {
      _webReports.remove(id);
      return;
    }
    final db = await database;
    await db.delete('veterinary_reports', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operaciones de Recordatorios ---

  Future<List<Reminder>> getRemindersByUser(String userId) async {
    if (kIsWeb) {
      final list = _webReminders.values.where((r) => r.userId == userId).toList();
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return list;
    }
    final db = await database;
    final maps = await db.query('reminders', where: 'userId = ?', whereArgs: [userId], orderBy: 'dueDate ASC');
    return maps.map((map) => Reminder.fromJson(map)).toList();
  }

  Future<void> insertReminder(Reminder reminder) async {
    if (kIsWeb) {
      _webReminders[reminder.id] = reminder;
      return;
    }
    final db = await database;
    await db.insert('reminders', reminder.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateReminder(Reminder reminder) async {
    if (kIsWeb) {
      _webReminders[reminder.id] = reminder;
      return;
    }
    final db = await database;
    await db.update('reminders', reminder.toJson(), where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<void> deleteReminder(String id) async {
    if (kIsWeb) {
      _webReminders.remove(id);
      return;
    }
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operaciones de Galería de Fotos ---

  Future<void> insertPetPhoto(PetPhoto photo) async {
    if (kIsWeb) {
      _webPhotos[photo.id] = photo;
      return;
    }
    final db = await database;
    await db.insert('pet_photos', photo.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PetPhoto>> getPetPhotos(String petId) async {
    if (kIsWeb) {
      final list = _webPhotos.values.where((p) => p.petId == petId).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }
    final db = await database;
    final maps = await db.query('pet_photos', where: 'petId = ?', whereArgs: [petId], orderBy: 'date DESC');
    return maps.map((map) => PetPhoto.fromJson(map)).toList();
  }

  Future<void> deletePetPhoto(String id) async {
    if (kIsWeb) {
      _webPhotos.remove(id);
      return;
    }
    final db = await database;
    await db.delete('pet_photos', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operaciones de Registro de Peso ---

  Future<void> insertPetWeight(PetWeight weight) async {
    if (kIsWeb) {
      _webWeights[weight.id] = weight;
      return;
    }
    final db = await database;
    await db.insert('pet_weights', weight.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PetWeight>> getPetWeights(String petId) async {
    if (kIsWeb) {
      final list = _webWeights.values.where((w) => w.petId == petId).toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    }
    final db = await database;
    final maps = await db.query('pet_weights', where: 'petId = ?', whereArgs: [petId], orderBy: 'date ASC');
    return maps.map((map) => PetWeight.fromJson(map)).toList();
  }

  Future<void> deletePetWeight(String id) async {
    if (kIsWeb) {
      _webWeights.remove(id);
      return;
    }
    final db = await database;
    await db.delete('pet_weights', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operaciones de Límite de Eventos ---

  Future<int> getPetEventCount(String petId) async {
    if (kIsWeb) {
      final vaccinesCount = _webVaccines.values.where((v) => v.petId == petId).length;
      final reportsCount = _webReports.values.where((r) => r.petId == petId).length;
      final weightsCount = _webWeights.values.where((w) => w.petId == petId).length;
      final photosCount = _webPhotos.values.where((p) => p.petId == petId).length;
      return vaccinesCount + reportsCount + weightsCount + photosCount;
    }
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> vRes = await db.rawQuery('SELECT COUNT(*) as count FROM vaccine_reminders WHERE petId = ?', [petId]);
      final vaccinesCount = vRes.isNotEmpty ? (vRes.first['count'] as int? ?? 0) : 0;
      
      final List<Map<String, dynamic>> rRes = await db.rawQuery('SELECT COUNT(*) as count FROM veterinary_reports WHERE petId = ?', [petId]);
      final reportsCount = rRes.isNotEmpty ? (rRes.first['count'] as int? ?? 0) : 0;
      
      final List<Map<String, dynamic>> wRes = await db.rawQuery('SELECT COUNT(*) as count FROM pet_weights WHERE petId = ?', [petId]);
      final weightsCount = wRes.isNotEmpty ? (wRes.first['count'] as int? ?? 0) : 0;
      
      final List<Map<String, dynamic>> pRes = await db.rawQuery('SELECT COUNT(*) as count FROM pet_photos WHERE petId = ?', [petId]);
      final photosCount = pRes.isNotEmpty ? (pRes.first['count'] as int? ?? 0) : 0;
      
      final total = vaccinesCount + reportsCount + weightsCount + photosCount;
      AppLogger.info('Database: Total de eventos históricos para la mascota $petId = $total (vacunas: $vaccinesCount, visitas: $reportsCount, pesos: $weightsCount, fotos: $photosCount)');
      return total;
    } catch (e) {
      AppLogger.error('Error al obtener recuento de eventos para $petId', error: e);
      return 0;
    }
  }
}


