import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rodera/main.dart';

class viewMyProfile extends StatefulWidget {
  viewMyProfile({Key key, this.myFirebaseUser,}) : super(key: key);

  final FirebaseUser myFirebaseUser;

  @override
  _viewMyProfileState createState() => new _viewMyProfileState();
}

class _viewMyProfileState extends State<viewMyProfile> {

  Profile profile;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<String> _getImageURI() async {
    String uri = await FirebaseStorage.instance
        .ref()
        .child("profile_images/" + widget.myFirebaseUser.uid.toString())
        .getDownloadURL();
    return uri;
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getImageURI(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(child: RefreshProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if(profile!=null){
              return _buildProfileEdit(context);
            }
            return _buildProfileView(snapshot.data);
        }
        return null; // unreachable
      },
    );
  }

  Widget _buildProfileView(String uri) {
    return Scaffold(

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
              child: new CircleAvatar(
                  backgroundImage: new NetworkImage(uri), radius: 60.0)),
          Container(
            margin: const EdgeInsets.only(right: 50.0, left: 50.0, top: 15.0),
            child: ListTile(
              title: Text("Nombre:"),
              subtitle: Text(widget.myFirebaseUser.email == null
                  ? "No se ha elegido un nombre."
                  : widget.myFirebaseUser.email.toString()),
            ),
          ),
          Container(
            margin:
            const EdgeInsets.only(right: 50.0, left: 50.0, bottom: 15.0),
            child: ListTile(
              title: Text("Email:"),
              subtitle: Text(widget.myFirebaseUser.email == null
                  ? "No se ha elegido un email."
                  : widget.myFirebaseUser.email.toString()),
            ),
          ),
          Container(
            child: widget.myFirebaseUser.uid == widget.myFirebaseUser.uid ? RaisedButton(
              onPressed: () => setState(() {
                Image image = new Image(image: NetworkImage(uri));
                profile = new Profile(
                    widget.myFirebaseUser.displayName != null
                        ? widget.myFirebaseUser.displayName
                        : "",
                    widget.myFirebaseUser.email != null ? widget.myFirebaseUser.email : "",
                    image);

              }),
              child: Text('EDIT'),
              color: Colors.black,
              textColor: Colors.white,

            ) : RaisedButton(
              onPressed: () => setState(() {
                Image image = new Image(image: NetworkImage(uri));
                profile = new Profile(
                    widget.myFirebaseUser.displayName != null
                        ? widget.myFirebaseUser.displayName
                        : "",
                    widget.myFirebaseUser.email != null ? widget.myFirebaseUser.email : "",
                    image);

              }),
              child: Text('EDIT'),
              color: Colors.black,
              textColor: Colors.white,

            ), //or any other widget but not null
          ),
        ],
      ),
    );
  }

  Future _pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      profile.image = image as Image;
    });
  }

  final _formKey = GlobalKey<FormState>();
  Widget _buildProfileEdit(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: profile.image == null
                ? IconButton(
                icon: new Icon(Icons.account_circle),
                color: Colors.blueAccent,
                iconSize: 120.0,
                onPressed: _pickImage)
                : new CircleAvatar(
              child: profile.image,
              radius: 60.0,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 50.0, left: 50.0, top: 10.0),
            child: TextFormField(
              controller: nameController,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                  hintText: profile.name, labelText: 'Name'),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 50.0, left: 50.0),
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  Pattern pattern =
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                  RegExp regex = new RegExp(pattern);
                  if (!regex.hasMatch(value))
                    return 'Enter Valid Email';
                  else
                    return null;
                }
              },
              decoration: new InputDecoration(
                  hintText: profile.email, labelText: 'Email'),
            ),
          ),
          Container(
            margin:
            const EdgeInsets.only(right: 50.0, left: 50.0, bottom: 20.0),
            child: TextFormField(
              controller: passwordController,
              keyboardType: TextInputType.text,
              validator: (input) {
                if (input != null && input.isNotEmpty) {
                  if (input.length < 6) {
                    return 'The password must contain more than 6 characters.' +
                        input.toString();
                  }
                }
              },
              decoration: new InputDecoration(
                  hintText: '******', labelText: 'Password'),
              obscureText: true,
            ),
          ),
          RaisedButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                try {
                  if (nameController.text != null &&
                      nameController.text.isNotEmpty) {
                    UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
                    userUpdateInfo.displayName = nameController.text; 
                    widget.myFirebaseUser.updateProfile(userUpdateInfo);
                  }
                  if (emailController.text != null &&
                      emailController.text.isNotEmpty) {
                    widget.myFirebaseUser.updateEmail(emailController.text);
                  }
                  if (passwordController.text != null &&
                      passwordController.text.isNotEmpty) {
                    widget.myFirebaseUser.updatePassword(passwordController.text);
                  }
                  if (profile.image != null) {
                    FirebaseStorage.instance
                        .ref()
                        .child("profile_images/" + widget.myFirebaseUser.uid.toString())
                        .putFile(profile.image as File);
                    UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
                    userUpdateInfo.photoUrl =
                        "profile_images/" + widget.myFirebaseUser.uid.toString();
                    widget.myFirebaseUser.updateProfile(userUpdateInfo);
                  }
                } catch (e) {
                  print(e.message);
                }
              }
            },
            child: Text('SUBMIT'),
            color: Colors.black,
            textColor: Colors.white,
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: RaisedButton(
              onPressed: () => {
              setState(() {
                profile = null;
              })
              },
              textColor: Colors.white,
              color: Colors.redAccent,
              child: Text('CANCEL'),
            ),
          ),
        ],
      ),
    );
  }
}
