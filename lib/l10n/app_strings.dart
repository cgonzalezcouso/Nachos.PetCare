import 'package:flutter/material.dart';
import 'package:nachos_pet_care_flutter/l10n/app_localizations.dart';

class AppStrings {
  final BuildContext context;
  AppStrings(this.context);

  static AppStrings of(BuildContext context) {
    return AppStrings(context);
  }

  AppLocalizations get _localizations {
    final loc = AppLocalizations.of(context);
    if (loc != null) return loc;
    
    // Fallback de seguridad en caso de que falten los delegates en el widget tree
    throw FlashLocalizationException();
  }

  // ── Navegación ─────────────────────────────────────────────────────────────
  String get navHome => _localizations.navHome;
  String get navPets => _localizations.navPets;
  String get navReminders => _localizations.navReminders;
  String get navMore => _localizations.navMore;

  // ── Home ───────────────────────────────────────────────────────────────────
  String get welcome => _localizations.welcome;
  String get welcomeSub => _localizations.welcomeSub;
  String get quickActions => _localizations.quickActions;
  String get myPets => _localizations.myPets;
  String get veterinarian => _localizations.veterinarian;
  String get vaccines => _localizations.vaccines;
  String get appointments => _localizations.appointments;

  // ── Mascotas ───────────────────────────────────────────────────────────────
  String get noPetsRegistered => _localizations.noPetsRegistered;
  String get addPet => _localizations.addPet;

  // ── Comunidad (Más) ────────────────────────────────────────────────────────
  String get community => _localizations.community;
  String get adoptionAnimals => _localizations.adoptionAnimals;
  String get adoptionSub => _localizations.adoptionSub;
  String get articles => _localizations.articles;
  String get articlesSub => _localizations.articlesSub;
  String get directory => _localizations.directory;
  String get directorySub => _localizations.directorySub;

  // ── Configuración ──────────────────────────────────────────────────────────
  String get settings => _localizations.settings;
  String get appearance => _localizations.appearance;
  String get appTheme => _localizations.appTheme;
  String get darkModeActive => _localizations.darkModeActive;
  String get lightModeActive => _localizations.lightModeActive;
  String get followSystem => _localizations.followSystem;
  String get themeLight => _localizations.themeLight;
  String get themeDark => _localizations.themeDark;
  String get themeSystem => _localizations.themeSystem;
  String get notifications => _localizations.notifications;
  String get pushNotifications => _localizations.pushNotifications;
  String get notificationsSub => _localizations.notificationsSub;
  String get account => _localizations.account;
  String get privacySecurity => _localizations.privacySecurity;
  String get language => _localizations.language;
  String get info => _localizations.info;
  String get about => _localizations.about;
  String get terms => _localizations.terms;

  // ── Recordatorios ──────────────────────────────────────────────────────────
  String get noReminders => _localizations.noReminders;

  // ── General ────────────────────────────────────────────────────────────────
  String get save => _localizations.save;
  String get cancel => _localizations.cancel;
  String get back => _localizations.back;

  // ── Widget Mascota Prioritaria ─────────────────────────────────────────────
  String get priorityPet => _localizations.priorityPet;
  String get nextHealthEvent => _localizations.nextHealthEvent;
  String get noUpcomingEvents => _localizations.noUpcomingEvents;
  String get daysRemaining => _localizations.daysRemaining;
  String get oneDayRemaining => _localizations.oneDayRemaining;
  String get today => _localizations.today;
  String get vaccine => _localizations.vaccine;
  String get noPetsText => _localizations.noPetsText;

  // ── Galería de Fotos ────────────────────────────────────────────────────────
  String get gallery => _localizations.gallery;
  String get addPhoto => _localizations.addPhoto;
  String get selectPhotoDate => _localizations.selectPhotoDate;
  String get photoNotes => _localizations.photoNotes;
  String get emptyGallery => _localizations.emptyGallery;
  String get emptyGallerySubtitle => _localizations.emptyGallerySubtitle;
  String get deletePhotoConfirm => _localizations.deletePhotoConfirm;
  String get deletePhotoConfirmBody => _localizations.deletePhotoConfirmBody;
  String get delete => _localizations.delete;
  String get photoAddedSuccessfully => _localizations.photoAddedSuccessfully;

  // ── Registro de Peso y Gráfica ──────────────────────────────────────────────
  String get weightHistory => _localizations.weightHistory;
  String get addWeight => _localizations.addWeight;
  String get weightInKg => _localizations.weightInKg;
  String get selectWeightDate => _localizations.selectWeightDate;
  String get emptyWeightHistory => _localizations.emptyWeightHistory;
  String get emptyWeightHistorySubtitle => _localizations.emptyWeightHistorySubtitle;
  String get deleteWeightConfirm => _localizations.deleteWeightConfirm;
  String get deleteWeightConfirmBody => _localizations.deleteWeightConfirmBody;
  String get weightAddedSuccessfully => _localizations.weightAddedSuccessfully;
  String get evolution => _localizations.evolution;

  // ── Red Social ─────────────────────────────────────────────────────────────
  String get socialNetwork => _localizations.socialNetwork;
  String get socialNetworkSub => _localizations.socialNetworkSub;
  String get discover => _localizations.discover;
  String get following => _localizations.following;
  String get myPetsTab => _localizations.myPetsTab;
  String get shareSocial => _localizations.shareSocial;
  String get shareSocialSub => _localizations.shareSocialSub;
  String get publicGallery => _localizations.publicGallery;
  String get publicGallerySub => _localizations.publicGallerySub;
  String get viewPublicProfile => _localizations.viewPublicProfile;
  String get commentPhoto => _localizations.commentPhoto;
  String get feedEmpty => _localizations.feedEmpty;
  String get feedEmptySub => _localizations.feedEmptySub;
  String get discoverPets => _localizations.discoverPets;
  String get aboutMe => _localizations.aboutMe;
  String get privateGallery => _localizations.privateGallery;
  String get privateGallerySub => _localizations.privateGallerySub;
  String get noPhotosPublished => _localizations.noPhotosPublished;
  String get comments => _localizations.comments;
  String get addComment => _localizations.addComment;
  String get firstComment => _localizations.firstComment;
  String get petNotFound => _localizations.petNotFound;
  String get errorLoadingProfile => _localizations.errorLoadingProfile;
  String get myPetBadge => _localizations.myPetBadge;

  // ── Mensajería Privada ──────────────────────────────────────────────────────
  String get chats => _localizations.chats;
  String get chatWith => _localizations.chatWith;
  String get sendMessage => _localizations.sendMessage;
  String get typeMessage => _localizations.typeMessage;
  String get noConversations => _localizations.noConversations;
  String get startChatSub => _localizations.startChatSub;
  String get typing => _localizations.typing;

  // ── Ecosistema B2B Clínicas ──────────────────────────────────────────────────
  String get _currentLocale {
    try {
      return Localizations.localeOf(context).languageCode;
    } catch (_) {
      return 'es';
    }
  }

  String get b2bClinicPortal {
    switch (_currentLocale) {
      case 'en': return 'B2B Clinical Panel';
      case 'pt': return 'Painel Clínico B2B';
      case 'fr': return 'Portail Clinique B2B';
      case 'ca': return 'Panell Clínic B2B';
      case 'de': return 'B2B Klinisches Portal';
      default: return 'Panel Clínico B2B';
    }
  }

  String get b2bClinicPortalSub {
    switch (_currentLocale) {
      case 'en': return 'Management for veterinarians and SaaS licenses';
      case 'pt': return 'Gestão para veterinários e licenças SaaS';
      case 'fr': return 'Gestion pour les vétérinaires et licences SaaS';
      case 'ca': return 'Gestió per a veterinaris i llicències SaaS';
      case 'de': return 'Verwaltung für Tierärzte und SaaS-Lizenzen';
      default: return 'Gestión para veterinarios y licencias SaaS';
    }
  }

  String get vetInvitations {
    switch (_currentLocale) {
      case 'en': return 'Share with Veterinarian';
      case 'pt': return 'Compartilhar com Veterinário';
      case 'fr': return 'Partager avec le Vétérinaire';
      case 'ca': return 'Compartir amb Veterinari';
      case 'de': return 'Mit Tierarzt teilen';
      default: return 'Compartir con Veterinario';
    }
  }

  String get vetInvitationsSub {
    switch (_currentLocale) {
      case 'en': return 'Grant secure access to your trusted veterinarian';
      case 'pt': return 'Conceda acesso seguro ao seu veterinário de confiança';
      case 'fr': return 'Accorder un accès sécurisé à votre vétérinaire';
      case 'ca': return 'Concedeix accés segur al teu veterinari de confiança';
      case 'de': return 'Gewähren Sie Ihrem Tierarzt sicheren Zugriff';
      default: return 'Concede acceso seguro a tu veterinario de confianza';
    }
  }

  String get wearablesTitle {
    switch (_currentLocale) {
      case 'en': return 'Wearables & Sensors';
      case 'pt': return 'Dispositivos e Wearables';
      case 'fr': return 'Appareils & Objets Connectés';
      case 'ca': return 'Dispositius i Wearables';
      case 'de': return 'Wearables & Sensoren';
      default: return 'Dispositivos & Wearables';
    }
  }

  String get wearablesSub {
    switch (_currentLocale) {
      case 'en': return 'Manage GPS collars and activity tracker sensors';
      case 'pt': return 'Gerencie coleiras GPS e sensores de atividade';
      case 'fr': return 'Gérer les colliers GPS et capteurs d\'activité';
      case 'ca': return 'Gestiona collars GPS i sensors d\'activitat';
      case 'de': return 'Verwalten Sie GPS-Halsbänder und Aktivitätssensoren';
      default: return 'Gestiona collares GPS y sensores de actividad';
    }
  }

  String get aiAssistantTitle {
    switch (_currentLocale) {
      case 'en': return 'AI Vet Assistant';
      case 'pt': return 'Assistente Vet IA';
      case 'fr': return 'Assistant Vétérinaire IA';
      case 'ca': return 'Asistent Veterinari IA';
      case 'de': return 'KI-Tierarzt-Assistent';
      default: return 'Asistente Veterinario IA';
    }
  }

  String get aiAssistantSub {
    switch (_currentLocale) {
      case 'en': return 'Symptom analysis and preventative care guidance';
      case 'pt': return 'Análise de sintomas e orientações de cuidados preventivos';
      case 'fr': return 'Analyse des symptômes et conseils de soins préventifs';
      case 'ca': return 'Anàlisi de símptomes i consells de cura preventiva';
      case 'de': return 'Symptomanalyse und Empfehlungen zur Vorsorge';
      default: return 'Análisis de síntomas y guías de cuidado preventivo';
    }
  }
}

class FlashLocalizationException implements Exception {
  @override
  String toString() => 'Error: AppLocalizations no está registrado en el árbol de Widgets';
}
