import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage
  await StorageService.init();
  
  runApp(
    const ProviderScope(
      child: SmartHubApp(),
    ),
  );
}
