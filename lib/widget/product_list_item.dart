import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/providers/state_provider.dart';
import 'package:grocery_store/screens/product_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final CartBloc cartBloc;
  final User currentUser;
  ProductListItem({
    @required this.product,
    this.cartBloc,
    @required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Provider.of<StateProvider>(context).isLoggedIn;
    return GestureDetector(
      onTap: () {
        print('Open Product');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(
              productId: product.id,
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 1 / 1.7,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/icons/category_placeholder.png',
                          alignment: Alignment.center,
                          image: product.productImages[0],
                          fadeInDuration: Duration(milliseconds: 250),
                          fadeInCurve: Curves.easeInOut,
                          fit: BoxFit.cover,
                          fadeOutDuration: Duration(milliseconds: 150),
                          fadeOutCurve: Curves.easeInOut,
                        ),
                      ),
                    ),
                    product.trending
                        ? Positioned(
                            height: 40.0,
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Shimmer.fromColors(
                                baseColor: Colors.white60,
                                highlightColor: Colors.white,
                                period: Duration(milliseconds: 1000),
                                child: Text(
                                  'Più Richiesti',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${product.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.85),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Categoria: ${product.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.75),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${Config().currency}${product.price}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Material(
                        child: InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          onTap: () {
                            print('Aggiungi al Carrello');
                            if (isLoggedIn) {
                              cartBloc.add(AddToCartEvent(
                                product.id,
                                currentUser.uid,
                                product.isExtras ? [] : null,
                                product.isSizes ? product.sizes[0] : null,
                                product.price,
                              ));
                            } else {
                              Navigator.pushNamed(context, '/sign_in');
                            }
                          },
                          child: Container(
                            width: 38.0,
                            height: 35.0,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.01),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                width: 0.8,
                                color: Colors.black.withOpacity(0.15),
                              ),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              color: Colors.black.withOpacity(0.7),
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                      
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
