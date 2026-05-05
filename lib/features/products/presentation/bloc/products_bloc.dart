import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecom/features/products/domain/repositories/product_repository.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductRepository productRepository;

  ProductsBloc({required this.productRepository}) : super(ProductsInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    try {
      final categories = await productRepository.getCategories();
      final featuredProducts = await productRepository.getFeaturedProducts();
      final dealsOfTheDay = await productRepository.getDealsOfTheDay();
      final recommendedProducts = await productRepository.getRecommendedProducts();
      emit(HomeDataLoaded(
        categories: categories,
        featuredProducts: featuredProducts,
        dealsOfTheDay: dealsOfTheDay,
        recommendedProducts: recommendedProducts,
      ));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    try {
      final products = await productRepository.getProductsByCategory(event.categoryId);
      emit(CategoryProductsLoaded(
        products: products,
        categoryId: event.categoryId,
      ));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
