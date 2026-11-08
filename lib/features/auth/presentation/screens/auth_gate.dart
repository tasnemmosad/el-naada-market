

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  late final PasswordAuthCubit _authCubit;

  bool _showRegister = false;
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();

    _authCubit = sl<PasswordAuthCubit>();

    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final storage = sl<FlutterSecureStorage>();
    final dio = sl<Dio>();

    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isAuthenticated = false;
          _isChecking = false;
        });

        return;
      }

      await dio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;

      setState(() {
        _isAuthenticated = true;
        _isChecking = false;
      });
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        await storage.delete(key: 'auth_token');
      }

      if (!mounted) return;

      setState(() {
        _isAuthenticated = false;
        _isChecking = false;
      });
    }
  }

  void _onAuthenticated() {
    if (!mounted) return;

    setState(() {
      _isAuthenticated = true;
    });
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
Future<void> _onLogout() async {
  final storage = sl<FlutterSecureStorage>();

  await storage.delete(key: 'auth_token');

  if (!mounted) return;

  setState(() {
    _isAuthenticated = false;
    _showRegister = false;
  });
}
  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

  if (_isAuthenticated) {
  return HomeScreen(
    onLogout: _onLogout,
  );
}

    return BlocProvider<PasswordAuthCubit>.value(
      value: _authCubit,
      child: _showRegister
          ? RegisterScreen(
              onLogin: _openLogin,
              onAuthenticated: _onAuthenticated,
            )
          : LoginScreen(
              onCreateAccount: _openRegister,
              onAuthenticated: _onAuthenticated,
            ),
    );
  }
}
