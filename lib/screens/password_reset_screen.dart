import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordResetScreen extends StatefulWidget {
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  String email;
  bool inProgress = false;
  FirebaseAuth auth = FirebaseAuth.instance;

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

  resetPassword() async{
    if(_formKey.currentState.validate()) {
      _formKey.currentState.save()
      ;
     setState(() {
       inProgress = true;
     });

     try {
      await auth.sendPasswordResetEmail(email: email).then((value) {

        print('Email Sent');
        setState(() {
          inProgress = false;
        });
        Navigator.pop(context);

      }).catchError((e) {
      print(e);
      setState(() {
        inProgress = false;
        showFailedSnakbar('Password Reset Failed');

      });
      });


     } catch (e) {
       print(e);
       setState(() {
         inProgress = false;
         showFailedSnakbar('Password Reset Failed');

       });
     }

    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Reset Password'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))
        ),


      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 20,),
            Text('A link will be sent to the provided email address.',

            ),
SizedBox(height: 20,),
            Form(
key: _formKey,
              child:   TextFormField(
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
            ),
SizedBox(height: 20,),
            buildSignInButton(size, context),
          ],
        ),
      ),
    );

  }

  Widget buildSignInButton(Size size, BuildContext context) {
    return Center(
      child: inProgress ? CircularProgressIndicator() : Container(
        width: size.width,
        height: 48.0,
        child: FlatButton(
          onPressed: () {
          resetPassword();
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
}
