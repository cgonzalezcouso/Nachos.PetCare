# NachosPetCare - Flutter

Aplicación multiplataforma para el cuidado de mascotas desarrollada con Flutter.

## Requisitos

- Flutter 3.6.0 o superior
- Dart 3.6.0 o superior
- Android Studio / Xcode (para desarrollo móvil)
- Cuenta de Supabase

## Configuración inicial

### 1. Supabase

Esta aplicación usa Supabase para autenticación y almacenamiento.

#### Crear proyecto en Supabase

1. Ve a [Supabase](https://supabase.com/) y crea una cuenta
2. Crea un nuevo proyecto
3. Copia la **URL** y la **anon key** desde Project Settings > API

#### Configurar la app

Edita `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
  static const String supabaseAnonKey = 'tu-anon-key';
  static const String googleClientId = 'tu-google-client-id.apps.googleusercontent.com';
  static const String redirectUrl = 'io.supabase.nachospetcare://login-callback/';
}
```

### 2. Configurar Google Sign-In

⚠️ **IMPORTANTE**: Google Sign-In requiere configuración específica para Android.

📖 **Guía completa**: Lee el archivo [`CONFIGURAR_GOOGLE_SIGNIN.md`](./CONFIGURAR_GOOGLE_SIGNIN.md) para instrucciones paso a paso.

**Resumen rápido**:

1. Obtén tu SHA-1 fingerprint:
   ```bash
   cd android
   .\gradlew signingReport
   ```

2. Configura credenciales OAuth en [Google Cloud Console](https://console.cloud.google.com/)
   - Crea credencial **Android** con tu SHA-1
   - Crea credencial **Web** para Supabase

3. Descarga `google-services.json` desde [Firebase Console](https://console.firebase.google.com/)
   - Colócalo en: `android/app/google-services.json`

4. Configura en [Supabase](https://supabase.com/dashboard):
   - Habilita Google en Authentication → Providers
   - Usa el **Web Client ID** (no el Android)

5. Actualiza `lib/config/supabase_config.dart` con tu Web Client ID

### 3. Configurar Facebook Login

#### En Facebook Developers

1. Ve a [Facebook Developers](https://developers.facebook.com/)
2. Crea una nueva app
3. Añade el producto "Facebook Login"
4. Configura las URIs de redirección válidas:
   - `https://tu-proyecto.supabase.co/auth/v1/callback`

#### En Supabase

1. Ve a Authentication > Providers > Facebook
2. Habilita Facebook
3. Añade tu App ID y App Secret de Facebook

### 4. Configurar Storage (Buckets)

En Supabase Dashboard > Storage:

1. Crea un bucket llamado `avatars` (público)
2. Crea un bucket llamado `pets` (público)

Políticas de ejemplo para buckets públicos:

```sql
-- Política para subir archivos (usuarios autenticados)
CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id IN ('avatars', 'pets'));

-- Política para lectura pública
CREATE POLICY "Allow public read" ON storage.objects
FOR SELECT TO public
USING (bucket_id IN ('avatars', 'pets'));
```

### 5. Configuración Android

#### `android/app/src/main/AndroidManifest.xml`

Añade dentro de `<activity>`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.nachospetcare" android:host="login-callback" />
</intent-filter>
```

### 6. Configuración iOS

#### `ios/Runner/Info.plist`

Añade:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.nachospetcare</string>
        </array>
    </dict>
</array>
```

## Ejecución

```bash
# Obtener dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Ejecutar para Android específicamente
flutter run -d android

# Ejecutar para iOS específicamente
flutter run -d ios

# Compilar APK para release
flutter build apk --release

# Compilar para iOS (requiere Mac)
flutter build ios --release
```

## Estructura del proyecto

```
lib/
├── config/           # Configuración (tema, rutas, supabase)
├── models/           # Modelos de datos
├── providers/        # State management (Provider)
├── screens/          # Pantallas de la app
│   ├── auth/         # Login, registro
│   ├── home/         # Pantalla principal
│   ├── pets/         # Gestión de mascotas
│   └── profile/      # Perfil de usuario
├── services/         # Servicios (auth, database, storage)
├── widgets/          # Widgets reutilizables
└── main.dart         # Punto de entrada
```

## Funcionalidades

### Gestión de mascotas
- ✅ Autenticación con email/contraseña (Supabase)
- ✅ Login social con Google (Supabase OAuth)
- ✅ Login social con Facebook (Supabase OAuth)
- ✅ Gestión de mascotas (CRUD)
- ✅ Perfil de usuario
- ✅ Base de datos local (SQLite)
- ✅ Almacenamiento de imágenes (Supabase Storage)
- ✅ Soporte para modo oscuro

### Comunidad y Adopción
- ✅ **Animales en adopción**: Encuentra mascotas que buscan un hogar
- ✅ **Artículos sobre adopción responsable**: Guías y consejos para adoptar
- ✅ **Directorio de profesionales**:
  - Veterinarios
  - Adiestradores
  - Nutricionistas
  - Etólogos
  - Peluqueros caninos/felinos
  - Lugares pet friendly

### Próximamente
- 🚧 Recordatorios de vacunas
- 🚧 Historial veterinario
- 🚧 Notificaciones push

## Categorías de mascotas soportadas

La aplicación soporta las siguientes categorías de mascotas:

1. **Perro** - Caninos domésticos
2. **Gato** - Felinos domésticos
3. **Conejo** - Lagomorfos
4. **Roedor** - Hámster, cobaya, rata, ratón, jerbo, chinchilla
5. **Hurón** - Mustélidos domésticos
6. **Ave** - Periquito, canario, ninfa, agapornis, loro
7. **Pez** - Agua dulce o marino
8. **Reptil** - Tortuga, gecko, dragón barbudo, serpiente
9. **Anfibio** - Axolote, rana, tritón
10. **Invertebrado** - Tarántula, mantis, insecto palo, caracol
11. **Animal de corral** - Gallina, pato, cabra, oveja, cerdo
12. **Otro / Exótico** - Cualquier otra especie no categorizada

Cada categoría permite especificar el subtipo o raza en el campo correspondiente.

## Plataformas soportadas

- ✅ Android
- ✅ iOS
- ✅ Web (experimental)
- ✅ Windows
- ✅ macOS
- ✅ Linux
