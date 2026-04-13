import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/dependency_injection.dart';
import 'env/env_config.dart';
import 'core/services/background_task_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Validate and load environment
  EnvConfig.validate();
  
  // Initialize all dependencies (Hive, Database, Services, Repositories, Blocs)
  await initDependencyInjection();

  // Initialize background tasks
  final backgroundService = BackgroundTaskService();
  await backgroundService.init();
  await backgroundService.schedulePeriodicSync();

  
  runApp(const App());
}
