import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:appflutter/CreateUserPage.dart';
import 'package:appflutter/MyHomePage.dart';

class LoginPage extends StatefulWidget {
  //Metodo mutable
  @override //Anular el metodo
  State createState() {
    //Se le asigna el comportamiento al widget
    return _LoginState(); //Crea la instancia login
  }
}

class _LoginState extends State<LoginPage> {
  late String email,
      password; //declaracion de variables //late se inician mas tarde
  final _formKey = GlobalKey<FormState>(); //clave para el form
  String error = '';

  @override
  void initState() {
    super.initState(); //Se inician los widget
  }

  @override
  Widget build(BuildContext context) {
    //Se crea el widget
    return Scaffold(
      //Estructura de la pagina
      appBar: AppBar(
        centerTitle: true,
        title: Text("Proyecto Flutter"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/fondoproyecto.jpg'), // Ruta de la imagen de fondo
            fit: BoxFit.cover, // Ajuste de la imagen
          ),
        ),
        child: Column(
          //Widget de columna
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Iniciar Sesión",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
            Offstage(
              //Nos muestra un error sí ese error no esta vacio
              offstage: error == '',
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: formulario(),
            ),
            butonLogin(),
            NuevaCuenta(),
            buildOrLine(), // Separador ó
            BotonesGoogle(),
          ],
        ),
      ),
    );
  }

  Widget BotonesGoogle() {
    //Este boton llama la funcion entrar
    return Column(
      children: [
        SignInButton(Buttons.Google, onPressed: () async {
          //singinbutton nos crea el boton de google
          await entrarConGoogle();
          if (FirebaseAuth.instance.currentUser != null) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
                (Route<dynamic> route) => false);
          }
        }),
      ],
    );
  }

  Future<UserCredential> entrarConGoogle() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn(); //Clase googlesingin para iniciar sesion
    final GoogleSignInAuthentication? autentication =
        await googleUser?.authentication;
    final credentials = GoogleAuthProvider.credential(
        accessToken: autentication?.accessToken,
        idToken: autentication?.idToken);
    return await FirebaseAuth.instance.signInWithCredential(
        credentials); //Devuelve las credenciales ingresadas
  }

  String sha256toString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString(); //Convierte los datos ingresados a hexa
  }

  Widget buildOrLine() {
    // Separador
    return FractionallySizedBox(
      //ajusta el tamaño
      widthFactor: 0.6,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Divider()),
          Text("ó"),
          Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget NuevaCuenta() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Usuario Nuevo ?"),
        TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateUserPage())); //Me envía a la pagina de creacion
            },
            child: Text("Registrarse")),
      ],
    );
  }

  Widget formulario() {
    //Form validar y guardar campos
    return Form(
        key: _formKey,
        child: Column(
          children: [
            buildEmail(), //campo de entrada correo
            const Padding(padding: EdgeInsets.only(top: 12)),
            buildPassword(), //campo de entrada correo
          ],
        ));
  }

  Widget buildEmail() {
    return TextFormField(
      //Campo de texto
      decoration: InputDecoration(
          //apariencia
          labelText: "Correo",
          border: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(8),
              borderSide: new BorderSide(color: Colors.black))),
      keyboardType: TextInputType.emailAddress, //Direccion de correo
      onSaved: (String? value) {
        // Se guarda en la variable
        email = value!;
      },
      validator: (value) {
        //Se verifica sí esta vacio
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
              borderRadius: new BorderRadius.circular(8),
              borderSide: new BorderSide(color: Colors.black))),
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

  Widget butonLogin() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              //Verificacion de formulario
              _formKey.currentState!.save(); // se inicia
              UserCredential? credenciales =
                  await login(email, password); //firebase auth
              if (credenciales != null) {
                if (credenciales.user != null) {
                  if (credenciales.user!.emailVerified) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyHomePage()), // se redirige a la pagina
                        (Route<dynamic> route) => false);
                  } else {
                    setState(() {
                      error = "Verifica tu correo";
                    });
                  }
                }
              }
            }
          },
          child: Text("Iniciar Sesión")),
    );
  }

  Future<UserCredential?> login(String email, String passwd) async {
    //inicio de sesion en firebase
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance //funcion de firebase
              .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      //Manejo de errores
      if (e.code == 'user-not-found') {
        //todo usuario no encontrado
        setState(() {
          error = "El usuario no existe";
        });
      }
      if (e.code == 'wrong-password') {
        //todo contrasenna incorrecta
        setState(() {
          error = "contraseña incorrecta";
        });
      }
    }
  }
}
