import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_return/providers/Auth.dart';

import 'ProductsOverview.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = "AuthScreen";

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(0, 128, 128,
                            0.3), // Lighter teal color with reduced opacity
                        Color.fromRGBO(0, 255, 255,
                            0.7), // Even lighter teal color with reduced opacity
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0, 1])),
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 120),
                height: deviceSize.height,
                width: deviceSize.width,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        child: Text(
                          "MyShop",
                          style: TextStyle(
                            color: Colors.teal.shade600,
                            fontSize: 50,
                            fontFamily: 'AmaticSC-Bold',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: AuthCard(),
                      flex: deviceSize.width > 600 ? 2 : 1,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  var _isLoading = false;


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
     showDialog(
        context: context,
        builder: (context) =>
          AlertDialog(
            title: Text("An Error Occurred"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                  Navigator.of(context).pop()
                ,
                child: Text("Okay"),
              ),
            ],
          ),
        );
  }

  void _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    String? errorMessage =
        Provider.of<Auth>(context, listen: false).errorMessage;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
      print('${_authData['password']} sth ${_authData['email']}');
    }
      if (context.mounted){
        if (_authMode == AuthMode.Login) {
          await Provider.of<Auth>(context, listen: false)
              .logIn(_authData['email']!, _authData['password']!);
        } if (_authMode == AuthMode.Signup) {
          await Provider.of<Auth>(context, listen: false)
              .signUp(_authData['email']!, _authData['password']!);
        }
      }


    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "E-Mail"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty != false ||
                        value?.contains('@') == false) {
                      return 'Invald email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _authData['email'] = value!;
                    });

                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value?.isEmpty != false || (value?.length ?? 0) < 5) {
                      return 'Password Is Too Short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    controller: _confirmPasswordController,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              print("Password Dosn't match");
                              return "Password Dosn't match";
                            }
                            return null;
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.teal.shade400,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed:  _submit,
                      child: Text(
                        _authMode == AuthMode.Login ? "Login" : "Signup",
                        style: TextStyle(color: Colors.white),
                      )),
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      textStyle: TextStyle(color: Colors.brown),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  onPressed: _switchAuthMode,
                  child: Text(
                    '${_authMode == AuthMode.Login ? "SIGNUP" : "LOGIN"}',
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
