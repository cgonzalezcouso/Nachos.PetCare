class SupabaseConfig {
  // Reemplaza estos valores con los de tu proyecto Supabase
  static const String supabaseUrl = 'https://bixmxkhfgrwnubmqaqdj.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpeG14a2hmZ3J3bnVibXFhcWRqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAzMjgyOTAsImV4cCI6MjA4NTkwNDI5MH0.fxS3Bg5-aIs-eGTm_JeZ89-06LjdQqWuYOLwautIoi4';
  
  // Configuración de OAuth - Client IDs de google-services.json
  static const String googleWebClientId = '222665857066-j80d6uuojqo7hvif9qmehab3up7tjbsk.apps.googleusercontent.com';  // Web Client ID (para Supabase)
  static const String googleAndroidClientId = '222665857066-81jhtj4cjfh5s4tppp3k34qj32v04ri9.apps.googleusercontent.com';  // Android Client ID
  static const String redirectUrl = 'io.supabase.nachospetcare://login-callback';
}
