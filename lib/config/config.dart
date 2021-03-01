import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_store/providers/state_provider.dart';

class Config {
  String onboardingImage1 = 'assets/banners/shop_at_ease.svg';
  String onboardingImage2 = 'assets/banners/wide_categories.svg';
  String onboardingImage3 = 'assets/banners/easy_returns.svg';

//TODO: change below given title and subtitle as per your requirement
  String onboardingPage1Title = 'Shop at ease';
  String onboardingPage1Subtitle =
      'Just add the products to cart and have them delivered to you in 60 minutes';

  String onboardingPage2Title = 'Wide categories';
  String onboardingPage2Subtitle =
      'Select the products as per your need from our wide range of categories';

  String onboardingPage3Title = 'Easy returns';
  String onboardingPage3Subtitle =
      'Hand over the product to our delivery agent with no questions asked';

//TODO: change the currency and country prefix as per your need
  String currency = '\€';
  String countryMobileNoPrefix = "+39";

  void changeCode(value) {
    countryMobileNoPrefix = value;
  }

  //stripe api keys
  String apiBase = 'https://api.stripe.com';
  String currencyCode = 'eur';

  //dynamic link url
  String urlPrefix = 'https://myliverydemo.page.link';

  String packageName = 'com.mylivery.democustomer';

  String countryCode = StateProvider().code;

  List<String> reportList = [
    'Descrizione prodotto inappropriata',
    'Prodotto rovinato',
    'Nome prodotto fuorviante',
    'Prezzo troppo alto',
    'Altro',
  ];

  List<String> cancelOrderReasons = [
    'Non più necessario',
    'Inviato per errore',
    'Ordinati prodotti errati',
    'I prezzi dei prodotti sono cambiati',
    'Altro',
  ];

  //razorpay
  String companyName = 'myliverydemo';
  String razorpayCreateOrderIdUrl = 'RAZORPAY_FIREBASE_FUNCTION_URL';
  String razorpayKey = 'RAZORPAY_KEY';
}
