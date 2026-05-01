# Nacho's PetCare 🐾

Aplicación móvil multiplataforma desarrollada con **Flutter (Dart)** para registrar mascotas y gestionar su información sanitaria, recordatorios con notificaciones y centralizar recursos de adopción responsable.

- 📱 **Plataformas**: Android, iOS, Windows
- 🔐 **Autenticación**: Firebase Auth + Google Sign-In
- 💾 **Persistencia**: SQLite (sqflite) + Supabase
- 📊 **Estado**: Provider + GetIt (Dependency Injection)
- 📍 **Navegaci��n**: GoRouter

---

## Índice

- [Resumen](#resumen)
- [Funcionalidades](#funcionalidades)
- [Tecnología](#tecnología)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Requisitos](#requisitos)
- [Instalación y ejecución](#instalación-y-ejecución)
  - [Instalación General](#instalación-general)
  - [Android](#android)
  - [Windows](#windows)
- [Despliegue](#despliegue)
  - [Build Android (APK)](#build-android-apk)
  - [Build Android (App Bundle)](#build-android-app-bundle)
  - [Build Windows](#build-windows)
- [Configuración Firebase (Google Sign-In)](#configuración-firebase-google-sign-in)
- [Variables de entorno](#variables-de-entorno)
- [Permisos y privacidad](#permisos-y-privacidad)
- [Seguridad](#seguridad)
- [Licencia](#licencia)

---

## Resumen

**Nacho's PetCare** es una aplicación completa de gestión de mascotas que permite a los usuarios:

- ✅ Iniciar sesión seguro con Google (**Firebase Auth**)
- ✅ Registrar y gestionar múltiples mascotas con datos completos
- ✅ Guardar información sanitaria: vacunas, enfermedades, historial veterinario
- ✅ Crear recordatorios inteligentes con notificaciones locales
- ✅ Gestionar avisos de mascotas perdidas
- ✅ Acceder a recursos de adopción responsable
- ✅ Consultar directorios de profesionales (veterinarios, adiestradores, etc.)
- ✅ Descubrir sitios pet-friendly

**Especies soportadas:**
Perros, Gatos, Conejos, Roedores (hámster, cobaya, rata, ratón, jerbo, chinchilla), Hurones, Aves (periquitos, canarios, ninfas, agapornis, loros), Peces (agua dulce/marina), Reptiles (tortugas, geckos, dragones)

---

## Funcionalidades

### 🔐 Autenticación y Seguridad
- Login/Logout con Firebase Auth + Google Sign-In
- Gestión segura de sesiones
- Recuperación de contraseña

### 🐾 Gestión de Mascotas
- CRUD completo de mascotas
- Fotos desde cámara/galería
- Datos básicos: nombre, especie, raza, fecha de nacimiento, chip
- Información de contacto de propietarios

### 💊 Salud y Documentación
- Registro de vacunas (con próximas dosis)
- Historial de enfermedades/condiciones
- Historial veterinario (visitas y controles)
- Gestión de informes veterinarios
- Adjuntar/descargar documentos

### 🔔 Recordatorios y Notificaciones
- Crear recordatorios para citas, vacunas, desparasitación
- Notificaciones locales automáticas
- Historial de notificaciones

### 🆘 Funcionalidades Adicionales
- Gestión de mascotas perdidas
- Estado, contacto y ubicación
- Adopción responsable: artículos y guías
- Directorio profesional (veterinarios, adiestradores, etólogos, peluqueros, nutricionistas)
- Sitios pet-friendly

---

## Tecnología

### Frontend
- **Flutter (Dart)** - Framework multiplataforma
- **Material Design** - Interfaz de usuario
- **Provider** - Gestión de estado
- **GetIt** - Inyección de dependencias
- **GoRouter** - Navegación

### Backend y Datos
- **Firebase** - Autenticación y configuración
- **Supabase** - Base de datos en la nube
- **SQLite** (sqflite) - Base de datos local
- **shared_preferences** - Almacenamiento de preferencias

### Librerías Principales
```yaml
# UI
- google_fonts: Fuentes personalizadas
- flutter_svg: Gráficos vectoriales
- cached_network_image: Caché de imágenes

# Autenticación
- google_sign_in: Google Sign-In
- supabase_flutter: Supabase

# Multimedia
- image_picker: Selección de imágenes
- permission_handler: Permisos del sistema
- file_picker: Selección de archivos

# Utilidades
- intl: Internacionalización
- url_launcher: Abrir URLs
- http & dio: Peticiones HTTP
- uuid: Generación de IDs únicos
