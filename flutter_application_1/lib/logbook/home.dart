// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/logbook/route_name.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log-book"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/cartoon.png',
                      width: 250.0,
                      height: 150.0,
                      fit: BoxFit.cover,
                    ),
                  ),
               const Padding(
                    padding: EdgeInsets.only(
                        left: 16, top: 32, right: 16, bottom: 8),
                    child: Text(
                      'Welcome to the Logbook!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    child: Text(
                      'Capture every moment with us',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
                    child:OutlinedButton.icon(
                      label: const Text(
                        'Capture images from your device',
                        style: TextStyle(
                            color:Colors.black,
                            fontSize: 16),
                      ),
                      icon: Icon(Icons.camera_alt_rounded),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),),
                      ),
                      
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.MyImage);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 40.0, left: 40.0, top: 20, bottom: 20),
                    child: OutlinedButton.icon(
                      
                      icon: Icon(Icons.download_for_offline_outlined),
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.Dowload);
                      },
                      label: const Text(
                        'Capture images from the internet',
                        style: TextStyle(
                            color: Colors.black ,
                            fontSize: 16,),
                      ),
                      style: ButtonStyle(
                        
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.only(top: 12, bottom: 12),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                  )
                ],   
      ),
    )
    );
  }
}