import 'dart:io';

import 'package:fcf_messaging/src/repositories/authentication_repository.dart';
import 'package:fcf_messaging/src/repositories/chats_repository.dart';
import 'package:fcf_messaging/src/repositories/contacts_repository.dart';
import 'package:fcf_messaging/src/repositories/hive/hive_repository.dart';
import 'package:fcf_messaging/src/repositories/messages_repository.dart';
import 'package:fcf_messaging/src/repositories/users_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  final ChatsRepository chatsRepository = ChatsRepository();
  locator.registerLazySingleton<ChatsRepository>(() => chatsRepository);

  final ContactsRepository ontactsRepository = ContactsRepository();
  locator.registerLazySingleton<ContactsRepository>(() => ontactsRepository);

  final MessagesRepository messagesRepository = MessagesRepository();
  locator.registerLazySingleton<MessagesRepository>(() => messagesRepository);

  final UsersRepository usersRepository = UsersRepository();
  locator.registerLazySingleton<UsersRepository>(() => usersRepository);

  final AuthenticationRepository authRepository = AuthenticationRepository(
    usersRepository: usersRepository,
  );
  locator.registerLazySingleton<AuthenticationRepository>(() => authRepository);

  final Directory dir = await path_provider.getApplicationDocumentsDirectory();
  final HiveRepository hiveService = HiveRepository(documentDir: dir);
  await hiveService.openBoxes();
  locator.registerLazySingleton<HiveRepository>(() => hiveService);
}
