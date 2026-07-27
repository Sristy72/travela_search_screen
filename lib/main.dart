import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:travela_search_screen/features/property_search/views/property_search_screen.dart';
import 'package:travela_search_screen/features/screens/home_screen.dart';

import 'core/init/app_initializer.dart';
import 'core/theme/app_theme.dart';

void main() async {
  await AppInitializer.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.light,
      home: PropertySearchScreen(),
    );
  }
}