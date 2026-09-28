class Review {
  final String reviewerName;
  final int rating;
  final String comment;

  Review({
    required this.reviewerName,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Review(reviewerName: 'Anonymous', rating: 0, comment: '');
    }
    return Review(
      reviewerName: json['reviewerName'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
    );
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String brand;
  final int stock;
  final double rating;
  final String thumbnail;
  final List<String> images;
  final String category;
  final List<Review> reviews;
  final String? qrCode;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.brand,
    required this.stock,
    required this.rating,
    required this.thumbnail,
    required this.images,
    required this.category,
    required this.reviews,
    this.qrCode,
  });

  bool get isInStock => stock > 0;
  String get availabilityStatus => isInStock ? 'In Stock' : 'Out of Stock';
  String get displayBrand => brand.isNotEmpty ? brand : 'Unknown';
  bool get hasQrCode => qrCode != null && qrCode!.isNotEmpty;
  List<String> get galleryImages {
    final nonEmpty = images.where((url) => url.isNotEmpty).toList();
    if (nonEmpty.isNotEmpty) return nonEmpty;
    return thumbnail.isNotEmpty ? [thumbnail] : [];
  }

  factory Product.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Product(
        id: 0,
        title: '',
        description: '',
        price: 0,
        brand: 'Unknown',
        stock: 0,
        rating: 0,
        thumbnail: '',
        images: const [],
        category: '',
        reviews: const [],
        qrCode: null,
      );
    }

    final reviewsJson = json['reviews'] as List<dynamic>? ?? [];
    final imagesJson = json['images'] as List<dynamic>? ?? [];
    final meta = json['meta'];
    final qrCode = meta is Map<String, dynamic>
        ? meta['qrCode'] as String?
        : null;

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      brand: json['brand'] as String? ?? 'Unknown',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
      images: imagesJson
          .whereType<Object>()
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      category: json['category'] as String? ?? '',
      reviews: reviewsJson
          .map((e) => Review.fromJson(e is Map<String, dynamic> ? e : null))
          .toList(),
      qrCode: qrCode,
    );
  }
}

class ProductListResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  ProductListResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ProductListResponse(
        products: const [],
        total: 0,
        skip: 0,
        limit: 0,
      );
    }

    final productsJson = json['products'] as List<dynamic>? ?? [];
    final products = productsJson
        .map((e) => Product.fromJson(e is Map<String, dynamic> ? e : null))
        .toList();

    return ProductListResponse(
      products: products,
      total: (json['total'] as num?)?.toInt() ?? products.length,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? products.length,
    );
  }
}
