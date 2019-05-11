import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rodera/viewIncidence.dart';

import './main.dart';

class AddIncidence extends StatefulWidget {
  AddIncidence({Key key, this.user}) : super(key: key);

  final FirebaseUser user;

  @override
  _AddIncidenceState createState() => new _AddIncidenceState();
}

class _AddIncidenceState extends State<AddIncidence> {
  final titleController = TextEditingController();

  final descriptionController = TextEditingController();

  Geoflutterfire geo = Geoflutterfire();

  File _image;

  Future getImage() async {
    print("Entered image picker");
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print("Image chosen");
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<dynamic> category = null;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Incidence", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Center(
          child: Form(
              child: new ListView(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
              right: 50.0, left: 50.0, top: 15.0, bottom: 15.0),
          child: TextFormField(
            keyboardType:
                TextInputType.text, // Use email input type for emails.
            controller: titleController,
            decoration:
                new InputDecoration(hintText: 'Bache', labelText: 'Title'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
              right: 50.0, left: 50.0, top: 15.0, bottom: 15.0),
          child: TextFormField(
              keyboardType:
                  TextInputType.multiline, // Use email input type for emails.
              controller: descriptionController,
              decoration: new InputDecoration(
                  hintText: 'Bache', labelText: 'Description')),
        ),
        Container(
          margin: const EdgeInsets.only(
              right: 50.0, left: 50.0, top: 15.0, bottom: 15.0),
          child: DropdownButton<Set<dynamic>>(
            hint: Text("Choose a category"),
            items: <Set<dynamic>>[
              {"Acerado y asfaltado", Icons.directions_car, Colors.red},
              {"Alcantarillado", Icons.invert_colors, Colors.blue},
              {"Alumbrado", Icons.lightbulb_outline, Colors.amber},
              {"Limpieza", Icons.delete, Colors.purple},
              {"Mobiliario urbano", Icons.event_seat, Colors.deepOrangeAccent},
              {"Vegetación y sombra", Icons.nature_people, Colors.lightGreen},
              {"Transporte", Icons.directions_bus, Colors.pink},
              {"Otros", Icons.category, Colors.black54}
            ].map((Set<dynamic> value) {
              return new DropdownMenuItem<Set<dynamic>>(
                value: value,
                child: new Row(
                  children: <Widget>[
                    Icon(value.elementAt(1), color: value.elementAt(2)),
                    Text("  " + value.elementAt(0)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              category = value;
              print(category.elementAt(0));
            },
            value: category,
            isExpanded: true,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
              right: 50.0, left: 50.0, top: 15.0, bottom: 15.0),
          child: _image == null
              ? RaisedButton(
                  onPressed: getImage,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('Pick an image'),
                      Icon(Icons.add_a_photo)
                    ],
                  ),
                )
              : Image.file(_image, width: 150, height: 150),
        ),
        Container(
          margin: const EdgeInsets.only(
              right: 50.0, left: 50.0, top: 15.0, bottom: 15.0),
          child: _image == null
              ? RaisedButton(
                  onPressed: null,
                  child: const Text('UPLOAD'),
                )
              : RaisedButton(
                  onPressed: () async {
                    var location = new Location();
                    var currentLocation = await location.getLocation();
                    GeoFirePoint myLocation = geo.point(
                        latitude: currentLocation.latitude,
                        longitude: currentLocation.longitude);
                    DocumentReference docReference =
                        Firestore.instance.collection('Madrid').document();
                    Firestore.instance
                        .collection('locations')
                        .document(docReference.documentID.toString())
                        .setData({'position': myLocation.data});
                    docReference.setData({
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'score': 0,
                      'user': widget.user.uid,
                      'category': category.elementAt(0),
                      'position': GeoPoint(
                          currentLocation.latitude, currentLocation.longitude),
                      'comments': [],
                    });
                    FirebaseStorage.instance
                        .ref()
                        .child(docReference.documentID.toString())
                        .putFile(_image);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewIncidence(
                              title: titleController.text,
                              description: descriptionController.text,
                              score: 0,
                              reference: docReference.documentID,
                            ),
                      ),
                    );
                  },
                  color: Colors.black87,
                  textColor: Colors.white,
                  child: const Text('UPLOAD'),
                ),
        ),
      ]))),
    );
  }
}
