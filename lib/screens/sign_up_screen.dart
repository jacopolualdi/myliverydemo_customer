import 'package:apple_sign_in/apple_sign_in.dart' as apple;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/providers/state_provider.dart';
import 'package:grocery_store/screens/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';

import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignupBloc signupBloc;

  MaskedTextController mobileNoController;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String mobileNo, email, name, password;
  bool inProgress;
  bool appleinProgress;
  bool emailinProgress;
  String prefixCode = '+39';

  @override
  void initState() {
    super.initState();
    inProgress = false;
    appleinProgress = false;
    emailinProgress = false;

    mobileNoController = MaskedTextController(mask: '0000000000');
    signupBloc = BlocProvider.of<SignupBloc>(context);

    signupBloc.listen((state) {
      if (state is SignupWithGoogleInitialCompleted) {
        //proceed to save details
        if (state.firebaseUser.displayName != null) {
          name = state.firebaseUser.displayName;
        } else {
          name = state.firebaseUser.email;
        }
        email = state.firebaseUser.email;

        db
            .collection(Paths.usersPath)
            .doc(state.firebaseUser.uid)
            .get()
            .then((doc) {
          if (!doc.exists) {
            signupBloc.add(SaveUserDetails(
              name: name,
              mobileNo: '',
              email: email,
              firebaseUser: state.firebaseUser,
              loggedInVia: 'GOOGLE',
            ));
          } else {
            setState(() {
              inProgress = false;
            });
            signupBloc.close();
            Provider.of<StateProvider>(context, listen: false)
                .changeLoggedIn(true);
            Navigator.popAndPushNamed(context, '/home');
          }
        });
      }
      if (state is SignupWithEmailInitialCompleted) {
        //proceed to save details


        db
            .collection(Paths.usersPath)
            .doc(state.firebaseUser.uid)
            .get()
            .then((doc) {
          if (!doc.exists) {
            signupBloc.add(SaveUserDetails(
              name: name,
              mobileNo: '',
              email: email,
              firebaseUser: state.firebaseUser,
              loggedInVia: 'EMAIL',
            ));
          } else {
            setState(() {
              emailinProgress = false;
            });
            signupBloc.close();
            Provider.of<StateProvider>(context, listen: false)
                .changeLoggedIn(true);
            Navigator.popAndPushNamed(context, '/home');
          }
        });
      }

      if (state is SignupWithAppleInitialCompleted) {
        //proceed to save details
        name = state.firebaseUser.displayName;
        email = state.firebaseUser.email;

        db
            .collection(Paths.usersPath)
            .doc(state.firebaseUser.uid)
            .get()
            .then((doc) {
          if (!doc.exists) {
            signupBloc.add(SaveUserDetails(
              name: name,
              mobileNo: '',
              email: email,
              firebaseUser: state.firebaseUser,
              loggedInVia: 'APPLE',
            ));
          } else {
            setState(() {
              appleinProgress = false;
            });
            signupBloc.close();
            Provider.of<StateProvider>(context, listen: false)
                .changeLoggedIn(true);
            Navigator.popAndPushNamed(context, '/home');
          }
        });
      }
      if (state is SignupWithGoogleInitialFailed) {
        //failed to sign in with google
        print('failed to sign in with google');
        showFailedSnakbar('Accesso non riuscito');
        setState(() {
          inProgress = false;
        });
      }

      if (state is SignupWithEmailInitialFailed) {
        //failed to sign in with email
        print('failed to sign in with email');
        showFailedSnakbar("Accesso non riuscito, prova a utilizzare un'altra email");
        setState(() {
          emailinProgress = false;
        });
      }

      if (state is SignupWithAppleInitialFailed) {
        //failed to sign in with google
        print('failed to sign in with apple');
        showFailedSnakbar('Accesso non riuscito');
        setState(() {
          appleinProgress = false;
        });
      }

      if (state is CompletedSavingUserDetails) {
        print(state.user.email);
        //proceed to home
        //close signupBloc

        signupBloc.close();
        Provider.of<StateProvider>(context, listen: false).changeLoggedIn(true);
        Navigator.popAndPushNamed(context, '/home');
      }
      if (state is FailedSavingUserDetails) {
        //failed saving user details
        print('failed to save');
        showFailedSnakbar('Salvataggio dati non riuscito.');

        setState(() {
          inProgress = false;
          appleinProgress = false;
        });
      }
      if (state is SavingUserDetails) {
        //saving user details
        print('Salvataggio dati utente');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // signupBloc.close();
  }

  signUpWithEmail() {
    if (_formKey.currentState.validate()) {
      //proceed
      _formKey.currentState.save();
      // signupBloc.add(
      //     SignupWithMobileNo(email: email, mobileNo: mobileNo, name: name));

     signupBloc.add(SignupWithEmail(email, password));
     setState(() {
       emailinProgress = true;
     });
    }
  }

  signUpWithMobileNo() {
    //validate first
    if (_formKey.currentState.validate()) {
      //proceed
      _formKey.currentState.save();
      // signupBloc.add(
      //     SignupWithMobileNo(email: email, mobileNo: mobileNo, name: name));
      mobileNo = '$prefixCode$mobileNo';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: email,
            mobileNo: mobileNo,
            name: name,
            isSigningIn: false,
          ),
        ),
      );
    }
  }

  signUpWithGoogle() {
    signupBloc.add(SignupWithGoogle());
  }

  signUpWithApple() {
    signupBloc.add(SignupWithApple());
  }

  void showFailedSnakbar(String s) {
    SnackBar snackbar = SnackBar(
      content: Text(
        s,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Theme.of(context).primaryColor,
      action: SnackBarAction(
          label: 'OK', textColor: Colors.white, onPressed: () {}),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var stateProvider = Provider.of<StateProvider>(context);
    final appleSignInAvailable =
        Provider.of<StateProvider>(context).appleAvailable;
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Container(
              height: 200.0,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColorDark,
                    Theme.of(context).primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/banners/signup_top.svg',
                    fit: BoxFit.fitWidth,
                  ),
                  Positioned(
                    left: 12.0,
                    top: 35.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () {
                            Navigator.popAndPushNamed(context, '/sign_in');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: 38.0,
                            height: 35.0,
                            child: Icon(
                              Icons.close,
                              color: Colors.white.withOpacity(0.85),
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: size.height - 200.0,
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Crea un Account',
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.85),
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: nameController,
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.isEmpty) {
                              return 'Per favore, inserisci Nome e Cognome';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            name = val;
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
                              Icons.person,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'Nome e Cognome',
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
                        // SizedBox(
                        //   height: 20.0,
                        // ),
                        // TextFormField(
                        //   controller: mobileNoController,
                        //   textAlignVertical: TextAlignVertical.center,
                        //   validator: (String val) {
                        //     if (val.isEmpty) {
                        //       return 'Per favore, inserisci un Numero Cellulare';
                        //     }
                        //     // else if (val.length != 10) {
                        //     //   return 'Mobile No. is invalid';
                        //     // }
                        //     return null;
                        //   },
                        //   onSaved: (val) {
                        //     mobileNo = val;
                        //   },
                        //   enableInteractiveSelection: false,
                        //   style: GoogleFonts.poppins(
                        //     color: Colors.black,
                        //     fontSize: 14.5,
                        //     fontWeight: FontWeight.w500,
                        //     letterSpacing: 0.5,
                        //   ),
                        //   textInputAction: TextInputAction.done,
                        //   keyboardType: TextInputType.number,
                        //   decoration: InputDecoration(
                        //     contentPadding: EdgeInsets.all(0),
                        //     helperStyle: GoogleFonts.poppins(
                        //       color: Colors.black.withOpacity(0.65),
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     prefix: CountryCodePicker(
                        //         initialSelection: '+39',
                        //         showDropDownButton: true,
                        //         showFlag: false,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             prefixCode = value.dialCode;
                        //             print(prefixCode);
                        //           });
                        //         }),
                        //     // prefixText: '${Config().countryMobileNoPrefix} ',
                        //     prefixStyle: GoogleFonts.poppins(
                        //       color: Colors.black87,
                        //       fontWeight: FontWeight.w500,
                        //       fontSize: 14.5,
                        //     ),
                        //     errorStyle: GoogleFonts.poppins(
                        //       fontSize: 13.0,
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     hintStyle: GoogleFonts.poppins(
                        //       color: Colors.black54,
                        //       fontSize: 14.5,
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     prefixIcon: Icon(
                        //       Icons.phone,
                        //     ),
                        //     prefixIconConstraints: BoxConstraints(
                        //       minWidth: 50.0,
                        //     ),
                        //     labelText: 'Numero Cellulare',
                        //     labelStyle: GoogleFonts.poppins(
                        //       fontSize: 14.5,
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(12.0),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          controller: emailController,
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return 'Per favore, inserisci un indirizzo email';
                            }
                            if (!RegExp(
                                    r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$")
                                .hasMatch(val)) {
                              return 'Indirizzo email non valido';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            email = val;
                          },
                          enableInteractiveSelection: false,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.emailAddress,
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
                              Icons.email,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'Indirizzo Email',
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
                          controller: passwordController,
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return 'Per favore inserire una password';
                            }
                            if (val.trim().length < 8) {
                              return 'la password dovrebbe essere almeno 8';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            password = val;
                          },
                          enableInteractiveSelection: false,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,

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
                              Icons.vpn_key_rounded,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: "parola d'ordine",
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                    child: Text(
                      'Registrandoti dichiari di aver letto e di approvare la nostra Privacy Policy e i Termini & Condizioni, disponibili sul nostro sito e/o sulla pagina di download di questa app.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10.0,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: emailinProgress ? CircularProgressIndicator() : Container(
                      width: size.width,
                      height: 48.0,
                      child: FlatButton(
                        onPressed: () {
                          //validate inputs
                          signUpWithEmail();


                        },
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          'Registrati',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                    child: Center(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Divider(
                              color: Colors.black54,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text(
                              'OPPURE',
                              style: GoogleFonts.poppins(
                                color: Colors.black54,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  if (appleSignInAvailable) buildAppleSignupButton(size),
                  SizedBox(
                    height: 20.0,
                  ),
                  buildGoogleSignupButton(size),
                  SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppleSignupButton(Size size) {
    return Center(
      child: appleinProgress
          ? CircularProgressIndicator()
          : Container(
              width: size.width,
              height: 48.0,
              child: FlatButton(
                onPressed: () {
                  signUpWithApple();
                  setState(() {
                    appleinProgress = true;
                  });
                },
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.apple,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Text(
                      'Registrati con Apple',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildGoogleSignupButton(Size size) {
    return Center(
      child: inProgress
          ? CircularProgressIndicator()
          : Container(
              width: size.width,
              height: 48.0,
              child: FlatButton(
                onPressed: () {
                  signUpWithGoogle();
                  setState(() {
                    inProgress = true;
                  });
                },
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Text(
                      'Registrati con Google',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
