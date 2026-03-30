import 'package:flutter/material.dart';
import 'router.dart';

class CodeNyxApp extends StatelessWidget {
  const CodeNyxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CodeNyx',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
