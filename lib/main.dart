import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:threadup/Core/Theme/pallete.dart';
import 'package:threadup/routes/router.dart';
import 'firebase_options.dart';
void main() async {
  debugPrint("Firebase Initialing...");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
  debugPrint("Firebase Initialized...");
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: Pallete.lightModeAppTheme,
      darkTheme: Pallete.darkModeAppTheme,
      themeMode: ThemeMode.system,
      title: "ThreadUP",
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) => loggedOutRoute),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}