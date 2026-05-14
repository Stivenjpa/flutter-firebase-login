import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State createState() {
    return _CreateUserState();
  }
}

class _CreateUserState extends State<CreateUserPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String error = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proyecto Flutter"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/fondoproyecto.jpg'), // Ruta de la imagen de fondo
            fit: BoxFit.cover, // Ajuste de la imagen
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Registrarse",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
            Offstage(
              offstage: error == '',
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: formulario(),
            ),
            butonCrearUsuario(),
          ],
        ),
      ),
    );
  }

  Widget formulario() {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            buildEmail(),
            const Padding(padding: EdgeInsets.only(top: 12)),
            buildPassword(),
          ],
        ));
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Correo",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black))),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value) {
        email = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Contraseña",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black))),
      obscureText: true,
      validator: (value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
      onSaved: (String? value) {
        password = value!;
      },
    );
  }

  Widget butonCrearUsuario() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              //verificacion de formulario
              _formKey.currentState!.save();
              UserCredential? credenciales =
                  await crear(email, password); //funcion de firebase para crear
              if (credenciales != null) {
                if (credenciales.user != null) {
                  await credenciales.user!
                      .sendEmailVerification(); //funcion de firebase para enviar el correo de verificacion
                  Navigator.of(context).pop();
                }
              }
            }
          },
          child: const Text("Registrarse")),
    );
  }

  Future<UserCredential?> crear(String email, String passwd) async {
    //Async para que se ejecute de manera asincrona, lo que quiere decir que no para el flujo de la aplicacion
    try {
      UserCredential userCredential = await FirebaseAuth
          .instance //await espera el resultado
          .createUserWithEmailAndPassword(
              email: email,
              password: password); //instancio de firebase para crear el usuario
      return userCredential;
    } on FirebaseAuthException catch (e) {
      //Manejo de errores
      if (e.code == 'email-already-in-use') {
        //todo correo en uso
        setState(() {
          error = "El correo ya se encuentra en uso";
        });
      }
      if (e.code == 'weak-password') {
        //todo contrasenna muy debil
        setState(() {
          error = "contraseña debil";
        });
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
