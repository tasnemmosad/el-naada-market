import 'package:el_nada_market/core/di/set_up_locator.dart';
import 'package:el_nada_market/features/auth/presentation/screens/auth_gate.dart';
import 'package:flutter/material.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupServiceLocator();

  runApp(const ElNadaMarket());
}

class ElNadaMarket extends StatelessWidget {
  const ElNadaMarket({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'خضروات وفواكه الندى',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFFFFFEF9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF19813E)),
      ),

      // home: BlocProvider(
      //   create: (_) => sl<PhoneAuthCubit>(),
      //   // child: const LoginScreen(),
      //   child: const AuthGate(),
      // ),
      home: const AuthGate(),
    );
  }
}
