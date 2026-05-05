import 'package:equatable/equatable.dart';
import 'package:ecom/shared/models/category.dart';
import 'package:ecom/shared/models/product.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();
  
  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class HomeDataLoaded extends ProductsState {
  final List<Category> categories;
  final List<Product> featuredProducts;
  final List<Product> dealsOfTheDay;
  final List<Product> recommendedProducts;

  const HomeDataLoaded({
    required this.categories,
    required this.featuredProducts,
    required this.dealsOfTheDay,
    required this.recommendedProducts,
  });

  @override
  List<Object> get props => [categories, featuredProducts, dealsOfTheDay, recommendedProducts];
}

class CategoryProductsLoaded extends ProductsState {
  final List<Product> products;
  final String categoryId;

  const CategoryProductsLoaded({
    required this.products,
    required this.categoryId,
  });

  @override
  List<Object> get props => [products, categoryId];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object> get props => [message];
}
