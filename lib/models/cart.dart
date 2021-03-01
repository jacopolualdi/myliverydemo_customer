import 'package:cloud_firestore/cloud_firestore.dart';

import 'product.dart';

class Cart {
  Product product;
  String quantity;
  String itemId;
  bool isExtras;
  bool isSizes;
  List<Extras> extras;
  Sizes size;
  String totalPrice;

  Cart({
    this.product,
    this.quantity,
    this.itemId,
    this.isExtras,
    this.extras,
    this.isSizes,
    this.size,
    this.totalPrice,
  });

  factory Cart.fromFirestore({
    DocumentSnapshot documentSnapshot,
    String quantity,
    String itemId,
    bool isSizes,
    bool isExtras,
    List<Extras> extras,
    Sizes size,
    String totalPrice,
  }) {
    return Cart(
      product: Product.fromFirestore(documentSnapshot),
      quantity: quantity,
      itemId: itemId,
      isExtras: isExtras,
      extras: extras,
      isSizes: isSizes,
      size: size,
      totalPrice: totalPrice,
    );
  }
}
