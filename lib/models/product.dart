import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  AdditionalInfo additionalInfo;
  String category;
  String description;
  String id;
  bool inStock;
  bool isListed;
  String name;
  String ogPrice;
  String price;
  List productImages;
  int quantity;
  List<QuestionAnswer> queAndAns;
  List<Review> reviews;
  String subCategory;
  Timestamp timestamp;
  bool trending;
  bool featured;
  String unitQuantity;
  var views;
  bool isSizes;
  bool isExtras;
  List<Sizes> sizes;
  List<Extras> extras;

  Product({
    this.additionalInfo,
    this.category,
    this.description,
    this.id,
    this.inStock,
    this.isListed,
    this.name,
    this.ogPrice,
    this.price,
    this.productImages,
    this.quantity,
    this.queAndAns,
    this.reviews,
    this.subCategory,
    this.timestamp,
    this.trending,
    this.featured,
    this.unitQuantity,
    this.views,
    this.extras,
    this.isExtras,
    this.isSizes,
    this.sizes,
  });

  factory Product.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data();
    return Product(
      additionalInfo: AdditionalInfo.fromHashmap(data['additionalInfo']),
      category: data['category'],
      description: data['description'],
      id: data['id'],
      inStock: data['inStock'],
      isListed: data['isListed'],
      name: data['name'],
      ogPrice: data['ogPrice'],
      price: data['price'],
      productImages: data['productImages'],
      quantity: data['quantity'],
      queAndAns: getListOfQueAns(data['queAndAns']),
      reviews: getListOfReviews(data['reviews']),
      subCategory: data['subCategory'],
      timestamp: data['timestamp'],
      trending: data['trending'],
      featured: data['featured'],
      unitQuantity: data['unitQuantity'],
      views: data['views'],
      sizes: List<Sizes>.from(
        data['sizes'].map(
          (size) {
            return Sizes(
              name: size['name'],
              price: size['price'],
            );
          },
        ),
      ),
      extras: List<Extras>.from(
        data['extras'].map(
          (size) {
            return Extras(
              name: size['name'],
              price: size['price'],
            );
          },
        ),
      ),
      isExtras: data['isExtras'],
      isSizes: data['isSizes'],
    );
  }
}

class QuestionAnswer {
  String ans;
  String que;
  Timestamp timestamp;
  String userId;
  String userName;
  String queId;

  QuestionAnswer({
    this.ans,
    this.que,
    this.timestamp,
    this.userId,
    this.userName,
    this.queId,
  });

  factory QuestionAnswer.fromHashMap(Map<String, dynamic> queAndAns) {
    return QuestionAnswer(
      ans: queAndAns['ans'],
      que: queAndAns['que'],
      timestamp: queAndAns['timestamp'],
      userId: queAndAns['userId'],
      userName: queAndAns['userName'],
      queId: queAndAns['queId'],
    );
  }
}

class Review {
  String review;
  String rating;
  Timestamp timestamp;
  String userId;
  String userName;
  String reviewId;

  Review({
    this.rating,
    this.review,
    this.timestamp,
    this.userId,
    this.userName,
    this.reviewId,
  });

  factory Review.fromHashMap(Map<String, dynamic> review) {
    return Review(
      rating: review['rating'],
      review: review['review'],
      timestamp: review['timestamp'],
      userId: review['userId'],
      userName: review['userName'],
      reviewId: review['reviewId'],
    );
  }
}

class Sizes {
  String name;
  String price;

  Sizes({
    this.name,
    this.price,
  });

  factory Sizes.fromHashMap(Map<String, dynamic> size) {
    return Sizes(
      name: size['name'],
      price: size['price'],
    );
  }
}

class Extras {
  String name;
  String price;

  Extras({
    this.name,
    this.price,
  });

  factory Extras.fromHashMap(Map<String, dynamic> extra) {
    return Extras(
      name: extra['name'],
      price: extra['price'],
    );
  }
}

class AdditionalInfo {
  String bestBefore;
  String brand;
  String manufactureDate;
  String shelfLife;

  AdditionalInfo({
    this.bestBefore,
    this.brand,
    this.manufactureDate,
    this.shelfLife,
  });

  factory AdditionalInfo.fromHashmap(Map<String, dynamic> additionalInfo) {
    return AdditionalInfo(
      bestBefore: additionalInfo['bestBefore'],
      brand: additionalInfo['brand'],
      manufactureDate: additionalInfo['manufactureDate'],
      shelfLife: additionalInfo['shelfLife'],
    );
  }
}

List<QuestionAnswer> getListOfQueAns(Map queAns) {
  List<QuestionAnswer> list = List();
  queAns.forEach((key, value) {
    list.add(QuestionAnswer(
      ans: value['ans'],
      que: value['que'],
      timestamp: value['timestamp'],
      userId: value['userId'],
      userName: value['userName'],
      queId: value['queId'],
    ));
  });

  return list;
}

List<Review> getListOfReviews(Map reviews) {
  List<Review> list = List();
  reviews.forEach((key, value) {
    list.add(Review(
      rating: value['rating'],
      review: value['review'],
      timestamp: value['timestamp'],
      userId: value['userId'],
      userName: value['userName'],
      reviewId: value['reviewId'],
    ));
  });

  return list;
}

List<Sizes> getListOfSizes(List sizes) {
  List<Sizes> list = List();

  // reviews: List<Review>.from(
  //   data['reviews'].map(
  //     (review) {
  //       return Review(
  //         rating: review['rating'],
  //         review: review['review'],
  //         timestamp: review['timestamp'],
  //         userId: review['userId'],
  //         userName: review['userName'],
  //       );
  //     },
  //   ),
  // ),

  return list;
}

List<Extras> getListOfExtras(Map extras) {
  List<Extras> list = List();
  extras.forEach((key, value) {
    list.add(Extras(
      price: value['price'],
      name: value['name'],
    ));
  });

  return list;
}
