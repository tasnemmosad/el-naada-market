// import 'package:el_nada_market/features/auth/presentation/manager/password_auth_state.dart';
// import 'package:el_nada_market/features/cart/manager/cart_cubit.dart';
// import 'package:el_nada_market/features/products/presentation/screens/fruits_screen.dart';
// import 'package:el_nada_market/features/products/presentation/screens/vegetables_screen.dart';
// import 'package:el_nada_market/features/profile/presentation/profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:el_nada_market/core/di/set_up_locator.dart';
// import 'package:el_nada_market/features/home/presentation/screens/home_screen.dart';
// import '../manager/password_auth_cubit.dart';
// import 'login_screen.dart';
// import 'register_screen.dart';
// class AuthGate extends StatefulWidget {
//   const AuthGate({super.key});

//   @override
//   State<AuthGate> createState() => _AuthGateState();
// }

// class _AuthGateState extends State<AuthGate> {
//   late final PasswordAuthCubit _authCubit;

//   bool _showRegister = false;
//   bool _isChecking = true;
//   bool _isAuthenticated = false;

//   @override
//   void initState() {
//     super.initState();
//     _authCubit = sl<PasswordAuthCubit>();
//     _checkAuthentication();
//   }

//   Future<void> _checkAuthentication() async {
//     final storage = sl<FlutterSecureStorage>();
//     final dio = sl<Dio>();

//     try {
//       final token = await storage.read(key: 'auth_token');

//       if (token == null || token.isEmpty) {
//         if (!mounted) return;

//         setState(() {
//           _isAuthenticated = false;
//           _isChecking = false;
//         });

//         return;
//       }

//       await dio.get(
//         '/auth/me',
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );

//       if (!mounted) return;

//       setState(() {
//         _isAuthenticated = true;
//         _isChecking = false;
//       });
//     } on DioException catch (error) {
//       final statusCode = error.response?.statusCode;

//       if (statusCode == 401 || statusCode == 403) {
//         await storage.delete(key: 'auth_token');
//       }

//       if (!mounted) return;

//       setState(() {
//         _isAuthenticated = false;
//         _isChecking = false;
//       });
//     }
//   }
// void _onAuthenticated() {
//   if (!mounted) return;

//   // Start with a fresh cart for the new session
//   sl<CartCubit>().clearCart();

//   setState(() {
//     _isAuthenticated = true;
//   });
// }
//   void _openRegister() {
//     setState(() {
//       _showRegister = true;
//     });
//   }

//   void _openLogin() {
//     setState(() {
//       _showRegister = false;
//     });
//   }
// // Future<void> _onLogout() async {
// //   final storage = sl<FlutterSecureStorage>();

// //   // Clear current user's cart
// //   sl<CartCubit>().clearCart();

// //   await storage.delete(key: 'auth_token');

// //   if (!mounted) return;

// //   setState(() {
// //     _isAuthenticated = false;
// //     _showRegister = false;
// //   });
// // }
//  Future<void> _onLogout() async {
//   await _authCubit.logout();

//   if (!mounted) return;

//   if (_authCubit.state is PasswordAuthError) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           (_authCubit.state as PasswordAuthError).message,
//         ),
//       ),
//     );
//     return;
//   }

//   // Clear current user's cart
//   sl<CartCubit>().clearCart();

//   setState(() {
//     _isAuthenticated = false;
//     _showRegister = false;
//   });
// }
//   @override
//   void dispose() {
//     _authCubit.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isChecking) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (_isAuthenticated) {
//       return HomeScreen(
//         onLogout: _onLogout,
//         onFruits: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const FruitsScreen()),
//           );
//         },
//         onVegetables: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const VegetablesScreen()),
//           );
//         },
//         onProfile: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const ProfileScreen()),
//           );
//         },
//       );
//     }

//     // }

//     return BlocProvider<PasswordAuthCubit>.value(
//       value: _authCubit,
//       child: _showRegister
//           ? RegisterScreen(
//               onLogin: _openLogin,
//               onAuthenticated: _onAuthenticated,
//             )
//           : LoginScreen(
//               onCreateAccount: _openRegister,
//               onAuthenticated: _onAuthenticated,
//             ),
//     );
//   }
// }

import 'package:el_nada_market/features/auth/domain/entities/auth_user.dart';
import 'package:el_nada_market/features/auth/presentation/manager/password_auth_state.dart';
import 'package:el_nada_market/features/cart/manager/cart_cubit.dart';
import 'package:el_nada_market/features/products/presentation/screens/fruits_screen.dart';
import 'package:el_nada_market/features/products/presentation/screens/vegetables_screen.dart';
import 'package:el_nada_market/features/profile/presentation/manager/profile_cubit.dart';
import 'package:el_nada_market/features/profile/presentation/profile_screen.dart';
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

  AuthUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<PasswordAuthCubit>();
    _checkAuthentication();
  }

  // Read current user from backend
  Future<AuthUser> _fetchCurrentUser() async {
    final storage = sl<FlutterSecureStorage>();
    final dio = sl<Dio>();

    final token = await storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) {
      throw const FormatException('Authentication token is missing');
    }

    final response = await dio.get<Map<String, dynamic>>(
      '/auth/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final data = response.data;
    final userData = data?['user'];

    if (userData is! Map<String, dynamic>) {
      throw const FormatException('User data is missing');
    }

    final id = userData['id'];
    final phone = userData['phone'];
    final nickname = userData['nickname'];
    final type = userData['type'];

    if (id is! int || phone is! String || type is! String) {
      throw const FormatException('Invalid user data');
    }

    return AuthUser(
      id: id,
      phone: phone,
      nickname: nickname is String ? nickname : '',
      type: type,
    );
  }

  // Check saved authentication session
  Future<void> _checkAuthentication() async {
    final storage = sl<FlutterSecureStorage>();

    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          _currentUser = null;
          _isAuthenticated = false;
          _isChecking = false;
        });

        return;
      }

   final user = await _fetchCurrentUser();

// تحميل سلة المستخدم من قاعدة البيانات
try {
  await sl<CartCubit>().loadBasket();
} catch (error) {
  debugPrint('Loading basket error: $error');
}

if (!mounted) return;

setState(() {
  _currentUser = user;
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
    _currentUser = null;
    _isAuthenticated = false;
    _isChecking = false;
  });
} catch (error) {
  debugPrint('Authentication check error: $error');

  if (!mounted) return;

  setState(() {
    _currentUser = null;
    _isAuthenticated = false;
    _isChecking = false;
  });
}
  }

  // Called after successful login or registration
  void _onAuthenticated() async {
    if (!mounted) return;

    try {
      final user = await _fetchCurrentUser();

      if (!mounted) return;

      sl<CartCubit>().clearCart();

      setState(() {
        _currentUser = user;
        _isAuthenticated = true;
      });
    } catch (error) {
      debugPrint('Loading user data error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحميل بيانات المستخدم. يرجى المحاولة مرة أخرى.'),
        ),
      );
    }
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

  // Logout
  Future<void> _onLogout() async {
    await _authCubit.logout();

    if (!mounted) return;

    if (_authCubit.state is PasswordAuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (_authCubit.state as PasswordAuthError).message,
          ),
        ),
      );
      return;
    }

    sl<CartCubit>().clearCart();

    setState(() {
      _currentUser = null;
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated && _currentUser != null) {
   return HomeScreen(
  user: _currentUser!,
  onLogout: _onLogout,
        onFruits: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FruitsScreen(),
            ),
          );
        },
        onVegetables: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VegetablesScreen(),
            ),
          );
        },
    
onProfile: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => sl<ProfileCubit>()..getProfile(),
        child: ProfileScreen(
          user: _currentUser!,
        ),
      ),
    ),
  );
},

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
