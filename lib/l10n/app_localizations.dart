import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt')
  ];

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navPets.
  ///
  /// In es, this message translates to:
  /// **'Mascotas'**
  String get navPets;

  /// No description provided for @navReminders.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios'**
  String get navReminders;

  /// No description provided for @navMore.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get navMore;

  /// No description provided for @welcome.
  ///
  /// In es, this message translates to:
  /// **'¡Hola'**
  String get welcome;

  /// No description provided for @welcomeSub.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a NachosPetCare'**
  String get welcomeSub;

  /// No description provided for @quickActions.
  ///
  /// In es, this message translates to:
  /// **'Acciones rápidas'**
  String get quickActions;

  /// No description provided for @myPets.
  ///
  /// In es, this message translates to:
  /// **'Mis mascotas'**
  String get myPets;

  /// No description provided for @veterinarian.
  ///
  /// In es, this message translates to:
  /// **'Veterinario'**
  String get veterinarian;

  /// No description provided for @vaccines.
  ///
  /// In es, this message translates to:
  /// **'Vacunas'**
  String get vaccines;

  /// No description provided for @appointments.
  ///
  /// In es, this message translates to:
  /// **'Citas'**
  String get appointments;

  /// No description provided for @noPetsRegistered.
  ///
  /// In es, this message translates to:
  /// **'No tienes mascotas registradas'**
  String get noPetsRegistered;

  /// No description provided for @addPet.
  ///
  /// In es, this message translates to:
  /// **'Añadir mascota'**
  String get addPet;

  /// No description provided for @community.
  ///
  /// In es, this message translates to:
  /// **'Comunidad'**
  String get community;

  /// No description provided for @adoptionAnimals.
  ///
  /// In es, this message translates to:
  /// **'Animales en Adopción'**
  String get adoptionAnimals;

  /// No description provided for @adoptionSub.
  ///
  /// In es, this message translates to:
  /// **'Encuentra tu nuevo compañero'**
  String get adoptionSub;

  /// No description provided for @articles.
  ///
  /// In es, this message translates to:
  /// **'Artículos sobre Adopción'**
  String get articles;

  /// No description provided for @articlesSub.
  ///
  /// In es, this message translates to:
  /// **'Aprende sobre adopción responsable'**
  String get articlesSub;

  /// No description provided for @directory.
  ///
  /// In es, this message translates to:
  /// **'Directorio de Profesionales'**
  String get directory;

  /// No description provided for @directorySub.
  ///
  /// In es, this message translates to:
  /// **'Veterinarios, adiestradores, peluqueros y más'**
  String get directorySub;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @appTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema de la aplicación'**
  String get appTheme;

  /// No description provided for @darkModeActive.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro activo'**
  String get darkModeActive;

  /// No description provided for @lightModeActive.
  ///
  /// In es, this message translates to:
  /// **'Modo claro activo'**
  String get lightModeActive;

  /// No description provided for @followSystem.
  ///
  /// In es, this message translates to:
  /// **'Sigue al sistema'**
  String get followSystem;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones push'**
  String get pushNotifications;

  /// No description provided for @notificationsSub.
  ///
  /// In es, this message translates to:
  /// **'Recibir alertas y recordatorios'**
  String get notificationsSub;

  /// No description provided for @account.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get account;

  /// No description provided for @privacySecurity.
  ///
  /// In es, this message translates to:
  /// **'Privacidad y Seguridad'**
  String get privacySecurity;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @info.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get info;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Sobre NachosPetCare'**
  String get about;

  /// No description provided for @terms.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get terms;

  /// No description provided for @noReminders.
  ///
  /// In es, this message translates to:
  /// **'No hay recordatorios pendientes'**
  String get noReminders;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @priorityPet.
  ///
  /// In es, this message translates to:
  /// **'Mascota Prioritaria'**
  String get priorityPet;

  /// No description provided for @nextHealthEvent.
  ///
  /// In es, this message translates to:
  /// **'Próximo Evento de Salud'**
  String get nextHealthEvent;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In es, this message translates to:
  /// **'Sin eventos pendientes'**
  String get noUpcomingEvents;

  /// No description provided for @daysRemaining.
  ///
  /// In es, this message translates to:
  /// **'días restantes'**
  String get daysRemaining;

  /// No description provided for @oneDayRemaining.
  ///
  /// In es, this message translates to:
  /// **'mañana'**
  String get oneDayRemaining;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'¡hoy!'**
  String get today;

  /// No description provided for @vaccine.
  ///
  /// In es, this message translates to:
  /// **'Vacuna'**
  String get vaccine;

  /// No description provided for @noPetsText.
  ///
  /// In es, this message translates to:
  /// **'Añade una mascota para registrar su salud'**
  String get noPetsText;

  /// No description provided for @gallery.
  ///
  /// In es, this message translates to:
  /// **'Álbum de Fotos'**
  String get gallery;

  /// No description provided for @addPhoto.
  ///
  /// In es, this message translates to:
  /// **'Añadir Foto'**
  String get addPhoto;

  /// No description provided for @selectPhotoDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de la foto'**
  String get selectPhotoDate;

  /// No description provided for @photoNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas o descripción (opcional)'**
  String get photoNotes;

  /// No description provided for @emptyGallery.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay fotos en el álbum de'**
  String get emptyGallery;

  /// No description provided for @emptyGallerySubtitle.
  ///
  /// In es, this message translates to:
  /// **'¡Añade fotos para guardar hermosos recuerdos de tu mascota!'**
  String get emptyGallerySubtitle;

  /// No description provided for @deletePhotoConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar foto?'**
  String get deletePhotoConfirm;

  /// No description provided for @deletePhotoConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar esta foto de tu álbum? Esta acción no se puede deshacer.'**
  String get deletePhotoConfirmBody;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @photoAddedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Foto añadida correctamente'**
  String get photoAddedSuccessfully;

  /// No description provided for @weightHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de Peso'**
  String get weightHistory;

  /// No description provided for @addWeight.
  ///
  /// In es, this message translates to:
  /// **'Registrar Peso'**
  String get addWeight;

  /// No description provided for @weightInKg.
  ///
  /// In es, this message translates to:
  /// **'Peso (kg)'**
  String get weightInKg;

  /// No description provided for @selectWeightDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha del registro'**
  String get selectWeightDate;

  /// No description provided for @emptyWeightHistory.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay registros de peso para'**
  String get emptyWeightHistory;

  /// No description provided for @emptyWeightHistorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'¡Registra el peso regularmente para ver la evolución de tu mascota!'**
  String get emptyWeightHistorySubtitle;

  /// No description provided for @deleteWeightConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar registro de peso?'**
  String get deleteWeightConfirm;

  /// No description provided for @deleteWeightConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar este registro de peso de tu historial?'**
  String get deleteWeightConfirmBody;

  /// No description provided for @weightAddedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Peso registrado correctamente'**
  String get weightAddedSuccessfully;

  /// No description provided for @evolution.
  ///
  /// In es, this message translates to:
  /// **'Evolución temporal'**
  String get evolution;

  /// No description provided for @socialNetwork.
  ///
  /// In es, this message translates to:
  /// **'Red Social de Mascotas'**
  String get socialNetwork;

  /// No description provided for @socialNetworkSub.
  ///
  /// In es, this message translates to:
  /// **'Sigue a tus amigos y comenta sus fotos'**
  String get socialNetworkSub;

  /// No description provided for @discover.
  ///
  /// In es, this message translates to:
  /// **'Descubrir'**
  String get discover;

  /// No description provided for @following.
  ///
  /// In es, this message translates to:
  /// **'Siguiendo'**
  String get following;

  /// No description provided for @myPetsTab.
  ///
  /// In es, this message translates to:
  /// **'Mis Mascotas'**
  String get myPetsTab;

  /// No description provided for @shareSocial.
  ///
  /// In es, this message translates to:
  /// **'Compartir en Red Social'**
  String get shareSocial;

  /// No description provided for @shareSocialSub.
  ///
  /// In es, this message translates to:
  /// **'Permite que otros usuarios busquen y sigan a tu mascota.'**
  String get shareSocialSub;

  /// No description provided for @publicGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería Pública'**
  String get publicGallery;

  /// No description provided for @publicGallerySub.
  ///
  /// In es, this message translates to:
  /// **'Permite que otros usuarios vean e interactúen con tus fotos.'**
  String get publicGallerySub;

  /// No description provided for @viewPublicProfile.
  ///
  /// In es, this message translates to:
  /// **'Ver mi perfil público'**
  String get viewPublicProfile;

  /// No description provided for @commentPhoto.
  ///
  /// In es, this message translates to:
  /// **'Comentar foto'**
  String get commentPhoto;

  /// No description provided for @feedEmpty.
  ///
  /// In es, this message translates to:
  /// **'Tu feed está vacío'**
  String get feedEmpty;

  /// No description provided for @feedEmptySub.
  ///
  /// In es, this message translates to:
  /// **'Ve a la pestaña \"Descubrir\" y sigue a las mascotas de tus amigos para ver sus fotos aquí.'**
  String get feedEmptySub;

  /// No description provided for @discoverPets.
  ///
  /// In es, this message translates to:
  /// **'Descubrir mascotas'**
  String get discoverPets;

  /// No description provided for @aboutMe.
  ///
  /// In es, this message translates to:
  /// **'Sobre mí'**
  String get aboutMe;

  /// No description provided for @privateGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería Privada'**
  String get privateGallery;

  /// No description provided for @privateGallerySub.
  ///
  /// In es, this message translates to:
  /// **'El dueño de esta mascota ha decidido mantener su galería privada.'**
  String get privateGallerySub;

  /// No description provided for @noPhotosPublished.
  ///
  /// In es, this message translates to:
  /// **'No hay fotos publicadas'**
  String get noPhotosPublished;

  /// No description provided for @comments.
  ///
  /// In es, this message translates to:
  /// **'Comentarios'**
  String get comments;

  /// No description provided for @addComment.
  ///
  /// In es, this message translates to:
  /// **'Añadir un comentario...'**
  String get addComment;

  /// No description provided for @firstComment.
  ///
  /// In es, this message translates to:
  /// **'Sé el primero en comentar esta foto 🐾'**
  String get firstComment;

  /// No description provided for @petNotFound.
  ///
  /// In es, this message translates to:
  /// **'Mascota no encontrada en la red social'**
  String get petNotFound;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el perfil público'**
  String get errorLoadingProfile;

  /// No description provided for @myPetBadge.
  ///
  /// In es, this message translates to:
  /// **'Mi Mascota'**
  String get myPetBadge;

  /// No description provided for @chats.
  ///
  /// In es, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @chatWith.
  ///
  /// In es, this message translates to:
  /// **'Chat con'**
  String get chatWith;

  /// No description provided for @sendMessage.
  ///
  /// In es, this message translates to:
  /// **'Enviar Mensaje'**
  String get sendMessage;

  /// No description provided for @typeMessage.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje...'**
  String get typeMessage;

  /// No description provided for @noConversations.
  ///
  /// In es, this message translates to:
  /// **'No tienes conversaciones activas'**
  String get noConversations;

  /// No description provided for @startChatSub.
  ///
  /// In es, this message translates to:
  /// **'Inicia una conversación con los dueños de mascotas que sigues'**
  String get startChatSub;

  /// No description provided for @typing.
  ///
  /// In es, this message translates to:
  /// **'escribiendo...'**
  String get typing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ca',
        'de',
        'en',
        'es',
        'fr',
        'pt'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
