import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'details_page.dart';

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late SharedPreferences _prefs;
  bool _isLoggedIn = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final savedEmail = _prefs.getString('email');
    final savedPassword = _prefs.getString('password');
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _isLoggedIn = true;
      });
      _navigateToDetailsPage(savedEmail, savedPassword);
    }
  }

  Future<void> _navigateToDetailsPage(String email, String password) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          email: email,
          password: password,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(245, 223, 214, 254),
      ),
      backgroundColor: Color.fromARGB(246, 29, 6, 110),
      body: _isLoggedIn
          ? Container()
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 0), // Add top padding
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'assets/icon.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      obscureText: _obscureText,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        String email = _emailController.text.trim();
                        String password = _passwordController.text.trim();
                        if (email.isNotEmpty && password.isNotEmpty) {
                          await _prefs.setString('email', email);
                          await _prefs.setString('password', password);
                          _navigateToDetailsPage(email, password);
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(133, 80, 53, 255),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
