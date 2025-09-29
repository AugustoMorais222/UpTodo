import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email == "admin" && password == "123") {
      Fluttertoast.showToast(
      msg: "Login bem-sucedido!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP_RIGHT,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      webBgColor: "#00b09b",
      fontSize: 16.0,
    );
    Navigator.pushReplacementNamed(context, '/on_boarding');
    } else {
      Fluttertoast.showToast(
      msg: "Credenciais inválidas!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP_RIGHT,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      webBgColor: "#ff5f6d",
      fontSize: 16.0,
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 80, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    "Bem-vindo",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Entrar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
