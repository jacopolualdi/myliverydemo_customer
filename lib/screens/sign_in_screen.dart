import 'package:country_code_picker/country_code_picker.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/pages/home_page.dart';
import 'package:grocery_store/providers/state_provider.dart';
import 'package:grocery_store/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'verification_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  MaskedTextController mobileNoController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  String mobileNo, email, password;
  bool inProgress;
  bool emailinProgress;
  bool appleinProgress;
  SigninBloc signinBloc;
  String prefixCode;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    inProgress = false;
    appleinProgress = false;
    emailinProgress = false;
    mobileNoController = MaskedTextController(mask: '0000000000');
    signinBloc = BlocProvider.of<SigninBloc>(context);

//TODO:Detect if signed up or not while signing in

    signinBloc.listen((state) {
      if (state is SignInWithAppleInProgress) {
        print('sign in with apple in progress');

        setState(() {
          appleinProgress = true;
        });
      }

      if (state is SigninWithAppleCompleted) {
        print('sign in with apple completed');
        Provider.of<StateProvider>(context, listen: false).changeLoggedIn(true);
        //proceed

        setState(() {
          appleinProgress = false;
        });

        if (state.result.isEmpty) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else {
          showFailedSnakbar(state.result);
        }
      }
      if (state is SigninWithAppleFailed) {
        //failed
        print('sign in with apple failed');
        setState(() {
          appleinProgress = false;
        });
        showFailedSnakbar('Accesso con Apple non riuscito.');
      }
      if (state is SignInWithAppleInProgress) {
        print('sign in with apple in progress');

        setState(() {
          appleinProgress = true;
        });
      }

      if (state is SigninWithEmailCompleted) {
        print('sign in with email completed');
        Provider.of<StateProvider>(context, listen: false).changeLoggedIn(true);
        //proceed

        setState(() {
          emailinProgress = false;
        });

        if (state.result.isEmpty) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (route) => false,
          );
        } else {
          showFailedSnakbar(state.result);
        }
      }
      if (state is SignInWithEmailInProgress) {
        print('sign in with email in progress');

        setState(() {
          emailinProgress = true;
        });
      }
      if (state is SigninWithEmailFailed) {
        //failed
        print('sign in with email failed');
        setState(() {
          emailinProgress = false;
        });
        showFailedSnakbar('Email o password errate.');
      }
      if (state is SignInWithGoogleInProgress) {
        print('sign in with google in progress');

        setState(() {
          inProgress = true;
        });
      }
      if (state is SigninWithGoogleFailed) {
        //failed
        print('sign in with google failed');
        setState(() {
          inProgress = false;
        });
        showFailedSnakbar('Accesso con Google non riuscito.');
      }
      if (state is SigninWithGoogleCompleted) {
        print('sign in with google completed');
        Provider.of<StateProvider>(context, listen: false).changeLoggedIn(true);
        //proceed

        setState(() {
          inProgress = false;
        });

        if (state.result.isEmpty) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else {
          showFailedSnakbar(state.result);
        }
      }
      if (state is CheckIfBlockedInProgress) {
        print('in progress');
      }
      if (state is CheckIfBlockedFailed) {
        //failed
        print('failed to check');
        setState(() {
          inProgress = false;
        });
        showFailedSnakbar('Accesso non riuscito.');
      }
      if (state is CheckIfBlockedCompleted) {
        setState(() {
          inProgress = false;
        });
        if (state.result.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                mobileNo: mobileNo,
                isSigningIn: true,
              ),
            ),
          );
        } else {
          showFailedSnakbar(state.result);
        }
      }
    });
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
      backgroundColor: Colors.red,
      action: SnackBarAction(
          label: 'OK', textColor: Colors.white, onPressed: () {}),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final appleSignInAvailable =
        Provider.of<StateProvider>(context).appleAvailable;
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
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
              child: SvgPicture.asset(
                'assets/banners/signin_top.svg',
                fit: BoxFit.fitWidth,
              ),
            ),
            Container(
              height: size.height - 200.0,
              width: size.width,
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
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
                    'Benvenuto',
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.85),
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Accedi o Registrati e ordina subito!',
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
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
                  SizedBox(
                    height: 20.0,
                  ),
                  buildSignInButton(size, context),
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
                  if (appleSignInAvailable) buildAppleSignInButton(size),
                  SizedBox(
                    height: 20.0,
                  ),
                  buildGoogleSignInButton(size),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        'Non hai un Account?',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/sign_up');
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          'Registrati',
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSignInButton(Size size, BuildContext context) {
    return Center(
      child: emailinProgress ? CircularProgressIndicator() : Container(
        width: size.width,
        height: 48.0,
        child: FlatButton(
          onPressed: () {
            signInWithEmail();
          },
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Text(
            'Accedi',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGoogleSignInButton(Size size) {
    return Center(
      child: inProgress
          ? CircularProgressIndicator()
          : Container(
              width: size.width,
              height: 48.0,
              child: FlatButton(
                onPressed: () {
                  signinBloc.add(SignInWithGoogle());
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
                      'Accedi con Google',
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

  Widget buildAppleSignInButton(Size size) {
    return Center(
      child: appleinProgress
          ? CircularProgressIndicator()
          : Container(
              width: size.width,
              height: 48.0,
              child: FlatButton(
                onPressed: () {
                  signinBloc.add(SignInWithApple());
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
                      'Accedi con Apple',
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

  void signInWithMobile() {

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      mobileNo = '$prefixCode$mobileNo';
      signinBloc.add(CheckIfBlocked(mobileNo));
      inProgress = true;
    }
  }

  void signInWithEmail() {
    if(_formKey.currentState.validate()) {
      _formKey.currentState.save()
;
      signinBloc.add(SignInWithEmail(email, password));
      setState(() {
        emailinProgress = true;
      });

    }
  }

}
