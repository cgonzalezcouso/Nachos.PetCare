import 'package:flutter/material.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/models/marketplace_product.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/marketplace_service.dart';
import 'package:nachos_pet_care_flutter/widgets/affiliate_redirect_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final Pet? selectedPet;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.selectedPet,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final MarketplaceService _marketplaceService = getIt<MarketplaceService>();
  final DatabaseService _db = getIt<DatabaseService>();

  late MarketplaceProduct _product;
  List<String> _recommendationReasons = [];
  bool _isLoadingReasons = false;

  @override
  void initState() {
    super.initState();
    // Retrieve product from catalog
    _product = _marketplaceService.getAllProducts().firstWhere(
          (p) => p.id == widget.productId,
        );

    if (widget.selectedPet != null) {
      _loadPersonalizedReasons();
    }
  }

  Future<void> _loadPersonalizedReasons() async {
    setState(() {
      _isLoadingReasons = true;
    });

    try {
      final pet = widget.selectedPet!;
      final reports = await _db.getVeterinaryReportsByPet(pet.id);
      final vaccines = await _db.getVaccineRemindersByPet(pet.id);

      final recs = _marketplaceService.getRecommendations(pet, reports, vaccines);
      final match = recs.firstWhere(
        (r) => r.product.id == _product.id,
        orElse: () => ProductRecommendation(product: _product, reasons: [], score: 0),
      );

      if (mounted) {
        setState(() {
          _recommendationReasons = match.reasons;
          _isLoadingReasons = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReasons = false;
        });
      }
    }
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

  void _showRedirectDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AffiliateRedirectDialog(product: _product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sourceColor = _getSourceColor(_product.source);
    final hasReasons = _recommendationReasons.isNotEmpty && widget.selectedPet != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.category),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Hero Image
            Hero(
              tag: 'product_image_${_product.id}',
              child: AspectRatio(
                aspectRatio: 1.35,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    image: DecorationImage(
                      image: NetworkImage(_product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Merchant badge & Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: sourceColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _product.source.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: sourceColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${_product.rating}',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_product.reviewCount} opiniones)',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product Title
                  Text(
                    _product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price & commission indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.volunteer_activism_outlined, size: 14, color: colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Genera ${_product.commissionPercentage}% de comisión',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Personalized Recommendations Card
                  if (widget.selectedPet != null) ...[
                    _isLoadingReasons
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : hasReasons
                            ? Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primaryContainer.withValues(alpha: 0.25),
                                      Colors.purple.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          '¿Por qué te lo recomendamos?',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Text(
                                      'Este producto está especialmente seleccionado para ${widget.selectedPet!.name} por:',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ..._recommendationReasons.map((reason) {
                                      // Extracting markdown bold tags to render rich text easily in standard Flutter
                                      final cleanText = reason.replaceAll('**', '');
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 16,
                                              color: Colors.purpleAccent,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                cleanText,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colorScheme.outlineVariant),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check, color: Colors.grey),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Producto apto y seguro para el perfil de ${widget.selectedPet!.name}.',
                                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ],

                  // Product Description Section
                  Text(
                    'Descripción del producto',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for floating buy button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _showRedirectDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sourceColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _product.source.toLowerCase() == 'amazon'
                            ? Icons.shopping_cart_outlined
                            : Icons.storefront_outlined,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Comprar en ${_product.source}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
