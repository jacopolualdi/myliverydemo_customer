import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/models/cart_values.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widget/processing_dialog.dart';

class AddAddressScreen extends StatefulWidget {
  final User currentUser;
  final GroceryUser user;

  AddAddressScreen({this.currentUser, this.user});

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AccountBloc accountBloc;
  bool isAdded;
  String addressLine1,
      addressLine2,
      houseNo,
      landmark,
      city,
      state,
      pincode,
      country;

  Address address = Address();
  List<Address> allAddresses = List();

  bool isDefault;
  int defaultAddress;

  CartBloc cartBloc;
  CartValues cartValues;

  @override
  void initState() {
    super.initState();

    isDefault = false;
    isAdded = false;

    defaultAddress = int.parse(widget.user.defaultAddress);

    accountBloc = BlocProvider.of<AccountBloc>(context);
    cartBloc = BlocProvider.of<CartBloc>(context);

    cartBloc.add(GetCartValuesEvent());

    allAddresses = widget.user.address;

    accountBloc.listen((state) {
      print(state);

      if (isAdded) {
        if (state is AddAddressCompletedState) {
          Navigator.pop(context);
          Navigator.pop(context, true);
        }
        if (state is AddAddressFailedState) {
          //show popup
          showSnack('Aggiunta indirizzo non riuscita.', context);
        }
        if (state is AddAddressInProgressState) {
          //show popup
          showUpdatingDialog();
        }
      }
    });
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Aggiungo indirizzo...\nAttendere...',
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

  void addAddress() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      print('save address');
      print(addressLine1);
      print(addressLine2);
      print(city);
      print(state);
      print(country);
      print(pincode);
      print(landmark);
      print(houseNo);

      Map<String, dynamic> addressMap = Map();
      addressMap.putIfAbsent('addressLine1', () => addressLine1 ?? '');
      addressMap.putIfAbsent('addressLine2', () => addressLine2 ?? '');
      addressMap.putIfAbsent('city', () => city ?? '');
      addressMap.putIfAbsent('state', () => state ?? '');
      addressMap.putIfAbsent('country', () => country ?? '');
      addressMap.putIfAbsent('pincode', () => pincode ?? '');
      addressMap.putIfAbsent('landmark', () => landmark ?? '');
      addressMap.putIfAbsent('houseNo', () => houseNo ?? '');

      // widget.user.address.add(address);
      allAddresses.add(Address.fromHashmap(addressMap));

      if (allAddresses.length == 1) {
        defaultAddress = 0;
      }

      accountBloc.add(
        AddAddressEvent(
          allAddresses,
          widget.currentUser.uid,
          defaultAddress == -1 ? 0 : defaultAddress,
        ),
      );
      print('after');

      isAdded = true;
    }
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
                      'Aggiungi Indirizzo',
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
              cubit: cartBloc,
              buildWhen: (previous, current) {
                if (current is GetCartValuesCompletedState ||
                    current is GetCartValuesFailedState ||
                    current is GetCartValuesInProgressState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetCartValuesInProgressState) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state is GetCartValuesFailedState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/banners/retry.svg',
                        width: size.width * 0.6,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        'Caricamento non riuscito.',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.9),
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
                if (state is GetCartValuesCompletedState) {
                  cartValues = state.cartValues;

                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                validator: (String val) {
                                  if (val.trim().isEmpty) {
                                    return 'Per favore, indica il numero civico.';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  houseNo = val.trim();
                                },
                                enableInteractiveSelection: false,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  helperStyle: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.65),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.home,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 50.0,
                                  ),
                                  labelText: 'Numero Civico',
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                validator: (String val) {
                                  if (val.trim().isEmpty) {
                                    return 'Per favore, inserisci l\'indirizzo';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  addressLine1 = val.trim();
                                },
                                enableInteractiveSelection: false,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  helperStyle: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.65),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 50.0,
                                  ),
                                  labelText: 'Indirizzo',
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                // validator: (String val) {
                                //   if (val.trim().isEmpty) {
                                //     return 'Address line 2 is required';
                                //   }
                                //   return null;
                                // },
                                onSaved: (val) {
                                  addressLine2 = val.trim();
                                },
                                enableInteractiveSelection: false,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  helperStyle: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.65),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 50.0,
                                  ),
                                  labelText: 'Indirizzo secondario (opzionale)',
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                onSaved: (val) {
                                  landmark = val.trim();
                                },
                                enableInteractiveSelection: false,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  helperStyle: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.65),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.local_convenience_store,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 50.0,
                                  ),
                                  labelText: 'Citofono (opzionale)',
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                validator: (String val) {
                                  if (val.trim().isEmpty) {
                                    return 'Per favore, indica la città.';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  city = val.trim();
                                },
                                readOnly: cartValues.cartInfo.city.isNotEmpty
                                    ? true
                                    : false,
                                initialValue: cartValues.cartInfo.city,
                                enableInteractiveSelection: false,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  helperStyle: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.65),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_city,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 50.0,
                                  ),
                                  labelText: 'Città',
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                validator: (String val) {
                                  if (val.trim().isEmpty) {
                                    return 'Per favore, indica la provincia.';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  this.state = val.trim();
                                },
                                enableInteractiveSelection: false,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  helperStyle: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.65),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.map,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 50.0,
                                  ),
                                  labelText: 'Provincia',
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                validator: (String val) {
                                  if (val.trim().isEmpty) {
                                    return 'Per favore, inserisci il CAP';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  pincode = val.trim();
                                },
                                enableInteractiveSelection: false,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  helperStyle: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.65),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.my_location,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 50.0,
                                  ),
                                  labelText: 'CAP',
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                validator: (String val) {
                                  if (val.trim().isEmpty) {
                                    return 'Per favore, inserisci la Nazione';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  country = val.trim();
                                },
                                enableInteractiveSelection: false,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  helperStyle: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.65),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 50.0,
                                  ),
                                  labelText: 'Nazione',
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              CheckboxListTile(
                                dense: true,
                                value: isDefault,
                                onChanged: (value) {
                                  if (value) {
                                    defaultAddress = widget.user.address.length;
                                  } else {
                                    defaultAddress =
                                        int.parse(widget.user.defaultAddress);
                                  }
                                  setState(() {
                                    isDefault = value;
                                  });

                                  print(defaultAddress);
                                },
                                activeColor: Theme.of(context).primaryColor,
                                title: Text(
                                  'Imposta come Indirizzo Principale',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                height: 45.0,
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: FlatButton(
                                  onPressed: () {
                                    //add address
                                    addAddress();
                                  },
                                  color: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.add_location,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                        'Salva Indirizzo',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
