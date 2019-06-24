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
  String dropdownValue = null;

  Future getImage() async {
    print("Entered image picker");
    var image = await ImagePicker.pickImage(source: ImageSource.gallery,maxHeight: 600, maxWidth: 600);
    print("Image chosen");
    setState(() {
      _image = image;
    });
  }

  Icon getIcon(String value) {
    switch (value) {
      case "Acerado y asfaltado":
        return Icon(Icons.directions_car, color: Colors.red);
        break;
      case "Alcantarillado":
        return Icon(Icons.invert_colors, color: Colors.blue);
        break;
      case "Alumbrado":
        return Icon(Icons.lightbulb_outline, color: Colors.amber);
        break;
      case "Limpieza":
        return Icon(Icons.delete, color: Colors.purple);
        break;
      case "Mobiliario urbano":
        return Icon(Icons.event_seat, color: Colors.deepOrangeAccent);
        break;
      case "Vegetación y sombra":
        return Icon(Icons.nature_people, color: Colors.lightGreen);
        break;
      case "Transporte":
        return Icon(Icons.directions_bus, color: Colors.pink);
        break;
      case "Otros":
        return Icon(Icons.category, color: Colors.black54);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: new InputDecoration(
                hintText: 'Write the title here...', labelText: 'Title'),
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
                  hintText: 'Write the description here...',
                  labelText: 'Description')),
        ),
        Container(
          margin: const EdgeInsets.only(
              right: 50.0, left: 50.0, top: 15.0, bottom: 15.0),
          child: DropdownButton<String>(
            hint: Text("Choose a category"),
            value: dropdownValue,
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: <String>["Acerado y asfaltado", "Alcantarillado", "Alumbrado", "Limpieza", "Mobiliario urbano", "Vegetación y sombra", "Transporte", "Otros"]
                .map<DropdownMenuItem<String>>((String value) {

              return DropdownMenuItem<String>(
                value: value,
                child: new Row(
                  children: <Widget>[
                    getIcon(value),
                    Text("  " + value),
                  ],
                ),
              );
            })
                .toList(),
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
                        Firestore.instance.collection('incidences').document();
                    Firestore.instance
                        .collection('locations')
                        .document(docReference.documentID.toString())
                        .setData({'position': myLocation.data});
                    docReference.setData({
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'score': 0,
                      'user': widget.user.uid,
                      'category': dropdownValue,
                      'position': GeoPoint(
                          currentLocation.latitude, currentLocation.longitude),
                      'comments': [],
                    });
                    FirebaseStorage.instance
                        .ref()
                        .child(docReference.documentID.toString())
                        .putFile(_image);
                    Navigator.pop(context);
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
