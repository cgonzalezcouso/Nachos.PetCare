import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/models/marketplace_product.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/marketplace_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final MarketplaceService _marketplaceService = getIt<MarketplaceService>();
  final DatabaseService _db = getIt<DatabaseService>();

  Pet? _selectedPetForRecommendations;
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  
  bool _isLoadingRecommendations = false;
  List<ProductRecommendation> _recommendations = [];
  List<MarketplaceProduct> _allProducts = [];

  final List<String> _categories = [
    'Todos',
    'Alimentación',
    'Juguetes',
    'Salud',
    'Higiene',
    'Accesorios'
  ];

  @override
  void initState() {
    super.initState();
    _allProducts = _marketplaceService.getAllProducts();
    
    // Select first pet by default if available after frame layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petProvider = context.read<PetProvider>();
      if (petProvider.pets.isNotEmpty) {
        _selectPet(petProvider.pets.first);
      } else {
        _loadDefaultProducts();
      }
    });
  }

  void _loadDefaultProducts() {
    setState(() {
      _recommendations = _allProducts.map((p) => ProductRecommendation(
        product: p,
        reasons: [],
        score: 0,
      )).toList();
    });
  }

  Future<void> _selectPet(Pet? pet) async {
    if (pet == null) {
      setState(() {
        _selectedPetForRecommendations = null;
        _loadDefaultProducts();
      });
      return;
    }

    setState(() {
      _selectedPetForRecommendations = pet;
      _isLoadingRecommendations = true;
    });

    try {
      // Query SQLite database for history & vaccine data
      final reports = await _db.getVeterinaryReportsByPet(pet.id);
      final vaccines = await _db.getVaccineRemindersByPet(pet.id);

      if (mounted) {
        final recs = _marketplaceService.getRecommendations(pet, reports, vaccines);
        setState(() {
          _recommendations = recs;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar recomendaciones de ${pet.name}: $e')),
        );
      }
    }
  }

  List<ProductRecommendation> _getFilteredRecommendations() {
    return _recommendations.where((rec) {
      final product = rec.product;
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Todos' || product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'amazon':
        return Colors.orange;
      case 'kiwoko':
        return Colors.deepOrangeAccent;
      case 'tiendanimal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  ImageProvider? _getPetImageProvider(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return null;
    if (photoPath.startsWith('http')) {
      return NetworkImage(photoPath);
    }
    return FileImage(File(photoPath));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final petProvider = context.watch<PetProvider>();
    final filteredRecommendations = _getFilteredRecommendations();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar piensos, juguetes, champús...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Pet Picker for Personalized Recommendations
            if (petProvider.pets.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Recomendaciones para:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 52,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: petProvider.pets.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Option for "Show All"
                      final isSelected = _selectedPetForRecommendations == null;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          avatar: Icon(
                            Icons.shopping_bag_outlined, 
                            size: 16, 
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant
                          ),
                          label: const Text('Todos'),
                          selected: isSelected,
                          onSelected: (selected) => _selectPet(null),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    }

                    final pet = petProvider.pets[index - 1];
                    final isSelected = _selectedPetForRecommendations?.id == pet.id;
                    final img = _getPetImageProvider(pet.photoPath);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        avatar: CircleAvatar(
                          radius: 12,
                          backgroundImage: img,
                          child: img == null 
                              ? Icon(Icons.pets, size: 12, color: isSelected ? Colors.white : colorScheme.primary)
                              : null,
                        ),
                        label: Text(pet.name),
                        selected: isSelected,
                        onSelected: (selected) => _selectPet(pet),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // Prompt user to add a pet
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '¡Registra a tu mascota para obtener recomendaciones basadas en su salud y edad!',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Category Chips List
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Products Grid View
            Expanded(
              child: _isLoadingRecommendations
                  ? const Center(child: CircularProgressIndicator())
                  : filteredRecommendations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_basket_outlined, size: 64, color: colorScheme.outline),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron productos',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredRecommendations.length,
                          itemBuilder: (context, index) {
                            final rec = filteredRecommendations[index];
                            final product = rec.product;
                            final hasPersonalizedReason = rec.reasons.isNotEmpty && _selectedPetForRecommendations != null;

                            return Card(
                              elevation: hasPersonalizedReason ? 4 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: hasPersonalizedReason 
                                    ? BorderSide(color: colorScheme.primary.withValues(alpha: 0.6), width: 1.5)
                                    : BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Navigate to product detail
                                  context.push(
                                    '/marketplace/product/${product.id}',
                                    extra: _selectedPetForRecommendations,
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Product Image
                                        AspectRatio(
                                          aspectRatio: 1.25,
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                            child: Hero(
                                              tag: 'product_image_${product.id}',
                                              child: Image.network(
                                                product.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  color: colorScheme.surfaceContainer,
                                                  child: Icon(Icons.broken_image, color: colorScheme.outline),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Source Badge
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: _getSourceColor(product.source).withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    product.source,
                                                    style: theme.textTheme.labelSmall?.copyWith(
                                                      color: _getSourceColor(product.source),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 9,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                
                                                // Product Name
                                                Text(
                                                  product.name,
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const Spacer(),

                                                // Rating & Price
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          '${product.rating}',
                                                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      '\$${product.price.toStringAsFixed(2)}',
                                                      style: theme.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        color: colorScheme.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                
                                                // Commission helper text (aesthetic indicator)
                                                if (hasPersonalizedReason) ...[
                                                  const Divider(height: 10),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.volunteer_activism_outlined, size: 11, color: colorScheme.primary),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Soporte +${product.commissionPercentage}%',
                                                        style: theme.textTheme.labelSmall?.copyWith(
                                                          fontSize: 8,
                                                          color: colorScheme.primary,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Recommended Ribbon/Badge
                                    if (hasPersonalizedReason)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.purpleAccent, colorScheme.primary],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorScheme.primary.withValues(alpha: 0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                'RECOMENDADO',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
