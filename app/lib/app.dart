import 'package:flutter/material.dart';
import 'features/auth/presentation/splash_screen.dart';


class ChamaWiseApp extends StatelessWidget {
const ChamaWiseApp({super.key});


@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'ChamaWise',
theme: ThemeData(primarySwatch: Colors.green),
home: const SplashScreen(),
debugShowCheckedModeBanner: false,
);
}
}