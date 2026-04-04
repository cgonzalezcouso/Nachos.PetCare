import 'package:flutter/material.dart';


class AppStrings {
  final Locale locale;
  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        AppStrings(const Locale('es'));
  }

  T _t<T>(Map<String, T> map) =>
      map[locale.languageCode] ?? map['es']!;

  // ── Navegación ─────────────────────────────────────────────────────────────
  String get navHome => _t({'es': 'Inicio', 'en': 'Home', 'ca': 'Inici', 'fr': 'Accueil', 'de': 'Start', 'pt': 'Início'});
  String get navPets => _t({'es': 'Mascotas', 'en': 'Pets', 'ca': 'Mascotes', 'fr': 'Animaux', 'de': 'Haustiere', 'pt': 'Animais'});
  String get navReminders => _t({'es': 'Recordatorios', 'en': 'Reminders', 'ca': 'Recordatoris', 'fr': 'Rappels', 'de': 'Erinnerungen', 'pt': 'Lembretes'});
  String get navMore => _t({'es': 'Más', 'en': 'More', 'ca': 'Més', 'fr': 'Plus', 'de': 'Mehr', 'pt': 'Mais'});

  // ── Home ───────────────────────────────────────────────────────────────────
  String get welcome => _t({'es': '¡Hola', 'en': 'Hello', 'ca': 'Hola', 'fr': 'Bonjour', 'de': 'Hallo', 'pt': 'Olá'});
  String get welcomeSub => _t({'es': 'Bienvenido a NachosPetCare', 'en': 'Welcome to NachosPetCare', 'ca': 'Benvingut a NachosPetCare', 'fr': 'Bienvenue sur NachosPetCare', 'de': 'Willkommen bei NachosPetCare', 'pt': 'Bem-vindo ao NachosPetCare'});
  String get quickActions => _t({'es': 'Acciones rápidas', 'en': 'Quick actions', 'ca': 'Accions ràpides', 'fr': 'Actions rapides', 'de': 'Schnellaktionen', 'pt': 'Ações rápidas'});
  String get myPets => _t({'es': 'Mis mascotas', 'en': 'My pets', 'ca': 'Les meves mascotes', 'fr': 'Mes animaux', 'de': 'Meine Tiere', 'pt': 'Meus animais'});
  String get veterinarian => _t({'es': 'Veterinario', 'en': 'Vet', 'ca': 'Veterinari', 'fr': 'Vétérinaire', 'de': 'Tierarzt', 'pt': 'Veterinário'});
  String get vaccines => _t({'es': 'Vacunas', 'en': 'Vaccines', 'ca': 'Vacunes', 'fr': 'Vaccins', 'de': 'Impfungen', 'pt': 'Vacinas'});
  String get appointments => _t({'es': 'Citas', 'en': 'Appointments', 'ca': 'Cites', 'fr': 'Rendez-vous', 'de': 'Termine', 'pt': 'Consultas'});

  // ── Mascotas ───────────────────────────────────────────────────────────────
  String get noPetsRegistered => _t({'es': 'No tienes mascotas registradas', 'en': 'No pets registered', 'ca': 'No tens mascotes registrades', 'fr': 'Aucun animal enregistré', 'de': 'Keine Haustiere registriert', 'pt': 'Nenhum animal registrado'});
  String get addPet => _t({'es': 'Añadir mascota', 'en': 'Add pet', 'ca': 'Afegir mascota', 'fr': 'Ajouter un animal', 'de': 'Tier hinzufügen', 'pt': 'Adicionar animal'});

  // ── Comunidad (Más) ────────────────────────────────────────────────────────
  String get community => _t({'es': 'Comunidad', 'en': 'Community', 'ca': 'Comunitat', 'fr': 'Communauté', 'de': 'Community', 'pt': 'Comunidade'});
  String get adoptionAnimals => _t({'es': 'Animales en Adopción', 'en': 'Pets for Adoption', 'ca': 'Animals en Adopció', 'fr': 'Animaux à Adopter', 'de': 'Tiere zur Adoption', 'pt': 'Animais para Adoção'});
  String get adoptionSub => _t({'es': 'Encuentra tu nuevo compañero', 'en': 'Find your new companion', 'ca': 'Troba el teu nou company', 'fr': 'Trouvez votre nouveau compagnon', 'de': 'Finde deinen neuen Begleiter', 'pt': 'Encontre seu novo companheiro'});
  String get articles => _t({'es': 'Artículos sobre Adopción', 'en': 'Adoption Articles', 'ca': 'Articles sobre Adopció', 'fr': 'Articles sur l\'Adoption', 'de': 'Adoptionsartikel', 'pt': 'Artigos sobre Adoção'});
  String get articlesSub => _t({'es': 'Aprende sobre adopción responsable', 'en': 'Learn about responsible adoption', 'ca': 'Aprèn sobre adopció responsable', 'fr': 'Apprenez l\'adoption responsable', 'de': 'Lernen Sie über verantwortliche Adoption', 'pt': 'Aprenda sobre adoção responsável'});
  String get directory => _t({'es': 'Directorio de Profesionales', 'en': 'Professionals Directory', 'ca': 'Directori de Professionals', 'fr': 'Annuaire des Professionnels', 'de': 'Fachleute-Verzeichnis', 'pt': 'Diretório de Profissionais'});
  String get directorySub => _t({'es': 'Veterinarios, adiestradores, peluqueros y más', 'en': 'Vets, trainers, groomers and more', 'ca': 'Veterinaris, entrenadors, perruquers i més', 'fr': 'Vétérinaires, dresseurs, toiletteurs et plus', 'de': 'Tierärzte, Trainer, Groom er und mehr', 'pt': 'Veterinários, adestrados, tosadores e mais'});

  // ── Configuración ──────────────────────────────────────────────────────────
  String get settings => _t({'es': 'Configuración', 'en': 'Settings', 'ca': 'Configuració', 'fr': 'Paramètres', 'de': 'Einstellungen', 'pt': 'Configurações'});
  String get appearance => _t({'es': 'Apariencia', 'en': 'Appearance', 'ca': 'Aparença', 'fr': 'Apparence', 'de': 'Erscheinungsbild', 'pt': 'Aparência'});
  String get appTheme => _t({'es': 'Tema de la aplicación', 'en': 'App theme', 'ca': 'Tema de l\'aplicació', 'fr': 'Thème de l\'application', 'de': 'App-Design', 'pt': 'Tema do aplicativo'});
  String get darkModeActive => _t({'es': 'Modo oscuro activo', 'en': 'Dark mode active', 'ca': 'Mode fosc actiu', 'fr': 'Mode sombre actif', 'de': 'Dunkelmodus aktiv', 'pt': 'Modo escuro ativo'});
  String get lightModeActive => _t({'es': 'Modo claro activo', 'en': 'Light mode active', 'ca': 'Mode clar actiu', 'fr': 'Mode clair actif', 'de': 'Hellmodus aktiv', 'pt': 'Modo claro ativo'});
  String get followSystem => _t({'es': 'Sigue al sistema', 'en': 'Follow system', 'ca': 'Segueix el sistema', 'fr': 'Suivre le système', 'de': 'System folgen', 'pt': 'Seguir sistema'});
  String get themeLight => _t({'es': 'Claro', 'en': 'Light', 'ca': 'Clar', 'fr': 'Clair', 'de': 'Hell', 'pt': 'Claro'});
  String get themeDark => _t({'es': 'Oscuro', 'en': 'Dark', 'ca': 'Fosc', 'fr': 'Sombre', 'de': 'Dunkel', 'pt': 'Escuro'});
  String get themeSystem => _t({'es': 'Sistema', 'en': 'System', 'ca': 'Sistema', 'fr': 'Système', 'de': 'System', 'pt': 'Sistema'});
  String get notifications => _t({'es': 'Notificaciones', 'en': 'Notifications', 'ca': 'Notificacions', 'fr': 'Notifications', 'de': 'Benachrichtigungen', 'pt': 'Notificações'});
  String get pushNotifications => _t({'es': 'Notificaciones push', 'en': 'Push notifications', 'ca': 'Notificacions push', 'fr': 'Notifications push', 'de': 'Push-Benachrichtigungen', 'pt': 'Notificações push'});
  String get notificationsSub => _t({'es': 'Recibir alertas y recordatorios', 'en': 'Receive alerts and reminders', 'ca': 'Rebre alertes i recordatoris', 'fr': 'Recevoir des alertes et rappels', 'de': 'Benachrichtigungen erhalten', 'pt': 'Receber alertas e lembretes'});
  String get account => _t({'es': 'Cuenta', 'en': 'Account', 'ca': 'Compte', 'fr': 'Compte', 'de': 'Konto', 'pt': 'Conta'});
  String get privacySecurity => _t({'es': 'Privacidad y Seguridad', 'en': 'Privacy & Security', 'ca': 'Privacitat i Seguretat', 'fr': 'Confidentialité et Sécurité', 'de': 'Datenschutz & Sicherheit', 'pt': 'Privacidade e Segurança'});
  String get language => _t({'es': 'Idioma', 'en': 'Language', 'ca': 'Idioma', 'fr': 'Langue', 'de': 'Sprache', 'pt': 'Idioma'});
  String get info => _t({'es': 'Información', 'en': 'Information', 'ca': 'Informació', 'fr': 'Informations', 'de': 'Informationen', 'pt': 'Informações'});
  String get about => _t({'es': 'Sobre NachosPetCare', 'en': 'About NachosPetCare', 'ca': 'Sobre NachosPetCare', 'fr': 'À propos de NachosPetCare', 'de': 'Über NachosPetCare', 'pt': 'Sobre NachosPetCare'});
  String get terms => _t({'es': 'Términos y Condiciones', 'en': 'Terms & Conditions', 'ca': 'Termes i Condicions', 'fr': 'Conditions Générales', 'de': 'AGB', 'pt': 'Termos e Condições'});

  // ── Recordatorios ──────────────────────────────────────────────────────────
  String get noReminders => _t({'es': 'No hay recordatorios pendientes', 'en': 'No pending reminders', 'ca': 'No hi ha recordatoris pendents', 'fr': 'Aucun rappel en attente', 'de': 'Keine ausstehenden Erinnerungen', 'pt': 'Nenhum lembrete pendente'});

  // ── General ────────────────────────────────────────────────────────────────
  String get save => _t({'es': 'Guardar', 'en': 'Save', 'ca': 'Desar', 'fr': 'Enregistrer', 'de': 'Speichern', 'pt': 'Salvar'});
  String get cancel => _t({'es': 'Cancelar', 'en': 'Cancel', 'ca': 'Cancel·lar', 'fr': 'Annuler', 'de': 'Abbrechen', 'pt': 'Cancelar'});
  String get back => _t({'es': 'Volver', 'en': 'Back', 'ca': 'Tornar', 'fr': 'Retour', 'de': 'Zurück', 'pt': 'Voltar'});
}

// ─── Delegate para el localizador de Flutter ──────────────────────────────────

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  static const supportedLocales = [
    Locale('es'),
    Locale('en'),
    Locale('ca'),
    Locale('fr'),
    Locale('de'),
    Locale('pt'),
  ];

  @override
  bool isSupported(Locale locale) =>
      supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(AppStringsDelegate old) => false;
}
