import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/models/marketplace_product.dart';
import 'package:nachos_pet_care_flutter/models/veterinary_report.dart';
import 'package:nachos_pet_care_flutter/models/vaccine_reminder.dart';
import 'package:intl/intl.dart';

class ProductRecommendation {
  final MarketplaceProduct product;
  final List<String> reasons;
  final double score;

  ProductRecommendation({
    required this.product,
    required this.reasons,
    required this.score,
  });
}

class MarketplaceService {
  final List<MarketplaceProduct> _products = [
    MarketplaceProduct(
      id: '1',
      name: 'Pienso Pro Plan Puppy (Pollo)',
      description: 'Alimento premium formulado científicamente para cachorros. Aporta nutrientes esenciales para el óptimo desarrollo del sistema inmune, cerebro y articulaciones en crecimiento.',
      price: 45.99,
      imageUrl: 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.amazon.es/dp/B07PHPD999',
      category: 'Alimentación',
      source: 'Amazon',
      commissionPercentage: 9.5,
      rating: 4.8,
      reviewCount: 342,
      targetPetTypes: [PetType.dog],
      minAgeMonths: 0,
      maxAgeMonths: 12,
      recommendedKeywords: ['cachorro', 'crecimiento', 'desarrollo', 'joven', 'pupy', 'puppy'],
    ),
    MarketplaceProduct(
      id: '2',
      name: 'Pienso Royal Canin Sensible (Salmón)',
      description: 'Dieta veterinaria de alta tolerancia para mascotas con problemas digestivos crónicos o piel extremadamente sensible. Contiene proteínas seleccionadas de salmón y arroz.',
      price: 54.50,
      imageUrl: 'https://images.unsplash.com/photo-1608454367599-c1139e5593cd?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.tiendanimal.es/pienso-sensible-salmon',
      category: 'Alimentación',
      source: 'Tiendanimal',
      commissionPercentage: 11.0,
      rating: 4.7,
      reviewCount: 198,
      targetPetTypes: [PetType.dog, PetType.cat],
      recommendedKeywords: ['sensible', 'gastritis', 'estomago', 'estómago', 'digestión', 'digestivo', 'vomitos', 'vómitos', 'diarrea', 'intolerancia'],
    ),
    MarketplaceProduct(
      id: '3',
      name: 'Cama Ortopédica Viscoelástica Premium',
      description: 'Cama con espuma viscoelástica con memoria ortopédica de alta densidad. Diseñada para aliviar la presión articular y ósea de perros de tamaño mediano y grande.',
      price: 79.99,
      imageUrl: 'https://images.unsplash.com/photo-1541599540903-216a46ca1df0?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.amazon.es/dp/B07ORTHO123',
      category: 'Accesorios',
      source: 'Amazon',
      commissionPercentage: 8.5,
      rating: 4.9,
      reviewCount: 512,
      targetPetTypes: [PetType.dog],
      minWeightKg: 15.0,
      recommendedKeywords: ['artritis', 'articulaciones', 'mayor', 'senior', 'huesos', 'displasia', 'cadera', 'dolor', 'espalda'],
    ),
    MarketplaceProduct(
      id: '4',
      name: 'Champú Hipoalergénico de Avena Organica',
      description: 'Champú calmante dermatológicamente testado con extractos naturales de avena y aloe vera. Alivia instantáneamente la irritación de la piel, descamación y picores alérgicos.',
      price: 14.90,
      imageUrl: 'https://images.unsplash.com/photo-1516733725897-1aa73b87c8e8?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.tiendanimal.es/champu-hipoalergenico-avena',
      category: 'Higiene',
      source: 'Tiendanimal',
      commissionPercentage: 10.0,
      rating: 4.6,
      reviewCount: 165,
      targetPetTypes: [PetType.dog, PetType.cat],
      recommendedKeywords: ['alergia', 'dermatitis', 'piel', 'pelo', 'picor', 'irritación', 'seborrea', 'champú', 'shampoo'],
    ),
    MarketplaceProduct(
      id: '5',
      name: 'Collar Antiparasitario Seresto (Perro Grande)',
      description: 'Protección antiparasitaria líder de hasta 8 meses contra pulgas, garrapatas, larvas y efecto repelente contra el mosquito transmisor de la Leishmaniasis.',
      price: 38.95,
      imageUrl: 'https://images.unsplash.com/photo-1503256207526-0d5d80fa2f47?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.amazon.es/dp/B07SERESTO8',
      category: 'Salud',
      source: 'Amazon',
      commissionPercentage: 9.0,
      rating: 4.9,
      reviewCount: 1240,
      targetPetTypes: [PetType.dog],
      minWeightKg: 8.0,
      recommendedKeywords: ['parasito', 'parásito', 'pulgas', 'garrapatas', 'leishmania', 'collar', 'prevencion', 'prevención', 'mosquito', 'insecto'],
    ),
    MarketplaceProduct(
      id: '6',
      name: 'Collar Antiparasitario Seresto (Gato y Perro Pequeño)',
      description: 'Máxima seguridad antiparasitaria de hasta 8 meses de liberación prolongada para gatos y perros pequeños. Resistente al agua y sin olores.',
      price: 34.50,
      imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.amazon.es/dp/B07SERESTO4',
      category: 'Salud',
      source: 'Amazon',
      commissionPercentage: 9.0,
      rating: 4.8,
      reviewCount: 980,
      targetPetTypes: [PetType.dog, PetType.cat],
      maxWeightKg: 8.0,
      recommendedKeywords: ['parasito', 'parásito', 'pulgas', 'garrapatas', 'collar', 'prevencion', 'prevención', 'gato'],
    ),
    MarketplaceProduct(
      id: '7',
      name: "Pienso Hill's Prescription Diet Urinary MultiCare",
      description: 'Alimento clínico húmedo/seco formulado para disolver los cálculos de estruvita en gatos y reducir su reaparición, favoreciendo un pH de orina saludable.',
      price: 42.00,
      imageUrl: 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.kiwoko.com/hills-urinary-multicare-cat',
      category: 'Alimentación',
      source: 'Kiwoko',
      commissionPercentage: 12.0,
      rating: 4.7,
      reviewCount: 220,
      targetPetTypes: [PetType.cat],
      recommendedKeywords: ['renal', 'urinario', 'riñon', 'riñón', 'cistitis', 'calculos', 'cálculos', 'orina', 'vejiga', 'infección'],
    ),
    MarketplaceProduct(
      id: '8',
      name: 'Juguete Dispensador de Premios KONG Classic',
      description: 'El estándar de oro de los juguetes interactivos para perros. Fabricado con goma natural súper resistente, ideal para rellenar con golosinas y aliviar el estrés.',
      price: 12.80,
      imageUrl: 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.amazon.es/dp/B0002AR0I8',
      category: 'Juguetes',
      source: 'Amazon',
      commissionPercentage: 8.0,
      rating: 4.9,
      reviewCount: 2450,
      targetPetTypes: [PetType.dog],
      recommendedKeywords: ['ansiedad', 'aburrimiento', 'masticar', 'juego', 'estres', 'estrés', 'hiperactivo', 'destruir', 'morder'],
    ),
    MarketplaceProduct(
      id: '9',
      name: 'Fuente de Agua de Acero Inoxidable con Filtro',
      description: 'Fuente de circulación continua que estimula a las mascotas a beber más agua. Cuenta con filtros de carbón activo para purificar y eliminar olores.',
      price: 29.99,
      imageUrl: 'https://images.unsplash.com/photo-1560743641-3914f2c45636?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.amazon.es/dp/B08WATERFOUN',
      category: 'Accesorios',
      source: 'Amazon',
      commissionPercentage: 10.0,
      rating: 4.5,
      reviewCount: 389,
      targetPetTypes: [PetType.dog, PetType.cat],
      recommendedKeywords: ['deshidratacion', 'deshidratación', 'beber', 'renal', 'orina', 'agua', 'riñon', 'riñón', 'hidratarse'],
    ),
    MarketplaceProduct(
      id: '10',
      name: 'Condroprotector Articulaciones (Glucosamina & Condroitina)',
      description: 'Suplemento nutricional con alta concentración de Glucosamina, MSM y Ácido Hialurónico. Previene y combate el desgaste de cartílagos en mascotas de edad avanzada.',
      price: 22.90,
      imageUrl: 'https://images.unsplash.com/photo-1584036561566-baf241830940?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.kiwoko.com/suplemento-articulaciones-glucosamina',
      category: 'Salud',
      source: 'Kiwoko',
      commissionPercentage: 11.5,
      rating: 4.8,
      reviewCount: 310,
      targetPetTypes: [PetType.dog, PetType.cat],
      minAgeMonths: 84, // 7 años+
      recommendedKeywords: ['artritis', 'articulaciones', 'cojera', 'dolor', 'huesos', 'vejez', 'senior', 'mayor', 'dificultad', 'andar'],
    ),
    MarketplaceProduct(
      id: '11',
      name: 'Rascador Castillo Árbol Multinivel',
      description: 'Estructura estable con postes de sisal natural para afilar uñas, cuevas acolchadas y juguetes colgantes. Ideal para mantener a gatos activos y proteger tus muebles.',
      price: 65.00,
      imageUrl: 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.tiendanimal.es/rascador-castillo-gatos',
      category: 'Accesorios',
      source: 'Tiendanimal',
      commissionPercentage: 8.0,
      rating: 4.7,
      reviewCount: 145,
      targetPetTypes: [PetType.cat],
      recommendedKeywords: ['uñas', 'rascar', 'arbol', 'árbol', 'ejercicio', 'aburrimiento', 'saltar', 'arañar'],
    ),
    MarketplaceProduct(
      id: '12',
      name: 'Henode Alfalfa Premium Verde Organica',
      description: 'Heno de alfalfa fresca recolectada a mano. Proporciona alto contenido en fibra y calcio, esencial para el desgaste dental y digestión equilibrada de pequeños herbívoros.',
      price: 8.50,
      imageUrl: 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.tiendanimal.es/heno-alfalfa-roedores',
      category: 'Alimentación',
      source: 'Tiendanimal',
      commissionPercentage: 10.5,
      rating: 4.9,
      reviewCount: 82,
      targetPetTypes: [PetType.rabbit, PetType.rodent],
      recommendedKeywords: ['heno', 'fibra', 'dientes', 'digestión', 'roedor', 'conejo', 'cobaya', 'hámster'],
    ),
    MarketplaceProduct(
      id: '13',
      name: 'Traje Quirúrgico de Recuperación Post-Cirugía',
      description: 'Alternativa cómoda al collar isabelino. Tela suave, transpirable e hipoalergénica que previene que la mascota lama o rasque heridas y puntos de sutura quirúrgicos.',
      price: 18.50,
      imageUrl: 'https://images.unsplash.com/photo-1629909613654-28e377c37b09?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.amazon.es/dp/B08SURGERYCOV',
      category: 'Salud',
      source: 'Amazon',
      commissionPercentage: 12.0,
      rating: 4.6,
      reviewCount: 231,
      targetPetTypes: [PetType.dog, PetType.cat],
      recommendedKeywords: ['cirugía', 'operación', 'cirugia', 'operacion', 'esterilización', 'castracion', 'castración', 'herida', 'puntos', 'lame', 'veterinario'],
    ),
    MarketplaceProduct(
      id: '14',
      name: 'Snacks Dentales Higiénicos Greenies',
      description: 'Snacks masticables dentales diarios. Su forma patentada cepilla los dientes, controla la acumulación de sarro y placa bacteriana, y refresca el aliento.',
      price: 16.20,
      imageUrl: 'https://images.unsplash.com/photo-1568640347023-a616a30bc3bd?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.amazon.es/dp/B00GREENIES',
      category: 'Higiene',
      source: 'Amazon',
      commissionPercentage: 9.0,
      rating: 4.8,
      reviewCount: 1540,
      targetPetTypes: [PetType.dog],
      recommendedKeywords: ['dientes', 'sarro', 'aliento', 'dental', 'boca', 'limpieza', 'cepillar', 'encías'],
    ),
    MarketplaceProduct(
      id: '15',
      name: 'Caña Interactiva de Plumas Silvestres',
      description: 'Caña de pescar interactiva y flexible con plumas naturales móviles. Fomenta el instinto de caza activo, el ejercicio aeróbico y la destreza del gato.',
      price: 6.90,
      imageUrl: 'https://images.unsplash.com/photo-1513360309081-36f5e878fc9e?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.kiwoko.com/cana-juguete-plumas-gatos',
      category: 'Juguetes',
      source: 'Kiwoko',
      commissionPercentage: 10.0,
      rating: 4.8,
      reviewCount: 310,
      targetPetTypes: [PetType.cat],
      recommendedKeywords: ['ejercicio', 'cazar', 'plumas', 'jugar', 'activo', 'diversión', 'pluma', 'caña', 'estimulacion'],
    ),
    MarketplaceProduct(
      id: '16',
      name: 'Suplemento Calcio en Polvo con Vitamina D3',
      description: 'Suplemento de alta pureza de carbonato de calcio enriquecido con Vitamina D3 para una óptima absorción. Previene enfermedades de deficiencia ósea en reptiles.',
      price: 11.50,
      imageUrl: 'https://images.unsplash.com/photo-1504450758481-7338eaa75e6a?w=500&auto=format&fit=crop&q=60',
      affiliateUrl: 'https://www.amazon.es/dp/B07CALCIUM',
      category: 'Salud',
      source: 'Amazon',
      commissionPercentage: 11.0,
      rating: 4.7,
      reviewCount: 94,
      targetPetTypes: [PetType.reptile, PetType.bird, PetType.amphibian],
      recommendedKeywords: ['calcio', 'vitamina', 'reptil', 'huesos', 'suplemento', 'pájaro', 'tortuga', 'iguana', 'gecko'],
    )
  ];

  // Get all products in catalog
  List<MarketplaceProduct> getAllProducts() {
    return List.unmodifiable(_products);
  }

  // Recommendation engine: parses pet profile and history to return scored, explained product list
  List<ProductRecommendation> getRecommendations(
    Pet pet,
    List<VeterinaryReport> medicalHistory,
    List<VaccineReminder> vaccines,
  ) {
    final List<ProductRecommendation> recommendations = [];

    // Filter to only show products suitable for this pet type
    final petTypeProducts = _products.where((p) => p.supportsPetType(pet.type)).toList();

    for (final product in petTypeProducts) {
      final List<String> reasons = [];
      double score = 1.0; // Base score

      // 1. Age Matching
      if (pet.birthDate != null) {
        final now = DateTime.now();
        final ageInMonths = (now.year - pet.birthDate!.year) * 12 + now.month - pet.birthDate!.month;

        if (product.minAgeMonths != null && product.maxAgeMonths != null) {
          if (ageInMonths >= product.minAgeMonths! && ageInMonths <= product.maxAgeMonths!) {
            score += 3.0;
            if (product.minAgeMonths == 0 && product.maxAgeMonths! <= 12) {
              reasons.add('Recomendado porque **${pet.name}** es un cachorro de **$ageInMonths meses** y necesita nutrientes de crecimiento.');
            } else {
              reasons.add('Adaptado para la etapa de desarrollo de tu mascota.');
            }
          }
        } else if (product.minAgeMonths != null && ageInMonths >= product.minAgeMonths!) {
          // Senior/older animals
          score += 2.5;
          reasons.add('Recomendado por su etapa de edad avanzada (**${pet.ageInYears} años**), ideal para mantener su vitalidad.');
        }
      }

      // 2. Weight Matching
      if (pet.weight != null) {
        final weight = pet.weight!;
        if (product.minWeightKg != null && weight >= product.minWeightKg!) {
          score += 2.0;
          reasons.add('Especialmente indicado para perros grandes con peso superior a ${product.minWeightKg} kg (peso de **${pet.name}**: **$weight kg**).');
        }
        if (product.maxWeightKg != null && weight <= product.maxWeightKg!) {
          score += 2.0;
          reasons.add('Especialmente indicado para razas pequeñas con peso inferior a ${product.maxWeightKg} kg (peso de **${pet.name}**: **$weight kg**).');
        }
      }

      // 3. Veterinary History Matching (Diagnoses, Treatments, Notes)
      for (final report in medicalHistory) {
        final diagnosis = report.diagnosis?.toLowerCase() ?? '';
        final treatment = report.treatment?.toLowerCase() ?? '';
        final notes = report.notes?.toLowerCase() ?? '';

        bool matchedReport = false;
        for (final keyword in product.recommendedKeywords) {
          final lowercaseKeyword = keyword.toLowerCase();
          if (diagnosis.contains(lowercaseKeyword) || 
              treatment.contains(lowercaseKeyword) || 
              notes.contains(lowercaseKeyword)) {
            matchedReport = true;
          }
        }

        if (matchedReport) {
          score += 6.0; // High priority boost
          final formattedDate = DateFormat('dd/MM/yyyy').format(report.visitDate);
          final diagText = report.diagnosis != null && report.diagnosis!.isNotEmpty 
              ? 'diagnóstico de "${report.diagnosis}"' 
              : 'registro veterinario';
          reasons.add('Indicado debido al **$diagText** en su visita clínica del **$formattedDate**.');
        }
      }

      // 4. Vaccine Matching (to suggest parasite prevention or immune support)
      for (final vaccine in vaccines) {
        final vaccineName = vaccine.vaccineName.toLowerCase();
        final notes = vaccine.notes?.toLowerCase() ?? '';

        bool matchedVaccine = false;
        for (final keyword in product.recommendedKeywords) {
          final lowercaseKeyword = keyword.toLowerCase();
          if (vaccineName.contains(lowercaseKeyword) || notes.contains(lowercaseKeyword)) {
            matchedVaccine = true;
          }
        }

        if (matchedVaccine) {
          score += 4.0;
          final formattedDate = DateFormat('dd/MM/yyyy').format(vaccine.dueDate);
          reasons.add('Recomendado en relación con su vacuna/recordatorio de **"${vaccine.vaccineName}"** programado para el **$formattedDate**.');
        }
      }

      // 5. Breed Matching
      if (pet.breed != null && pet.breed!.isNotEmpty) {
        final breed = pet.breed!.toLowerCase();
        bool matchedBreed = false;
        for (final keyword in product.recommendedKeywords) {
          if (breed.contains(keyword.toLowerCase())) {
            matchedBreed = true;
          }
        }

        if (matchedBreed) {
          score += 1.5;
          reasons.add('Especialmente recomendado para la raza **${pet.breed}**.');
        }
      }

      // Add to list only if there is a recommendation reason (to show personalized ones first,
      // or we can include base products with lower score and no reasons)
      recommendations.add(
        ProductRecommendation(
          product: product,
          reasons: reasons,
          score: score,
        ),
      );
    }

    // Sort by recommendation score (descending)
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    return recommendations;
  }
}
