# Configurar Google Sign-In para Android

## 🔑 Tu SHA-1 Fingerprint (Debug):

```
E0:D2:3F:AD:4C:ED:A3:98:EE:2C:DB:38:7C:3F:ED:85:79:11:53:F8
```

## 📦 Nuevo Package Name:

```
com.nachospetcare.app
```

*He cambiado el package name porque el anterior (`com.example.nachos_pet_care_flutter`) ya estaba en uso en otro proyecto.*

---

## Paso 1: Obtener SHA-1 Fingerprint (Ya lo tenemos ✅)

Ya tenemos tu SHA-1. Si necesitas regenerarlo en el futuro:

```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

---

## Paso 2: Configurar en Google Cloud Console

### 2.1 Ir a Google Cloud Console

1. Ve a: https://console.cloud.google.com/
2. Selecciona tu proyecto o crea uno nuevo

### 2.2 Habilitar Google Sign-In API

1. Ve a **APIs & Services → Library**
2. Busca **"Google Sign-In API"** o **"Google+ API"**
3. Haz clic en **Enable**

### 2.3 Crear credenciales OAuth 2.0

1. Ve a **APIs & Services → Credentials**
2. Haz clic en **+ CREATE CREDENTIALS**
3. Selecciona **OAuth client ID**
4. Tipo de aplicación: **Android**
5. Nombre: `NachosPetCare Android`
6. Nombre del paquete: `com.nachospetcare.app`
7. **SHA-1**: `E0:D2:3F:AD:4C:ED:A3:98:EE:2C:DB:38:7C:3F:ED:85:79:11:53:F8`
8. Haz clic en **Create**

### 2.4 Crear credencial Web (importante para Supabase)

1. Haz clic nuevamente en **+ CREATE CREDENTIALS**
2. Selecciona **OAuth client ID**
3. Tipo de aplicación: **Web application**
4. Nombre: `NachosPetCare Web`
5. URIs de redirección autorizados:
   ```
   https://bixmxkhfgrwnubmqaqdj.supabase.co/auth/v1/callback
   ```
6. Haz clic en **Create**
7. **COPIA el Client ID** que aparece (algo como `123456789-abc.apps.googleusercontent.com`)

---

## Paso 3: Descargar google-services.json

### Opción A: Desde Firebase Console (Recomendado)

1. Ve a: https://console.firebase.google.com/
2. Crea un proyecto o usa uno existente
3. Añade una aplicación Android:
   - Nombre del paquete: `com.nachospetcare.app`
   - SHA-1: `E0:D2:3F:AD:4C:ED:A3:98:EE:2C:DB:38:7C:3F:ED:85:79:11:53:F8`
4. **Descarga `google-services.json`**
5. **REEMPLAZA** el archivo existente en:
   ```
   c:\Users\cgonz\Downloads\nachos_pet_care_flutter\android\app\google-services.json
   ```

### Opción B: Desde Google Cloud Console

1. Ve a **APIs & Services → Credentials**
2. Busca tu **OAuth 2.0 Client ID** de Android
3. Descarga el archivo JSON
4. Renómbralo a `google-services.json`
5. Coloca el archivo en:
   ```
   android/app/google-services.json
   ```

---

## Paso 4: Configurar Supabase

1. Ve a tu proyecto en: https://supabase.com/dashboard
2. Ve a **Authentication → Providers → Google**
3. Activa el toggle de **Enable Sign in with Google**
4. Configura:
   - **Client ID (for OAuth)**: El Web Client ID del Paso 2.4
   - **Client Secret (for OAuth)**: El Secret correspondiente
5. Guarda los cambios

---

## Paso 5: Actualizar supabase_config.dart

Abre `lib/config/supabase_config.dart` y actualiza:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://bixmxkhfgrwnubmqaqdj.supabase.co';
  static const String supabaseAnonKey = 'tu-anon-key-aqui';
  
  // Usa el WEB Client ID (no el Android Client ID)
  static const String googleClientId = 'TU_WEB_CLIENT_ID.apps.googleusercontent.com';
  static const String redirectUrl = 'io.supabase.nachospetcare://login-callback/';
}
```

**IMPORTANTE**: Usa el **Web Client ID**, NO el Android Client ID.

---

## Paso 6: Verificar y compilar

```bash
flutter clean
flutter pub get
flutter run
```

---

## Troubleshooting

### Error: "API 10: ApiException"

**Causa**: SHA-1 no configurado correctamente

**Solución**:
1. Verifica que el SHA-1 en Google Cloud Console coincida exactamente con el de tu keystore
2. Espera 5-10 minutos después de añadir el SHA-1
3. Limpia el cache: `flutter clean`

### Error: "sign_in_failed"

**Causa**: Archivo `google-services.json` incorrecto o faltante

**Solución**:
1. Verifica que `android/app/google-services.json` exista
2. Verifica que el `package_name` en el JSON sea `com.nachospetcare.app`
3. Descarga el archivo de nuevo desde Firebase Console

### Error: "DEVELOPER_ERROR"

**Causa**: Client ID incorrecto en `supabase_config.dart`

**Solución**:
1. Asegúrate de usar el **Web Client ID** (no el Android Client ID)
2. Verifica que no haya espacios al inicio o final
3. El formato debe ser: `123456789-abc.apps.googleusercontent.com`

---

## Verificación final

Después de configurar todo:

1. ✅ SHA-1 añadido en Google Cloud Console
2. ✅ Credencial OAuth Android creada
3. ✅ Credencial OAuth Web creada
4. ✅ `google-services.json` en `android/app/`
5. ✅ Google habilitado en Supabase
6. ✅ Web Client ID en `supabase_config.dart`
7. ✅ `flutter clean && flutter pub get`

Ahora el Google Sign-In debería funcionar correctamente! 🎉
