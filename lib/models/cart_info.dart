import 'package:cloud_firestore/cloud_firestore.dart';

class CartInfo {
  String discountAmt;
  String discountPer;
  String shippingAmt;
  String taxPer;
  String city;
  String minAmt;

  CartInfo({
    this.discountAmt,
    this.discountPer,
    this.shippingAmt,
    this.taxPer,
    this.city,
    this.minAmt,
  });

  factory CartInfo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return CartInfo(
      discountAmt: data['discountAmt'],
      discountPer: data['discountPer'],
      shippingAmt: data['shippingAmt'],
      taxPer: data['taxPer'],
      city: data['city'],
      minAmt: data['minAmt'],
    );
  }
}
