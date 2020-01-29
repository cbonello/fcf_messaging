part of 'tab_bloc.dart';

abstract class TabEvent extends Equatable {
  const TabEvent();
}

class UpdateTab extends TabEvent {
  const UpdateTab(this.tab);

  final AppTabModel tab;

  @override
  List<Object> get props => <Object>[tab];

  @override
  String toString() => 'UpdateTab { tab: $tab }';
}
