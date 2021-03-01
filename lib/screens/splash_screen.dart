import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/providers/state_provider.dart';
import 'package:grocery_store/screens/home_screen.dart';
import 'package:grocery_store/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SigninBloc signinBloc;
  Map<dynamic, Widget> mapping = {1: SignInScreen(), 2: HomeScreen()};

  @override
  void initState() {
    super.initState();
    var stateProvider = Provider.of<StateProvider>(context, listen: false);
    signinBloc = BlocProvider.of<SigninBloc>(context);

    signinBloc.listen((state) {
      if (state is CheckIfSignedInCompleted) {
        //proceed to home
        print('logged in');

        if (state.res.isEmpty) {
          stateProvider.changeLoggedIn(true);
          Navigator.popAndPushNamed(context, '/home');
        } else {
          // Navigator.popAndPushNamed(context, '/sign_in');
          stateProvider.changeLoggedIn(false);
          Navigator.popAndPushNamed(context, '/home');
        }
      }
      if (state is NotLoggedIn) {
        //proceed to sign in
        print('not logged in');
      }
      if (state is FailedToCheckLoggedIn) {
        //proceed to sign in
        print('failed to check if logged in');
        // Navigator.popAndPushNamed(context, '/sign_in');
        stateProvider.changeLoggedIn(false);
        Navigator.popAndPushNamed(context, '/home');
      }
    });

    signinBloc.add(CheckIfSignedIn());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // Timer(Duration(milliseconds: 0), () {
    //   Navigator.popAndPushNamed(context, '/sign_in');
    // });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/icona_master.svg',
              width: size.width * 0.25,
              height: size.width * 0.25,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'App Sviluppata da Mylivery\nwww.mylivery.app',
              style: GoogleFonts.poppins(
                color: Colors.black.withOpacity(0.85),
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
