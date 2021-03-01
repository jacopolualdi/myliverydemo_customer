import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_count_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/increment_view_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/post_question_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/rate_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/report_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/similar_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/wishlist_product_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/providers/state_provider.dart';
import 'package:grocery_store/widget/post_question_dialog.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:grocery_store/widget/product_detail_item.dart';
import 'package:grocery_store/widget/product_list_item.dart';
import 'package:grocery_store/widget/question_answer_item.dart';
import 'package:grocery_store/widget/rate_product_dialog.dart';
import 'package:grocery_store/widget/report_product_dialog.dart';
import 'package:grocery_store/widget/review_item.dart';
import 'package:grocery_store/widget/shimmer_product_detail.dart';
import 'package:grocery_store/widget/shimmer_product_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'all_questions_screen.dart';
import 'all_reviews_screen.dart';
import 'fullscreen_image_screen.dart';

class ProductScreen extends StatefulWidget {
  final String productId;
  ProductScreen({this.productId});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ProductBloc productBloc;
  SimilarProductBloc similarProductBloc;
  CartBloc cartBloc;
  SigninBloc signinBloc;
  CartCountBloc cartCountBloc;
  User _currentUser;
  WishlistProductBloc wishlistProductBloc;
  IncrementViewBloc incrementViewBloc;
  ReportProductBloc reportProductBloc;

  Product _product;
  List<Product> _similarProducts;
  int cartCount;

  bool isReporting;

  List<Widget> productImages = List();
  double rating;
  String discount;
  PostQuestionBloc postQuestionBloc;
  RateProductBloc rateProductBloc;

  bool isPostingQuestion;
  bool isRatingProduct;
  bool checkRatingProduct;

  List<Extras> addedExtras;
  int seletedSize;

  double totalCost;

  @override
  void initState() {
    super.initState();

    print('');
    print('');
    print('CALLING ::');
    print('PRODUCT ID :: ${widget.productId}');
    print('');
    print('');

    isReporting = false;

    totalCost = 0;

    isPostingQuestion = false;
    checkRatingProduct = false;
    isRatingProduct = false;

    wishlistProductBloc = BlocProvider.of<WishlistProductBloc>(context);
    productBloc = BlocProvider.of<ProductBloc>(context);
    postQuestionBloc = BlocProvider.of<PostQuestionBloc>(context);
    rateProductBloc = BlocProvider.of<RateProductBloc>(context);

    rating = 0;

    productBloc = BlocProvider.of<ProductBloc>(context);
    similarProductBloc = BlocProvider.of<SimilarProductBloc>(context);
    cartBloc = BlocProvider.of<CartBloc>(context);
    signinBloc = BlocProvider.of<SigninBloc>(context);
    cartCountBloc = BlocProvider.of<CartCountBloc>(context);
    wishlistProductBloc = BlocProvider.of<WishlistProductBloc>(context);
    incrementViewBloc = BlocProvider.of<IncrementViewBloc>(context);
    reportProductBloc = BlocProvider.of<ReportProductBloc>(context);

    productBloc.add(LoadProductEvent(widget.productId));
    // signinBloc.add(GetCurrentUser());
    incrementViewBloc.add(IncrementViewEvent(widget.productId));

    _currentUser = FirebaseAuth.instance.currentUser;

    // signinBloc.listen((state) {
    //   print('Current User :: $state');
    //   if (state is GetCurrentUserCompleted) {
    //     _currentUser = state.firebaseUser;
    //   }
    //   if (state is GetCurrentUserFailed) {
    //     //failed to get current user
    //   }
    //   if (state is GetCurrentUserInProgress) {
    //     //getting current user
    //   }
    // });

    cartBloc.add(InitializeCartEvent());
    wishlistProductBloc.add(InitializeWishlistEvent());

    wishlistProductBloc.listen((state) {
      //TODO: add to wishlist and remove from wishlist
      // if (state is AddToWishlistCompletedState) {
      //   showSnack('Added to wishlist');
      //   // wishlistProductBloc.close();
      // }
      if (state is AddToWishlistFailedState) {
        showSnack('Aggiunta alla Wishlist non riuscita.', context);
      }
      if (state is AddToWishlistInProgressState) {
        showSnack('Aggiunto alla Wishlist', context);
      }
    });

    reportProductBloc.listen((state) {
      print('REPORT BLOC: $state');

      if (state is ReportProductInProgressState) {
        //show updating dialog
        isReporting = true;
        Navigator.pop(context);
        showReportingProductDialog();
      }
      if (state is ReportProductFailedState) {
        //show failed dialog
        if (isReporting = false) {
          isReporting = false;
          Navigator.pop(context);
          showReportSnack(
              'Segnalazione prodotto non riuscita.', 'FAILED', context);
        }
      }
      if (state is ReportProductCompletedState) {
        //show reported dialog
        if (isReporting) {
          isReporting = false;
          Navigator.pop(context);
          showReportSnack('Prodotto segnalato.', 'REPORTED', context);
        }
      }
    });

    wishlistProductBloc.listen((state) {
      if (state is AddToWishlistCompletedState) {
        print('Aggiunto alla Wishlist');
      }
    });

    postQuestionBloc.listen((state) {
      print('$state');

      if (state is PostQuestionInProgressState) {
        //show popup
        isPostingQuestion = true;
        Navigator.pop(context);
        showUpdatingDialog('Posting your question..\nPlease wait!');
      }
      if (state is PostQuestionFailedState) {
        //show failed popup
        if (isPostingQuestion) {
          Navigator.pop(context);
          showSnack('Failed to post question!', context);
          isPostingQuestion = false;
        }
      }
      if (state is PostQuestionCompletedState) {
        //show popup
        if (isPostingQuestion) {
          Navigator.pop(context);
          showPostedSnack('Posted your question!', context);
          isPostingQuestion = false;

          totalCost = double.parse(_product.price);
          addedExtras = List();
          seletedSize = 0;

          productBloc.add(LoadProductEvent(_product.id));
        }
      }
    });

    rateProductBloc.listen((state) {
      print('RATE PRODUCT BLOC :: $state');

      if (state is CheckRateProductInProgressState) {
        //show popup
        checkRatingProduct = true;
      }
      if (state is CheckRateProductFailedState) {
        //show failed popup
        if (checkRatingProduct) {
          showSnack('Failed to check!', context);
          checkRatingProduct = false;
        }
      }
      if (state is CheckRateProductCompletedState) {
        //show popup
        if (checkRatingProduct) {
          checkRatingProduct = false;

          if (state.result != null) {
            if (state.result == 'RATED') {
              //already rated
              showRateProductPopup(state.review, 'RATED');
            }
            if (state.result == 'NOT_RATED') {
              //not rated
              showRateProductPopup(state.review, 'NOT_RATED');
            }
            if (state.result == 'NOT_ORDERED') {
              //not ordered
              showSnack(
                  'Non puoi recensire questo prodotto, devi prima ordinarlo almeno una volta.',
                  context);
            }
          } else {
            showSnack('Non puoi recensire questo prodotto.', context);
          }
        }
      }

      if (state is RateProductInProgressState) {
        //show popup
        isRatingProduct = true;
        Navigator.pop(context);
        showUpdatingDialog('Pubblico la recensione...\nAttendere...');
      }
      if (state is RateProductFailedState) {
        //show failed popup
        if (isRatingProduct) {
          Navigator.pop(context);
          showSnack('Pubblicazione recensione non riuscita.', context);
          isRatingProduct = false;
        }
      }
      if (state is RateProductCompletedState) {
        //show popup
        if (isRatingProduct) {
          Navigator.pop(context);
          showPostedSnack('Recensione pubblicata.', context);
          isRatingProduct = false;

          productBloc.add(LoadProductEvent(_product.id));
        }
      }
    });
  }

  void addToCart() {
    print('adding to cart');
    if (_currentUser.uid != null) {
      if (_product.inStock) {
        cartBloc.add(AddToCartEvent(
          _product.id,
          _currentUser.uid,
          _product.isExtras
              ? addedExtras.isEmpty
                  ? null
                  : addedExtras
              : null,
          _product.isSizes ? _product.sizes[seletedSize] : null,
          totalCost.toString(),
        ));
        // if (_product.isSizes) {
        //   cartBloc.add(AddToCartEvent(
        //     _product.id,
        //     _currentUser.uid,
        //     addedExtras,
        //     _product.sizes[seletedSize] ?? null,
        //   ));
        // } else {
        //   cartBloc.add(AddToCartEvent(
        //     _product.id,
        //     _currentUser.uid,
        //     addedExtras,
        //     null,
        //   ));
        // }
      } else {
        showReportSnack('Prodotto Esaurito', 'FAILED', context);
      }
    } else {
      //not logged in

    }
  }

  void showReportingProductDialog() {
    showDialog(
      context: context,
      child: AlertDialog(
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'Segnalazione Prodotto',
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              style: GoogleFonts.poppins(
                color: Colors.black.withOpacity(0.9),
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Future showReportProductPopup() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ReportProductDialog(
          productId: widget.productId,
          reportProductBloc: reportProductBloc,
          uid: _currentUser.uid,
        );
      },
    );
  }

  showUpdatingDialog(String s) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: s,
        );
      },
    );
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: Colors.red.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.error,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  void showPostedSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.done,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  Future showPostQuestionPopup() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PostQuestionDialog(
          postQuestionBloc,
          _currentUser.uid,
          _product.id,
        );
      },
    );
  }

  Future showRateProductPopup(Review review, String result) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return RateProductDialog(
          rateProductBloc,
          _currentUser.uid,
          _product.id,
          review,
          result,
          _product,
        );
      },
    );
  }

  Future<void> _createDynamicLink(bool short) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: Config().urlPrefix,
      link: Uri.parse('${Config().urlPrefix}/${_product.id}'),
      androidParameters: AndroidParameters(
        packageName: Config().packageName,
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.google.FirebaseCppDynamicLinksTestApp.dev',
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: _product.name,
        imageUrl: Uri.parse(_product.productImages[0]),
        description: 'Prova questo prodotto!',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    await FlutterShare.share(
      title: 'Prova questo prodotto!',
      text: '${_product.name}',
      linkUrl: url.toString(),
      chooserTitle: 'Condividi',
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var stateProvider = Provider.of<StateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              if (stateProvider.isLoggedIn) {
                Navigator.pushNamed(context, '/cart');
              } else {
                Navigator.pushNamed(context, '/sign_in');
              }
            },
            child: BlocBuilder(
              cubit: cartCountBloc,
              builder: (context, state) {
                if (state is CartCountUpdateState) {
                  cartCount = state.cartCount;
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Icon(
                            Icons.shopping_cart,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      cartCount > 0
                          ? Positioned(
                              right: 3.0,
                              top: 5.0,
                              child: Container(
                                height: 16.0,
                                width: 16.0,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.0),
                                  color: Colors.amber,
                                ),
                                child: Text(
                                  '$cartCount',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  );
                }
                return Icon(
                  Icons.shopping_cart,
                  size: 25.0,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: PopupMenuButton(
              offset: Offset(0, 50.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 1) {
                  showReportProductPopup();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.report,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        'Segnala prodotto',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 16.0,
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              BlocBuilder(
                cubit: productBloc,
                buildWhen: (previous, current) {
                  if (current is LoadProductCompletedState ||
                      current is LoadProductFailedState ||
                      current is LoadProductInProgressState) {
                    return true;
                  } else {
                    return false;
                  }
                },
                builder: (context, state) {
                  print('ProductEvent State: $state');

                  // if (state is ProductInitial) {
                  //   return SizedBox();
                  // } else
                  if (state is LoadProductInProgressState) {
                    return Shimmer.fromColors(
                      period: Duration(milliseconds: 1000),
                      baseColor: Colors.grey.withOpacity(0.5),
                      highlightColor: Colors.black.withOpacity(0.5),
                      child: ShimmerProductDetail(),
                    );
                  } else if (state is LoadProductFailedState) {
                    return Column(
                      children: <Widget>[
                        SizedBox(
                          height: 15.0,
                        ),
                        SvgPicture.asset(
                          'assets/banners/retry.svg',
                          height: 150.0,
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          height: 75.0,
                          width: size.width * 0.7,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: FlatButton(
                            onPressed: () {
                              //TODO: fix this
                              // productBloc.add(LoadSimilarProductsEvent(
                              //     category: 'Fruits & Vegetables',
                              //     subCategory: 'Fruits'));
                              // productBloc
                              //     .add(LoadProductEvent(widget.productId));
                            },
                            color: Colors.lightGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.rotate_right,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 15.0,
                                ),
                                Text(
                                  'Retry loading',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (state is LoadProductCompletedState) {
                    print('');
                    print('ProductEvent State: ${state.product.id}');
                    print('');

                    if (state.product.id != widget.productId) {
                      return SizedBox();
                    }

                    if (_product == null) {
                      _product = state.product;

                      addedExtras = List();
                      seletedSize = 0;

                      totalCost = double.parse(_product.price);

                      print('COST  _______________');
                      print(_product.price);
                      print(totalCost);

                      // discount = ((1 -
                      //             (int.parse(_product.price) /
                      //                 (int.parse(_product.ogPrice)))) *
                      //         100)
                      //     .round()
                      //     .toString();

                      if (_product.reviews.length == 0) {
                      } else {
                        if (_product.reviews.length > 0) {
                          for (var review in _product.reviews) {
                            rating = rating + double.parse(review.rating);
                          }
                          rating = rating / _product.reviews.length;
                        }
                      }

                      if (_product.productImages.length == 0) {
                        productImages.add(
                          Center(
                            child: Text(
                              'Immagine non disponibile.',
                              style: GoogleFonts.poppins(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.75),
                              ),
                            ),
                          ),
                        );
                      } else {
                        for (var item in _product.productImages) {
                          productImages.add(
                            Center(
                              child: FadeInImage.assetNetwork(
                                placeholder:
                                    'assets/icons/category_placeholder.png',
                                image: item,
                                fadeInDuration: Duration(milliseconds: 250),
                                fadeInCurve: Curves.easeInOut,
                                fadeOutDuration: Duration(milliseconds: 150),
                                fadeOutCurve: Curves.easeInOut,
                              ),
                            ),
                          );
                        }
                      }

                      similarProductBloc.add(
                        LoadSimilarProductsEvent(
                          category: _product.category,
                          subCategory: _product.subCategory,
                          productId: _product.id,
                        ),
                      );
                    }

                    // _product = state.product;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 240.0,
                          width: size.width,
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                top: 0,
                                child: Container(
                                  height: 180.0,
                                  padding: const EdgeInsets.only(
                                      bottom: 20.0,
                                      left: 16.0,
                                      right: 16.0,
                                      top: 10.0),
                                  width: size.width,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(25.0),
                                      bottomRight: Radius.circular(25.0),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                width: size.width,
                                child: Container(
                                  height: 230.0,
                                  width: double.infinity,
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 15.0,
                                        offset: Offset(1, 10.0),
                                        spreadRadius: 2.0,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Carousel(
                                      images: productImages,
                                      dotSize: 4.0,
                                      dotSpacing: 15.0,
                                      dotColor: Colors.lightGreenAccent,
                                      dotIncreasedColor: Colors.amber,
                                      autoplayDuration:
                                          Duration(milliseconds: 3000),
                                      autoplay: false,
                                      showIndicator: true,
                                      indicatorBgPadding: 5.0,
                                      dotBgColor: Colors.transparent,
                                      borderRadius: false,
                                      animationDuration:
                                          Duration(milliseconds: 450),
                                      animationCurve: Curves.easeInOut,
                                      boxFit: BoxFit.contain,
                                      dotVerticalPadding: 5.0,
                                      dotPosition: DotPosition.bottomCenter,
                                      noRadiusForIndicator: true,
                                      onImageTap: (index) {
                                        print('Tapped: $index');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FullScreenImageScreen(
                                              images: _product.productImages,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  _product.name,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black.withOpacity(0.75),
                                  ),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Material(
                                      child: InkWell(
                                        splashColor:
                                            Colors.blue.withOpacity(0.5),
                                        onTap: () {
                                          print('Wishlist');

                                          if (!stateProvider.isLoggedIn) {
                                            Navigator.pushNamed(
                                                context, '/sign_in');
                                          } else {
                                            wishlistProductBloc
                                                .add(AddToWishlistEvent(
                                              _product.id,
                                              _currentUser.uid,
                                            ));
                                          }

                                          // wishlistProductBloc
                                          //     .add(AddToWishlistEvent(
                                          //   _product.id,
                                          //   _currentUser.uid,
                                          // ));
                                        },
                                        child: Container(
                                          width: 38.0,
                                          height: 35.0,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.04),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Icon(
                                            Icons.favorite_border,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            size: 20.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15.0,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Material(
                                      child: InkWell(
                                        splashColor:
                                            Colors.blue.withOpacity(0.5),
                                        onTap: () {
                                          print('Share');
                                          _createDynamicLink(true);
                                        },
                                        child: Container(
                                          width: 38.0,
                                          height: 35.0,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.04),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Icon(
                                            Icons.share,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            size: 20.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                '${Config().currency}${totalCost.toStringAsFixed(2)}',
                                overflow: TextOverflow.clip,
                                style: GoogleFonts.poppins(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withOpacity(0.9),
                                ),
                              ),
                              // SizedBox(
                              //   width: 10.0,
                              // ),
                              // Text(
                              //   '${Config().currency}${_product.ogPrice}',
                              //   maxLines: 1,
                              //   overflow: TextOverflow.ellipsis,
                              //   style: GoogleFonts.poppins(
                              //     decoration: TextDecoration.lineThrough,
                              //     color: Colors.black54,
                              //     fontSize: 14.0,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: 15.0,
                              // ),
                              // Text(
                              //   '$discount% off',
                              //   maxLines: 1,
                              //   style: GoogleFonts.poppins(
                              //     fontSize: 14.0,
                              //     color: Colors.green.shade700,
                              //     fontWeight: FontWeight.w500,
                              //     letterSpacing: 0.5,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                _product.inStock ? 'Disponibile' : 'Esaurito',
                                maxLines: 1,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.5,
                                  color: _product.inStock
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Categoria: ${_product.category}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.black.withOpacity(0.85),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     mainAxisSize: MainAxisSize.max,
                        //     crossAxisAlignment: CrossAxisAlignment.end,
                        //     children: <Widget>[
                        //       Container(
                        //         padding: EdgeInsets.symmetric(
                        //             horizontal: 12.0, vertical: 5.0),
                        //         decoration: BoxDecoration(
                        //           color: Colors.green.shade300,
                        //           borderRadius: BorderRadius.circular(7.0),
                        //         ),
                        //         child: Row(
                        //           children: <Widget>[
                        //             Text(
                        //               'Unit:',
                        //               maxLines: 1,
                        //               style: GoogleFonts.poppins(
                        //                 fontSize: 14.0,
                        //                 color: Colors.white,
                        //                 fontWeight: FontWeight.w500,
                        //                 letterSpacing: 0.5,
                        //               ),
                        //             ),
                        //             SizedBox(
                        //               width: 10.0,
                        //             ),
                        //             Text(
                        //               _product.unitQuantity,
                        //               maxLines: 1,
                        //               style: GoogleFonts.poppins(
                        //                 fontSize: 14.0,
                        //                 color: Colors.white,
                        //                 fontWeight: FontWeight.w500,
                        //                 letterSpacing: 0.5,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        _product.isSizes
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Divider(),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                      'Scegli la Dimensione',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  ListView.separated(
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(0),
                                    itemBuilder: (context, index) =>
                                        RadioListTile(
                                      value: index,
                                      groupValue: seletedSize != null
                                          ? seletedSize
                                          : -1,
                                      onChanged: (val) {
                                        setState(() {
                                          seletedSize = val;

                                          totalCost = double.parse(_product
                                              .sizes[seletedSize].price);

                                          if (addedExtras.isNotEmpty) {
                                            for (var item in addedExtras) {
                                              totalCost = totalCost +
                                                  double.parse(item.price);
                                            }
                                          }
                                        });
                                      },
                                      activeColor: Colors.black87,
                                      dense: true,
                                      title: Text(
                                        '${_product.sizes[index].name} - ${Config().currency}${_product.sizes[index].price}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    separatorBuilder: (context, index) =>
                                        SizedBox(),
                                    itemCount: _product.sizes.length,
                                    shrinkWrap: true,
                                  ),
                                ],
                              )
                            : SizedBox(),
                        _product.isExtras
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Divider(),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                      'Ingredienti Extra',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  ListView.separated(
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(0),
                                    addAutomaticKeepAlives: true,
                                    itemBuilder: (context, index) =>
                                        CheckboxListTile(
                                      value: addedExtras
                                          .contains(_product.extras[index]),
                                      selected: addedExtras
                                          .contains(_product.extras[index]),
                                      activeColor: Colors.black87,
                                      onChanged: (val) {
                                        if (val) {
                                          setState(() {
                                            addedExtras
                                                .add(_product.extras[index]);

                                            totalCost = totalCost +
                                                double.parse(_product
                                                    .extras[index].price);
                                          });
                                        } else {
                                          setState(() {
                                            addedExtras
                                                .remove(_product.extras[index]);

                                            totalCost = totalCost -
                                                double.parse(_product
                                                    .extras[index].price);
                                          });
                                        }
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      dense: true,
                                      title: Text(
                                        '${_product.extras[index].name} (+ ${_product.extras[index].price} ${Config().currency})',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    separatorBuilder: (context, index) =>
                                        SizedBox(),
                                    itemCount: _product.extras.length,
                                    shrinkWrap: true,
                                  ),
                                ],
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(),
                        ),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     mainAxisSize: MainAxisSize.max,
                        //     children: <Widget>[
                        //       Expanded(
                        //         child: Container(
                        //           padding: EdgeInsets.symmetric(
                        //               horizontal: 12.0, vertical: 8.0),
                        //           decoration: BoxDecoration(
                        //             color: Colors.black.withOpacity(0.05),
                        //             borderRadius: BorderRadius.circular(15.0),
                        //           ),
                        //           child: Text(
                        //             'Free Delivery',
                        //             maxLines: 1,
                        //             textAlign: TextAlign.center,
                        //             overflow: TextOverflow.ellipsis,
                        //             style: GoogleFonts.poppins(
                        //               fontSize: 13.0,
                        //               color: Colors.brown,
                        //               fontWeight: FontWeight.w500,
                        //               letterSpacing: 0.3,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       SizedBox(
                        //         width: 16.0,
                        //       ),
                        //       Expanded(
                        //         child: Container(
                        //           padding: EdgeInsets.symmetric(
                        //               horizontal: 12.0, vertical: 8.0),
                        //           decoration: BoxDecoration(
                        //             color: Colors.black.withOpacity(0.05),
                        //             borderRadius: BorderRadius.circular(15.0),
                        //           ),
                        //           child: Text(
                        //             'Easy cancellation',
                        //             maxLines: 1,
                        //             textAlign: TextAlign.center,
                        //             overflow: TextOverflow.ellipsis,
                        //             style: GoogleFonts.poppins(
                        //               fontSize: 13.0,
                        //               color: Colors.brown,
                        //               fontWeight: FontWeight.w500,
                        //               letterSpacing: 0.3,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: Divider(),
                        // ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Descrizione',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                _product.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(),
                        ),
                        // SizedBox(
                        //   height: 5.0,
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: <Widget>[
                        //       Text(
                        //         'Additional Information',
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 16.0,
                        //           fontWeight: FontWeight.w600,
                        //           letterSpacing: 0.3,
                        //         ),
                        //       ),
                        //       SizedBox(
                        //         height: 10.0,
                        //       ),
                        //       Text(
                        //         _product.additionalInfo.bestBefore.length == 0
                        //             ? '\u2022 Best before: NA'
                        //             : '\u2022 Best before: ${_product.additionalInfo.bestBefore}',
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 13.5,
                        //           fontWeight: FontWeight.w400,
                        //           letterSpacing: 0.5,
                        //         ),
                        //       ),
                        //       Text(
                        //         _product.additionalInfo.manufactureDate
                        //                     .length ==
                        //                 0
                        //             ? '\u2022 Manufacture date: NA'
                        //             : '\u2022 Manufacture date: ${_product.additionalInfo.manufactureDate}',
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 13.5,
                        //           fontWeight: FontWeight.w400,
                        //           letterSpacing: 0.5,
                        //         ),
                        //       ),
                        //       Text(
                        //         _product.additionalInfo.shelfLife.length == 0
                        //             ? '\u2022 Shelf life: NA'
                        //             : '\u2022 Shelf life: ${_product.additionalInfo.shelfLife}',
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 13.5,
                        //           fontWeight: FontWeight.w400,
                        //           letterSpacing: 0.5,
                        //         ),
                        //       ),
                        //       Text(
                        //         _product.additionalInfo.brand.length == 0
                        //             ? '\u2022 Brand: NA'
                        //             : '\u2022 Brand: ${_product.additionalInfo.brand}',
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 13.5,
                        //           fontWeight: FontWeight.w400,
                        //           letterSpacing: 0.5,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: Divider(),
                        // ),
                        // SizedBox(
                        //   height: 5.0,
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: <Widget>[
                        //       Row(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: <Widget>[
                        //           Expanded(
                        //             child: Text(
                        //               'Questions & Answers',
                        //               style: GoogleFonts.poppins(
                        //                 fontSize: 16.0,
                        //                 fontWeight: FontWeight.w600,
                        //                 letterSpacing: 0.3,
                        //               ),
                        //             ),
                        //           ),
                        //           Container(
                        //             height: 33.0,
                        //             child: FlatButton(
                        //               onPressed: () {
                        //                 //post question
                        //                 showPostQuestionPopup();
                        //               },
                        //               color: Theme.of(context).primaryColor,
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     BorderRadius.circular(10.0),
                        //               ),
                        //               child: Text(
                        //                 'Post Question',
                        //                 style: GoogleFonts.poppins(
                        //                   color: Colors.white,
                        //                   fontSize: 13.5,
                        //                   fontWeight: FontWeight.w500,
                        //                   letterSpacing: 0.3,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       SizedBox(
                        //         height: 12.0,
                        //       ),
                        //       _product.queAndAns.length == 0
                        //           ? Padding(
                        //               padding: const EdgeInsets.all(8.0),
                        //               child: Center(
                        //                 child: Text(
                        //                   'No questions found!',
                        //                   textAlign: TextAlign.center,
                        //                   overflow: TextOverflow.clip,
                        //                   style: GoogleFonts.poppins(
                        //                     color:
                        //                         Colors.black.withOpacity(0.7),
                        //                     fontSize: 14.5,
                        //                     fontWeight: FontWeight.w500,
                        //                     letterSpacing: 0.3,
                        //                   ),
                        //                 ),
                        //               ),
                        //             )
                        //           : Column(
                        //               children: <Widget>[
                        //                 ListView.separated(
                        //                   shrinkWrap: true,
                        //                   physics:
                        //                       NeverScrollableScrollPhysics(),
                        //                   padding: const EdgeInsets.only(
                        //                       bottom: 10.0),
                        //                   itemBuilder: (context, index) {
                        //                     return QuestionAnswerItem(
                        //                         _product.queAndAns[index]);
                        //                   },
                        //                   separatorBuilder: (context, index) {
                        //                     return Divider();
                        //                   },
                        //                   itemCount:
                        //                       _product.queAndAns.length > 3
                        //                           ? 3
                        //                           : _product.queAndAns.length,
                        //                 ),
                        //                 _product.queAndAns.length > 3
                        //                     ? Column(
                        //                         mainAxisSize: MainAxisSize.min,
                        //                         crossAxisAlignment:
                        //                             CrossAxisAlignment.start,
                        //                         mainAxisAlignment:
                        //                             MainAxisAlignment.start,
                        //                         children: <Widget>[
                        //                           Divider(),
                        //                           Container(
                        //                             height: 36.0,
                        //                             width: double.infinity,
                        //                             child: FlatButton(
                        //                               onPressed: () {
                        //                                 //TODO: take to all questions screen
                        //                                 Navigator.push(
                        //                                   context,
                        //                                   MaterialPageRoute(
                        //                                     builder: (context) =>
                        //                                         AllQuestionsScreen(
                        //                                             _product
                        //                                                 .queAndAns),
                        //                                   ),
                        //                                 );
                        //                               },
                        //                               color: Colors.transparent,
                        //                               padding:
                        //                                   const EdgeInsets.all(
                        //                                       0),
                        //                               shape:
                        //                                   RoundedRectangleBorder(
                        //                                 borderRadius:
                        //                                     BorderRadius
                        //                                         .circular(10.0),
                        //                               ),
                        //                               child: Container(
                        //                                 alignment: Alignment
                        //                                     .centerLeft,
                        //                                 child: Text(
                        //                                   'View All Questions',
                        //                                   style: GoogleFonts
                        //                                       .poppins(
                        //                                     color:
                        //                                         Colors.black87,
                        //                                     fontSize: 14.0,
                        //                                     fontWeight:
                        //                                         FontWeight.w500,
                        //                                     letterSpacing: 0.3,
                        //                                   ),
                        //                                 ),
                        //                               ),
                        //                             ),
                        //                           ),
                        //                         ],
                        //                       )
                        //                     : SizedBox(),
                        //               ],
                        //             ),
                        //     ],
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: Divider(),
                        // ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      'Recensioni',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 33.0,
                                    child: FlatButton(
                                      onPressed: () {
                                        //rate
                                        rateProductBloc
                                            .add(CheckRateProductEvent(
                                          _currentUser.uid,
                                          _product.id,
                                          _product,
                                        ));
                                      },
                                      color: Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Text(
                                        'Vota',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          '${_product.reviews.length}',
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          style: GoogleFonts.poppins(
                                            color: Colors.green.shade700,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text(
                                          'recensioni',
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.3,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          _product.reviews.length == 0
                                              ? '0'
                                              : '${rating.toStringAsFixed(1)}',
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          style: GoogleFonts.poppins(
                                            color: Colors.green.shade700,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 1.5),
                                          child: Text(
                                            '\u2605',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.clip,
                                            style: GoogleFonts.poppins(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              _product.reviews.length == 0
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Center(
                                        child: Text(
                                          'Ancora nessuna recensione.',
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          style: GoogleFonts.poppins(
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: <Widget>[
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          itemBuilder: (context, index) {
                                            return ReviewItem(
                                              review: _product.reviews[index],
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return Divider();
                                          },
                                          itemCount: _product.reviews.length > 3
                                              ? 3
                                              : _product.reviews.length,
                                        ),
                                        _product.reviews.length > 3
                                            ? Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Divider(),
                                                  Container(
                                                    height: 36.0,
                                                    width: double.infinity,
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        //TODO: take to all reviews screen
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                AllReviewsScreen(
                                                              _product.reviews,
                                                              rating,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      color: Colors.transparent,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      child: Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Vedi Recensioni',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            letterSpacing: 0.3,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else
                    return Shimmer.fromColors(
                      period: Duration(milliseconds: 1000),
                      baseColor: Colors.grey.withOpacity(0.5),
                      highlightColor: Colors.black.withOpacity(0.5),
                      child: ShimmerProductDetail(),
                    );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(),
              ),
              SizedBox(
                height: 5.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      'Prodotti Correlati',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              BlocBuilder(
                cubit: similarProductBloc,
                builder: (context, state) {
                  print('SIMILAR PRODUCTS :: $state');
                  if (state is LoadSimilarProductsInProgressState) {
                    return Container(
                      height: 280.0,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            period: Duration(milliseconds: 800),
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.black.withOpacity(0.5),
                            child: ShimmerProductListItem(),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            width: 20.0,
                          );
                        },
                      ),
                    );
                  } else if (state is LoadSimilarProductsFailedState) {
                    return Center(
                      child: Text(
                        'Caricamento prodotti correlati non riuscito.',
                        style: GoogleFonts.poppins(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    );
                  } else if (state is LoadSimilarProductsCompletedState) {
                    if (state.productList.length == 0) {
                      return Center(
                        child: Text(
                          'Nessun prodotto correlato.',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      );
                    }
                    _similarProducts = state.productList;
                    return Container(
                      height: 280.0,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: _similarProducts.length > 5
                            ? 5
                            : _similarProducts.length,
                        itemBuilder: (context, index) {
                          return ProductListItem(
                            product: _similarProducts[index],
                            cartBloc: cartBloc,
                            currentUser: _currentUser,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            width: 20.0,
                          );
                        },
                      ),
                    );
                  } else {
                    return SizedBox();
                  }
                },
              ),
              SizedBox(
                height: 95.0,
              ),
            ],
          ),
          buildAddToCart(size, context),
        ],
      ),
    );
  }

  Widget buildAddToCart(Size size, BuildContext context) {
    var isLoggedIn = Provider.of<StateProvider>(context).isLoggedIn;
    return Positioned(
      bottom: 0,
      child: Container(
        height: 80.0,
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white70,
              Colors.white54,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: BlocBuilder(
          cubit: cartBloc,
          builder: (context, state) {
            // if (state is AddToCartInProgressState) {
            //   return FlatButton(
            //     onPressed: () {
            //       //temporary
            //     },
            //     color: Theme.of(context).primaryColor,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(15.0),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       mainAxisSize: MainAxisSize.max,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: <Widget>[
            //         Container(
            //           height: 25.0,
            //           width: 25.0,
            //           child: CircularProgressIndicator(
            //             backgroundColor: Colors.white,
            //             strokeWidth: 3.0,
            //             valueColor:
            //                 AlwaysStoppedAnimation<Color>(Colors.black38),
            //           ),
            //         ),
            //         SizedBox(
            //           width: 15.0,
            //         ),
            //         Text(
            //           'Adding to cart',
            //           style: GoogleFonts.poppins(
            //             fontSize: 15.0,
            //             fontWeight: FontWeight.w500,
            //             letterSpacing: 0.3,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ],
            //     ),
            //   );
            // }
            // if (state is AddToCartFailedState) {
            //   //create snack
            // }
            // if (state is AddToCartCompletedState) {
            //   //create snack
            //   // showSnack();
            //   return FlatButton(
            //     onPressed: () {
            //       //temporary
            //     },
            //     color: Theme.of(context).primaryColor,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(15.0),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       mainAxisSize: MainAxisSize.max,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: <Widget>[
            //         Icon(
            //           Icons.shopping_cart,
            //           color: Colors.white,
            //         ),
            //         SizedBox(
            //           width: 15.0,
            //         ),
            //         Text(
            //           'Added to cart',
            //           style: GoogleFonts.poppins(
            //             fontSize: 15.0,
            //             fontWeight: FontWeight.w500,
            //             letterSpacing: 0.3,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ],
            //     ),
            //   );
            // }
            return FlatButton(
              onPressed: () {
                //add to cart
                if (isLoggedIn) {
                  addToCart();
                } else {
                  Navigator.pushNamed(context, '/sign_in');
                }
              },
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    'Aggiungi al Carrello',
                    style: GoogleFonts.poppins(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void showReportSnack(String text, String type, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: type == 'FAILED' ? Colors.red : Colors.green,
      animationDuration: Duration(milliseconds: 350),
      isDismissible: true,
      duration: Duration(milliseconds: 2500),
      icon: Icon(
        Icons.error,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }
}
