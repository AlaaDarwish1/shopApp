import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app_return/models/HttpException.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  // ignore: unused_field
  String? _userId;

  void setToken(String newToken){
    _token = newToken;
    print(_token);
    notifyListeners();
  }

  bool get isAuth {
    // If the token is null, isAuth returns false, indicating that the user is not authenticated.
    _token != null ? print("True") : print("false");
    return _token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }



  String? errorMessage;
  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    Uri url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCA_UVHMNDLnP-No9l6k7rQ8xBTMIffxLY');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        // meaning we have a problem
        print(responseData['error']['message']);
        throw HttpException(message: responseData['error']['message']);
      }
      // _token = responseData['idToken'];
      print(_token);
      setToken(responseData['idToken']);
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add((Duration(seconds: int.parse(responseData['expiresIn']))));
      notifyListeners();
    } catch (error) {
      print("Exception Type: ${error.runtimeType}");
      if (error is HttpException) {
        print("Auth: ${error.message}");
        errorMessage = error.message.toString();
        print("Auth Error Message: $errorMessage");
      } else {
        print("Other Exceptions: $error");
        errorMessage = error.toString();
        print("Error Message: $errorMessage");
      }
    }
  }

  Future<void> signUp(String email, String password) async {
    return await _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return await _authenticate(email, password, 'signInWithPassword');
  }
}
