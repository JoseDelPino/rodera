import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import './signIn.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Image.asset("images/rodera_logo_bw_cold.png"),
              Container(
                margin: const EdgeInsets.only(
                    right: 50.0, left: 50.0, top: 15.0, bottom: 15.0),
                child: TextFormField(
                  validator: (input) {
                    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                    RegExp regex = new RegExp(pattern);
                    if (input.isEmpty) {
                      return 'Provide an email.';
                    }else if(!regex.hasMatch(input)){
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
                onPressed: signUp,
                child: Text('REGISTER'),
                color: Colors.black,
                textColor: Colors.white,
              ),
              Container(
                margin: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                child:
                    Text('Already a member of Rodera?', textScaleFactor: 1.2),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignIn()));
                },
                child: Text('SIGN IN'),
                color: Colors.black,
                textColor: Colors.white,
              ),
            ],
          )),
    );
  }

  void signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignIn()));
      } catch (e) {
        print(e.message);
      }
    }
  }
}
