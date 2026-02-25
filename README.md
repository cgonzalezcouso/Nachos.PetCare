# Nacho’s PetCare 🐾 (Nachos.PetCare)

Aplicación Android desarrollada con **Flutter (Dart)** para registrar mascotas y su información sanitaria, gestionar recordatorios con notificaciones y centralizar recursos (adopción responsable, directorio profesional, sitios pet-friendly).

- Repositorio: https://github.com/cgonzalezcouso/Nachos.PetCare
- Autenticación: **Firebase Auth + Google Sign-In**
- Persistencia local: **SQLite (sqflite)**

---

## Índice
- [Resumen](#resumen)
- [Funcionalidades](#funcionalidades)
- [Tecnología](#tecnología)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Requisitos](#requisitos)
- [Instalación y ejecución](#instalación-y-ejecución)
- [Configuración Firebase (Google Sign-In)](#configuración-firebase-google-sign-in)
- [Base de datos (borrador)](#base-de-datos-borrador)
- [Planificación (GitHub Projects)](#planificación-github-projects)
- [Documentación](#documentación)
- [Permisos y privacidad](#permisos-y-privacidad)
- [Licencia](#licencia)

---

## Resumen
**Nacho’s PetCare** permite a los usuarios:
- Iniciar sesión con Google (**Firebase Auth**).
- Añadir y gestionar **mascotas** con datos básicos (especie, nombre, foto, chip…).
- Guardar información sanitaria: **vacunas**, **enfermedades/condiciones**, **historial veterinario** e **informes**.
- Crear **recordatorios** (citas, vacunas, desparasitación) con **notificaciones**.
- Gestionar un **aviso de mascota perdida**.
- Consultar recursos: **adopción responsable**, directorio de profesionales y sitios **pet-friendly**.

**Especies soportadas** (catálogo):
Perro, Gato, Conejo, Roedor (hámster, cobaya, rata, ratón, jerbo, chinchilla), Hurón, Ave (periquito, canario, ninfa, agapornis, loro), Pez (agua dulce / marino), Reptil (tortuga, gecko, dragón barbudo, serpiente), Anfibio (axolote, rana, tritón), Invertebrado (tarántula, mantis, insecto palo, caracol), Animal de corral (gallina, pato, cabra/oveja, cerdo), Otro/Exótico (texto libre + aviso legal).

---

## Funcionalidades
### Núcleo
- ✅ Login/Logout con **Firebase Auth + Google Sign-In**
- ✅ CRUD de mascotas
- ✅ Persistencia local con **SQLite**
- ✅ Fotos desde cámara/galería
- ✅ Notificaciones locales para recordatorios

### Salud y documentación
- Vacunas: registro y próxima dosis
- Enfermedades/condiciones: diagnóstico + notas
- Historial veterinario: visitas y controles
- Informes veterinarios: adjuntar/gestionar documentos (local)

### Extra
- Mascota perdida: estado + contacto + ubicación (si aplica)
- Adopción responsable: listados/artículos
- Directorio: veterinarios, adiestradores, etólogos, peluqueros, nutricionistas…
- Sitios pet-friendly

---

## Tecnología
- **Flutter (Dart)**
- Android (Kotlin/AndroidX)
- **Firebase** (Auth + configuración Android)
- **SQLite** (`sqflite`)
- Preferencias (`shared_preferences`)
- Permisos (p. ej. `permission_handler`)
- Multimedia (p. ej. `image_picker`)
- Utilidades (`path_provider`, `url_launcher`)
- Notificaciones (p. ej. `flutter_local_notifications`)

> Paquetes exactos en `pubspec.yaml`.

---

## Estructura del repositorio
```text
.vscode/
android/
assets/
docs/
ios/
lib/
linux/
macos/
test/
web/
windows/
pubspec.yaml
