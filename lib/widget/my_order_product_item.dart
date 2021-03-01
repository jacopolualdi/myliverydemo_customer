import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/my_order.dart';
import 'package:grocery_store/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrderProductItem extends StatelessWidget {
  final OrderProduct product;

  const MyOrderProductItem({this.product});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    String extras = '';
    if (product.isExtras) {
      for (var item in product.extras) {
        if (extras.isEmpty) {
          extras = extras + '${item.name}';
        } else {
          extras = extras + ', ${item.name}';
        }
      }
    }
    return Container(
      // height: product.isExtras ? 180.0 : 150.0,
      width: size.width,
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 115.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  width: 104.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11.0),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/icons/category_placeholder.png',
                      image: product.productImage,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration(milliseconds: 250),
                      fadeInCurve: Curves.easeInOut,
                      fadeOutDuration: Duration(milliseconds: 150),
                      fadeOutCurve: Curves.easeInOut,
                    ),
                  ),
                ),
                SizedBox(
                  width: 12.0,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0, right: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${product.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Text(
                              'Q.tà: ${product.quantity}',
                              style: GoogleFonts.poppins(
                                color: Colors.black54,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      product.isSizes
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  'Dimensione: ${product.size.name}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      Column(
                        children: [
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            'Categoria: ${product.category}',
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      // Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0, right: 3.0),
                        child: Text(
                          '${Config().currency}${product.totalAmt}',
                          style: GoogleFonts.poppins(
                            color: Colors.green.shade700,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          product.isExtras
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 13,
                    ),
                    Text(
                      'Ingr. Extra: $extras',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
