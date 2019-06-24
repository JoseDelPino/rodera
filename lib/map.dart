import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:rodera/viewIncidence.dart';
import 'package:rodera/main.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController mapController;
  Geoflutterfire geo = Geoflutterfire();
  Location location = new Location();
  Set<Marker> markers = new Set<Marker>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(

        mapType: MapType.normal,
        myLocationEnabled: true,
        markers: markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 13,
        ),
        onMapCreated: (GoogleMapController controller) {
          _onMapCreated(controller);
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    var position = await location.getLocation();

    GeoFirePoint center = geo.point(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(
          collectionRef: Firestore.instance.collection('locations'),
        )
        .within(center: center, radius: 30, field: 'position');

    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((DocumentSnapshot document) async {
        GeoPoint point = document.data['position']['geopoint'];

        Firestore.instance
            .collection('incidences')
            .document(document.documentID)
            .get()
            .then((incidence) {

          print("Se ha querieado el docuemento: " +
              document.documentID.toString());
          print("como resultado se ha obtenido la incidencia: " +
              incidence.data.toString());
          Marker marker = Marker(
              markerId: MarkerId(
                  point.latitude.toString() + point.longitude.toString()),
              position: LatLng(point.latitude, point.longitude),
              infoWindow: InfoWindow(
                  title: incidence.data['title'],
                  snippet: incidence.data['description']));


          setState(() {
            markers.add(marker);
          });
        });
      });
    });

    setState(() {
      mapController = controller;
    });

    controller.moveCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
  }
}
