import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/Products.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app_return/models/HttpException.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  late String? _userId;
  Timer? _authTimer;

  void setToken(String newToken){
    _token = newToken;
    notifyListeners();
  }

  bool get isAuth {
    // If the token is null, isAuth returns false, indicating that the user is not authenticated.
    _token != null ? print("isAuth = True") : print("isAuth = false");
    // notifyListeners();
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

  String? get userId {
    return _userId;
  }

  String? errorMessage;
  FutureOr<void> _authenticate(
      String email, String password, String urlSegment) async {
    const apiKey = 'AIzaSyCA_UVHMNDLnP-No9l6k7rQ8xBTMIffxLY';
    Uri url = Uri.https(
        'identitytoolkit.googleapis.com', '/v1/accounts:$urlSegment',
        {'key': apiKey});
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['error'] != null) {
        // meaning we have a problem
        print("Auth class responseData: ${responseData['error']['message']}");
        throw HttpException(message: responseData['error']['message']);
      }
      setToken(responseData['idToken']);
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add((Duration(seconds: int.parse(responseData['expiresIn']))));
      print("Auth class TOKEN: $_token");
      print("Auth class responseData['expiresIn']: ${_expiryDate?.toIso8601String()}");
      _autoLogout();

      // Save the user info to auto log him in later
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', _token!);
      prefs.setString('userId', _userId!);
      prefs.setString('expiryDate', _expiryDate!.toIso8601String());
    } catch (error) {
      print("Exception Type: ${error.runtimeType}");
      if (error is HttpException) {
        print("Auth: ${error.message}");
        errorMessage ??= error.message.toString();
        print("Auth Error Message: $errorMessage");
      } else {
        print("Other Exceptions: $error");
        errorMessage ??= error.toString();
        print("Error Message: $errorMessage");
      }
    } finally{
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    return await _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return await _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin([BuildContext? context]) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDateString = prefs.getString('expiryDate') as String;
    final expiryDate = DateTime.tryParse(expiryDateString);

    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _expiryDate = expiryDate;

    // Debugging statements
    print('Token from SharedPreferences: $_token');
    print('User ID from SharedPreferences: $_userId');
    print('Expiry Date from SharedPreferences: $_expiryDate');

    if (_token == null || _userId == null) {
      print('Token or User ID is null.');
      return false;
    }
    // Trigger a new update for the products based on the retrieved user token and id
    Provider.of<Products>(context!, listen: false).fetchAndSetProducts(updateToken: _token, updateUserId: _userId);
    notifyListeners();
    _autoLogout();
    print('Auto-login successful.');
    return true;

  }

    Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _authTimer?.cancel();
    _authTimer = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout(){
    _authTimer?.cancel();
    // use the conditional access operator (?.) to call difference only if _expiryDate is not null:
    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    // set a new timer:
    _authTimer = Timer(Duration(seconds: timeToExpiry ?? 0 ), logout);
    // notifyListeners();
  }
}
