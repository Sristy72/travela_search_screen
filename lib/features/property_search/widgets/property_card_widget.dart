import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/property_item_model.dart';

class PropertyCardWidget extends StatefulWidget {
  final PropertyItemModel property;
  final int totalDays;

  const PropertyCardWidget({
    super.key,
    required this.property,
    this.totalDays = 2,
  });

  static const Color primaryPink = Color(0xFFE51D5A);

  @override
  State<PropertyCardWidget> createState() => _PropertyCardWidgetState();
}

class _PropertyCardWidgetState extends State<PropertyCardWidget> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final images = property.images;
    final effectivePrice = property.effectivePrice;

    final days = widget.totalDays > 0 ? widget.totalDays : 1;
    final totalPrice = effectivePrice * days;

    // Specs string construction
    final specsList = <String>[];
    if (property.bedroom > 0) specsList.add('${property.bedroom} Bedroom');
    if (property.beds > 0) specsList.add('${property.beds} Bed');
    if (property.bathroom > 0) specsList.add('${property.bathroom} Bath');
    final specsText = specsList.join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Slider / Header Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1.25,
                  child: images.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: images[index].url,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFFF2F2F7),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: PropertyCardWidget.primaryPink,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFFEFEFF4),
                                child: const Icon(Icons.apartment, size: 48, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFFEFEFF4),
                          child: const Icon(Icons.apartment, size: 48, color: Colors.grey),
                        ),
                ),
              ),

              // Featured Badge
              if (property.featuredBadge != null && property.featuredBadge!.name != null)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      property.featuredBadge!.name!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

              // Page indicator dots
              if (images.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length.clamp(0, 6), (idx) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentImageIndex == idx ? 8 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == idx
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Rating Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  property.placeType ?? property.propertyTypeName ?? 'Property',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (property.reviewsAvg != null) ...[
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(
                      property.reviewsAvg!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (property.reviewsCount > 0)
                      Text(
                        ' (${property.reviewsCount})',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ],
          ),

          // Detailed Title / Address
          if (property.title.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              property.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
            ),
          ],

          // Specs Line
          if (specsText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              specsText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // Price per day
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'BDT ${effectivePrice.toInt()} ',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                '/ Day',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (property.offerPrice != null && property.offerPrice! < property.price) ...[
                const SizedBox(width: 8),
                Text(
                  'BDT ${property.price.toInt()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),

          // Total Price
          const SizedBox(height: 2),
          Text(
            'Total BDT ${totalPrice.toInt()}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
