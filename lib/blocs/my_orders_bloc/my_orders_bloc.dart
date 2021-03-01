import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:grocery_store/models/my_order.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';
import 'package:meta/meta.dart';

part 'my_orders_event.dart';
part 'my_orders_state.dart';

class MyOrdersBloc extends Bloc<MyOrdersEvent, MyOrdersState> {
  final UserDataRepository userDataRepository;

  StreamSubscription orderLocationSubscription;

  MyOrdersBloc({this.userDataRepository}) : super(null);

  @override
  MyOrdersState get initialState => MyOrdersInitial();

  @override
  Future<void> close() {
    print('CLOSING ORDER BLOC');
    orderLocationSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<MyOrdersState> mapEventToState(
    MyOrdersEvent event,
  ) async* {
    if (event is GetAllOrdersEvent) {
      yield* mapGetAllOrdersEventToState(uid: event.uid);
    }
    if (event is GetCancelledOrdersEvent) {
      yield* mapGetCancelledOrdersEventToState(allOrders: event.allOrders);
    }

    if (event is GetDeliveredOrdersEvent) {
      yield* mapGetDeliveredOrdersEventToState(allOrders: event.allOrders);
    }
    if (event is CancelOrderEvent) {
      yield* mapCancelOrderEventToState(event.cancelOrderMap);
    }
  }

  Stream<MyOrdersState> mapGetAllOrdersEventToState({String uid}) async* {
    yield GetAllOrdersInProgressState();
    try {
      List<MyOrder> allOrders = await userDataRepository.getAllOrders(uid);
      if (allOrders != null) {
        yield GetAllOrdersCompletedState(allOrders);
      } else {
        yield GetAllOrdersFailedState();
      }
    } catch (e) {
      print(e);
      yield GetAllOrdersFailedState();
    }
  }

  Stream<MyOrdersState> mapGetDeliveredOrdersEventToState(
      {List<MyOrder> allOrders}) async* {
    yield GetDeliveredOrdersInProgressState();
    try {
      List<MyOrder> deliveredOrders =
          await userDataRepository.getDeliveredOrders(allOrders);
      if (deliveredOrders != null) {
        yield GetDeliveredOrdersCompletedState(deliveredOrders);
      } else {
        yield GetDeliveredOrdersFailedState();
      }
    } catch (e) {
      print(e);
      yield GetDeliveredOrdersFailedState();
    }
  }

  Stream<MyOrdersState> mapGetCancelledOrdersEventToState(
      {List<MyOrder> allOrders}) async* {
    yield GetCancelledOrdersInProgressState();
    try {
      List<MyOrder> cancelledOrders =
          await userDataRepository.getCancelledOrders(allOrders);
      if (allOrders != null) {
        yield GetCancelledOrdersCompletedState(cancelledOrders);
      } else {
        yield GetCancelledOrdersFailedState();
      }
    } catch (e) {
      print(e);
      yield GetCancelledOrdersFailedState();
    }
  }

  Stream<MyOrdersState> mapCancelOrderEventToState(
    Map cancelOrderMap,
  ) async* {
    yield CancelOrderInProgressState();
    try {
      bool isCancelled = await userDataRepository.cancelOrder(cancelOrderMap);
      if (isCancelled) {
        yield CancelOrderCompletedState();
      } else {
        yield CancelOrderFailedState();
      }
    } catch (e) {
      print(e);
      yield CancelOrderFailedState();
    }
  }

  // Stream<MyOrdersState> TrackOrderEventToState(String uid) async* {
  //   yield TrackOrderInProgressState();
  //   try {
  //     cartCountSubscription?.cancel();
  //     cartCountSubscription = userDataRepository.TrackOrder(uid).listen(
  //       (cartCount) => add(CartCountUpdateEvent(cartCount)),
  //       onError: (err) {
  //         print(err);
  //         return TrackOrderFailedState();
  //       },
  //     );
  //   } catch (e) {
  //     print(e);
  //     yield TrackOrderFailedState();
  //   }
  // }
}
