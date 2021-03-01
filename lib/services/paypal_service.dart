import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert' as convert;
import 'package:http_auth/http_auth.dart';

class PaypalServices {
  String domain = "https://api.sandbox.paypal.com"; // for sandbox mode
//  String domain = "https://api.paypal.com"; // for production mode

  // change clientId and secret with your own, provided by paypal
  String clientId =
      'AZb2QsOaGGem-DIwcQ1oa5TL1CswNtLOgz9qVW7gFewPG-nstLlTDIiqLQqFjVCl0dW33g-sAao6YJME';
  String secret =
      'ECQmzWj7Nh0Zn356dD_GA_R_e280S4icdTMYSq9X2ntgGiNTKFZ0KADDjzWaacbk2wnAVjN9ktqyoXf7';

  // for getting the access token from Paypal
  Future<String> getAccessToken() async {
    try {
      var client = BasicAuthClient(clientId, secret);
      var response = await client
          .post('$domain/v1/oauth2/token?grant_type=client_credentials');
      if (response.statusCode == 200) {
        print('RESPONSE :: $response');
        print('RESPONSE :: ${response.body}');
        print('RESPONSE :: ${response.statusCode}');

        final body = convert.jsonDecode(response.body);

        print(body['access_token']);

        return body['access_token'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // for creating the payment request with Paypal
  Future<Map<String, String>> createPaypalPayment(
      transactions, accessToken) async {
    try {
      var response = await http.post("$domain/v2/checkout/orders",
          body: convert.jsonEncode({
            'intent': "AUTHORIZE",
            "purchase_units": [
              {
                "amount": {
                  "currency_code": "USD",
                  "value": "100.00",
                }
              }
            ]
          }),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);
      print(body);

      if (response.statusCode == 201) {
        if (body["links"] != null && body["links"].length > 0) {
          List links = body["links"];

          String executeUrl = "";
          String approvalUrl = "";
          String captureUrl = "";
          final item = links.firstWhere((o) => o["rel"] == "approve",
              orElse: () => null);
          if (item != null) {
            approvalUrl = item['href'];
          }
          final item1 = links.firstWhere((o) => o["rel"] == "execute",
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1['href'];
          }
          final item2 = links.firstWhere((o) => o["rel"] == "authorize",
              orElse: () => null);
          if (item != null) {
            captureUrl = item2['href'];
          }
          return {
            "executeUrl": executeUrl,
            "approvalUrl": approvalUrl,
            "captureUrl": captureUrl
          };
        }
        return null;
      } else {
        throw Exception(body["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  // for executing the payment transaction
  Future<String> executePayment(url, payerId, accessToken) async {
    try {
      var response = await http.post(url,
          // body: convert.jsonEncode({"payer_id": payerId}),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);

      print('TRANSACTION :: $body');

      if (response.statusCode == 200) {
        return body;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  } // for executing the payment transaction

  Future<String> capturePayment(url, accessToken) async {
    try {
      var response = await http.post(url,
          // body: convert.jsonEncode({"payer_id": payerId}),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);

      print('CAPTURE PAYMENT :: $body');

      if (response.statusCode == 200) {
        return body['id'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
