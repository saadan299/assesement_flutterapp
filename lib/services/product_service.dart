import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String baseUrl = 'https://dummyjson.com';

  Map<String, dynamic> _decodeObject(http.Response response, String action) {
    if (response.statusCode != 200) {
      throw Exception('Failed to $action (${response.statusCode})');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response while trying to $action');
    }
    return decoded;
  }

  Future<ProductListResponse> fetchProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    final uri = Uri.parse('$baseUrl/products?limit=$limit&skip=$skip');
    final response = await http.get(uri);
    return ProductListResponse.fromJson(
      _decodeObject(response, 'load products'),
    );
  }

  Future<ProductListResponse> searchProducts(
    String query, {
    int limit = 10,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/products/search?q=${Uri.encodeQueryComponent(query)}&limit=$limit&skip=$skip',
    );
    final response = await http.get(uri);
    return ProductListResponse.fromJson(
      _decodeObject(response, 'search products'),
    );
  }

  Future<ProductListResponse> fetchProductsByCategory(
    String category, {
    int limit = 10,
    int skip = 0,
  }) async {
    if (category.isEmpty) {
      return fetchProducts(limit: limit, skip: skip);
    }

    final uri = Uri.parse(
      '$baseUrl/products/category/${Uri.encodeComponent(category)}?limit=$limit&skip=$skip',
    );
    final response = await http.get(uri);
    return ProductListResponse.fromJson(
      _decodeObject(response, 'load category'),
    );
  }

  Future<int> countProducts({String query = '', String? category}) async {
    if (query.isEmpty) {
      final response = category == null
          ? await fetchProducts(limit: 1)
          : await fetchProductsByCategory(category, limit: 1);
      return response.total;
    }
    if (category == null) {
      return (await searchProducts(query, limit: 1)).total;
    }
    var skip = 0;
    var count = 0;
    while (true) {
      final response = await searchProducts(query, limit: 100, skip: skip);
      count += response.products.where((p) => p.category == category).length;
      skip += response.products.length;
      if (skip >= response.total) return count;
      if (response.products.isEmpty) {
        throw Exception('Could not count all matching products');
      }
    }
  }

  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('$baseUrl/products/categories');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories (${response.statusCode})');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! List) return const [];

    return decoded
        .map((e) {
          if (e is String) return e;
          if (e is Map<String, dynamic>) {
            return (e['slug'] ?? e['name'] ?? '').toString();
          }
          return '';
        })
        .where((category) => category.isNotEmpty)
        .toList();
  }

  Future<Product> fetchProductDetail(int id) async {
    final uri = Uri.parse('$baseUrl/products/$id');
    final response = await http.get(uri);
    return Product.fromJson(_decodeObject(response, 'load product'));
  }
}
