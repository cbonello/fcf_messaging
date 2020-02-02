import 'package:fcf_messaging/src/repositories/authentication_repository.dart';
import 'package:fcf_messaging/src/repositories/cache_repository.dart';
import 'package:fcf_messaging/src/repositories/chats_repository.dart';
import 'package:fcf_messaging/src/repositories/contacts_repository.dart';
import 'package:fcf_messaging/src/repositories/hive/hive_repository.dart';
import 'package:fcf_messaging/src/repositories/messages_repository.dart';
import 'package:fcf_messaging/src/repositories/users_repository.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationRepository extends Mock implements AuthenticationRepository {}

class MockCacheRepository extends Mock implements CacheRepository {}

class MockChatsRepository extends Mock implements ChatsRepository {}

class MockContactsRepository extends Mock implements ContactsRepository {}

class MockHiveRepository extends Mock implements HiveRepository {}

class MockMessagesRepository extends Mock implements MessagesRepository {}

class MockUsersRepository extends Mock implements UsersRepository {}
