import 'package:ecom/shared/models/category.dart';
import 'package:ecom/shared/models/product.dart';

abstract class ProductRepository {
  Future<List<Category>> getCategories();
  Future<List<Product>> getFeaturedProducts();
  Future<List<Product>> getDealsOfTheDay();
  Future<List<Product>> getRecommendedProducts();
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<Product?> getProductById(String id);
  Future<List<Product>> searchProducts(String query);
}
