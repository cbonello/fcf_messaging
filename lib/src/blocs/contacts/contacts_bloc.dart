import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/cache_repository.dart';
import 'package:fcf_messaging/src/utils/exceptions.dart';
import 'package:meta/meta.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc({@required CacheRepositoryContactsInterface cache}) : _cache = cache {
    _cacheSub = _cache.readUnregisteredUsers().listen(
      (List<UserModel> contacts) {
        add(ContactsReceivedFromCache(contacts));
      },
    );
  }

  final CacheRepositoryContactsInterface _cache;
  StreamSubscription<List<UserModel>> _cacheSub;

  @override
  ContactsState get initialState => Uninitialized();

  @override
  Stream<ContactsState> mapEventToState(
    ContactsEvent event,
  ) async* {
    if (event is AddContact) {
      yield* mapAddContactEventToState(event);
    } else if (event is ContactsReceivedFromCache) {
      yield* mapContactsReceivedFromCacheEventToState(event);
    }
  }

  Stream<ContactsState> mapAddContactEventToState(AddContact event) async* {
    try {
      await _cache.addUnregisteredUser(event.contact);
    } catch (e) {
      yield ContactsError(AppException.from(e));
    }
  }

  Stream<ContactsState> mapContactsReceivedFromCacheEventToState(
    ContactsReceivedFromCache event,
  ) async* {
    try {
      event.contacts.sort((UserModel a, UserModel b) {
        return a.name.compareTo(b.name);
      });
      yield ContactsFetched(event.contacts);
    } catch (e) {
      yield ContactsError(AppException.from(e));
    }
  }

  @override
  Future<void> close() async {
    await _cacheSub?.cancel();
    return super.close();
  }
}
