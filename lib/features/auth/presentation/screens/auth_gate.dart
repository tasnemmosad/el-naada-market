import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el_nada_market/core/di/set_up_locator.dart';
import 'package:el_nada_market/features/home/presentation/screens/home_screen.dart';
import '../manager/password_auth_cubit.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<User?> _authStream;
  late final PasswordAuthCubit _authCubit;

  bool _showRegister = false;

  @override
  void initState() {
    super.initState();

    _authStream = FirebaseAuth.instance.authStateChanges();
    _authCubit = sl<PasswordAuthCubit>();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  void _openRegister() {
    setState(() {
      _showRegister = true;
    });
  }

  void _openLogin() {
    setState(() {
      _showRegister = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return BlocProvider<PasswordAuthCubit>.value(
          value: _authCubit,
          child: _showRegister
              ? RegisterScreen(onLogin: _openLogin)
              : LoginScreen(onCreateAccount: _openRegister),
        );
      },
    );
  }
}
