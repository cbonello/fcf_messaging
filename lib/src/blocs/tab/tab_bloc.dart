import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fcf_messaging/src/models/app_tabs_model.dart';
import 'package:meta/meta.dart';

part 'tab_event.dart';

class TabBloc extends Bloc<TabEvent, AppTabModel> {
  TabBloc({@required AppTabModel initialTab}) : _initialTab = initialTab;

  final AppTabModel _initialTab;

  @override
  AppTabModel get initialState => _initialTab;

  @override
  Stream<AppTabModel> mapEventToState(
    TabEvent event,
  ) async* {
    if (event is UpdateTab) {
      yield event.tab;
    }
  }
}
