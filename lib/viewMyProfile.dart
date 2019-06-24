import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rodera/main.dart';

class viewMyProfile extends StatefulWidget {
  viewMyProfile({Key key, this.myFirebaseUser}) : super(key: key);

  final FirebaseUser myFirebaseUser;

  @override
  _viewMyProfileState createState() => new _viewMyProfileState();
}

class _viewMyProfileState extends State<viewMyProfile> {
  File imageFile;
  bool editing;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<String> imageURI;

  @override
  void initState() {
    imageURI = _getImageURI(); // only create the future once.
    super.initState();
  }

  Future<String> _getImageURI() async {
    try {
      String uri = await FirebaseStorage.instance
          .ref()
          .child("profile_images/" + widget.myFirebaseUser.uid.toString())
          .getDownloadURL();
      print(uri);
      return uri;
    } catch (e) {
      print("BOAB");
      return "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: imageURI,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(child: RefreshProgressIndicator());
          case ConnectionState.done:
            if (editing != null) {
              if(editing == true){
                return _buildProfileEdit(context, snapshot.data);
              }
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
              backgroundImage: new NetworkImage(uri),
              radius: 60.0,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 50.0, left: 50.0, top: 15.0),
            child: ListTile(
              title: Text("Nombre:"),
              subtitle: Text(widget.myFirebaseUser.displayName == null
                  ? "No se ha elegido un nombre."
                  : widget.myFirebaseUser.displayName.toString()),
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
              child: RaisedButton(
            onPressed: () => setState(() {
                  Image image = new Image(image: NetworkImage(uri));
                  editing = true;

                }),
            child: Text('EDIT'),
            color: Colors.black,
            textColor: Colors.white,
          ) //or any other widget but not null
              ),
        ],
      ),
    );
  }

  Future _pickImage() async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
      imageFile = image;
    });
  }

  final _formKey = GlobalKey<FormState>();
  Widget _buildProfileEdit(BuildContext context, String uri) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: imageFile == null
                ? GestureDetector(
          onTap: () {
    _pickImage();
    },
      child: new Container(
        child: new CircleAvatar(
          backgroundImage: new NetworkImage(uri),
          radius: 60.0,
        ),
      ),
    )
                : GestureDetector(
                    onTap: () {
                      _pickImage();
                    },
                    child: new Container(
                      child: new CircleAvatar(
                        backgroundImage: Image.file(imageFile).image,
                        radius: 60.0,
                      ),
                    ),
                  ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 50.0, left: 50.0, top: 10.0),
            child: TextFormField(
              controller: nameController,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                  hintText: widget.myFirebaseUser.displayName, labelText: 'Name'),
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
                  hintText: widget.myFirebaseUser.email, labelText: 'Email'),
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
              print("Se entra en el update");
              if (_formKey.currentState.validate()) {
                try {
                  if (nameController.text != null &&
                      nameController.text.isNotEmpty) {
                    UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
                    userUpdateInfo.displayName = nameController.text;
                    widget.myFirebaseUser.updateProfile(userUpdateInfo);
                    Firestore.instance
                        .collection('users')
                        .document(widget.myFirebaseUser.uid)
                        .updateData({"name": nameController.text});
                  }
                  if (emailController.text != null &&
                      emailController.text.isNotEmpty) {
                    widget.myFirebaseUser.updateEmail(emailController.text);
                    Firestore.instance
                        .collection('users')
                        .document(widget.myFirebaseUser.uid)
                        .updateData({"email": emailController.text});
                  }
                  if (passwordController.text != null &&
                      passwordController.text.isNotEmpty) {
                    widget.myFirebaseUser
                        .updatePassword(passwordController.text);
                  }
                  if (imageFile != null) {
                    FirebaseStorage.instance
                        .ref()
                        .child("profile_images/" + widget.myFirebaseUser.uid.toString())
                        .putFile(imageFile);
                    UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
                    userUpdateInfo.photoUrl =
                        "profile_images/" + widget.myFirebaseUser.uid.toString();
                    widget.myFirebaseUser.updateProfile(userUpdateInfo);
                  }

                  setState(() {
                    editing = false;
                    imageFile = null;
                  });
                } catch (e) {
                  print(e.toString());
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
                      editing = false;
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
