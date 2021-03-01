import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/models/my_order.dart';

class TrackOrderScreen extends StatefulWidget {
  final MyOrder myOrder;

  const TrackOrderScreen({Key key, @required this.myOrder}) : super(key: key);

  @override
  _TrackOrderScreenState createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  GoogleMapController googleMapController;
  Marker marker;
  Circle circle;

  StreamSubscription subscription;

  static double currentLatitude = 0.0;
  static double currentLongitude = 0.0;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    subscription = FirebaseFirestore.instance
        .collection(Paths.ordersPath)
        .doc(widget.myOrder.orderId)
        .snapshots()
        .listen((event) {
      MyOrder myOrder = MyOrder.fromFirestore(event);
      setState(() {
        currentLatitude = myOrder.deliveryDetails.locationDetails.latitude;
        currentLongitude = myOrder.deliveryDetails.locationDetails.longitude;
      });

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentLatitude, currentLongitude),
            zoom: 17,
          ),
        ),
      );

      getCurrentLocation(myOrder.deliveryDetails.locationDetails);

      // googleMapController.addMarker(
      //   MarkerOptions(
      //     position: LatLng(event.snapshot.value['latitude'],
      //         event.snapshot.value['longitude']),
      //   ),
      // );
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context)
        .load('assets/icons/delivery-man.png');
    return byteData.buffer.asUint8List();
  }

  void getCurrentLocation(LocationDetails locationDetails) async {
    try {
      Uint8List imageData = await getMarker();

      updateMarkerAndCircle(locationDetails, imageData);
    } catch (e) {
      print(e);
    }
  }

  void updateMarkerAndCircle(
      LocationDetails locationDetails, Uint8List imageData) {
    LatLng latLng = LatLng(locationDetails.latitude, locationDetails.longitude);
    this.setState(() {
      marker = Marker(
        markerId: MarkerId('value'),
        position: latLng,
        flat: true,
        icon: BitmapDescriptor.fromBytes(imageData),
        zIndex: 2,
        anchor: Offset(0.5, 0.5),
        draggable: false,
      );

      circle = Circle(
        circleId: CircleId('value'),
        center: latLng,
        radius: 18,
        strokeWidth: 1,
        strokeColor: Colors.blue,
        zIndex: 1,
        fillColor: Colors.blue.withAlpha(70),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
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
                          'Traccia Ordine',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          StreamBuilder<Object>(
              stream: null,
              builder: (context, snapshot) {
                return Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                    markers: Set.of((marker != null) ? [marker] : []),
                    circles: Set.of((circle != null) ? [circle] : []),
                    onMapCreated: (controller) {
                      setState(() {
                        googleMapController = controller;
                      });
                    },
                  ),
                );
              }),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(
      //     Icons.location_on,
      //   ),
      // ),
    );
  }
}
