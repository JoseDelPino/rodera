import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './home.dart';
import './signUp.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Builder(
          builder: (context) => Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Image.asset("images/rodera_logo_bw_warm.png"),
                  Container(
                    margin: const EdgeInsets.only(
                        right: 50.0, left: 50.0, top: 15.0, bottom: 15.0),
                    child: TextFormField(
                      validator: (input) {
                        Pattern pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regex = new RegExp(pattern);
                        if (input.isEmpty) {
                          return 'Provide an email.';
                        } else if (!regex.hasMatch(input)) {
                          return 'Please enter a correct email. ';
                        }
                      },
                      decoration: InputDecoration(labelText: 'Email'),
                      onSaved: (input) => _email = input,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        right: 50.0, left: 50.0, top: 15.0, bottom: 30.0),
                    child: TextFormField(
                      validator: (input) {
                        if (input.length < 6) {
                          return 'The password must contain more than 6 characters.';
                        }
                      },
                      decoration: InputDecoration(labelText: 'Password'),
                      onSaved: (input) => _password = input,
                      obscureText: true,
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      signIn(context);
                    },
                    child: Text('SIGN IN'),
                    color: Colors.black,
                    textColor: Colors.white,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                    child: Text('New to Rodera?', textScaleFactor: 1.2),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUp()));
                    },
                    child: Text('SIGN UP'),
                    color: Colors.black,
                    textColor: Colors.white,
                  ),
                ],
              )),
        ));
  }

  void signIn(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FocusScope.of(context).requestFocus(new FocusNode());
      try {
        FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
        if(user.isEmailVerified){
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyHome(title: 'Rodera', myFirebaseUser: user)));
        }else{
          final snackBar = SnackBar(content: Text('Please verify your email first.'));
          Scaffold.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
        final snackBar = SnackBar(content: Text('Either the user or the password are not correct.'));
        Scaffold.of(context).showSnackBar(snackBar);
      }
    }
  }
}
