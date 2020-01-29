import 'dart:io';

import 'package:fcf_messaging/repositories/authentication_repository.dart';
import 'package:fcf_messaging/repositories/firestore_repository.dart';
import 'package:fcf_messaging/repositories/hive/hive_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  final FirestoreRepository firestoreService = FirestoreRepository();

  locator.registerLazySingleton<FirestoreRepository>(() => firestoreService);
  locator.registerLazySingleton<AuthenticationRepository>(() => AuthenticationRepository(
        firestoreService: firestoreService,
      ));

  final Directory dir = await path_provider.getApplicationDocumentsDirectory();
  final HiveRepository hiveService = HiveRepository(documentDir: dir);
  await hiveService.openBoxes();
  locator.registerLazySingleton<HiveRepository>(() => hiveService);
}
