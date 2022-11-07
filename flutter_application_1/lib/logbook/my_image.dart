// ignore_for_file: unnecessary_null_comparison, prefer_const_constructors, unused_local_variable

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase/image_entity.dart';
import 'package:flutter_application_1/logbook/location.dart';
import 'package:flutter_application_1/logbook/route_name.dart';
import 'package:image_picker/image_picker.dart';

class MyImage extends StatefulWidget {
  const MyImage({super.key});

  @override
  State<MyImage> createState() => _MyImageState();
}

const Color green = Colors.blue;
const Color orange = Colors.blue;

class _MyImageState extends State<MyImage> {
  File? _image;
  final imagePicker = ImagePicker();
  TextEditingController txtLocation = TextEditingController();

  String? lat, long, country, local, street;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future getImage() async {
    final image = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(image!.path);
    });
    print(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera"),
        centerTitle: true,
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: Text("Home"),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text("Images "),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              Navigator.pushNamed(context, RouteNames.Welcome);
            } else if (value == 1) {
              Navigator.pushNamed(context, RouteNames.Dowload);
            }
          })
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 80),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: double.infinity,
                        margin: const EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: _image != null
                              ? Image.file(_image!)
                              : IconButton(
                                  icon: Icon(
                                    Icons.add_a_photo,
                                    color: Colors.blue,
                                    size: 50,
                                  ),
                                  onPressed: getImage,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Center(
                    child: Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                              controller: txtLocation,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                              readOnly: true,
                              onTap: () async {
                                txtLocation.text =
                                    "${local!},${street!},${country!}";
                              },
                              decoration: InputDecoration(
                                focusColor: Colors.white,
                                //add prefix icon
                                prefixIcon: Icon(
                                  Icons.location_on_sharp,
                                  color: Colors.blue.shade400,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 1.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                fillColor: Colors.grey,
                                hintText:
                                    "Click here to get the current location!",
                                //make hint text
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontFamily: "verdana_regular",
                                  fontWeight: FontWeight.w400,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontFamily: "verdana_regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                uploadImageButton(context),
              ],
            ),
          ),
        ],
      ),
      
    );
  }

  @override
  void dispose() {
    txtLocation.dispose();
    super.dispose();
  }

  void getLocation() async {
    final service = LocationService();
    final locationData = await service.getLocation();

    if (locationData != null) {
      final placeMark = await service.getPlaceMark(locationData: locationData);

      setState(() {
        lat = locationData.latitude!.toStringAsFixed(2);
        long = locationData.longitude!.toStringAsFixed(2);

        country = placeMark?.country ?? 'could not get country';
        local = placeMark?.locality ?? 'could not get local';
        street = placeMark?.street ?? 'could not get local';
      });
    }
  }

  Future<void> saveImage() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('deviceImages')
        .child('${txtLocation.text}.jpg');
    await ref.putFile(_image!);
    var url = await ref.getDownloadURL();
    print(url);
    txtLocation.clear();
  }
  
 Widget uploadImageButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () => uploadImageToFirebase(context),
        child: Text(
          "Upload Image",
          style: TextStyle(fontSize: 20,color: Colors.white),
        ),
    );
  }

  Future uploadImageToFirebase(BuildContext context) async {
    final storage = FirebaseStorage.instance.ref();
    final imagesRef = storage.child("images/${txtLocation.text}.jpg");
    try{
      await imagesRef.putFile(_image!);
      final String url  = await imagesRef.getDownloadURL();
      var anImage =
              ImageEntity.newImage(url, txtLocation.text);
          var db = FirebaseFirestore.instance;
          db
              .collection('image')
              .add(anImage.getHash())
              .then((docsnap) => {print("Add Data with ID: ${docsnap.id}")});
    }
    catch(e){
      print("Error while pushing image is $e");
    }
    txtLocation.clear();
    Navigator.pushNamed(context, RouteNames.Dowload);
  }
}
