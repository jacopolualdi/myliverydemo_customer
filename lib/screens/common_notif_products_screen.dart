import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/notif_products_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/widget/product_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/widget/shimmer_product_list_item.dart';
import 'package:shimmer/shimmer.dart';

class CommonNotifProductsScreen extends StatefulWidget {
  final String productType;
  final User currentUser;
  final CartBloc cartBloc;

  CommonNotifProductsScreen({
    this.productType,
    this.currentUser,
    this.cartBloc,
  });

  @override
  _CommonNotifProductsScreenState createState() =>
      _CommonNotifProductsScreenState();
}

class _CommonNotifProductsScreenState extends State<CommonNotifProductsScreen> {
  NotifProductsBloc notifProductsBloc;

  List<Product> productList;

  @override
  void initState() {
    super.initState();

    notifProductsBloc = BlocProvider.of<NotifProductsBloc>(context);
    notifProductsBloc.add(GetNotifProducts(widget.productType));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: 38.0,
                            height: 35.0,
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'Tutti i Prodotti ${widget.productType}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder(
              cubit: notifProductsBloc,
              buildWhen: (previous, current) {
                if (current is GetNotifProductsCompletedState ||
                    current is GetNotifProductsFailedState ||
                    current is GetNotifProductsInProgressState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetNotifProductsInProgressState) {
                  return GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1 / 1.6,
                      crossAxisSpacing: 16.0,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        period: Duration(milliseconds: 800),
                        baseColor: Colors.grey.withOpacity(0.5),
                        highlightColor: Colors.black.withOpacity(0.5),
                        child: ShimmerProductListItem(),
                      );
                    },
                  );
                } else if (state is GetNotifProductsFailedState) {
                  return Center(
                    child: Text(
                      'Caricamento prodotti non riuscito.',
                      style: GoogleFonts.poppins(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                }
                if (state is GetNotifProductsCompletedState) {
                  if (state.productList.length == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/images/empty_prod.svg',
                          width: size.width * 0.6,
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          'Nessun prodotto in questa categoria.',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                      ],
                    );
                  }
                  productList = state.productList;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1 / 1.6,
                      crossAxisSpacing: 16.0,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    itemCount: productList.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return ProductListItem(
                        product: productList[index],
                        cartBloc: widget.cartBloc,
                        currentUser: widget.currentUser,
                      );
                    },
                  );
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
