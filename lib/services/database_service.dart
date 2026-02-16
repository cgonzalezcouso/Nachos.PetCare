import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:nachos_pet_care_flutter/models/user.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    try {
      debugPrint('🔧 Inicializando base de datos SQLite...');
      

      
      _database = await _initDatabase();
      debugPrint('✅ Base de datos inicializada correctamente');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al inicializar base de datos: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      debugPrint('📁 Ruta de base de datos: $dbPath');
      final path = join(dbPath, 'nachos_pet_care.db');
      debugPrint('📄 Archivo de base de datos: $path');

      // En escritorio, usamos explícitamente la fábrica FFI
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        final databaseFactory = databaseFactoryFfi;
        return await databaseFactory.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: _onCreate,
          ),
        );
      }
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      debugPrint('❌ Error en _initDatabase: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      debugPrint('🔨 Creando tabla users...');
      // Tabla de usuarios
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

      debugPrint('🔨 Creando tabla pets...');
      // Tabla de mascotas
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
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (ownerId) REFERENCES users (id)
      )
    ''');

      debugPrint('🔨 Creando tabla vaccine_reminders...');
      // Tabla de recordatorios de vacunas
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

      debugPrint('🔨 Creando tabla veterinary_reports...');
      // Tabla de informes veterinarios
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
      
      debugPrint('✅ Todas las tablas creadas exitosamente');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al crear tablas: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
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
}
