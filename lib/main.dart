import 'package:appflutter/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

//Se inicializa la aplicacion
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Verifica widgets
  await Firebase.initializeApp(); //inicializa firebase
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //MaterialApp contiene la estructura principal de la aplicacion
      debugShowCheckedModeBanner: false,
      title: "Login Proyecto Flutter",
      home: LoginPage(), //pagina de inicio
    );
  }
}
