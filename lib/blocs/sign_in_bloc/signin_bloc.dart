import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/repositories/authentication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'signin_event.dart';
part 'signin_state.dart';

class SigninBloc extends Bloc<SigninEvent, SigninState> {
  final AuthenticationRepository authenticationRepository;

  SigninBloc({this.authenticationRepository}) : super(null);

  SigninState get initialState => SigninInitial();

  @override
  Stream<SigninState> mapEventToState(
    SigninEvent event,
  ) async* {
    if (event is SignInWithGoogle) {
      yield* mapSignInWithGoogleToState();
    }
    if (event is SignInWithEmail) {
      yield* mapSignInWithEmailToState(event.email, event.password);
    }


    if (event is SignInWithApple) {
      yield* mapSignInWithAppleToState();
    }
    if (event is SignInWithMobileNo) {
      yield* mapSignInWithMobileNoToState(event.mobileNo);
    }
    if (event is CheckIfBlocked) {
      yield* mapCheckIfBlockedToState(event.mobileNo);
    }
    if (event is CheckIfSignedIn) {
      yield* mapCheckIfSignedInToState();
    }
    if (event is GetCurrentUser) {
      yield* mapGetCurrentUserToState();
    }
    if (event is SignoutEvent) {
      yield* mapSignoutEventToState();
    }
    if (event is VerifyMobileNo) {
      yield* mapVerifyMobileNoToState(event.otp);
    }
  }

  Stream<SigninState> mapSignInWithGoogleToState() async* {
    yield SignInWithGoogleInProgress();

    try {
      String res = await authenticationRepository.signInWithGoogle();
      if (res != null) {
        yield SigninWithGoogleCompleted(res);
      } else {
        yield SigninWithGoogleFailed();
      }
    } catch (e) {
      print(e);
      yield SigninWithGoogleFailed();
    }
  }

  Stream<SigninState> mapSignInWithEmailToState(String email, String password) async* {
    yield SignInWithEmailInProgress();

    try {
      String res = await authenticationRepository.signInWithEmail(email, password);
      if (res != null) {
        yield SigninWithEmailCompleted(res);
      } else {
        yield SigninWithEmailFailed();
      }
    } catch (e) {
      print(e);
      yield SigninWithEmailFailed();
    }
  }

  Stream<SigninState> mapSignInWithAppleToState() async* {
    yield SignInWithAppleInProgress();

    try {
      String res = await authenticationRepository.signInWithApple();
      if (res != null) {
        yield SigninWithAppleCompleted(res);
      } else {
        yield SigninWithAppleFailed();
      }
    } catch (e) {
      print(e);
      yield SigninWithAppleFailed();
    }
  }

  Stream<SigninState> mapSignInWithMobileNoToState(String mobileNo) async* {
    yield SignInWithMobileNoInProgress();

    try {
      bool isSent = await authenticationRepository.signInWithMobileNo(mobileNo);
      if (isSent) {
        yield SigninWithMobileNoCompleted();
      } else {
        yield SigninWithMobileNoFailed();
      }
    } catch (e) {
      print('ERROR');
      print(e);
      yield SigninWithMobileNoFailed();
    }
  }

  Stream<SigninState> mapCheckIfBlockedToState(String mobileNo) async* {
    yield CheckIfBlockedInProgress();

    try {
      String res = await authenticationRepository.checkIfBlocked(mobileNo);
      if (res != null) {
        yield CheckIfBlockedCompleted(res);
      } else {
        yield CheckIfBlockedFailed();
      }
    } catch (e) {
      print(e);
      yield CheckIfBlockedFailed();
    }
  }

  Stream<SigninState> mapCheckIfSignedInToState() async* {
    try {
      String res = await authenticationRepository.isLoggedIn();
      if (res != null) {
        yield CheckIfSignedInCompleted(res);
      } else {
        yield FailedToCheckLoggedIn();
      }
    } catch (e) {
      print(e);
      yield FailedToCheckLoggedIn();
    }
  }

  Stream<SigninState> mapGetCurrentUserToState() async* {
    try {
      User currentUser = await authenticationRepository.getCurrentUser();
      if (currentUser != null) {
        yield GetCurrentUserCompleted(currentUser);
      } else {
        yield GetCurrentUserFailed();
      }
    } catch (e) {
      print(e);
      yield GetCurrentUserFailed();
    }
  }

  Stream<SigninState> mapSignoutEventToState() async* {
    yield SignoutInProgress();
    try {
      bool isSignedOut = await authenticationRepository.signOutUser();
      if (isSignedOut) {
        yield SignoutCompleted();
      } else {
        yield SignoutFailed();
      }
    } catch (e) {
      print(e);
      yield SignoutFailed();
    }
  }

  Stream<SigninState> mapVerifyMobileNoToState(String otp) async* {
    yield VerifyMobileNoInProgress();
    try {
      User user = await authenticationRepository.signInWithSmsCode(otp);
      if (user != null) {
        yield VerifyMobileNoCompleted(user);
      } else {
        yield VerifyMobileNoFailed();
      }
    } catch (e) {
      print(e);
      yield VerifyMobileNoFailed();
    }
  }
}
