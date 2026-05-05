import 'package:ecom/features/products/domain/repositories/product_repository.dart';
import 'package:ecom/shared/models/category.dart';
import 'package:ecom/shared/models/product.dart';

class MockProductRepository implements ProductRepository {
  // Mock Data
  final List<Category> _mockCategories = const [
    Category(id: 'c1', name: 'Electronics', imageUrl: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=400&auto=format&fit=crop'),
    Category(id: 'c2', name: 'Clothing', imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=400&auto=format&fit=crop'),
    Category(id: 'c3', name: 'Home', imageUrl: 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?q=80&w=400&auto=format&fit=crop'),
  ];

  final List<Product> _mockProducts = const [
    Product(
      id: 'p1',
      name: 'Wireless Headphones',
      description: 'High quality wireless headphones with noise cancellation.',
      price: 199.99,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=800&auto=format&fit=crop',
      categoryId: 'c1',
      rating: 4.5,
    ),
    Product(
      id: 'p2',
      name: 'Smartphone',
      description: 'Latest model smartphone with great camera.',
      price: 899.99,
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=800&auto=format&fit=crop',
      categoryId: 'c1',
      rating: 4.8,
    ),
    Product(
      id: 'p3',
      name: "Men's T-Shirt",
      description: 'Comfortable cotton t-shirt.',
      price: 24.99,
      imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=800&auto=format&fit=crop',
      categoryId: 'c2',
      rating: 4.2,
    ),
    Product(
      id: 'p4',
      name: 'Coffee Maker',
      description: 'Automatic coffee maker with timer.',
      price: 79.99,
      imageUrl: 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?q=80&w=800&auto=format&fit=crop',
      categoryId: 'c3',
      rating: 4.6,
    ),
    Product(
      id: 'p5',
      name: 'Laptop',
      description: 'Powerful laptop for work and gaming.',
      price: 1299.99,
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?q=80&w=800&auto=format&fit=crop',
      categoryId: 'c1',
      rating: 4.9,
    ),
  ];

  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate delay
    return _mockCategories;
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return _mockProducts.take(3).toList();
  }

  @override
  Future<List<Product>> getDealsOfTheDay() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockProducts.reversed.take(4).toList(); // Just to show different data
  }

  @override
  Future<List<Product>> getRecommendedProducts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockProducts.toList()..shuffle(); // Shuffle for variety
  }

  @override
  Future<Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockProducts.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final lowercaseQuery = query.toLowerCase();
    return _mockProducts
        .where((p) => p.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
}
