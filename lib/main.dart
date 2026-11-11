
import 'package:el_nada_market/features/cart/manager/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:el_nada_market/core/di/set_up_locator.dart';
import 'package:el_nada_market/core/theme/app_theme.dart';
import 'package:el_nada_market/features/auth/presentation/screens/auth_gate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();

  runApp(const ElNadaMarket());
}

class ElNadaMarket extends StatelessWidget {
  const ElNadaMarket({super.key});

  @override
  Widget build(BuildContext context) {
 return BlocProvider<CartCubit>.value(
  value: sl<CartCubit>(),
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'خضروات وفواكه الندى',
    theme: AppTheme.lightTheme,
    home: const AuthGate(),
  ),
);
  }
}
