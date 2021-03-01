import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/models/cart_info.dart';
import 'package:grocery_store/models/closing_hours.dart';
import 'package:grocery_store/models/payment_methods.dart';

class CartValues {
  CartInfo cartInfo;
  PaymentMethods paymentMethods;
  ClosingHours closingHours;

  CartValues({
    this.cartInfo,
    this.paymentMethods,
    this.closingHours,
  });
}
