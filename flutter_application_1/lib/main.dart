import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/logbook/dowload.dart';
import 'package:flutter_application_1/logbook/home.dart';
import 'package:flutter_application_1/logbook/my_image.dart';
import 'package:flutter_application_1/logbook/route_name.dart';
import 'firebase_options.dart';

// void main() {
//   runApp(const MyApp());
// }

Future main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      runApp(const MyApp());
    }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        RouteNames.Welcome : (context) => const Welcome(),
        RouteNames.MyImage:(context) => const MyImage(),
        RouteNames.Dowload:(context) => const Dowload()
      },
      initialRoute: RouteNames.Welcome,
    );
  }
  
}