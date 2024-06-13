import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'details_page.dart';
import 'input_page.dart';
import 'default_firebase_options.dart'; // Import the default Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with default options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('already exists')) {
      // if already exists, skip initialization
    } else {
      rethrow; // rethrow if it is a different error
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vcf',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/input': (context) => const InputPage(), // Route to InputPage
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute<dynamic>(
            builder: (context) {
              return DetailsPage(
                email: args['email']!,
                password: args['password']!,
              );
            },
          ) as Route<dynamic>;
        }
        return null;
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to InputPage after a delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/input');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo.png', // Use local asset image
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
