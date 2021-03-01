import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotifProductsBloc extends Bloc<ProductEvent, ProductState> {
  final UserDataRepository userDataRepository;

  NotifProductsBloc({this.userDataRepository}) : super(null);

  @override
  ProductState get initialState => InitialTrendingProductState();

  @override
  Stream<ProductState> mapEventToState(ProductEvent event) async* {
    if (event is GetNotifProducts) {
      yield* mapGetNotifProductsToState(event.type);
    }
  }

  Stream<ProductState> mapGetNotifProductsToState(String type) async* {
    yield GetNotifProductsInProgressState();
    try {
      List<Product> productList =
          await userDataRepository.getNotifProducts(type);
      if (productList != null) {
        yield GetNotifProductsCompletedState(productList);
      } else {
        yield GetNotifProductsFailedState();
      }
    } catch (e) {
      print(e);
      yield GetNotifProductsFailedState();
    }
  }
}
